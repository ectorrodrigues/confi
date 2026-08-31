CREATE DATABASE IF NOT EXISTS confi CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE confi;
SET FOREIGN_KEY_CHECKS=0;
DROP TABLE IF EXISTS transactions;
DROP TABLE IF EXISTS recurrings;
DROP TABLE IF EXISTS clients;
DROP TABLE IF EXISTS users;
SET FOREIGN_KEY_CHECKS=1;

CREATE TABLE users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE clients (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(160) NOT NULL,
  phone VARCHAR(40) NOT NULL,
  email VARCHAR(190) NULL,
  address VARCHAR(190) NULL,
  number VARCHAR(30) NULL,
  complement VARCHAR(120) NULL,
  state CHAR(2) NULL,
  city VARCHAR(100) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_clients_name(name)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE recurrings (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  item VARCHAR(160) NOT NULL,
  amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  day_of_month TINYINT UNSIGNED NOT NULL,
  active TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE transactions (
  id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  kind ENUM('entrada','saida') NOT NULL,
  client_id INT UNSIGNED NULL,
  item VARCHAR(190) NOT NULL,
  amount DECIMAL(12,2) NOT NULL DEFAULT 0,
  payment_method VARCHAR(40) NULL,
  installments VARCHAR(20) NULL,
  brand VARCHAR(40) NULL,
  status ENUM('Pago','Pendente') NOT NULL DEFAULT 'Pago',
  transaction_date DATE NULL,
  period_month DATE NOT NULL,
  notes TEXT NULL,
  installment_group CHAR(32) NULL,
  installment_number TINYINT UNSIGNED NULL,
  installment_total TINYINT UNSIGNED NULL,
  original_date DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_transactions_period(period_month),
  INDEX idx_transactions_kind(kind),
  INDEX idx_transactions_due(transaction_date,status,payment_method),
  INDEX idx_transactions_group(installment_group),
  CONSTRAINT fk_transactions_client FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Demo login for local MAMP
INSERT INTO users(name,email,password_hash) VALUES
('Administrador','admin@confi.local','$2y$12$wIlTFdeEdi0ybz7QlFh1M.uXmtoCOpiSkDjGYiuba3jJyR1OPJVVW');
-- Password: admin123

USE confi;
INSERT INTO clients(name,phone,email,address,number,complement,state,city) VALUES ('Ana Maria Braga','(45) 99999-1234','anamariabraga@gmail.com','Rua Lorem Ipsum','123','Apto. 210','PR','Toledo');
INSERT INTO clients(name,phone,email,address,number,complement,state,city) VALUES ('João da Silva Sauro','',NULL,NULL,NULL,NULL,'PR','Toledo');
INSERT INTO clients(name,phone,email,address,number,complement,state,city) VALUES ('John Doe','',NULL,NULL,NULL,NULL,'PR','Toledo');
INSERT INTO clients(name,phone,email,address,number,complement,state,city) VALUES ('Jane Doe','',NULL,NULL,NULL,NULL,'PR','Toledo');
INSERT INTO clients(name,phone,email,address,number,complement,state,city) VALUES ('Dolly Parton','',NULL,NULL,NULL,NULL,'PR','Toledo');
INSERT INTO recurrings(item,amount,day_of_month) VALUES ('Aluguel',1800.00,1);
INSERT INTO recurrings(item,amount,day_of_month) VALUES ('Água',100.00,3);
INSERT INTO recurrings(item,amount,day_of_month) VALUES ('Internet',100.00,3);
INSERT INTO recurrings(item,amount,day_of_month) VALUES ('Salário Raquel',0.00,5);
INSERT INTO recurrings(item,amount,day_of_month) VALUES ('Salário Alda',0.00,5);
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA ANDREZA OK',30.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','3 BOJOS',24.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','4 PANOS MARINA OK',80.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','FIBRA',31.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','1 CALCINHA MARINA OK',10.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','TECIDOS SÓ RETALHOS',576.69,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','VESTIDO SOGRA OK',30.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','TECIDOS PARAGUAY',595.83,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS MARLETE OK',85.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','MOLDES',344.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','4 PANOS GABI OK',100.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','TECIDOS SÓ RETALHOS',172.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','3 LENÇOL GABI OK',30.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','CARIMBOS',165.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','2 PANOS ALE OK',50.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','LINHAS',34.50,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','ROUPA BENICIO OK',40.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','MOISES GABI OK',250.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','3 PANOS MARINA OK',60.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMA ALINE OK',90.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMA CARLINE OK',110.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS LU OK',60.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS CARLA OK',140.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA KATRINI OK',30.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','2 PIJAMAS CARLINE OK',220.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','JARDINEIRA CARLINE OK',90.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMAS SILMAIRA OK',625.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','NECESSAIRE ANA OK',40.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS MARIA',35.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SAIA MARLETE OK',20.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMAS MAYARA OK',320.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMA AMANDA OK',110.00,'Dinheiro','1X','Mastercard','Pago','2026-04-01','2026-04-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CAMISA ALINE',140.00,NULL,'1X','Mastercard','Pago','2026-05-01','2026-05-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','CONSERTO MAQUINA PICO',150.00,NULL,'1X','Mastercard','Pago','2026-05-01','2026-05-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMA MARINA OK',30.00,NULL,'1X','Mastercard','Pago','2026-05-02','2026-05-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','ALUGUEL',1850.00,NULL,'1X','Mastercard','Pago','2026-05-02','2026-05-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CALÇA FELIPE OK',10.00,NULL,'1X','Mastercard','Pago','2026-05-04','2026-05-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CALÇA HENRIQUE OK',35.00,NULL,'1X','Mastercard','Pago','2026-05-05','2026-05-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMA MARIA OK',120.00,NULL,'1X','Mastercard','Pago','2026-05-06','2026-05-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS KATRINI OK',90.00,NULL,'1X','Mastercard','Pago','2026-05-08','2026-05-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SUZANA OK',180.00,NULL,'1X','Mastercard','Pago','2026-05-09','2026-05-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PAMELA OK',25.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','TECIDOS CALÇA',220.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','KEILLA OK',40.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','MOTOR MAQUINA',850.00,NULL,'1X','Mastercard','Pago','2026-06-02','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','ANATIELE OK',25.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','ALUGUEL',1850.00,NULL,'1X','Mastercard','Pago','2026-06-03','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','LU OK',130.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','MAQUINA TON',92.00,NULL,'1X','Mastercard','Pago','2026-06-04','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CARLA OK',20.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','FITAS',30.00,NULL,'1X','Mastercard','Pago','2026-06-05','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','VESTIDO HELENA OK',65.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CAMISA ALINE OK',140.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','VESTIDO ALINE OK',80.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','VESTIDO NEIVA OK',85.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DUANI BARRAS OK',60.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS FELIPE OK',70.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','JARDINEIRA LETICIA OK',125.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMA DIANA OK',100.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SABINE OK',50.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS SIL OK',150.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DUANI  OK',90.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','VESTIDO FABIANA OK',320.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','VESTIDO PAULA OK',95.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SAIA JUNINA MARCIA OK',85.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','RICARDO APLIQUE OK',21.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','ADRIANE OK',50.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','KEILLA  VESTIDO OK',90.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','MARLETE CNSERTOS OK',263.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','MARCIA CONSERTOS OK',125.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','FABI CONSERTOS OK',75.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS KARINE OK',45.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CALÇA ANDRE OK',25.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SAIA SAIO OK',25.00,NULL,'1X','Mastercard','Pago','2026-06-01','2026-06-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SAIA CARLA',0.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','ALUGUEL',1850.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CALÇAS ANA ',0.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','SALARIO MAE',400.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CALÇA MARCIA',0.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Luz',86.58,NULL,'1X','Mastercard','Pago','2026-07-04','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','VESTIDOS FABI',0.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CALÇA TIAGO OK',280.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','MARLETE OK ',100.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTO SABINE OK',120.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS DAYANE OK',130.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS BIQUINI OK',45.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMA CLARA OK',130.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BLAZER ROSSATO OK',50.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS FABIANA OK',38.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','VESTIDO JUNINO DAIA OK',95.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS CLAUDETE',0.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS DUANI OK',70.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA DIANA OK',20.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA VIZINHA OK',20.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS ALINE OK',60.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','MARLETE SAIA E CALÇA OK',100.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','AJUSTE PATRICIA OK',25.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','JAIRO OK',45.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','REIS BARRAS OK',50.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','AJUSTE CALÇA LU OK',35.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA LUANA OK',25.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CONSERTOS ALESSANDRA OK',38.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA ERIKA OK',25.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CLAUCIMAR OK',45.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRAS RAFA OK',120.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PAMELA VESTIDO E PILLOW OK',65.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','NEUDI OK',35.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA VESTIDO MARIANA OK',60.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DAYANE CONSERTOS OK',250.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA VESTIDO PAMELA OK',85.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','MARA SALOMAO BARRAS OK',45.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PATRICIA BARRAS OK',100.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','MARIANA ZIPER OK',25.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA JALECO OK',20.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRA ERIKA OK',25.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','BARRAS FABIANA OK',55.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMA BRUNA OK',130.00,NULL,'1X','Mastercard','Pago','2026-07-01','2026-07-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','KARINE OK',35.00,'Crédito','1X','Mastercard','Pendente','2026-08-04','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Aluguel',1850.00,'Dinheiro','1X','Mastercard','Pago','2026-08-20','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SANDRAOK',60.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Luz',143.30,'Débito','1X','Mastercard','Pago','2026-08-04','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','KEILLA OK',170.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Internet',89.90,'Débito','1X','Mastercard','Pago','2026-08-15','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CALÇAS ANA OK',700.00,'Crédito','1X','Mastercard','Pendente','2026-08-06','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Salário Raquel',2000.00,'Pix','1X','Mastercard','Pendente',NULL,'2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','GENOVEVA OK',100.00,'Dinheiro','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Salário Alda',400.00,'Dinheiro','1X','Mastercard','Pendente',NULL,'2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','NEIVA OK',70.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Linha celular',35.00,'Pix','1X','Mastercard','Pago','2026-08-28','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CAROL CALCINHAS OK',70.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Tecido Arnaldo ',40.00,'Pix','1X','Mastercard','Pago','2026-08-24','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PIJAMAS BRUNA OK',240.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','MEI',87.05,'Pix','1X','Mastercard','Pago','2026-08-20','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','FABIANO BARRA OK',50.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Panorama aviamentos',117.50,'Pix','1X','Mastercard','Pago','2026-08-11','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','ERIKA OK',135.00,'Crédito ','1X','Mastercard','Pendente','2026-08-12','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Luminaria maquina',55.00,'Pix','1X','Mastercard','Pago','2026-08-11','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CLAUDETE',350.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Dariane',23.80,'Pix','1X','Mastercard','Pago','2026-08-10','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','ALESSANDRA OK',20.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Cesta relacionamento Sicredi',35.00,'Débito','1X','Mastercard','Pago','2026-08-10','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','PATRICIA JAQUETA OK',25.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Integração cota capital',10.00,'Débito','1X','Mastercard','Pago','2026-08-10','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CARLA SAIA',290.00,NULL,'1X','Mastercard','Pendente','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Dariane',91.20,'Pix','1X','Mastercard','Pago','2026-08-05','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','MANI OK',50.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Saída conta Raquel',100.00,'Pix','1X','Mastercard','Pago','2026-08-03','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DAIA SICREDI OK',55.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DIANA PIJAMA OK',110.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CASACO DAIANE OK',130.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','ANDRESSA OK',150.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','MARLETE OK',40.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','JEFERSON OK',25.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','ALINE VESTIDO OK',40.00,'Débito','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CATUSSO OK',80.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DIANA BARRA OK',35.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','AMANDA OK',120.00,'Débito','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','2 CALCINHAS NINA OK',20.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CAMILA OK',55.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CALÇA MARCIA',175.00,NULL,'1X','Mastercard','Pendente','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DONA FATIMA',120.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','GABRIEL ',125.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DIANA PIJAMA CONDI',140.00,'Débito','1X','Mastercard','Pago','2026-08-26','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SHEILA OK',70.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SUELI',30.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','GABRIELE OK',60.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','LUCILENE OK',25.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DANI MERTZ OK',40.00,'Débito','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','AMANDA ',180.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','FABI CONSERTOS OK',230.00,'Pix','1X','Mastercard','Pago','2026-08-01','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','JESSICA BARRA E PIJAMA',200.00,'Crédito','1X','Mastercard','Pendente','2026-08-26','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','AMANDA',180.00,' ','1X','Mastercard','Pendente',NULL,'2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','DAIANE',200.00,'Pix','1X','Mastercard','Pago','2026-08-28','2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','FABI',90.00,NULL,'1X','Mastercard','Pendente',NULL,'2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','SHEILA',50.00,NULL,'1X','Mastercard','Pendente',NULL,'2026-08-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','TIA CELIA',80.00,'Dinheiro','1X','Mastercard','Pendente','2026-08-01','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Aluguel',1850.00,'Dinheiro','1X','Mastercard','Pendente','2026-09-20','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','KARINE OK',35.00,'Crédito','1X','Mastercard','Pendente','2026-08-04','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Luz',169.44,'Débito','1X','Mastercard','Pendente','2026-09-04','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','CALÇAS ANA OK',350.00,'Crédito','1X','Mastercard','Pendente','2026-08-06','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Internet',89.90,'Débito','1X','Mastercard','Pendente','2026-09-15','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','ERIKA OK',135.00,'Crédito ','1X','Mastercard','Pendente','2026-08-12','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Salário Raquel',2000.00,'Pix','1X','Mastercard','Pendente',NULL,'2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('entrada','JESSICA BARRA E PIJAMA',200.00,'Crédito','1X','Mastercard','Pendente','2026-08-26','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Salário Alda',400.00,'Dinheiro','1X','Mastercard','Pendente',NULL,'2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','MEI',87.05,'Pix','1X','Mastercard','Pendente','2026-09-20','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Cesta relacionamento Sicredi',35.00,'Débito','1X','Mastercard','Pendente','2026-09-10','2026-09-01');
INSERT INTO transactions(kind,item,amount,payment_method,installments,brand,status,transaction_date,period_month) VALUES ('saida','Integração cota capital',10.00,'Débito','1X','Mastercard','Pendente','2026-09-10','2026-09-01');
