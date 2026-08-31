<?php require __DIR__.'/../layouts/header.php'; ?>
<div class="page-title"><h1>Clientes</h1><a class="btn btn-green" href="<?= e(url('cliente')) ?>"><i class="fa-solid fa-plus"></i> Adicionar Cliente</a></div>
<section class="list-panel">
    <?php if(!$clients): ?><div class="empty-state">Nenhum cliente cadastrado.</div><?php endif; ?>
    <?php foreach($clients as $c): ?>
    <div class="client-list-row">
        <span class="client-name-pill"><?= e($c['name']) ?></span>
        <a class="circle-search" href="<?= e(url('cliente',['id'=>$c['id']])) ?>" aria-label="Abrir cliente"><i class="fa-solid fa-magnifying-glass"></i></a>
        <form method="post" action="<?= e(url('cliente/excluir')) ?>" onsubmit="return confirm('Excluir este cliente?');"><input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>"><input type="hidden" name="id" value="<?= (int)$c['id'] ?>"><button class="circle-delete" type="submit" aria-label="Excluir cliente"><i class="fa-solid fa-xmark"></i></button></form>
    </div>
    <?php endforeach; ?>
</section>
<?php require __DIR__.'/../layouts/footer.php'; ?>
