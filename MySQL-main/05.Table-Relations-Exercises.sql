-- 01. One-To-One Relationship
DROP DATABASE IF EXISTS homework;
CREATE DATABASE homework;
USE homework;

CREATE TABLE passports(
	passport_id INT PRIMARY KEY AUTO_INCREMENT,
	passport_number CHAR(8)
);

INSERT INTO passports
VALUES
(101, 'N34FG21B'),
(102, 'K65LO4R7'),
(103, 'ZE657QP2');

CREATE TABLE people(
	person_id INT PRIMARY KEY AUTO_INCREMENT,
	first_name VARCHAR(50) NOT NULL,
	salary DECIMAL(64, 2),
	passport_id INT UNIQUE,
	CONSTRAINT fk_people_passrot
		FOREIGN KEY (passport_id)
		REFERENCES passports(passport_id)
);

INSERT INTO people
VALUES
(1, 'Roberto', 43300.00, 102),
(2, 'Tom', 56100.00, 103),
(3, 'Yana',	60200.00, 101);

-- 02. One-To-Many Relationship
CREATE TABLE manufacturers(
	manufacturer_id INT PRIMARY KEY AUTO_INCREMENT,
	`name` VARCHAR(50),
	established_on DATE
);

CREATE TABLE models(
	model_id INT PRIMARY KEY AUTO_INCREMENT,
	`name` VARCHAR(50),
	manufacturer_id INT,
    CONSTRAINT fk_model_manufactorer
    FOREIGN KEY (manufacturer_id)
    REFERENCES manufacturers(manufacturer_id));
    
INSERT INTO manufacturers
VALUES
	(1, 'BMW', '1916/03/01'),
	(2, 'Tesla', '2003/01/01'),
	(3, 'Lada', '1966/05/01');

INSERT INTO models
VALUES
	(101, 'X1', 1),
	(102, 'i6', 1),
	(103, 'Model S', 2),
	(104, 'Model X', 2),
	(105, 'Model 3', 2),
	(106, 'Nova', 3);
    
-- 03. Many-To-Many Relationship
CREATE TABLE students(
	student_id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

CREATE TABLE exams(
	exam_id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

CREATE TABLE students_exams(
	student_id INT,
    exam_id INT,
    PRIMARY KEY(student_id, exam_id),
    CONSTRAINT fk_exams_student
		FOREIGN KEY (student_id)
        REFERENCES students(student_id),
    CONSTRAINT fk_studentс_exam
		FOREIGN KEY (exam_id)
        REFERENCES exams(exam_id)
);

INSERT INTO students(`name`)
VALUES
	('Mila'),
	('Toni'),
	('Ron');
    
INSERT INTO exams
VALUES
(101,'Spring MVC'),
(102, 'Neo4j'),
(103, 'Oracle 11g');

INSERT INTO students_exams
VALUES
	(1,	101),
	(1,	102),
	(2,	101),
	(3,	103),
	(2,	102),
	(2,	103);
    
-- 04. Self-Referencing
CREATE TABLE teachers(
	`teacher_id` INT PRIMARY KEY AUTO_INCREMENT,
	`name` VARCHAR(50),
	`manager_id` INT NULL
) AUTO_INCREMENT = 101;    

INSERT INTO teachers (`name`, manager_id)
VALUES
	('John', NULL),	
	('Maya', 106),
	('Silvia', 106),
	('Ted', 105),
	('Mark', 101),
	('Greta', 101);
    
ALTER TABLE teachers
ADD     CONSTRAINT fk_teacher_manager
		FOREIGN KEY(manager_id)
        REFERENCES teachers(teacher_id);

-- 05. Online Store Database
DROP DATABASE IF EXISTS online_store;
CREATE DATABASE online_store;
USE online_store;

CREATE TABLE cities(
	city_id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

CREATE TABLE customers(
	customer_id INT PRIMARY KEY AUTO_INCREMENT,
	`name` VARCHAR(50),
    birthday DATE,
    city_id INT,
    CONSTRAINT fk_customer_city
		FOREIGN KEY(city_id)
		REFERENCES cities(city_id)
);

CREATE TABLE orders(
	order_id INT PRIMARY KEY AUTO_INCREMENT,
    customer_id INT,
     CONSTRAINT fk_order_customer
		FOREIGN KEY (customer_id)
		REFERENCES customers(customer_id)
);

CREATE TABLE item_types(
	item_type_id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

CREATE TABLE items(
	item_id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50),
    item_type_id INT,
    CONSTRAINT fk_item_item_type
    FOREIGN KEY (item_type_id)
    REFERENCES item_types(item_type_id)
);

CREATE TABLE order_items(
	order_id INT,
	item_id INT,
    CONSTRAINT pk_orders_otems
    PRIMARY KEY(order_id, item_id),
     CONSTRAINT fk_orders_item
		FOREIGN KEY(order_id)
		REFERENCES orders(order_id),
	CONSTRAINT fk_items_order
		FOREIGN KEY(item_id)
		REFERENCES items(item_id)
);

-- 06. University Database
DROP DATABASE IF EXISTS university;
CREATE DATABASE university;
USE university;

CREATE TABLE subjects(
	subject_id INT PRIMARY KEY AUTO_INCREMENT,
    subject_name VARCHAR(50)
);

CREATE TABLE majors(
	major_id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(50)
);

CREATE TABLE students(
	student_id INT PRIMARY KEY AUTO_INCREMENT,
    student_number VARCHAR(12),
    student_name VARCHAR(50),
    major_id INT,
    CONSTRAINT fk_student_major
		FOREIGN KEY (major_id)
        REFERENCES majors(major_id)
);

CREATE TABLE payments (
	payment_id INT PRIMARY KEY AUTO_INCREMENT,
    payment_date DATE,
    payment_amount DECIMAL(8,2),
    student_id INT,
    CONSTRAINT fk_payment_student
		FOREIGN KEY (student_id)
        REFERENCES students(student_id)
);

CREATE TABLE agenda(
	student_id INT,
    subject_id INT,
    PRIMARY KEY(student_id, subject_id),
     CONSTRAINT fk_student_subjects
		FOREIGN KEY (subject_id)
        REFERENCES subjects(subject_id),
	CONSTRAINT fk_subject_students
		FOREIGN KEY (student_id)
        REFERENCES students(student_id)
);


-- 09. Peaks in Rila
USE geography;
SELECT 
    m.mountain_range AS mountain_range,
    p.peak_name AS peak_name,
    p.elevation AS peak_elevation
FROM
    mountains AS m
        JOIN
    peaks AS p ON p.mountain_id = m.id
WHERE
    m.mountain_range = 'Rila'
ORDER BY p.elevation DESC;






