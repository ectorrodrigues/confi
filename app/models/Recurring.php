<?php
declare(strict_types=1);

class Recurring {
    public function __construct(private PDO $db) {}
    public function allActive(): array { return $this->db->query('SELECT * FROM recurrings WHERE active=1 ORDER BY day_of_month, item')->fetchAll(); }
    public function find(int $id): ?array { $st=$this->db->prepare('SELECT * FROM recurrings WHERE id=?'); $st->execute([$id]); return $st->fetch() ?: null; }
    public function totalActive(): float { return (float)$this->db->query('SELECT COALESCE(SUM(amount),0) FROM recurrings WHERE active=1')->fetchColumn(); }
    public function save(array $data, int $id=0): int {
        if ($id>0) { $st=$this->db->prepare('UPDATE recurrings SET item=?, amount=?, day_of_month=?, active=? WHERE id=?'); $st->execute([$data['item'],$data['amount'],$data['day_of_month'],$data['active'],$id]); return $id; }
        $st=$this->db->prepare('INSERT INTO recurrings(item,amount,day_of_month,active) VALUES(?,?,?,?)'); $st->execute([$data['item'],$data['amount'],$data['day_of_month'],$data['active']]); return (int)$this->db->lastInsertId();
    }
    public function delete(int $id): void { $st=$this->db->prepare('DELETE FROM recurrings WHERE id=?'); $st->execute([$id]); }
}
