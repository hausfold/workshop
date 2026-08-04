# hausfold.co

A placeholder page. One `index.html` that says **hausfold**, served on
[hausfold.co](https://hausfold.co) (and `www.`) by a static-assets-only
Cloudflare Worker. No build step, no framework, no JS — `wrangler deploy`
uploads `public/` and Cloudflare serves it.

Every path returns the same page (`not_found_handling = "single-page-application"`),
so nothing 404s while the real site doesn't exist yet.

[`PRESENCE.md`](./PRESENCE.md) is the register of every account, handle and
namespace claimed under the hausfold name — what we hold, what's still a gap,
and which channel to reach for when there's something to announce.

## Deploy

```sh
cd hausfold && npx wrangler deploy     # nixpkgs' wrangler fails to build — use npx
```

There is deliberately **no CI workflow** for this, unlike `web/`. It's one static
file that changes approximately never, and the repo's existing
`CLOUDFLARE_API_TOKEN` secret is scoped for the `nebelhaus.com` zone — pointing it
at a second zone's DNS is more setup than the thing is worth. Deploy by hand; if
hausfold grows into a real site, it earns its own repo and its own pipeline.

## Why `custom_domain` and not a route

The `hausfold.co` zone had no DNS records at all. A plain Workers route
(`hausfold.co/*`) needs a proxied record to already exist for the hostname;
`custom_domain = true` makes wrangler create and proxy that record itself.

## Watch-out

**Always Use HTTPS is on** for this zone, so `http://hausfold.co/` 301s to
`https://` (same for `www.`). That's a Cloudflare dashboard setting
(SSL/TLS → Edge Certificates), not something this config carries — if the
redirect ever disappears, look there first, not here.
