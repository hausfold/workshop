# Ejecting trill from the workshop incubator

This tree is a complete, self-contained repo-to-be. It lives inside the
workshop only because the cloud session that scaffolded it couldn't create
GitHub repos (the integration token has no repo-creation scope — both
`nebelhaus` and personal-account creation 403'd).

It was scaffolded as **flick** and renamed to **trill** on 2026-08-08, taking
the name back from the archived Messages client. That rename is why the eject
now has preconditions it didn't have before — read §0 before running §1.

## §0 — Preconditions the name reuse created — ✅ all clear

The old Trill held three slots this app needs. All three were freed on
2026-08-08, in the same day as the rename; this section stays so nobody
re-discovers the constraint and assumes it's still live.

| # | Slot | State |
|---|---|---|
| 1 | GitHub repo name | ✅ the archived client is **`nebelhaus/messages`** (unarchive → rename → re-archive; GitHub keeps the `nebelhaus/trill` redirect). It never conflicted — different org — but two live apps called "trill" would have. |
| 2 | on-disk checkout `~/code/workshop/trill` | ✅ now `~/code/workshop/messages`, with its remote, `.gitignore` and `bench`'s `FAMILY` entry moved with it. **This is the one that mattered for the eject** — step 2 below `mv`s into that exact path. |
| 3 | Homebrew cask token `trill` | ✅ `homebrew-tap/Casks/trill.rb` **deleted** — it had no install base. Blocked the first release, never the eject. |

Slot 2 was the load-bearing one: `bench` resolves family repos as *directory
names* under the workshop root (`local_src` → `$ROOT/$1`), so two things called
`trill` in that dir was never a cosmetic clash — it is `bench status` reporting
the wrong repo.

## §1 — One-time eject (≈2 minutes, from the workshop main checkout)

1. Create the empty repo on GitHub: <https://github.com/organizations/hausfold/repositories/new>
   → name `trill`, description "trill — a quiet, scriptable notification
   compositor for macOS", **no** README/license/gitignore (this tree has
   them). It is born in the `hausfold` org on purpose: every family repo is
   migrating there (`notes/hausfold-rename.md` §3), and a repo created in the
   dead org months from now is exactly the trap that section calls out.

2. Move the tree out and push it:

   ```sh
   cd ~/code/workshop        # the workshop main checkout, this branch merged
   git mv incubator/trill /tmp/trill-eject 2>/dev/null || mv incubator/trill /tmp/trill-eject
   cd /tmp/trill-eject
   git init -b main
   git add -A
   git commit -m "trill: scaffold the quiet notification compositor

   Compositor architecture (queue-owns-state, disposable panels), socket
   provider + CLI, pure policy engine with hot-reloaded rules, quarantined
   experimental System Mirror probe, sqlite history, tests for geometry/
   policy/pipeline. Scaffolded in the workshop incubator as flick; renamed
   to trill before eject. See README, ARCHITECTURE, PRD."
   git remote add origin git@github.com:hausfold/trill.git
   git push -u origin main
   mv /tmp/trill-eject ~/code/workshop/trill   # its place in the family dir
   ```

   That last `mv` is §0's slot 2, and it is clear: the archived client's
   checkout moved to `~/code/workshop/messages` on 2026-08-08. Check anyway —
   if something is sitting at `~/code/workshop/trill`, the `mv` nests one repo
   inside the other instead of failing loudly.

3. Back in the workshop repo: delete `incubator/` (this file goes with it),
   add `/trill/` to `.gitignore` next to the other family repos, and commit.
   (The routing-table row for trill already landed with this branch.)

4. Delete this BOOTSTRAP.md from the new repo once ejected — it's about the
   incubator, not about trill.

## First verification on a Mac

```sh
cd ~/code/workshop/trill
xcodebuild -project Trill.xcodeproj -scheme Trill \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

The scaffold was written in a Linux cloud session — it has **not** been
through a Swift compiler yet. Expect a short round of compile fixes (Swift 6
strict-concurrency niggles are the likely suspects) before the tests run;
the test files state intent precisely enough to fix against.

Then feel it: run Trill.app, `trill ping`, `trill send --title hello`.

## Wiring into the family (later, separate PRs)

- **rice** (`nebelhaus`): a `modules/trill` room — launchd/login-item
  wiring, `trill` CLI shim on PATH, nebelung palette hookup. ⚠️ The rice
  already carries a hand-added prowl float roster entry for this app, added
  ahead of the module landing. It was named `flick` with `appId =
  "com.nebelhaus.flick"`, and a separate rice PR renames it to `trill` /
  `com.hausfold.trill` alongside this change — **check that it landed before
  adding a second entry**, and if it hasn't, the generated
  `on-window-detected` rule is pointing at a bundle id that no longer exists.
- **web**: a docs page at nebelhaus.com/trill — 🚨 **which cannot exist until
  `web/astro.config.mjs`'s `redirects` block stops sending `/trill`,
  `/trill/`, `/guides/trill` and `/guides/trill/` to `nebelhaus/messages`.**
  A redirect beats a page, and retiring those four means accepting that a
  frozen Homebrew cask and a frozen about box start 404ing. `/download/trill`
  **is** free — that slug moved to `messages` with the rename. Still inherited
  from the old product page and still describing the archived app: the
  `--neb-product-trill` palette token and the `'trill'` slot in `FamilyNav`.
  Check each one means *this* app before relying on it.
- **workshop**: routing-table row (already in the workshop's `AGENTS.md`).
- **`.github/copilot-instructions.md`**: the one piece of the agent-config layer
  deliberately left out while incubating — a file at `incubator/trill/.github/`
  is not a path GitHub resolves, and there's no `hausfold/trill` to read it
  from until the eject. Write it then, as a **real file, never a symlink**:
  Copilot reads through the GitHub API, where a symlink is just a path string.
  Everything else (`AGENTS.md`, the `CLAUDE.md` pointer, `GEMINI.md`,
  `opencode.json`, `.agents/setup.sh` and its three hook registrations) is
  already in place and ejects as-is.
- **homebrew-tap / release.yml**: only when the first release is cut
  (CalVer via `bench release trill`); `nix/release.nix` carries a
  placeholder until CI stamps it. §0's slot 3 is already closed — the old
  `Casks/trill.rb` was deleted, so the token is free for this app's cask.
