# CLAUDE.md

**The nebelhaus workshop** — the parent directory holding every repo in the
[nebelhaus](https://github.com/nebelhaus) family, plus the `bench` script that
moves changes between them. This folder's own repo holds the README, this file,
`bench`, `web/` (the nebelhaus.com Astro Starlight docs site + its Cloudflare
Worker), plus `assets/` and `test/`; the subdirectories are independent git repos.

## Master routing table

Every task belongs to exactly one repo. Go there first; each has its own
CLAUDE.md with the deep rules.

| Want to change… | Repo |
|---|---|
| colors / palette / how a tool is themed | `./nebelung` |
| the pounce app (UI, ranking) or a generic command script | `./pounce` |
| the trill Messages client (UI, providers over `chat.db`) | `./trill` |
| the rice: macOS defaults, tiling (prowl), bar (sill), shell (hearth), Touch ID (collar), pounce wiring | `./nebelhaus` |
| the org's GitHub front page | `./.github` (the `nebelhaus/.github` repo; `bench clone` maps the alias `org-profile` to it) |
| this machine's apps / identity / secrets | `~/.config/nix` (not in this dir) |
| the cross-repo workflow itself (`bench`, this README) | here |
| the nebelhaus.com install front door (`curl … init.sh`, Cloudflare Worker) | `./web` |
| pounce's Homebrew formula / trill's cask | `./homebrew-tap` — **CI-owned**; hand-edit only to bootstrap a new formula/cask |

## The one gotcha that explains everything

The repos form a chain of pinned flake inputs:
`nebelung → pounce → nebelhaus → ~/.config/nix`. A commit — even a pushed one —
is **invisible downstream** until each downstream `flake.lock` is updated.
Never hand-walk that ripple; the tooling does it:

- `./bench status` — shows every stale lock edge, dirty/unpushed repo, and
  every agent worktree / unmerged `worktree-*` branch.
- `./bench try [switch]` — build/run the user's machine against the **local
  checkouts** (via `--override-input`). This is how you test WITHOUT pushing.
  Worktree-aware: run from inside an agent worktree, it substitutes that
  worktree for the repo it belongs to — so a branch can prove it builds
  before anyone merges it. `try switch` refuses from a worktree.
- `./bench try-batch [switch] [repo…]` — the antidote to serial activation.
  Instead of merging a stack of ready PRs to main and *then* rebuilding to
  test them (unverified code on main before you've felt it), it merges every
  **open PR** onto a throwaway integration tree per repo, overrides the flake
  at those trees, and builds/activates the whole queue in ONE rebuild — main
  untouched. Ends with a tick-off checklist; you merge only the PRs that pass.
  Test-then-merge, not merge-then-test.
- `./bench ship` — after commits exist: pushes upstream→downstream, running
  `nix flake update` + a lock-bump commit at each hop.

**Iterating on a zellij edit — skip the ripple entirely.** A zellij change
(`config.kdl`, a layout, a freshly-built plugin `.wasm`) doesn't even need
`bench try switch`: that restarts the `main` session and nukes every open tab.
Instead use **`zscratch`** — a rice dev CLI (`nebelhaus/modules/den`, next to
`wt`, on PATH) that renders your candidate over a copy of the live
`~/.config/zellij` into a temp `--config-dir` and boots a throwaway session in
its own Ghostty window, so the working multiplexer is untouched (`zscratch
--config`/`--layout`/`--theme FILE`, `--plugin tab-bar=WASM`; `zscratch clean`
reaps it). Feel it there; the real `bench try switch` happens once, at the end,
already knowing it works. It's not a `bench` command — the full flag set + the
permission-cache gotchas live in the [rice's
CLAUDE.md](https://github.com/nebelhaus/nebelhaus/blob/main/CLAUDE.md) and the
`zscratch.sh` header ([nebelhaus#69](https://github.com/nebelhaus/nebelhaus/pull/69)).

## Agent worktrees (parallel Claude sessions)

Claude panes spawned with `Super c` (⌘C) run `claude --worktree`: each session
gets its own checkout under `~/.cache/claude-worktrees/<repo>/<name>` on branch
`worktree-<name>`, branched from the repo's **local HEAD**. The plumbing is
`wt` — a standalone, repo-agnostic tool that ships in the **rice**
(`nebelhaus/modules/den`, next to `haus`) on PATH, wired into
`~/.claude/settings.json` as Claude Code's `WorktreeCreate`/`WorktreeRemove`
hooks (the host points the hooks at it). It lives in the rice, not `bench`,
because the rice already ships the `claude --worktree` keybinds — and not every
machine running `wt` has the workshop. Worktrees live OUTSIDE the repos so trees
stay clean and `bench try`'s `path:` overrides never swallow them. (`Ctrl Alt
Shift c` is the in-place variant: the one agent per tab allowed to edit the real
checkout.)

**Closing a pane never loses work, and every session is resumable.** `wt`'s
remove hook parks any uncommitted edits as a WIP commit on the branch before
deleting the checkout (only *merged* branches get reaped), so the checkout dir
is disposable — the branch + the Claude transcript are the real persistence.
Run `wt` to list every parked/live agent worktree across **all** repos, and
`wt <name>` (or `wt <repo>/<name>`) to rebuild a parked checkout and drop back
into `claude --resume`. This is `wt`'s job, not `bench`'s.

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
  release moved an upstream repo's HEAD). Still off-limits from a worktree:
  `bench try switch` / `darwin-rebuild switch` (activation) and `bench release`
  (always gated).
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
- **When I say ship/land/merge, `/ship` finishes the whole job** (see
  `.claude/skills/ship`): merge the PR, ripple the locks (`bench ship`), then
  clean up every worktree *this session* spun up — a workshop worktree
  hand-creates child-repo worktrees for out-of-repo work, and those aren't
  auto-reaped, so merge their PRs too and `git worktree remove` them. When it's
  all landed and nothing ≥3/5 needs my attention (don't wait on CI unless that's
  the point), `/ship` may close this pane with
  `zellij action close-pane -p "$ZELLIJ_PANE_ID"` (target the pane id, not
  whatever's focused) — but reap the merged worktree first with
  `( cd "$main" && wt reap )`: the `close-pane` kill bypasses the `wt` remove
  hook (it only fires on Claude's own graceful teardown), so a bare close leaves
  the landed checkout behind.
- When done, push the branch, open the PR, and — if I didn't say ship — tell me
  the PR link. The worktree dies with the pane; the branch + PR survive until
  merged (and `bench status` nags about the branch).

**A worktree is of whichever repo the pane sat in — and a *workshop* worktree
cannot see the child repos.** Check `git rev-parse --git-common-dir`: if it
points at `…/nebelhaus/.git` (the workshop), your tree holds ONLY the workshop's
own files (`README.md`, `CLAUDE.md`, `bench`, `assets`, `web/`). The family
sub-repos — rice (`nebelhaus/`), `nebelung/`, `pounce/`, `trill/`, `.github/`,
`homebrew-tap/` — are **not here at all.** This is **NOT** a `.gitignore`
visibility problem, and re-reading the ignore file won't change it: a linked
worktree of the workshop simply never checks out the sibling repos, because each
is an independent repo that lives only beside the workshop's main checkout.
So the moment a task turns out to belong to a child repo (per the routing table),
don't grep, edit, or hunt for those files in *this* tree, and don't report them as
"hidden by gitignore." **You have standing permission — no need to ask — to make a
dedicated worktree of that child repo and do the work there.** That's the default
path from a workshop worktree; use `wt child` — **not** a raw `git worktree add`:

```sh
workshop_root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
cd "$(wt child "$workshop_root/<repo>")"
```

`wt child` does the `git worktree add` **and registers it** with this pane as the
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
(`nebelhaus`, `nebelung`, `pounce`, `trill`, `.github`, `homebrew-tap`) are
`.gitignore`d by the workshop **only to keep the outer tree clean** — each is a
full, independent repo I own solo, and from the main checkout you drive it
end-to-end:

- To change a child, `cd` into it and commit / push / ship it normally, under
  its own CLAUDE.md and the ship-by-default policy. A child being gitignored
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

## Claude Code on the web (cloud sessions)

Web sessions boot a bare Linux container with **no Nix**. A remote-only
`SessionStart` hook (`.claude/hooks/session-start.sh`, present in each repo)
installs Determinate Nix so flake work is possible at all — without it you get
"nix isn't on this box" the moment you touch a lock. It also exports
`NIX_SSL_CERT_FILE` at the agent-proxy CA, because Nix's fetches tunnel through
that proxy (TLS re-terminated) and fail verification otherwise. The hook is
guarded on `CLAUDE_CODE_REMOTE`, so local macOS sessions no-op.

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
  Activation is always a local, main-checkout job.

So cloud is for **editing + own-org lock bumps**, not for building or switching.

## Rules for working here

- **Verify by actually running it.** `./bench try` to build, then
  `./bench try switch` to activate on the machine — testing in prod is the
  house style, and `darwin-rebuild` is passwordless, so drive the whole loop
  yourself (activation is main-checkouts-only; from a worktree you stop at
  `bench try` — no `try switch` — but `bench ship` IS allowed from a worktree).
- **Ship by default, sized to the change.** `./bench ship` pushes to GitHub.
  Small stuff — bugfixes, typos, config/theme tweaks, docs — commit, verify,
  ship, without asking; a verified fix left unpushed is a bug here. Big
  stuff — new features, refactors, anything users could feel break — verify
  it works, then stop and ask before shipping. When unsure which bucket, ask.
- **Releases are always gated.** `./bench release` puts a version in real
  users' hands (tag → CI → homebrew). Never run it unprompted — but DO
  propose one after shipping user-facing changes to a tagged repo. Nudging
  is expected; tagging is the user's call.
- Commit in the repo you edited; `bench ship` refuses dirty trees on purpose
  (commit messages are yours/the user's, lock bumps are its).
- **Releases ride tags, not pushes.** Versions are **date-based** (CalVer):
  `./bench release pounce` stamps today's date — `YYYY.MM.DD`, or `YYYY.MM.DD-N`
  on a same-day repeat — into the repo's version source, commits it, and tags
  `v<date>`; CI then publishes the GitHub release and bumps `homebrew-tap`. No
  version number is ever typed by hand — the date IS the version, so there's
  nothing to bump before releasing. Never hand-bump the formula's url/sha lines.
  Ship first, then release (the date-stamp moves HEAD, so `bench ship` again
  afterward to ripple that lock downstream).
- Don't cross-edit: a color hex in `nebelhaus`, or launchd logic in `pounce`,
  is in the wrong repo even if it would work. Each repo's CLAUDE.md enforces
  its own boundary — respect it from up here too.
- The whole life of a change: **hack** (agents draft on `worktree-*` branches)
  → **test** (`bench try`, worktree-aware) → **PR** (the worktree agent pushes
  its branch and opens a PR against `main`) → **batch-test** (main checkout only:
  `bench try-batch` feels the whole review queue — every open PR — in ONE rebuild,
  main untouched; the antidote to landing unverified code) → **merge** (I review
  and merge on GitHub — or, when I say `/ship`, the agent merges its own PR with
  `gh pr merge`; either way, never a direct push or local `git merge` into `main`)
  → **try switch** (main checkouts only) → **ship** → **release** (tagged repos
  only; CI does the rest). A single in-place agent editing the *main* checkout
  directly (the `Ctrl Alt Shift c` mode, or a plain non-worktree session) can
  still drive a small fix straight through **ship** — the PR rule exists to keep
  *parallel* branches from clobbering each other, not to gate a lone editor on
  main; features pause for the user before ship; **release** always waits for
  the user.
