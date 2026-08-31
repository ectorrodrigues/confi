<?php require __DIR__ . '/../layouts/header.php'; ?>

<div class="page-title">
    <h1><?= $editing ? 'Editar cliente' : 'Clientes' ?></h1>
</div>

<?php if ($errors): ?>
    <div class="alert alert-error">
        <i class="fa-solid fa-triangle-exclamation"></i>
        <?= e(implode(' ', $errors)) ?>
    </div>
<?php endif; ?>

<form
    class="form-panel"
    method="post"
    action="<?= e(url('cliente', $editing ? ['id' => $client['id']] : ['return' => $return])) ?>"
>
    <input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>">
    <input type="hidden" name="return" value="<?= e($return) ?>">

    <div class="form-group">
        <label for="name">Nome Completo</label>
        <input id="name" name="name" value="<?= e($client['name']) ?>" placeholder="Nome Completo" required>
    </div>

    <div class="form-group">
        <label for="phone">Telefone</label>
        <input id="phone" name="phone" value="<?= e($client['phone']) ?>" placeholder="(45) 99999-9999" required>
    </div>

    <div class="form-group">
        <label for="email">E-mail</label>
        <input id="email" type="email" name="email" value="<?= e($client['email']) ?>" placeholder="email@email.com">
    </div>

    <div class="form-group">
        <label for="address">Endereço</label>
        <input id="address" name="address" value="<?= e($client['address']) ?>" placeholder="Rua Lorem Ipsum">
    </div>

    <div class="form-row small-left">
        <div class="form-group">
            <label for="number">Número</label>
            <input id="number" name="number" value="<?= e($client['number']) ?>" placeholder="123">
        </div>

        <div class="form-group">
            <label for="complement">Complemento</label>
            <input id="complement" name="complement" value="<?= e($client['complement']) ?>" placeholder="Apto. 123">
        </div>
    </div>

    <div class="form-row small-left">
        <div class="form-group">
            <label for="state">UF</label>
            <select id="state" name="state">
                <?php foreach ($states as $st): ?>
                    <option value="<?= e($st) ?>" <?= $st === $client['state'] ? 'selected' : '' ?>>
                        <?= e($st) ?>
                    </option>
                <?php endforeach; ?>
            </select>
        </div>

        <div class="form-group">
            <label for="city">Cidade</label>
            <select id="city" name="city" data-selected-city="<?= e($client['city']) ?>">
                <option value="">Selecione uma cidade</option>
            </select>
            <small class="field-loading" id="city-loading" aria-live="polite"></small>
        </div>
    </div>

    <div class="form-actions">
        <a href="<?= e(url($return === 'entrada' || $return === 'saida' ? $return : 'clientes')) ?>" class="btn btn-back">
            <i class="fa-solid fa-arrow-left"></i> Voltar
        </a>
        <button class="btn btn-primary" type="submit">
            <i class="fa-solid fa-floppy-disk"></i> Salvar
        </button>
    </div>
</form>

<?php require __DIR__ . '/../layouts/footer.php'; ?>
