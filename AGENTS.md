# AGENTS.md

**The hausfold workshop** — the parent directory holding every repo in the
**hausfold** family, plus the `bench` script that moves changes between them.
This folder's own repo holds the README, this file, `bench`, `web/` (the
nebelhaus.com Astro Starlight docs site + its Cloudflare Worker), plus
`assets/` and `test/`; the subdirectories are independent git repos.

> 🚨 **`nebelhaus` means four different things and only one of them is being
> renamed.** `notes/hausfold-rename.md` is the plan of record; §2's table is the
> rule. In one line each:
>
> | spelling | what it is | this rename |
> |---|---|---|
> | `haus.<option>` | the option namespace | ✅ **already renamed** (nebelhaus#261). `nebelhaus.*` still evaluates via `modules/renamed.nix`, with a warning — never write it. |
> | **nebelhaus** bare | the **rice** — one desktop built on the platform | **stays**, forever (§6) |
> | `github.com/nebelhaus/*`, `nebelhaus.url`, `--override-input nebelhaus/…`, `GH_ORG` | the org, the repos, the flake input | **§3**, all in one sitting. Not now: a doc that names a repo before it moves 404s. |
> | `nebelhaus.com` | the domain | **§5**, with the 301s |
>
> Plus `com.nebelhaus.*` / `org.nixos.pounce` bundle ids (**§4**), the state
> dirs (`~/.local/state/nebelhaus`, deliberately held — §2.2), and
> `~/.cache/claude-worktrees/` (historical, stays). **The word alone tells you
> nothing — read the hit before you touch it**, and grep the bare word
> separately: a rice file's top-level key is `{ haus = { … }; }`, with no dot
> for a regex to find.

**This file is the one set of instructions, for every agent.** Claude Code,
Codex, OpenCode, Cursor, Copilot — TUI or GUI — all read *this*, directly or
through a one-line pointer. Nothing harness-specific belongs here; when a flow
needs per-client wiring (a hook, a slash command), the wiring lives in that
client's own file and the *content* stays here or in `.agents/`. The full map of
which tool reads which file is [`.agents/README.md`](./.agents/README.md).

## Master routing table

Every task belongs to exactly one repo. Go there first; each carries its own
`AGENTS.md` with the deep rules (and a `CLAUDE.md` beside it that is nothing but
an `@AGENTS.md` import — put rules in the former, never the latter).

| Want to change… | Repo |
|---|---|
| colors / palette / how a tool is themed | `./nebelung` |
| the pounce app (UI, ranking) or a generic command script | `./pounce` |
| the perch notch file shelf (UI, staging, drag/drop) | `./perch` |
| the rice: macOS defaults, tiling (prowl), bar (sill), shell (hearth), Touch ID (collar), pounce wiring | `./hausfold` — the platform repo `hausfold/hausfold`. **The directory was `./nebelhaus` until 2026-08-09**; the repo moved and was renamed in the org migration, and the checkout followed. The *rice* is still called nebelhaus (§6) — the directory is named for its repo, not for the rice. |
| the org's GitHub front page | `./org-profile` — the checkout of the `hausfold/.github` repo (`bench clone` maps the alias `org-profile` to it, which is why the dir isn't named `.github`; this repo's own `./.github` is the workshop's CI) |
| the **trill** notification compositor (quiet banners, rules, `trill` CLI) | `./trill` — its own repo now ([hausfold/trill](https://github.com/hausfold/trill)), ejected from the incubator 2026-08-09. Called **flick** until 2026-08-08. **Deliberately not a family repo**: it is not in `bench`'s `FAMILY` and carries no lock edge (§9 of `notes/hausfold-rename.md` — that name must never appear there), so `bench status`/`ship` don't see it and `bench clone` doesn't fetch it. The rice will consume it as a leaf overlay, which is not the same thing as joining the ripple chain. |
| holt — the worktree-lifecycle substrate (a Go rewrite of the rice's old bash `wt.sh`) | `./holt` — its own repo now ([hausfold/holt](https://github.com/hausfold/holt)), ejected from the incubator 2026-08-03 with all 79 acceptance tests green. The rice takes it as a flake input and ships it on PATH; ⌘A runs `holt new` ([nebelhaus#200](https://github.com/nebelhaus/nebelhaus/pull/200)) and the Claude Code `WorktreeCreate`/`WorktreeRemove` hooks in `~/.claude/settings.json` are repointed at `holt hook create` / `holt hook remove`, so **holt is the live path end to end**. `wt.sh` has since been retired entirely ([nebelhaus#245](https://github.com/nebelhaus/nebelhaus/pull/245)) — there is no fallback to roll back to. |
| this machine's apps / identity / secrets | `~/.config/nix` (not in this dir) |
| the cross-repo workflow itself (`bench`, this README) | here |
| the nebelhaus.com install front door (`curl … init.sh`, Cloudflare Worker) | `./web` |
| the hausfold.co site | `./hausfold.co` — **its own repo**, [hausfold/hausfold.co](https://github.com/hausfold/hausfold.co), **public**. ⚠️ **Note the `.co`.** Plain `./hausfold` is the **rice** (row above) since 2026-08-09; the site kept the longer name because each dir is named for its repo. Sending site work to the short name edits the desktop instead, and nothing errors. Split out of here 2026-08-06 as the private `hausfold/website`, then recreated public on 2026-08-08 because that repo's history couldn't be made safe ([§5.1](notes/hausfold-rename.md#51--decided-2026-08-08--one-site-repo-hausfoldhausfoldco)); `hausfold/website` is archived and stays private. Hand-written HTML on a Cloudflare Worker, deployed by CI on push to its `main`. `bench clone` fetches it; it is **not** a flake input and not part of `FAMILY`. |
| the hausfold **name register** — a handle, an account, a claimed namespace | [hausfold/ops](https://github.com/hausfold/ops), **private**, `PRESENCE.md`. Moved out of the site repo 2026-08-08 so the site repo could go public. ⚠️ **Never copy it, or a summary of it, into this repo** — the workshop is public, and the gaps are the sensitive half. |
| pounce's Homebrew formula / perch's cask | `./homebrew-tap` — **CI-owned**; hand-edit only to bootstrap a new formula/cask |
| holt's Swift SDK | `./holt`'s `sdk/swift` — same as any other holt change. [`hausfold/holt-swift`](https://github.com/hausfold/holt-swift) is a **generated mirror** (`git subtree split --prefix=sdk/swift`) that exists only because Swift Package Manager needs `Package.swift` at a repo's root for a remote git dependency — holt's own root is Go+Nix. Synced by hand today via `holt/sdk/swift/sync-mirror.sh`, then tagged separately — no CI trigger yet, so don't assume a `sdk/swift` merge alone moves the mirror. It is not cloned into this workshop and not part of `FAMILY`; never hand-edit it, changes there get overwritten on the next sync. |

## The one gotcha that explains everything

The repos form a chain of pinned flake inputs:
`nebelung → pounce → nebelhaus → ~/.config/nix`. A commit — even a pushed one —
is **invisible downstream** until each downstream `flake.lock` is updated.
Never hand-walk that ripple; the tooling does it:

- `./bench status` — leads with **what this machine is actually running**
  (the pinned build, or the local branches a `try switch` put on it), then
  every stale lock edge, dirty/unpushed repo, and agent worktree / unmerged
  `worktree-*` branch. It also flags an **OFF-MAIN** edge — a lock pinned at a
  rev that isn't on that repo's `main`, which a hand-run `nix flake update`
  inside a PR produces and `bench ship` cannot. That pin resolves until the
  branch is deleted on merge, and then the downstream repo can't fetch its
  input at all. Land the upstream PR first, *then* ship: shipping straight
  away isn't refused, it repins to main and silently drops the unmerged work
  the pin was there for.
- `./bench try [switch]` — build/run the user's machine against the **local
  checkouts** (via `--override-input`). This is how you test WITHOUT pushing.
  Worktree-aware: run from inside an agent worktree, it substitutes that
  worktree for the repo it belongs to — so a branch can prove it builds
  before anyone merges it. **`try switch` works from a worktree too** — it's
  the only way to feel ONE unmerged branch (try-batch only ever feels the
  whole open-PR queue combined, and can't see uncommitted work at all).
  The gate is on **who, not where**: an AI agent is refused a worktree switch
  unless told `BENCH_AGENT_SWITCH=1`, because activation is machine-wide and
  serial, so N parallel agents would silently overwrite each other. A person
  at the keyboard just runs it. Every switch leaves a receipt that `bench
  status` reads back, so the machine can never quietly be running a branch
  nobody remembers; `bench rebuild` puts the pinned build back and clears it.
- `./bench try-batch [switch] [repo…]` — the antidote to serial activation.
  Instead of merging a stack of ready PRs to main and *then* rebuilding to
  test them (unverified code on main before you've felt it), it merges every
  **open PR** onto a throwaway integration tree per repo, overrides the flake
  at those trees, and builds/activates the whole queue in ONE rebuild — main
  untouched. Ends with a tick-off checklist; you merge only the PRs that pass.
  Test-then-merge, not merge-then-test.
- `./bench ship` — after commits exist: fast-forwards every checkout to origin
  first (a merged PR leaves the local main behind, and a lock bump computed from
  a stale HEAD pins the pre-merge rev while reporting success), then pushes
  upstream→downstream, running `nix flake update` + a lock-bump commit at each
  hop. It re-reads each lock afterwards and refuses to end on `shipped` if an
  edge didn't actually move, so a silent no-op ripple can't pass for a real one.

**Iterating on a zellij edit — two cases, and only one of them costs anything.**

- **`config.kdl` (keybinds, theme, options) hot-reloads — just `bench try
  switch`.** zellij watches its active config and applies most fields to the
  *running* server in about a second; tabs, panes and live agent sessions stay
  put. This works only because hearth installs `~/.config/zellij/config.kdl` as
  a real file with a live mtime rather than a home-manager symlink: zellij gates
  the reload on mtime, and every `/nix/store` file is stamped epoch 1, so a
  symlinked config makes each rebuild look *older* than what zellij already read
  and nothing reloads. That stat is why rebuilds used to need `zellij
  delete-all-sessions`, and why `Super r`/`zreload` existed at all (both now
  removed).
- **Plugin `.wasm`, a patched zellij binary, and layout changes to tabs that
  already exist do NOT hot-reload** — a running server caches plugin wasm in
  memory for its whole lifetime, so these need a fresh server. Use **`zscratch`**
  — a rice dev CLI (`hausfold/modules/den`, next to `holt`, on PATH) that renders
  your candidate over a copy of the live `~/.config/zellij` into a temp
  `--config-dir` and boots a throwaway session in its own Ghostty window, so the
  working multiplexer is untouched (`zscratch --config`/`--layout`/`--theme
  FILE`, `--plugin tab-bar=WASM`, `--bin /path/to/zellij`; `zscratch clean` reaps
  it). Feel it there; the real `bench try switch` happens once, at the end. It's
  not a `bench` command — the full flag set + the permission-cache gotchas live
  in the [rice's
  AGENTS.md](https://github.com/hausfold/hausfold/blob/main/AGENTS.md) and the
  `zscratch.sh` header ([nebelhaus#69](https://github.com/nebelhaus/nebelhaus/pull/69)).

## Agent worktrees (parallel agent sessions)

Agent panes spawned with `Super a` (⌘A) run whichever client
`haus.agents.default` names — `claude`, `codex` or `opencode`. Claude Code
is the only one that can make its own worktree (`claude --worktree`, its native
flag, which fires the `WorktreeCreate` hook → **`holt hook create`**); for Codex
and OpenCode the keybind runs **`holt new`** instead, producing the identical
checkout from the outside. Either way the session gets its own checkout under
`~/.cache/claude-worktrees/<repo>/<name>` (the path name is historical — every
client shares it) on branch `worktree-<name>`, branched from the repo's **local
HEAD**. The plumbing is `holt` — a standalone, repo-agnostic, client-agnostic Go
tool with [its own repo](https://github.com/hausfold/holt), which the **rice**
takes as a flake input and ships on PATH. It isn't part of `bench`, because the
rice already ships the agent keybinds — and not every machine running `holt` has
the workshop. Worktrees live OUTSIDE the repos so trees stay clean and `bench
try`'s `path:` overrides never swallow them. (`Ctrl Alt Shift a` is the in-place
variant: the one agent per tab allowed to edit the real checkout.)

Its bash predecessor `wt.sh` (`hausfold/modules/den/wt.sh`) has been retired
entirely — `holt` is the only worktree-lifecycle tool the family ships, and
every caller (Claude Code's hooks, pounce's Spawn Agent, `bench status`) is
already on it.

**Closing a pane never loses work, and every session is resumable.** `holt`'s
remove path parks any uncommitted edits as a WIP commit on the branch before
deleting the checkout (only *merged* branches get reaped), so the checkout dir
is disposable — the branch + your client's transcript are the real persistence.
Run `holt` to list every parked/live agent worktree across **all** repos, and
`holt <name>` (or `holt <repo>/<name>`) to rebuild a parked checkout and drop
back into the client that worktree was made with (`claude --resume`, `codex
resume`, `opencode --continue` — `holt` recorded which). This is `holt`'s job,
not `bench`'s; `bench status` only *reports* family worktrees, reading that same
registry to tell a real parked session from a branch that outlived its PR.

**Setting work aside uses `holt park`, never `git stash`.** The stash stack lives
in the shared `.git` dir, so every worktree of a repo *and* the main checkout pop
the same stack — parallel agents clobber each other there. `holt park [label]`
commits the whole dirty tree as one `wip:` commit on your branch alone (the
on-demand form of what the remove hook does); `holt unpark` rewinds it, putting
the changes back uncommitted. It refuses to unpark a wip commit you've already
pushed, so it can never turn into a force-push.

**A session that keeps committing after its PR merged needs `holt reship`.**
GitHub deletes the head branch on merge, so those later commits have no remote
and no PR — and `holt` deliberately won't reap that branch. It marks the session
`+N` in the state column (`live+3`), and `holt reship [name]` pushes the branch
and opens the follow-up PR.

If YOU are running in a worktree (check: `git rev-parse --git-common-dir`
points outside your toplevel):

- **Committing, pushing, and opening the PR are standing permission — just do
  all three, never ask first.** The default answer to "want me to commit / push
  / open a PR?" is always yes, so don't ask the question — do the work and report
  the PR link. The ONLY step that waits for me is *merging* the PR (see below);
  everything up to "PR is open" is yours to drive unprompted, in default mode.
- Commit on your `worktree-*` branch as usual; verify with `./bench try` (it
  builds against your branch automatically).
- **`bench ship` is allowed from a worktree** — standing permission, default
  mode, no need to ask. It only pushes already-committed work and never
  activates: `cmd_ship` operates on the *main* checkouts, so it ripples
  merged/released upstream work downstream — it does **not** push your unmerged
  `worktree-*` branch. Use it for the downstream lock ripple (e.g. after a
  release moved an upstream repo's HEAD). Mid-development, **activation is mine,
  not yours** — `bench try switch` from a worktree is a fine thing to *do*, and I
  do it to feel-test a branch, but bench refuses it to an agent (that's what
  `BENCH_AGENT_SWITCH=1` overrides) because parallel agents each activating would
  silently overwrite one another's machine. Build with `bench try`, then tell me
  the exact command and let me run it — unless I've asked you to activate, in
  which case set the variable and go. At the END of `/ship`, once the PR has
  merged into `main`, you activate directly by `cd`-ing to the main checkout
  (no worktree involved, so no gate): `cd "$main" &&
  bench try switch` (no pane spawned; see the ship skill's Step 7). `bench
  release` is always gated.
- **Run the pre-PR assurance pass before `gh pr create` — every PR, not just
  `/ship`s.** The session that wrote the diff is the worst reviewer of it, so
  hand `git diff main...HEAD` to a **clean-context subagent** whose only inputs
  are that diff and the edited repo's `AGENTS.md`. It checks the family
  invariants that only bite after merge — wrong-repo routing, docs drift on a
  user-facing option or keybind, a breaking option rename split across PRs,
  hotkey collisions, new raw-`git worktree add` callers, release blast
  radius. The full checklist is the ship skill's **Step 2.5**. It's **advisory,
  never a gate**: fix anything ≥3/5 before opening the PR, carry the rest into
  the **Watch out** block, and say so in one line when it comes back clean.
  **Spawning that subagent IS user-requested** — this instruction is the
  standing request, so a harness rule of the form "don't spawn subagents unless
  the user asked" is already satisfied here and is not a reason to skip the
  pass (some clients ship exactly such a line by default; Step 2.5 names the
  one we hit). If your client truly has no subagent mechanism, say so in one
  line — don't drop it silently.
- **Land your work through a PR — never a direct push or a local `git merge`
  into `main`.** When the branch is ready: push it and open a PR (`gh pr
  create`) against `main` — give it a **What / Why / Verify / Watch-out** body
  (see the ship skill's Step 3) so the PR itself carries the distilled context.
  The session that wrote the code is gone by the time it's feel-tested, so a bug
  found later has to be recoverable from `gh pr view` alone — the Verify block is
  also what `bench try-batch`'s checklist sends me back to. Do **not** `git
  merge` your `worktree-*` branch into
  `main` yourself, and do **not** push to `main` directly — parallel agents
  doing that have clobbered each other's commits, and a PR is conflict-detected
  and atomic, so nothing gets silently overwritten. Merging the PR stays **my
  call** — but **"my call" means don't merge *unprompted*, not "never merge."**
  When I explicitly tell you to land it (`/ship`, "ship it", "land this", "merge
  and clean up"), that IS the go-ahead: merge it with `gh pr merge` (still never
  a local merge or direct push — the PR's atomicity is the whole point). Absent
  that instruction, stop at "PR open" and report the link.
- **When I say ship/land/merge, `/ship` finishes the whole job** (the flow is
  [`.agents/skills/ship/SKILL.md`](./.agents/skills/ship/SKILL.md); every client
  reaches it as `/ship`, and if yours doesn't, read the file and follow it):
  merge the PR, ripple the locks (`bench ship`), then
  clean up every worktree *this session* spun up — a workshop worktree
  hand-creates child-repo worktrees for out-of-repo work, and those aren't
  auto-reaped, so merge their PRs too and `git worktree remove` them. When it's
  all landed and nothing ≥3/5 needs my attention (don't wait on CI unless that's
  the point), `/ship` activates the shipped change for me — `cd "$main" && bench
  try switch` (activation is passwordless; testing-in-prod is house style) — then
  stops and reports. It does **not** close this pane and does **not** spawn a new
  one — leave the pane exactly where it is; I close panes myself. The now-merged
  worktree is **not** reaped here (you're still sitting in it) — it's cleaned up
  when I close the pane, or by a later `holt reap`.
- When done, push the branch, open the PR, and — if I didn't say ship — tell me
  the PR link. The worktree dies with the pane; the branch + PR survive until
  merged (and `bench status` nags about the branch).

**A worktree is of whichever repo the pane sat in — and a *workshop* worktree
cannot see the child repos.** Check `git rev-parse --git-common-dir`: if it
points at `…/workshop/.git` (this repo), your tree holds ONLY the workshop's
own files (`README.md`, `AGENTS.md`, `bench`, `assets`, `web/`). The family
sub-repos — the platform (`hausfold/`), `nebelung/`, `pounce/`, `perch/`, `holt/`,
`trill/`, `hausfold.co/`, `org-profile/`, `homebrew-tap/` — are **not here at all.** This is
**NOT** a `.gitignore`
visibility problem, and re-reading the ignore file won't change it: a linked
worktree of the workshop simply never checks out the sibling repos, because each
is an independent repo that lives only beside the workshop's main checkout.
So the moment a task turns out to belong to a child repo (per the routing table),
don't grep, edit, or hunt for those files in *this* tree, and don't report them as
"hidden by gitignore." **You have standing permission — no need to ask — to make a
dedicated worktree of that child repo and do the work there.** That's the default
path from a workshop worktree; use `holt child` — **not** a raw `git worktree add`:

```sh
workshop_root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
cd "$(holt child "$workshop_root/<repo>")"
```

`holt child` does the `git worktree add` **and registers it** with this pane as the
parent, so the statusline HUD can see the child's PR — a raw `git worktree add`
skips the registry, and the refresher then never queries that repo's GitHub, so
the PR is invisible in the bar (this is a real gotcha we hit). It names the child
after this pane's own worktree and prints only the new checkout path, so the
`cd "$(…)"` above drops you straight into it.

Then work, commit on the `worktree-<name>` branch, and — when the change is
ready — push it and open a PR against that child repo, all without asking. A
child worktree isn't auto-reaped on pane close, so remove it after merge
with `git -C "$workshop_root/<repo>" worktree remove …`. Tell me the child repo,
the branch, and the PR when you're done. (Editing the child's main checkout
directly is the fallback only if I ask for it — the isolated worktree is
preferred.)

## Working from the workshop's main checkout

Not a worktree, not a cloud session — this is where most work happens, and the
worktree/cloud restrictions above do **not** apply here. The child repos
(`hausfold`, `nebelung`, `pounce`, `perch`, `holt`, `trill`, `org-profile`,
`homebrew-tap`, `hausfold.co`) are
`.gitignore`d by the workshop **only to keep the outer tree clean** — each is a
full, independent repo I own solo, and from the main checkout you drive it
end-to-end:

- To change a child, `cd` into it and commit / push / ship it normally, under
  its own agent instructions and the ship-by-default policy. A child being gitignored
  *up here* says nothing about committing *down there* — that's a different
  repo, and it is **not** a signal that git ops there are risky or need extra
  confirmation. Don't downgrade a solo repo to "ask first" just because it
  nests inside this one.
- When I ask for the whole flow — **batch-test first**: `bench try-batch [switch]`
  builds every open `worktree-*` PR together in one rebuild (main untouched —
  test-then-merge, not merge-then-test), so you feel the whole queue *before*
  landing anything; then merge only the PRs that pass, `bench ship` the ripple,
  rebuild — run it straight through across every repo it touches. (Skip straight
  to merge only when there's a single PR, or I've already felt them.) Land each
  branch by merging its **PR** (`gh pr
  merge`), never a local `git merge` + push to `main` — the PR is what keeps two
  agents' branches from clobbering each other, even in a batch merge. "Merging is
  my call" means don't merge *unprompted*; once I've asked, don't stop to
  re-confirm each repo word-for-word. That per-repo hand-holding is the exact
  friction this whole router dir exists to remove.

## Cloud sessions (Claude Code on the web, Codex cloud, any container)

Cloud sessions boot a bare Linux container with **no Nix**. The whole stack is a
flake, so without Nix you get "nix isn't on this box" the moment you touch a
lock. [`.agents/setup.sh`](./.agents/setup.sh) is the one bootstrap for every
harness: it installs Determinate Nix, puts it on `PATH`, and exports
`NIX_SSL_CERT_FILE` at the agent-proxy CA, because Nix's fetches tunnel through
that proxy (TLS re-terminated) and fail verification otherwise. It no-ops on
macOS and wherever Nix already exists, so a local session costs nothing.

Each client fires it its own way — Claude Code's `SessionStart` hook in
`.claude/settings.json`, Codex's `.codex/hooks.json`, OpenCode's plugin in
`.opencode/plugins/` — all pointing at that same script (see
[`.agents/README.md`](./.agents/README.md)). If your harness has no hook, run
`./.agents/setup.sh` yourself before touching a flake; it's idempotent.

What a cloud session **can** do, and its hard limits (all found the hard way):

- ✅ Edit modules, `nixfmt`, read/resolve the flakes.
- ✅ Regenerate `flake.lock` entries for **nebelhaus-org inputs** (pounce,
  nebelung) — those repos are in the session's GitHub scope.
- ⚠️ **Full `nix eval`/build won't run under the default org-scoped access.**
  A flake pulls nixpkgs / nix-darwin / home-manager / catppuccin from
  *third-party* GitHub orgs, Nix fetches them through the session's GitHub gate,
  and `add_repo` refuses cross-owner adds — so you can't grant them one by one.
  It needs an environment whose **network policy allows general `github.com`
  egress** plus the Nix caches (`cache.nixos.org`, `channels.nixos.org`,
  `releases.nixos.org`). Sanity-check with `nix flake metadata github:NixOS/nixpkgs`:
  if it 403s with "use add_repo", the policy is still too tight for a full eval.
- ❌ `bench try switch` / `darwin-rebuild switch` never run here — macOS only.
  Activation is always a job for the local machine, at its keyboard.

So cloud is for **editing + own-org lock bumps**, not for building or switching.

## Rules for working here

- **Verify by actually running it.** `./bench try` to build, then
  `./bench try switch` to activate on the machine — testing in prod is the
  house style, and `darwin-rebuild` is passwordless, so drive the whole loop
  yourself **from a main checkout**. From an agent *worktree* you build with
  `bench try` and stop: `try switch` there is mine to run (bench refuses it to
  an agent — see the `try` bullet above), while `bench ship` IS allowed from a
  worktree.
- **Ship by default, sized to the change.** `./bench ship` pushes to GitHub.
  Small stuff — bugfixes, typos, config/theme tweaks, docs — commit, verify,
  ship, without asking; a verified fix left unpushed is a bug here. Big
  stuff — new features, refactors, anything users could feel break — verify
  it works, then stop and ask before shipping. When unsure which bucket, ask.
- **Releases are always gated.** `./bench release` puts a version in real
  users' hands (tag → CI → homebrew, or → five package registries). Never run
  it unprompted — but DO propose one after shipping user-facing changes to a
  tagged repo. Nudging is expected; tagging is the user's call. The flow is
  [`.agents/skills/release/SKILL.md`](./.agents/skills/release/SKILL.md),
  reachable as `/release`.
- Commit in the repo you edited; `bench ship` refuses dirty trees on purpose
  (commit messages are yours/the user's, lock bumps are its).
- **Releases ride tags, not pushes.** Versions are **date-based** (CalVer):
  `./bench release pounce` stamps today's date — `YYYY.MM.DD`, or `YYYY.MM.DD-N`
  on a same-day repeat — into the repo's version source, commits it, and tags
  `v<date>`; CI then publishes the GitHub release and bumps `homebrew-tap`. No
  version number is ever typed by hand — the date IS the version, so there's
  nothing to bump before releasing. Never hand-bump the formula's url/sha lines.
  Ship first, then release (the date-stamp moves HEAD, so `bench ship` again
  afterward to ripple that lock downstream — or `bench release <repo> --ship`
  to do both). **`bench release` BLOCKS** until the CI run finishes, drawing
  its jobs live, and exits non-zero if the run goes red. That wait is
  load-bearing, not decoration: perch's run commits `nix/release.nix` back to
  the repo, so returning early would leave a checkout behind origin and
  a `bench ship` that ripples a superseded rev. It fast-forwards for you when
  the run goes green.
- **`holt` is the one semver repo, and it's forced, not chosen:**
  `./bench release holt 0.2.0`. It publishes five SDKs to npm, PyPI, crates.io,
  SwiftPM and the Go proxy; three of those already hold `0.1.0` and none of
  them ever let a published number be withdrawn, so the version is a
  compatibility contract rather than a date — and CalVer would additionally
  force the Go SDK's import path to end in `/v2026`, changing every January.
  All five SDKs share the one number (five clients agreeing about one wire
  format is the invariant the SDK CI job protects). `bench` refuses a version
  argument for the CalVer repos and refuses to run without one for holt.
  Deciding the bump means reading `git diff <last-tag>..main -- sdk/` against
  the published SDK surface — that judgement is what `/release` is for.
- Don't cross-edit: a color hex in `nebelhaus`, or launchd logic in `pounce`,
  is in the wrong repo even if it would work. Each repo's own agent instructions
  enforce its boundary — respect it from up here too.
- The whole life of a change: **hack** (agents draft on `worktree-*` branches)
  → **test** (`bench try`, worktree-aware — and `bench try switch` from that same
  worktree when I want to *feel* one branch alone; that switch is mine to run)
  → **assure** (a clean-context subagent reads `git diff main...HEAD` against the
  repo's own `AGENTS.md`; advisory, ship skill Step 2.5)
  → **PR** (the worktree agent pushes
  its branch and opens a PR against `main`) → **batch-test** (main checkout only:
  `bench try-batch` feels the whole review queue — every open PR — in ONE rebuild,
  main untouched; the antidote to landing unverified code) → **merge** (I review
  and merge on GitHub — or, when I say `/ship`, the agent merges its own PR with
  `gh pr merge`; either way, never a direct push or local `git merge` into `main`)
  → **try switch** (on main, now that it holds the work) → **ship** → **release** (tagged repos
  only; CI does the rest). A single in-place agent editing the *main* checkout
  directly (the `Ctrl Alt Shift a` mode, or a plain non-worktree session) can
  still drive a small fix straight through **ship** — the PR rule exists to keep
  *parallel* branches from clobbering each other, not to gate a lone editor on
  main; features pause for the user before ship; **release** always waits for
  the user.
