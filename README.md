# confi

## Rotinas automáticas

No dia 01, todas as recorrências ativas são lançadas como saídas pendentes do
mês seguinte, usando o dia configurado em cada recorrência como vencimento. A
rotina é idempotente: uma recorrência só gera um lançamento por mês.

Para que isso ocorra mesmo sem alguém abrir o sistema, execute o cron abaixo
diariamente no servidor (ajuste os caminhos):

```cron
0 0 * * * /caminho/para/php /caminho/para/confi/cron/sync-credit-status.php
```

O mesmo cron também atualiza o status das parcelas de cartão vencidas.
