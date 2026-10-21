USE inventory_order_management;

-- updating the stock level when the level is below reorder

DELIMITER //

CREATE PROCEDURE UpdateStock(
    IN p_product_id INT,
    IN p_quantity INT
)
BEGIN
    IF p_quantity <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Quantity must be greater than zero';
    END IF;

    UPDATE products
    SET stock_quantity = stock_quantity + p_quantity
    WHERE product_id = p_product_id;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Product not found or stock unchanged';
    END IF;
END //

DELIMITER ;