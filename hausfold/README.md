# hausfold.co

The landing page for **hausfold** — the commercial umbrella behind the
[nebelhaus](https://github.com/nebelhaus) family. One `index.html`, served on
[hausfold.co](https://hausfold.co) (and `www.`) by a static-assets-only
Cloudflare Worker. No build step, no framework, no JS: `wrangler deploy` uploads
`public/` and Cloudflare serves it.

Every path returns the same page (`not_found_handling = "single-page-application"`),
so nothing 404s while the site is still one sheet.

[`PRESENCE.md`](./PRESENCE.md) is the register of every account, handle and
namespace claimed under the hausfold name — what we hold, what's still a gap,
and which channel to reach for when there's something to announce.

## Deploy

**CI does it.** [`.github/workflows/deploy.yml`](./.github/workflows/deploy.yml)
runs on every push to `main` that touches `public/`, `wrangler.toml` or the
workflow itself, and on demand via *Actions → Deploy hausfold.co → Run workflow*.
It needs three repo secrets — the workflow header lists them and the exact
Cloudflare permissions each one wants.

By hand, when you need it (an unpushed change, a broken token):

```sh
npx wrangler deploy      # nixpkgs' wrangler fails to build — use npx
```

That path uses your own `wrangler login` OAuth session, not the CI token.

## The page

`public/index.html` is the whole site: a self-contained document with its
palette, type and layout decisions written into the header comment. The short
version — nebelung's neutral ramp pushed one rung outward for contrast, no
accent colour anywhere, New York over SF Mono, and no motion. It's greyscale on
purpose: hausfold is the quiet house behind the products, not a sixth product
competing with them for attention.

Both themes are token-level: `prefers-color-scheme` carries the OS preference
and `:root[data-theme]` overrides it in both directions. Check both before
shipping a colour change.

## Why `custom_domain` and not a route

The `hausfold.co` zone had no DNS records at all. A plain Workers route
(`hausfold.co/*`) needs a proxied record to already exist for the hostname;
`custom_domain = true` makes wrangler create and proxy that record itself. This
is why the deploy token needs **Zone → DNS:Edit** and not just Workers scopes.

## Watch out

**Always Use HTTPS is on** for this zone, so `http://hausfold.co/` 301s to
`https://` (same for `www.`). That's a Cloudflare dashboard setting
(SSL/TLS → Edge Certificates), not something this config carries — if the
redirect ever disappears, look there first, not here.

**The page is one un-hashed `index.html`.** Nothing about its URL changes when
its contents do, so an edge cache can keep serving the old copy after a deploy.
That's what the workflow's purge step is for; without `CLOUDFLARE_ZONE_ID` set
it warns and skips, and your change lands whenever the edge feels like it.

## History

This repo was `hausfold/` inside
[nebelhaus/workshop](https://github.com/nebelhaus/workshop) until it was split
out with its history intact. It lives in the `hausfold` org, not `nebelhaus`,
because it isn't part of the product family — same reasoning that keeps
`PRESENCE.md`'s GitHub row saying nothing in that family belongs here.
