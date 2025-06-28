CREATE TABLE events (
  id UUID PRIMARY KEY,
  name TEXT NOT NULL,
  available INTEGER NOT NULL CHECK (available >= 0)
);

CREATE TABLE orders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL,
  event_id UUID NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_orders_event_id ON orders(event_id);
CREATE INDEX idx_orders_user_id ON orders(user_id);

CREATE EXTENSION IF NOT EXISTS "pgcrypto";
