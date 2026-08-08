# The hausfold rename — a walkthrough

Working doc, written 2026-08-08. **Separates `hausfold` (the platform, the org,
the seller) from `nebelhaus` (one rice built on it — the developer-focused
one, and the first).**

This is the walkable version: every step is tagged 👤 (you, at a keyboard or a
web console) or 🤖 (an agent, unattended), in dependency order, with a gate at
the end of each phase. Work it top to bottom. A phase that isn't gated green
does not unblock the next one.

**Read §0 before starting anything.** It contains the one deadline and the one
irreversible step.

---

## The decisions, already made

Taken 2026-08-08, in conversation. Recorded here so no later session re-opens
them:

| # | Decision | |
|---|---|---|
| 1 | Option namespace becomes **`haus.*`** | brand ≠ namespace, the nixos/nixpkgs pattern. `haus` is already the verb (`haus rebuild`/`set`/`doctor`/`rollback`). |
| 2 | **Transfer + rename in place** — `nebelhaus/nebelhaus` → `hausfold/hausfold` | keeps history, issues, PR links, git redirects. |
| 3 | **`hausfold.co`**, accept the `.co` | `hausfold.com` stays unbought; logged as accepted risk in §0.4. |
| 4 | **Rename now, neutralize defaults later** | the sweep is mechanical and provable; the rice carve-out is design work (§7). |
| 5 | **All Apple bundle IDs move to `com.hausfold.*`** | free today, impossible after an App Store record exists. |
| 6 | **All 8 repos transfer to the `hausfold` org** | plus the `holt-swift` mirror and the archived `trill`. |

### And these three reverse earlier written decisions

`go-to-market.md` §6 (decided 2026-08-04) and `hausfold/PRESENCE.md` currently
say the opposite. **They are read by every agent session**, so if they aren't
rewritten first, a future session will "correct" this work back:

- ~~"hausfold is the umbrella, not a product brand"~~ → hausfold **is** the
  platform (and still the seller).
- ~~"nothing in the nebelhaus family migrates to the hausfold org, ever"~~ →
  everything does.
- ~~"the gallery lives at nebelhaus.com/rices, not hausfold.co"~~ →
  `hausfold.co/market`.

One thing from §6 that survives and one that doesn't:

- ✅ *"funnels die at extra hops"* still holds — which is why nebelhaus.com
  **301s** to hausfold.co rather than merely coexisting.
- ❌ *"support stays support@nebelhaus.com, because people bought a nebelhaus
  product"* is now wrong: they buy a hausfold product. Support moves.

---

## §0 — Before anything moves

### 0.1 🤖 Rewrite the reversed decisions *first*

Before a single line of code. Otherwise every subsequent agent reads a note
that contradicts the work in front of it.

- `notes/go-to-market.md` — §1 portfolio table (hausfold row), §5 (the gallery
  question — where it lives), §6 (the whole section), §9 (open decisions 1 and 4).
- `hausfold/PRESENCE.md` — the "deliberately separate, nothing belongs here" rule.
- `notes/options-roadmap.md` — §7 repo routing, and a header note that
  `nebelhaus.*` is now `haus.*` throughout. **Don't rewrite the body**; it's a
  historical record and §5.14 is explicit about that. One banner at the top.
- `notes/perch-monetization.md` — the support-address line.

**Gate:** `grep -rn 'nothing in the family migrates\|not on hausfold.co' notes/ ../hausfold/`
returns nothing.

### 0.2 👤 Name clearance — 20 minutes, do it now

"hausfold" as an *umbrella* was low exposure. As a **platform with a market and
paid products**, it's a different check:

- USPTO TESS + EUIPO for "hausfold" in software classes (9/42).
- npm, crates.io, PyPI, Homebrew: is `hausfold` taken as a package name?
- GitHub: any `hausfold*` user/org squatting near you.
- A plain web search for an existing German/Austrian company using it.

**Gate:** nothing that would force a second rename. If something turns up, stop
here — this is the cheapest possible moment to pick a different name.

### 0.3 🤖 Drain the queue

**A namespace rename conflicts with every open branch.** Today the family has
exactly one open PR — that's the readiness signal, and it decays.

```sh
gh pr list --state open -R nebelhaus/workshop    # → #249 (flick) as of 2026-08-08
holt                                              # every live/parked worktree, all repos
~/code/workshop/bench status                      # dirty trees, unpushed, stale locks
```

- Merge or park workshop#249.
- `holt reap` anything already landed.
- `bench status` must show **no stale lock edge and no OFF-MAIN pin** before the
  sweep starts — a rename ripple on top of a stale lock is undebuggable.

**Gate:** `bench status` clean, zero open PRs, zero unmerged `worktree-*`
branches.

### 0.4 👤 hausfold.com — accepted risk, logged

Decision 3 accepts `.co`. Two consequences to hold consciously rather than
discover:

- The `.com` gets more expensive as the brand gains value, and this rename is
  the event that gives it value.
- The seller name appears on receipts and terms. `.co` reads second-tier there.

**Not a blocker.** But check the `.com` isn't parked by a squatter *today*, and
if it's ~$12, the argument for buying it is that this is the last time it's that
cheap. Re-log in `go-to-market.md` §9 as decided-accept rather than open.

### 0.5 👤 App Store Connect audit — **this is the deadline**

`perch` already has `IOS_DIST_CERT_P12` and `ASC_KEY_*` repo secrets (created
2026-08-07), so Apple-side work has started. **Apple never lets a bundle ID
change after an app record exists.**

Check, in [App Store Connect](https://appstoreconnect.apple.com) and the
[Developer portal](https://developer.apple.com/account/resources/identifiers):

- [ ] Is there an **App Record** for perch (iOS or macOS)? If yes — which bundle ID?
- [ ] Which **App IDs / Identifiers** are registered: `com.nebelhaus.perch`,
      `.ios`, `.ios.share`, `.mobile`?
- [ ] Is `group.com.nebelhaus.perch` a registered **App Group**?
- [ ] Any provisioning profiles bound to them?

**Gate:** if **no App Record exists**, Phase 4 proceeds as planned. If one
*does*, stop and escalate — you're choosing between a permanent
`com.nebelhaus.perch` and deleting/re-creating the app record, and that's a
decision, not a step.

---

## §1 — The namespace sweep: `nebelhaus.*` → `haus.*`

The technically hardest phase. ~44 option leaves, and per the family's own rule
(`options-roadmap.md` §7) a **breaking option rename couples the consumer's
lock-bump and config edit into one PR — `bench ship` can't split them without
breaking main mid-ripple.**

### 1.0 🤖 Spike first: can the rename be non-breaking? (~30 min)

If `lib.mkRenamedOptionModule` can carry the whole tree, the atomicity problem
**dissolves**: `haus.*` becomes real, `nebelhaus.*` becomes a warning-emitting
alias, main never breaks, and `~/.config/nix` bumps its lock whenever it likes.

```sh
# generate the leaf list from the artifact that already exists
cd nebelhaus && nix build .#options-json
# → modules/renamed.nix, one mkRenamedOptionModule per leaf, generated not typed
```

Two things the spike must actually prove, not assume:

1. Does it survive `types.attrsOf (submodule …)` — i.e. **`roster`** and
   **`workspaces`**? Renaming a whole attrset-of-submodules tree is where this
   mechanism usually breaks.
2. Does `nebelhaus.lib.checkRice` still work when a rice sets the *alias*? It
   asserts "touches only `nebelhaus.*`" today; that assertion has to become
   "only `haus.*`" and accept the alias during the transition.

**Verdict fork:**
- ✅ works → §1.1a, the easy path.
- ❌ doesn't → §1.1b, the atomic path. Costs one coordinated PR pair and a
  window where `~/.config/nix` can't rebuild until both land.

### 1.1a 🤖 Alias path (preferred)

1. `haus.*` becomes the canonical namespace in every `modules/*/options.nix`.
2. Generated `modules/renamed.nix` aliases the old tree, warning on use.
3. `presets/*.nix`, `packs/*.nix`, `hosts/example/default.nix` move to `haus.*`.
4. `checkRice` asserts `haus.*`.
5. `~/.config/nix/hosts/mbp/default.nix` moves to `haus.*` — 👤 **separately**,
   whenever, because the alias holds.
6. Aliases deleted in a follow-up PR **after** the last consumer moves.

### 1.1b 🤖+👤 Atomic path (fallback)

One PR in `hausfold/hausfold` renaming the tree with no alias, and one in
`~/.config/nix` rewriting the host file + bumping the lock, merged in that order
within the same sitting. Nothing else may be mid-ripple.

### 1.2 🤖 Prove it changed nothing

The house technique — §3.1 did exactly this and called it "byte-identical
derivation":

```sh
# BEFORE the sweep, on a clean tree
nix path-info --derivation .#darwinConfigurations.example.system > /tmp/before.drv
# AFTER
nix path-info --derivation .#darwinConfigurations.example.system > /tmp/after.drv
diff /tmp/before.drv /tmp/after.drv     # must be empty
```

Plus `nix flake check` (it evaluates a real system per preset) and the
options-drift CI.

**Gate:** derivation identical, `nix flake check` green, `bench try` builds.

---

## §2 — In-repo naming, docs, tooling

Pure text, ~250 files, but **not** a blind `sed`. Three distinct classes that a
single find-replace would conflate:

| Class | Rule |
|---|---|
| the **platform** (options, modules, the CLI, the docs' subject) | → `hausfold` / `haus.*` |
| the **rice** (presets, the desktop, the showcase, the grey) | stays **nebelhaus** |
| **historical record** (roadmap §5 bodies, PR titles, commit messages, `holt`'s `~/.cache/claude-worktrees/` path) | **leave alone** |

### 2.1 🤖 Per repo

- **hausfold** (was nebelhaus): `README.md`, `AGENTS.md`, `flake.nix`
  description, `modules/**`, `presets/**`, `packs/**`, `bootstrap.sh`,
  `hosts/example`, `LICENSE` holder line.
- **web**: 29 doc files under `web/src/content/docs/`.
  `start/what-is-nebelhaus.md` → `what-is-hausfold.md` (**leave a redirect**),
  `start/the-family.md`, `reference/haus.md`, `reference/options.md`
  (regenerates — don't hand-edit), `guides/sharing-a-rice.mdx` (the format doc),
  `astro.config.mjs:8` (`site:`), `:63` (the GitHub edit baseUrl).
- **bench**: `FAMILY=(…)` at `bench:75` — and **drop the stale `trill`** while
  you're there, it was archived 2026-08-04. Also the repo lists at `:1003`,
  `:1455`, `:1541`, and the `--override-input nebelhaus/*` block at `:281-284`.
- **workshop**: `README.md`, `AGENTS.md` routing table, `.agents/**` skills
  (`ship`, `docs-sync`), `docs/workflows.md`.
- **nebelung / pounce / perch / holt / org-profile / homebrew-tap**: each
  repo's `AGENTS.md` + `CLAUDE.md` routing table and README.

### 2.2 🤖 The agent surface specifically

Easy to miss and it breaks *your* sessions, not users':

- `nebelhaus.claude.globalMd` → `haus.claude.globalMd`, in `hearth`.
- The generated skill dir `~/.claude/skills/nebelhaus/` → `.../haus/`, and the
  skill's own `name:` + description.
- `~/.claude/CLAUDE.md`'s generated body (rendered from the option above) —
  its routing table, its `holt` section.
- `HAUS_CONSUMER` — already `haus`-prefixed, **no change**.
- `holt` hooks — repo-agnostic, **no change**.
- `~/.cache/claude-worktrees/` — already documented as historical, **leave**.

**Gate:** `bench try` builds; `haus rebuild` from a main checkout produces a
byte-identical system; the docs site builds and `nix build .#options-json`
regenerates `reference/options.md` with zero drift.

---

## §3 — The GitHub org migration

10 repos. **Do all transfers in one sitting**, then one lock ripple — a
half-migrated org means flake inputs resolving through redirects for days.

### 3.1 👤 Pre-flight

- [ ] `hausfold` org has only `website` today. Confirm **no name collision**
      with an incoming repo (there isn't one — `website` is unique).
- [ ] Confirm you can create repos in `hausfold` and that transfer targets show it.
- [ ] **Repo secrets travel with the repo; org-level secrets do not.** perch's
      `MACOS_CERT_P12` / `NOTARY_*` / `ASC_*` / `IOS_DIST_*` are repo secrets →
      fine. Check pounce, holt, homebrew-tap for anything org-scoped.
- [ ] **Deploy keys and Actions permissions** — the homebrew-tap bump uses a
      deploy key (see the pounce release pipeline). Confirm it survives, or
      re-issue it after.
- [ ] Cloudflare Pages / Workers GitHub integrations bound to `nebelhaus/*`
      repos will need re-authorizing against the new owner.

### 3.2 👤 Transfer, in this order

Upstream first, so each lock bump has a settled target:

| # | From | To | Note |
|---|---|---|---|
| 1 | `nebelhaus/nebelung` | `hausfold/nebelung` | keeps its name — see §6 |
| 2 | `nebelhaus/pounce` | `hausfold/pounce` | |
| 3 | `nebelhaus/perch` | `hausfold/perch` | |
| 4 | `nebelhaus/holt` | `hausfold/holt` | |
| 5 | `nebelhaus/holt-swift` | `hausfold/holt-swift` | the generated SPM mirror |
| 6 | `nebelhaus/nebelhaus` | `hausfold/hausfold` | **rename during/after transfer** |
| 7 | `nebelhaus/workshop` | `hausfold/workshop` | |
| 8 | `nebelhaus/homebrew-tap` | `hausfold/homebrew-tap` | |
| 9 | `nebelhaus/.github` | `hausfold/.github` | the org front page |
| 10 | `nebelhaus/trill` | `hausfold/trill` | archived; transfer or leave, low stakes |

**Keep the `nebelhaus` org alive and empty.** It costs nothing and holds every
redirect. Deleting it breaks them permanently.

### 3.3 🤖 Rewrite every edge

Redirects work, but `flake.lock`'s `original` field keeps the old owner and
that's a landmine.

```sh
# every github:nebelhaus/* across 4 flake.nix files
rg 'github:nebelhaus/' --type nix
# then, per repo, upstream → downstream:
nix flake update <input> --refresh
```

⚠️ **Two known traps here, both already learned:**
- `bench ship` can pin a lock **one commit behind** your merged HEAD (GitHub /
  flake-cache lag). Verify the rev after shipping, `--refresh` to correct.
- Bare `bench ship` from a *workshop worktree* silently fails (exit 128) because
  `./bench` shadows the real one. Call `~/code/workshop/bench` explicitly.

Also: `holt/sdk/swift/sync-mirror.sh` and any `Package.swift` URL, the
homebrew-tap's formula/cask `homepage`/`url` (👤 CI-owned — hand-edit only to
bootstrap), and `.github/workflows/*` that reference `nebelhaus/`.

**Gate:** `bench status` shows every lock edge fresh and no OFF-MAIN pin;
`bench try` builds; a clean `git clone` of each new URL works without redirect.

---

## §4 — Apple identity

**Gated on §0.5.** Highest-blast-radius phase; every step is felt on your own
Mac immediately.

### 4.1 👤 Developer portal, before touching code

- Register App IDs: `com.hausfold.perch`, `com.hausfold.perch.ios`,
  `com.hausfold.perch.ios.share`, `com.hausfold.perch.mobile`,
  `com.hausfold.pounce`, `com.hausfold.flick`.
- Register App Group `group.com.hausfold.perch`.
- Regenerate provisioning profiles; re-export `IOS_DIST_CERT_P12` if bound.
- **Team ID `88M28542LQ` does not change.** Certificates don't change.

### 4.2 🤖 The code

| Old | New |
|---|---|
| `com.nebelhaus.perch` (+ `.ios`, `.ios.share`, `.mobile`, `.dev`, `.tests`, `.transfer`, `.promises`, `.export`) | `com.hausfold.perch…` |
| `group.com.nebelhaus.perch` | `group.com.hausfold.perch` |
| `com.nebelhaus.flick` | `com.hausfold.flick` |
| **`org.nixos.pounce`** | `com.hausfold.pounce` |

`org.nixos.pounce` is a nix-darwin launchd convention leaking into a product —
worth fixing regardless of this rename. But it's the **launchd label**, so:

- The old agent must be unloaded before the new one loads. nix-darwin handles
  this, but verify with `launchctl list | grep -i pounce` that only one remains.
- **The `AssociatedBundleIdentifiers` work is keyed to that label.** Re-verify
  the maintainer's legal name doesn't reappear in macOS permission prompts —
  that was a five-PR chain to fix and this step can undo it.
- The daemon-restart race is real: force
  `launchctl kickstart -k com.hausfold.pounce` and verify by binary timestamp.

### 4.3 👤 Re-grant everything

**TCC grants are keyed to bundle ID + path.** Renaming invalidates all of them:

- Accessibility, Screen Recording, Full Disk Access for pounce and perch.
- ⚠️ The palette's plugins inherit the spawner's TCC identity — the daemon must
  own ⌘Space, and classic-API denials **abort silently**. Test the command
  palette specifically, not just app launch.

### 4.4 👤 Check the license layer

Does perch's offline-Ed25519 license bind to the bundle ID? If yes, **this must
land before the first sale**, and any test licenses you've issued are void.
If no, note it here so nobody re-checks.

**Gate:** pounce launches and its palette runs a plugin command; perch's shelf
accepts a drop; `codesign -dv` shows the new IDs; nothing prompts with a legal
name.

---

## §5 — Domains and sites

### 5.1 👤 A decision this doc won't make for you

Two site codebases exist today:

- `workshop/web/` — the Astro Starlight docs, serving `nebelhaus.com`
  (worker name `nebelhaus`, apex route).
- `hausfold/` (repo `hausfold/website`) — a static one-sheet on
  `hausfold.co` + `www`, custom-domain Workers, `public/index.html` and
  `public/perch/`.

**Fold `hausfold/website` into `workshop/web` and serve hausfold.co from the
Astro app** — otherwise `/docs`, `/market` and `/holt` live in one repo and `/`
lives in another, and the nav has to be maintained twice. Alternative: move
`web/` into the `hausfold/hausfold` repo so the platform ships its own docs.
Pick one before 5.2; the steps below assume the first.

### 5.2 🤖 The move

- `web/astro.config.mjs:8` → `site: 'https://hausfold.co'`.
- Routes: `/docs/*` (the current Starlight tree), `/holt`, `/market` (empty
  placeholder — see §7), `/` (the one-sheet, ported from `hausfold/public/index.html`).
- `web/wrangler.toml`: worker `nebelhaus` → `hausfold`, add the `hausfold.co` +
  `www.hausfold.co` custom domains, keep the `nebelhaus.com/*` route.
- `web/worker.js`: `nebelhaus.com/*` → **301** to the matching `hausfold.co`
  path. Keep `nebelhaus.com/` itself as the rice's showcase page, or 301 it
  too — your call, it's reversible.
- Preserve slugs where you can; where you can't (`what-is-nebelhaus` →
  `what-is-hausfold`), add an explicit redirect.
- `llms.txt.ts` / `llms-full.txt.ts` regenerate.

### 5.3 👤 DNS + verification

- Cloudflare: `hausfold.co` zone gets the Astro worker; confirm the custom-domain
  records wrangler creates.
- 👤 `npx wrangler deploy` (nixpkgs' wrangler fails to build — use npx).
- ⚠️ **Cloudflare edge-caches 404s.** Cache-bust when verifying, or you'll chase
  a redirect that already works.

### 5.4 🤖 Support address

`support@nebelhaus.com` → `support@hausfold.co` in perch's terms, the site
footer, `perch-monetization.md`, and the Paddle application notes.

**Gate:** `curl -sI https://nebelhaus.com/guides/pounce` returns 301 to the
hausfold.co equivalent; every docs page resolves; the options reference renders.

---

## §6 — What deliberately does *not* change

Write these down or they get "fixed" by a later session:

- **`nebelung`** keeps its name. It's a cat breed, its audience is the
  Catppuccin community, and renaming costs a 53-port catalog sweep for zero gain.
- **`nebelhaus`** keeps its name — as the **rice**. It stays the developer-focused
  showcase and the first thing in `/market`.
- **`haus` the CLI** — unchanged, and now the namespace matches it.
- **`holt`, `pounce`, `perch`, `flick`, `prowl`, `sill`, `den`, `hearth`,
  `collar`, `hush`** — all product/room names, all unchanged.
- **Team ID, signing certs, notary keys** — unchanged.
- **`~/.cache/claude-worktrees/`** — already historical, stays.
- **Roadmap §5 bodies, commit messages, PR titles** — historical record.

---

## §7 — Deliberately out of scope (the next arc)

**The nebelhaus rice is not a directory — it's the platform's default values.**
`presets/full.nix` says so in its own comment: *"the whole rice, and the rice's
own default. Importing this changes nothing from a bare install."* So
`git mv`-ing rice files into `rices/nebelhaus/` moves ~187 lines of presets and
nothing else.

Making nebelhaus a real rice means **neutralizing every default** in
`modules/*/options.nix` and pushing the opinions into `rices/nebelhaus.nix`.
That's a behavioral refactor gated by a readiness test — months, not days, and
`developer.enable` (§3.2 of the roadmap) was only its first installment. It does
not belong in a rename that must be provably behavior-neutral.

**And `/market` has a known blocker.** `options-roadmap.md` §6 Limit 3,
measured: a published rice or pack colliding with a stranger's host produces a
**raw nix conflict trace**, not your error message — the module system stops
before your assertions run. Leaf-`mkDefault` is the one depth that composes.
Ship `/market` before that's the enforced format rule and the first thing a
visitor sees is a stack trace. So: `/market` is a **placeholder page** until
leaf-`mkDefault` is the documented rule and `checkRice` enforces it.

---

## §8 — Order of operations, at a glance

```
§0  decisions rewritten · name cleared · queue drained · App Store audited
      │
§1  haus.* namespace  ──── gate: byte-identical derivation
      │
§2  docs, tooling, agent surface  ──── gate: bench try + zero options-drift
      │
§3  GitHub org migration + lock ripple  ──── gate: bench status clean
      │
      ├── §4  Apple bundle IDs  ──── gate: TCC re-granted, palette works
      │
      └── §5  domains + 301s  ──── gate: curl shows the redirect
      │
§6  (nothing — the do-not-touch list)
      │
§7  LATER: neutralize defaults → rices/nebelhaus.nix → /market opens
```

§4 and §5 are independent of each other and can run in either order once §3 is
green. Everything else is strictly sequential.

## §9 — Loose ends found while writing this

- `bench:75` still lists **`trill`** in `FAMILY`; it was archived 2026-08-04.
  Fix in §2.1.
- `notes/launch-phase-1.md` §0 has an unresolved **`.bak` discrepancy**
  carry-over (`guides/the-bar.mdx:128`) — unrelated, but it's in the same file
  you'll be editing.
- ~50 of the agent memory files are keyed to nebelhaus names and will misroute
  future sessions. Cheap sweep, do it last (§2.2's tail).
