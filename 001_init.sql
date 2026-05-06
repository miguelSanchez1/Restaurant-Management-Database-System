
-- 001_init.sql
-- Purpose: Initialize the Restaurant Management Database System
-- Based on the project proposal PDF scope

CREATE TABLE customer (
  customer_id      BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name        VARCHAR(120) NOT NULL,
  phone            VARCHAR(20) NOT NULL UNIQUE,
  email            VARCHAR(255) UNIQUE,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE TABLE staff (
  staff_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  full_name        VARCHAR(120) NOT NULL,
  role             VARCHAR(20) NOT NULL,
  phone            VARCHAR(20) UNIQUE,
  hire_date        DATE NOT NULL,
  is_active        BOOLEAN NOT NULL DEFAULT TRUE,
  CHECK (role IN ('Manager', 'Server', 'Host', 'Cashier'))
);

CREATE TABLE restaurant_table (
  table_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  table_number     INT NOT NULL UNIQUE,
  seating_capacity INT NOT NULL CHECK (seating_capacity > 0),
  status           VARCHAR(20) NOT NULL DEFAULT 'Available',
  CHECK (status IN ('Available', 'Reserved', 'Occupied', 'Cleaning'))
);

CREATE TABLE menu_item (
  menu_item_id     BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  item_name        VARCHAR(120) NOT NULL UNIQUE,
  category         VARCHAR(50) NOT NULL,
  price            NUMERIC(10,2) NOT NULL CHECK (price > 0),
  is_available     BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE reservation (
  reservation_id   BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id      BIGINT NOT NULL,
  table_id         BIGINT NOT NULL,
  reserved_by      BIGINT NOT NULL,
  reservation_time TIMESTAMPTZ NOT NULL,
  party_size       INT NOT NULL CHECK (party_size > 0),
  status           VARCHAR(20) NOT NULL DEFAULT 'Booked',
  notes            TEXT,
  created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  CHECK (status IN ('Booked', 'Seated', 'Completed', 'Cancelled')),
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
  FOREIGN KEY (table_id) REFERENCES restaurant_table(table_id),
  FOREIGN KEY (reserved_by) REFERENCES staff(staff_id)
);

CREATE TABLE customer_order (
  order_id         BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  customer_id      BIGINT NOT NULL,
  table_id         BIGINT,
  staff_id         BIGINT NOT NULL,
  order_type       VARCHAR(20) NOT NULL,
  order_status     VARCHAR(20) NOT NULL DEFAULT 'Pending',
  order_time       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  total_amount     NUMERIC(10,2) NOT NULL DEFAULT 0 CHECK (total_amount >= 0),
  notes            TEXT,
  CHECK (order_type IN ('Dine-In', 'Takeout')),
  CHECK (order_status IN ('Pending', 'Preparing', 'Served', 'Paid', 'Cancelled')),
  FOREIGN KEY (customer_id) REFERENCES customer(customer_id),
  FOREIGN KEY (table_id) REFERENCES restaurant_table(table_id),
  FOREIGN KEY (staff_id) REFERENCES staff(staff_id)
);

CREATE TABLE order_item (
  order_item_id    BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id         BIGINT NOT NULL,
  menu_item_id     BIGINT NOT NULL,
  quantity         INT NOT NULL CHECK (quantity > 0),
  unit_price       NUMERIC(10,2) NOT NULL CHECK (unit_price > 0),
  line_total       NUMERIC(10,2) NOT NULL CHECK (line_total >= 0),
  FOREIGN KEY (order_id) REFERENCES customer_order(order_id) ON DELETE CASCADE,
  FOREIGN KEY (menu_item_id) REFERENCES menu_item(menu_item_id),
  UNIQUE (order_id, menu_item_id)
);

CREATE TABLE payment (
  payment_id       BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  order_id         BIGINT NOT NULL UNIQUE,
  processed_by     BIGINT NOT NULL,
  payment_method   VARCHAR(20) NOT NULL,
  amount_paid      NUMERIC(10,2) NOT NULL CHECK (amount_paid >= 0),
  payment_status   VARCHAR(20) NOT NULL DEFAULT 'Pending',
  paid_at          TIMESTAMPTZ,
  CHECK (payment_method IN ('Cash', 'Card', 'Mobile')),
  CHECK (payment_status IN ('Pending', 'Paid', 'Refunded')),
  FOREIGN KEY (order_id) REFERENCES customer_order(order_id) ON DELETE CASCADE,
  FOREIGN KEY (processed_by) REFERENCES staff(staff_id)
);

CREATE INDEX idx_reservation_time ON reservation(reservation_time);
CREATE INDEX idx_order_status ON customer_order(order_status);
CREATE INDEX idx_order_staff ON customer_order(staff_id);
CREATE INDEX idx_order_item_order ON order_item(order_id);
CREATE INDEX idx_payment_status ON payment(payment_status);
