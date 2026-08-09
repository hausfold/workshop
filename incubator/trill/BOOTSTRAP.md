# Ejecting trill from the workshop incubator

This tree is a complete, self-contained repo-to-be. It lives inside the
workshop only because the cloud session that scaffolded it couldn't create
GitHub repos (the integration token has no repo-creation scope — both
`nebelhaus` and personal-account creation 403'd).

It was scaffolded as **flick** and renamed to **trill** on 2026-08-08.

Every name this app needs is free: the GitHub repo `hausfold/trill`, the
directory `~/code/workshop/trill`, and the Homebrew cask token `trill`. That
last one matters at first release, never at eject; the directory is the one the
eject actually depends on, because `bench` resolves family repos as *directory
names* under the workshop root (`local_src` → `$ROOT/$1`).

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

   Check `~/code/workshop/trill` is empty before that last `mv` — if something
   is already sitting there, the `mv` nests one repo inside the other instead
   of failing loudly.

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
  already carries a hand-added prowl float roster entry for this app (`trill`,
  `appId = "com.hausfold.trill"`), added ahead of the module landing —
  **don't add a second one.**
- **web**: a docs page at nebelhaus.com/trill. `/trill`, `/guides/trill` and
  `/download/trill` are all free — nothing redirects or resolves there today.
  A product colour token (`--neb-product-trill`) and a `FamilyNav` slot are
  both still to be added.
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
