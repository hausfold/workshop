# Ejecting flick from the workshop incubator

This tree is a complete, self-contained repo-to-be. It lives inside the
workshop only because the cloud session that scaffolded it couldn't create
GitHub repos (the integration token has no repo-creation scope — both
`nebelhaus` and personal-account creation 403'd).

## One-time eject (≈2 minutes, from the workshop main checkout)

1. Create the empty repo on GitHub: <https://github.com/organizations/nebelhaus/repositories/new>
   → name `flick`, description "flick — a quiet, scriptable notification
   compositor for macOS", **no** README/license/gitignore (this tree has
   them).

2. Move the tree out and push it:

   ```sh
   cd ~/code/workshop        # the workshop main checkout, this branch merged
   git mv incubator/flick /tmp/flick-eject 2>/dev/null || mv incubator/flick /tmp/flick-eject
   cd /tmp/flick-eject
   git init -b main
   git add -A
   git commit -m "flick: scaffold the quiet notification compositor

   Compositor architecture (queue-owns-state, disposable panels), socket
   provider + CLI, pure policy engine with hot-reloaded rules, quarantined
   experimental System Mirror probe, sqlite history, tests for geometry/
   policy/pipeline. Scaffolded in the workshop incubator; see README,
   ARCHITECTURE, PRD."
   git remote add origin git@github.com:nebelhaus/flick.git
   git push -u origin main
   mv /tmp/flick-eject ~/code/workshop/flick   # its place in the family dir
   ```

3. Back in the workshop repo: delete `incubator/` (this file goes with it),
   add `/flick/` to `.gitignore` next to the other family repos, and commit.
   (The routing-table row for flick already landed with this branch.)

4. Delete this BOOTSTRAP.md from the new repo once ejected — it's about the
   incubator, not about flick.

## First verification on a Mac

```sh
cd ~/code/workshop/flick
xcodebuild -project Flick.xcodeproj -scheme Flick \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO test
```

The scaffold was written in a Linux cloud session — it has **not** been
through a Swift compiler yet. Expect a short round of compile fixes (Swift 6
strict-concurrency niggles are the likely suspects) before the tests run;
the test files state intent precisely enough to fix against.

Then feel it: run Flick.app, `flick ping`, `flick send --title hello`.

## Wiring into the family (later, separate PRs)

- **rice** (`nebelhaus`): a `modules/flick` room — launchd/login-item
  wiring, `flick` CLI shim on PATH, nebelung palette hookup.
- **web**: a docs page at nebelhaus.com/flick.
- **workshop**: routing-table row (already in this branch's CLAUDE.md edit).
- **homebrew-tap / release.yml**: only when the first release is cut
  (CalVer via `bench release flick`); `nix/release.nix` carries a
  placeholder until CI stamps it.
