DROP DATABASE IF EXISTS `minions`;
CREATE DATABASE `minions`;
USE `minions`;
-- 01. Create Tables
CREATE TABLE `minions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL,
    `age` INT
);

CREATE TABLE `towns` (
    `town_id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

-- 02. Alter Minions Table
ALTER TABLE `towns` RENAME COLUMN `town_id` TO `id`;
ALTER TABLE `minions` ADD COLUMN `town_id` INT NOT NULL,
					  ADD FOREIGN KEY (`town_id`) 
						  REFERENCES `towns`(`id`);
                          
-- 03. Insert Records in Both Tables
INSERT INTO `towns`(`id`,`name`)
VALUES(1, 'Sofia'),
	  (2, 'Plovdiv'),
	  (3, 'Varna');
      
INSERT INTO `minions`(`id`, `name`, `age`, `town_id`)
VALUES(1, 'Kevin',	22,	1),
	  (2, 'Bob', 15, 3),
	  (3, 'Steward', NULL,	2);
      
-- 04. Truncate Table Minions
TRUNCATE TABLE `minions`;

-- 05. Drop All Tables
DROP TABLE `minions`;
DROP TABLE `towns`;

-- 06. Create Table People
CREATE TABLE `people`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(200) NOT NULL,
`picture` BLOB,
`height` DECIMAL(65, 2),
`weight` DECIMAL(65, 2),
`gender` CHAR(1) NOT NULL,
`birthdate` DATETIME not null,
`biography` TEXT);

INSERT INTO `people`(`name`, `picture`, `height`, `weight`, `gender`, `birthdate`, `biography`)
VALUES
	('Pesho', NULL, 1.85, 100, 'm', '1977-02-01 10:11:12',''),
	('Pesho', NULL, 1.85, 100, 'm', '1977-02-01 10:11:12',''),
	('Pesho', NULL, 1.85, 100, 'm', '1977-02-01 10:11:12',''),
	('Pesho', NULL, 1.85, 100, 'm', '1977-02-01 10:11:12',''),
	('Pesho', NULL, 1.85, 100, 'm', '1977-02-01 10:11:12','');
    
-- 07. Create Table Users
DROP TABLE IF EXISTS `users`;

CREATE TABLE `users`(
	`id` INT PRIMARY KEY AUTO_INCREMENT,
	`username` VARCHAR(30) NOT NULL,
	`password` VARCHAR(26) NOT NULL,
	`profile_picture` BLOB,
	`last_login_time` DATETIME,
    `is_deleted` BOOLEAN
);

INSERT INTO `users`(`username`, `password`, `last_login_time`, `is_deleted`)
VALUES
	('pesho1', 'test', NULL, TRUE),
	('pesho2', 'test', NULL, FALSE),
	('pesho3', 'test', '2022-01-11 14:19', FALSE),
	('pesho4', 'test', NULL, FALSE),
	('pesho5', 'test', NULL, TRUE);

-- 08. Change Primary Key
ALTER TABLE `users` DROP PRIMARY KEY,
					ADD PRIMARY KEY(`id`, `username`);
                    
-- 9. Set Default Value of a Field
ALTER TABLE `users` 
CHANGE COLUMN `last_login_time` `last_login_time` DATETIME DEFAULT NOW();

-- 10. Set Unique Field
ALTER TABLE `users` DROP PRIMARY KEY,
					ADD PRIMARY KEY(`id`),
                    ADD UNIQUE(`username`);
                    
-- 11. Movies Database
DROP DATABASE IF EXISTS `movies`;
CREATE DATABASE `movies`;
USE `movies`;

DROP TABLE IF EXISTS `directors`, `genres`, `categories`, `movies`;
CREATE TABLE `directors` (
	`id` INT PRIMARY KEY AUTO_INCREMENT, 
	`director_name` VARCHAR(50) NOT NULL, 
	`notes` TEXT);
    
CREATE TABLE `genres` (
	`id` INT PRIMARY KEY AUTO_INCREMENT, 
	`genre_name` VARCHAR(50) NOT NULL, 
	`notes` TEXT);

CREATE TABLE `categories` (
	`id`INT PRIMARY KEY AUTO_INCREMENT, 
    `category_name` VARCHAR(50) NOT NULL, 
    `notes` TEXT); 
    
CREATE TABLE `movies` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`title` VARCHAR(200) NOT NULL, 
`director_id` INT NOT NULL, 
`copyright_year` INT NOT NULL, 
`length` INT NOT NULL, 
`genre_id` INT NOT NULL, 
`category_id` INT NOT NULL, 
`rating` DECIMAL(2,1) UNSIGNED NOT NULL, 
`notes` TEXT);
    
INSERT INTO `directors`(`director_name`)
    VALUES ('George Lucas'),
		   ('Nikita Mihalkov'), 
		   ('Quentin Tarantino'), 
		   ('Steven Spielberg'), 
		   ('Martin Scorsese');
           
INSERT INTO `genres`(`genre_name`)
    VALUES ('Si-Fi'),
		   ('Drama'), 
		   ('Action'), 
		   ('Crime'), 
		   ('Biography');

           
INSERT INTO `categories`(`category_name`)
    VALUES ('Movie'),
		   ('Series'), 
		   ('Animation'), 
		   ('B&W'), 
		   ('Other');
           
INSERT INTO `movies`(`title`, `director_id`, `copyright_year`, `length`, `genre_id`, `category_id`, `rating`)
VALUES
	('Star Wars: Episode IV - A New Hope', 1, 1977, 121, 1, 1, 8.6),
	('Burnt by the Sun', 2, 1994, 135, 2, 1, 7.9),
	('Pulp Fiction', 3, 1994, 154, 3, 1, 8.6),
	('West Side Story', 4, 2021, 156, 4, 5, 8.6),
	('Taxi Driver', 5, 1976, 114, 1, 1, 8.2);
    
-- 12. Car Rental Database
/*
•	categories (id, category, daily_rate, weekly_rate, monthly_rate, weekend_rate)
•	cars (id, plate_number, make, model, car_year, category_id, doors, picture, car_condition, available)
•	employees (id, first_name, last_name, title, notes)
•	customers (id, driver_licence_number, full_name, address, city, zip_code, notes)
•	rental_orders (id, employee_id, customer_id, car_id, car_condition, tank_level, kilometrage_start, kilometrage_end, total_kilometrage, start_date, end_date, total_days, rate_applied, tax_rate, order_status, notes)

*/

DROP DATABASE IF EXISTS `car_rental`;
CREATE DATABASE `car_rental`;
USE `car_rental`;

CREATE TABLE `categories` (
	`id` INT PRIMARY KEY AUTO_INCREMENT, 
    `category` VARCHAR(50) NOT NULL, 
    `daily_rate` DECIMAL(65, 2), 
    `weekly_rate` DECIMAL(65, 2), 
    `monthly_rate` DECIMAL(65, 2), 
    `weekend_rate` DECIMAL(65, 2));

CREATE TABLE `cars` (
	`id` INT PRIMARY KEY AUTO_INCREMENT, 
    `plate_number` VARCHAR(10) NOT NULL, 
    `make` VARCHAR(50) NOT NULL, 
    `model`VARCHAR(50) NOT NULL, 
    `car_year` SMALLINT, 
    `category_id` INT NOT NULL, 
    `doors` TINYINT, 
    `picture` BLOB, 
    `car_condition` VARCHAR(50) NOT NULL, 
    `available` BOOLEAN NOT NULL
);
CREATE TABLE employees (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`first_name` VARCHAR(50) NOT NULL, 
`last_name` VARCHAR(50) NOT NULL, 
`title` VARCHAR(50) NOT NULL, 
`notes` TEXT);

CREATE TABLE `customers` (
`id` INT PRIMARY KEY AUTO_INCREMENT, 
`driver_licence_number` CHAR(10), 
`full_name` VARCHAR(100) NOT NULL, 
`address` VARCHAR(200) NOT NULL, 
`city` VARCHAR(50) NOT NULL, 
`zip_code` CHAR(4), 
`notes` TEXT);

CREATE TABLE `rental_orders` (
	`id` INT PRIMARY KEY AUTO_INCREMENT,
    `employee_id` INT NOT NULL, 
    `customer_id` INT NOT NULL, 
    `car_id` INT NOT NULL, 
    `car_condition` VARCHAR(50) NOT NULL, 
    `tank_level` ENUM ('FULL', 'HALF', 'EMPTY'), 
    `kilometrage_start` INT NOT NULL, 
    `kilometrage_end` INT NOT NULL, 
    `total_kilometrage` INT NOT NULL, 
    `start_date` DATE, 
    `end_date` DATE, 
    `total_days` INT, 
    `rate_applied` DECIMAL(65, 2), 
    `tax_rate` DECIMAL(65, 2), 
    `order_status` ENUM ('ORDERED', 'FULFILLED'), 
    `notes` TEXT);
    
    INSERT INTO `categories` (`category`, `daily_rate`, `weekly_rate`, `monthly_rate`, `weekend_rate`)
    VALUES
		('Econo', 20, 200, 2000, 40),
        ('Family', 22, 220, 2200, 45),
        ('Lux', 24, 240, 2400, 50);
        
	INSERT INTO `cars` (`plate_number`, `make`, `model`, `car_year`, `category_id`, `doors`, `car_condition`, `available`)
    VALUES 
		('A1020AB', 'Ford', 'Fiesta', 2010, 1, 2, 'Perfect', TRUE),
		('A1021AB', 'Ford', 'Mondeo', 2015, 2, 4, 'Good', TRUE),
		('A1022AB', 'Ford', 'MUSTANG', 1968, 1, 2, 'Perfect', TRUE);
        
    INSERT INTO `employees` (`first_name`, `last_name`, `title`)
		VALUES
			('Pesho', 'Peshev', 'Dealer'),
			('Gosho', 'Goshev', 'Dealer'),
			('Ivan', 'Ivanov', 'Manager');
            
	INSERT INTO `customers` (`driver_licence_number`, `full_name`, `address`, `city`, `zip_code`)
		VALUES
			('1234567890', 'Ali Mehmed', 'Busmantsi', 'Pernik', '1200'),
			('6234567890', 'Gosho', 'Pochivka', 'Varna', '5000'),
			('5234567890', 'Pesho Adidasa', 'Meden Rudnik', 'Burgas', '8000');
            
	INSERT INTO `rental_orders` 
    (`employee_id`, `customer_id`, `car_id`, `car_condition`, `tank_level`, `kilometrage_start`, `kilometrage_end`, `total_kilometrage`, 
    `start_date`, `end_date`, `total_days`, `rate_applied`, `tax_rate`, `order_status`)
		VALUES
			(1,1,1,'Perfect', 'FULL', 1000, 2000, 12345678, '2022-01-01', '2022-01-02', 1, 20, 20, 'FULFILLED'),
			(1,2,2,'Perfect', 'HALF', 1000, 2000, 12345678, '2022-01-01', '2022-01-10', 10, 240, 350,'FULFILLED'),
			(2,3,3,'Perfect', 'FULL', 1000, 2000, 12345678, '2022-01-11', '2022-01-14', 4, 20, 80,'ORDERED');
            
-- 13. Basic Insert
DROP DATABASE IF EXISTS `soft_uni`;
CREATE DATABASE `soft_uni`;
USE `soft_uni`;

CREATE TABLE `towns` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);
    
CREATE TABLE `addresses` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `address_text` VARCHAR(255),
    `town_id` INT NOT NULL,
    FOREIGN KEY (`town_id`)
        REFERENCES `towns` (`id`)
        ON DELETE RESTRICT
);

CREATE TABLE `departments` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50) NOT NULL
);

CREATE TABLE `employees` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `first_name` VARCHAR(50) NOT NULL,
    `middle_name` VARCHAR(50),
    `last_name` VARCHAR(50) NOT NULL,
    `job_title` VARCHAR(50) NOT NULL,
    `department_id` INT,
    `hire_date` DATE,
    `salary` DECIMAL(65 , 2 ),
    `address_id` INT,
    FOREIGN KEY (`department_id`)
        REFERENCES `departments` (`id`),
	FOREIGN KEY (`address_id`)
        REFERENCES `addresses` (`id`)
);

INSERT INTO `towns`(`name`)
VALUES
	('Sofia'), 
    ('Plovdiv'), 
    ('Varna'), 
    ('Burgas');
    
INSERT INTO `departments`(`name`)
	VALUES
		('Engineering'), -- 1
        ('Sales'), -- 2
        ('Marketing'), -- 3
        ('Software Development'), -- 4 
        ('Quality Assurance'); -- 5

INSERT INTO `employees` (`first_name`, `middle_name`, `last_name`, `job_title`, `department_id`, `hire_date`, `salary`)
VALUES
	('Ivan', 'Ivanov', 'Ivanov', '.NET Developer', 4, '2013/02/01', 3500.00),        
	('Petar', 'Petrov', 'Petrov', 'Senior Engineer', 1, '2004/03/02', 4000.00),        
	('Maria', 'Petrova', 'Ivanova',	'Intern', 5, '2016/08/28', 525.25),        
	('Georgi', 'Terziev', 'Ivanov',	'CEO', 2, '2007/12/09',	3000.00),        
	('Peter', 'Pan', 'Pan',	'Intern', 3, '2016/08/28',599.88);
        
-- 14. Basic Select All Fields
SELECT *
FROM `towns`;

SELECT *
FROM `departments`;

SELECT *
FROM `employees`;
    
-- 15. Basic Select All Fields and Order Them

SELECT *
FROM `towns`
ORDER BY `name`;

SELECT *
FROM `departments`
ORDER BY `name`;

SELECT *
FROM `employees`
ORDER BY `salary` DESC;

-- 16. Basic Select Some Fields
SELECT `name`
FROM `towns`
ORDER BY `name`;

SELECT `name`
FROM `departments`
ORDER BY `name`;

SELECT `first_name`, `last_name`, `job_title`, `salary`
FROM `employees`
ORDER BY `salary` DESC;

-- 17. Increase Employees Salary
UPDATE `employees` 
SET 
    `salary` = `salary` * 1.1
WHERE
    id > 0;
SELECT 
    `salary`
FROM
    `employees`;

-- 18. Delete All Records
TRUNCATE TABLE `occupancies`;
    