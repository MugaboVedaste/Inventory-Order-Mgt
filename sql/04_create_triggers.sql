USE inventory_order_management;


DELIMITER $$

CREATE TRIGGER trg_products_after_insert
AFTER INSERT ON products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity > 0 THEN
        INSERT INTO inventory_logs (product_id, change_quantity, reason)
        VALUES (NEW.product_id, NEW.stock_quantity, 'Initial stock');
    END IF;
END$$

CREATE TRIGGER trg_products_after_update
AFTER UPDATE ON products
FOR EACH ROW
BEGIN
    IF NEW.stock_quantity <> OLD.stock_quantity THEN
        INSERT INTO inventory_logs (product_id, change_quantity, reason, order_id)
        VALUES (
            NEW.product_id,
            NEW.stock_quantity - OLD.stock_quantity,
            COALESCE(@log_reason, 'Manual adjustment'),
            @log_order_id
        );
    END IF;
END$$

DELIMITER ;