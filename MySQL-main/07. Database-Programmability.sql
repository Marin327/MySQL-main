-- 1. Count Employees by Town
DROP function IF EXISTS `ufn_count_employees_by_town`;
DELIMITER $$

CREATE FUNCTION `ufn_count_employees_by_town` (town_name VARCHAR(50))
RETURNS INTEGER
DETERMINISTIC
BEGIN
RETURN (SELECT COUNT(*)
	FROM employees as e
		JOIN addresses as a USING(address_id)
		JOIN towns as t USING (town_id)
	WHERE t.`name` = town_name);
END$$

DELIMITER ;

-- 2. Employees Promotion
USE `soft_uni`;
DROP procedure IF EXISTS `usp_raise_salaries`;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE usp_raise_salaries(department_name VARCHAR(50)) 
DETERMINISTIC
BEGIN
    UPDATE employees AS e 
	JOIN departments AS d
	USING(department_id)
	SET e.salary = e.salary * 1.05
	WHERE d.`name` = department_name;
END$$

DELIMITER ;

SELECT e.first_name, e.salary
 FROM employees AS e 
	JOIN departments AS d
	USING(department_id)
WHERE d.`name` = 'Finance'
ORDER BY e.first_name;

CALL usp_raise_salaries('Finance');

-- 3. Employees Promotion By ID
USE `soft_uni`;
DROP procedure IF EXISTS `usp_raise_salary_by_id`;

USE `soft_uni`;
DROP procedure IF EXISTS `soft_uni`.`usp_raise_salary_by_id`;
;

DELIMITER $$
USE `soft_uni`$$
CREATE PROCEDURE `usp_raise_salary_by_id`(id INT)
BEGIN
	IF (SELECT employee_id 
			FROM employees
            WHERE employee_id = id
            LIMIT 1) IS NOT NULL THEN 
		UPDATE employees
		SET salary = salary * 1.05
		WHERE employee_id = id;
    END IF;
END$$

DELIMITER ;
;

CALL usp_raise_salary_by_id(5);
CALL usp_raise_salary_by_id(0);

-- 4. Triggered
DROP TABLE IF EXISTS deleted_employees;
CREATE TABLE deleted_employees (
    employee_id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    middle_name VARCHAR(50),
    job_title VARCHAR(50),
    department_id INT,
    salary DECIMAL(19, 4 )
); 

DROP TRIGGER IF EXISTS `soft_uni`.`employees_AFTER_DELETE`;

DELIMITER $$
USE `soft_uni`$$
CREATE TRIGGER `deleted_employees` 
AFTER DELETE ON `employees` FOR EACH ROW
BEGIN
INSERT INTO deleted_employees(first_name, last_name, middle_name, job_title, department_id, salary)
		VALUES (OLD.first_name, OLD.last_name, OLD.middle_name, OLD.job_title, OLD.department_id, OLD.salary);
END$$
DELIMITER ;




