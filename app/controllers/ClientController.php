<?php
declare(strict_types=1);

class ClientController {
    private function defaults(): array { return ['id'=>0,'name'=>'','phone'=>'','email'=>'','address'=>'','number'=>'','complement'=>'','state'=>'PR','city'=>'Toledo']; }
    public function index(): void { require_auth(); $clients=(new Client(db()))->all(); $page='clientes'; $title='Clientes'; require __DIR__.'/../views/clients/index.php'; }
    public function form(): void {
        require_auth(); $model=new Client(db()); $id=(int)($_GET['id']??0); $editing=$id>0; $client=$editing?($model->find($id)?:$this->defaults()):$this->defaults(); $errors=[];
        $return=(string)($_GET['return']??$_POST['return']??'clientes');
        if($_SERVER['REQUEST_METHOD']==='POST'){
            verify_csrf();
            foreach(['name','phone','email','address','number','complement','state','city'] as $f) $client[$f]=trim((string)($_POST[$f]??''));
            if($client['name']==='')$errors[]='Nome é obrigatório.'; if($client['phone']==='')$errors[]='Telefone é obrigatório.';
            if(!$errors){$model->save($client,$id); flash('success',$editing?'Cliente atualizado.':'Cliente cadastrado.'); redirect_to($return==='entrada'||$return==='saida'?$return:'clientes');}
        }
        $states=['AC','AL','AP','AM','BA','CE','DF','ES','GO','MA','MT','MS','MG','PA','PB','PR','PE','PI','RJ','RN','RS','RO','RR','SC','SP','SE','TO'];
        $page='clientes'; $title=$editing?'Editar Cliente':'Clientes'; require __DIR__.'/../views/clients/form.php';
    }
    public function cities(): void {
        require_auth();
        header('Content-Type: application/json; charset=utf-8');
        $uf = strtoupper(trim((string)($_GET['uf'] ?? '')));
        if (!preg_match('/^[A-Z]{2}$/', $uf)) {
            http_response_code(422);
            echo json_encode(['error' => 'UF inválida'], JSON_UNESCAPED_UNICODE);
            return;
        }
        $url = 'https://servicodados.ibge.gov.br/api/v1/localidades/estados/' . rawurlencode($uf) . '/municipios';
        $ch = curl_init($url);
        curl_setopt_array($ch, [
            CURLOPT_RETURNTRANSFER => true,
            CURLOPT_FOLLOWLOCATION => true,
            CURLOPT_CONNECTTIMEOUT => 5,
            CURLOPT_TIMEOUT => 15,
            CURLOPT_HTTPHEADER => ['Accept: application/json'],
            CURLOPT_USERAGENT => 'confi/1.0',
        ]);
        $json = curl_exec($ch);
        $httpCode = (int)curl_getinfo($ch, CURLINFO_HTTP_CODE);
        curl_close($ch);
        if ($json === false || $httpCode < 200 || $httpCode >= 300) {
            http_response_code(502);
            echo json_encode(['error' => 'Não foi possível consultar o serviço de localidades do IBGE.'], JSON_UNESCAPED_UNICODE);
            return;
        }
        echo $json;
    }

    public function delete(): void { require_auth(); verify_csrf(); (new Client(db()))->delete((int)($_POST['id']??0)); flash('success','Cliente excluído.'); redirect_to('clientes'); }
}
