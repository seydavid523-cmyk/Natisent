# Natis Phone Ent — no-install static website

## Run it
- Open `index.html` directly in Chrome, Edge, Firefox, or another modern browser.
- No Node.js, npm, terminal, server, or build step is needed to view the storefront.
- Internet is needed for product images and WhatsApp links.

## Included
- Responsive storefront layout
- Search and brand filtering
- Admin option to mark products as latest and show them first in the catalog
- Optional product discounts by percentage or sale price, shown on the storefront and applied to new cart items
- Admin catalog sync merges the current draft with the latest Supabase products and upserts without deleting existing rows
- Scheduled storefront campaigns for Black Friday, Black Saturday, Black Monday, or a custom event
- Installable PWA manifest, Natis icon, and app-shell service worker
- Admin product type selection for phones and laptops, with storefront filters
- Optional GSMArena image search when adding a product without an image
- Product catalog copied from the existing Natis project catalog
- Bundled Supabase catalog snapshot in `catalog-data.js`, used when live Supabase is unavailable
- Customer cart snapshots stored in Supabase when configured
- Checkout requests stored in Supabase before opening WhatsApp at +233 555 016 982

## Important limitations
This is the static/no-build edition. Supabase must be configured before checkout requests, customer carts, or scheduled campaigns are shared with visitors. Checkout stores a pending order, then opens WhatsApp for confirmation; it does not charge a customer or verify payment. Customer details and carts are protected by Supabase row-level security. Phone listings with confirmed model matches use GSMArena image URLs and require an internet connection. Custom product image paths override the model image. Confirm prices and stock with the shop before accepting an order.

## Configure Supabase
1. Create a Supabase project.
2. The configured project already exposes `public.catalog_products`. Check your Supabase schema before running any SQL; the repository setup script also changes security policies and should not be run blindly.
3. In Authentication settings, enable anonymous sign-ins and email/password sign-ins.
4. Open `supabase-config.js` and set `url` and `anonKey` from the project's API settings. The publishable/anon key is intended for browser use; never put a service-role key in this file.
5. Create an admin user in Supabase Authentication. In the SQL Editor, replace the example email and run `update auth.users set raw_app_meta_data = coalesce(raw_app_meta_data, '{}'::jsonb) || '{"role":"admin"}'::jsonb where email = 'admin@example.com';`. The admin panel at `/admin/` accepts only users with this role.
6. Host the site over HTTP/HTTPS and add its URL to Supabase Auth's allowed site/redirect URLs. Direct `file://` use cannot reliably complete Supabase authentication.
7. Create any missing order/cart tables or image bucket only after reviewing the schema and policies with your Supabase administrator.
8. To enable scheduled campaigns, review and run the focused migration in `../supabase/store-campaigns.sql`. It creates a public-readable active campaign record and restricts writes to Supabase admins. Until that table exists, campaign saves will report a setup error.

The customer checkout stores the name, phone, delivery area, notes, items, count, and estimated total. Admins can view up to 200 recent orders and non-empty carts, and update order status. This remains an order-request workflow, not payment processing. Paystack is not connected; orders remain pending and no payment credentials or card data are collected.

Products load from Supabase when the `catalog_products` table contains published rows, with `catalog-data.js` used as the current bundled fallback if Supabase is empty or unavailable. Refresh the deploy snapshot from the project root with `npm run catalog:sync`; the command writes the latest publicly visible products to `backup-static-site/catalog-data.js`. Admin product changes publish to `catalog_products`; deleting a product removes only its selected row. Add a product type (phone or laptop) in the admin form, then filter the storefront catalog by type. Admins can optionally add a percentage discount or set a discounted sale price; the storefront shows the regular and discounted prices, and new cart items use the discounted amount. When adding a product without an image, the admin opens a GSMArena search for the product name and pastes a direct image URL; image retrieval is manual because GSMArena does not provide an automatic lookup API. Uploaded product photos are stored in the public `product-images` bucket; only authenticated admins can upload, replace, or delete files. Only JPEG, PNG, and WebP files up to 5 MB are accepted.

## Editing
Edit `index.html` in VS Code. The HTML, CSS, product data, and JavaScript are in that one file. Keep a backup before making changes.


## Add your own product images
1. Sign in to the Admin panel with the Supabase admin account.
2. Open a product form and choose a JPEG, PNG, or WebP image up to 5 MB. Supabase Storage uploads it and the resulting public URL is saved with the product.
3. Or set a product image path/URL manually. A custom image overrides the default model image.

The bundled catalog snapshot was last refreshed with 105 storefront-visible product records.


ADMIN PANEL
1. Open your shop URL and add `/admin/` to the end of the address.
2. Sign in with the Supabase admin user's email and password.
3. View orders, customer details, requested products, item counts, and non-empty carts. Update order status from the order list.
4. Product edits publish to Supabase; exports and imports are performed in the browser. Order and cart data are stored in Supabase.
