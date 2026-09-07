<?php require __DIR__ . '/../layouts/header.php'; ?>

<div class="page-title">
    <h1><i class="fa-solid fa-clipboard-list"></i> Ordens de Serviço</h1>
</div>

<section class="service-orders-list">
    <?php if (!$orders): ?>
        <div class="empty-state">Nenhuma ordem de serviço cadastrada.</div>
    <?php else: ?>
        <?php foreach ($groups as $date => $rows): ?>
            <div class="service-order-date">
                <i class="fa-regular fa-calendar"></i>
                <?= e(date_br($date)) ?>
            </div>

            <?php foreach ($rows as $row): ?>
                <?php $overdue = $date !== '' && $date < date('Y-m-d'); ?>
                <div class="service-order-row <?= $overdue ? 'overdue' : '' ?> <?= $row['status'] === 'Pago' ? 'paid' : '' ?>">
                    <span class="service-order-number">
                        OS <?= e(service_order_label($row['service_order_number'] ?? 0)) ?>
                    </span>
                    <span class="service-order-client">
                        <?= e($row['client_name'] ?: 'Cliente não informado') ?>
                    </span>
                    <span class="service-order-item">
                        <?= e($row['item']) ?>
                    </span>
                    <span class="service-order-value">
                        <?= e(money($row['amount'])) ?>
                    </span>
                    <span class="mini-status <?= $row['status'] === 'Pago' ? 'paid' : 'pending' ?>">
                        <?= e($row['status']) ?>
                    </span>
                    <a class="circle-search" href="<?= e(url('entrada', ['id' => $row['id']])) ?>" aria-label="Abrir ordem de serviço">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </a>
                    <a class="circle-print" href="<?= e(url('ordem-de-servico/imprimir', ['id' => $row['id']])) ?>" target="_blank" rel="noopener" aria-label="Imprimir ordem de serviço">
                        <i class="fa-solid fa-print"></i>
                    </a>
                </div>
            <?php endforeach; ?>
        <?php endforeach; ?>
    <?php endif; ?>
</section>

<?php require __DIR__ . '/../layouts/footer.php'; ?>
