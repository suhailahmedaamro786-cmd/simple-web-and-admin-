# SK Product Store

A simple single-product storefront with a password-protected admin dashboard, built for Cloudflare Workers + D1.

## Features
- Public product page and customer order form
- Admin sign-in with HttpOnly, Secure, SameSite session cookie
- Edit product name, price, description and image URL
- View orders, update order status, and delete orders
- Cloudflare D1 database; no Supabase or third-party payment API

## Deploy to Cloudflare

1. Create a D1 database named `sk-product-store-db`.
2. Replace `REPLACE_WITH_D1_DATABASE_ID` in `wrangler.toml` with its ID.
3. Apply the schema: `npx wrangler d1 migrations apply sk-product-store-db --remote`.
4. Set secrets (never commit them):
   - `npx wrangler secret put ADMIN_PASSWORD`
   - `npx wrangler secret put SESSION_SECRET` (use a long random value)
5. Deploy: `npx wrangler deploy`.
6. Open the Worker URL. Storefront is at `/`; admin is at `/admin.html`.

The sample product can be edited from the admin dashboard. Keep admin credentials private and rotate the password before accepting real customer orders.
