-- Inventory and Order Management System
-- Phase 1: Database setup

CREATE DATABASE IF NOT EXISTS inventory_order_management;

USE inventory_order_management;

-- 1. Products
CREATE TABLE IF NOT EXISTS products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    stock_quantity INT NOT NULL DEFAULT 0,
    reorder_level INT NOT NULL DEFAULT 10,

    CONSTRAINT chk_products_price
        CHECK (price >= 0),

    CONSTRAINT chk_products_stock
        CHECK (stock_quantity >= 0),

    CONSTRAINT chk_products_reorder
        CHECK (reorder_level >= 0)
) ENGINE = InnoDB;


-- 2. Customers
CREATE TABLE IF NOT EXISTS customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    phone VARCHAR(30) NULL,
    -- Kept up to date by triggers (see 05_automation.sql)
    tier VARCHAR(20) NOT NULL DEFAULT 'No orders'
) ENGINE = InnoDB;


-- 3. Orders
CREATE TABLE IF NOT EXISTS orders (
    order_id INT AUTO_INCREMENT PRIMARY KEY,
    customer_id INT NOT NULL,
    order_date DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(12,2) NOT NULL DEFAULT 0,

    CONSTRAINT chk_orders_total
        CHECK (total_amount >= 0),

    CONSTRAINT fk_orders_customers
        FOREIGN KEY (customer_id)
        REFERENCES customers(customer_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- 4. Order Details
CREATE TABLE IF NOT EXISTS order_details (
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    unit_price DECIMAL(10,2) NOT NULL,
    -- Set by a trigger from the quantity (see 04_bulk_discounts.sql)
    discount_percent DECIMAL(5,2) NOT NULL DEFAULT 0.00,

    PRIMARY KEY (order_id, product_id),

    CONSTRAINT chk_details_quantity
        CHECK (quantity > 0),

    CONSTRAINT chk_details_price
        CHECK (unit_price >= 0),

    CONSTRAINT fk_details_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_details_products
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;


-- 5. Inventory Logs
CREATE TABLE IF NOT EXISTS inventory_logs (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    change_quantity INT NOT NULL,
    reason VARCHAR(50) NOT NULL,
    created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    order_id INT NULL,

    CONSTRAINT chk_inventory_change
        CHECK (change_quantity <> 0),

    CONSTRAINT fk_logs_products
        FOREIGN KEY (product_id)
        REFERENCES products(product_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT,

    CONSTRAINT fk_logs_orders
        FOREIGN KEY (order_id)
        REFERENCES orders(order_id)
        ON UPDATE CASCADE
        ON DELETE RESTRICT
) ENGINE = InnoDB;