-- --Quantity of one product	Discount
-- 1 – 9	0%
-- 10 – 19	5%
-- 20 – 49	10%
-- 50 or more	15%

-- Step 1: add a discount column and a function (run once)
USE inventory_order_management;

ALTER TABLE order_details
    ADD COLUMN discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00;

DROP FUNCTION IF EXISTS fn_bulk_discount;

DELIMITER $$

CREATE FUNCTION fn_bulk_discount(qty INT)
RETURNS DECIMAL(5,2)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN qty >= 50 THEN 15.00
        WHEN qty >= 20 THEN 10.00
        WHEN qty >= 10 THEN 5.00
        ELSE 0.00
    END;
END$$

DELIMITER ;

-- Report: discounts given

SELECT
    o.order_id,
    c.name AS customer_name,
    p.name AS product_name,
    d.quantity,
    d.unit_price,
    d.discount_percent,
    d.quantity * d.unit_price                                   AS price_before_discount,
    ROUND(d.quantity * d.unit_price * d.discount_percent / 100, 2) AS discount_amount,
    ROUND(d.quantity * d.unit_price * (1 - d.discount_percent / 100), 2) AS price_after_discount
FROM order_details AS d
JOIN orders    AS o ON d.order_id   = o.order_id
JOIN customers AS c ON o.customer_id = c.customer_id
JOIN products  AS p ON d.product_id = p.product_id
WHERE d.discount_percent > 0
ORDER BY o.order_id;