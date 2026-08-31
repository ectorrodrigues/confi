<?php
declare(strict_types=1);
require_once __DIR__.'/app/bootstrap.php';
require_once __DIR__.'/app/models/Transaction.php';
require_once __DIR__.'/app/models/Client.php';
require_once __DIR__.'/app/models/Recurring.php';
require_once __DIR__.'/app/controllers/AuthController.php';
require_once __DIR__.'/app/controllers/DashboardController.php';
require_once __DIR__.'/app/controllers/TransactionController.php';
require_once __DIR__.'/app/controllers/ClientController.php';
require_once __DIR__.'/app/controllers/RecurringController.php';

$path=parse_url($_SERVER['REQUEST_URI']??'/',PHP_URL_PATH) ?: '/';
$base=rtrim(str_replace('\\','/',dirname($_SERVER['SCRIPT_NAME']??'/index.php')),'/');
if($base && str_starts_with($path,$base)) $path=substr($path,strlen($base));
$path='/'.trim($path,'/');
$route=$path==='/'?'/login':$path;

switch($route){
    case '/login': (new AuthController())->login(); break;
    case '/logout': (new AuthController())->logout(); break;
    case '/dashboard': (new DashboardController())->index(); break;
    case '/lancamentos': (new TransactionController())->index(); break;
    case '/entrada': (new TransactionController())->form('entrada'); break;
    case '/saida': (new TransactionController())->form('saida'); break;
    case '/clientes': (new ClientController())->index(); break;
    case '/cliente': (new ClientController())->form(); break;
    case '/api/cidades': (new ClientController())->cities(); break;
    case '/cliente/excluir': if($_SERVER['REQUEST_METHOD']==='POST')(new ClientController())->delete(); else redirect_to('clientes'); break;
    case '/recorrencias': (new RecurringController())->index(); break;
    case '/recorrencia': (new RecurringController())->form(); break;
    case '/recorrencia/excluir': if($_SERVER['REQUEST_METHOD']==='POST')(new RecurringController())->delete(); else redirect_to('recorrencias'); break;
    case '/lancamento/excluir': if($_SERVER['REQUEST_METHOD']==='POST')(new TransactionController())->delete(); else redirect_to('lancamentos'); break;
    default: http_response_code(404); echo 'Página não encontrada.'; break;
}
