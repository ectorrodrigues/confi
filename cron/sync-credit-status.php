<?php
declare(strict_types=1);
require_once __DIR__ . '/../app/bootstrap.php';

try {
    $recurringCreated = launch_recurring_expenses_for_next_month();
    $creditUpdated = sync_due_credit_installments();
    echo "Recorrências lançadas: {$recurringCreated}. Parcelas de cartão atualizadas: {$creditUpdated}. " . date('Y-m-d H:i:s') . PHP_EOL;
} catch (Throwable $e) {
    fwrite(STDERR, "Falha na sincronização: {$e->getMessage()}" . PHP_EOL);
    exit(1);
}
