-- Exercise 1
-- Total per customer; above 100, highest first

SELECT
    c.id,
    c.name,
    SUM(o.amount) AS total_amount
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
GROUP BY c.id, c.name
HAVING SUM(o.amount) > 100
ORDER BY total_amount DESC;

-- EXERCISE 2
-- All customers with their order count, including those with 0

SELECT
    c.id,
    c.name,
    COUNT(o.id) AS order_count
FROM customers c
LEFT JOIN orders o
    ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY c.id;

-- Exercise 3
-- Customers who have no orders

SELECT
    c.id,
    c.name
FROM customers c
WHERE NOT EXISTS(
    SELECT 1
    FROM orders o
    WHERE o.customer_id = c.id
);

-- Exercise 4
-- The largest single order and who made it

SELECT
    c.name,
    o.id AS order_id,
    o.amount
FROM orders o
JOIN customers c
    ON o.customer_id = c.id
WHERE o.amount = (SELECT MAX(amount) FROM orders);

-- Exercise 5
-- Average order amount per customer, rounded to 2 decimals

SELECT
    c.id,
    c.name,
    ROUND(AVG(o.amount), 2) AS average_amount
FROM customers c
JOIN orders o
    ON c.id = o.customer_id
GROUP BY c.id, c.name
ORDER BY c.id;