-- 02. Insert
INSERT INTO addresses(address, town, country, user_id)
SELECT 
	username, 
	`password`, 
    ip, 
    age
FROM users
WHERE gender = 'M';

-- 03. Update
UPDATE addresses
SET country = (CASE 
	WHEN LEFT(country,1) = 'B' THEN 'Blocked'
	WHEN LEFT(country,1) = 'T' THEN 'Test'
	WHEN LEFT(country,1) = 'P' THEN 'In Progress'
    ELSE country
END);

-- 04. Delete
DELETE FROM addresses
WHERE id % 3 = 0;

-- 05. Users
SELECT username, gender, age
FROM users
ORDER BY age DESC, username;

-- 06. Extract 5 most commented photos
SELECT 
    p.id,
    p.`date`AS date_and_time,
    p.`description`,
    COUNT(c.id) AS commentsCount
FROM
    photos AS p
        JOIN
    comments AS c ON c.photo_id = p.id
GROUP BY p.id
ORDER BY commentsCount DESC, p.id
LIMIT 5;

-- 07. Lucky users
SELECT 
	CONCAT_WS(' ', u.id, u.username) AS id_username,
	u.email
FROM users as u
	WHERE u.id in (SELECT user_id FROM users_photos WHERE user_id = photo_id)
ORDER BY u.id;

-- 08. Count likes and comments
SELECT 
	p.id AS photo_id,
	(SELECT COUNT(*) FROM likes WHERE photo_id = p.id) AS likes_count,
	(SELECT COUNT(*) FROM comments WHERE photo_id = p.id) AS comments_count
FROM photos as p
ORDER BY likes_count DESC, comments_count DESC, p.id;

-- 09. The photo on the tenth day of the month
SELECT 
	CONCAT(LEFT(`description`, 30),'...') AS `summary`,
	`date`
FROM photos
WHERE DAY(`date`) = 10
ORDER BY `date` DESC;

-- 10. Get user’s photos count
USE `instd`;
DROP function IF EXISTS `udf_users_photos_count`;

DELIMITER $$
USE `instd`$$
CREATE FUNCTION udf_users_photos_count(username VARCHAR(30)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
RETURN (
	SELECT COUNT(*)
		FROM users_photos AS up
			JOIN users as u ON u.id = up.user_id
		WHERE u.username = username
);
END$$

DELIMITER ;

SELECT udf_users_photos_count('ssantryd') AS photosCount;


-- 11. Increase user age
USE `instd`;
DROP procedure IF EXISTS `udp_modify_user`;

DELIMITER $$
USE `instd`$$
CREATE PROCEDURE udp_modify_user (address VARCHAR(30), town VARCHAR(30)) 
BEGIN
	UPDATE users as u
		JOIN addresses as a ON a.user_id = u.id
    SET age = age + 10
    WHERE a.address = address AND a.town = town;
END$$

DELIMITER ;



