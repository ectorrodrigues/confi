<?php require __DIR__ . '/../layouts/header.php'; ?>

<div class="page-title">
    <h1>Lançamentos</h1>
</div>

<section class="calendar-strip panel-light">
    <div class="calendar-title">
        <i class="fa-regular fa-calendar"></i> Calendário
    </div>

    <div class="month-nav">
        <?php
            $prev = add_month_same_day($month, -1);
            $next = add_month_same_day($month, 1);
        ?>

        <a href="<?= e(url('lancamentos', ['month' => $prev])) ?>" class="nav-arrow" aria-label="Mês anterior">
            <i class="fa-solid fa-chevron-left"></i>
        </a>

        <div class="month-scroll">
            <?php foreach ($months as $m): ?>
                <a class="month-pill <?= $m === $month ? 'selected' : '' ?>" href="<?= e(url('lancamentos', ['month' => $m])) ?>">
                    <?= e(month_label($m)) ?>
                </a>
            <?php endforeach; ?>
        </div>

        <a href="<?= e(url('lancamentos', ['month' => $next])) ?>" class="nav-arrow" aria-label="Próximo mês">
            <i class="fa-solid fa-chevron-right"></i>
        </a>
    </div>
</section>

<div class="balance-pill <?= $balance >= 0 ? 'green' : 'red' ?>">
    Balanço: <?= e(money_signed($balance)) ?>
</div>

<div class="entries-grid">
    <?php foreach (['entrada' => 'Entradas', 'saida' => 'Saídas'] as $kind => $label): ?>
        <?php
            $rows = $data[$kind];
            $paid = (float) $summary[$kind]['paid'];
            $total = (float) $summary[$kind]['total'];
            $difference = (float) $summary[$kind]['difference'];
        ?>

        <section class="ledger-column">
            <div class="ledger-head <?= $kind === 'entrada' ? 'in' : 'out' ?>">
                <span>
                    <i class="fa-solid <?= $kind === 'entrada' ? 'fa-arrow-up' : 'fa-arrow-down' ?>"></i>
                    <?= e($label) ?> Realizadas
                </span>
                <strong><?= e(money($paid)) ?></strong>
            </div>

            <div class="ledger-summary-bar total">
                <span><i class="fa-solid fa-list"></i> Previsão</span>
                <strong><?= e(money($total)) ?></strong>
            </div>

            <div class="ledger-summary-bar difference">
                <span><i class="fa-solid fa-equals"></i> Diferença</span>
                <strong><?= e(money_signed($difference)) ?></strong>
            </div>

            <?php if (!$rows): ?>
                <div class="empty-state">Nenhum lançamento neste mês.</div>
            <?php endif; ?>

            <?php foreach ($rows as $r): ?>
                <div class="ledger-row">
                    <span><?= e(date_br($r['transaction_date'])) ?></span>
                    <strong><?= e($r['client_name'] ?: $r['item']) ?></strong>
                    <span><?= e(money($r['amount'])) ?></span>
                    <span class="mini-status <?= $r['status'] === 'Pago' ? 'paid' : 'pending' ?>"><?= e($r['status']) ?></span>
                    <a class="circle-search" href="<?= e(url($kind, ['id' => $r['id']])) ?>" aria-label="Ver lançamento">
                        <i class="fa-solid fa-magnifying-glass"></i>
                    </a>
                </div>
            <?php endforeach; ?>
        </section>
    <?php endforeach; ?>
</div>

<?php require __DIR__ . '/../layouts/footer.php'; ?>
