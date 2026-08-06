# AGENTS.md

**hausfold.co** — one static page on a Cloudflare Worker, plus the register of
every name claimed under the hausfold brand. This file is the one set of
instructions for every agent working here; [`README.md`](./README.md) covers how
the thing is built and deployed, and this file covers what you may change.

## What belongs here, and what doesn't

hausfold is the **commercial umbrella** — the entity that sells, the name on a
receipt, terms, refunds and press. It is deliberately *not* a product brand and
*not* the rice gallery.

| Want to change… | Where |
|---|---|
| the hausfold.co page — copy, design, the products it lists | here, `public/index.html` |
| a handle, an account, a claimed namespace | here, [`PRESENCE.md`](./PRESENCE.md) |
| anything about a **product** (nebelhaus, pounce, perch, nebelung, holt) | that product's own repo, under [github.com/nebelhaus](https://github.com/nebelhaus) |
| nebelhaus.com — docs, install one-liner, product pages | `web/` in [nebelhaus/workshop](https://github.com/nebelhaus/workshop) |
| the family's strategy notes (`go-to-market.md`, monetization) | `notes/` in the workshop |

**Nothing in the nebelhaus family may move into this org.** Not a product, not
the gallery, not holt. That rule is `PRESENCE.md`'s GitHub row and it's why this
repo exists apart from the family in the first place.

## The page

`public/index.html` is the entire site — a single self-contained document, no
build step, no dependencies. Its header comment carries the palette and type
decisions; read it before changing a colour.

Rules that are easy to break by accident:

- **Greyscale only.** No accent colour, in either theme. The restraint is the
  brand: hausfold is the quiet house behind the products, and a hue here would
  put it in competition with nebelung's palette.
- **No motion.** No load animation, no transitions. Removed on purpose.
- **Both themes, every time.** Colours are tokens on `:root`, redefined under
  `@media (prefers-color-scheme: dark)` and again under `:root[data-theme=…]`
  so a viewer's explicit toggle wins in both directions. Style through the
  tokens, never inside the media query.
- **No prices and no licences on the page.** Every product line is one clause
  and one link out. Pricing copy here would be a second place for perch's terms
  to drift from `notes/perch-monetization.md` in the workshop.
- **Links go outward.** The page indexes the products; it doesn't try to hold
  traffic. nebelhaus.com and GitHub are where each one actually lives.

## Deploying

Pushing to `main` deploys — the workflow fires on any change under `public/`.
There is no staging environment and no preview: **main is the live site.** Look
at your change in a browser first (`open public/index.html`; the file works
straight off disk), and check both themes.

`wrangler deploy` by hand uses your own OAuth session and is fine for a fix that
can't wait, but prefer the push — CI is what has the token with DNS:Edit, which
the `custom_domain` routes need.

## Shipping

Small changes — copy, a colour, a typo — commit and push; that ships them. It's
a one-page site with no users' machines downstream, so the blast radius of a bad
deploy is one `git revert` and a re-run.

Two things are **not** small, because they're positioning and not code:

- **Changing what the page claims hausfold is.** The maker-voice framing on the
  live page reversed an earlier decision (`notes/go-to-market.md` §6 in the
  workshop) that hausfold would stay a placeholder. Reversing it again is the
  user's call, not a copy edit.
- **Adding a product name that isn't real yet.** Anything named on this page
  should have a row in `PRESENCE.md` first — the domain, the org and the handles
  checked. Naming is the expensive kind of reversible.
