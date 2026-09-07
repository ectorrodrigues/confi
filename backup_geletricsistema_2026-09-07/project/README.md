# confi



### Lançamento automático de recorrências

No dia 01 de cada mês, as recorrências ativas são lançadas automaticamente como saídas `Pendente` no próximo mês, usando o dia configurado na recorrência. O processo é idempotente e não duplica o mesmo lançamento para a mesma recorrência e mês.

O sistema também executa essa sincronização automaticamente quando é acessado no dia 01. Para garantir a execução mesmo sem abrir o sistema nesse dia, configure o cron do MAMP/macOS para executar diariamente:

```bash
0 1 * * * /Applications/MAMP/bin/php/php8.*/bin/php /Applications/MAMP/htdocs/confi/cron/generate-recurring-expenses.php
```

Ajuste o caminho da versão do PHP e da pasta `htdocs` conforme sua instalação.
