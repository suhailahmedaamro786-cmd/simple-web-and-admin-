-- SK Store Phase 1: multi-product catalog foundation.
-- Existing product #1 and existing orders are preserved.
CREATE TABLE IF NOT EXISTS categories (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  slug TEXT NOT NULL UNIQUE,
  description TEXT NOT NULL DEFAULT '',
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT OR IGNORE INTO categories (name,slug) VALUES
('Electronics','electronics'),
('Home & Living','home-living'),
('Fashion','fashion'),
('Office & Study','office-study'),
('Beauty & Personal Care','beauty-personal-care'),
('Sports & Fitness','sports-fitness'),
('Accessories','accessories'),
('Other','other');
CREATE TABLE IF NOT EXISTS products_v2 (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  sku TEXT NOT NULL DEFAULT '',
  category_id INTEGER REFERENCES categories(id),
  price REAL NOT NULL DEFAULT 0,
  compare_price REAL NOT NULL DEFAULT 0,
  cost_price REAL NOT NULL DEFAULT 0,
  stock INTEGER NOT NULL DEFAULT 0,
  description TEXT NOT NULL DEFAULT '',
  image_url TEXT NOT NULL DEFAULT '',
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);
INSERT INTO products_v2 (id,name,slug,price,description,image_url,stock,is_active)
SELECT id,name,'everyday-essential-product',price,description,image_url,0,1 FROM products WHERE id=1;
DROP TABLE products;
ALTER TABLE products_v2 RENAME TO products;
ALTER TABLE orders ADD COLUMN product_id INTEGER;
ALTER TABLE orders ADD COLUMN product_name TEXT NOT NULL DEFAULT '';
ALTER TABLE orders ADD COLUMN unit_price REAL NOT NULL DEFAULT 0;
ALTER TABLE orders ADD COLUMN total_amount REAL NOT NULL DEFAULT 0;
ALTER TABLE orders ADD COLUMN payment_method TEXT NOT NULL DEFAULT 'COD';
ALTER TABLE orders ADD COLUMN payment_status TEXT NOT NULL DEFAULT 'Pending';
