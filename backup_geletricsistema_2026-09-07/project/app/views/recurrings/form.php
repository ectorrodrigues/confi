<?php require __DIR__ . '/../layouts/header.php'; ?>

<div class="page-title">
    <h1><?= $editing ? 'Editar Recorrência' : 'Recorrências' ?></h1>
</div>

<?php if ($errors): ?>
    <div class="alert alert-error">
        <i class="fa-solid fa-triangle-exclamation"></i>
        <?= e(implode(' ', $errors)) ?>
    </div>
<?php endif; ?>

<form class="form-panel" method="post" action="<?= e(url('recorrencia', $editing ? ['id' => $rec['id']] : [])) ?>">
    <input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>">

    <div class="form-group">
        <label for="item">Item</label>
        <input id="item" name="item" value="<?= e($rec['item']) ?>" placeholder="Item" required>
    </div>

    <div class="form-group">
        <label for="amount">Valor</label>
        <input id="amount" name="amount" value="<?= e($rec['amount'] !== '' ? number_format((float)$rec['amount'], 2, ',', '') : '') ?>" placeholder="0,00" inputmode="decimal" required>
    </div>

    <div class="form-group">
        <label for="day_of_month">Dia do mês</label>
        <input id="day_of_month" type="number" name="day_of_month" min="1" max="31" value="<?= (int)$rec['day_of_month'] ?>" required>
    </div>

    <div class="form-actions">
        <a href="<?= e(url('recorrencias')) ?>" class="btn btn-back">
            <i class="fa-solid fa-arrow-left"></i> Voltar
        </a>
        <button class="btn btn-primary" type="submit">
            <i class="fa-solid fa-floppy-disk"></i> Salvar
        </button>
    </div>
</form>

<?php require __DIR__ . '/../layouts/footer.php'; ?>
