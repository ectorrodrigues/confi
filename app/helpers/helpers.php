<?php
declare(strict_types=1);

function e(mixed $value): string {
    return htmlspecialchars((string)$value, ENT_QUOTES, 'UTF-8');
}

function money(float|int|null $value): string {
    return 'R$ ' . number_format((float)$value, 2, ',', '.');
}

function money_signed(float|int|null $value): string {
    $n = (float)$value;
    return ($n >= 0 ? '+ ' : '- ') . money(abs($n));
}


function parse_money(mixed $value): float {
    $s = trim((string)$value);
    if ($s === '') return 0.0;
    $s = preg_replace('/[^0-9,.-]/', '', $s) ?? '';
    if (str_contains($s, ',')) {
        $s = str_replace('.', '', $s);
        $s = str_replace(',', '.', $s);
    }
    return is_numeric($s) ? round((float)$s, 2) : 0.0;
}

function date_br(?string $date): string {
    return $date ? date('d/m/Y', strtotime($date)) : '';
}

function month_label(string $ymd): string {
    $months = ['jan','fev','mar','abr','mai','jun','jul','ago','set','out','nov','dez'];
    $t = strtotime($ymd);
    return ucfirst($months[(int)date('n', $t) - 1]) . '/' . date('Y', $t);
}

function month_start(?string $value): string {
    if ($value && preg_match('/^\d{4}-\d{2}/', $value)) {
        $ts = strtotime(substr($value, 0, 7) . '-01');
        if ($ts !== false) return date('Y-m-01', $ts);
    }
    return date('Y-m-01');
}

function payment_options(): array { return ['Pix', 'Dinheiro', 'Cartão de Crédito', 'Débito']; }
function parcel_options(): array { return ['1X', '2X', '3X', '4X', '5X', '6X', '7X', '8X', '9X', '10X', '11X', '12X']; }
function brand_options(): array { return ['Mastercard', 'Visa', 'Elo']; }
function status_options(): array { return ['Pago', 'Pendente']; }

function page_title(string $title): string { return $title . ' - ' . APP_NAME; }

function base_url(): string {
    $script = str_replace('\\', '/', $_SERVER['SCRIPT_NAME'] ?? '/index.php');
    $dir = rtrim(str_replace('/index.php', '', $script), '/');
    return $dir === '/' ? '' : $dir;
}

function url(string $route, array $query = []): string {
    $path = base_url() . '/' . ltrim($route, '/');
    if ($query) $path .= '?' . http_build_query($query);
    return $path;
}

function asset_url(string $path): string { return base_url() . '/public/assets/' . ltrim($path, '/'); }

function redirect_to(string $route, array $query = []): never {
    header('Location: ' . url($route, $query));
    exit;
}

function flash(string $key, ?string $message = null): ?string {
    if ($message !== null) $_SESSION['_flash'][$key] = $message;
    $value = $_SESSION['_flash'][$key] ?? null;
    unset($_SESSION['_flash'][$key]);
    return $value;
}

function csrf_token(): string {
    if (empty($_SESSION['_csrf'])) $_SESSION['_csrf'] = bin2hex(random_bytes(32));
    return $_SESSION['_csrf'];
}

function verify_csrf(): void {
    $given = (string)($_POST['_csrf'] ?? '');
    if (!hash_equals($_SESSION['_csrf'] ?? '', $given)) {
        http_response_code(419);
        exit('Token CSRF inválido. Recarregue a página e tente novamente.');
    }
}

function add_month_same_day(string $date, int $months): string {
    $dt = new DateTime($date);
    $day = (int)$dt->format('d');
    $base = new DateTime($dt->format('Y-m-01'));
    $base->modify(($months >= 0 ? '+' : '') . $months . ' month');
    $last = (int)$base->format('t');
    $base->setDate((int)$base->format('Y'), (int)$base->format('m'), min($day, $last));
    return $base->format('Y-m-d');
}

function installment_count(?string $installments): int {
    if (!$installments || $installments === 'À vista') return 1;
    if (preg_match('/^(\d+)X$/i', trim($installments), $m)) return max(1, (int)$m[1]);
    return 1;
}

function split_installments(float $total, int $count): array {
    $count = max(1, $count);
    $totalCents = (int)round($total * 100);
    $base = intdiv($totalCents, $count);
    $remainder = $totalCents - ($base * $count);
    $values = [];
    for ($i = 0; $i < $count; $i++) {
        $cents = $base + ($i === $count - 1 ? $remainder : 0);
        $values[] = $cents / 100;
    }
    return $values;
}

function sync_due_credit_installments(): void {
    $sql = "UPDATE transactions
            SET status = 'Pago'
            WHERE kind IN ('entrada','saida')
              AND payment_method = 'Cartão de Crédito'
              AND status = 'Pendente'
              AND transaction_date <= CURDATE()";
    db()->exec($sql);
}
