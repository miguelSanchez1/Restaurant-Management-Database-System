 -- 004_views.sql
-- Purpose: Reporting and dashboard views

CREATE OR REPLACE VIEW vw_reservation_schedule AS
SELECT
  r.reservation_id,
  c.full_name AS customer_name,
  rt.table_number,
  rt.seating_capacity,
  r.party_size,
  r.reservation_time,
  r.status,
  s.full_name AS reserved_by
FROM reservation r
JOIN customer c ON c.customer_id = r.customer_id
JOIN restaurant_table rt ON rt.table_id = r.table_id
JOIN staff s ON s.staff_id = r.reserved_by
ORDER BY r.reservation_time;


CREATE OR REPLACE VIEW vw_order_summary AS
SELECT
  o.order_id,
  c.full_name AS customer_name,
  o.order_type,
  o.order_status,
  o.order_time,
  COALESCE(rt.table_number, 0) AS table_number,
  s.full_name AS staff_name,
  o.total_amount
FROM customer_order o
JOIN customer c ON c.customer_id = o.customer_id
LEFT JOIN restaurant_table rt ON rt.table_id = o.table_id
JOIN staff s ON s.staff_id = o.staff_id
ORDER BY o.order_time DESC;


CREATE OR REPLACE VIEW vw_payment_summary AS
SELECT
  p.payment_id,
  p.order_id,
  c.full_name AS customer_name,
  p.payment_method,
  p.amount_paid,
  p.payment_status,
  p.paid_at
FROM payment p
JOIN customer_order o ON o.order_id = p.order_id
JOIN customer c ON c.customer_id = o.customer_id
ORDER BY p.payment_id;


CREATE OR REPLACE VIEW vw_table_status AS
SELECT
  rt.table_id,
  rt.table_number,
  rt.seating_capacity,
  rt.status,
  r.reservation_time,
  r.party_size
FROM restaurant_table rt
LEFT JOIN reservation r
  ON r.table_id = rt.table_id
 AND r.status IN ('Booked', 'Seated')
ORDER BY rt.table_number;


CREATE OR REPLACE VIEW vw_sales_by_menu_item AS
SELECT
  mi.menu_item_id,
  mi.item_name,
  mi.category,
  SUM(oi.quantity) AS total_quantity_sold,
  SUM(oi.line_total) AS total_sales
FROM order_item oi
JOIN menu_item mi ON mi.menu_item_id = oi.menu_item_id
GROUP BY mi.menu_item_id, mi.item_name, mi.category
ORDER BY total_sales DESC, total_quantity_sold DESC;
