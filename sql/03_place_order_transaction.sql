
USE inventory_order_management;

START TRANSACTION;

-- 1. Find Vedaste's customer ID
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

-- 3. Add the laptop to the order
INSERT INTO order_details
    (order_id, product_id, quantity, unit_price)
SELECT @order_id, product_id, 1, price
FROM products
WHERE name = 'Isabune';

-- 4. Add two mice to the same order
INSERT INTO order_details
    (order_id, product_id, quantity, unit_price)
SELECT @order_id, product_id, 2, price
FROM products
WHERE name = 'Ibirayi (1kg)';

-- 5. Add one keyboard to the same order
INSERT INTO order_details
    (order_id, product_id, quantity, unit_price)
SELECT @order_id, product_id, 1, price
FROM products
WHERE name = 'Amagi (30)';

-- 6. Calculate the order total from its details
UPDATE orders
SET total_amount = (
    SELECT SUM(quantity * unit_price)
    FROM order_details
    WHERE order_id = @order_id
)
WHERE order_id = @order_id;

-- 7. Reduce stock for every item in the order (the trigger logs each change)
SET @log_reason = 'Order';
SET @log_order_id = @order_id;

UPDATE products AS p
JOIN order_details AS od
    ON p.product_id = od.product_id
SET p.stock_quantity = p.stock_quantity - od.quantity
WHERE od.order_id = @order_id;

-- Clear the variables so later changes aren't linked to this order
SET @log_reason = NULL;
SET @log_order_id = NULL;

COMMIT;

-- 8. View the order summary
SELECT
    o.order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
WHERE o.order_id = @order_id;

-- 9. View the products in the order with their new stock
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

-- 10. View the inventory log entries for this order
SELECT *
FROM inventory_logs
WHERE order_id = @order_id;
