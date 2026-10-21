USE inventory_order_management;

-- Customers: finding a customer by email in the order script
CREATE UNIQUE INDEX idx_customers_email ON customers (email);

-- Products: looking up products by name and filtering by category
CREATE UNIQUE INDEX idx_products_name ON products (name);
CREATE INDEX idx_products_category ON products (category);

-- Orders: per-customer summaries, tiers, and date-range reports
CREATE INDEX idx_orders_customer_date_total ON orders (customer_id, order_date, total_amount);
CREATE INDEX idx_orders_date ON orders (order_date);

-- Order details: recalculating order totals and product sales reports
CREATE INDEX idx_details_order_totals
    ON order_details (order_id, quantity, unit_price, discount_percent);
CREATE INDEX idx_details_product ON order_details (product_id);

-- Inventory logs: audit history, replenishment reports, date ranges
CREATE INDEX idx_logs_product_date ON inventory_logs (product_id, created_at);
CREATE INDEX idx_logs_reason_date ON inventory_logs (reason, created_at);
CREATE INDEX idx_logs_date ON inventory_logs (created_at);

-- Check the indexes on each table
SHOW INDEX FROM customers;
SHOW INDEX FROM products;
SHOW INDEX FROM orders;
SHOW INDEX FROM order_details;
SHOW INDEX FROM inventory_logs;