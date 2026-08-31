<?php
/** @var string $title */
/** @var string $page */
?>
<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e(page_title($title)) ?></title>
    <link rel="stylesheet" href="<?= e(asset_url('css/style.css')) ?>">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v6.7.2/css/all.css">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <script src="https://cdn.ckeditor.com/4.22.1/standard/ckeditor.js"></script>
</head>
<body class="app-body">
<div class="app-shell">
    <aside class="sidebar">
        <a class="sidebar-brand" href="<?= e(url('dashboard')) ?>" aria-label="confi">
            <span class="brand-mark"><i class="fa-solid fa-sack-dollar"></i></span>
        </a>
        <nav class="side-nav">
            <a class="<?= $page === 'dashboard' ? 'active' : '' ?>" href="<?= e(url('dashboard')) ?>"><i class="fa-solid fa-chart-line"></i><span>Dashboard</span></a>
            <a class="<?= $page === 'lancamentos' ? 'active' : '' ?>" href="<?= e(url('lancamentos')) ?>"><i class="fa-solid fa-list-check"></i><span>Lançamentos</span></a>
            <a class="<?= $page === 'clientes' ? 'active' : '' ?>" href="<?= e(url('clientes')) ?>"><i class="fa-solid fa-users"></i><span>Clientes</span></a>
            <a class="<?= $page === 'recorrencias' ? 'active' : '' ?>" href="<?= e(url('recorrencias')) ?>"><i class="fa-solid fa-repeat"></i><span>Recorrências</span></a>
        </nav>
        <a class="side-logout" href="<?= e(url('logout')) ?>"><i class="fa-solid fa-arrow-right-from-bracket"></i><span>Sair</span></a>
    </aside>
    <div class="main-wrap">
        <header class="topbar">
            <a class="top-logo" href="<?= e(url('dashboard')) ?>"><span class="brand-mark small"><i class="fa-solid fa-sack-dollar"></i></span><strong>confi</strong></a>
            <div class="top-actions">
                <a href="<?= e(url('entrada')) ?>" class="btn btn-green"><i class="fa-solid fa-plus"></i> Lançar Entrada</a>
                <a href="<?= e(url('saida')) ?>" class="btn btn-red"><i class="fa-solid fa-plus"></i> Lançar Saída</a>
                <img class="client-logo" src="<?= e(asset_url('img/client-logo.svg')) ?>" alt="<?= e(APP_CLIENT) ?>">
            </div>
        </header>
        <main class="content">
<?php if ($message = flash('success')): ?><div class="alert alert-success"><i class="fa-solid fa-circle-check"></i><?= e($message) ?></div><?php endif; ?>
<?php if ($message = flash('error')): ?><div class="alert alert-error"><i class="fa-solid fa-triangle-exclamation"></i><?= e($message) ?></div><?php endif; ?>
