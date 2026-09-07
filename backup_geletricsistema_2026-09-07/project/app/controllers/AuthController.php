<?php
declare(strict_types=1);

class AuthController {
    public function login(): void {
        if (current_user()) redirect_to('dashboard');
        $error=null; $email='';
        if ($_SERVER['REQUEST_METHOD']==='POST') {
            verify_csrf();
            $email=trim((string)($_POST['email']??'')); $password=(string)($_POST['password']??'');
            $st=db()->prepare('SELECT * FROM users WHERE email=? AND active=1 LIMIT 1'); $st->execute([$email]); $user=$st->fetch();
            if($user && password_verify($password,$user['password_hash'])) { login_user($user); redirect_to('dashboard'); }
            $error='E-mail ou senha inválidos.';
        }
        require __DIR__.'/../views/auth/login.php';
    }
    public function logout(): void { logout_user(); redirect_to('login'); }
}
