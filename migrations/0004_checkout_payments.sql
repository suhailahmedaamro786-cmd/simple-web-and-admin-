-- Phase 4: Pakistan delivery addresses, server-calculated checkout, coupons and payment verification.
ALTER TABLE orders ADD COLUMN subtotal_amount REAL NOT NULL DEFAULT 0;
ALTER TABLE orders ADD COLUMN shipping_amount REAL NOT NULL DEFAULT 0;
ALTER TABLE orders ADD COLUMN discount_amount REAL NOT NULL DEFAULT 0;
ALTER TABLE orders ADD COLUMN coupon_code TEXT NOT NULL DEFAULT '';
ALTER TABLE orders ADD COLUMN city TEXT NOT NULL DEFAULT '';
ALTER TABLE orders ADD COLUMN province TEXT NOT NULL DEFAULT '';
ALTER TABLE orders ADD COLUMN postal_code TEXT NOT NULL DEFAULT '';
ALTER TABLE orders ADD COLUMN payment_reference TEXT NOT NULL DEFAULT '';
ALTER TABLE orders ADD COLUMN saved_address_id INTEGER;
CREATE TABLE IF NOT EXISTS customer_addresses (id INTEGER PRIMARY KEY AUTOINCREMENT,customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE CASCADE,recipient_name TEXT NOT NULL,phone TEXT NOT NULL,address_line TEXT NOT NULL,city TEXT NOT NULL,province TEXT NOT NULL,postal_code TEXT NOT NULL DEFAULT '',is_default INTEGER NOT NULL DEFAULT 0,created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE INDEX IF NOT EXISTS idx_customer_addresses_customer ON customer_addresses(customer_id,is_default DESC,id DESC);
CREATE TABLE IF NOT EXISTS coupons (id INTEGER PRIMARY KEY AUTOINCREMENT,code TEXT NOT NULL UNIQUE COLLATE NOCASE,discount_type TEXT NOT NULL CHECK(discount_type IN ('percent','fixed')),discount_value REAL NOT NULL CHECK(discount_value>0),min_order REAL NOT NULL DEFAULT 0,max_discount REAL,usage_limit INTEGER,usage_count INTEGER NOT NULL DEFAULT 0,starts_at TEXT,expires_at TEXT,is_active INTEGER NOT NULL DEFAULT 1,created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
CREATE INDEX IF NOT EXISTS idx_coupons_active_code ON coupons(code,is_active);
CREATE TABLE IF NOT EXISTS store_settings (setting_key TEXT PRIMARY KEY,setting_value TEXT NOT NULL DEFAULT '',updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP);
INSERT OR IGNORE INTO store_settings(setting_key,setting_value) VALUES ('shipping_fee','200'),('free_shipping_threshold','5000'),('payment_jazzcash',''),('payment_easypaisa',''),('payment_bank_transfer','');