-- 05. Database Basics MySQL Exam - 9 Jun 2019
DROP DATABASE IF EXISTS ruk_database;
CREATE DATABASE ruk_database;
USE ruk_database;

-- 01. Table Design
CREATE TABLE branches(
	id INT PRIMARY KEY AUTO_INCREMENT,
	`name` VARCHAR(30) NOT NULL UNIQUE
);

CREATE TABLE employees(
	id INT PRIMARY KEY AUTO_INCREMENT,
	first_name  VARCHAR(20) NOT NULL,
	last_name VARCHAR(20) NOT NULL,
	salary DECIMAL(10,2) NOT NULL,
	started_on DATE NOT NULL,
	branch_id INT NOT NULL,
    CONSTRAINT fk_eployee_branch
		FOREIGN KEY(branch_id)
        REFERENCES branches(id)
);

CREATE TABLE clients(
	id INT PRIMARY KEY AUTO_INCREMENT,
	full_name VARCHAR(50) NOT NULL,
	age	INT NOT NULL
);

CREATE TABLE employees_clients(
	employee_id INT NOT NULL,
	client_id INT NOT NULL,
    CONSTRAINT fk_employee_clients
		FOREIGN KEY (client_id)
        REFERENCES clients(id),
	CONSTRAINT fk_client_employees
		FOREIGN KEY (employee_id)
        REFERENCES employees(id)
);

CREATE TABLE employees_clients_log(
	id INT PRIMARY KEY AUTO_INCREMENT,
	old_employee_id INT NOT NULL,
	old_client_id INT NOT NULL,
    new_employee_id INT NOT NULL,
	new_client_id INT NOT NULL
);

DROP TRIGGER IF EXISTS `ruk_database`.`employees_clients_AFTER_UPDATE`;

DELIMITER $$
USE `ruk_database`$$
CREATE DEFINER = CURRENT_USER TRIGGER `ruk_database`.`employees_clients_AFTER_UPDATE` AFTER UPDATE ON `employees_clients` FOR EACH ROW
BEGIN
	INSERT INTO employees_clients_log(old_employee_id, old_client_id, new_employee_id, new_client_id)
    VALUES (old.employee_id, old.client_id, new.employee_id, new.client_id);
END$$
DELIMITER ;

CREATE TABLE bank_accounts(
	id INT PRIMARY KEY AUTO_INCREMENT,
	account_number VARCHAR(10) NOT NULL,
	balance DECIMAL(10,2) NOT NULL,
	client_id INT UNIQUE,
     CONSTRAINT fk_bank_account_client
		FOREIGN KEY (client_id)
        REFERENCES clients(id)
);

CREATE TABLE cards(
	id INT PRIMARY KEY AUTO_INCREMENT,
    card_number  VARCHAR(19) NOT NULL,
	card_status  VARCHAR(7) NOT NULL,
	bank_account_id INT,
    CONSTRAINT fk_card_bank_account
		FOREIGN KEY(bank_account_id)
        REFERENCES bank_accounts(id)
);

-- 02. Insert
INSERT INTO cards (card_number,card_status,bank_account_id)
	SELECT reverse(full_name), 'Active', id
    FROM clients
    WHERE id BETWEEN 191 AND 200;

-- 03. Update
SET SQL_SAFE_UPDATES = 0;

UPDATE employees_clients
SET employee_id =
(SELECT * FROM (SELECT ec1.employee_id
		FROM employees_clients as ec1 
		GROUP BY ec1.employee_id
		ORDER BY COUNT(ec1.client_id), ec1.employee_id
        LIMIT 1) as s)
WHERE employee_id = client_id;

-- 04. Delete
DELETE FROM employees as e
WHERE (SELECT COUNT(ec.client_id) 
       FROM employees_clients as ec
       WHERE ec.employee_id = e.id) = 0;

-- 05. Clients
SELECT id, full_name
FROM clients
ORDER BY id;

-- 06. Newbies
SELECT  
	id,
	CONCAT_WS(' ', first_name, last_name) AS full_name,
	CONCAT('$',salary),
	started_on
FROM employees
WHERE salary >= 100000 AND started_on > '2018-01-01'
ORDER BY salary DESC, id;

-- 07. Cards against Humanity
SELECT 
	c.id,
	concat_ws(' : ', c.card_number, cl.full_name) AS card_token
FROM cards as c 
	JOIN bank_accounts as ba ON ba.id = c.bank_account_id
    JOIN clients as cl ON ba.client_id = cl.id
ORDER BY c.id DESC;

-- 08. Top 5 Employees
SELECT  
	CONCAT_WS(' ', e.first_name, e.last_name) AS `name`,
    e.started_on,
    COUNT(ec.client_id) AS count_of_clients
FROM employees as e 
	JOIN employees_clients as ec ON ec.employee_id = e.id
GROUP BY e.id
ORDER BY count_of_clients DESC, e.id
LIMIT 5;

-- 09. Branch cards
SELECT 
	b.`name`,
	COUNT(c.id) AS count_of_cards
FROM branches AS b
	LEFT JOIN employees AS e ON  e.branch_id = b.id
    LEFT JOIN employees_clients as ec ON ec.employee_id = e.id
    LEFT JOIN clients as cl on cl.id = ec.client_id
    LEFT JOIN bank_accounts as ba ON ba.client_id = cl.id
	LEFT JOIN cards as c ON c.bank_account_id = ba.id
GROUP BY b.`name`
ORDER BY count_of_cards DESC, b.`name`;

-- 10. Extract card's count
USE `ruk_database`;
DROP function IF EXISTS `udf_client_cards_count`;

DELIMITER $$
USE `ruk_database`$$
CREATE FUNCTION udf_client_cards_count(`name` VARCHAR(30)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(ca.id)
		FROM clients as c
			LEFT JOIN bank_accounts as ba ON ba.client_id = c.id
			LEFT JOIN cards as ca ON ca.bank_account_id = ba.id
		WHERE c.full_name = `name`);
END$$

DELIMITER ;

SELECT c.full_name, udf_client_cards_count('Baxy David') as `cards` FROM clients c
WHERE c.full_name = 'Baxy David';

-- 11. Client Info
USE `ruk_database`;
DROP procedure IF EXISTS `udp_clientinfo`;

DELIMITER $$
USE `ruk_database`$$
CREATE PROCEDURE udp_clientinfo(`name` VARCHAR(30))
BEGIN
	SELECT c.full_name, c.age, ba.account_number, CONCAT('$',ba.balance) AS balance
	FROM clients as c LEFT JOIN bank_accounts AS ba ON ba.client_id = c.id
	WHERE c.full_name = `name`;
END$$

DELIMITER ;

CALL udp_clientinfo('Hunter Wesgate');

