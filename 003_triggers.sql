-- 003_triggers.sql
-- Purpose: Triggers for restaurant business rules and automation

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
