<?php
declare(strict_types=1);

class DashboardController {
    public function index(): void {
        require_auth();
        $tx=new Transaction(db());
        $current=date('Y-m-01'); $evolution=$tx->evolution($current);
        $currentRow=$evolution[5]; $nextRow=$evolution[6];
        // O próximo mês representa somente as previsões já lançadas.
        // Não adicionar recorrências ativas diretamente ao balanço.
        $alltime=$tx->allTime($current); $latest=$tx->latest(15);
        $page='dashboard'; $title='Dashboard';
        require __DIR__.'/../views/dashboard/index.php';
    }
}
