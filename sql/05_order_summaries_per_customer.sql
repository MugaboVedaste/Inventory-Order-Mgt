-- each order, grouped by customer
SELECT
    c.customer_id,
    c.name AS customer_name,
    o.order_id,
    o.order_date,
    o.total_amount,
    d.item_lines,
    d.total_units
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN (
    SELECT
        order_id,
        COUNT(*)      AS item_lines,   -- different products in the order
        SUM(quantity) AS total_units   -- total pieces ordered
    FROM order_details
    GROUP BY order_id
) AS d
    ON o.order_id = d.order_id
ORDER BY c.name, o.order_date;

-- one summary row per customer
SELECT
    c.customer_id,
    c.name AS customer_name,
    COUNT(o.order_id)  AS number_of_orders,
    MIN(o.order_date)  AS first_order,
    MAX(o.order_date)  AS last_order,
    SUM(o.total_amount) AS total_spent,
    SUM(d.total_units) AS total_units
FROM orders AS o
JOIN customers AS c
    ON o.customer_id = c.customer_id
JOIN (
    SELECT order_id, SUM(quantity) AS total_units
    FROM order_details
    GROUP BY order_id
) AS d
    ON o.order_id = d.order_id
GROUP BY c.customer_id, c.name
ORDER BY total_spent DESC;