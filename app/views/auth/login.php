<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>Entrar - <?= e(APP_NAME) ?></title>
    <link rel="stylesheet" href="<?= e(asset_url('css/style.css')) ?>">
    <link rel="stylesheet" href="https://use.fontawesome.com/releases/v6.7.2/css/all.css">
    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
</head>
<body class="login-page">
    <a class="login-logo" href="<?= e(url('login')) ?>">
        <img class="client-logo" src="<?= e(asset_url('img/confi_logo.png')) ?>" alt="Confi Logo">
    </a>

    <section class="login-card">
        <h1>Entrar.</h1>
        <p>Insira seus dados para entrar em sua conta.</p>

        <?php if (!empty($error)): ?>
            <div class="alert alert-error">
                <i class="fa-solid fa-triangle-exclamation"></i>
                <?= e($error) ?>
            </div>
        <?php endif; ?>

        <form method="post" action="<?= e(url('login')) ?>">
            <input type="hidden" name="_csrf" value="<?= e(csrf_token()) ?>">

            <label for="email">EMAIL</label>
            <input 
                id="email" 
                name="email" 
                type="email" 
                value="<?= e($email ?? '') ?>" 
                placeholder="name@example.com" 
                autocomplete="username" 
                required
            >

            <label for="password">SENHA</label>
            <div class="password-wrap">
                <input 
                    id="password" 
                    name="password" 
                    type="password" 
                    placeholder="••••••••" 
                    autocomplete="current-password" 
                    required
                >
                <button class="password-toggle" type="button" aria-label="Mostrar senha">
                    <i class="fa-regular fa-eye-slash"></i>
                </button>
            </div>

            <div class="forgot">Esqueceu a senha?</div>
            <button class="login-submit" type="submit">Entrar</button>
        </form>

        <div class="create-account">
            Não tem uma conta ainda? 
            <strong>Criar conta</strong>
        </div>
    </section>

    <script src="<?= e(asset_url('js/app.js')) ?>"></script>
</body>
</html>
