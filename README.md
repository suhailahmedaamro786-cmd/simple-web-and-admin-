# SK Store

A responsive multi-product general-store storefront and private admin dashboard built with Cloudflare Workers and D1.

## Current features
- Green-and-white responsive storefront
- Product catalogue with category filters and search
- Shopping cart and checkout
- Cash on Delivery, JazzCash, Easypaisa and bank-transfer manual payment choices
- Server-side price calculation from D1 product records
- Admin sign-in using HttpOnly, Secure, SameSite session cookies
- Product create, edit and soft-delete; SKU, category, price, compare price, stock, image and description
- Order list and order-status management
- Existing customer orders retained during the catalogue migration

## Inventory behavior
A stock value of 0 means inventory is not being tracked (unlimited). A positive stock value is checked and decremented when an order is placed. Set a positive value in Admin when stock tracking is required.

## Cloudflare resources
- Worker: `sk-product-store`
- D1 binding: `DB`
- Database: `sk-product-store-db`
- Migration history: `migrations/`

## Deploy
1. Install Wrangler and authenticate with `npx wrangler login`.
2. Ensure `wrangler.toml` references the correct D1 database ID.
3. Apply pending migrations with `npx wrangler d1 migrations apply sk-product-store-db --remote`. Do not manually re-run already-applied migrations.
4. Set `ADMIN_PASSWORD` and `SESSION_SECRET` using Wrangler secrets; never commit secret values.
5. Deploy with `npx wrangler deploy`.

The Worker embeds its static storefront assets in `src/index.js`. When changing files in `public/`, update the corresponding `STATIC_ASSETS` entries in `src/index.js` as well before deployment.


## Phase 2: customer accounts
- Customer email/password sign-up, sign-in, sign-out and account profile.
- Passwords use salted PBKDF2-SHA-256 (310,000 iterations); raw passwords are never stored.
- Signed HttpOnly Secure SameSite cookie sessions, with a seven-day expiry.
- Customers can view only their own order history. Orders placed while signed in are linked to that customer; guest checkout remains available.
- Basic per-email failed-login throttling. Email verification and password reset are not configured because no email delivery provider is connected.
