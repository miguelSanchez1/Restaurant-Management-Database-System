
-- 002_seed_data.sql
-- Purpose: Insert sample data for the Restaurant Management Database System

INSERT INTO customer (full_name, phone, email) VALUES
('Emma Rodriguez', '714-555-1001', 'emma@email.com'),
('Noah Kim', '714-555-1002', 'noah@email.com'),
('Sophia Patel', '714-555-1003', 'sophia@email.com');

INSERT INTO staff (full_name, role, phone, hire_date) VALUES
('Olivia Martinez', 'Manager', '714-555-2001', '2022-04-01'),
('Ethan Chen', 'Server', '714-555-2002', '2023-01-15'),
('Mia Johnson', 'Host', '714-555-2003', '2023-06-01'),
('Lucas Brown', 'Cashier', '714-555-2004', '2023-09-10');

INSERT INTO restaurant_table (table_number, seating_capacity, status) VALUES
(1, 2, 'Available'),
(2, 4, 'Reserved'),
(3, 4, 'Available'),
(4, 6, 'Occupied');

INSERT INTO menu_item (item_name, category, price, is_available) VALUES
('Garlic Bread', 'Appetizer', 6.50, TRUE),
('Caesar Salad', 'Appetizer', 8.00, TRUE),
('Grilled Salmon', 'Entree', 24.00, TRUE),
('Chicken Alfredo', 'Entree', 18.50, TRUE),
('Cheesecake', 'Dessert', 7.50, TRUE),
('Iced Tea', 'Drink', 3.50, TRUE);

INSERT INTO reservation (
  customer_id, table_id, reserved_by, reservation_time, party_size, status, notes
) VALUES
(1, 2, 3, NOW() + INTERVAL '2 hours', 4, 'Booked', 'Birthday dinner'),
(2, 3, 3, NOW() + INTERVAL '1 day', 2, 'Booked', 'Window preferred'),
(3, 1, 3, NOW() - INTERVAL '3 hours', 2, 'Completed', 'Anniversary');

INSERT INTO customer_order (
  customer_id, table_id, staff_id, order_type, order_status, order_time, total_amount, notes
) VALUES
(1, 2, 2, 'Dine-In', 'Preparing', NOW() - INTERVAL '20 minutes', 0, 'No onions'),
(2, NULL, 2, 'Takeout', 'Paid', NOW() - INTERVAL '2 hours', 0, 'Pickup order'),
(3, 4, 2, 'Dine-In', 'Served', NOW() - INTERVAL '45 minutes', 0, 'Extra plates');

INSERT INTO order_item (order_id, menu_item_id, quantity, unit_price, line_total) VALUES
(1, 1, 1, 6.50, 6.50),
(1, 4, 2, 18.50, 37.00),
(1, 6, 2, 3.50, 7.00),
(2, 3, 1, 24.00, 24.00),
(2, 5, 1, 7.50, 7.50),
(3, 2, 1, 8.00, 8.00),
(3, 4, 1, 18.50, 18.50);

UPDATE customer_order o
SET total_amount = totals.total_amount
FROM (
  SELECT order_id, SUM(line_total) AS total_amount
  FROM order_item
  GROUP BY order_id
) totals
WHERE totals.order_id = o.order_id;

INSERT INTO payment (
  order_id, processed_by, payment_method, amount_paid, payment_status, paid_at
) VALUES
(1, 4, 'Card', 0, 'Pending', NULL),
(2, 4, 'Cash', 31.50, 'Paid', NOW() - INTERVAL '90 minutes'),
(3, 4, 'Mobile', 0, 'Pending', NULL);
