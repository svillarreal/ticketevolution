CREATE TABLE IF NOT EXISTS event (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  total_tickets int4 NOT NULL,
  sold_tickets int4 NOT NULL,
  price INTEGER,
  event_date TIMESTAMPTZ
);


CREATE TABLE IF NOT EXISTS orders (
  id UUID PRIMARY KEY,
  event_id UUID NOT NULL,
  user_id UUID NOT NULL,
  total_tickets int4 NOT NULL,
  created_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_orders_event_id ON orders(event_id);
CREATE INDEX IF NOT EXISTS idx_orders_user_id ON orders(user_id);

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
