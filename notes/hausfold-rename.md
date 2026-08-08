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
| 7 | **One site repo: `hausfold/website`** | `/`, `/docs`, `/market`, `/holt`, `/pounce`, `/perch`. `workshop/web` folds into it and the landing pages are redesigned, not ported — see §5.1. |

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
- **`hausfold/AGENTS.md` and `hausfold/README.md`** — both quote that rule, and
  AGENTS.md's pre-PR checklist *instructs future reviewers to enforce it*. A
  repeal hides in the checklist that quotes the rule, not in the paragraph you
  rewrite. Missing these was this doc's own bug.
- **`README.md` and `AGENTS.md` here** — the workshop's own routing table calls
  hausfold "the umbrella" and says hausfold is "the only one outside the
  `nebelhaus` org". Both are *decisions*, so they belong in §0.1, not in §2's
  naming sweep — otherwise every session between §0 and §2 reads the
  contradiction §0.1 exists to prevent.
- `notes/options-roadmap.md` — §7 repo routing, and a header note that
  `nebelhaus.*` is now `haus.*` throughout. **Don't rewrite the body**; it's a
  historical record and §5.14 is explicit about that. One banner at the top.
- `notes/perch-monetization.md` — the support-address line.

**Gate:** the following returns nothing (it hits `go-to-market.md:117,171` and
`hausfold/PRESENCE.md:52` today — the `--exclude` is load-bearing, or this doc
matches itself forever):

```sh
grep -rniE "nothing in th(e|at) (nebelhaus )?family (migrates|belongs|may move)|commercial umbrella|don't put it on hausfold\.co|nebelhaus\.com/rices" \
  notes/ hausfold/ README.md AGENTS.md --exclude=hausfold-rename.md \
  | grep -v '~~' | grep -vE ':[0-9]+:> '
```

⚠️ **This gate went through three wrong versions, and the third mistake is the
instructive one.** v1 pointed at `../hausfold/` (a path that doesn't exist) with
patterns that didn't match the real prose. v2 matched, then could never go green
— because it also matched **its own tombstones**: a `~~struck~~` quotation of a
repealed rule preserves the literal string.

The naive fix is to paraphrase every tombstone. That's wrong, and the hausfold
assurance pass caught why: **a repealed rule that isn't quoted reads as an
omission**, so a later session re-adds it in good faith. The rule has to stay
legible *and* the gate has to be able to pass.

Hence the two filters: what this gate is actually looking for is an assertion
that is **still standing** — not one struck through (`~~`) or quoted inside a
reversal blockquote (`> `). Marked-as-dead is the goal state, not a violation.

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
for r in workshop nebelhaus nebelung pounce perch holt homebrew-tap .github; do
  gh pr list --state open -R nebelhaus/$r
done
holt                            # every live/parked worktree, all repos
~/code/workshop/bench status    # dirty trees, unpushed, stale locks
```

- As of 2026-08-08 that's **workshop#249** (flick) and **nebelhaus#257**. Merge
  or park both. Checking only one repo is how a rename lands over an open rice
  PR — which is the exact thing this step exists to prevent.
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

**Audited 2026-08-08 — 🚨 THE GATE FIRED. An app record exists with an uploaded
build.**

| Found | Status |
|---|---|
| App Store Connect → My Apps: **"Perch for Mac" iOS 1.0** | **Waiting for Review** |
| `XC com nebelhaus perch ios` → `com.nebelhaus.perch.ios` | App ID, **bound to that record** |
| `XC com nebelhaus perch ios share` → `com.nebelhaus.perch.ios.share` | App ID, share extension |
| `group.com.nebelhaus.perch` | **registered App Group — it exists** |

The `XC ` prefix said "automatic signing", which was true and not the point: a
build has been uploaded and associated, so **the bundle ID on that record is
locked**, and App Store Connect's bundle-ID dropdown is only editable while no
build is associated.

**The window is open only until Apple approves it**, which can happen within a
day. After approval the app is published, `com.nebelhaus.perch.ios` is in users'
devices, and the *only* remaining fix is publishing a separate app and sunsetting
the first — losing ratings, reviews and any purchase history. There is no
bundle-ID migration on the App Store.

#### 👤 Do this first, before deciding anything

**Remove the submission from review.** App Store Connect → the version →
*Remove from Review* (or *Cancel Submission*). It costs a resubmission and your
queue position — roughly a day — and it preserves **both** options below.
Approval forecloses one of them permanently. That asymmetry is the whole
argument; take the free move now and decide after.

#### The fork, once the clock is stopped

| | **A — recreate under `com.hausfold.perch.ios`** | **B — freeze iOS at `com.nebelhaus.*`** |
|---|---|---|
| Do | Cancel review, delete the app record, create a fresh one with the new bundle ID | Accept the old reverse-DNS on the iOS app only |
| Cost | A review cycle, and **the App Store name is at risk** — Apple does not reliably release a deleted app's name back immediately | A permanent inconsistency **no user ever sees** (bundle IDs don't appear in a listing) |
| §4.3 App Group | must migrate or discard shelf data | **disappears** — the group stays `group.com.nebelhaus.perch`, no data touched |
| Reversal | ⚠️ **one-way.** Deleting the record burns `com.nebelhaus.perch.ios` — Apple never permits reuse — so option B is gone the moment you delete | fully reversible: a future rename is the same decision, just later and no worse |

**Note the macOS app is not affected either way.** perch for Mac ships Developer
ID + notarized via Homebrew, never the App Store, so `com.nebelhaus.perch` →
`com.hausfold.perch` is free. Only the *iOS* record is locked.

#### ✅ Decided 2026-08-08: **route A**

The code half is done — **perch#41** renames the four bundle IDs, both
entitlements and `MobileConfig.appGroupID`, and adds a
*Re-identifying an already-submitted app* runbook to `perch/docs/app-store.md`.
That runbook is the authority on the human steps; it is written to protect the
App Store **name**, which is the real hostage here (plain `Perch` is taken by
someone else, which is why the listing is `Perch for Mac`).

The ordering, in one line each — full version in perch's doc:

- [x] 👤 1.0 removed from review
- [x] 🤖 perch#41 merged — bundle ids, entitlements, `MobileConfig.appGroupID`
- [x] 👤 App IDs + App Group `group.com.hausfold.perch` registered
- [x] 👤 New ASC record created: **`Perch Companion`**, `com.hausfold.perch.ios`,
      SKU `perch-ios-hausfold`
- [x] 🤖 TestFlight build green — run `31261461679`, marketing `2026.8.8`, build 70
- [x] 🤖 perch#42 — docs updated to the new name
- [ ] 👤 Re-enter listing metadata on the new record and submit
- [ ] 👤 Delete the old `Perch for Mac` record (optional cleanup, no deadline)

**The green build is the proof, not the diff.** `-allowProvisioningUpdates`
cannot invent an App Group, so an unregistered or unassigned
`group.com.hausfold.perch` would have failed the archive at signing.

**★ The move that made this cheap: the new record took a name chosen to be
kept** (`Perch Companion`) rather than a placeholder waiting to trade
`Perch for Mac` back. That deleted the one irreversible risk in route A —
there's no name to reclaim, so the old record is now ordinary cleanup. The rule
generalises past Apple: **when a forced rename makes you pick a new name anyway,
take one you'd keep.** `Perch for Mac` was itself only a consolation prize for
`Perch` being taken, and it read oddly on an iPhone app.

⚠️ **Metadata does not travel with a bundle id.** Description, keywords,
screenshots, privacy label, export compliance and review notes are per-record and
start empty; `perch/docs/app-store.md` is the copy of record to paste from.

### 0.6 🚨 The Mac app has the same problem, with a released install base

Found while doing §0.5, and **§4 originally missed it entirely.** perch for Mac
is publicly released — `v2026.08.08`, a live Homebrew cask — and its bundle id
*is* its sandbox container and its defaults domain:

- `~/Library/Containers/com.nebelhaus.perch/Data/…` — **the shelf itself**
  (`perch/docs/reference.md:34`)
- `defaults` domain `com.nebelhaus.perch` — where `LicenseStore` lives
- every TCC grant

So `com.nebelhaus.perch` → `com.hausfold.perch` **empties a released app**:
shelf gone, settings gone, permissions re-prompted, and — once Phase 2 ships the
public key — **every paid license de-activated**. Today that costs nothing
because the install base is approximately you and the license layer is inert.
After the paid launch it is unrecoverable without a migration shim.

**This is an argument for doing it soon, not for skipping it.** It stays in §4.2
rather than jumping the queue like the iOS half, because Apple's review queue is
a clock and Homebrew is not — but it must land **before** perch's Phase 2.

- [x] ✅ **Decided 2026-08-08: discard, no migration shim.** "No users yet" — the
      shelf, the settings and the (inert) license state are ours alone, so the
      rename simply starts a fresh container. Note it in perch's changelog; do
      **not** write a migration path for data that belongs to one person.
- [ ] Land it before perch's license layer goes live — **that's the whole
      constraint now.** The window is "any time before Phase 2 ships the public
      key", and it closes for good the first time somebody pays.

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
# the leaf list already exists as a declared output — generate FROM it
cd nebelhaus && nix build .#options-json
# then: options.json → modules/renamed.nix, one mkRenamedOptionModule per
# leaf, generated rather than hand-typed
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

The house technique — `options-roadmap.md` §3.1 (the options split, nebelhaus#92)
did exactly this and called it "byte-identical derivation":

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
- **bench**: `FAMILY=(…)` at `bench:75`, the repo lists at `:1003`, `:1455`,
  `:1541`, and the `--override-input nebelhaus/*` block at `:281-284`.
  ⚠️ **Leave `trill` in `FAMILY` alone.** `bench:72-74` keeps it there
  deliberately so `bench status` still reports the checkout; it carries no lock
  edge and no release path. Removing it is a behavior change, and this phase is
  gated on "changed nothing".
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

**Gate:** `bench try` builds; the §1.2 derivation diff is still empty; the docs
site builds and `nix build .#options-json` regenerates `reference/options.md`
with zero drift. *(No `haus rebuild` here — that activates the machine, which is
👤's, never 🤖's.)*

---

## §3 — The GitHub org migration

10 repos. **Do all transfers in one sitting**, then one lock ripple — a
half-migrated org means flake inputs resolving through redirects for days.

### 3.1 👤 Pre-flight

- [ ] `hausfold` org has only `website` today. Confirm **no GitHub name
      collision** with an incoming repo (there isn't one — `website` is unique).
- [ ] ⚠️ **There IS an on-disk collision, and it must be decided before §2.1.**
      `bench` resolves `FAMILY` entries as *directory names* under the workshop
      root (`local_src` → `$ROOT/$1` at `bench:252`; `cmd_clone`'s
      `[ -d "$ROOT/$name/.git" ]` at `bench:1541`). Renaming the FAMILY entry
      `nebelhaus` → `hausfold` puts the platform checkout at
      `~/code/workshop/hausfold` — **which is already the `hausfold/website`
      checkout.** This repo survived exactly this once before (the
      `~/code/nebelhaus` → `~/code/workshop` rename, and the child-repo name
      collision that forced it). Pick one:
      **(a)** keep the platform's *directory* named `nebelhaus/` even though the
      repo is `hausfold/hausfold` — zero churn, mildly confusing; or
      **(b)** move the website checkout to `website/` and update `bench:1003`'s
      `repos=(… hausfold consumer)` list plus the comment at `bench:1000-1002`.
      **✅ Resolved by §5.1's decision: take (b).** The site consolidates into
      `hausfold/website`, so the checkouts become `workshop/hausfold/` (the
      platform) and `workshop/website/` (the site) — each named for its repo.
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

⚠️ **One repo that doesn't exist yet still has to be repointed: `flick`.** Its
eject target is written as `nebelhaus/flick` in `AGENTS.md:30`,
`incubator/flick/BOOTSTRAP.md:30,65`, `CLAUDE.md:22`, `.agents/README.md:38,41`
and `nix/package.nix:45,80`. There is no row for it in the table above because
there's no repo to transfer — which is exactly how it gets created in the dead
org months from now. **Repoint it to `hausfold/flick` in §2's sweep**, and treat
"a repo that doesn't exist yet" as a category the transfer table structurally
can't see.

### 3.3 🤖 Rewrite every edge

Redirects work, but `flake.lock`'s `original` field keeps the old owner and
that's a landmine.

There are **three** such files, not four, and the command below reaches only two
of them:

| File | `github:nebelhaus/*` inputs |
|---|---|
| `nebelhaus/flake.nix` | nebelung, pounce, perch, holt |
| `pounce/flake.nix` | nebelung |
| 👤 `~/.config/nix/flake.nix` (`$HAUS_CONSUMER`) | nebelhaus |

`perch`, `holt`, `nebelung`, `trill` and `incubator/flick` have none.

```sh
rg 'github:nebelhaus/' --type nix          # from ~/code/workshop — misses the consumer
rg 'github:nebelhaus/' ~/.config/nix       # 👤 the one flake this machine builds from
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

✅ **The iOS half is already done and pulled forward** — §0.5 route A, perch#41.
What remains here is macOS only.

- Register the macOS App IDs: `com.hausfold.perch`, `com.hausfold.pounce`,
  `com.hausfold.flick`. These ship Developer ID + notarized, never through the
  App Store, so they're unconstrained by any record.
- ⚠️ **`com.nebelhaus.perch` is a released app's container and defaults domain
  — see §0.6 before touching it.** Renaming it empties the shelf and the license
  state of every install.
- `org.nixos.pounce` → `com.hausfold.pounce` is the launchd label; the notes
  below still apply.
- 🚨 **`.nebelhauslicense` — the one user-facing artifact named after the
  demoted brand, and it is in the same deadline class as the bundle IDs.**
  `perch-monetization.md:43` defines it as the signed JSON blob a customer
  receives, and shipped code parses it (perch#27). It is free to rename today
  and unrecoverable after the first sale — a renamed extension orphans every
  license file already in a customer's hands. **Decide it in the same breath as
  §0.6's Mac container, and land both before Phase 2 bakes the public key.**
  Candidates: `.hausfoldlicense`, or a neutral `.perchlicense` (it's
  product-scoped anyway, so the house name earns nothing in the filename).
- Regenerate provisioning profiles; re-export `IOS_DIST_CERT_P12` if bound.
- 👤 **Delete the two `XC com nebelhaus perch ios*` Identifiers** once the new
  ones sign a build. Safe: no app record ever claimed them.
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

### 4.3 🤖+👤 The App Group is a data container, not just an identifier

**Applies under §0.5 option A only.** Under B the group is untouched and this
section is dead. `group.com.nebelhaus.perch` is confirmed registered.

**This one silently destroys perch's state and nothing else in §4 covers it.**
`group.com.nebelhaus.perch` is passed to
`containerURL(forSecurityApplicationGroupIdentifier:)` and
`UserDefaults(suiteName:)` — see `perch/PerchMobileCore/MobileConfig.swift:10-14,38`.
Renaming it gives you a **new, empty container and empty defaults**: every shelf
item and every setting goes invisible, and the old container is orphaned on disk
with no UI pointing at it.

Pick one, explicitly:

- **(a) Migrate** — on first launch under the new group, copy the old
  container's contents and read the old `UserDefaults` suite, keeping the old ID
  readable for one release. Costs a one-shot migration path you delete later.
- **(b) Discard** — declare that shelf state is lost, and **land it before any
  external tester has data**. Free today (the install base is you), impossible
  once §0.5's audit or Phase 1 testers exist.

Whichever you take, write it in perch's changelog. A user who loses a shelf
without warning does not file a bug, they uninstall.

### 4.4 👤 Re-grant everything

**TCC grants are keyed to bundle ID + path.** Renaming invalidates all of them:

- Accessibility, Screen Recording, Full Disk Access for pounce and perch.
- ⚠️ The palette's plugins inherit the spawner's TCC identity — the daemon must
  own ⌘Space, and classic-API denials **abort silently**. Test the command
  palette specifically, not just app launch.

### 4.5 👤 Check the license layer

Does perch's offline-Ed25519 license bind to the bundle ID? If yes, **this must
land before the first sale**, and any test licenses you've issued are void.
If no, note it here so nobody re-checks.

**Gate:** pounce launches and its palette runs a plugin command; perch's shelf
accepts a drop; `codesign -dv` shows the new IDs; nothing prompts with a legal
name.

---

## §5 — Domains and sites

### 5.1 ✅ Decided 2026-08-08 — one site repo, `hausfold/website`

Two site codebases exist today and they merge into the second:

- `workshop/web/` — the Astro Starlight docs + `index/pounce/perch` landing
  pages + **the Worker**, serving `nebelhaus.com` (worker name `nebelhaus`,
  apex route).
- `workshop/hausfold/` (repo `hausfold/website`) — a static one-sheet on
  `hausfold.co` + `www`, assets-only Worker, `public/index.html` and
  `public/perch/privacy/`.

**Everything moves into `hausfold/website`: `/`, `/docs`, `/market`, `/holt`,
`/pounce`, `/perch`.** One repo, one domain, one deploy. The landing pages get
**redesigned**, not ported — nebelhaus stops being a destination and becomes one
rice inside `/market`, so its landing page has no domain to be the front door of.

This decision does two useful things beyond tidiness:

1. **It dissolves §3.1's on-disk collision.** Checkouts become
   `workshop/hausfold/` (the platform) and `workshop/website/` (the site) —
   which is just what the repos are called. Take §3.1 option (b).
2. **It removes the duplicate perch surface** — perch marketing currently exists
   in both repos.

#### 🚨 Blocker found 2026-08-08: `hausfold/website` is a **private** repo

And it is private for a reason its own README spells out: `PRESENCE.md` lists
every namespace held **and every gap** — `hausfold.com` unheld, PyPI unsecured,
no trademark work, `flick` claimed nowhere. That's a shopping list for a reader.

A docs site can't live in a private repo: Starlight's edit links, contributions,
and "improve this page" all assume public. So §5.1 requires flipping it, and the
README names the price:

1. **Scrub `.wrangler/cache/wrangler-account.json` from history** — it predates
   the split and holds a Cloudflare account id plus an account name containing a
   personal email. `git filter-repo --path .wrangler --invert-paths`, **before**
   flipping visibility, never after.
2. **Move `PRESENCE.md` to a new private repo, `hausfold/ops`.** ✅ Decided
   2026-08-08. It keeps the file in git with its history, and gives the rest of
   the ops surface a home: pointers to where credentials live (never the
   credentials), the Cloudflare and Paddle account facts, the register's annual
   re-check. Reversing later is a `git mv`.
   ⚠️ **This doc first said `workshop/notes/`, and that would have been the whole
   bug: `nebelhaus/workshop` is a public repo**, so the "prerequisite" would have
   published the exact gap list that makes the file sensitive — trading a private
   repo for a public one and protecting nothing.

- [ ] 🤖 scrub the blob
- [ ] 👤 create `hausfold/ops`, **private**
- [ ] 🤖 move `PRESENCE.md` into it, repoint every link
- [ ] 👤 flip `hausfold/website` to public

#### The one condition: don't drag Nix into the site repo's CI

`web/scripts/gen-options.mjs` consumes `nix build .#options-json` from the rice,
and `options-drift.yml` fails the build when `reference/options.md` is stale.
Move that as-is and `hausfold/website` needs Nix plus a flake pin just to check
its docs.

Use the family's own rule instead (`options-roadmap.md` §7): *"mirror only what
fits in one expression and can be pinned by a golden test; anything table-shaped
becomes an output of the repo that owns it."* Same lesson as `ports.meta.json`.

So: **`hausfold/hausfold` commits `options.json` as a generated, drift-checked
artifact** (its CI already has Nix), and the site reads that file. No Nix in the
site repo, and the drift check stays where the derivation is.

### 5.2 🤖 The move — and the salvage list

The pages get redesigned. **These are not pages and must survive verbatim:**

| Salvage | Why it's load-bearing |
|---|---|
| `web/worker.js` (158 lines) + `web/test/*.js` (4 suites) | `/init.sh` **proxies the rice's `bootstrap.sh`** — it *is* the install one-liner in every README and doc. Plus `/download/<app>` → latest release, and `/api/release/<app>`, which is how the landing pages label the download button with a real version instead of a hardcoded one that goes stale. |
| `hausfold/public/perch/privacy/` | perch's **privacy policy** — an App Store submission requirement. |
| `web/src/pages/llms.txt.ts`, `llms-full.txt.ts` | generated routes LLM/agent consumers read. |
| `web/public/` — `logos/`, `social/*-og.png`, `media/stills/`, `_headers` | the assets and OG cards; see `assets/SHOTLIST.md` for the media policy. |
| the **copy** in the three `.astro` pages | redesign the layout, keep the sentences that took work. |

Then:

- `astro.config.mjs` → `site: 'https://hausfold.co'`, and the GitHub editLink
  baseUrl → the new repo.
- Routes: `/` (one-sheet), `/docs/*` (the Starlight tree), `/market`
  (placeholder — see §7), `/holt`, `/pounce`, `/perch`, **`/nebelhaus`**.
  ⚠️ **That last route is not optional, and this doc first omitted it.** The
  installer decision below puts `hausfold.co/nebelhaus.sh`'s only CTA "on the
  nebelhaus page inside `/market`" — while §7 makes `/market` a placeholder
  until a months-away refactor. Net: the rice would ship with its install
  one-liner advertised nowhere. Give nebelhaus a route that does **not** depend
  on `/market` opening; `/market` can link to it once it exists.
- `worker.js`: `REPO` → `hausfold/hausfold`, `DOWNLOADABLE` app URLs →
  `github.com/hausfold/<app>`, and drop `trill`.
- `wrangler.toml`: this repo stops being assets-only — it gains a `main` and a
  build step. ⚠️ **Keep `custom_domain = true`** on the hausfold.co routes; its
  comment explains why (the zone has no DNS records, and a plain `pattern` route
  needs a proxied record to already exist).
- Add the `nebelhaus.com/*` route and **301** it path-for-path to hausfold.co.
- Preserve slugs; where you can't (`what-is-nebelhaus` → `what-is-hausfold`),
  add an explicit redirect.

#### ✅ Decided 2026-08-08 — the installer becomes per-rice

`nebelhaus.com/init.sh` → **`hausfold.co/nebelhaus.sh`**, and it is **not** a CTA
on hausfold.co's front page — it lives on the **`/nebelhaus` page** (see §5.2:
that route must exist independently of `/market`, or the one-liner has nowhere
to be advertised), and `/market` links there once it opens.

That generalizes for free: `hausfold.co/<rice>.sh` is every rice's own
one-liner, which is exactly the shape a platform wants. `worker.js`'s `/init.sh`
handler becomes a `/<rice>.sh` route; today it resolves one name, and the
resolution table is the thing to keep small.

**Explicitly deferred:** whether that table scales, and what happens when rices
come from repos the worker doesn't own. Ship the one-name version, watch it,
fix later.

- Keep `nebelhaus.com/init.sh` alive as a 301 to `hausfold.co/nebelhaus.sh` —
  it's in READMEs and shell histories.
- ⚠️ `nebelung.sh` would be the wrong filename: **nebelung is the palette**, the
  rice is **nebelhaus**. Easy slip, and it's a URL.

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
- **`nebelhaus`** keeps its name — as the **rice**. It loses its domain and its
  landing page, but it still needs a *page*: it's the developer-focused showcase
  and the first entry in `/market`. Don't let "no landing page" turn into "no
  page" — `curl … /init.sh | bash` installs it, so something has to describe it.
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

**And `/market` has a known blocker** — `options-roadmap.md` §6 Limit 3. State it
as that file **measured** it, not as it first asserted: §6(b) retracted the
"they see a raw trace rather than anything we wrote" claim, because someone
finally read the trace and it names the option, both files and `lib.mkForce`.
Not friendly, but nearly everything.

The part that is genuinely unfixed is **rice-vs-rice**, which is precisely what a
gallery manufactures:

- §6(d), measured: presets at `mkDefault` collide exactly like plain values.
  Leaf-`mkDefault` is a fix for **host-vs-rice** and "can never be one for
  rice-vs-rice" — so it is the right rule for *packs*, and not the gate here.
- `checkRice` structurally cannot catch it: the module system stops before any
  assertion of ours runs.
- A seam that *transforms* a rice erases the filename — two packs naming one app
  report ``- In `<unknown-file>'`` twice: loud and anonymous.

So `/market` is a **placeholder page** until §6(e)'s **priority by list
position** (`compose [ a b ]`, stamping each rice one `mkOverride` weaker than
the next) ships. That's the live candidate and it's measured in both directions.

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
§7  LATER: neutralize defaults → rices/nebelhaus.nix → /market opens
```

(§6 is the do-not-touch list — no steps, nothing to gate.)

§4 and §5 are independent of each other and can run in either order once §3 is
green. Everything else is strictly sequential.

## §9 — Loose ends found while writing this

- `bench:75` still lists **`trill`** in `FAMILY` — and that's **deliberate**
  (`bench:72-74`), so `bench status` keeps reporting the checkout. Recorded here
  only because it reads like drift and will get "fixed" otherwise. See §2.1.
- `notes/launch-phase-1.md` §0 has an unresolved **`.bak` discrepancy**
  carry-over (`guides/the-bar.mdx:128`) — unrelated, but it's in the same file
  you'll be editing.
- ~50 of the agent memory files are keyed to nebelhaus names and will misroute
  future sessions. Cheap sweep, do it last (§2.2's tail).
