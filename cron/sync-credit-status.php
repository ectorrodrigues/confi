<?php
declare(strict_types=1);
require_once __DIR__ . '/../app/bootstrap.php';
db()->exec("UPDATE transactions SET status='Pago' WHERE payment_method='Cartão de Crédito' AND status='Pendente' AND transaction_date <= CURDATE()");
echo "Status das parcelas de cartão atualizado em ".date('Y-m-d H:i:s').PHP_EOL;
