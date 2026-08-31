<?php
declare(strict_types=1);

class DashboardController {
    public function index(): void {
        require_auth();
        $tx=new Transaction(db()); $rec=new Recurring(db());
        $current=date('Y-m-01'); $evolution=$tx->evolution($current);
        $currentRow=$evolution[5]; $nextRow=$evolution[6];
        // O próximo mês também considera as recorrências ativas ainda não lançadas.
        $nextRow['saida'] += $rec->totalActive(); $nextRow['balanco']=$nextRow['entrada']-$nextRow['saida'];
        $alltime=$tx->allTime($current); $latest=$tx->latest(15);
        $page='dashboard'; $title='Dashboard';
        require __DIR__.'/../views/dashboard/index.php';
    }
}
