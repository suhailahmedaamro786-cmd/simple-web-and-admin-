-- Phase 2: customer accounts and private order history.
CREATE TABLE IF NOT EXISTS customers (id INTEGER PRIMARY KEY AUTOINCREMENT,name TEXT NOT NULL,email TEXT NOT NULL UNIQUE COLLATE NOCASE,password_hash TEXT NOT NULL,password_salt TEXT NOT NULL,is_active INTEGER NOT NULL DEFAULT 1,created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,last_login_at TEXT);
ALTER TABLE orders ADD COLUMN customer_id INTEGER REFERENCES customers(id);
CREATE INDEX IF NOT EXISTS idx_orders_customer_id ON orders(customer_id);
CREATE TABLE IF NOT EXISTS customer_auth_attempts (id INTEGER PRIMARY KEY AUTOINCREMENT,email TEXT NOT NULL,attempted_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,success INTEGER NOT NULL DEFAULT 0);
CREATE INDEX IF NOT EXISTS idx_customer_auth_attempts_email_time ON customer_auth_attempts(email,attempted_at);
