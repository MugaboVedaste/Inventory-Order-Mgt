
USE inventory_order_management;

START TRANSACTION;

-- Discounts, stock deduction, inventory logging, the order total and the
-- customer tier are all handled by the triggers in 05_automation.sql.
-- This script only inserts the order and its lines.

-- 1. Find the customer ID
SET @customer_id = (
    SELECT customer_id
    FROM customers
    WHERE email = 'alice.uwimana@example.com'
);

-- 2. Create the order
INSERT INTO orders (customer_id, total_amount)
VALUES (@customer_id, 0.00);

-- Save the newly generated order ID
SET @order_id = LAST_INSERT_ID();

-- 3. Add one soap to the order
-- (the product is read into variables first, because the order_details
--  trigger updates products and MySQL does not allow that in the same
--  statement that reads it)
SELECT product_id, price INTO @product_id, @price
FROM products
WHERE name = 'Isabune';

INSERT INTO order_details (order_id, product_id, quantity, unit_price)
VALUES (@order_id, @product_id, 1, @price);

-- 4. Add two kilos of potatoes to the same order
SELECT product_id, price INTO @product_id, @price
FROM products
WHERE name = 'Ibirayi (1kg)';

INSERT INTO order_details (order_id, product_id, quantity, unit_price)
VALUES (@order_id, @product_id, 2, @price);

-- 5. Add one tray of eggs to the same order
SELECT product_id, price INTO @product_id, @price
FROM products
WHERE name = 'Amagi (30)';

INSERT INTO order_details (order_id, product_id, quantity, unit_price)
VALUES (@order_id, @product_id, 1, @price);

COMMIT;

-- 6. View the order summary (total_amount was calculated by the trigger)
SELECT
    o.order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_id = @order_id;

-- 7. View the products in the order with their new stock
SELECT
    p.product_id,
    p.name AS product_name,
    od.quantity,
    od.unit_price,
    od.quantity * od.unit_price AS subtotal,
    p.stock_quantity AS stock_now
FROM order_details AS od
JOIN products AS p
    ON od.product_id = p.product_id
WHERE od.order_id = @order_id;

-- 8. View the inventory log entries for this order
SELECT *
FROM inventory_logs
WHERE order_id = @order_id;
