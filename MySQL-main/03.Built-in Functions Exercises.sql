-- 01. Find Names of All Employees by First Name
SELECT first_name, last_name
FROM employees
WHERE SUBSTR(first_name, 1,2) = 'Sa';

-- 02. Find Names of All Employees by Last Name
SELECT first_name, last_name
FROM employees
WHERE last_name LIKE '%ei%';

-- 03. Find First Names of All Employess
SELECT first_name
FROM employees
WHERE department_id IN(3,10)
	 AND YEAR(hire_date) BETWEEN 1995 AND 2005
ORDER BY employee_id;

-- 04. Find All Employees Except Engineers
SELECT first_name, last_name
FROM employees
WHERE job_title NOT LIKE '%engineer%'
ORDER BY employee_id;

-- 05. Find Towns with Name Length
SELECT `name`
FROM towns
WHERE char_length(`name`) IN (5,6)
ORDER BY `name`;

-- 06. Find Towns Starting With
SELECT town_id,	`name`
FROM towns
WHERE SUBSTR(LOWER(`name`),1,1) IN ('m','k','b','e')
ORDER BY `name`;

-- 07. Find Towns Not Starting With
SELECT town_id,	`name`
FROM towns
WHERE SUBSTR(LOWER(`name`),1,1) NOT IN ('r','b','d')
ORDER BY `name`;

-- 08. Create View Employees Hired After
CREATE VIEW v_employees_hired_after_2000 AS
SELECT first_name, last_name
FROM employees
WHERE YEAR(hire_date) > 2000;

SELECT * 
FROM v_employees_hired_after_2000;

-- 09. Length of Last Name
SELECT first_name, last_name
FROM employees
WHERE CHAR_LENGTH(`last_name`) = 5 
ORDER BY employee_id;

-- 10. Countries Holding 'A'
SELECT country_name, iso_code
FROM countries
WHERE LENGTH(country_name) - LENGTH(REPLACE(LOWER(country_name), 'a', '')) >= 3
ORDER BY iso_code;

-- 11. Mix of Peak and River Names
SELECT 
    peak_name,
    river_name,
    LOWER(CONCAT(peak_name, SUBSTR(river_name, 2))) AS mix
FROM
    peaks,
    rivers
WHERE
    RIGHT(peak_name, 1) = LEFT(river_name, 1)
ORDER BY mix;

-- 12. Games From 2011 and 2012 Year
SELECT 
    `name`, DATE_FORMAT(`start`, '%Y-%m-%d') AS start
FROM
    games
WHERE
    YEAR(`start`) BETWEEN 2011 AND 2012
ORDER BY `start` , `name`
LIMIT 50;

-- 13. User Email Providers
SELECT user_name, SUBSTRING_INDEX(`email`, '@', -1) AS `Email Provider`
FROM users
ORDER BY `Email Provider`, user_name;

-- 14. Get Users with IP Address Like Pattern
SELECT user_name, ip_address
FROM users
WHERE ip_address LIKE '___.1%.%.___'
ORDER BY user_name;

-- 15. Show All Games with Duration
SELECT 
    `name` AS game,
    IF(HOUR(`start`) >= 0
            AND HOUR(`start`) < 12,
        'Morning',
        IF(HOUR(`start`) >= 12
                AND HOUR(`start`) < 18,
            'Afternoon',
            'Evening')) AS `Part of the Day`,
	IF(duration <=3, 'Extra Short',
		IF(duration > 3 AND duration <=6, 'Short',
			IF(duration > 6 AND duration <=10,'Long',
				'Extra Long'))) AS `Duration`
FROM
    games; 
    
    -- v2
    SELECT 
    `name` AS game,
    (CASE 
		WHEN HOUR(`start`) BETWEEN 0 AND 11 THEN 'Morning'
		WHEN HOUR(`start`) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evaning'
	END) AS `Part of the Day`,
    (CASE 
		WHEN `duration` < 4 'Extra Short'
		WHEN `duration` < 7 'Short'
		WHEN `duration` < 11 THEN 'Long'
		ELSE 'Extra Long'
    END) AS `Duration`
FROM
    games; 
    
-- 16. Orders Table
SELECT product_name, 
	   order_date, 
	   ADDDATE(order_date, INTERVAL 3 DAY) AS pay_due,	
       ADDDATE(`order_date`, INTERVAL 1 MONTH) AS deliver_due
FROM orders