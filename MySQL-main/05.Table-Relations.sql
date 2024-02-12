-- 1. Mountains and Peaks
DROP TABLE IF EXISTS `peaks`;
DROP TABLE IF EXISTS `mountains`;
CREATE TABLE `mountains`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL);

CREATE TABLE `peaks`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
`mountain_id` INT,
CONSTRAINT `fk_peak_mointain`
	FOREIGN KEY (`mountain_id`)
    REFERENCES `mountains`(`id`));
    
-- 2. Trip Organization
SELECT 
	d.id AS driver_id,
	v.vehicle_type AS vehicle_type,
	CONCAT_WS(' ', d.first_name, d.last_name) AS driver_name
FROM campers AS d
	JOIN vehicles AS v
    ON d.id = v.driver_id;

-- 3. SoftUni Hiking
SELECT 
	r.starting_point AS route_starting_point,
	r.end_point AS route_ending_point,
	r.leader_id AS leader_id,
	CONCAT_WS(' ', c.first_name, c.last_name) AS leader_name
FROM routes as r
JOIN campers as c
	ON r.leader_id = c.id;
    
-- 4. Delete Mountains
DROP TABLE IF EXISTS `peaks`;
DROP TABLE IF EXISTS `mountains`;
CREATE TABLE `mountains`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL);

CREATE TABLE `peaks`(
`id` INT PRIMARY KEY AUTO_INCREMENT,
`name` VARCHAR(50) NOT NULL,
`mountain_id` INT,
CONSTRAINT `fk_peak_mointain`
	FOREIGN KEY (`mountain_id`)
    REFERENCES `mountains`(`id`)
    ON DELETE CASCADE);


-- 5.	 Project Management DB*
DROP DATABASE IF EXISTS management;
CREATE DATABASE management;
USE management;

CREATE TABLE `clients` (
    id INT PRIMARY KEY AUTO_INCREMENT,
    client_name VARCHAR(100)
);

CREATE TABLE `projects` (
	id INT PRIMARY KEY AUTO_INCREMENT,
    client_id INT,
    project_lead_id INT,
    CONSTRAINT fk_project_client
		FOREIGN KEY(client_id)
        REFERENCES clients(id)		
);

CREATE TABLE employees(
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30),
    last_name VARCHAR(30),
    project_id INT,
    CONSTRAINT fk_employee_project
		FOREIGN KEY(project_id)
        REFERENCES projects(id)
);

ALTER TABLE projects
ADD CONSTRAINT fk_project_project_lead
	FOREIGN KEY (project_lead_id)
    REFERENCES employees(id);


