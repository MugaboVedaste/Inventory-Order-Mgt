USE inventory_order_management;
-- Report A: only the products that need replenishment
SELECT
    product_id,
    name AS product_name,
    category,
    stock_quantity,
    reorder_level,
    reorder_level - stock_quantity AS shortage
FROM products
WHERE stock_quantity < reorder_level
ORDER BY shortage DESC;


-- Report B: all products, with a flag on each
SELECT
    product_id,
    name AS product_name,
    category,
    stock_quantity,
    reorder_level,
    CASE
        WHEN stock_quantity = 0             THEN 'OUT OF STOCK'
        WHEN stock_quantity < reorder_level THEN 'REORDER NOW'
        ELSE 'OK'
    END AS stock_status
FROM products
ORDER BY
    CASE
        WHEN stock_quantity = 0             THEN 1
        WHEN stock_quantity < reorder_level THEN 2
        ELSE 3
    END,
    name;