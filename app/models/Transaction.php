<?php
declare(strict_types=1);

class Transaction {
    public function __construct(private PDO $db) {
        $this->ensureServiceOrderColumn();
    }

    private function ensureServiceOrderColumn(): void {
        static $ready = false;
        if ($ready) return;

        $columns = $this->db->query('SHOW COLUMNS FROM transactions')->fetchAll(PDO::FETCH_COLUMN);
        if (!in_array('service_order_number', $columns, true)) {
            $this->db->exec('ALTER TABLE transactions ADD COLUMN service_order_number INT UNSIGNED NULL AFTER client_id');
        }

        $indexes = $this->db->query('SHOW INDEX FROM transactions')->fetchAll();
        $hasIndex = false;
        foreach ($indexes as $index) {
            if (($index['Key_name'] ?? '') === 'idx_transactions_service_order') {
                $hasIndex = true;
                break;
            }
        }
        if (!$hasIndex) {
            $this->db->exec('ALTER TABLE transactions ADD INDEX idx_transactions_service_order(service_order_number)');
        }

        $ready = true;
    }

    public function find(int $id, string $kind): ?array {
        $st = $this->db->prepare('SELECT t.*, c.name AS client_name FROM transactions t LEFT JOIN clients c ON c.id=t.client_id WHERE t.id=? AND t.kind=?');
        $st->execute([$id,$kind]);
        return $st->fetch() ?: null;
    }

    public function monthly(string $month): array {
        $st = $this->db->prepare('SELECT t.*, c.name AS client_name FROM transactions t LEFT JOIN clients c ON c.id=t.client_id WHERE t.period_month=? ORDER BY t.transaction_date DESC, t.id DESC');
        $st->execute([month_start($month)]);
        $rows=$st->fetchAll();
        $out=['entrada'=>[],'saida'=>[]];
        foreach($rows as $row) $out[$row['kind']][]=$row;
        return $out;
    }

    public function monthlySummary(string $month): array {
        $st = $this->db->prepare(
            "SELECT kind,
                COALESCE(SUM(CASE WHEN status='Pago' THEN amount ELSE 0 END),0) AS paid_total,
                COALESCE(SUM(amount),0) AS total
             FROM transactions
             WHERE period_month=?
             GROUP BY kind"
        );
        $st->execute([month_start($month)]);
        $summary = [
            'entrada' => ['paid' => 0.0, 'total' => 0.0, 'difference' => 0.0],
            'saida' => ['paid' => 0.0, 'total' => 0.0, 'difference' => 0.0],
        ];
        foreach ($st->fetchAll() as $row) {
            $kind = (string)$row['kind'];
            if (!isset($summary[$kind])) continue;
            $summary[$kind]['paid'] = (float)$row['paid_total'];
            $summary[$kind]['total'] = (float)$row['total'];
            $summary[$kind]['difference'] = $summary[$kind]['paid'] - $summary[$kind]['total'];
        }
        return $summary;
    }

    public function evolution(string $currentMonth): array {
        $start = (new DateTime(month_start($currentMonth)))->modify('-5 months');
        $months=[];

        $st=$this->db->prepare("
            SELECT
                kind,
                COALESCE(SUM(amount),0) AS total,
                COALESCE(SUM(CASE WHEN status='Pago' THEN amount ELSE 0 END),0) AS paid_total
            FROM transactions
            WHERE period_month=?
            GROUP BY kind
        ");

        for($i=0;$i<7;$i++){
            $m=$start->format('Y-m-01');
            $in=0.0;
            $out=0.0;
            $st->execute([$m]);

            foreach($st->fetchAll() as $row){
                // Os seis primeiros meses (incluindo o mês atual) são realizados: somente Pago.
                // O sétimo mês é previsão: Pago + Pendente.
                $value = ($i === 6)
                    ? (float)$row['total']
                    : (float)$row['paid_total'];

                if($row['kind']==='entrada'){
                    $in=$value;
                } else {
                    $out=$value;
                }
            }

            $months[]=[
                'month'=>$m,
                'label'=>month_label($m),
                'entrada'=>$in,
                'saida'=>$out,
                'balanco'=>$in-$out
            ];

            $start->modify('+1 month');
        }

        return $months;
    }

    public function currentBalance(string $month): float {
        $st=$this->db->prepare("
            SELECT COALESCE(
                SUM(
                    CASE
                        WHEN kind='entrada' AND status='Pago' THEN amount
                        WHEN kind='saida' AND status='Pago' THEN -amount
                        ELSE 0
                    END
                ),
                0
            )
            FROM transactions
            WHERE period_month=?
        ");
        $st->execute([month_start($month)]);
        return (float)$st->fetchColumn();
    }

    public function allTime(string $throughMonth): float {
        $st=$this->db->prepare("
            SELECT COALESCE(
                SUM(
                    CASE
                        WHEN kind='entrada' AND status='Pago' THEN amount
                        WHEN kind='saida' AND status='Pago' THEN -amount
                        ELSE 0
                    END
                ),
                0
            )
            FROM transactions
            WHERE period_month<=?
        ");
        $st->execute([month_start($throughMonth)]);
        return (float)$st->fetchColumn();
    }

    public function latest(int $limit=15): array {
        $limit=max(1,min(50,$limit));
        return $this->db->query("SELECT t.*, c.name AS client_name FROM transactions t LEFT JOIN clients c ON c.id=t.client_id ORDER BY t.transaction_date DESC, t.id DESC LIMIT {$limit}")->fetchAll();
    }

    public function monthsAvailable(): array {
        $rows=$this->db->query('SELECT DISTINCT period_month FROM transactions ORDER BY period_month')->fetchAll(PDO::FETCH_COLUMN);
        $values=array_map(fn($v)=>month_start((string)$v),$rows);
        $current=date('Y-m-01'); if(!in_array($current,$values,true))$values[]=$current;
        $values=array_values(array_unique($values)); sort($values);
        if(!$values) $values=[$current];
        $min=new DateTime($values[0]); $max=new DateTime(end($values));
        $min->modify('-1 month'); $max->modify('+1 month'); $months=[];
        while($min <= $max){$months[]=$min->format('Y-m-01');$min->modify('+1 month');}
        return $months;
    }

    public function serviceOrder(int $id): ?array {
        $st = $this->db->prepare(
            "SELECT
                t.*,
                c.name AS client_name,
                c.phone AS client_phone,
                c.email AS client_email,
                c.address AS client_address,
                c.number AS client_number,
                c.complement AS client_complement,
                c.state AS client_state,
                c.city AS client_city,
                CASE
                    WHEN t.payment_method = 'Cartão de Crédito'
                         AND t.installment_number = 1
                    THEN DATE_SUB(t.transaction_date, INTERVAL 1 MONTH)
                    ELSE t.transaction_date
                END AS service_order_date
             FROM transactions t
             LEFT JOIN clients c ON c.id=t.client_id
             WHERE t.id=? AND t.kind='entrada'"
        );
        $st->execute([$id]);
        return $st->fetch() ?: null;
    }

    public function serviceOrders(): array {
        $st = $this->db->query(
            "SELECT
                t.*,
                c.name AS client_name,
                CASE
                    WHEN t.payment_method = 'Cartão de Crédito'
                         AND t.installment_number = 1
                    THEN DATE_SUB(t.transaction_date, INTERVAL 1 MONTH)
                    ELSE t.transaction_date
                END AS service_order_date
             FROM transactions t
             LEFT JOIN clients c ON c.id=t.client_id
             WHERE t.kind='entrada'
               AND (
                    t.payment_method <> 'Cartão de Crédito'
                    OR t.payment_method IS NULL
                    OR t.installment_number = 1
               )
             ORDER BY service_order_date DESC, t.id DESC"
        );
        return $st->fetchAll();
    }

    private function nextServiceOrderNumber(): int {
        $lockName = 'confi_service_order_number';
        $stmt = $this->db->prepare('SELECT GET_LOCK(?, 10)');
        $stmt->execute([$lockName]);
        $lock = (int) $stmt->fetchColumn();
        if ($lock !== 1) {
            throw new RuntimeException('Não foi possível reservar o próximo número da ordem de serviço.');
        }

        try {
            $next = (int) $this->db->query(
                "SELECT COALESCE(MAX(service_order_number), 0) + 1
                 FROM transactions
                 WHERE kind='entrada'"
            )->fetchColumn();
            return max(1, $next);
        } finally {
            $release = $this->db->prepare('SELECT RELEASE_LOCK(?)');
            $release->execute([$lockName]);
        }
    }

    public function createOrReplace(array $data, string $kind, int $id=0): int {
        if($id>0) {
            $st=$this->db->prepare('UPDATE transactions SET client_id=?, item=?, amount=?, payment_method=?, installments=?, brand=?, status=?, transaction_date=?, period_month=?, original_date=? WHERE id=? AND kind=?');
            $st->execute([$data['client_id'],$data['item'],$data['amount'],$data['payment_method'],$data['installments'],$data['brand'],$data['status'],$data['transaction_date'],month_start($data['transaction_date']),$data['original_date'],$id,$kind]);
            return $id;
        }
        $method=$data['payment_method'];
        $date=$data['transaction_date'];
        $total=(float)$data['amount'];
        $notes=$data['notes'] ?? null;
        $installments=$method==='Cartão de Crédito' ? installment_count($data['installments']) : 1;
        $serviceOrderNumber = $kind === 'entrada' ? $this->nextServiceOrderNumber() : null;

        if($method==='Cartão de Crédito'){
            $status='Pendente';
            $values=split_installments($total,$installments);
            $group=bin2hex(random_bytes(16));
            $st=$this->db->prepare('INSERT INTO transactions(kind,client_id,service_order_number,item,amount,payment_method,installments,brand,status,transaction_date,period_month,notes,installment_group,installment_number,installment_total,original_date) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)');
            $firstId=0;
            foreach($values as $idx=>$value){
                $due=add_month_same_day($date,$idx+1);
                $st->execute([$kind,$data['client_id'],$serviceOrderNumber,$data['item'],$value,$method,$data['installments'],$data['brand'],$status,$due,month_start($due),$notes,$group,$idx+1,$installments,$date]);
                if($firstId===0)$firstId=(int)$this->db->lastInsertId();
            }
            return $firstId;
        }
        $st=$this->db->prepare('INSERT INTO transactions(kind,client_id,service_order_number,item,amount,payment_method,installments,brand,status,transaction_date,period_month,notes,original_date) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?)');
        $st->execute([$kind,$data['client_id'],$serviceOrderNumber,$data['item'],$total,$method,$data['installments'],'',$data['status'],$date,month_start($date),$notes,$date]);
        return (int)$this->db->lastInsertId();
    }

    public function delete(int $id): void {
        $st=$this->db->prepare('SELECT installment_group FROM transactions WHERE id=?');$st->execute([$id]);$group=$st->fetchColumn();
        if($group){$q=$this->db->prepare('DELETE FROM transactions WHERE installment_group=?');$q->execute([$group]);return;}
        $st=$this->db->prepare('DELETE FROM transactions WHERE id=?');$st->execute([$id]);
    }
}
