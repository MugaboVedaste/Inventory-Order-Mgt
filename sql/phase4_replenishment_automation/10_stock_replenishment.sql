USE inventory_order_management;

-- Replenishment: add stock to one product, or to every product below its reorder level

DELIMITER //

CREATE PROCEDURE UpdateStock(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    DECLARE v_rows INT;

    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    -- The products trigger logs the change with this reason
    SET @log_reason = 'Replenishment';

    UPDATE products
    SET stock_quantity = stock_quantity + p_quantity
    WHERE product_id = p_product_id;

    SET v_rows = ROW_COUNT();
    SET @log_reason = NULL;

    IF v_rows = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found or stock unchanged';
    END IF;
END //

-- Restocks every product below its reorder level up to twice that level.
-- Returns the products that were restocked.
CREATE PROCEDURE ReplenishLowStock()
BEGIN
    DROP TEMPORARY TABLE IF EXISTS tmp_replenished;

    CREATE TEMPORARY TABLE tmp_replenished AS
    SELECT product_id,
           name AS product_name,
           stock_quantity AS stock_before,
           reorder_level * 2 AS stock_after
    FROM products
    WHERE stock_quantity < reorder_level;

    -- The products trigger logs each change with this reason
    SET @log_reason = 'Replenishment';

    UPDATE products AS p
    JOIN tmp_replenished AS r
        ON p.product_id = r.product_id
    SET p.stock_quantity = r.stock_after;

    SET @log_reason = NULL;

    SELECT product_id, product_name, stock_before, stock_after,
           stock_after - stock_before AS quantity_added
    FROM tmp_replenished
    ORDER BY product_id;

    DROP TEMPORARY TABLE tmp_replenished;
END //

DELIMITER ;