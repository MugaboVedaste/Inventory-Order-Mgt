-- Phase 4: Automation
-- After this script, inserting a row into order_details is all it takes to:
--   1. apply the bulk discount to the line,
--   2. deduct the stock (the products trigger in 02 logs the change),
--   3. recalculate the order total,
--   4. refresh the customer's tier.
-- Needs 02_create_triggers.sql and 04_bulk_discounts.sql to be run first.

USE inventory_order_management;

DROP FUNCTION IF EXISTS fn_customer_tier;
DROP PROCEDURE IF EXISTS sp_refresh_customer_tier;

DELIMITER $$

-- Tier from the number of orders and the total spent
CREATE FUNCTION fn_customer_tier(p_orders INT, p_total_spent DECIMAL(12,2))
RETURNS VARCHAR(20)
DETERMINISTIC
BEGIN
    RETURN CASE
        WHEN p_orders = 0           THEN 'No orders'
        WHEN p_total_spent >= 50000 THEN 'Gold'
        WHEN p_total_spent >= 20000 THEN 'Silver'
        ELSE 'Bronze'
    END;
END$$

-- Recalculates one customer's tier from their orders
CREATE PROCEDURE sp_refresh_customer_tier(IN p_customer_id INT)
BEGIN
    UPDATE customers
    SET tier = fn_customer_tier(
        (SELECT COUNT(*) FROM orders WHERE customer_id = p_customer_id),
        (SELECT COALESCE(SUM(total_amount), 0) FROM orders WHERE customer_id = p_customer_id)
    )
    WHERE customer_id = p_customer_id;
END$$


-- 1. Bulk discount: set from the quantity before the line is saved
CREATE TRIGGER trg_order_details_before_insert
BEFORE INSERT ON order_details
FOR EACH ROW
BEGIN
    SET NEW.discount_percent = fn_bulk_discount(NEW.quantity);
END$$


-- 2 + 3. Stock and order total: after the line is saved
CREATE TRIGGER trg_order_details_after_insert
AFTER INSERT ON order_details
FOR EACH ROW
BEGIN
    -- Deduct the stock. The products trigger writes the inventory log entry
    -- using these two variables. If there is not enough stock, the CHECK on
    -- products.stock_quantity fails and the whole insert is rejected.
    SET @log_reason = 'Order';
    SET @log_order_id = NEW.order_id;

    UPDATE products
    SET stock_quantity = stock_quantity - NEW.quantity
    WHERE product_id = NEW.product_id;

    SET @log_reason = NULL;
    SET @log_order_id = NULL;

    -- Recalculate the order total from all of its lines
    UPDATE orders
    SET total_amount = (
        SELECT ROUND(SUM(quantity * unit_price * (1 - discount_percent / 100)), 2)
        FROM order_details
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END$$


-- 4. Customer tier: whenever an order is created or its total changes
CREATE TRIGGER trg_orders_after_insert
AFTER INSERT ON orders
FOR EACH ROW
BEGIN
    CALL sp_refresh_customer_tier(NEW.customer_id);
END$$

CREATE TRIGGER trg_orders_after_update
AFTER UPDATE ON orders
FOR EACH ROW
BEGIN
    IF NEW.total_amount <> OLD.total_amount THEN
        CALL sp_refresh_customer_tier(NEW.customer_id);
    END IF;
END$$

DELIMITER ;
