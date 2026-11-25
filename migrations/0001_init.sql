CREATE TABLE IF NOT EXISTS products (
  id INTEGER PRIMARY KEY CHECK (id = 1),
  name TEXT NOT NULL,
  price REAL NOT NULL,
  description TEXT NOT NULL DEFAULT '',
  image_url TEXT NOT NULL DEFAULT '',
  updated_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_name TEXT NOT NULL,
  phone TEXT NOT NULL,
  email TEXT NOT NULL DEFAULT '',
  quantity INTEGER NOT NULL DEFAULT 1,
  address TEXT NOT NULL,
  note TEXT NOT NULL DEFAULT '',
  status TEXT NOT NULL DEFAULT 'New',
  created_at TEXT NOT NULL DEFAULT CURRENT_TIMESTAMP
);

INSERT OR IGNORE INTO products (id, name, price, description, image_url)
VALUES (1, 'Everyday Essential Product', 2499, 'A simple sample product. Update the details from your admin dashboard.', 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=1000');
