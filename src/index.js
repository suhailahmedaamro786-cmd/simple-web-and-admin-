const COOKIE = "sk_admin_session";
const encoder = new TextEncoder();

function json(data, status = 200) {
  return new Response(JSON.stringify(data), { status, headers: { "content-type": "application/json; charset=utf-8", "cache-control": "no-store" } });
}
function cookieValue(request, name) {
  const part = (request.headers.get("Cookie") || "").split(";").map(v => v.trim()).find(v => v.startsWith(name + "="));
  return part ? decodeURIComponent(part.slice(name.length + 1)) : "";
}
function toBase64Url(bytes) {
  let binary = "";
  for (const b of new Uint8Array(bytes)) binary += String.fromCharCode(b);
  return btoa(binary).replace(/=/g, "").replace(/\+/g, "-").replace(/\//g, "_");
}
function fromBase64Url(value) {
  const base = value.replace(/-/g, "+").replace(/_/g, "/");
  const binary = atob(base + "=".repeat((4 - base.length % 4) % 4));
  return Uint8Array.from(binary, c => c.charCodeAt(0));
}
async function sign(value, secret) {
  const key = await crypto.subtle.importKey("raw", encoder.encode(secret), { name: "HMAC", hash: "SHA-256" }, false, ["sign"]);
  return toBase64Url(await crypto.subtle.sign("HMAC", key, encoder.encode(value)));
}
async function makeSession(secret) {
  const payload = toBase64Url(encoder.encode(JSON.stringify({ exp: Date.now() + 8 * 60 * 60 * 1000 })));
  return payload + "." + await sign(payload, secret);
}
async function isAdmin(request, env) {
  if (!env.SESSION_SECRET) return false;
  const token = cookieValue(request, COOKIE);
  const [payload, signature] = token.split(".");
  if (!payload || !signature) return false;
  const expected = await sign(payload, env.SESSION_SECRET);
  if (signature !== expected) return false;
  try { return JSON.parse(new TextDecoder().decode(fromBase64Url(payload))).exp > Date.now(); } catch { return false; }
}
function secureCookie(value, maxAge) {
  return `${COOKIE}=${encodeURIComponent(value)}; HttpOnly; Secure; SameSite=Strict; Path=/; Max-Age=${maxAge}`;
}
async function seed(env) {
  await env.DB.prepare("INSERT OR IGNORE INTO products (id,name,price,description,image_url) VALUES (1,?,?,?,?)")
    .bind("Everyday Essential Product", 2499, "A simple sample product. Update the details from your admin dashboard.", "https://images.unsplash.com/photo-1523275335684-37898b6baf30?w=1000").run();
}
async function handleApi(request, env) {
  const url = new URL(request.url);
  const path = url.pathname;
  const method = request.method;
  await seed(env);

  if (path === "/api/product" && method === "GET") {
    const product = await env.DB.prepare("SELECT * FROM products WHERE id=1").first();
    return json(product);
  }
  if (path === "/api/orders" && method === "POST") {
    const body = await request.json();
    const name = String(body.name || "").trim();
    const phone = String(body.phone || "").trim();
    const address = String(body.address || "").trim();
    const quantity = Math.max(1, Math.min(20, Number.parseInt(body.quantity, 10) || 1));
    if (name.length < 2 || phone.length < 7 || address.length < 5) return json({ error: "Please enter a valid name, phone and address." }, 400);
    if (name.length > 100 || phone.length > 30 || address.length > 500) return json({ error: "Some fields are too long." }, 400);
    const result = await env.DB.prepare("INSERT INTO orders (customer_name,phone,email,quantity,address,note) VALUES (?,?,?,?,?,?)")
      .bind(name, phone, String(body.email || "").slice(0,150), quantity, address, String(body.note || "").slice(0,500)).run();
    return json({ ok: true, orderId: result.meta.last_row_id }, 201);
  }
  if (path === "/api/admin/login" && method === "POST") {
    if (!env.ADMIN_PASSWORD || !env.SESSION_SECRET) return json({ error: "Admin secrets are not configured yet." }, 503);
    const body = await request.json();
    if (typeof body.password !== "string" || body.password !== env.ADMIN_PASSWORD) return json({ error: "Incorrect password." }, 401);
    const token = await makeSession(env.SESSION_SECRET);
    return new Response(JSON.stringify({ ok: true }), { headers: { "content-type": "application/json", "cache-control": "no-store", "set-cookie": secureCookie(token, 8 * 60 * 60) } });
  }
  if (path === "/api/admin/logout" && method === "POST") {
    return new Response(JSON.stringify({ ok: true }), { headers: { "content-type": "application/json", "set-cookie": secureCookie("", 0) } });
  }
  if (path.startsWith("/api/admin/")) {
    if (!(await isAdmin(request, env))) return json({ error: "Unauthorized" }, 401);
    if (path === "/api/admin/me" && method === "GET") return json({ ok: true });
    if (path === "/api/admin/product" && method === "PUT") {
      const body = await request.json();
      const name = String(body.name || "").trim();
      const price = Number(body.price);
      const description = String(body.description || "").trim();
      const imageUrl = String(body.image_url || "").trim();
      if (!name || name.length > 120 || !Number.isFinite(price) || price < 0 || price > 100000000 || description.length > 2000 || imageUrl.length > 1000) return json({ error: "Please check product fields." }, 400);
      await env.DB.prepare("UPDATE products SET name=?,price=?,description=?,image_url=?,updated_at=CURRENT_TIMESTAMP WHERE id=1").bind(name, price, description, imageUrl).run();
      return json({ ok: true });
    }
    if (path === "/api/admin/orders" && method === "GET") {
      const { results } = await env.DB.prepare("SELECT * FROM orders ORDER BY created_at DESC LIMIT 200").all();
      return json(results);
    }
    const orderMatch = path.match(/^\/api\/admin\/orders\/(\d+)$/);
    if (orderMatch && method === "PATCH") {
      const body = await request.json();
      const status = String(body.status || "");
      if (!["New", "Confirmed", "Shipped", "Completed", "Cancelled"].includes(status)) return json({ error: "Invalid order status." }, 400);
      await env.DB.prepare("UPDATE orders SET status=? WHERE id=?").bind(status, Number(orderMatch[1])).run();
      return json({ ok: true });
    }
    if (orderMatch && method === "DELETE") {
      await env.DB.prepare("DELETE FROM orders WHERE id=?").bind(Number(orderMatch[1])).run();
      return json({ ok: true });
    }
  }
  return json({ error: "Not found" }, 404);
}
export default {
  async fetch(request, env) {
    const url = new URL(request.url);
    if (url.pathname.startsWith("/api/")) {
      try { return await handleApi(request, env); }
      catch (error) { console.error("API error", error); return json({ error: "Something went wrong. Please try again." }, 500); }
    }
    return env.ASSETS.fetch(request);
  }
};
