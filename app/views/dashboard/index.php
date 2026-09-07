<?php require __DIR__.'/../layouts/header.php'; ?>
<div class="page-title"><h1>Dashboard</h1></div>
<div class="dashboard-grid">
    <section class="panel chart-panel">
        <h2>Evolução</h2>
        <div class="chart-wrap"><div id="evolutionChart" class="evolution-chart"></div></div>
        <div class="chart-legend"><span class="legend-entry">Entradas</span><span class="legend-exit">Saídas</span><span class="legend-balance">Balanço</span></div>
    </section>
    <aside class="kpi-stack">
        <div class="kpi-card"><div class="kpi-label">Balanço Mês Atual</div><div class="kpi-value <?= $currentRow['balanco']>=0?'positive':'negative' ?>"><?= e(money_signed($currentRow['balanco'])) ?></div></div>
        <div class="kpi-card"><div class="kpi-label">Balanço Próximo mês</div><div class="kpi-value <?= $nextRow['balanco']>=0?'positive':'negative' ?>"><?= e(money_signed($nextRow['balanco'])) ?></div><div class="kpi-note">Inclui recorrências ativas</div></div>
        <div class="kpi-card alltime"><div class="kpi-label">Balanço All-Time</div><div class="kpi-value <?= $alltime>=0?'positive':'negative' ?>"><?= e(money_signed($alltime)) ?></div></div>
    </aside>
</div>
<section class="history panel">
    <div class="section-heading"><h2>Histórico Lançamentos</h2></div>
    <?php foreach($latest as $row): ?>
        <div class="history-row">
            <span class="flow-icon <?= $row['kind']==='entrada'?'in':'out' ?>"><i class="fa-solid <?= $row['kind']==='entrada'?'fa-arrow-up':'fa-arrow-down' ?>"></i></span>
            <span class="history-date"><?= e(date_br($row['transaction_date'])) ?></span>
            <span class="history-name"><?= e($row['client_name'] ?: $row['item']) ?></span>
            <span class="history-amount"><?= e(money($row['amount'])) ?></span>
            <span class="history-status <?= $row['status']==='Pago'?'paid':'pending' ?>"><?= e($row['status']) ?></span>
            <a class="circle-search" href="<?= e(url($row['kind'])) ?>?id=<?= (int)$row['id'] ?>" aria-label="Ver lançamento"><i class="fa-solid fa-magnifying-glass"></i></a>
        </div>
    <?php endforeach; ?>
    <a class="more-link" href="<?= e(url('lancamentos')) ?>">+ ver mais</a>
</section>
<script>
window.confiDashboard = <?= json_encode($evolution, JSON_UNESCAPED_UNICODE|JSON_UNESCAPED_SLASHES) ?>;
</script>
<?php $pageScripts=['js/dashboard.js']; require __DIR__.'/../layouts/footer.php'; ?>
