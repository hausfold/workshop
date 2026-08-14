# nebelhaus.com — the landing page, docs, and install front door

One Cloudflare Worker serves all of `nebelhaus.com`:

| Path | What | Source |
|---|---|---|
| `/` | the landing page | `src/pages/index.astro` (custom Astro page) |
| `/start`, `/guides`, `/reference`, `/internals` | the docs | Astro **Starlight** (`src/content/docs/`) |
| `/init.sh` | the install one-liner | `worker.js` (proxies the rice's `bootstrap.sh`) |
| `/download/<app>` | 302 to the latest notarized macOS release artifact (pounce and perch; only perch shows it as a landing button — pounce's tarball still assumes Homebrew lays it out) | `worker.js` |
| `/api/release/<app>` | JSON release metadata (tag, asset, size) for the latest notarized artifact | `worker.js` |

```sh
curl -fsSL https://nebelhaus.com/init.sh | bash
```

> ⚠️ **That is no longer the canonical install URL, and this is no longer the
> canonical copy of these pages.** Since 2026-08-14 hausfold.co serves the
> one-liner itself — `curl -fsSL https://hausfold.co/nebelhaus.sh | bash` —
> from its own port of this Worker, and every docs page here has a rebuilt
> equivalent under `hausfold.co/docs`. Both sites work, which is the problem:
> **a fact fixed in one tree and not the other will disagree.** This site's
> remaining job is to become the `nebelhaus.com/*` → `hausfold.co/*` 301 map
> (rename plan §5.2), after which `/init.sh` redirects to `/nebelhaus.sh`.
> Until then, fix a fact in both trees or in neither.

The site is a static [Astro](https://astro.build) build (Starlight for docs, a
hand-rolled landing page). It's served by Cloudflare's `[assets]` binding.
`worker.js` handles `/init.sh`, `/download/*`, and `/api/release/*`; everything
else is a static asset. 404s render Starlight's own 404 page.

## Develop

Node isn't global on this Nix box — get it via nix:

```sh
cd web
nix shell nixpkgs#nodejs_22 --command npm install
nix shell nixpkgs#nodejs_22 --command npm run dev      # http://localhost:4321
```

Content lives in `src/content/docs/` (Markdown/MDX). The sidebar is defined in
`astro.config.mjs`. The landing page is `src/pages/index.astro`. Colours are the
[nebelung](https://github.com/hausfold/nebelung) palette, applied to Starlight
in `src/styles/nebelung.css` and inline on the landing page.

## The `/init.sh` proxy

`worker.js` **proxies** (not redirects) the rice's `bootstrap.sh`, served as
`text/plain`, so the pretty URL is what `curl` sees. By default it serves the
**latest GitHub release tag** of `hausfold/haus` (cached ~1h), falling back
to `main` before the first release exists. Pin an exact one with
`?ref=v2026.07.18` (releases are date-tagged), or hard-pin for everyone via the
`REF` var in `wrangler.toml`.

## Deploy

The `nebelhaus.com` zone must be on the logged-in Cloudflare account. Build the
static site first, then deploy the Worker (which uploads `dist/` as assets):

```sh
cd web
nix shell nixpkgs#nodejs_22 --command npm ci
nix shell nixpkgs#nodejs_22 --command npm run build
nix shell nixpkgs#nodejs_22 --command 'npx wrangler login'    # once, opens a browser
nix shell nixpkgs#nodejs_22 --command 'npx wrangler deploy'
```

Validate config without deploying:

```sh
nix shell nixpkgs#nodejs_22 --command 'npx wrangler deploy --dry-run'
```

> The nixpkgs `wrangler` currently fails to build from source on this machine, so
> use node's `npx wrangler` (shown above) rather than `nix run nixpkgs#wrangler`.

Pushing to `main` (touching `web/**`) auto-deploys via
`.github/workflows/deploy-web.yml`, which also **purges the Cloudflare cache**
after each deploy — belt-and-suspenders on top of the caching policy below.

Pull requests that touch `web/**` get a live staging link from
`.github/workflows/preview-web.yml`. The workflow builds and tests the site,
deploys an isolated, route-less Worker named `nebelhaus-pr-<number>`, and puts
its stable `workers.dev` URL in GitHub's deployment panel and the job summary.
It never moves the Worker serving the `nebelhaus.com` route: `wrangler.preview.toml`
carries no route, and since that file is read from the PR's own head commit, a
guard step fails the job if one reappears in it (in any TOML form). Treat the
guard as accident-prevention, not a security boundary — a same-repo PR edits the
workflow too. The boundary is the fork check: Cloudflare secrets are unavailable
to forked pull requests, so previews run only for branches in this repository.

Closing the PR deletes the Worker, via one `DELETE
/accounts/:id/workers/scripts/:name` call rather than `wrangler delete`. Two
reasons. `wrangler delete` also sweeps a legacy Workers Sites KV namespace,
needing a KV scope nothing else here wants — in `hausfold/hausfold.co`, which runs
the same workflow against its own token, that sweep 403s and turns a *completed*
delete into a red job. And a close whose Worker was already gone used to fail
outright (it did, for `nebelhaus-pr-216`); "no such Worker" is now a warning.

Orphans are still possible when the `closed` event never fires a run at all —
`nebelhaus-pr-84` sat on the account from July until it was deleted by hand,
with no cleanup run for its branch. If a preview URL outlives its PR, check
whether the run exists before suspecting this step.

### Gotcha: stale HTML → a since-deleted stylesheet → "no CSS" (esp. on iOS)

Astro used to fingerprint the whole stylesheet into `/_astro/index.<hash>.css`
and **every page — the landing page and every Starlight doc — linked exactly one
hashed stylesheet with no inline fallback.** The hash changes whenever the
bundled CSS changes, so each deploy published a *new* filename and deleted the
old one.

That meant a browser holding a **stale cached HTML document** was holding a
`<link>` to an `/_astro/<oldhash>.css` that no longer existed → the stylesheet
404s → the page renders as raw, unstyled HTML, with no code change since the
last deploy. iOS WebKit (Safari **and** every WKWebView — the Instagram /
Facebook in-app browsers) caches top-level HTML *heuristically* and far more
aggressively than desktop Chrome/Firefox, so it took the hit first and hardest.
Purging Cloudflare's **edge** cache never touched those **client-side** caches,
and `must-revalidate` HTML only helps if the client actually honors it — iOS
WebViews demonstrably don't always — which is why the bug kept coming back after
"fixes."

**The durable fix is `build.inlineStylesheets: 'always'` in
[`astro.config.mjs`](./astro.config.mjs).** Astro inlines the bundled CSS into
each page's `<head>`, so there is **no external main stylesheet to 404** — the
styles travel with the document, and even a stale HTML page renders fully styled
without fetching anything. It sidesteps the whole bug class: rendering no longer
depends on any cache header being honored by any client. (`test/inline-css.test.js`
fails loudly if the setting is ever dropped or weakened to `'auto'`.) The only
external CSS left on doc pages is Expressive Code's `ec.v<version>.css` — a
*stable*, non-per-deploy filename that isn't deleted on each build — and a
`media="print"` sheet, which can't affect on-screen rendering.

[`public/_headers`](./public/_headers) stays as belt-and-suspenders: HTML is
served `max-age=0, must-revalidate` and `/_astro/*` stays `immutable`, which
keeps hashed **JS** fresh (a stale script 404 degrades interactivity, e.g. the
copy button, without unstyling the page). (Watch the merge gotcha documented in
that file — an `/_astro` asset matches both rules, and wrangler *appends*
duplicate `Cache-Control` values, so the `/_astro/*` rule must `! Cache-Control`
first. `test/headers.test.js` guards all of this.) The post-deploy **cache
purge** in `deploy-web.yml` (needs the `CLOUDFLARE_ZONE_ID` secret + Zone → Cache
Purge on the token) stays as a secondary guard against a transient mid-deploy 404
cached at an edge colo.

### Gotcha: images broken *only* in the Instagram / Facebook in-app browser

Sibling of the above, opposite cause. The logos (`/logos/*`), doc stills
(`/media/*`), social card (`/social/*`) and favicon live at **stable, non-hashed
paths** and are pulled by `<img>`. The `_headers` `/*` catch-all would give them
`max-age=0, must-revalidate` too — forcing the browser to **revalidate every
image on every load**. Instagram's and Facebook's in-app WebViews are
memory-constrained and evict cached image *bodies* aggressively; when they
revalidate and the origin returns `304 Not Modified` with the body already gone,
the `<img>` renders as a broken-image glyph. Safari keeps the bodies, so it never
hits this — which is why it only shows up in the in-app browser (and only became
visible once the CSS was inlined and images were the last external subresource).

The fix is a per-directory rule in [`public/_headers`](./public/_headers) giving
those images a plain, finite `max-age` (a week) with **no `must-revalidate`**, so
the WebView serves them straight from cache and never does the fragile 304 dance.
Finite rather than `immutable` so a changed logo still self-heals; each rule
`! Cache-Control`-unsets the `/*` value first (same merge gotcha as `/_astro/*`).
`src/pages/index.astro` also appends a `?v=` query to the logo `<img>` srcs — a
one-time bust that hands already-poisoned in-app caches a fresh URL. All guarded
by `test/headers.test.js`.

To clear a stuck page by hand: Cloudflare dash → Caching → Configuration →
**Purge Everything**, or a hard reload for a browser-only stale copy. To confirm
the origin is healthy, grab a stylesheet URL from a live page and fetch it —
expect `200` and `content-type: text/css`:

```sh
css=$(curl -s https://nebelhaus.com/ | grep -o '/_astro/[^"]*\.css' | head -1)
curl -sI "https://nebelhaus.com${css}"
```

## On a release

`bench release haus` date-stamps `VERSION` and tags `v<date>`; CI publishes
the GitHub release. The
Worker picks up the new tag for `/init.sh` within the cache hour — **the script
needs no redeploy**. The *site* only changes when you rebuild and redeploy it.

## Verify it's live

```sh
curl -fsSL https://nebelhaus.com/init.sh | head -5
curl -sI  https://nebelhaus.com/init.sh | grep -i x-nebelhaus-ref   # which ref served
curl -fsSL 'https://nebelhaus.com/init.sh?ref=v2026.07.18' | head -2  # exact pin
curl -sI  https://nebelhaus.com/ | head -1                          # site is up
```

## Trust

`curl | bash` runs whatever this serves, so `/init.sh` stays boring and readable:
it only proxies `bootstrap.sh` from this org's own repo. A Cloudflare/domain
compromise would mean arbitrary code on installers' Macs — inherent to any
`curl | bash`. Wary users can read the script first (drop the `| bash`) or pin a
`?ref=` tag and verify it against GitHub.

## Adding docs

- New page: drop a `.md`/`.mdx` file in `src/content/docs/<section>/`, add
  frontmatter (`title`, `description`), and add it to the `sidebar` in
  `astro.config.mjs`.
- Screenshots/video: the family's shot list lives in `../assets/SHOTLIST.md`.
  Slots on the landing page and feature pages are ready for hero stills and
  clips once they're captured.
