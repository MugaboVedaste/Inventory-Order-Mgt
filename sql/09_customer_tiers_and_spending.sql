USE inventory_order_management;

-- The tier is stored in customers.tier and kept up to date by triggers
-- (see 05_automation.sql), so the view only reads it.
CREATE OR REPLACE VIEW vw_customer_spending AS
SELECT
    c.customer_id,
    c.name AS customer_name,
    c.email,
    COUNT(o.order_id)                   AS number_of_orders,
    COALESCE(SUM(o.total_amount), 0)    AS total_spent,
    COALESCE(AVG(o.total_amount), 0)    AS average_order_value,
    MAX(o.order_date)                   AS last_order_date,
    c.tier
FROM customers AS c
LEFT JOIN orders AS o
    ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name, c.email, c.tier;


-- Report A: every customer with their tier
SELECT *
FROM vw_customer_spending
ORDER BY total_spent DESC;


-- Report B: summary per tier
SELECT
    tier,
    COUNT(*)                          AS number_of_customers,
    SUM(total_spent)                  AS tier_revenue,
    ROUND(AVG(total_spent), 2)        AS average_spent_per_customer,
    ROUND(SUM(total_spent) * 100 /
          (SELECT SUM(total_spent) FROM vw_customer_spending), 1)
                                      AS percent_of_revenue
FROM vw_customer_spending
GROUP BY tier
ORDER BY FIELD(tier, 'Gold', 'Silver', 'Bronze', 'No orders');