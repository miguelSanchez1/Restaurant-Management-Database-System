-- 005_queries.sql
-- Purpose: Example SELECT / UPDATE / DELETE queries

-- =========================
-- READ (SELECT) — 3 examples
-- =========================

-- READ #1: List all customers and their orders
SELECT
  c.customer_id,
  c.full_name,
  o.order_id,
  o.order_status,
  o.total_amount
FROM customer c
LEFT JOIN customer_order o ON o.customer_id = c.customer_id
ORDER BY c.customer_id, o.order_id;

-- READ #2: Show upcoming reservations with table capacity
SELECT
  r.reservation_id,
  c.full_name,
  rt.table_number,
  rt.seating_capacity,
  r.party_size,
  r.reservation_time
FROM reservation r
JOIN customer c ON c.customer_id = r.customer_id
JOIN restaurant_table rt ON rt.table_id = r.table_id
WHERE r.reservation_time >= NOW()
ORDER BY r.reservation_time;

-- READ #3: Show all payments and order totals
SELECT
  p.payment_id,
  p.order_id,
  p.payment_status,
  p.amount_paid,
  o.total_amount
FROM payment p
JOIN customer_order o ON o.order_id = p.order_id
ORDER BY p.payment_id;


-- =========================
-- UPDATE — 6 examples
-- =========================

-- UPDATE #1: Change a reservation status
SELECT * FROM reservation WHERE reservation_id = 1;
UPDATE reservation SET status = 'Seated' WHERE reservation_id = 1;
SELECT * FROM reservation WHERE reservation_id = 1;

-- UPDATE #2: Mark a table as occupied
SELECT * FROM restaurant_table WHERE table_id = 2;
UPDATE restaurant_table SET status = 'Occupied' WHERE table_id = 2;
SELECT * FROM restaurant_table WHERE table_id = 2;

-- UPDATE #3: Mark a payment as paid
SELECT * FROM payment WHERE payment_id = 1;
UPDATE payment SET payment_status = 'Paid', amount_paid = 50.50, paid_at = NOW() WHERE payment_id = 1;
SELECT * FROM payment WHERE payment_id = 1;

-- UPDATE #4: Change customer phone number
SELECT * FROM customer WHERE customer_id = 1;
UPDATE customer SET phone = '714-555-1111' WHERE customer_id = 1;
SELECT * FROM customer WHERE customer_id = 1;

-- UPDATE #5: Change menu item price
SELECT * FROM menu_item WHERE menu_item_id = 2;
UPDATE menu_item SET price = 9.00 WHERE menu_item_id = 2;
SELECT * FROM menu_item WHERE menu_item_id = 2;

-- UPDATE #6: Mark staff as inactive
SELECT * FROM staff WHERE staff_id = 3;
UPDATE staff SET is_active = FALSE WHERE staff_id = 3;
SELECT * FROM staff WHERE staff_id = 3;


-- =========================
-- DELETE — 6 examples
-- =========================

BEGIN;

-- DELETE #1: Delete a pending payment record
SELECT * FROM payment WHERE payment_id = 1;
DELETE FROM payment WHERE payment_id = 1;
SELECT * FROM payment WHERE payment_id = 1;

-- DELETE #2: Delete an order item row
SELECT * FROM order_item WHERE order_item_id = 1;
DELETE FROM order_item WHERE order_item_id = 1;
SELECT * FROM order_item WHERE order_item_id = 1;

-- DELETE #3: Delete a completed reservation record
SELECT * FROM reservation WHERE reservation_id = 3;
DELETE FROM reservation WHERE reservation_id = 3;
SELECT * FROM reservation WHERE reservation_id = 3;

-- DELETE #4: Remove a customer (must delete their reservations and orders first)
SELECT * FROM reservation WHERE customer_id = 2;
DELETE FROM reservation WHERE customer_id = 2;

SELECT * FROM customer_order WHERE customer_id = 2;
DELETE FROM customer_order WHERE customer_id = 2;

SELECT * FROM customer WHERE customer_id = 2;
DELETE FROM customer WHERE customer_id = 2;
SELECT * FROM customer WHERE customer_id = 2;

-- DELETE #5: Remove a menu item (must delete dependent order items first)
SELECT * FROM order_item WHERE menu_item_id = 6;
DELETE FROM order_item WHERE menu_item_id = 6;
SELECT * FROM menu_item WHERE menu_item_id = 6;
DELETE FROM menu_item WHERE menu_item_id = 6;
SELECT * FROM menu_item WHERE menu_item_id = 6;

-- DELETE #6: Remove a staff record (must delete dependent payments first)
SELECT * FROM payment WHERE processed_by = 4;
DELETE FROM payment WHERE processed_by = 4;
SELECT * FROM staff WHERE staff_id = 4;
DELETE FROM staff WHERE staff_id = 4;
SELECT * FROM staff WHERE staff_id = 4;

ROLLBACK;
