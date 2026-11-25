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
- Customers can view only their own order history. Checkout requires a customer session; placed orders are linked to that customer.
- Basic per-email failed-login throttling. Email verification and password reset are not configured because no email delivery provider is connected.


## Phase 3: product discovery
- Premium product cards with category labels, sale-price comparison and discount badges.
- Live search across product name, description, SKU and category.
- Category, price-range, sorting and inventory-mode filters.
- Product quick-view with image, description, SKU, category, price and availability.
- Persistent browser cart across page refreshes, quantity controls and cart totals.
- Public product data continues to load from D1; no fake catalogue items are inserted.

Inventory note: a stock value of `0` currently means untracked/unlimited inventory (not out of stock), matching the existing order API. Positive values are tracked and decremented on successful orders.


## Checkout account requirement
- Checkout now requires a valid customer session in both the storefront and the Worker API.
- Unauthenticated customers are directed to sign in or create an account before checkout.
- Signed-in customer name and email are prefilled from their account, and orders are linked to the authenticated customer ID.


## Phase 4: advanced checkout and payments
- Customer-owned saved delivery addresses with recipient, phone, street, city, province and postal code.
- Pakistan province/region selection and city field at checkout.
- Server-side quote and order totals from live D1 product prices; client-submitted prices and totals are ignored.
- Configurable flat delivery charge and free-delivery threshold.
- Coupon codes support percentage or fixed discounts, minimum order, maximum discount, date windows and usage limits.
- Manual JazzCash, Easypaisa and bank transfer instructions are configurable in the admin dashboard; payment references are stored with orders.
- Admin can independently update order fulfilment status and payment verification status (Pending, Verified, Rejected, Refunded).
- No online payment gateway is connected; manual payments remain Pending until an admin verifies them.
