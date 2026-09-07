<?php
declare(strict_types=1);

class ServiceOrderController {
    public function index(): void {
        require_auth();
        $tx = new Transaction(db());
        $orders = $tx->serviceOrders();

        $groups = [];
        foreach ($orders as $order) {
            $date = (string) ($order['transaction_date'] ?? '');
            $groups[$date][] = $order;
        }

        $page = 'ordens-servico';
        $title = 'Ordens de Serviço';
        require __DIR__ . '/../views/service-orders/index.php';
    }

    public function print(int $id): void {
        require_auth();
        $tx = new Transaction(db());
        $order = $tx->serviceOrder($id);

        if (!$order) {
            http_response_code(404);
            echo 'Ordem de serviço não encontrada.';
            return;
        }

        $title = 'Ordem de Serviço ' . service_order_label($order['service_order_number'] ?? 0);
        require __DIR__ . '/../views/service-orders/print.php';
    }
}
