USE inventory_order_management;

-- view for order summary
CREATE VIEW order_summary AS
SELECT
    o.order_id,
    c.name AS customer_name,
    o.order_date,
    o.total_amount,
    COALESCE(SUM(od.quantity), 0) AS total_items
FROM orders o
JOIN customers c
    ON o.customer_id = c.customer_id
LEFT JOIN order_details od
    ON o.order_id = od.order_id
GROUP BY
    o.order_id,
    c.name,
    o.order_date,
    o.total_amount;

-- use the view
SELECT *
FROM order_summary
ORDER BY order_date DESC;

-- low product view

CREATE VIEW low_stock_products AS
SELECT
    product_id,
    name AS product_name,
    category,
    stock_quantity,
    reorder_level
FROM products
WHERE stock_quantity = 0
   OR stock_quantity < reorder_level;
   
-- use view 
SELECT *
FROM low_stock_products
ORDER BY stock_quantity ASC;

-- both view
SHOW FULL TABLES
WHERE Table_type = 'VIEW';