<?php
declare(strict_types=1);

require_once __DIR__ . '/../app/bootstrap.php';

if (date('d') !== '01') {
    echo 'Hoje não é dia 01. Nenhuma recorrência foi lançada.' . PHP_EOL;
    exit;
}

$created = (new Recurring(db()))->generateForNextMonth(date('Y-m-d'));
$nextMonth = (new DateTime('first day of next month'))->format('m/Y');
echo $created . ' recorrência(s) lançada(s) para ' . $nextMonth . '.' . PHP_EOL;
