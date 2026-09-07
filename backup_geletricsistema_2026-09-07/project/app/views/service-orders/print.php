<?php
$osNumber = service_order_label($order['service_order_number'] ?? 0);
$clientAddress = trim(implode(', ', array_filter([
    $order['client_address'] ?? '',
    $order['client_number'] ?? '',
    $order['client_complement'] ?? ''
])));
$clientLocation = trim(implode(' - ', array_filter([
    $order['client_city'] ?? '',
    $order['client_state'] ?? ''
])));
$serviceDate = $order['service_order_date'] ?? $order['original_date'] ?? $order['transaction_date'] ?? null;
?>
<!doctype html>
<html lang="pt-BR">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><?= e($title) ?></title>
    <style>
        @page {
            size: A5 landscape;
            margin: 5mm;
        }

        * { box-sizing: border-box; }
        html, body { margin: 0; padding: 0; }
        body {
            font-family: Arial, Helvetica, sans-serif;
            color: #000;
            background: #fff;
            font-size: 8pt;
            line-height: 1.1;
        }

        .print-sheet {
            width: 100%;
            max-width: 200mm;
            height: 70mm;
            margin: 0 auto;
            position: relative;
        }

        .print-head {
            min-height: 10mm;
            padding-right: 36mm;
            display: flex;
            align-items: flex-start;
            justify-content: space-between;
            border-bottom: 1px solid #000;
            padding-bottom: 2mm;
            margin-bottom: 2.5mm;
        }

        .brand {
            font-size: 13pt;
            font-weight: 800;
            letter-spacing: .8px;
            text-transform: lowercase;
        }

        .title {
            font-size: 8pt;
            font-weight: 700;
            margin-top: 1mm;
        }

        .os-box {
            position: absolute;
            top: 0;
            right: 0;
            width: 31mm;
            padding: 1.8mm 1.5mm;
            background: #000;
            color: #fff;
            text-align: center;
            border: 1px solid #000;
        }

        .os-box span {
            display: block;
            font-size: 5.5pt;
            text-transform: uppercase;
            letter-spacing: .7px;
        }

        .os-box strong {
            display: block;
            margin-top: .5mm;
            font-size: 14pt;
            line-height: 1;
            letter-spacing: 1px;
        }

        .block {
            border: 1px solid #000;
            margin-bottom: 2.5mm;
            padding: 2mm 2.5mm;
            page-break-inside: avoid;
        }

        .block-title {
            margin: -2mm -2.5mm 1.5mm;
            padding: 1mm 2.5mm;
            border-bottom: 1px solid #000;
            font-size: 7pt;
            font-weight: 800;
            text-transform: uppercase;
            letter-spacing: .6px;
        }

        .grid {
            display: grid;
            grid-template-columns: repeat(2, minmax(0, 1fr));
            gap: 1.5mm 4mm;
        }

        .field.wide { grid-column: 1 / -1; }

        .label {
            display: block;
            font-size: 5.5pt;
            font-weight: 700;
            text-transform: uppercase;
            margin-bottom: .5mm;
        }

        .value {
            font-size: 7.5pt;
            min-height: 3.5mm;
            word-break: break-word;
        }

        .value.highlight {
            font-size: 9pt;
            font-weight: 800;
        }

        .footer-note {
            margin-top: 1mm;
            font-size: 5.5pt;
            text-align: center;
        }

        @media screen {
            body { padding: 12px; background: #eee; }
            .print-sheet {
                background: #fff;
                padding: 3mm;
                box-shadow: 0 2px 16px rgba(0,0,0,.12);
            }
        }

        @media print {
            .no-print { display: none !important; }
        }
    </style>
</head>
<body>
    <main class="print-sheet">
        <div class="print-head">
            <div>
                <div class="brand">confi</div>
                <div class="title">Ordem de Serviço</div>
            </div>

            <div class="os-box">
                <span>Ordem de Serviço</span>
                <strong><?= e($osNumber) ?></strong>
            </div>
        </div>

        <section class="block">
            <div class="block-title">Dados do Cliente</div>

            <div class="grid">
                <div class="field wide">
                    <span class="label">Nome</span>
                    <div class="value"><?= e($order['client_name'] ?? '') ?></div>
                </div>

                <div class="field">
                    <span class="label">Telefone</span>
                    <div class="value"><?= e($order['client_phone'] ?? '') ?></div>
                </div>

                <div class="field">
                    <span class="label">E-mail</span>
                    <div class="value"><?= e($order['client_email'] ?? '') ?></div>
                </div>

                <div class="field wide">
                    <span class="label">Endereço</span>
                    <div class="value">
                        <?= e($clientAddress) ?>
                        <?php if ($clientLocation): ?>
                            <?= $clientAddress ? ' — ' : '' ?><?= e($clientLocation) ?>
                        <?php endif; ?>
                    </div>
                </div>
            </div>
        </section>

        <section class="block">
            <div class="block-title">Dados do Lançamento</div>

            <div class="grid">
                <div class="field wide">
                    <span class="label">Item / Serviço</span>
                    <div class="value highlight"><?= e($order['item'] ?? '') ?></div>
                </div>

                <div class="field">
                    <span class="label">Data</span>
                    <div class="value"><?= e(date_br($serviceDate)) ?></div>
                </div>

                <div class="field">
                    <span class="label">Valor</span>
                    <div class="value highlight"><?= e(money((float)($order['amount'] ?? 0))) ?></div>
                </div>

                <div class="field">
                    <span class="label">Método de Pagamento</span>
                    <div class="value"><?= e($order['payment_method'] ?? '') ?></div>
                </div>

                <div class="field">
                    <span class="label">Nº de Parcelas</span>
                    <div class="value"><?= e($order['installments'] ?? '') ?></div>
                </div>

                <div class="field">
                    <span class="label">Bandeira</span>
                    <div class="value"><?= e($order['brand'] ?? '') ?></div>
                </div>

                <div class="field">
                    <span class="label">Status do Pagamento</span>
                    <div class="value"><?= e($order['status'] ?? '') ?></div>
                </div>
            </div>
        </section>

        <div class="footer-note">
            Documento referente à Ordem de Serviço <?= e($osNumber) ?>.
        </div>
    </main>

    <script>
        window.addEventListener('load', function () {
            setTimeout(function () {
                window.print();
            }, 150);
        });
    </script>
</body>
</html>
