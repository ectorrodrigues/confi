<?php
declare(strict_types=1);

class Client {
    public function __construct(private PDO $db) {}

    public function all(): array {
        return $this->db->query('SELECT * FROM clients ORDER BY name')->fetchAll();
    }

    public function find(int $id): ?array {
        $st = $this->db->prepare('SELECT * FROM clients WHERE id=?');
        $st->execute([$id]);
        return $st->fetch() ?: null;
    }

    public function save(array $data, int $id = 0): int {
        if ($id > 0) {
            $st = $this->db->prepare('UPDATE clients SET name=?, phone=?, email=?, address=?, number=?, complement=?, state=?, city=? WHERE id=?');
            $st->execute([$data['name'],$data['phone'],$data['email'],$data['address'],$data['number'],$data['complement'],$data['state'],$data['city'],$id]);
            return $id;
        }
        $st = $this->db->prepare('INSERT INTO clients(name,phone,email,address,number,complement,state,city) VALUES(?,?,?,?,?,?,?,?)');
        $st->execute([$data['name'],$data['phone'],$data['email'],$data['address'],$data['number'],$data['complement'],$data['state'],$data['city']]);
        return (int)$this->db->lastInsertId();
    }

    public function delete(int $id): void {
        $st = $this->db->prepare('DELETE FROM clients WHERE id=?');
        $st->execute([$id]);
    }
}
