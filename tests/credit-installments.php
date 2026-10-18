<?php
declare(strict_types=1);
require __DIR__.'/../app/helpers/helpers.php';
require __DIR__.'/../app/models/Transaction.php';

function check(bool $condition, string $message): void {
    if (!$condition) throw new RuntimeException($message);
}
function fixture(): array {
    $db=new PDO('sqlite::memory:', null, null, [PDO::ATTR_ERRMODE=>PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE=>PDO::FETCH_ASSOC]);
    $db->exec('CREATE TABLE clients (id INTEGER PRIMARY KEY, name TEXT)');
    $db->exec('CREATE TABLE transactions (id INTEGER PRIMARY KEY AUTOINCREMENT, kind TEXT, client_id INTEGER, item TEXT, amount NUMERIC, payment_method TEXT, installments TEXT, brand TEXT, status TEXT, transaction_date TEXT, period_month TEXT, notes TEXT, installment_group TEXT, installment_number INTEGER, installment_total INTEGER, original_date TEXT)');
    return [$db,new Transaction($db)];
}
$data=['client_id'=>null,'item'=>'Example','amount'=>100,'payment_method'=>'Pix','installments'=>'1X','brand'=>'','status'=>'Pendente','transaction_date'=>'2026-01-31','original_date'=>'2026-01-31','notes'=>'Keep this note'];
foreach (['entrada','saida'] as $kind) {
    [$db,$model]=fixture();
    $id=$model->createOrReplace($data,$kind);
    $credit=array_replace($data,['payment_method'=>'Cartão de Crédito','installments'=>'3X','brand'=>'Mastercard']);
    unset($credit['notes']);
    check($model->createOrReplace($credit,$kind,$id)===$id,'Original ID must survive conversion');
    $rows=$db->query('SELECT * FROM transactions ORDER BY installment_number')->fetchAll();
    check(count($rows)===3,'Conversion must create exactly three installments');
    check(array_column($rows,'transaction_date')===['2026-02-28','2026-03-31','2026-04-30'],'Month-end dates must be clamped correctly');
    check(array_column($rows,'period_month')===['2026-02-01','2026-03-01','2026-04-01'],'Installments must appear in following months');
    check(array_map('floatval',array_column($rows,'amount'))===[33.33,33.33,33.34],'Amounts must preserve the total');
    check(count(array_unique(array_column($rows,'installment_group')))===1 && !empty($rows[0]['installment_group']),'Installments must share a group');
    foreach($rows as $i=>$row) {
        check($row['status']==='Pendente' && $row['installment_number']===$i+1 && $row['installment_total']===3,'Installment metadata must be complete');
    }
    check($rows[0]['notes']===$data['notes'],'Conversion must preserve notes');
    $model->createOrReplace(array_replace($credit,['amount'=>33.33,'transaction_date'=>'2026-02-28']),$kind,$id);
    check((int)$db->query('SELECT COUNT(*) FROM transactions')->fetchColumn()===3,'Editing an existing installment must not duplicate the schedule');
}
[$db,$model]=fixture();
$id=$model->createOrReplace($data,'saida');
$db->exec("CREATE TRIGGER fail_installment BEFORE INSERT ON transactions WHEN NEW.installment_number=2 BEGIN SELECT RAISE(ABORT, 'Simulated failure'); END");
try {
    $model->createOrReplace($credit,'saida',$id);
    throw new RuntimeException('Expected insert failure');
} catch(PDOException $expected) {}
check((int)$db->query('SELECT COUNT(*) FROM transactions')->fetchColumn()===1,'Failure must not leave extra entries');
check($model->find($id,'saida')['payment_method']==='Pix','Failure must restore the original record');
$db->exec('DROP TRIGGER fail_installment');
$model->createOrReplace($credit,'entrada');
check((int)$db->query("SELECT COUNT(*) FROM transactions WHERE kind='entrada'")->fetchColumn()===3,'New credit records must still create installments');
echo "Credit installment regression checks passed.\n";
