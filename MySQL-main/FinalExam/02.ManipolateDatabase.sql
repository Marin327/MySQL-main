-- MySQL Final Exam 13.02.2022
USE final_exam;

-- 02. Insert
INSERT INTO reviews(content, picture_url, published_at, rating)
SELECT
	LEFT(`description`, 15) as content,
	REVERSE(`name`)	AS picture_url,
    '2010-10-10' AS published_at,
    CAST((price / 8) AS DECIMAL(12,2)) AS rating
FROM products
WHERE id >= 5;

-- 03. Update
UPDATE products
SET quantity_in_stock = quantity_in_stock - 5
WHERE quantity_in_stock BETWEEN 60 AND 70;

-- 04. Delete
DELETE FROM customers
WHERE id NOT IN (
	SELECT DISTINCT customer_id FROM orders
);

-- 05. Categories
SELECT
	id,	
    `name`
FROM categories
ORDER BY `name` DESC;

-- 06. Quantity
SELECT 
	id, 
	brand_id, 
	`name`, 
	quantity_in_stock
FROM products
WHERE price > 1000 AND quantity_in_stock < 30
ORDER BY quantity_in_stock, id;

-- 07. Review
SELECT id, content, rating, picture_url, published_at
FROM reviews
WHERE content LIKE 'My%' AND CHAR_LENGTH(content) > 61
ORDER BY rating DESC;

-- 08.First customers
SELECT 
	CONCAT_WS(' ', c.first_name, c.last_name) AS full_name, 
    c.address, 
    o.order_datetime AS order_date
FROM customers as c
	JOIN orders as o ON o.customer_id = c.id
WHERE YEAR(order_datetime) <= 2018
ORDER BY full_name DESC;

-- 09. Best categories
SELECT
	COUNT(p.id) AS items_count,	
    c.`name`,	
    SUM(p.quantity_in_stock) AS total_quantity
FROM categories as c
		JOIN products as p ON p.category_id = c.id
GROUP BY c.`name`
ORDER BY items_count DESC, total_quantity
LIMIT 5;

-- 10. Extract client cards count
USE `final_exam`;
DROP function IF EXISTS `udf_customer_products_count`;

DELIMITER $$
USE `final_exam`$$
CREATE FUNCTION udf_customer_products_count(`name` VARCHAR(30)) 
RETURNS INTEGER
DETERMINISTIC
BEGIN
	RETURN ( SELECT COUNT(op.product_id)
    FROM customers as c
		LEFT JOIN orders as o ON o.customer_id = c.id
        LEFT JOIN orders_products as op ON op.order_id = o.id
	WHERE c.first_name = `name`);
END$$

DELIMITER ;

SELECT c.first_name,c.last_name, udf_customer_products_count('Shirley') as `total_products` FROM customers c
WHERE c.first_name = 'Shirley';

-- 11. Reduce price
USE `final_exam`;
DROP procedure IF EXISTS `udp_reduce_price`;

DELIMITER $$
USE `final_exam`$$
CREATE PROCEDURE udp_reduce_price (category_name VARCHAR(50))
BEGIN
	UPDATE products as p
		JOIN categories as c on c.id = p.category_id
        LEFT JOIN reviews as r ON r.id = p.review_id
	SET p.price = CAST((p.price * 0.7) AS DECIMAL(19,2))
    WHERE c.`name` = category_name 
		AND r.rating < 4;
END$$

DELIMITER ;

CALL udp_reduce_price ('Phones and tablets');



