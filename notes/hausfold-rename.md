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
| 3 | **`hausfold.co`**, accept the `.co` | `hausfold.com` isn't unbought, it's **unbuyable** — an operating laundry business holds it, checked 2026-08-08. §0.4. |
| 4 | **Rename now, neutralize defaults later** | the sweep is mechanical and provable; the rice carve-out is design work (§7). |
| 5 | **All Apple bundle IDs move to `com.hausfold.*`** | free today, impossible after an App Store record exists. |
| 6 | **All 8 repos transfer to the `hausfold` org** | plus the `holt-swift` mirror and the archived `trill`. |
| 7 | **One site repo: `hausfold/hausfold.co`** | `/`, `/docs`, `/desktops`, `/holt`, `/pounce`, `/perch`. `workshop/web` folds into it and the landing pages are redesigned, not ported — see §5.1. *(Was `hausfold/website`, which is archived and private; the new repo was created 2026-08-08.)* |

### And these three reverse earlier written decisions

`go-to-market.md` §6 (decided 2026-08-04) and `hausfold/PRESENCE.md` currently
say the opposite. **They are read by every agent session**, so if they aren't
rewritten first, a future session will "correct" this work back:

- ~~"hausfold is the umbrella, not a product brand"~~ → hausfold **is** the
  platform (and still the seller).
- ~~"nothing in the nebelhaus family migrates to the hausfold org, ever"~~ →
  everything does.
- ~~"the gallery lives at nebelhaus.com/rices, not hausfold.co"~~ →
  `hausfold.co/desktops`.

> **The gallery's path was `/market` throughout this document until
> 2026-08-08.** It was amended to **`/desktops`** the same day, after the page
> shipped under that name: a parallel session building it put `/market`,
> `/gallery`, `/rices` and `/desktops` to the user and was told `/desktops` —
> plainer English, a generic noun rather than a name, and therefore no row
> needed in `hausfold/PRESENCE.md`. Told the two had collided, the user chose to
> amend the plan rather than rename the live page.
>
> Two things the swap is **not**. It isn't a retreat from commerce — nothing
> about the word `market` was load-bearing for perch's paid line, which lives at
> `/perch`. And it doesn't reopen §5: *the gallery is on hausfold.co, not
> nebelhaus.com* is the decision and it stands. Only the noun moved.

One thing from §6 that survives and one that doesn't:

- ✅ *"funnels die at extra hops"* still holds — which is why nebelhaus.com
  **301s** to hausfold.co rather than merely coexisting.
- ❌ *"support stays support@nebelhaus.com, because people bought a nebelhaus
  product"* is now wrong: they buy a hausfold product. Support moves.

---

## §0 — Before anything moves

### 0.1 ✅ Rewrite the reversed decisions *first* — done, gate green 2026-08-08

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

**Gate: ✅ returns nothing, verified 2026-08-08** (run from the workshop's *main*
checkout — a workshop worktree has no `hausfold/` in it at all, so a green run
there proves nothing). It used to hit `go-to-market.md:117,171` and
`hausfold/PRESENCE.md:52` — the `--exclude` is load-bearing, or this doc
matches itself forever:

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

### 0.2 👤 Name clearance — partly run 2026-08-08

"hausfold" as an *umbrella* was low exposure. As a **platform with a market and
paid products**, it's a different check:

| | Status |
|---|---|
| npm — `hausfold` as a package name | ✅ **free** (2026-08-08) |
| PyPI — `hausfold` as a project name | ✅ **free** (2026-08-08). ⚠️ `flick`, `nebelung`, `pounce`, `perch` are all **taken** by unrelated projects — not recoverable, PyPI has no reservation |
| GitHub — any `hausfold*` squatting near you | ✅ nothing found; the org is ours |
| A web search for an existing company using it | 🚨 **found one** — see below |
| USPTO TESS + EUIPO, software classes (9/42) | ❌ **not done.** The USPTO search API needs a key; this needs the web UI or a service. **Still 👤.** |

🚨 **`hausfold.com` is an operating US business: HAUS FOLD, in-home laundry and
light housekeeping in Charleston / Columbia / Greenville, South Carolina.**
Registered 2025-04-19, live site, phone, pricing, testimonials, and
`instagram.com/hausfold`. Not German or Austrian, which is why the original
phrasing of this check wouldn't have found it. Full detail in §0.4.

**Gate: passed, provisionally — no forced rename.** They sell a household
*service*; we sell software. Different Nice classes coexist routinely and
nobody confuses a laundry round with a nix-darwin platform. But they are **first
in time on the word, in the US, in commercial use**, so this is coexistence
rather than clearance, and the one check that would settle it is the one still
undone.

⚠️ **The undone half has a trigger, not a date.** Run the USPTO/EUIPO search
before **any** of: filing an application, paid marketing, or incorporating an
entity that trades under the name. Below that line the exposure is logged and
accepted. Above it, "we looked at their website" is not a clearance opinion.

### 0.3 🟨 Drain the queue — PR/lock half green 2026-08-08, branches still open

**A namespace rename conflicts with every open branch.** Today the family has
exactly one open PR — that's the readiness signal, and it decays.

```sh
for r in workshop nebelhaus nebelung pounce perch holt homebrew-tap .github; do
  gh pr list --state open -R nebelhaus/$r
done
# the loop above is the nebelhaus org only — the hausfold org already holds
# repos that §2 and §5 edit, and they have their own lanes
for r in hausfold.co ops; do gh pr list --state open -R hausfold/$r; done
holt                            # every live/parked worktree, all repos
~/code/workshop/bench status    # dirty trees, unpushed, stale locks
```

- Both PRs this section named (workshop#249, nebelhaus#257) have landed. **Re-run
  the loop before starting §1 rather than trusting this line** — it was true at
  one instant and the whole point of the step is that the instant passes.
  Checking only one repo is how a rename lands over an open rice PR.
- `holt reap` anything already landed.
- `bench status` must show **no stale lock edge and no OFF-MAIN pin** before the
  sweep starts — a rename ripple on top of a stale lock is undebuggable.

**Gate:** `bench status` clean, zero open PRs, zero unmerged `worktree-*`
branches.

**Measured 2026-08-08 — two of the gate's three clauses.** Zero open PRs across
the eight `nebelhaus/*` repos; all six lock edges current, no OFF-MAIN pin. The
**branch clause is not met** and shouldn't be forced: `holt` lists live lanes
across workshop, nebelhaus, hausfold and perch. Sort them like this:

- 🚨 **`nebelhaus`'s `worktree-fizzy-moseying-snowglobe` is exempt.** It carries
  §1.0's parked spike (wip `7d9ee70`), which is §1's expensive input. An agent
  reaping to satisfy this gate deletes the artifact the next phase depends on.
- A stale `perch` branch `worktree-workshop-name` — no checkout, no registry row.
  `git -C perch branch -D` it.
- A `holt` checkout under `~/.codex/worktrees/`. That path is **not** where any
  client's lanes live (`AGENTS.md`: every client shares
  `~/.cache/claude-worktrees/`), so it's an orphan created outside `holt` — the
  invisible-in-the-statusline gotcha, not a session to resume. Remove it.
- Everything else: land or park normally.

One release edge is behind — `nebelhaus v2026.08.08` is 13 commits behind main —
which is orthogonal to the rename, but note that **cutting that release after §1
lands stamps a `haus.*` rice**, so either release before the sweep or accept that
the next tag is the rename's.

### 0.4 ✅ hausfold.com — checked 2026-08-08, and it isn't for sale

Decision 3 accepts `.co`. Two consequences to hold consciously rather than
discover:

- ~~The `.com` gets more expensive as the brand gains value, and this rename is
  the event that gives it value.~~ **Moot — see below.**
- The seller name appears on receipts and terms. `.co` reads second-tier there.

**This section used to end: *"check the `.com` isn't parked by a squatter today,
and if it's ~$12, the argument for buying it is that this is the last time it's
that cheap."* That check has now been run, and the answer is no.**

`hausfold.com` was registered **2025-04-19** (expiry 2028-04-19) and serves
**HAUS FOLD — "For your household."**, an operating in-home laundry and
light-housekeeping service in Charleston, Columbia and Greenville, South
Carolina. Live site, phone number, service tiers, testimonials, pricing. Not
parked, not a squatter, **not a $12 registration waiting to be made** — buying
it would mean buying a working business's primary domain.

So there was never a purchase to be early for, and "buy it now while it's cheap"
was wrong from the start rather than expired. Three things follow:

1. **Decision 3 stands, for a different reason.** Accepting `.co` isn't a thrift
   decision any more; it's the only option.
2. **It explains the handles.** `instagram.com/hausfold` is theirs, linked from
   their own site — which is why the register records `hausfold.co` there.
   Anywhere else the bare `hausfold` was "unavailable", assume the same cause
   and stop re-checking.
3. **It promotes the trademark question.** A same-word mark in commercial use in
   the US, first in time. Likely fine — a household *service* against *software*
   are different Nice classes — but that is a reading, not a search. **Get a real
   USPTO search before filing anything, spending on marketing, or incorporating
   under the name.** Nothing here was checked against the trademark register.

Re-logged in `go-to-market.md` §9 decision 4 as decided-accept.

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

The technically hardest phase — **and the spike has now run, so it is a known
quantity rather than a fork.** Per the family's own rule
(`options-roadmap.md` §7) a **breaking option rename couples the consumer's
lock-bump and config edit into one PR — `bench ship` can't split them without
breaking main mid-ripple.** §1.0's answer is that the rename doesn't have to be
breaking, so that coupling never has to happen.

**The tree is 110 declared leaves, not the "~44" this section used to claim**
(155 paths counting each `<name>` submodule field). Measured, not estimated —
see §1.0's method, which is also the only way to get the real number.
⚠️ `options-roadmap.md` says **130** for the same tree, on its own date and by its
own count. Don't reconcile the two by picking one: **re-run §1.0's snippet** — it
states its rule (every node whose `_type` is `"option"`, under
`options-modules.nix`, internals included) and is the number `renamed.nix` has to
agree with.

### 1.0 ✅ Spike run 2026-08-08 — the alias carries it. Take §1.1a.

The question was: if `lib.mkRenamedOptionModule` can carry the whole tree, the
atomicity problem **dissolves** — `haus.*` becomes real, `nebelhaus.*` becomes a
warning-emitting alias, main never breaks, and `~/.config/nix` bumps its lock
whenever it likes.

**It carries it.** The spike renamed all 14 declaration sites, generated
`modules/renamed.nix` (105 `mkRenamedOptionModule` entries), and left the example
host, both presets and the pack file still written as `nebelhaus.*`. Result:

- `nix flake check --no-build` **green across all 16 checks** — including
  `presets`, `packs`, `data-only-surface` and `preset-composition`, which is the
  one that composes two rices.
- The example system's derivation differs from pristine in **exactly one leaf**:
  `options.json`. Everything else that moved (`claude-skill`, `host-template`,
  and therefore `system-path`, `etc`, `system-applications`) is downstream of
  that one file. See §1.2 — this is the corrected gate, not a failure.
- `.#options-json` renders **155 `haus.*` keys and zero `nebelhaus.*`**: the
  aliases are `visible = false`, so they never reach the docs.

The spike tree is parked, not thrown away: nebelhaus branch
`worktree-fizzy-moseying-snowglobe`, wip commit `7d9ee70` (`holt unpark` in that
lane). 27 files, and the generated `renamed.nix` is the expensive part.

#### The five things it found that the plan didn't have

1. 🚨 **`nix build .#options-json` is NOT the leaf list, and generating
   `renamed.nix` from it silently misses five options.** `optionsDoc` drops
   anything `internal = true`. Four are obvious (`_roster`, `_workspaces`,
   `_appWorkspace`, `_launchers`); **the fifth is `theme.ports.handled`, which
   is internal without an underscore**, so `options-doc.nix:78`'s
   `hasPrefix "_"` filter isn't what hides it and no naming convention will
   find it. Enumerate from the module system instead:

   ```nix
   # nix eval --impure --raw --file leaves.nix
   let ev = lib.evalModules {
         modules = (import ./modules/options-modules.nix) ++ [ { _module.check = false; } ];
       };
       go = path: opts: lib.concatLists (lib.mapAttrsToList (n: v:
         if !(lib.isAttrs v) then [ ]
         else if v._type or "" == "option" then [ (path ++ [ n ]) ]
         else go (path ++ [ n ]) v) opts);
   in lib.concatStringsSep "\n" (map (lib.concatStringsSep ".") (go [ ] ev.options.nebelhaus))
   ```

   110 leaves out, 105 of which options.json knows about.
2. **Internal options get swept, not aliased.** They're ours; an alias would
   just emit an obsolete-option trace on every eval of our own code.
3. **Reading an option's *declaration* through an alias breaks.** `doRename`'s
   alias carries no `default`, so `options.nebelhaus.fonts.mono.name.default`
   throws `attribute 'default' missing`. One site today —
   `modules/den/default.nix:151` — and it has to move with the declarations.
   Reading a *value* (`config.nebelhaus.x`) is fine: `doRename` gives the alias
   an `apply` that returns the target's value, which is precisely why consumer
   reads don't have to move in the same PR.
4. **`modules/options-doc.nix:78` hardcodes `optionsEval.options.nebelhaus`** —
   the docs generator must move in the same commit or the whole build fails, not
   just the docs.
5. **The option-file list is written twice** — `modules/options-modules.nix` and
   `modules/default.nix` each carry their own copy — and `renamed.nix` must be in
   **both**. In only `default.nix`, the pure-lib option-surface evals in
   `flake.nix` (`packCompose`, the pack surface check) fail with ``The option
   `nebelhaus' does not exist``. In only `options-modules.nix`, the *system*
   eval fails instead. Neither failure names the duplication.

The second spike question — does `checkRice` still work when a rice sets the
alias — has a sharper answer than expected. **It can't be carried by the alias
at all:** `checkRice` reads the *file's* top-level attribute name, not the option
system, so a `{ haus = …; }` rice is rejected by a string comparison
(`flake.nix:198`) no matter what the module system thinks. It has to accept
**both names for the length of the transition** and narrow to `haus` only at
step 6 — third-party rices are exactly the consumers who move last.

### 1.1a 🤖 Alias path — confirmed, and here is what it actually costs

1. `haus.*` becomes the canonical namespace in all **14** `options.nix` files —
   a one-line change each (`options.nebelhaus` → `options.haus`).
2. Generated `modules/renamed.nix` aliases the old tree, warning on use. Listed
   in **both** module lists (finding 5).
3. Sweep, in the same PR, the things the alias can't cover: the five internal
   options and their ~33 references, `options-doc.nix:78`, and
   `den/default.nix:151`.
4. `checkRice` accepts `haus` **and** `nebelhaus` (finding above).
5. `presets/*.nix`, `packs/*.nix`, `hosts/example/default.nix` move to `haus.*` —
   these can land in the same PR or a later one; the alias holds either way, and
   the spike proved they still evaluate untouched.
6. `~/.config/nix/hosts/mbp/default.nix` moves to `haus.*` — 👤 **separately**,
   whenever, because the alias holds.
7. Aliases deleted, and `checkRice` narrowed to `haus` alone, in a follow-up PR
   **after** the last consumer moves.

### 1.1b 🤖+👤 Atomic path (fallback — no longer expected to be needed)

Kept because a future nixpkgs could regress `doRename`, not because anything
points here today. One PR in `hausfold/hausfold` renaming the tree with no alias,
and one in `~/.config/nix` rewriting the host file + bumping the lock, merged in
that order within the same sitting. Nothing else may be mid-ripple.

### 1.2 🤖 Prove it changed nothing — the gate, as measured

The house technique — `options-roadmap.md` §3.1 (the options split, nebelhaus#92)
did exactly this and called it "byte-identical derivation":

```sh
# BEFORE the sweep, on a clean tree
nix path-info --derivation .#darwinConfigurations.example.system > /tmp/before.drv
# AFTER
nix path-info --derivation .#darwinConfigurations.example.system > /tmp/after.drv
diff /tmp/before.drv /tmp/after.drv
```

**First, the technique is sound and that was worth checking.** A control run —
same commit, one added comment — produced the identical drv path, so the flake's
source hash does *not* leak into the derivation and a difference here is a real
difference.

⚠️ **But `diff` cannot be empty for this particular change, and a plan that
demands it will get "fixed" by deleting the gate.** The rice **ships its own
option surface as an artifact**: `.#options-json` feeds `.#claude-skill` and
`.#host-template`, which are in `system-path`, `etc` and `system-applications`.
Renaming the namespace legitimately renames every key in that file.

So the gate is **one leaf divergence, and it is `options.json`**. Walk the two
derivation graphs and find where they stop differing:

```sh
# recurse both drvs through inputs.drvs, matching by name, and report every
# pair that differs while all of its own inputs match
```

Measured on the spike: exactly one such leaf, `options.json.drv`. Anything else
in that list is a real behavior change and the gate is red.

🚨 **The trap that produced a second leaf on the first run, and the reason it
belongs to §2 rather than §1:** `modules/sill/default.nix:119` reads
`# GENERATED from nebelhaus._roster by modules/sill/default.nix — do not edit.`
— and that line is **inside the `workspacesSh` string**, so it is a line of
`~/.config/sketchybar/workspaces.sh`, not a comment on the Nix. Sweeping it
changed the shipped file. There are ~12 more `# GENERATED from nebelhaus.*`
comments in `sill/default.nix` alone, plus `prowl/aerospace.toml`,
`prowl/scripts/resort-windows.sh` and `sill/sketchybar/plugins/launch_mode.sh`.
**Leave every one of them for §2.** In §1 they are gate-breakers; in §2, after
the gate has passed, they are ordinary text.

Plus `nix flake check` (it evaluates a real system per preset, and composes two
rices) and the options-drift CI.

**Gate:** the derivation walk's only leaf divergence is `options.json`,
`nix flake check` green, `bench try` builds.

---

## §2 — In-repo naming, docs, tooling

Pure text, ~250 files, but **not** a blind `sed`. Three distinct classes that a
single find-replace would conflate:

| Class | Rule |
|---|---|
| the **platform** (options, modules, the CLI, the docs' subject) | → `hausfold` / `haus.*` |
| the **rice** (presets, the desktop, the showcase, the grey) | stays **nebelhaus** |
| **historical record** (roadmap §5 bodies, PR titles, commit messages, `holt`'s `~/.cache/claude-worktrees/` path) | **leave alone** |

⚠️ **A fourth class the table missed, handed over by §1.2: comments that are
inside generated files.** `# GENERATED from nebelhaus.<option> …` appears ~12
times inside string bodies in `modules/sill/default.nix`, and again in
`prowl/aerospace.toml`, `prowl/scripts/resort-windows.sh` and
`sill/sketchybar/plugins/launch_mode.sh`. They *are* the shipped file, so
touching them changes a store path. They belong here, in §2, **after** §1's
byte-identity gate has gone green — never during §1.

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
  ⚠️ **Two golden tests pin that path by hand.** The literal line
  `file .claude/skills/nebelhaus/references/this-machine.md moves` is in
  **both** `expectedScaleTable` (`nebelhaus/flake.nix:1194`) and
  `expectedFontTable` (`:1311`). So the rename fails the *scale-reach* and
  *font-reach* checks — errors about scale and fonts, the last two places anyone
  would look. Fix only one and the other still fires. Move both in the same commit.
- `~/.claude/CLAUDE.md`'s generated body (rendered from the option above) —
  its routing table, its `holt` section.
- `HAUS_CONSUMER` — already `haus`-prefixed, **no change**.
- `holt` hooks — repo-agnostic, **no change**.
- `~/.cache/claude-worktrees/` — already documented as historical, **leave**.

**Gate:** `bench try` builds; the §1.2 derivation walk shows **no leaf divergence
beyond `options.json` and the generated files this phase deliberately edited**
(the ~12 `# GENERATED from nebelhaus.*` comment lines — see the fourth class
above); the docs site builds and `nix build .#options-json` regenerates
`reference/options.md` with zero drift. *(This used to read "the §1.2 derivation
diff is still empty", which §2 is designed to break — the exact shape of
over-broad gate §1.2 warns gets deleted rather than met.)* *(No `haus rebuild` here — that activates the machine, which is
👤's, never 🤖's.)*

---

## §3 — The GitHub org migration

10 repos. **Do all transfers in one sitting**, then one lock ripple — a
half-migrated org means flake inputs resolving through redirects for days.

### 3.1 👤 Pre-flight

- [ ] `hausfold` org has `website` (archived), `hausfold.co` and `ops` today.
      Confirm **no GitHub name collision** with an incoming repo — there isn't
      one, none of the three is on §3.2's transfer list.
- [ ] ⚠️ **There IS an on-disk collision, and it must be decided before §2.1.**
      `bench` resolves `FAMILY` entries as *directory names* under the workshop
      root (`local_src` → `$ROOT/$1` at `bench:252`; `cmd_clone`'s
      `[ -d "$ROOT/$name/.git" ]` at `bench:1541`). Renaming the FAMILY entry
      `nebelhaus` → `hausfold` puts the platform checkout at
      `~/code/workshop/hausfold` — **which is already the site checkout**
      (`hausfold/website` then, `hausfold/hausfold.co` now). This repo survived
      exactly this once before (the
      `~/code/nebelhaus` → `~/code/workshop` rename, and the child-repo name
      collision that forced it). Pick one:
      **(a)** keep the platform's *directory* named `nebelhaus/` even though the
      repo is `hausfold/hausfold` — zero churn, mildly confusing; or
      **(b)** move the website checkout to `website/` and update `bench:1003`'s
      `repos=(… hausfold consumer)` list plus the comment at `bench:1000-1002`.
      **✅ Resolved by §5.1's decision: take (b).** The site consolidates into
      `hausfold/hausfold.co`, so the checkouts become `workshop/hausfold/` (the
      platform) and `workshop/hausfold.co/` (the site) — each named for its repo.
      *(This read `workshop/website/` until 2026-08-08, when the site repo was
      recreated under a new name; the on-disk name follows the repo.)*
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

### 5.1 ✅ Decided 2026-08-08 — one site repo, `hausfold/hausfold.co`

> ⚠️ **Renamed 2026-08-08, after this section was written.** The site repo is
> **`hausfold/hausfold.co`** (public), not `hausfold/website` (private, now
> archived). This wasn't a rename — it's a new repo, and the blocker subsection
> below explains why that was the only way to satisfy §5.1's public requirement.
> Read `hausfold/website` in this section as `hausfold/hausfold.co` throughout.

Two site codebases exist today and they merge into the second:

- `workshop/web/` — the Astro Starlight docs + `index/pounce/perch` landing
  pages + **the Worker**, serving `nebelhaus.com` (worker name `nebelhaus`,
  apex route).
- `hausfold/hausfold.co` — a small static site on `hausfold.co` + `www`,
  assets-only Worker: the landing page, `/desktops`, `/perch/privacy`, `404`.

**Everything moves into `hausfold/hausfold.co`: `/`, `/docs`, `/desktops`,
`/holt`, `/pounce`, `/perch`.** One repo, one domain, one deploy. The landing pages get
**redesigned**, not ported — nebelhaus stops being a destination and becomes one
rice inside `/desktops`, so its landing page has no domain to be the front door of.

This decision does two useful things beyond tidiness:

1. **It dissolves §3.1's on-disk collision.** Checkouts become
   `workshop/hausfold/` (the platform) and `workshop/website/` (the site) —
   which is just what the repos are called. Take §3.1 option (b).
2. **It removes the duplicate perch surface** — perch marketing currently exists
   in both repos.

#### ✅ Blocker found and cleared 2026-08-08: the site repo was **private**

`hausfold/website` was private for a reason its own README spelled out:
`PRESENCE.md` listed every namespace held **and every gap**, which is a shopping
list for a reader. A docs site can't live in a private repo — Starlight's edit
links, contributions and "improve this page" all assume public — so §5.1 needed
it flipped.

**The plan was to scrub and flip. The plan was wrong, and the reason is the part
worth keeping.** It was:

1. Scrub a cached Cloudflare account id out of the history via `git
   filter-repo`, **before** flipping.
2. Move `PRESENCE.md` to a new private `hausfold/ops`.

Step 1 does not do what it claims. `hausfold/website` had pull requests, and
**GitHub keeps `refs/pull/N/head` forever — a history rewrite does not GC them.**
Measured on 2026-08-08 before deciding: every PR ref then in existence still
reached both artifacts after the rewrite, so they stay fetchable — on a repo that
has just gone public. **Rewriting history on a repo that has ever had a pull
request is hygiene, not removal.** The original plan also named only the blob,
not the file: a `git mv` of `PRESENCE.md` to another repo leaves every past
revision of it behind.

*(The exact paths, commits and refs stay in `hausfold/website`'s own README,
which is private. **This repo is public** — writing the fetch recipe down here
would hand over what the migration was for. Same reason this section no longer
enumerates the gaps it used to list verbatim.)*

**So the site moved to a new repo instead**, which has no PR refs and nothing to
purge. Cost: 33 commits of a placeholder page — which this very section replaces
with an Astro build anyway.

Where things landed:

- **`hausfold/hausfold.co`** — public, created 2026-08-08. `public/`, both
  wrangler configs, both workflows, `README.md`, `AGENTS.md`, as one commit.
- **`hausfold/ops`** — private, created 2026-08-08. `PRESENCE.md` with its
  eleven revisions replayed, plus the rest of the ops surface: pointers to where
  credentials live (never the credentials), the Cloudflare and Paddle account
  facts, the register's annual re-check.
  ⚠️ **This doc first said `workshop/notes/`, and that would have been the whole
  bug: `nebelhaus/workshop` is a public repo**, so the "prerequisite" would have
  published the exact gap list that makes the file sensitive — trading a private
  repo for a public one and protecting nothing.
- **`hausfold/website`** — stays private **permanently**, archived. Not deleted:
  it is the site's only pre-2026-08-08 history. (Deleting it wouldn't break the
  domain — the `custom_domain` binding lives in Cloudflare, tied to the Worker
  name — it would just lose the history.) 🚨 *Never flip it to public. No scrub
  makes it safe; see above.*

- [x] 🤖 create `hausfold/ops`, private, `PRESENCE.md` carried with its history
- [x] 🤖 create `hausfold/hausfold.co`, public, site carried as one commit
- [x] 🤖 archive `hausfold/website` (workflows removed, README/AGENTS rewritten)
- [x] 👤 re-enter the three Actions secrets on `hausfold/hausfold.co`
- [x] 👤 delete those secrets from `hausfold/website` and archive it

**✅ §5.1's blocker is fully closed as of 2026-08-08.** hausfold.co serves from
`hausfold/hausfold.co` — deploy green, `/`, `/desktops/` and `/perch/privacy/`
all 200, an unknown path 404s (so `not_found_handling = "404-page"` came over
intact). `hausfold/website` is archived, private, and holds no secrets.

#### The one condition: don't drag Nix into the site repo's CI

`web/scripts/gen-options.mjs` consumes `nix build .#options-json` from the rice,
and `options-drift.yml` fails the build when `reference/options.md` is stale.
Move that as-is and `hausfold/hausfold.co` needs Nix plus a flake pin just to
check its docs.

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
- Routes: `/` (one-sheet), `/docs/*` (the Starlight tree), `/desktops` and
  `/desktops/<rice>`, `/holt`, `/pounce`, `/perch`.
  ✅ **Resolved 2026-08-08 — and the two routes already exist.** This bullet
  used to demand a separate top-level **`/nebelhaus`**, because the installer
  decision below puts `hausfold.co/nebelhaus.sh`'s only CTA on the nebelhaus
  page, and §7 was going to make the gallery a placeholder for months: net, the
  rice would ship with its one-liner advertised nowhere. The site repo
  then shipped `/desktops` **and** `/desktops/nebelhaus` as plain HTML, the
  latter carrying the install command — which is exactly the
  independent-of-the-gallery route this was asking for, one level deeper than
  proposed. No top-level `/nebelhaus` is needed; **preserve
  `/desktops/nebelhaus` through the Astro port** rather than re-deriving it.
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
on hausfold.co's front page — it lives on the rice's own page, which as of
2026-08-08 is **`/desktops/nebelhaus`** (see §5.2: that page exists and already
carries the command, so nothing waits on the gallery).

⚠️ **That page prints the old one-liner today** —
`curl -fsSL https://nebelhaus.com/init.sh | bash`, hand-copied from
`nebelhaus/README.md`. It is correct now and wrong the moment this decision
lands. `hausfold/PRESENCE.md`'s Gaps records the duplication; **this is the step
that has to edit it**, and nothing checks the two agree.

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
  and the first entry in `/desktops`. Don't let "no landing page" turn into "no
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

**And `/desktops` has a known blocker** — `options-roadmap.md` §6 Limit 3. State it
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

So the gallery cannot open properly until §6(e)'s **priority by list position**
(`compose [ a b ]`, stamping each rice one `mkOverride` weaker than the next)
ships. That's the live candidate and it's measured in both directions.

**Amended 2026-08-08 — the gate is on the *second* entry, not on the page.**
This section said `/desktops` ships as a placeholder page. What actually shipped
is a working one: `/desktops` lists nebelhaus and `/desktops/nebelhaus` carries
a real install command. That doesn't trip Limit 3, and re-reading the bullets
above says why in one line — **every one of them is about rice-vs-rice, and
rice-vs-rice needs two rices.** Today there is one, offering one command that
installs nebelhaus alone, exactly as nebelhaus.com already does. No composition
happens, so no seam collides.

The gate therefore binds where the danger actually is: **adding a second rice to
the gallery is blocked on §6(e)**, and `hausfold/AGENTS.md`'s Shipping section
carries the same rule at the point someone would break it. Restating it as "the
page is a placeholder" was over-broad, and the cost of an over-broad gate is
that the first person who finds it harmless ignores the whole thing.

---

## §8 — Order of operations, at a glance

```
§0  decisions rewritten · name cleared · queue drained · App Store audited
      │
§1  haus.* namespace  ──── gate: options.json is the ONLY leaf that moved
      │
§2  docs, tooling, agent surface  ──── gate: bench try + zero options-drift
      │
§3  GitHub org migration + lock ripple  ──── gate: bench status clean
      │
      ├── §4  Apple bundle IDs  ──── gate: TCC re-granted, palette works
      │
      └── §5  domains + 301s  ──── gate: curl shows the redirect
                │
§7  LATER: neutralize defaults → rices/nebelhaus.nix → a 2nd rice in /desktops
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
- **The rice's per-room options list is duplicated** — `modules/options-modules.nix`
  and `modules/default.nix` each hold their own copy of the same 14 paths, and
  `options-modules.nix`'s header comment ("the ONLY modules that declare
  `nebelhaus.*`") reads as if it were the single source. Adding a module to one
  and not the other fails in a way that names neither file (§1.0, finding 5).
  Folding `default.nix`'s copy into an `import ./options-modules.nix` is a
  standalone tidy-up worth doing **before** §1, so the rename doesn't have to
  discover it.
