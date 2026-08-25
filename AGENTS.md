# AGENTS.md

**The hausfold workshop** — the parent directory holding every repo in the
**hausfold** family, plus `bench`, the script that moves changes between them.
This repo owns the README, this file, `bench` (+ `_bench`, its zsh completion),
`notes/`, `docs/`, `assets/`, `test/`, `.agents/` and `LICENSE`. The
subdirectories are independent git repos.

**This file is the one set of instructions, for every agent** — Claude Code,
Codex, OpenCode, Cursor, Copilot alike, directly or through a one-line pointer.
Per-client wiring lives in that client's own file; the content stays here or in
[`.agents/`](./.agents/README.md).

## Naming

- **`haus`** is the nix-darwin **layer** — the `haus.*` option namespace, the
  CLI verb, the repo `hausfold/haus` at `./haus`, and the page
  `hausfold.co/haus`. **`hausfold`** is the org, the maker and the seller, never
  the layer. A bare `hausfold` hit is the org, the brand or a bundle id:
  `GH_ORG="hausfold"`, `com.hausfold.*` and `hausfold.co` all stand. Grep the
  bare word separately from `haus.` — a desktop file's top-level key is
  `{ haus = { … }; }`, with no dot for a regex to find.
- The desktop the layer ships is **`hacker`**.
- Say **desktop**, not "rice", for an installable `{ haus = { … }; }`
  configuration. Preserve "rice" only in quotations, URLs, filenames and code
  identifiers; never introduce it into new prose.

> **`_bench` is a hand copy and can rot.** It reaches fpath by
> `ln -s ~/code/workshop/_bench ~/.zsh-completions/_bench` (haus's terminal room
> prepends that dir); `exec zsh` reloads it. Its subcommand descriptions must
> follow `bench`'s own usage header (`bench:2-50`). Only `FAMILY` and
> `OVERRIDABLE` are drift-proof — `_bench` seds those two single-line arrays out
> of the script at completion time. Everything else is copied by hand: `pull`'s
> six non-flake names, `release`'s four repos (the arms of `version_file`),
> `docs-since`'s five non-family repos (`DOCS_REPOS` is composed from `FAMILY`,
> so the sed reads the nested expansion back literal and can't be used), and the
> fallbacks beside both sed'd lists. Add a repo to `version_file` and the
> completion silently omits it.

## Master routing table

Every task belongs to exactly one repo. Go there first; each carries its own
`AGENTS.md` with the deep rules (and a `CLAUDE.md` beside it that is the
`@AGENTS.md` import plus that client's wiring — put *project* rules in the
former, never the latter).

| Want to change… | Repo |
|---|---|
| colors / palette / how a tool is themed | `./nebelung` |
| the pounce app (UI, ranking) or a generic command script | `./pounce` |
| the perch notch file shelf (UI, staging, drag/drop) | `./perch` |
| the desktop: macOS defaults, tiling (`windows`), the menu bar (`bar`), the shell (`terminal`), Touch ID + firewall (`security`), Pounce wiring (`launcher`), the notch shelf (`shelf`), Focus/DND (`focus`) — rooms are named for what they do | `./haus` — the layer `hausfold/haus`. The directory is named for its repo, not for the desktop it carries |
| the org's GitHub front page | `./org-profile` — the checkout of `hausfold/.github` (`bench clone` maps the alias; this repo's own `./.github` is the workshop's CI) |
| the **trill** notification compositor (quiet banners, rules, `trill` CLI) | `./trill` ([hausfold/trill](https://github.com/hausfold/trill)). **Deliberately not a family repo**: not in `bench`'s `FAMILY`, no lock edge, so `bench status`/`ship` don't see it. It IS in `DOCS_REPOS`, `bench clone` and `bench pull` (like `hausfold.co`) — docs coverage and lock coverage are different lists |
| holt — the worktree-lifecycle substrate | `./holt` ([hausfold/holt](https://github.com/hausfold/holt)). The layer takes it as a flake input and ships it on PATH; the ⌘↵ lane chord runs `holt new` for every client, and the Claude Code `WorktreeCreate`/`WorktreeRemove` hooks call `holt hook create` / `holt hook remove` |
| this machine's apps / identity / secrets | `~/.config/nix` (not in this dir) |
| the cross-repo workflow itself (`bench`, this README) | here |
| **a write-up that turned out to be wrong** — a stale README claim, a comment that outlived its code, a check that passes while the thing it protects rots | [`notes/drift.md`](notes/drift.md), which lives here because it binds every repo: thirty numbered shapes and, beside each, the only thing that catches it. **Row numbering is frozen** — this repo's notes and `haus`'s commit messages cite rows by number (`6bb294c`: *"§5.14 row twenty"*). Append a shape when you find one the table can't already name — or, if you can't yet say its general form, put it under *Seen once, not yet a row* and let a second sighting promote it; the passes that find them are at the bottom of that file |
| **how an agent learns to drive one of our tools** — the `ai/SKILL.md` an end user's agent loads (and any sibling `ai/<name>/SKILL.md` the tool also ships), the `<tool> skill` verb, `--json`/exit-code shape | the tool's OWN repo, to the standard in [`notes/agent-surface.md`](notes/agent-surface.md) — which lives here because it binds every repo. ⚠️ Not a repo's `AGENTS.md`: that is for an agent working **on** the tool, from a checkout; a `SKILL.md` is for an agent **using** it, on a machine with no checkout. Which skills a machine gets is `./haus`'s `haus.ai.skill` |
| **the install one-liner** — the URL, which desktop it resolves, the ref pinning | `./hausfold.co`'s `worker.js`, and only there. It is `curl -fsSL https://hausfold.co/hacker.sh \| bash`. A change to the *script* belongs in `./haus`'s `bootstrap.sh` |
| the hausfold.co site | `./hausfold.co` — [hausfold/hausfold.co](https://github.com/hausfold/hausfold.co), **public**. ⚠️ **Keep the `.co`.** Next 16 + Fumadocs, statically exported onto a Cloudflare Worker, deployed by CI on push to its `main`; `worker.js` serves the installer, download and release-metadata routes in front of the export. `bench clone` fetches it; it is **not** a flake input and not part of `FAMILY` |
| the hausfold **name register** — a handle, an account, a claimed namespace | [hausfold/ops](https://github.com/hausfold/ops), **private**, `PRESENCE.md`. ⚠️ **Never copy it, or a summary of it, into this repo** — the workshop is public, and **which names are *free* is the sensitive half**: a list of what nobody has claimed hands it to whoever reads it first. *Trademark* findings are public register records and are fine here; *availability* findings are not, whichever name they're about. `ops` is in no `bench` list — `gh repo clone hausfold/ops ~/code/workshop/ops` by hand; the dir is `.gitignore`d |
| pounce's Homebrew formula / perch's cask | `./homebrew-tap` — **CI-owned**; hand-edit only to bootstrap a new formula/cask |
| holt's Swift SDK | `./holt`'s `sdk/swift`. [`hausfold/holt-swift`](https://github.com/hausfold/holt-swift) is a **generated mirror** (`git subtree split --prefix=sdk/swift`) that exists because SwiftPM needs `Package.swift` at a repo root. **A `sdk/swift` merge alone does not move the mirror** — only a `v*` tag does, via `sdk/swift/sync-mirror.sh --tag <version>`, and mirroring + tagging IS "publishing" for SwiftPM. To get an unreleased change to a consumer sooner, run that script by hand from holt's `main` (it refuses any other branch). Never hand-edit the mirror |

## The one gotcha that explains everything

The repos form a chain of pinned flake inputs. The spine is
`nebelung → pounce → haus → ~/.config/nix`; `perch` and `holt` are inputs of
`haus` too, as is `nebelung` a second time, directly. That is **six** lock
edges, enumerated in `bench`'s `EDGES`, not the three the spine suggests. A
commit — even a pushed one — is **invisible downstream** until each downstream
`flake.lock` is updated. Never hand-walk that ripple; the tooling does it:

- `./bench status` — leads with **what this machine is actually running** (the
  pinned build, or the local branches a `try switch` put on it), then every
  stale lock edge, dirty/unpushed repo, and agent worktree / unmerged
  `worktree-*` branch. The lane table **is** holt's registry (never `git
  worktree list`), filtered to repos under the workshop dir plus the host
  config — so a hand-run `git worktree add` isn't in it at all. It also flags an
  **OFF-MAIN** edge: a lock pinned at a rev that isn't on that repo's `main`,
  which a hand-run `nix flake update` inside a PR produces. That pin resolves
  until the branch is deleted on merge, after which the downstream repo can't
  fetch its input at all. Land the upstream PR first, *then* ship — shipping
  straight away isn't refused, it repins to main and silently drops the unmerged
  work the pin was there for.
- `./bench try [switch]` — build/run the user's machine against the **local
  checkouts** (via `--override-input`). Test WITHOUT pushing. Worktree-aware:
  run from inside an agent worktree, it substitutes that worktree for the repo
  it belongs to. **`try switch` works from a worktree too** — the only way to
  feel ONE unmerged branch (try-batch only ever feels the whole open-PR queue,
  and can't see uncommitted work). The gate is on **who, not where**: an AI
  agent is refused a worktree switch unless told `BENCH_AGENT_SWITCH=1`, because
  activation is machine-wide and serial and N parallel agents would overwrite
  each other. A person at the keyboard just runs it. Every switch leaves a
  receipt `bench status` reads back; `bench rebuild` puts the pinned build back
  and clears it. Both draw **one trill card that fills up** while they build —
  counted off the store, so nix keeps its own bar on the terminal; nothing to
  build means no card at all, and no trill installed means nothing happens.
  `BENCH_NO_BANNER=1` turns it off.
- `./bench try-batch [switch] [repo…]` — merges every **open PR** onto a
  throwaway integration tree per repo, overrides the flake at those trees, and
  builds/activates the whole queue in ONE rebuild, main untouched. Ends with a
  tick-off checklist; you merge only the PRs that pass. Test-then-merge.
- `./bench try lane [switch]` — like `bench try`, but ALSO overrides every repo
  a `holt child` spawned from this same pane, walking holt's registry
  transitively, so a cross-repo lane builds and activates together in ONE
  rebuild, no PR needed. Same who-not-where activation gate.
- `./bench overlap [--brief] [--path <f>]` — what the OTHER agent lanes on this
  repo have already changed, and where their edits and yours land in the same
  region of the same file. Measured from the shared object store rather than
  declared, including the uncommitted work `git merge-tree` can't see — and
  never crediting a side with what **main already landed into it**, which
  matters because a squash merge leaves the merged lane's own commits
  unreachable, so the merge base falls behind and every line that lane shipped
  would otherwise read as work still in flight, for as long as the branch
  exists. Only a side that CONTAINS main's commit has it subtracted: a lane
  that never rebased did not inherit that work, so nothing of main's is in its
  diff to take out. Run it at
  lane start, before a big edit to a shared file, and before every `gh pr
  create`. Advisory, refuses nothing; exit 0 clear · 3 same file · 4 same
  region. Flow: [`.agents/skills/earshot/SKILL.md`](./.agents/skills/earshot/SKILL.md),
  reachable as `/earshot`.
- `./bench ship` — after commits exist: fast-forwards every checkout to origin
  first (a merged PR leaves the local main behind, and a lock bump computed from
  a stale HEAD pins the pre-merge rev while reporting success), then pushes
  upstream→downstream, running `nix flake update` + a lock-bump commit at each
  hop. It re-reads each lock afterwards and refuses to end on `shipped` if an
  edge didn't move. An edge that won't move gets three `--refresh` attempts, 5s
  apart: `github:` with no ref resolves the default branch through
  api.github.com, whose answer is edge-cached for a few seconds. A rev that
  isn't on the upstream's `origin/main` at all fails fast.

**Iterating on a terminal edit costs nothing — just `bench try switch`.**
Ghostty watches its own config and applies new keybinds, theme and options to
every running window in about a second; windows, sessions and live agents stay
put. Even a window that restarts comes back to the same scrollback, because
every window's shell lives in a `zmx` session that outlives it, and the FIRST
window of a fresh Ghostty reopens one window per parked session
(`haus.terminal.restoreWindows`, on by default). ⌘N is always a new shell; the
automatic restore stays quiet while anything is still attached — a lane,
typically — where the palette's **Restore Terminal Windows** is the answer.

## Agent worktrees (parallel agent sessions)

Agent lanes spawned with **⌘↵** run whichever client `haus.ai.default` names —
`claude`, `codex` or `opencode`. **Every client goes through `holt new`**,
including Claude (`claude --worktree` would run the client in the pane it was
launched from and never ask holt's `[hooks] open`, the seam a lane's own window
arrives through). The `WorktreeCreate`/`WorktreeRemove` hooks → `holt hook
create` / `holt hook remove` are still declared, so a hand-run
`claude --worktree` still lands in the registry; it just isn't the chord's path.
Either way the session gets its own checkout under
`~/.cache/claude-worktrees/<repo>/<name>` (the path name is historical — every
client shares it) on branch `worktree-<name>`, branched from the repo's **local
HEAD**. The plumbing is [`holt`](https://github.com/hausfold/holt) — a
standalone, repo-agnostic, client-agnostic Go tool that the layer takes as a
flake input and ships on PATH. It isn't part of `bench`: the layer already ships
the agent keybinds, and not every machine running `holt` has the workshop.
Worktrees live OUTSIDE the repos so trees stay clean and `bench try`'s `path:`
overrides never swallow them. (The in-place variant — one agent per window,
allowed to edit the real checkout — is `c` in a window's own shell.)

**Closing a pane never loses work, and every session is resumable.** `holt`'s
remove path parks any uncommitted edits as a WIP commit on the branch before
deleting the checkout (only *merged* branches get reaped), so the checkout dir
is disposable — the branch + your client's transcript are the real persistence.
Run `holt` to list every parked/live agent worktree across **all** repos, and
`holt <name>` (or `holt <repo>/<name>`) to rebuild a parked checkout and drop
back into the client that worktree was made with (`claude --resume`, `codex
resume`, `opencode --continue` — `holt` recorded which). `bench status` only
*reports* family worktrees, reading that same registry.

**Setting work aside uses `holt park`, never `git stash`.** The stash stack
lives in the shared `.git` dir, so every worktree of a repo *and* the main
checkout pop the same stack — parallel agents clobber each other there. `holt
park [label]` commits the whole dirty tree as one `wip:` commit on your branch
alone; `holt unpark` rewinds it. It refuses to unpark a wip commit you've
already pushed, so it can never turn into a force-push.

**A session that keeps committing after its PR merged needs `holt reship`.**
GitHub deletes the head branch on merge, so those later commits have no remote
and no PR — and `holt` deliberately won't reap that branch. It marks the session
`+N` in the state column (`live+3`); `holt reship [name]` pushes the branch and
opens the follow-up PR.

If YOU are running in a worktree (check: `git rev-parse --git-common-dir` points
outside your toplevel):

- **Committing, pushing, and opening the PR are standing permission — just do
  all three, never ask first.** The only step that waits for the user is
  *merging* the PR.
- Commit on your `worktree-*` branch as usual; verify with `./bench try` (it
  builds against your branch automatically).
- **`bench ship` is allowed from a worktree** — standing permission, no need to
  ask. It only pushes already-committed work and never activates: `cmd_ship`
  operates on the *main* checkouts, so it ripples merged/released upstream work
  downstream — it does **not** push your unmerged `worktree-*` branch. Use it
  for the downstream lock ripple. Mid-development, **activation is the user's,
  not yours** — bench refuses `try switch` to an agent (that's what
  `BENCH_AGENT_SWITCH=1` overrides) because parallel agents each activating
  would silently overwrite one another's machine. Build with `bench try`, then
  hand over the exact command — unless the user asked you to activate, in which
  case set the variable and go. At the END of `/ship`, once the PR has merged,
  you activate directly by `cd`-ing to the main checkout (no worktree, so no
  gate): `cd "$main" && bench try switch`. `bench release` is always gated.
- **Run `bench overlap` before every `gh pr create`, and once at lane start.** A
  `⚠` means you and another lane are in the same *region* of the same file —
  move your edit, or put the printed landing order in the PR body's **Watch
  out** block verbatim. A `·` (same file, different regions) is normal and needs
  nothing.
- **Run the pre-PR assurance pass before `gh pr create` — every PR, not just
  `/ship`s.** Hand `git diff main...HEAD` to a **clean-context subagent** whose
  only inputs are that diff and the edited repo's `AGENTS.md`. It checks the
  family invariants that only bite after merge — wrong-repo routing, docs drift
  on a user-facing option or keybind, a breaking option rename split across PRs,
  hotkey collisions, new raw-`git worktree add` callers, release blast radius.
  Checklist: the ship skill's **Step 2.5**. **Advisory, never a gate** — fix
  anything ≥3/5 before opening the PR, carry the rest into **Watch out**, say so
  in one line when it comes back clean. **Spawning that subagent IS
  user-requested** — this instruction is the standing request, so a harness rule
  of the form "don't spawn subagents unless the user asked" is already satisfied
  and is not a reason to skip it. If your client has no subagent mechanism, say
  so in one line.
- **Land your work through a PR — never a direct push or a local `git merge`
  into `main`.** Give the PR a **What / Why / Verify / Watch-out** body (ship
  skill Step 3) so it carries the distilled context: the session that wrote the
  code is gone by the time it's feel-tested, so a bug found later has to be
  recoverable from `gh pr view` alone, and the Verify block is what `bench
  try-batch`'s checklist sends the user back to. Merging stays the user's call —
  but "the user's call" means don't merge *unprompted*, not "never merge." When
  they say ship/land/merge, that IS the go-ahead: `gh pr merge` (still never a
  local merge or direct push). Absent that, stop at "PR open" and report the
  link.
- **When the user says ship/land/merge, `/ship` finishes the whole job**
  ([`.agents/skills/ship/SKILL.md`](./.agents/skills/ship/SKILL.md); if your
  client has no `/ship`, read the file and follow it): merge the PR, ripple the
  locks (`bench ship`), then clean up every worktree *this session* spun up —
  child-repo worktrees aren't auto-reaped, so merge their PRs too and `git
  worktree remove` them. When it's all landed and nothing ≥3/5 needs attention
  (don't wait on CI unless that's the point), `/ship` activates the shipped
  change (`cd "$main" && bench try switch`; activation is passwordless,
  testing-in-prod is house style), then stops and reports. It does **not** close
  this pane and does **not** spawn one. The now-merged worktree is not reaped
  here (you're sitting in it) — it goes when the user closes the pane, or on a
  later `holt reap`.

**A worktree is of whichever repo the pane sat in — and a *workshop* worktree
cannot see the child repos.** If `git rev-parse --git-common-dir` points at
`…/workshop/.git`, your tree holds ONLY the workshop's own files. The family
sub-repos — `haus/`, `nebelung/`, `pounce/`, `perch/`, `holt/`, `trill/`,
`hausfold.co/`, `org-profile/`, `homebrew-tap/`, `ops/` — are **not there at
all.** This is **NOT** a `.gitignore` visibility problem: a linked worktree of
the workshop never checks out the sibling repos, because each is an independent
repo living only beside the workshop's main checkout. So the moment a task turns
out to belong to a child repo, don't grep or hunt for those files in this tree,
and don't report them as "hidden by gitignore." **You have standing permission —
no need to ask — to make a dedicated worktree of that child repo and work
there**, with `holt child`, **not** a raw `git worktree add`:

```sh
workshop_root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
cd "$(holt child "$workshop_root/<repo>")"
```

`holt child` does the `git worktree add` **and registers it** with this pane as
the parent, so the statusline HUD can see the child's PR — a raw `git worktree
add` skips the registry, and the refresher then never queries that repo's
GitHub, so the PR is invisible in the bar. It names the child after this pane's
own worktree and prints only the new checkout path.

Then work, commit on the `worktree-<name>` branch, push and open a PR against
that child repo, all without asking. A child worktree isn't auto-reaped on pane
close, so remove it after merge with `git -C "$workshop_root/<repo>" worktree
remove …`. Report the child repo, the branch, and the PR. (Editing the child's
main checkout directly is the fallback only if the user asks.)

## Working from the workshop's main checkout

Not a worktree, not a cloud session — this is where most work happens, and the
worktree/cloud restrictions above do **not** apply. The child repos are
`.gitignore`d by the workshop **only to keep the outer tree clean**; each is a
full, independent repo the user owns solo.

- To change a child, `cd` into it and commit / push / ship it normally, under
  its own agent instructions and the ship-by-default policy. A child being
  gitignored *up here* says nothing about committing *down there* — it is **not**
  a signal that git ops there need extra confirmation.
- When asked for the whole flow — **batch-test first**: `bench try-batch
  [switch]` builds every open `worktree-*` PR together in one rebuild (main
  untouched), so you feel the whole queue *before* landing anything; then merge
  only the PRs that pass, `bench ship` the ripple, rebuild. Run it straight
  through across every repo it touches. (Skip to merge only when there's a
  single PR, or the user has already felt them.) Land each branch by merging its
  **PR** (`gh pr merge`), never a local `git merge` + push to `main`. Once the
  user has asked, don't stop to re-confirm each repo word-for-word.

## Cloud sessions (Claude Code on the web, Codex cloud, any container)

Cloud sessions boot a bare Linux container with **no Nix**. The whole stack is a
flake, so without Nix you get "nix isn't on this box" the moment you touch a
lock. [`.agents/setup.sh`](./.agents/setup.sh) is the one bootstrap for every
harness: it installs Determinate Nix, puts it on `PATH`, and exports
`NIX_SSL_CERT_FILE` at the agent-proxy CA, because Nix's fetches tunnel through
that proxy (TLS re-terminated) and fail verification otherwise. It no-ops on
macOS and wherever Nix already exists. Each client fires it its own way (see
[`.agents/README.md`](./.agents/README.md)); if your harness has no hook, run
`./.agents/setup.sh` yourself before touching a flake — it's idempotent.

What a cloud session can do, and its hard limits:

- ✅ Edit modules, `nixfmt`, read/resolve the flakes.
- ✅ Regenerate `flake.lock` entries for **hausfold-org inputs** (pounce,
  nebelung) — those repos are in the session's GitHub scope.
- ⚠️ **Full `nix eval`/build won't run under the default org-scoped access.** A
  flake pulls nixpkgs / nix-darwin / home-manager / catppuccin from *third-party*
  GitHub orgs, Nix fetches them through the session's GitHub gate, and
  `add_repo` refuses cross-owner adds. Sanity-check with `nix flake metadata
  github:NixOS/nixpkgs`: a 403 with "use add_repo" means the policy is still too
  tight, and a full eval additionally wants the Nix caches (`cache.nixos.org`,
  `channels.nixos.org`, `releases.nixos.org`).
- ✅ **But the gate is `api.github.com`, not github.com.** A `github:` flakeref
  resolves through the API and 403s; `git+https://github.com/…` is a plain
  anonymous git read, which the container's proxy serves for any public repo,
  third-party org included. So a **source tree** is always reachable even when a
  flakeref isn't: nixpkgs' pure `lib/` is one `git clone --depth 1
  --filter=blob:none --sparse` + `sparse-checkout set lib` away, 15 MB, enough to
  run haus's own `modules/lib/*.nix` through `lib.evalModules` — its real
  validator, on Linux, in seconds. That is how
  `notes/probes/namespace-collision.nix` runs from a cloud session, and
  [`source-shapes.sh`](./notes/probes/source-shapes.sh) needs less still. It does
  not make `nix flake check` reachable: haus pins all nine inputs as `github:`,
  and the darwin half needs macOS however they are spelled.
- ❌ `bench try switch` / `darwin-rebuild switch` never run here — macOS only.
  Activation is always a job for the local machine, at its keyboard.

So cloud is for **editing + own-org lock bumps + running a pure-Nix probe**, not
for building or switching.

## Rules for working here

- **Verify by actually running it.** `./bench try` to build, then `./bench try
  switch` to activate — testing in prod is the house style and `darwin-rebuild`
  is passwordless, so drive the whole loop yourself **from a main checkout**.
  From an agent *worktree* you build with `bench try` and stop; `bench ship` IS
  allowed from a worktree.
- **Ship by default, sized to the change.** `./bench ship` pushes to GitHub.
  Small stuff — bugfixes, typos, config/theme tweaks, docs — commit, verify,
  ship, without asking; a verified fix left unpushed is a bug here. Big stuff —
  new features, refactors, anything users could feel break — verify it works,
  then ask before shipping. When unsure which bucket, ask.
- **Releases are always gated.** `./bench release` puts a version in real users'
  hands (tag → CI → homebrew, or → five package registries). Never run it
  unprompted — but DO propose one after shipping user-facing changes to a tagged
  repo. Flow: [`.agents/skills/release/SKILL.md`](./.agents/skills/release/SKILL.md),
  reachable as `/release`.
- Commit in the repo you edited; `bench ship` refuses dirty trees on purpose
  (commit messages are yours/the user's, lock bumps are its).
- **Releases ride tags, not pushes.** Versions are date-based (CalVer):
  `./bench release pounce` stamps `YYYY.MM.DD` (or `YYYY.MM.DD-N` on a same-day
  repeat) into the repo's version source, commits it, and tags `v<date>`; CI
  publishes the GitHub release and bumps `homebrew-tap`. No version number is
  ever typed by hand. Ship first, then release (the date-stamp moves HEAD, so
  `bench ship` again afterward — or `bench release <repo> --ship`). **`bench
  release` BLOCKS** until the CI run finishes, drawing its jobs live, and exits
  non-zero if the run goes red. That wait is load-bearing: perch's run commits
  `nix/release.nix` back to the repo, so returning early would leave a checkout
  behind origin and a `bench ship` that ripples a superseded rev. It
  fast-forwards for you when the run goes green. Never hand-bump the formula's
  url/sha lines.
- **`holt` is the one semver repo, and it's forced, not chosen:** `./bench
  release holt 0.2.0`. It publishes five SDKs to npm, PyPI, crates.io, SwiftPM
  and the Go proxy; three already hold `0.1.0` and none of them ever let a
  published number be withdrawn, so the version is a compatibility contract
  rather than a date — and CalVer would force the Go SDK's import path to end in
  `/v2026`, changing every January. All five SDKs share the one number. `bench`
  refuses a version argument for the CalVer repos and refuses to run without one
  for holt. Deciding the bump means reading `git diff <last-tag>..main -- sdk/`
  against the published SDK surface — that judgement is what `/release` is for.
- Don't cross-edit: a color hex in `haus`, or launchd logic in `pounce`, is in
  the wrong repo even if it would work.
- The whole life of a change: **hack** (agents draft on `worktree-*` branches)
  → **test** (`bench try`, worktree-aware; `bench try switch` from that worktree
  when the user wants to feel one branch alone) → **assure** (a clean-context
  subagent reads `git diff main...HEAD` against the repo's own `AGENTS.md`;
  `bench overlap` reads the *other* lanes, the half the subagent can't see)
  → **PR** → **batch-test** (main checkout only: `bench try-batch` feels the
  whole review queue in ONE rebuild, main untouched) → **merge** (the user
  reviews and merges — or, on `/ship`, the agent merges its own PR with `gh pr
  merge`; never a direct push or local `git merge` into `main`) → **try switch**
  → **ship** → **release** (tagged repos only; CI does the rest). A single
  in-place agent editing the *main* checkout directly can drive a small fix
  straight through **ship** — the PR rule exists to keep *parallel* branches from
  clobbering each other, not to gate a lone editor on main. Features pause for
  the user before ship; **release** always waits for the user.
