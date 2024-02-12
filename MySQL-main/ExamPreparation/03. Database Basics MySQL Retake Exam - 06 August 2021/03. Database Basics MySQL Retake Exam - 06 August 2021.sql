DROP DATABASE IF EXISTS sgd;
CREATE DATABASE sgd;
USE sgd;

-- 01. Table Design
CREATE TABLE addresses(
	id INT PRIMARY KEY AUTO_INCREMENT,
	`name` VARCHAR(50) NOT NULL
);

CREATE TABLE categories (
    id INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(10) NOT NULL
);

CREATE TABLE offices(
	id INT PRIMARY KEY AUTO_INCREMENT,
	workspace_capacity INT NOT NULL,
	website VARCHAR(50),
	address_id INT NOT NULL,
    CONSTRAINT fk_office_address
		FOREIGN KEY(address_id)
        REFERENCES addresses(id)
);

CREATE TABLE employees(
	id INT PRIMARY KEY AUTO_INCREMENT,
    first_name VARCHAR(30) NOT NULL,
	last_name VARCHAR(30) NOT NULL,
	age INT NOT NULL,
	salary DECIMAL(10,2) NOT NULL,
	job_title VARCHAR(20) NOT NULL,
	happiness_level CHAR(1) NOT NULL
);

CREATE TABLE teams(
	id INT PRIMARY KEY AUTO_INCREMENT,
	`name` VARCHAR(40) NOT NULL,
	office_id INT NOT NULL,
	leader_id INT UNIQUE,
    CONSTRAINT fk_team_office
		FOREIGN KEY(office_id)
        REFERENCES offices(id),
	CONSTRAINT fk_team_leader
		FOREIGN KEY(leader_id)
        REFERENCES employees(id)
);

CREATE TABLE games(
	id INT PRIMARY KEY AUTO_INCREMENT,
	`name` VARCHAR(50) NOT NULL UNIQUE,
	`description` TEXT,
	rating FLOAT NOT NULL DEFAULT 5.5,
	budget DECIMAL(10, 2) NOT NULL,
	release_date DATE,
	team_id INT,
    CONSTRAINT fk_game_team
		FOREIGN KEY(team_id)
        REFERENCES teams(id)
);

CREATE TABLE games_categories(
	game_id INT NOT NULL,
	category_id INT NOT NULL,
    PRIMARY KEY(game_id, category_id),
    CONSTRAINT fk_game_categories
		FOREIGN KEY (category_id)
        REFERENCES categories(id),
	CONSTRAINT fk_category_games
		FOREIGN KEY (game_id)
        REFERENCES games(id)
);

-- 02. Insert
INSERT INTO games(`name`, rating, budget, team_id)
	(
    SELECT REVERSE(SUBSTR(LOWER(`name`),2)) , id, leader_id * 1000, id
		FROM teams
        WHERE id BETWEEN 1 AND 9);
        
-- 03. Update
UPDATE employees AS e
        JOIN
    teams AS t ON t.leader_id = e.id 
SET 
    e.salary = e.salary + 1000
WHERE
    e.age < 40 AND e.salary <= 5000;
    
-- 04. Delete
DELETE g
FROM games AS g
    WHERE (SELECT COUNT(*) FROM games_categories WHERE game_id = g.id) = 0  
    AND g.release_date IS NULL;
    
-- 05. Employees
SELECT first_name, last_name, age,salary, happiness_level
FROM employees
ORDER BY salary, id;

-- 06. Addresses of the teams
SELECT 
	t.`name` AS team_name, 
    a.`name` AS address_name, 
    char_length(a.`name`) AS count_of_characters
FROM teams as t 
	JOIN offices AS o 
    ON t.office_id = o.id
    JOIN addresses AS a
    ON o.address_id = a.id
WHERE o.website IS NOT NULL
ORDER BY team_name, address_name;

-- 07. Categories Info
SELECT 
	c.`name`,	
    COUNT(g.id) AS games_count,	
	ROUND(AVG(g.budget), 2) AS avg_budget,
 	MAX(g.rating) AS max_rating
FROM categories as c
	LEFT JOIN games_categories as gc 
    ON c.id = gc.category_id
    LEFT JOIN games as g
	ON gc.game_id = g.id
GROUP BY(c.id)
HAVING max_rating >= 9.5
ORDER BY games_count DESC, c.`name`;

-- 08. Games of 2022
SELECT  
	g.`name`,
	g.release_date,
	CONCAT (LEFT(g.`description`, 10), "...") AS summary,
	CONCAT ('Q', QUARTER(g.release_date)) AS `quarter`,	
    t.`name` AS team_name
FROM games AS g
	JOIN teams AS t ON g.team_id = t.id
    WHERE YEAR(g.release_date) = 2022 
		AND MONTH(g.release_date) % 2 = 0
        AND g.`name` LIKE ('%2')
ORDER BY `quarter`;

-- 09. Full info for games
SELECT 
	g.`name`,
	IF (g.budget < 50000 , 'Normal budget', 'Insufficient budget') AS budget_level,
	t.`name` AS team_name,
	a.`name` AS address_name
FROM games AS g 
	JOIN teams as t
    ON g.team_id = t.id
    JOIN offices as o 
    ON t.office_id = o.id
    JOIN addresses as a 
    ON o.address_id = a.id
WHERE g.release_date IS NULL 
	AND (SELECT COUNT(game_id) FROM games_categories WHERE game_id = g.id) = 0
ORDER BY g.`name`;

-- 10. Find all basic information for a game
USE `sgd`;
DROP function IF EXISTS `udf_game_info_by_name`;

DELIMITER $$
USE `sgd`$$
CREATE FUNCTION udf_game_info_by_name(game_name VARCHAR (20))
RETURNS VARCHAR(250)
DETERMINISTIC
BEGIN
	RETURN (SELECT 
    CONCAT_WS(' ','The', g.`name`, 'is developed by a', t.`name`, 
    'in an office with an address', a.`name`)
    FROM games as g
		JOIN teams as t ON g.team_id = t.id
        JOIN offices as o ON t.office_id = o.id
        JOIN addresses as a ON o.address_id = a.id
	WHERE g.`name` = game_name
);
END$$

DELIMITER ;

SELECT udf_game_info_by_name('Bitwolf') AS info;
SELECT udf_game_info_by_name('Fix San') AS info;

-- 11. Update Budget of the Games
USE `sgd`;
DROP procedure IF EXISTS `udp_update_budget`;

DELIMITER $$
USE `sgd`$$
CREATE PROCEDURE udp_update_budget (min_game_rating FLOAT)
BEGIN
	UPDATE games AS g 
	SET g.budget = g.budget + 100000,
		g.release_date = DATE_ADD(g.release_date, INTERVAL 1 YEAR)
	WHERE g.release_date IS NOT NULL 
		AND g.rating > min_game_rating
		AND (SELECT COUNT(game_id) FROM games_categories WHERE game_id = g.id) = 0;
END$$

DELIMITER ;

CALL udp_update_budget (8);

