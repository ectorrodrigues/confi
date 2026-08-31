<?php
declare(strict_types=1);

class Transaction {
    public function __construct(private PDO $db) {}

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
        $months = [];

        $st = $this->db->prepare("
            SELECT
                kind,
                COALESCE(
                    SUM(
                        CASE
                            WHEN status = 'Pago' THEN amount
                            ELSE 0
                        END
                    ),
                    0
                ) AS paid_total,
                COALESCE(SUM(amount), 0) AS total
            FROM transactions
            WHERE period_month = ?
            GROUP BY kind
        ");

        for ($i = 0; $i < 7; $i++) {

            $m = $start->format('Y-m-01');

            $in = 0.0;
            $out = 0.0;

            $st->execute([$m]);

            foreach ($st->fetchAll() as $row) {

                /*
                * Próximo mês:
                * previsão = Pago + Pendente
                */
                if ($i === 6) {
                    $value = (float) $row['total'];
                }

                /*
                * Meses anteriores + mês atual:
                * realizado = somente Pago
                */
                else {
                    $value = (float) $row['paid_total'];
                }

                if ($row['kind'] === 'entrada') {
                    $in = $value;
                } else {
                    $out = $value;
                }
            }

            $months[] = [
                'month'    => $m,
                'label'    => month_label($m),
                'entrada'  => $in,
                'saida'    => $out,
                'balanco'  => $in - $out
            ];

            $start->modify('+1 month');
        }

        return $months;
    }

    public function currentBalance(string $month): float {
    $st = $this->db->prepare("
        SELECT COALESCE(
            SUM(
                CASE
                    WHEN kind = 'entrada' AND status = 'Pago' THEN amount
                    WHEN kind = 'saida' AND status = 'Pago' THEN -amount
                    ELSE 0
                END
            ),
            0
        )
        FROM transactions
        WHERE period_month = ?
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
        if($method==='Cartão de Crédito'){
            $status='Pendente';
            $values=split_installments($total,$installments);
            $group=bin2hex(random_bytes(16));
            $st=$this->db->prepare('INSERT INTO transactions(kind,client_id,item,amount,payment_method,installments,brand,status,transaction_date,period_month,notes,installment_group,installment_number,installment_total,original_date) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)');
            $firstId=0;
            foreach($values as $idx=>$value){
                $due=add_month_same_day($date,$idx+1);
                $st->execute([$kind,$data['client_id'],$data['item'],$value,$method,$data['installments'],$data['brand'],$status,$due,month_start($due),$notes,$group,$idx+1,$installments,$date]);
                if($firstId===0)$firstId=(int)$this->db->lastInsertId();
            }
            return $firstId;
        }
        $st=$this->db->prepare('INSERT INTO transactions(kind,client_id,item,amount,payment_method,installments,brand,status,transaction_date,period_month,notes,original_date) VALUES(?,?,?,?,?,?,?,?,?,?,?,?)');
        $st->execute([$kind,$data['client_id'],$data['item'],$total,$method,$data['installments'],'',$data['status'],$date,month_start($date),$notes,$date]);
        return (int)$this->db->lastInsertId();
    }

    public function delete(int $id): void {
        $st=$this->db->prepare('SELECT installment_group FROM transactions WHERE id=?');$st->execute([$id]);$group=$st->fetchColumn();
        if($group){$q=$this->db->prepare('DELETE FROM transactions WHERE installment_group=?');$q->execute([$group]);return;}
        $st=$this->db->prepare('DELETE FROM transactions WHERE id=?');$st->execute([$id]);
    }
}
