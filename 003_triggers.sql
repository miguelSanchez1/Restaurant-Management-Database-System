-- 003_triggers.sql
-- Purpose: Triggers for restaurant business rules and automation

-- calculates line total for each order item based on quantity and unit price
-- keeps line totals up-to-date without relying on manual input
CREATE OR REPLACE FUNCTION fn_set_order_item_total()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  NEW.line_total := ROUND((NEW.quantity * NEW.unit_price)::numeric, 2);
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_set_order_item_total
  BEFORE INSERT OR UPDATE ON order_item
  FOR EACH ROW
  EXECUTE FUNCTION fn_set_order_item_total();

-- Recalculates the total amount for an order whenever an order item is added, updated, or deleted
-- Ensures that each customers order reflects the correct total amount based on the current order items
CREATE OR REPLACE FUNCTION fn_refresh_order_total()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_order_id BIGINT;
BEGIN
  v_order_id := COALESCE(NEW.order_id, OLD.order_id);

  UPDATE customer_order
  SET total_amount = COALESCE((
    SELECT SUM(line_total)
    FROM order_item
    WHERE order_id = v_order_id
  ), 0)
  WHERE order_id = v_order_id;

  RETURN COALESCE(NEW, OLD);
END;
$$;

CREATE TRIGGER trg_refresh_order_total
  AFTER INSERT OR UPDATE OR DELETE ON order_item
  FOR EACH ROW
  EXECUTE FUNCTION fn_refresh_order_total();

-- Checks that the party size for a reservation does not exceed the seating capacity of the assigned table
-- Prevents overbooking / business constraints by validating reservation details before they are saved
CREATE OR REPLACE FUNCTION fn_check_reservation_capacity()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
DECLARE
  v_capacity INT;
BEGIN
  SELECT seating_capacity
  INTO v_capacity
  FROM restaurant_table
  WHERE table_id = NEW.table_id;

  IF NEW.party_size > v_capacity THEN
    RAISE EXCEPTION
      'Party size % exceeds seating capacity % for table %.',
      NEW.party_size, v_capacity, NEW.table_id;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_check_reservation_capacity
  BEFORE INSERT OR UPDATE ON reservation
  FOR EACH ROW
  EXECUTE FUNCTION fn_check_reservation_capacity();

-- Updates order status to 'Paid' when a payment record is marked as paid
-- Ensures that the order status accurately reflects the payment status without requiring manual updates
CREATE OR REPLACE FUNCTION fn_mark_order_paid()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
  IF NEW.payment_status = 'Paid' THEN
    UPDATE customer_order
    SET order_status = 'Paid'
    WHERE order_id = NEW.order_id;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_mark_order_paid
  AFTER INSERT OR UPDATE ON payment
  FOR EACH ROW
  EXECUTE FUNCTION fn_mark_order_paid();
