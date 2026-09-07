<?php
declare(strict_types=1);

class Recurring {
    public function __construct(private PDO $db) {}

    public function allActive(): array {
        return $this->db->query('SELECT * FROM recurrings WHERE active=1 ORDER BY day_of_month, item')->fetchAll();
    }

    public function find(int $id): ?array {
        $st=$this->db->prepare('SELECT * FROM recurrings WHERE id=?');
        $st->execute([$id]);
        return $st->fetch() ?: null;
    }

    public function totalActive(): float {
        return (float)$this->db->query('SELECT COALESCE(SUM(amount),0) FROM recurrings WHERE active=1')->fetchColumn();
    }

    public function totalActiveNotGeneratedForMonth(string $month): float {
        $this->ensureTransactionRecurringColumns();
        $month = month_start($month);
        $st = $this->db->prepare(
            "SELECT COALESCE(SUM(r.amount),0)
             FROM recurrings r
             WHERE r.active=1
               AND NOT EXISTS (
                   SELECT 1
                   FROM transactions t
                   WHERE t.recurring_id = r.id
                     AND t.recurring_reference_month = ?
               )"
        );
        $st->execute([$month]);
        return (float)$st->fetchColumn();
    }

    public function save(array $data, int $id=0): int {
        if ($id>0) {
            $st=$this->db->prepare('UPDATE recurrings SET item=?, amount=?, day_of_month=?, active=? WHERE id=?');
            $st->execute([$data['item'],$data['amount'],$data['day_of_month'],$data['active'],$id]);
            return $id;
        }
        $st=$this->db->prepare('INSERT INTO recurrings(item,amount,day_of_month,active) VALUES(?,?,?,?)');
        $st->execute([$data['item'],$data['amount'],$data['day_of_month'],$data['active']]);
        return (int)$this->db->lastInsertId();
    }

    public function delete(int $id): void {
        $st=$this->db->prepare('DELETE FROM recurrings WHERE id=?');
        $st->execute([$id]);
    }

    /**
     * Gera, no dia 01, as despesas recorrentes do próximo mês.
     * Cada recorrência é criada como uma saída Pendente e fica
     * associada ao mês de referência para impedir duplicidades.
     */
    public function generateForMonth(string $targetMonth): int {
        $this->ensureTransactionRecurringColumns();

        $targetMonth = month_start($targetMonth);
        $targetDate = new DateTime($targetMonth);

        $recurrences = $this->allActive();
        if (!$recurrences) {
            return 0;
        }

        $check = $this->db->prepare(
            'SELECT id FROM transactions WHERE recurring_id=? AND recurring_reference_month=? LIMIT 1'
        );

        $insert = $this->db->prepare(
            "INSERT INTO transactions(
                kind, client_id, item, amount, payment_method, installments, brand,
                status, transaction_date, period_month, notes, original_date,
                recurring_id, recurring_reference_month
            ) VALUES(
                'saida', NULL, ?, ?, NULL, '1X', '',
                'Pendente', ?, ?, NULL, ?, ?, ?
            )"
        );

        $created = 0;

        $this->db->beginTransaction();
        try {
            foreach ($recurrences as $rec) {
                $recurrenceId = (int)$rec['id'];

                // Idempotência: a mesma recorrência só pode ser lançada uma vez
                // para cada mês de referência.
                $check->execute([$recurrenceId, $targetMonth]);
                if ($check->fetchColumn()) {
                    continue;
                }

                $day = max(1, min(31, (int)$rec['day_of_month']));
                $lastDay = (int)$targetDate->format('t');
                $day = min($day, $lastDay);
                $dueDate = $targetDate->format('Y-m-') . str_pad((string)$day, 2, '0', STR_PAD_LEFT);

                $insert->execute([
                    $rec['item'],
                    (float)$rec['amount'],
                    $dueDate,
                    $targetMonth,
                    $dueDate,
                    $recurrenceId,
                    $targetMonth
                ]);

                $created++;
            }

            $this->db->commit();
        } catch (Throwable $e) {
            if ($this->db->inTransaction()) {
                $this->db->rollBack();
            }
            throw $e;
        }

        return $created;
    }

    public function generateForNextMonth(string $referenceDate): int {
        $reference = new DateTime($referenceDate);
        $targetMonth = (clone $reference)->modify('first day of next month')->format('Y-m-01');
        return $this->generateForMonth($targetMonth);
    }

    private function ensureTransactionRecurringColumns(): void {
        static $ready = false;
        if ($ready) {
            return;
        }

        $columns = $this->db->query('SHOW COLUMNS FROM transactions')->fetchAll(PDO::FETCH_COLUMN);

        if (!in_array('recurring_id', $columns, true)) {
            $this->db->exec('ALTER TABLE transactions ADD COLUMN recurring_id INT UNSIGNED NULL');
        }

        if (!in_array('recurring_reference_month', $columns, true)) {
            $this->db->exec('ALTER TABLE transactions ADD COLUMN recurring_reference_month DATE NULL');
        }

        $indexes = $this->db->query('SHOW INDEX FROM transactions')->fetchAll();
        $hasUniqueRecurring = false;
        foreach ($indexes as $index) {
            if (($index['Key_name'] ?? '') === 'uq_transactions_recurring_month') {
                $hasUniqueRecurring = true;
                break;
            }
        }

        if (!$hasUniqueRecurring) {
            $this->db->exec(
                'ALTER TABLE transactions ADD UNIQUE KEY uq_transactions_recurring_month(recurring_id, recurring_reference_month)'
            );
        }

        $ready = true;
    }
}
