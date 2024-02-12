--
DROP DATABASE IF EXISTS softuni_stores_system;
CREATE DATABASE softuni_stores_system;
USE softuni_stores_system;

-- 01. Table Design
CREATE TABLE pictures(
	id INT PRIMARY KEY AUTO_INCREMENT,
	url VARCHAR(100) NOT NULL,
	added_on DATETIME NOT NULL
);

CREATE TABLE categories(
	id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(40) NOT NULL UNIQUE
);

CREATE TABLE products(
	id INT PRIMARY KEY AUTO_INCREMENT,
	`name` VARCHAR(40) NOT NULL UNIQUE,
	best_before DATE,
	price DECIMAL(10,2) NOT NULL,
	`description` TEXT,
	category_id INT NOT NULL,
	picture_id INT NOT NULL,
    CONSTRAINT fk_product_category
		FOREIGN KEY(category_id)
        REFERENCES categories(id),
	CONSTRAINT fk_product_picture
		FOREIGN KEY(picture_id)
			REFERENCES pictures(id)
);

CREATE TABLE towns(
	id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(20) NOT NULL UNIQUE
);

CREATE TABLE addresses(
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL UNIQUE,
    town_id INT,
    CONSTRAINT fk_adderss_town
		FOREIGN KEY (town_id)
        REFERENCES towns(id)
);

CREATE TABLE stores(
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(20) NOT NULL UNIQUE,
    rating FLOAT NOT NULL,
	has_parking BOOL DEFAULT FALSE,
    address_id INT NOT NULL,
    CONSTRAINT fk_store_address
		FOREIGN KEY (address_id)
        REFERENCES addresses(id)
);

CREATE TABLE products_stores(
	product_id INT NOT NULL,
    store_id INT NOT NULL,
    PRIMARY KEY(product_id, store_id),
    CONSTRAINT fk_product_stores
			FOREIGN KEY(store_id)
			REFERENCES stores(id),
   CONSTRAINT fk_store_products
			FOREIGN KEY(product_id)
			REFERENCES products(id)
);

CREATE TABLE employees(
	id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(15) NOT NULL,
	middle_name CHAR(1),
	last_name VARCHAR(20) NOT NULL,
	salary DECIMAL (19, 2) DEFAULT 0,
	hire_date DATE NOT NULL,
	manager_id INT,
	store_id INT NOT NULL,
    CONSTRAINT fk_employee_manager
		FOREIGN KEY(manager_id)
        REFERENCES employees(id),
	CONSTRAINT fk_employee_store
		FOREIGN KEY(store_id)
        REFERENCES stores(id)
);

-- 02. Insert
INSERT INTO products_stores(product_id, store_id)
(SELECT p.id, 1
FROM products as p LEFT JOIN products_stores as ps
	ON p.id = ps.product_id
    WHERE ps.product_id IS NULL);
    
-- 03. Update
UPDATE employees AS e
JOIN stores AS s ON e.store_id = s.id
SET manager_id = 3,
	salary = salary - 500
WHERE YEAR(e.hire_date) > 2003 AND s.name NOT IN ('Cardguard','Veribet');

-- 04. Delete
DELETE FROM employees
WHERE manager_id IS NOT NULL AND salary >= 6000;

-- 05. Employees
SELECT first_name, middle_name,	last_name, salary, hire_date
FROM employees
ORDER BY hire_date DESC;

-- 06. Products with old pictures
SELECT 
	p.`name`, 
	p.price, 
    p.best_before,
    CONCAT(LEFT(p.`description`, 10) , '...') AS short_description,
    url
FROM products AS p JOIN pictures AS pi ON p.picture_id = pi.id
WHERE CHAR_LENGTH(p.`description`) > 100 
	AND YEAR(pi.added_on) < 2019 
    AND p.price > 20
ORDER BY p.price DESC;

-- 07. Counts of products in stores
SELECT 
 s.`name`, 
	COUNT(p.id) AS product_count, 
    ROUND(AVG(p.price), 2) AS `avg`
FROM stores AS s 
	LEFT JOIN products_stores AS ps ON s.id = ps.store_id
    LEFT JOIN products AS p ON ps.product_id = p.id
GROUP BY s.`name` 
ORDER BY product_count DESC, `avg` DESC, s.id;

-- 08. Specific employee
SELECT 
CONCAT_WS(' ', e.first_name, e.last_name) AS `Full_name`,
		s.`name` AS `Store_name`,
        a.`name` AS `address`,
        e.salary
FROM employees as e JOIN stores as s ON e.store_id = s.id
	JOIN addresses AS a ON s.address_id = a.id
WHERE e.salary < 4000
	AND a.`name` LIKE('%5%')
    AND CHAR_LENGTH(s.`name`) > 8
    AND e.last_name LIKE ('%n');
    
-- 09. Find all information of stores
SELECT REVERSE(s.`name`) AS reversed_name,
	   CONCAT_WS('-', UPPER(t.`name`), a.`name`) AS full_address,
	   COUNT(e.id) AS employees_count
FROM stores AS s
	JOIN addresses AS a ON s.address_id = a.id
    JOIN towns AS t ON a.town_id = t.id
    JOIN employees AS e ON e.store_id = s.id
GROUP BY s.id
HAVING employees_count >= 1
ORDER BY full_address;

-- 10. Find name of top paid employee by store name
-- udf_top_paid_employee_by_store(store_name VARCHAR(50))
USE `softuni_stores_system`;
DROP function IF EXISTS `udf_top_paid_employee_by_store`;

DELIMITER $$
USE `softuni_stores_system`$$
CREATE FUNCTION udf_top_paid_employee_by_store(store_name VARCHAR(50))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
RETURN(	SELECT 
	CONCAT_WS(' ', 
		e.first_name, 
        CONCAT(e.middle_name,'.'), 
        e.last_name, 
        'works in store for', 
        TIMESTAMPDIFF(YEAR, e.hire_date, '2020-10-18'),
        'years') AS full_info
FROM employees as e JOIN stores as s ON e.store_id = s.id
WHERE s.`name` = store_name AND
	  e.salary = (SELECT MAX(salary)
					FROM employees 
                    WHERE store_id = e.store_id));
END$$

DELIMITER ;

SELECT udf_top_paid_employee_by_store('Keylex') as 'full_info';

-- 11. Update product price by address
USE `softuni_stores_system`;
DROP procedure IF EXISTS `udp_update_product_price`;

DELIMITER $$
USE `softuni_stores_system`$$
CREATE PROCEDURE udp_update_product_price (address_name VARCHAR (50))
BEGIN
	DECLARE increase DEC;
    IF LEFT(address_name, 1) = '0' THEN  SET increase := 100.0; 
    ELSE SET increase := 200.0;
    END IF;
    
	UPDATE products as p
			JOIN products_stores as ps ON p.id = ps.product_id
			JOIN stores as s ON ps.store_id = s.id
			JOIN addresses as a ON s.address_id = a.id
    SET price = price + increase
	WHERE a.`name` = address_name;
END$$

DELIMITER ;

CALL udp_update_product_price('07 Armistice Parkway');
SELECT name, price FROM products WHERE id = 15;

CALL udp_update_product_price('1 Cody Pass');
SELECT name, price FROM products WHERE id = 17;
