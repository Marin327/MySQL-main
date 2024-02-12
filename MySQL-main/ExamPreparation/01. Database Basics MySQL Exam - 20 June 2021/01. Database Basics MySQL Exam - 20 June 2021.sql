-- 01. Table Design
DROP DATABASE IF EXISTS stc;
CREATE DATABASE stc;
USE stc;

DROP TABLE IF EXISTS addresses;
CREATE TABLE addresses(
	id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL
);

DROP TABLE IF EXISTS categories;
CREATE TABLE categories(
	id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(10) NOT NULL
);

DROP TABLE IF EXISTS clients;
CREATE TABLE clients(
	id INT PRIMARY KEY AUTO_INCREMENT,
    `full_name` VARCHAR(50) NOT NULL,
    `phone_number` VARCHAR(20) NOT NULL
);

DROP TABLE IF EXISTS drivers;
CREATE TABLE drivers(
	id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR (30) NOT NULL,
	last_name VARCHAR (30) NOT NULL,
	age INT NOT NULL,
	rating FLOAT DEFAULT 5.5
);

DROP TABLE IF EXISTS cars;
CREATE TABLE cars(
	id INT PRIMARY KEY AUTO_INCREMENT,
	make VARCHAR(20) NOT NULL, 
	model VARCHAR(20), 
	`year` INT DEFAULT 0 NOT NULL, 
	mileage INT DEFAULT 0, 
	`condition` CHAR(1)  NOT NULL,
	category_id INT,
    CONSTRAINT fk_car_category 
		FOREIGN KEY(category_id)
        REFERENCES categories(id));
        
DROP TABLE IF EXISTS courses;
CREATE TABLE courses(
	id INT PRIMARY KEY AUTO_INCREMENT,
	from_address_id INT NOT NULL,
	`start` DATETIME NOT NULL,
	bill DECIMAL(10, 2),
	car_id INT NOT NULL,
	client_id INT NOT NULL,
    CONSTRAINT fk_cours_address
		FOREIGN KEY(from_address_id)
        REFERENCES addresses(id),
	CONSTRAINT fk_cours_car
		FOREIGN KEY(car_id)
        REFERENCES cars(id),
	CONSTRAINT fk_cours_client
		FOREIGN KEY(client_id)
        REFERENCES clients(id)
);

DROP TABLE IF EXISTS cars_drivers;
CREATE TABLE cars_drivers(
	car_id INT NOT NULL,
	driver_id INT NOT NULL,
    CONSTRAINT pk_cars_drivers
    PRIMARY KEY (car_id, driver_id),
    CONSTRAINT fk_cars_drivers_car
		FOREIGN KEY(car_id)
        REFERENCES cars(id),
	CONSTRAINT fk_cars_drivers_driver
		FOREIGN KEY(driver_id)
        REFERENCES drivers(id)
);

-- 02. Insert
INSERT INTO clients(full_name, phone_number)
SELECT CONCAT_WS(' ', first_name, last_name) AS full_name, CONCAT('(088) 9999', id * 2) AS phone_number 
FROM drivers
WHERE id BETWEEN 10 and 20;

-- 03. Update
UPDATE cars
SET `condition` = 'C' 
WHERE (mileage >= 800000 OR mileage IS NULL OR `year` <= 2010 )
		AND make != 'Mercedes-Benz';

-- 04. Delete
DELETE FROM clients As c
WHERE char_length(c.full_name) > 3
	AND (SELECT COUNT(id) FROM courses WHERE client_id = c.id) = 0;
    
-- 05. Cars
SELECT make, model, `condition`
FROM cars
ORDER BY id;

-- 06. Drivers and Cars
SELECT d.first_name, d.last_name, c.make, c.model, c.mileage
FROM drivers AS d JOIN cars_drivers AS cd ON d.id = cd.driver_id
	JOIN cars as c ON cd.car_id = c.id
WHERE c.mileage IS NOT NULL
ORDER BY c.mileage DESC, d.first_name;

-- 07. Number of courses
SELECT 
	c.id as car_id,
	make,	
    mileage,
	COUNT(co.id) AS count_of_courses,
	ROUND(AVG(co.bill), 2)avg_bill
FROM cars AS c LEFT JOIN courses AS co ON c.id = co.car_id
GROUP BY c.id
HAVING count_of_courses != 2
ORDER BY count_of_courses DESC, c.id;

-- 08. Regular clients
SELECT 
    full_name,
    COUNT(co.car_id) AS count_of_cars,
    SUM(co.bill) total_sum
FROM
    clients AS c
        JOIN
    courses AS co ON c.id = client_id
WHERE
    SUBSTR(c.full_name, 2, 1) = 'a'
GROUP BY co.client_id
HAVING count_of_cars > 1
ORDER BY full_name;

-- 09. Full info for courses
SELECT a.`name`, TIME(c.`start`),
(CASE
    WHEN HOUR(c.`start`) BETWEEN 6 AND 20 THEN 'Day'
    ELSE 'Night'
END) AS `day_time`,
    c.`bill`,
    cl.`full_name`,
    ca.`make`,
    ca.`model`,
    cat.`name` AS `category_name`
FROM
    courses AS c 
    JOIN
    addresses AS a ON c.from_address_id = a.id
        JOIN
    clients AS cl ON c.client_id = cl.id
        JOIN
    cars AS ca ON c.car_id = ca.id
        JOIN
    categories AS cat ON ca.category_id = cat.id
ORDER BY c.id;
	
-- 10. Find all courses by client’s phone number
USE `stc`;
DROP function IF EXISTS `udf_courses_by_client`;

DELIMITER $$
USE `stc`$$
CREATE FUNCTION udf_courses_by_client (phone_num VARCHAR (20)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN(
		SELECT COUNT(c.id) 
		FROM courses as c 
		JOIN clients as cl ON c.client_id = cl.id
		WHERE cl.phone_number = phone_num);
END$$

DELIMITER ;

SELECT udf_courses_by_client ('(803) 6386812') as `count`; 

-- 11. Full info for address
USE `stc`;
DROP procedure IF EXISTS `udp_courses_by_address`;

DELIMITER $$
USE `stc`$$
CREATE PROCEDURE udp_courses_by_address (address VARCHAR(100))
BEGIN
	SELECT 
		a.`name`,
		c.full_name,
		(CASE
			WHEN co.bill <= 20 THEN 'Low'
			WHEN co.bill <= 30 THEN 'Medium'
			ELSE 'High'
		END) AS level_of_bill,
		car.make,
		car.`condition`,
		cat.`name` AS cat_name
	FROM
		courses AS co
			JOIN
		addresses AS a ON co.from_address_id = a.id
			JOIN
		clients AS c ON co.client_id = c.id
			JOIN
		cars AS car ON co.car_id = car.id
			JOIN
		categories AS cat ON car.category_id = cat.id
	WHERE
		a.`name` = address
	ORDER BY car.make , c.full_name;
END$$

DELIMITER ;

CALL udp_courses_by_address('700 Monterey Avenue');
CALL udp_courses_by_address('66 Thompson Drive');
