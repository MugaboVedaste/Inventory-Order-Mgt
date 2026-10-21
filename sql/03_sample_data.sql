USE inventory_order_management;

-- Insert sample products (Kinyarwanda names)
INSERT INTO products
    (name, category, price, stock_quantity, reorder_level)
VALUES
    ('Isukari (1kg)',          'Ibiribwa',   1800.00, 100, 20),  -- Sugar
    ('Umuceri (1kg)',          'Ibiribwa',   1500.00, 120, 25),  -- Rice
    ('Ibishyimbo (1kg)',       'Ibiribwa',   1000.00, 150, 30),  -- Beans
    ('Amavuta yo guteka (1L)', 'Ibiribwa',   3500.00,  60, 10),  -- Cooking oil
    ('Umunyu (1kg)',           'Ibiribwa',    500.00,  80, 15),  -- Salt
    ('Ifu y''ibigori (1kg)',   'Ibiribwa',    900.00,  90, 20),  -- Maize flour
    ('Ibirayi (1kg)',          'Imboga',      500.00, 200, 40),  -- Potatoes
    ('Inyanya (1kg)',          'Imboga',     1000.00,  70, 15),  -- Tomatoes
    ('Igitoki (1kg)',          'Imbuto',      400.00, 120, 25),  -- Cooking banana
    ('Amagi (30)',             'Ibiribwa',   5000.00,  40,  8),  -- Eggs (tray)
    ('Amata (1L)',             'Ibinyobwa',   800.00,  60, 12),  -- Milk
    ('Icyayi (250g)',          'Ibinyobwa',  2000.00,  50, 10),  -- Tea
    ('Ikawa (250g)',           'Ibinyobwa',  4000.00,  35,  7),  -- Coffee
    ('Amazi (1.5L)',           'Ibinyobwa',   600.00, 150, 30),  -- Water
    ('Isabune',                'Isuku',       600.00, 100, 20);  -- Soap

-- Display the inserted products
-- SELECT * FROM products;

-- Insert sample customers
INSERT INTO customers
    (name, email, phone)
VALUES
    ('Jean Claude', 'jean.claude@example.com', '0788000001'),
    ('Alice Uwimana', 'alice.uwimana@example.com', '0788000002'),
    ('Eric Niyonzima', 'eric.niyonzima@example.com', '0788000003');

-- Display the inserted customers
SELECT * FROM customers;
