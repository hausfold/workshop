# nebelhaus.com — the 301 map

This zone is a redirect and nothing else. Every page it used to serve was
rebuilt on **[hausfold.co](https://hausfold.co)** (rename plan
[§5.2](../notes/hausfold-rename.md)), and one Cloudflare Worker now answers the
whole domain with permanent redirects:

| Old URL | Where it goes |
|---|---|
| `/` | `hausfold.co/` |
| `/pounce`, `/perch` | the product pages there |
| `/start/*`, `/guides/*`, `/reference/*`, `/internals/*`, `/writing/*` | the rebuilt page in `hausfold.co/docs/*` — **one row each**, because the docs were reorganised into rooms on the way |
| `/init.sh` | `hausfold.co/nebelhaus.sh` |
| `/download/<app>`, `/api/release/<app>` | the same routes there |
| anything else | `404` |

```sh
curl -sI https://nebelhaus.com/guides/pounce
# 301 → https://hausfold.co/docs/haus/rooms/launcher/
```

The map is [`worker.js`](./worker.js) and it is the whole site. There is no
build, no `[assets]` binding, no Astro, no Starlight — deleting that tree is
what ended the two-live-copies-of-every-docs-page problem, and its history is
one `git log -- web/src` away if you need a sentence back.

## Why a Worker and not `_redirects`

Cloudflare's static-assets redirect file is the obvious tool and it needs an
assets binding to run — which means keeping a build whose only output is the
file that says the build is gone. A route-less Worker is 160 lines with a unit
suite, and it gives the one behaviour `_redirects` can't: **query strings
survive**, so a shell history holding `/init.sh?ref=v2026.08.13` still pins that
ref on the other side. (Use a tag that exists when you demo this — a well-formed
ref that isn't a release comes back **502**, not 404, from the other side, which
reads exactly like a broken redirect. `?ref=v2026.07.18`, this line's example
until 2026-08-14, was never a haus tag.)

## The map itself

`REDIRECTS` is keyed by normalized path — lowercased, no trailing slash — so
both spellings of every URL resolve. That normalization is load-bearing now: the
`[assets]` binding used to 307 `/guides/pounce` onto `/guides/pounce/` before the
Worker ever saw it, and it is gone.

Each row was composed from two records rather than guessed from an old build:
the rename plan's **source ledger** (which source page became which new page)
and hausfold.co's **`public/_redirects`** (where the 2026-08-14 rooms
reorganisation then moved it). Rows point at the *current* URL, so a visitor
never pays for that history with a second hop — verified by curling all 31
destinations for a `200`.

Two rows are worth knowing because they are the ones a later reader will
"correct" wrongly:

- `/start/what-is-nebelhaus` → `/docs/nebelhaus/`, the **desktop** tree's index.
  Not `/docs/haus/`. The docs are two trees now.
- `/guides/ai-agent` → `rooms/agent-rebuilds/` and `/guides/claude-agents` →
  `rooms/ai/`. The titles read the other way round; the content doesn't.

## Test

```sh
cd web
nix shell nixpkgs#nodejs_22 --command npm ci
nix shell nixpkgs#nodejs_22 --command npm test
```

The suite's spine is `OLD_URLS` — every URL nebelhaus.com ever published. The
site that served them is deleted, so that list can never grow, which makes it a
completeness gate rather than a second copy of the map: drop a row and it fails.

Feel it for real with the local runtime, which catches what a unit test can't
(the config, the runtime's own URL handling):

```sh
nix shell nixpkgs#nodejs_22 --command 'npx wrangler dev --port 8879 --local'
curl -sI http://127.0.0.1:8879/guides/pounce
```

## Deploy

The `nebelhaus.com` zone must be on the logged-in Cloudflare account.

```sh
cd web
nix shell nixpkgs#nodejs_22 --command 'npx wrangler login'    # once, opens a browser
nix shell nixpkgs#nodejs_22 --command 'npx wrangler deploy'
```

> The nixpkgs `wrangler` currently fails to build from source on this machine, so
> use node's `npx wrangler` rather than `nix run nixpkgs#wrangler`.

Pushing to `main` (touching `web/**`) auto-deploys via
`.github/workflows/deploy-web.yml`, which also **purges the Cloudflare cache**.
That purge matters more here than it did for the site: redirects go out with
`max-age=31536000`, and Cloudflare edge-caches 404s too, so a wrong row would
otherwise stick at whichever colo saw it first.

Pull requests touching `web/**` get a route-less preview Worker from
`.github/workflows/preview-web.yml` — `curl -sI <preview>/guides/pounce` is the
whole review. It never moves the Worker on the `nebelhaus.com` route:
`wrangler.preview.toml` carries no route, and since that file is read from the
PR's own head commit, a guard step fails the job if one reappears (in any TOML
spelling). Treat it as accident-prevention, not a security boundary — a same-repo
PR edits the workflow too. The boundary is the fork check: Cloudflare secrets are
unavailable to forked pull requests.

Closing the PR deletes the Worker with one `DELETE
/accounts/:id/workers/scripts/:name` call rather than `wrangler delete`, which
also sweeps a legacy Workers Sites KV namespace and needs a KV scope nothing
else here wants (in `hausfold/hausfold.co` that sweep 403s and turns a
*completed* delete into a red job). A close whose Worker was already gone is a
warning, not a failure — it used to be one, for `nebelhaus-pr-216`. Orphans are
still possible when the `closed` event fires no run at all; if a preview URL
outlives its PR, check whether the run exists before suspecting the step.

## Trust

The old Worker **proxied** `bootstrap.sh` for `curl | bash`, and that is exactly
why this one fetches nothing. The assurance pass on hausfold.co's port found the
hole: a 40-hex commit SHA passes the old `SAFE_REF`, and `raw.githubusercontent.com`
serves any object in a public repo's **fork network** — so a stranger could get a
commit into `hausfold/haus`'s network with a fork PR and hand out
`nebelhaus.com/init.sh?ref=<sha>`: our domain, our TLS, no visible redirect,
their script. hausfold.co closed it by holding `?ref=` to the release-tag shape.
This zone closes it by deletion — there is no fetch left to poison. The `?ref=`
it forwards is checked on arrival, where the check belongs.

Measured end to end on 2026-08-14, which is the only kind of proof this
paragraph is worth:

```sh
curl -sIL 'https://nebelhaus.com/init.sh?ref=v2026.08.14-2'   # 301 → 200, a release still pins
curl -sIL 'https://nebelhaus.com/init.sh?ref=<40-hex sha>'    # 301 → 400, refused on arrival
```

> ⚠️ **It was true here a day before it was true of the zone.** `/init.sh` did
> not reach this Worker at all: the installer's *first* deployment was a
> separate script, `nebelhaus-init`, holding the more specific route
> `nebelhaus.com/init.sh*` — and a route belongs to the script that declared it,
> so the rename never reclaimed it. It quietly served the old proxy, arbitrary
> 40-hex ref and all, until `npx wrangler delete --name nebelhaus-init` on the
> account. Rename plan [§5.3](../notes/hausfold-rename.md) has the whole finding.
> The lesson is one line long: **a config file describes the deployment it wants,
> and nothing in this repo enumerates the one that exists.** Curl the zone.

## When this can be turned off

Not soon, and not on a schedule: the one-liner is in READMEs, shell histories
and anything anyone bookmarked. The zone costs a Worker with no build. Retire it
only when the redirect logs go quiet, and the `nebelhaus` **desktop** keeps its
name either way (rename plan §6) — this is the domain retiring, not the desktop.
