<?php
declare(strict_types=1);

class RecurringController {
    private function defaults(): array { return ['id'=>0,'item'=>'','amount'=>'','day_of_month'=>1,'active'=>1,'notes'=>'']; }
    public function index(): void { require_auth(); $model=new Recurring(db()); $rows=$model->allActive(); $total=$model->totalActive(); $page='recorrencias'; $title='Recorrências'; require __DIR__.'/../views/recurrings/index.php'; }
    public function form(): void {
        require_auth(); $model=new Recurring(db()); $id=(int)($_GET['id']??0); $editing=$id>0; $rec=$editing?($model->find($id)?:$this->defaults()):$this->defaults(); $errors=[];
        if($_SERVER['REQUEST_METHOD']==='POST'){
            verify_csrf(); $rec['item']=trim((string)($_POST['item']??'')); $rec['amount']=parse_money($_POST['amount']??0); $rec['day_of_month']=(int)($_POST['day_of_month']??1); $rec['active']=1;
            if($rec['item']==='')$errors[]='Informe o item.'; if($rec['amount']<=0)$errors[]='Informe um valor maior que zero.'; if($rec['day_of_month']<1||$rec['day_of_month']>31)$errors[]='Dia inválido.';
            if(!$errors){$model->save($rec,$id); flash('success',$editing?'Recorrência atualizada.':'Recorrência cadastrada.'); redirect_to('recorrencias');}
        }
        $page='recorrencias'; $title=$editing?'Editar Recorrência':'Recorrências'; require __DIR__.'/../views/recurrings/form.php';
    }
    public function delete(): void { require_auth(); verify_csrf(); (new Recurring(db()))->delete((int)($_POST['id']??0)); flash('success','Recorrência excluída.'); redirect_to('recorrencias'); }
}
