<?php require __DIR__.'/../layouts/header.php'; ?>
<div class="page-title"><h1>Recorrências</h1><a class="btn btn-green" href="<?= e(url('recorrencia')) ?>"><i class="fa-solid fa-plus"></i> Adicionar Recorrência</a></div>
<div class="rec-total">Total: <?= e(money($total)) ?></div>
<section class="list-panel recurring-list">
    <?php if(!$rows): ?><div class="empty-state">Nenhuma recorrência cadastrada.</div><?php endif; ?>
    <?php foreach($rows as $r): ?>
    <div class="rec-row">
        <span class="rec-item"><?= e($r['item']) ?></span><span class="rec-day">Dia <?= str_pad((string)$r['day_of_month'],2,'0',STR_PAD_LEFT) ?></span>
        <a class="circle-search" href="<?= e(url('recorrencia',['id'=>$r['id']])) ?>" aria-label="Abrir recorrência"><i class="fa-solid fa-magnifying-glass"></i></a>
        <form method="post" action="<?= e(url('recorrencia/excluir')) ?>" onsubmit="return confirm('Excluir esta recorrência?');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="id" value="<?= (int)$r['id'] ?>"><button class="circle-delete" type="submit" aria-label="Excluir recorrência"><i class="fa-solid fa-xmark"></i></button></form>
    </div>
    <?php endforeach; ?>
</section>
<?php require __DIR__.'/../layouts/footer.php'; ?>
