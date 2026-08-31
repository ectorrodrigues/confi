<?php
declare(strict_types=1);

class TransactionController {
    public function index(): void {
        require_auth(); $tx=new Transaction(db());
        $months=$tx->monthsAvailable(); $month=month_start($_GET['month'] ?? date('Y-m-01'));
        if(!in_array($month,$months,true)) $month=$months[0] ?? date('Y-m-01');
        $data=$tx->monthly($month); $summary=$tx->monthlySummary($month); $balance=$tx->currentBalance($month);
        $page='lancamentos'; $title='Lançamentos';
        require __DIR__.'/../views/transactions/index.php';
    }

    public function form(string $kind): void {
        require_auth(); $tx=new Transaction(db()); $clients=(new Client(db()))->all();
        $id=(int)($_GET['id']??0); $editing=$id>0; $errors=[];
        $default=['id'=>0,'client_id'=>'','item'=>'','amount'=>'','payment_method'=>'Pix','installments'=>'1X','brand'=>'Mastercard','status'=>'Pago','transaction_date'=>date('Y-m-d'),'period_month'=>date('Y-m-01'),'notes'=>'','original_date'=>date('Y-m-d'),'installment_number'=>null,'installment_total'=>null];
        $transaction=$editing ? ($tx->find($id,$kind) ?: $default) : $default;
        if($editing && ($transaction['payment_method']??'')==='Cartão de Crédito') {
            $transaction['amount']=number_format((float)$transaction['amount'],2,'.','');
        }
        $legacyPayment = $editing && in_array(trim((string)($transaction['payment_method']??'')), ['Crédito','Crédito '], true);
        if($_SERVER['REQUEST_METHOD']==='POST'){
            verify_csrf();
            $data=[
                'client_id'=>(int)($_POST['client_id']??0) ?: null,
                'item'=>trim((string)($_POST['item']??'')),
                'amount'=>parse_money($_POST['amount']??0),
                'payment_method'=>trim((string)($_POST['payment_method']??'')),
                'installments'=>trim((string)($_POST['installments']??'1X')),
                'brand'=>trim((string)($_POST['brand']??'')),
                'status'=>trim((string)($_POST['status']??'Pendente')),
                'transaction_date'=>(string)($_POST['transaction_date']??date('Y-m-d')),
                'original_date'=>(string)($_POST['transaction_date']??date('Y-m-d')),
            ];
            if($editing) $data['original_date']=(string)($transaction['original_date']??$transaction['transaction_date']??$data['transaction_date']);
            if($data['item']==='') $errors[]='Informe o item.';
            $dateOk = DateTime::createFromFormat('Y-m-d', $data['transaction_date']);
            if(!$dateOk || $dateOk->format('Y-m-d') !== $data['transaction_date']) $errors[]='Informe uma data válida.';
            if($data['amount']<=0) $errors[]='Informe um valor maior que zero.';
            $validPayments = payment_options();
            if($legacyPayment) $validPayments[] = trim((string)($transaction['payment_method']??''));
            if(!in_array($data['payment_method'],$validPayments,true)) $errors[]='Método de pagamento inválido.';
            if($kind==='entrada' && $data['client_id']===null) $errors[]='Selecione um cliente.';
            if($data['payment_method']==='Cartão de Crédito'){
                if(!in_array($data['installments'],parcel_options(),true)) $errors[]='Selecione o número de parcelas.';
                if(!in_array($data['brand'],brand_options(),true)) $errors[]='Selecione a bandeira.';
                $data['status']='Pendente';
            } else { $data['installments']='1X'; $data['brand']=''; }
            if(!$errors){
                $saved=$tx->createOrReplace($data,$kind,$id);
                flash('success',$id>0?'Lançamento atualizado.':'Lançamento criado.');
                $redirectMonth=$data['payment_method']==='Cartão de Crédito' ? month_start(add_month_same_day($data['transaction_date'],1)) : month_start($data['transaction_date']);
                redirect_to('lancamentos',['month'=>$redirectMonth]);
            }
            $transaction=array_merge($transaction,$data); $transaction['amount']=$data['amount'];
        }
        $page='lancamentos'; $title=ucfirst($kind); $isEntrada=$kind==='entrada';
        require __DIR__.'/../views/transactions/form.php';
    }

    public function delete(): void {
        require_auth(); verify_csrf(); $id=(int)($_POST['id']??0); if($id>0)(new Transaction(db()))->delete($id); flash('success','Lançamento excluído.'); redirect_to('lancamentos');
    }
}
