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
  service_order_number INT UNSIGNED NULL,
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
  recurring_id INT UNSIGNED NULL,
  recurring_reference_month DATE NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX idx_transactions_period(period_month),
  INDEX idx_transactions_kind(kind),
  INDEX idx_transactions_service_order(service_order_number),
  INDEX idx_transactions_due(transaction_date,status,payment_method),
  INDEX idx_transactions_group(installment_group),
  INDEX idx_transactions_recurring(recurring_id, recurring_reference_month),
  UNIQUE KEY uq_transactions_recurring_month(recurring_id, recurring_reference_month),
  CONSTRAINT fk_transactions_client FOREIGN KEY(client_id) REFERENCES clients(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

USE confi;

INSERT INTO clients (`id`, `name`, `phone`, `email`, `address`, `number`, `complement`, `state`, `city`, `created_at`) VALUES
(6, 'Sheila Pereira', '(45) 99847-8976', '', '', '', '', 'PR', 'Toledo', '2026-08-31 01:24:49'),
(7, 'Fabiana Xavier', '(45) 99966-0677', '', '', '', '', 'PR', 'Toledo', '2026-08-31 01:26:37'),
(8, 'Amanda Rodrigues', '(45) 99982-8849', '', '', '', '', 'PR', 'Toledo', '2026-08-31 01:27:24'),
(9, 'Jessica Butke', '(45) 99935-4202', '', '', '', '', 'PR', 'Toledo', '2026-08-31 01:39:47'),
(10, 'Erika Dela Porte', '(45) 99993-0216', '', '', '', '', 'PR', 'Toledo', '2026-08-31 01:41:58'),
(11, 'Karine Pigosso', '(45) 99909-1822', '', '', '', '', 'PR', 'Toledo', '2026-08-31 02:00:00'),
(12, 'Ana Claudia Vieira', '(45) 99135-3863', '', '', '', '', 'PR', 'Toledo', '2026-08-31 02:01:01'),
(13, 'Claudete Trovo', '(45) 99849-0806', '', '', '', '', 'PR', 'Toledo', '2026-08-31 22:11:35'),
(14, 'Daniela Mertz', '(45) 99133-9941', '', '', '', '', 'PR', 'Toledo', '2026-08-31 22:16:14'),
(15, 'Márcia Torino Rocha', '(45) 99188-7525', '', 'Rua Formosa', '', '', 'PR', 'Toledo', '2026-08-31 22:32:32'),
(16, 'Carla Campagnolo', '(45) 99119-5920', '', '', '', '', 'PR', 'Toledo', '2026-08-31 22:33:36'),
(17, 'Celia Slongo', '(45) 99804-0936', '', '', '', '', 'PR', 'Toledo', '2026-08-31 23:01:32'),
(18, 'Keilla Vanessa de Souza', '(67) 99997-6083', '', 'Rua Gertrudes Pedrini', '936', 'Jd Bressan', 'PR', 'Toledo', '2026-09-01 16:39:55'),
(19, 'Dayanne Zimmer', '(45) 99950-9797', '', '', '', '', 'PR', 'Toledo', '2026-09-01 16:43:34'),
(20, 'Marlete Adriane Gross Rohsler', '(45) 99906-4552', '', 'Rua Breno Justen', '82', 'Vila Becker', 'PR', 'Toledo', '2026-09-01 16:46:30'),
(21, 'Claucimar Anholeto', '(45) 99974-5301', '', '', '', '', 'PR', 'Toledo', '2026-09-01 16:50:15'),
(22, 'Carol Weich', '(45) 99901-2981', '', '', '', '', 'PR', 'Toledo', '2026-09-01 16:50:44'),
(23, 'Diana Leite', '(45) 99992-9900', '', '', '', '', 'PR', 'Toledo', '2026-09-01 16:51:14'),
(24, 'Beatriz Welter Cavalli', '(45) 99914-7960', '', '', '', '', 'PR', 'Toledo', '2026-09-01 16:51:57'),
(25, 'Suzana Borges', '(45) 99995-9829', '', '', '', '', 'PR', 'Toledo', '2026-09-01 16:52:25'),
(26, 'Daiana Lovis', '(45) 99107-9086', '', 'Rua Anibaldo Hoffmann', '', '', 'PR', 'Toledo', '2026-09-01 16:53:21'),
(27, 'Jairo Antonio Puntel', '(45) 99981-1083', '', 'R. Santos Dumont', '2885', '', 'PR', 'Toledo', '2026-09-01 16:54:09'),
(28, 'Katrini Knupp', '(45) 99122-0517', '', '', '', '', 'PR', 'Toledo', '2026-09-01 16:54:44'),
(29, 'Debora Stiipp', '(45) 99959-3533', '', '', '', '', 'PR', 'Toledo', '2026-09-01 17:00:04'),
(30, 'Rose Melo', '(45) 99974-5869', '', '', '', '', 'PR', 'Toledo', '2026-09-01 17:01:31'),
(31, 'Diana Maria Beal Zenni', '(45) 99101-3516', '', '', '', '', 'PR', 'Toledo', '2026-09-01 17:07:55'),
(32, 'Jefferson Ribeiro', '(45) 99952-2652', '', '', '', '', 'PR', 'Toledo', '2026-09-01 17:08:44'),
(33, 'Lucilene Margarida Mestriner Manzato', '(45) 99898-8561', '', '', '', '', 'PR', 'Toledo', '2026-09-01 17:14:54'),
(34, 'Patricia Maiara Belo', '(45) 99105-5698', '', '', '', '', 'PR', 'Toledo', '2026-09-01 17:15:44'),
(35, 'Cleonice L Petter', '(45) 99856-2757', '', '', '', '', 'PR', 'Toledo', '2026-09-02 15:05:34'),
(36, 'Ana Maria', '(45) 99926-3248', '', '', '', '', 'PR', 'Toledo', '2026-09-03 19:54:40'),
(37, 'Duani Bazzo', '(44) 99909-8444', '', '', '', '', 'PR', 'Toledo', '2026-09-03 20:01:13'),
(38, 'Mauren Sauer', '(45) 99933-5103', '', '', '', '', 'PR', 'Toledo', '2026-09-04 11:14:10'),
(39, 'Alessandra Pereira da Silva', '(45) 99966-0345', '', '', '', '', 'PR', 'Toledo', '2026-09-04 18:36:27');

INSERT INTO recurrings (`id`, `item`, `amount`, `day_of_month`, `active`, `created_at`) VALUES
(1, 'Aluguel', 1800.00, 1, 1, '2026-08-31 01:19:58'),
(3, 'Internet', 89.90, 15, 1, '2026-08-31 01:19:58'),
(4, 'Salário Raquel', 2000.00, 5, 1, '2026-08-31 01:19:58'),
(5, 'Salário Alda', 500.00, 5, 1, '2026-08-31 01:19:58'),
(6, 'Cesta Relacionamento Sicredi', 35.00, 10, 1, '2026-09-01 17:25:00'),
(7, 'Integração cota capital', 10.00, 10, 1, '2026-09-01 17:25:23'),
(8, 'Luz', 10.00, 4, 1, '2026-09-01 17:26:11'),
(9, 'MEI', 87.05, 20, 1, '2026-09-01 17:26:27');

INSERT INTO transactions (`id`, `kind`, `client_id`, `item`, `amount`, `payment_method`, `installments`, `brand`, `status`, `transaction_date`, `period_month`, `notes`, `installment_group`, `installment_number`, `installment_total`, `original_date`, `created_at`) VALUES
(1, 'entrada', NULL, 'BARRA ANDREZA OK', 30.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(2, 'saida', NULL, '3 BOJOS', 24.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(3, 'entrada', NULL, '4 PANOS MARINA OK', 80.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(4, 'saida', NULL, 'FIBRA', 31.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(5, 'entrada', NULL, '1 CALCINHA MARINA OK', 10.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(6, 'saida', NULL, 'TECIDOS SÓ RETALHOS', 576.69, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(7, 'entrada', NULL, 'VESTIDO SOGRA OK', 30.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(8, 'saida', NULL, 'TECIDOS PARAGUAY', 595.83, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(9, 'entrada', NULL, 'CONSERTOS MARLETE OK', 85.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(10, 'saida', NULL, 'MOLDES', 344.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(11, 'entrada', NULL, '4 PANOS GABI OK', 100.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(12, 'saida', NULL, 'TECIDOS SÓ RETALHOS', 172.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(13, 'entrada', NULL, '3 LENÇOL GABI OK', 30.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(14, 'saida', NULL, 'CARIMBOS', 165.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(15, 'entrada', NULL, '2 PANOS ALE OK', 50.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(16, 'saida', NULL, 'LINHAS', 34.50, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(17, 'entrada', NULL, 'ROUPA BENICIO OK', 40.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(18, 'entrada', NULL, 'MOISES GABI OK', 250.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(19, 'entrada', NULL, '3 PANOS MARINA OK', 60.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(20, 'entrada', NULL, 'PIJAMA ALINE OK', 90.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(21, 'entrada', NULL, 'PIJAMA CARLINE OK', 110.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(22, 'entrada', NULL, 'CONSERTOS LU OK', 60.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(23, 'entrada', NULL, 'CONSERTOS CARLA OK', 140.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(24, 'entrada', NULL, 'BARRA KATRINI OK', 30.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(25, 'entrada', NULL, '2 PIJAMAS CARLINE OK', 220.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(26, 'entrada', NULL, 'JARDINEIRA CARLINE OK', 90.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(27, 'entrada', NULL, 'PIJAMAS SILMAIRA OK', 625.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(28, 'entrada', NULL, 'NECESSAIRE ANA OK', 40.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(29, 'entrada', NULL, 'CONSERTOS MARIA', 35.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(30, 'entrada', NULL, 'SAIA MARLETE OK', 20.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(31, 'entrada', NULL, 'PIJAMAS MAYARA OK', 320.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(32, 'entrada', NULL, 'PIJAMA AMANDA OK', 110.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-04-01', '2026-04-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(33, 'entrada', NULL, 'CAMISA ALINE', 140.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-05-01', '2026-05-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(34, 'saida', NULL, 'CONSERTO MAQUINA PICO', 150.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-05-01', '2026-05-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(35, 'entrada', NULL, 'PIJAMA MARINA OK', 30.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-05-02', '2026-05-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(36, 'saida', NULL, 'ALUGUEL', 1850.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-05-02', '2026-05-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(37, 'entrada', NULL, 'CALÇA FELIPE OK', 10.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-05-04', '2026-05-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(38, 'entrada', NULL, 'CALÇA HENRIQUE OK', 35.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-05-05', '2026-05-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(39, 'entrada', NULL, 'PIJAMA MARIA OK', 120.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-05-06', '2026-05-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(40, 'entrada', NULL, 'CONSERTOS KATRINI OK', 90.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-05-08', '2026-05-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(41, 'entrada', NULL, 'SUZANA OK', 180.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-05-09', '2026-05-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(42, 'entrada', NULL, 'PAMELA OK', 25.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(43, 'saida', NULL, 'TECIDOS CALÇA', 220.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(44, 'entrada', NULL, 'KEILLA OK', 40.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(45, 'saida', NULL, 'MOTOR MAQUINA', 850.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-02', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(46, 'entrada', NULL, 'ANATIELE OK', 25.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(47, 'saida', NULL, 'ALUGUEL', 1850.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-03', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(48, 'entrada', NULL, 'LU OK', 130.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(49, 'saida', NULL, 'MAQUINA TON', 92.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-04', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(50, 'entrada', NULL, 'CARLA OK', 20.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(51, 'saida', NULL, 'FITAS', 30.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-05', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(52, 'entrada', NULL, 'VESTIDO HELENA OK', 65.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(53, 'entrada', NULL, 'CAMISA ALINE OK', 140.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(54, 'entrada', NULL, 'VESTIDO ALINE OK', 80.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(55, 'entrada', NULL, 'VESTIDO NEIVA OK', 85.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(56, 'entrada', NULL, 'DUANI BARRAS OK', 60.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(57, 'entrada', NULL, 'CONSERTOS FELIPE OK', 70.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(58, 'entrada', NULL, 'JARDINEIRA LETICIA OK', 125.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(59, 'entrada', NULL, 'PIJAMA DIANA OK', 100.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(60, 'entrada', NULL, 'SABINE OK', 50.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(61, 'entrada', NULL, 'CONSERTOS SIL OK', 150.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(62, 'entrada', NULL, 'DUANI  OK', 90.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(63, 'entrada', NULL, 'VESTIDO FABIANA OK', 320.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(64, 'entrada', NULL, 'VESTIDO PAULA OK', 95.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(65, 'entrada', NULL, 'SAIA JUNINA MARCIA OK', 85.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(66, 'entrada', NULL, 'RICARDO APLIQUE OK', 21.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(67, 'entrada', NULL, 'ADRIANE OK', 50.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(68, 'entrada', NULL, 'KEILLA  VESTIDO OK', 90.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(69, 'entrada', NULL, 'MARLETE CNSERTOS OK', 263.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(70, 'entrada', NULL, 'MARCIA CONSERTOS OK', 125.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(71, 'entrada', NULL, 'FABI CONSERTOS OK', 75.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(72, 'entrada', NULL, 'CONSERTOS KARINE OK', 45.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(73, 'entrada', NULL, 'CALÇA ANDRE OK', 25.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(74, 'entrada', NULL, 'SAIA SAIO OK', 25.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-06-01', '2026-06-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(75, 'entrada', NULL, 'SAIA CARLA', 0.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(76, 'saida', NULL, 'ALUGUEL', 1850.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(77, 'entrada', NULL, 'CALÇAS ANA ', 0.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(78, 'saida', NULL, 'SALARIO MAE', 400.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(79, 'entrada', NULL, 'CALÇA MARCIA', 0.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(80, 'saida', NULL, 'Luz', 86.58, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-04', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(81, 'entrada', NULL, 'VESTIDOS FABI', 0.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(82, 'entrada', NULL, 'CALÇA TIAGO OK', 280.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(83, 'entrada', NULL, 'MARLETE OK ', 100.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(84, 'entrada', NULL, 'CONSERTO SABINE OK', 120.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(85, 'entrada', NULL, 'CONSERTOS DAYANE OK', 130.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(86, 'entrada', NULL, 'CONSERTOS BIQUINI OK', 45.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(87, 'entrada', NULL, 'PIJAMA CLARA OK', 130.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(88, 'entrada', NULL, 'BLAZER ROSSATO OK', 50.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(89, 'entrada', NULL, 'CONSERTOS FABIANA OK', 38.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(90, 'entrada', NULL, 'VESTIDO JUNINO DAIA OK', 95.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(91, 'entrada', NULL, 'CONSERTOS CLAUDETE', 0.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(92, 'entrada', NULL, 'CONSERTOS DUANI OK', 70.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(93, 'entrada', NULL, 'BARRA DIANA OK', 20.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(94, 'entrada', NULL, 'BARRA VIZINHA OK', 20.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(95, 'entrada', NULL, 'CONSERTOS ALINE OK', 60.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(96, 'entrada', NULL, 'MARLETE SAIA E CALÇA OK', 100.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(97, 'entrada', NULL, 'AJUSTE PATRICIA OK', 25.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(98, 'entrada', NULL, 'JAIRO OK', 45.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(99, 'entrada', NULL, 'REIS BARRAS OK', 50.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(100, 'entrada', NULL, 'AJUSTE CALÇA LU OK', 35.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(101, 'entrada', NULL, 'BARRA LUANA OK', 25.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(102, 'entrada', NULL, 'CONSERTOS ALESSANDRA OK', 38.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(103, 'entrada', NULL, 'BARRA ERIKA OK', 25.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(104, 'entrada', NULL, 'CLAUCIMAR OK', 45.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(105, 'entrada', NULL, 'BARRAS RAFA OK', 120.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(106, 'entrada', NULL, 'PAMELA VESTIDO E PILLOW OK', 65.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(107, 'entrada', NULL, 'NEUDI OK', 35.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(108, 'entrada', NULL, 'BARRA VESTIDO MARIANA OK', 60.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(109, 'entrada', NULL, 'DAYANE CONSERTOS OK', 250.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(110, 'entrada', NULL, 'BARRA VESTIDO PAMELA OK', 85.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(111, 'entrada', NULL, 'MARA SALOMAO BARRAS OK', 45.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(112, 'entrada', NULL, 'PATRICIA BARRAS OK', 100.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(113, 'entrada', NULL, 'MARIANA ZIPER OK', 25.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(114, 'entrada', NULL, 'BARRA JALECO OK', 20.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(115, 'entrada', NULL, 'BARRA ERIKA OK', 25.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(116, 'entrada', NULL, 'BARRAS FABIANA OK', 55.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(117, 'entrada', NULL, 'PIJAMA BRUNA OK', 130.00, NULL, 'À vista', 'Mastercard', 'Pago', '2026-07-01', '2026-07-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(118, 'entrada', 11, 'KARINE OK', 35.00, 'Cartão de Crédito', '1X', 'Mastercard', 'Pago', '2026-09-04', '2026-09-01', NULL, NULL, NULL, NULL, '2026-08-04', '2026-08-31 01:19:58'),
(119, 'saida', NULL, 'Aluguel', 1850.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-08-20', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(120, 'entrada', NULL, 'SANDRAOK', 60.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(121, 'saida', NULL, 'Luz', 143.30, 'Débito', 'À vista', 'Mastercard', 'Pago', '2026-08-04', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(122, 'entrada', NULL, 'KEILLA OK', 170.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(123, 'saida', NULL, 'Internet', 89.90, 'Débito', 'À vista', 'Mastercard', 'Pago', '2026-08-15', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(126, 'entrada', NULL, 'GENOVEVA OK', 100.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(128, 'entrada', NULL, 'NEIVA OK', 70.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(129, 'saida', NULL, 'Linha celular', 35.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-28', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(130, 'entrada', NULL, 'CAROL CALCINHAS OK', 70.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(131, 'saida', NULL, 'Tecido Arnaldo ', 40.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-24', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(132, 'entrada', NULL, 'PIJAMAS BRUNA OK', 240.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(133, 'saida', NULL, 'MEI', 87.05, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-20', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(134, 'entrada', NULL, 'FABIANO BARRA OK', 50.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(135, 'saida', NULL, 'Panorama aviamentos', 117.50, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-11', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(136, 'entrada', 10, 'ERIKA OK', 135.00, 'Cartão de Crédito', '1X', 'Mastercard', 'Pendente', '2026-09-12', '2026-09-01', NULL, NULL, NULL, NULL, '2026-08-12', '2026-08-31 01:19:58'),
(137, 'saida', NULL, 'Luminaria maquina', 55.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-11', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(138, 'entrada', 13, 'consertos varias roupas', 170.00, 'Cartão de Crédito', '1X', 'Mastercard', 'Pago', '2026-08-20', '2026-08-01', NULL, NULL, NULL, NULL, '2026-08-01', '2026-08-31 01:19:58'),
(139, 'saida', NULL, 'Dariane', 23.80, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-10', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(140, 'entrada', NULL, 'ALESSANDRA OK', 20.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(141, 'saida', NULL, 'Cesta relacionamento Sicredi', 35.00, 'Débito', 'À vista', 'Mastercard', 'Pago', '2026-08-10', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(142, 'entrada', NULL, 'PATRICIA JAQUETA OK', 25.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(143, 'saida', NULL, 'Integração cota capital', 10.00, 'Débito', 'À vista', 'Mastercard', 'Pago', '2026-08-10', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(144, 'entrada', 16, 'Saia', 290.00, 'Pix', '1X', '', 'Pendente', '2026-09-01', '2026-09-01', NULL, NULL, NULL, NULL, '2026-08-01', '2026-08-31 01:19:58'),
(145, 'saida', NULL, 'Dariane', 91.20, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-05', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(146, 'entrada', NULL, 'MANI OK', 50.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(147, 'saida', NULL, 'Saída conta Raquel', 100.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-03', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(148, 'entrada', NULL, 'DAIA SICREDI OK', 55.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(149, 'entrada', NULL, 'DIANA PIJAMA OK', 110.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(150, 'entrada', NULL, 'CASACO DAIANE OK', 130.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(151, 'entrada', NULL, 'ANDRESSA OK', 150.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(152, 'entrada', NULL, 'MARLETE OK', 40.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(153, 'entrada', NULL, 'JEFERSON OK', 25.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(154, 'entrada', NULL, 'ALINE VESTIDO OK', 40.00, 'Débito', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(155, 'entrada', NULL, 'CATUSSO OK', 80.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(156, 'entrada', NULL, 'DIANA BARRA OK', 35.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(157, 'entrada', NULL, 'AMANDA OK', 120.00, 'Débito', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(158, 'entrada', NULL, '2 CALCINHAS NINA OK', 20.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(159, 'entrada', NULL, 'CAMILA OK', 55.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(160, 'entrada', 15, 'Calça', 175.00, 'Pix', '1X', '', 'Pago', '2026-09-02', '2026-09-01', NULL, NULL, NULL, NULL, '2026-08-01', '2026-08-31 01:19:58'),
(161, 'entrada', NULL, 'DONA FATIMA', 120.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(162, 'entrada', NULL, 'GABRIEL ', 125.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(163, 'entrada', NULL, 'DIANA PIJAMA CONDI', 140.00, 'Débito', 'À vista', 'Mastercard', 'Pago', '2026-08-26', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(164, 'entrada', NULL, 'SHEILA OK', 70.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(165, 'entrada', NULL, 'SUELI', 30.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(166, 'entrada', NULL, 'GABRIELE OK', 60.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(167, 'entrada', NULL, 'LUCILENE OK', 25.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(168, 'entrada', NULL, 'DANI MERTZ OK', 40.00, 'Débito', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(169, 'entrada', NULL, 'AMANDA ', 180.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(170, 'entrada', NULL, 'FABI CONSERTOS OK', 230.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(171, 'entrada', 9, 'JESSICA BARRA E PIJAMA', 200.00, 'Cartão de Crédito', '1X', 'Mastercard', 'Pendente', '2026-09-26', '2026-09-01', NULL, NULL, NULL, NULL, '2026-08-26', '2026-08-31 01:19:58'),
(172, 'entrada', 8, 'AMANDA', 180.00, 'Pix', '1X', '', 'Pago', '2026-09-04', '2026-09-01', NULL, NULL, NULL, NULL, '2026-08-31', '2026-08-31 01:19:58'),
(173, 'entrada', NULL, 'DAIANE', 200.00, 'Pix', 'À vista', 'Mastercard', 'Pago', '2026-08-28', '2026-08-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(174, 'entrada', 7, 'FABI', 90.00, 'Dinheiro', '1X', '', 'Pendente', '2026-09-01', '2026-09-01', NULL, NULL, NULL, NULL, '2026-08-31', '2026-08-31 01:19:58'),
(176, 'entrada', 17, 'TIA CELIA', 80.00, 'Pix', '1X', '', 'Pago', '2026-09-02', '2026-09-01', NULL, NULL, NULL, NULL, '2026-08-01', '2026-08-31 01:19:58'),
(177, 'saida', NULL, 'Aluguel', 1850.00, 'Dinheiro', 'À vista', 'Mastercard', 'Pendente', '2026-09-20', '2026-09-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(179, 'saida', NULL, 'Luz', 169.44, 'Débito', '1X', '', 'Pago', '2026-09-03', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-04', '2026-08-31 01:19:58'),
(181, 'saida', NULL, 'Internet', 89.90, 'Débito', 'À vista', 'Mastercard', 'Pendente', '2026-09-15', '2026-09-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(183, 'saida', NULL, 'Salário Raquel', 2000.00, 'Pix', '1X', '', 'Pendente', '2026-09-05', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-06', '2026-08-31 01:19:58'),
(185, 'saida', NULL, 'Salário Alda', 500.00, 'Dinheiro', '1X', '', 'Pendente', '2026-09-05', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-06', '2026-08-31 01:19:58'),
(186, 'saida', NULL, 'MEI', 87.05, 'Pix', 'À vista', 'Mastercard', 'Pendente', '2026-09-20', '2026-09-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(187, 'saida', NULL, 'Cesta relacionamento Sicredi', 35.00, 'Débito', 'À vista', 'Mastercard', 'Pendente', '2026-09-10', '2026-09-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(188, 'saida', NULL, 'Integração cota capital', 10.00, 'Débito', 'À vista', 'Mastercard', 'Pendente', '2026-09-10', '2026-09-01', NULL, NULL, NULL, NULL, NULL, '2026-08-31 01:19:58'),
(189, 'saida', NULL, 'Salário Raquel', 2000.00, 'Pix', '1X', '', 'Pendente', '2026-08-01', '2026-08-01', NULL, NULL, NULL, NULL, '2026-08-01', '2026-08-31 01:23:22'),
(190, 'saida', NULL, 'Salário Alda', 400.00, 'Pix', '1X', '', 'Pendente', '2026-08-30', '2026-08-01', NULL, NULL, NULL, NULL, '2026-08-30', '2026-08-31 01:23:36'),
(191, 'entrada', 6, 'Sheila', 50.00, 'Débito', '1X', '', 'Pago', '2026-08-31', '2026-08-01', NULL, NULL, NULL, NULL, '2026-08-30', '2026-08-31 01:25:08'),
(197, 'entrada', 14, 'Roupas Cassiana', 80.00, 'Pix', '1X', '', 'Pendente', '2026-09-02', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-08-31 22:17:04'),
(201, 'entrada', 13, 'Conserto Roupas', 100.00, 'Pix', '1X', '', 'Pendente', '2026-09-01', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-08-31 22:30:52'),
(202, 'entrada', 18, 'Conserto roupas', 100.00, 'Pix', '1X', '', 'Pago', '2026-09-01', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-01 16:58:22'),
(203, 'entrada', 24, 'Kit pijama 3 peças', 175.00, 'Pix', '1X', '', 'Pago', '2026-09-01', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-01 16:58:56'),
(206, 'entrada', 29, 'Barra vestido', 40.00, 'Cartão de Crédito', '1X', 'Mastercard', 'Pago', '2026-09-02', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-01 17:18:21'),
(207, 'entrada', 27, 'Cortina', 70.00, 'Pix', '1X', '', 'Pago', '2026-09-03', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-01 17:19:35'),
(208, 'entrada', 32, 'Barra e ajuste calça jeans', 40.00, 'Pix', '1X', '', 'Pago', '2026-09-03', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-01 17:22:44'),
(209, 'entrada', 30, 'ajuste 3 peças', 90.00, 'Cartão de Crédito', '1X', 'Mastercard', 'Pendente', '2026-10-04', '2026-10-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-01 17:40:09'),
(210, 'entrada', 34, 'ajuste roupas filha e 1 anagua', 95.00, 'Pix', '1X', '', 'Pago', '2026-09-03', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-01 17:40:40'),
(211, 'entrada', 26, 'consertos varias roupas', 165.00, 'Pix', '1X', '', 'Pendente', '2026-09-01', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-01 17:42:20'),
(212, 'entrada', 11, 'Ajustes calça e shorts', 70.00, 'Cartão de Crédito', '1X', 'Visa', 'Pendente', '2026-10-01', '2026-10-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-01 19:52:01'),
(213, 'entrada', 35, '4 calcinhas tamanho 10', 60.00, 'Pix', '1X', '', 'Pago', '2026-09-02', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-02', '2026-09-02 15:07:26'),
(214, 'entrada', 22, '5 calcinhas para Maria tamanho 16', 75.00, 'Pix', '1X', '', 'Pago', '2026-09-02', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-02', '2026-09-02 15:10:07'),
(215, 'entrada', 22, '1 calcinha para Valentina tamanho 14', 15.00, 'Pix', '1X', '', 'Pendente', '2026-09-02', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-02', '2026-09-02 15:10:53'),
(216, 'entrada', 12, '4 calças social', 350.00, 'Cartão de Crédito', '2X', 'Visa', 'Pago', '2026-09-06', '2026-09-01', NULL, 'b1b8e7fce4d9d427c44b81c6ad79d370', 1, 2, '2026-08-06', '2026-09-02 15:14:45'),
(217, 'entrada', 12, '4 calças social', 350.00, 'Cartão de Crédito', '2X', 'Visa', 'Pendente', '2026-10-06', '2026-10-01', NULL, 'b1b8e7fce4d9d427c44b81c6ad79d370', 2, 2, '2026-08-06', '2026-09-02 15:14:45'),
(218, 'entrada', 13, 'consertos varias roupas', 80.00, 'Pix', '1X', '', 'Pago', '2026-08-20', '2026-08-01', NULL, NULL, NULL, NULL, '2026-08-20', '2026-09-02 15:16:45'),
(219, 'saida', NULL, 'Dariane', 35.70, 'Débito', '1X', '', 'Pago', '2026-09-01', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-01', '2026-09-02 17:03:56'),
(220, 'entrada', 15, 'Barra bandeira', 20.00, 'Pix', '1X', '', 'Pago', '2026-09-02', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-02', '2026-09-03 12:36:53'),
(221, 'entrada', 20, 'Consertos diversos', 45.00, 'Pix', '1X', '', 'Pendente', '2026-09-03', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-03', '2026-09-03 19:54:04'),
(222, 'entrada', 36, 'consertos varias roupas', 185.00, 'Pix', '1X', '', 'Pago', '2026-09-04', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-03', '2026-09-03 19:55:46'),
(223, 'entrada', 37, 'Ajuste macacão', 20.00, 'Pix', '1X', '', 'Pendente', '2026-09-03', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-03', '2026-09-03 20:01:43'),
(224, 'entrada', 38, 'Ajuste saia', 15.00, 'Pix', '1X', '', 'Pago', '2026-09-03', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-03', '2026-09-04 11:15:22'),
(225, 'saida', NULL, 'Aluguel maquina de cartão', 39.00, 'Débito', '1X', '', 'Pago', '2026-09-03', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-03', '2026-09-04 16:30:32'),
(226, 'entrada', 33, 'Barra colete e ajuste calça', 45.00, 'Pix', '1X', '', 'Pago', '2026-09-04', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-04', '2026-09-04 16:33:14'),
(227, 'entrada', 39, 'Barra 2 calças e cortina', 75.00, 'Pix', '1X', '', 'Pago', '2026-09-04', '2026-09-01', NULL, NULL, NULL, NULL, '2026-09-04', '2026-09-04 18:37:02');

-- Atribui números de ordem de serviço aos lançamentos de entrada existentes.
DROP TEMPORARY TABLE IF EXISTS tmp_service_order_groups;
CREATE TEMPORARY TABLE tmp_service_order_groups (
  group_key VARCHAR(80) PRIMARY KEY,
  first_id BIGINT UNSIGNED NOT NULL,
  service_order_number INT UNSIGNED NULL
) ENGINE=Memory;

INSERT INTO tmp_service_order_groups (group_key, first_id)
SELECT
  CASE
    WHEN installment_group IS NULL OR installment_group = '' THEN CONCAT('single:', id)
    ELSE CONCAT('group:', installment_group)
  END AS group_key,
  MIN(id) AS first_id
FROM transactions
WHERE kind='entrada'
GROUP BY CASE
    WHEN installment_group IS NULL OR installment_group = '' THEN CONCAT('single:', id)
    ELSE CONCAT('group:', installment_group)
  END;

SET @service_order_seq = 0;
UPDATE tmp_service_order_groups
SET service_order_number = (@service_order_seq := @service_order_seq + 1)
ORDER BY first_id;

UPDATE transactions t
JOIN tmp_service_order_groups g ON g.group_key = CASE
    WHEN t.installment_group IS NULL OR t.installment_group = '' THEN CONCAT('single:', t.id)
    ELSE CONCAT('group:', t.installment_group)
  END
SET t.service_order_number = g.service_order_number
WHERE t.kind='entrada';

DROP TEMPORARY TABLE tmp_service_order_groups;

INSERT INTO users (`id`, `name`, `email`, `password_hash`, `active`, `created_at`) VALUES
(1, 'Administrador', 'admin@confi.local', '$2y$12$wIlTFdeEdi0ybz7QlFh1M.uXmtoCOpiSkDjGYiuba3jJyR1OPJVVW', 1, '2026-08-31 01:19:58'),
(2, 'Raquel Prada', 'contato@raquelprada.com', '$2y$12$vvTjGWkXPJQJFC6LuiCiBusso4sAGMChegPGNaV8nvqeVgZfKzu6S', 1, '2026-08-31 04:49:21');

ALTER TABLE clients AUTO_INCREMENT = 40;
ALTER TABLE recurrings AUTO_INCREMENT = 10;
ALTER TABLE transactions AUTO_INCREMENT = 231;
ALTER TABLE users AUTO_INCREMENT = 3;
