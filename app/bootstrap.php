<?php
declare(strict_types=1);

date_default_timezone_set('America/Sao_Paulo');
session_start();
require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/helpers/helpers.php';

function current_user(): ?array { return $_SESSION['user'] ?? null; }
function require_auth(): void { if (!current_user()) redirect_to('login'); }
function login_user(array $user): void {
    session_regenerate_id(true);
    $_SESSION['user'] = ['id' => (int)$user['id'], 'name' => $user['name'], 'email' => $user['email']];
}
function logout_user(): void {
    $_SESSION = [];
    if (ini_get('session.use_cookies')) {
        $params = session_get_cookie_params();
        setcookie(session_name(), '', time() - 42000, $params['path'], $params['domain'] ?? '', $params['secure'], $params['httponly']);
    }
    session_destroy();
}

// Atualiza automaticamente parcelas de cartão que já chegaram à data de vencimento.
try { sync_due_credit_installments(); } catch (Throwable $e) { /* conexão ainda pode não estar configurada */ }
