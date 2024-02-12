-- 1. Employees with Salary Above 35000
USE `soft_uni`;
DROP procedure IF EXISTS `usp_get_employees_salary_above_35000`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_get_employees_salary_above_35000` ()
BEGIN
	SELECT 
    first_name, last_name
	FROM
		employees
	WHERE
		salary > 35000
	ORDER BY first_name, last_name, employee_id;
END$$

DELIMITER ;

CALL usp_get_employees_salary_above_35000();

-- 02. Employees with Salary Above Number
-- usp_get_employees_salary_above 
USE `soft_uni`;
DROP procedure IF EXISTS `usp_get_employees_salary_above`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_get_employees_salary_above` (min_salary DECIMAL(16,4))
BEGIN
	SELECT 
    first_name, last_name
	FROM
		employees
	WHERE
		salary >= min_salary
	ORDER BY first_name, last_name, employee_id;
END$$

DELIMITER ;

CALL usp_get_employees_salary_above(45000);

-- 03. Town Names Starting With
-- usp_get_towns_starting_with 
USE `soft_uni`;
DROP procedure IF EXISTS `usp_get_towns_starting_with`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_get_towns_starting_with` (begining VARCHAR(50))
BEGIN
	SELECT `name`
	FROM towns
	WHERE LOWER(`name`) LIKE concat(LOWER(begining),'%')
	ORDER BY `name`;
END$$
DELIMITER ;

CALL usp_get_towns_starting_with('b');

-- 04. Employees from Town
-- usp_get_employees_from_town 
USE `soft_uni`;
DROP procedure IF EXISTS `usp_get_employees_from_town`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_get_employees_from_town` (town_name VARCHAR(50))
BEGIN
	SELECT 
    first_name, last_name
	FROM
		employees AS e
			JOIN
		addresses USING (address_id)
			JOIN
		towns AS t USING (town_id)
	WHERE
		t.`name` = town_name
	ORDER BY e.first_name , e.last_name , e.employee_id;
END$$

DELIMITER ;

CALL usp_get_employees_from_town('Sofia');

-- 05. Salary Level Function
USE `soft_uni`;
DROP function IF EXISTS `ufn_get_salary_level`;

DELIMITER $$
USE `soft_uni`$$
CREATE FUNCTION `ufn_get_salary_level` (salary DECIMAL(16, 2))
RETURNS VARCHAR(30)
DETERMINISTIC
BEGIN
	DECLARE result VARCHAR(30);
	IF salary < 30000 THEN 
		SET result := "Low";
	ELSEIF salary BETWEEN 30000 AND 50000 THEN 
		SET result := "Average";
    ELSE 
    SET result := "High";
    END IF;
    RETURN result;
END$$

DELIMITER ;

SELECT salary, ufn_get_salary_level(salary)
FROM employees
LIMIT 100;

-- 06. Employees by Salary Level
USE `soft_uni`;
DROP procedure IF EXISTS `usp_get_employees_by_salary_level`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_get_employees_by_salary_level` (salary_level VARCHAR(20))
BEGIN
	SELECT first_name, last_name 
FROM employees
WHERE 
	CASE
		WHEN LOWER(salary_level)='low' THEN salary < 30000
        WHEN LOWER(salary_level)='average' THEN salary BETWEEN 30000 AND 50000
        WHEN LOWER(salary_level)='high' THEN salary > 50000
    END
ORDER BY first_name DESC, last_name DESC;
END$$

DELIMITER ;

CALL usp_get_employees_by_salary_level('High');

-- 07. Define Function
USE `soft_uni`;
DROP function IF EXISTS `ufn_is_word_comprised`;

DELIMITER $$
USE `soft_uni`$$
CREATE FUNCTION ufn_is_word_comprised(set_of_letters varchar(50), word varchar(50))
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN REGEXP_LIKE(LOWER(word), CONCAT('^[', LOWER(set_of_letters), ']+$'));
END$$

DELIMITER ;

SELECT ufn_is_word_comprised('oistmiahf', 'nikaragua');

-- 08. Find Full Name

USE `soft_uni`;
DROP PROCEDURE IF EXISTS `usp_get_holders_full_name`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_get_holders_full_name` ()
BEGIN
	SELECT 
		CONCAT_WS(' ', first_name, last_name) AS full_name
	FROM
		account_holders
	ORDER BY full_name , id;
END$$

DELIMITER ;

-- 9. People with Balance Higher Than
USE `soft_uni`;
DROP procedure IF EXISTS `usp_get_holders_with_balance_higher_than`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_get_holders_with_balance_higher_than` (having_balance DECIMAL(16,4))
BEGIN
	SELECT first_name, last_name
	FROM account_holders AS ah JOIN accounts as a
		on ah.id = a.account_holder_id
	GROUP BY ah.id
	HAVING sum(a.balance) > having_balance;
END$$

DELIMITER ;

CALL usp_get_holders_with_balance_higher_than(7000);

-- 10. Future Value Function
-- ufn_calculate_future_value 
USE `soft_uni`;
DROP function IF EXISTS `ufn_calculate_future_value`;

DELIMITER $$
USE `soft_uni`$$
CREATE FUNCTION `ufn_calculate_future_value` (sum DECIMAL (19,4), yearly_interest_rate DOUBLE(19,4), number_of_year INT)
RETURNS DECIMAL(19,4)
DETERMINISTIC
BEGIN
	DECLARE future_value DECIMAL(19,4);
	SET future_value := sum * POWER((1+yearly_interest_rate), number_of_year);
	RETURN future_value;
END$$

DELIMITER ;

SELECT ufn_calculate_future_value(123.1200, 0.1, 5);

-- 11. Calculating Interest
USE `soft_uni`;
DROP procedure IF EXISTS `usp_calculate_future_value_for_account`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_calculate_future_value_for_account` (account_id INT, interest_rate DOUBLE(19,4))
BEGIN
	SELECT a.id AS account_id,
	   ah.first_name,
       ah.last_name,
       a.balance as current_balance,
       ufn_calculate_future_value(a.balance, interest_rate, 5) AS balance_in_5_years
	FROM accounts as a JOIN account_holders as ah
		ON a.account_holder_id = ah.id
	WHERE a.id = account_id;
END$$

DELIMITER ;

CALL usp_calculate_future_value_for_account(1, 0.1);

-- 12. Deposit Money
USE `soft_uni`;
DROP procedure IF EXISTS `usp_deposit_money`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE usp_deposit_money(account_id INT, money_amount DECIMAL(19,4)) 
BEGIN
	START TRANSACTION;
    IF NOT money_amount >= 0 
		THEN ROLLBACK;
    ELSE
		UPDATE accounts
		SET balance = balance + money_amount
        WHERE id = account_id;
        COMMIT;
    END IF;
END$$

DELIMITER ;

CALL usp_deposit_money(1, 10);
SELECT balance FROM accounts WHERE id = 1;

-- 13. Withdraw Money
USE `soft_uni`;
DROP procedure IF EXISTS `usp_withdraw_money`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE usp_withdraw_money(account_id INT, money_amount DECIMAL(19,4)) 
BEGIN
	START TRANSACTION;
    IF NOT money_amount >= 0 
		THEN ROLLBACK;
    ELSE
		UPDATE accounts
		SET balance = balance - money_amount
        WHERE id = account_id;
        IF 	(SELECT balance FROM accounts WHERE id = account_id) >= 0 THEN COMMIT;
		ELSE ROLLBACK;
        END IF;
    END IF;
END$$

DELIMITER ;

CALL usp_withdraw_money(1, 10);
SELECT balance FROM accounts WHERE id = 1;

-- 14. Money Transfer
USE `soft_uni`;
DROP procedure IF EXISTS `usp_transfer_money`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_transfer_money` (from_account_id INT, to_account_id INT, amount DEC(19,4)) 
BEGIN
	START TRANSACTION;
    IF amount > 0
		AND EXISTS(SELECT * FROM accounts WHERE id = from_account_id)
		AND EXISTS(SELECT * FROM accounts WHERE id = to_account_id) THEN
        	UPDATE accounts 
			SET balance = balance - amount
            WHERE id = from_account_id;
            
            UPDATE accounts 
			SET balance = balance + amount
            WHERE id = to_account_id;
            
			IF (SELECT balance FROM accounts WHERE id = from_account_id) < 0 THEN
				ROLLBACK;
			ELSE 
				COMMIT;
            END IF;
        ELSE
			ROLLBACK;
        END IF;
    
END$$

DELIMITER ;

-- 15. Log Accounts Trigger
DROP TABLE IF EXISTS `logs`;
CREATE TABLE `logs`(
log_id INT PRIMARY KEY AUTO_INCREMENT, 
account_id INT, 
old_sum DEC(19,4),
new_sum DEC(19,4));

DROP TRIGGER IF EXISTS `soft_uni`.`accounts_AFTER_UPDATE`;

DELIMITER $$
USE `soft_uni`$$
CREATE TRIGGER `accounts_AFTER_UPDATE` AFTER UPDATE ON `accounts` FOR EACH ROW
BEGIN
	INSERT INTO `logs`(account_id, old_sum, new_sum)
    VALUES (OLD.id, OLD.balance, NEW.balance);
END
$$
DELIMITER ;

CALL usp_deposit_money(1, 10);
CALL usp_withdraw_money(1, 10);
SELECT * FROM `logs`;

-- 16. Emails Trigger
DROP TABLE IF EXISTS notification_emails;
CREATE TABLE notification_emails(
	id INT PRIMARY KEY, 
    recipient INT, 
    `subject` VARCHAR(50), 
    body VARCHAR(150));
    
DROP TRIGGER IF EXISTS `soft_uni`.`accounts_AFTER_UPDATE`;

DELIMITER $$
USE `soft_uni`$$
CREATE TRIGGER `accounts_AFTER_UPDATE` AFTER INSERT ON `logs` FOR EACH ROW
BEGIN
	INSERT INTO `notification_emails`(recipient, `subject`, body)
    VALUES (NEW.id, 
			CONCAT('Balance change for account: ', NEW.id),
            CONCAT('On', DATE(CURRENT_TIMESTAMP), ' your balance was changed from ',  NEW.old_sum, ' to ', NEW.new_sum,'.'));
END
$$
DELIMITER ;

CALL usp_deposit_money(1, 10);
CALL usp_withdraw_money(1, 10);
SELECT * FROM notification_emails;    
    
    

