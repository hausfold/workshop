# AGENTS.md

**The hausfold workshop** — the parent directory holding every repo in the
hausfold family, plus `bench`, the script that moves changes between them. It
owns the README, this file, `bench` (+ `_bench`, its zsh completion), `docs/`,
`script/`, `assets/`, `test/`, `.agents/`, `FOUNDING.md` and `LICENSE`; the
subdirectories are independent git repos.

`FOUNDING.md` is public on purpose and does not route to `ops`: the wording
lives here, the roster in `ops`, and a tester's name nowhere but the `THANKS.md`
they chose. This file is the one set of instructions for every agent; per-client
wiring lives in [`.agents/`](./.agents/README.md).

## Naming

- **`haus`** is the nix-darwin layer: the `haus.*` namespace, the CLI verb, the
  repo `hausfold/haus` at `./haus`, the page `hausfold.co/haus`. **`hausfold`**
  is the org, never the layer; a bare `hausfold` is the org, the brand or a
  bundle id (`GH_ORG="hausfold"`, `com.hausfold.*`, `hausfold.co`). Grep the
  bare word separately from `haus.` — a desktop file's top-level key is
  `{ haus = { … }; }`, no dot.
- The desktop the layer ships is **`hacker`**. Say **desktop**, not "rice",
  which survives only in quotations, URLs, filenames and code identifiers.

**`_bench` is a hand copy and can rot.** It reaches fpath by
`ln -s ~/code/workshop/_bench ~/.zsh-completions/_bench`; `exec zsh` reloads it,
and its descriptions follow `bench`'s usage header (`bench:2-54`). Only `FAMILY`
and `OVERRIDABLE` are sed'd out of the script at completion time, and they
differ — trill, snug and factory are overridable, not family. Hand-copied:
`pull`'s nine repos bench doesn't walk (not "the non-flake ones" — trill, snug
and factory are inputs, and `ops` is private), `ship`'s four extras (trill, snug,
factory, consumer; `LOCK_ONLY` derives from `EDGES` at runtime), `release`'s
five (`version_file`'s arms), `docs-since`'s seven non-family repos, and both
fallbacks. Add a repo to `version_file` and the completion silently omits it.

## Master routing table

Every task belongs to exactly one repo. Go there first; each carries its own
`AGENTS.md`, plus a `CLAUDE.md` that is the `@AGENTS.md` import and that
client's wiring — project rules go in the former.

| Want to change… | Repo |
|---|---|
| colors / palette / how a tool is themed | `./nebelung` |
| the pounce app (UI, ranking) or a generic command script | `./pounce` |
| the perch notch file shelf (UI, staging, drag/drop) | `./perch` |
| the desktop: macOS defaults, tiling (`windows`), the menu bar (`bar`), the shell (`terminal`), Touch ID + firewall (`security`), Pounce wiring (`launcher`), the notch shelf (`shelf`), Focus/DND (`focus`) | `./haus`, the layer `hausfold/haus` — the directory is named for its repo, not its desktop |
| the org's GitHub front page | `./org-profile`, the checkout of `hausfold/.github` (`bench clone` maps the alias; `./.github` here is the workshop's CI) |
| the **trill** notification compositor (quiet banners, rules, `trill` CLI) | `./trill` ([hausfold/trill](https://github.com/hausfold/trill)). **A flake input that is not `FAMILY`**: in `OVERRIDABLE`, `EDGES` (`haus → trill`, gating `haus.notifications.compositor`), `DOCS_REPOS`, `bench clone`, `bench pull`. `bench ship` ripples its lock but never pushes it — it lands through its own PRs. `bench release trill` (CalVer, notarized ZIP, CI-owned `nix/release.nix` pin) |
| **snug** — the terminal-presentation runtime (roles, glyphs, tables, live regions) | `./snug` ([hausfold/snug](https://github.com/hausfold/snug)). Trill's footing, two edges: `haus → snug`, which `bench ship` ripples, and `factory → snug`, which moves only in factory's own PR — `bench try`'s `--override-input` does not reach inside factory's flake. **Its README and `AGENTS.md` ARE the family's presentation standard.** Not releasable: consumers pin it by rev, `bench release snug` refuses, and `VERSION` only names the derivation (`snug-0.1.0`). *How* a line is drawn is snug's repo; *whether* a tool should print it is that tool's |
| scruff — the worktree-lifecycle substrate | `./scruff` ([hausfold/scruff](https://github.com/hausfold/scruff)). A flake input of haus, on PATH; ⌘↵ runs `scruff new` for every client, and Claude Code's `WorktreeCreate`/`WorktreeRemove` hooks call `scruff hook create` / `scruff hook remove` |
| this machine's apps / identity / secrets | `~/.config/nix` (not in this dir) |
| the cross-repo workflow itself (`bench`, this README) | here |
| **the night shift** — the merge lease, tier 1, the runner that drives it | [hausfold/factory](https://github.com/hausfold/factory); its README is the manual, and haus puts it on `PATH` (`haus.ai.enable`) with its one skill, `/factory`. Trill's footing (`haus → factory`), plus the one edge bench does not walk (`factory → snug`), so `bench status`'s row names factory's own PR. Nothing about the shift lives here: the operator half is hausfold.co's `docs/haus/night-shift`, the seams `./haus`'s `docs/night-shift-internals.md`, the policy `factory config print` alone. A live lease (`factory lease status`) is the standing go-ahead for **tier-1** merges as `factory tier` decides them; the rest waits at "PR open" |
| **how one of our tools puts a line on screen** | the tool's OWN repo, through **trill**, Apple's banner as fallback — never a bare `osascript -e 'display notification …'`: haus's `haus-notify` (`modules/core/haus-notify.sh`), pounce's per-command `notify()`, `bench`'s own, `scruff hook notify`. Every caller passes its own `--source`, the string `~/.config/trill/rules.json` matches on; no `haus.*` option gates it |
| **a write-up that turned out to be wrong** — a stale claim, a check that passes while what it protects rots | [`docs/drift.md`](docs/drift.md): thirty-two numbered shapes and what catches each. **Row numbering is frozen** — cite by number. Append a shape, or park it under *Seen once, not yet a row* |
| **how one of our CLIs looks on screen** — a colour, a glyph, a column, a spinner | snug's own `README.md` and `AGENTS.md` are the standard; this repo's `docs/design.md` is the brand's, not the CLI's. Roles resolve against **nebelung**, never a hand-picked 256-colour index, and columns are budgeted with `ui_col` + `ui_trow` + `ui_table_data`, never `%-44s`. In scope: `bench`; haus's `haus.sh`, `haus-show.sh`, `focus`, `github-signal`, `haus-secret`, `awake` (prose only — `status --raw` skips the painter), `statusline.sh`, `image-preview.sh`, `lane-open.sh`; scruff; factory (`share/ui.sh` off `FACTORY_UI_SH`, plain text without it). Named exceptions: `haus-show`'s `field`, `haus set`'s picker padding (counted by haus's `test/phase-painter.bats`), the statusline's row tint. **Installers are exempt from the runtime, not the palette** — `bootstrap.sh` and `haus-activate.sh` inline snug's numbers, `haus/test/installer-palette.bats` diffs them back, and **nothing is inlined without a drift test**. Out by settled decision: maintenance and probe scripts (haus's `script/build-golden-vm.sh`, trill's `scripts/dev-install.sh`, this repo's `script/issue-labels.sh` and `script/probes/*.sh`); trill's CLI, pounce's commands and haus's ten one-file Swift helpers; anything whose stdout is another program's input (`awake --raw`, `agent-state`, `scruff-cache`, `hausrect`, `barvitals`, `hausocr`, `hausax`, `haustabs`, `agent-desktop-guard`, `haus-vm-shot`, `haus-fix`/`haus-fix-github`); rows not drawn on a terminal at all — haus's `find.sh` pads for `fzf`, which owns the window and cuts its own, and a bar plugin's `printf` is read by sketchybar; and anything with no terminal at either end (`floatpin`, `floatring`, `barpop`, `haus-notify`, `trill.sh`, `lidawake`, `haus-github-receiver`, `statusline-refresh`, `portless`, `haus-nix-gc`, `portless-lane`). **Do not collapse those into one "nobody reads these" rule** — the installers and the maintenance scripts ARE read by people at real terminals, and their exemptions rest on when they run and who reads them. **This row owns that scope** — re-open an exemption here, never by quietly converting a file |
| **how the brand looks off the terminal** — a logo, a lockup, a hue, an OG card | [`docs/design.md`](docs/design.md), the brand's visual system and binding on every repo: two registers (the house is grey and borrows, a product owns one hue), two surfaces (an artifact is Space Grotesk and dark, or latte where it is light; a page is the Mac's own faces in both themes). A desktop never has a mark. Front matter is Google Stitch's DESIGN.md format (`npx @google/design.md lint docs/design.md`). Values resolve against **nebelung**; hausfold.co's implementation is its own `AGENTS.md`. **A mark's source of record is its SVG in git** — this repo's `assets/` for the house and nebelung, the product's own for the rest, PNGs rendered from it; the *Logo system* design project is where a mark is drawn and redrawn, not where the current one lives. The doc prints the same geometry because it is the public standard, so a change to a mark changes both: in one commit for the house and nebelung, whose SVGs are here, and for a product mark in that product's PR **first**, then here — `PRODUCT_MARKS` cannot reach a file that is on no upstream `main`, and says so by failing. All of it is indexed in [`assets/README.md`](assets/README.md), the public media kit hausfold.co's `/brand` 301s onto — a mark that moves, moves there too, and `test/design-palette.bats` diffs its hexes against nebelung as it does the doc's, plus every path, transform, tile radius and alpha step in every product mark — nebelung's here, pounce's, perch's and trill's read out of their own repos — against the doc's stanza. The same file closes the doc on itself: the clearspace ratios and the minimum-size table are re-derived from the doc's own *Lockups* bullets and geometry, and the kit's short version of both is diffed back against them |
| **how an agent learns to drive one of our tools** — the `ai/SKILL.md` (and sibling `ai/<name>/SKILL.md`) an end user's agent loads, the `<tool> skill` verb, `--json`/exit codes | the tool's OWN repo, to [`docs/agent-surface.md`](docs/agent-surface.md). A `SKILL.md` is for an agent *using* the tool with no checkout, `AGENTS.md` for one working *on* it. Which skills a machine gets is `./haus`'s `haus.ai.skill` |
| **what a stranger meets when something we made breaks** — an issue form's fields, the chooser, the labels, the security link | **the generator, never the rendered file**: [`script/issue-templates.sh`](script/issue-templates.sh) writes `.github/ISSUE_TEMPLATE/` into ten repos from one table, and [`script/issue-labels.sh`](script/issue-labels.sh) is its GitHub-side half — a form's `labels:` are silently dropped if the label is missing, and the security link 404s until private vulnerability reporting is on. Design, four fields on purpose: [`docs/bug-reports.md`](docs/bug-reports.md). A hand-edit in a child repo is invisible until the weekly `issue-templates` workflow sweeps — edit the table, re-run, ship each repo. The in-product door is each app's own repo (perch's and trill's *Report a Bug…*, `trill report`, `pounce report`, `haus report` — `haus/modules/core/haus.sh`'s `cmd_report`, `exec`'d by `modules/launcher/commands/report-issue-haus.sh`); it and that repo's `DIAG_HINT` change in the same round, since `--check` compares only generator to YAML. Third half: `haus/modules/ai/agents/hausfold/SKILL.md`, naming each repo's diagnostics verb — three edits per verb. Its rules are `docs/bug-reports.md`'s *The agent route*: an explicit yes before anything is filed, offer once, the user's own words, read the block before attaching it |
| **the install one-liner** — the URL, which desktop it resolves, the ref pinning | `./hausfold.co`'s `worker.js`, only there: `curl -fsSL https://hausfold.co/hacker.sh \| bash`. The *script* is `./haus`'s `bootstrap.sh` |
| the hausfold.co site | `./hausfold.co` ([hausfold/hausfold.co](https://github.com/hausfold/hausfold.co)), **public**, keep the `.co`. Next 16 + Fumadocs, statically exported onto a Cloudflare Worker, deployed by CI on push to its `main`; `worker.js` serves the installer, download and release-metadata routes. `bench clone` fetches it; not a flake input, not `FAMILY` |
| the hausfold **name register**, the launch plan, anything still to be decided | [hausfold/ops](https://github.com/hausfold/ops), **private**: `PRESENCE.md` for the register, `todo/` for every open workstream. **Never copy it, or a summary of it, into this repo** — which names are *free* is the sensitive half; trademark findings are public records and fine. In `DOCS_REPOS`, `bench clone` and `bench pull [ops]` only, both needing its credentials — clone warns when it can't fetch, pull skips a checkout that isn't there; the dir is `.gitignore`d |
| pounce's Homebrew formula / perch's cask | `./homebrew-tap` — **CI-owned**; hand-edit only to bootstrap a new formula/cask |
| scruff's Swift SDK | `./scruff`'s `sdk/swift`. [`hausfold/scruff-swift`](https://github.com/hausfold/scruff-swift) is a generated mirror (`git subtree split --prefix=sdk/swift`) moved only by a `v*` tag, via `sdk/swift/sync-mirror.sh --tag <version>` — run by hand from scruff's `main` to publish sooner; it refuses any other branch. Never hand-edit the mirror |

## Where a write-up goes

**One fact, one place.** No `notes/` anywhere.

| kind of write-up | where |
|---|---|
| what a user reads | `hausfold.co`'s `content/docs/`, the source of truth |
| a repo's `README.md` | a **door** where the manual is elsewhere; the front page, and maybe the manual, where there is no tree on the site |
| how a thing works **now**, for someone working *on* it | that repo's `docs/<topic>.md` |
| a standard that binds every repo | this repo's [`docs/`](./docs/): `agent-surface.md`, `bug-reports.md`, `design.md`, `drift.md`, `agent-vm.md` |
| work that still has steps in it | [hausfold/ops](https://github.com/hausfold/ops)'s `todo/` |

haus, pounce, perch and scruff have trees on the site, so their `docs/` hold
contributor material only, listed per repo in
[`/docs-sync`](./.agents/skills/docs-sync/SKILL.md); never prune haus's
`docs/site-data/`, which the site's `npm run options` reads. trill's manual is
`trill/docs/`, and snug's and nebelung's READMEs are theirs, so never cut either
to a door. The test: a sentence still true after the reader has installed the
thing belongs in the manual.

1. **State what is true now, not how it got that way** — no dates, "used to",
   "was retired", or a PR number standing in for a fact. Three stay: a date
   stamping a measurement (`script/probes/**`), "used to" / "no longer" naming
   a *shape* (`docs/drift.md`, the `/docs-sync` cut-list), and a fact about a
   stale config a reader may still hold ("`adopt = false` does nothing",
   "`flick` is an older name for trill").
2. **A plan is not a doc** — mostly unchecked boxes belongs in `ops/todo/`.
3. **Fix it in the same change.**

## The one gotcha that explains everything

The repos are a chain of pinned flake inputs: the spine
`nebelung → pounce → haus → ~/.config/nix`, plus `perch`, `trill`, `scruff`,
`snug`, `factory` and `nebelung` (directly) into `haus`, and `snug` into
`factory` — **ten** lock edges, enumerated in `bench`'s `EDGES`. `factory → snug`
is the one whose holder `bench ship` does not walk; that pin moves in factory's
own PR, and `bench status` still reports it. A commit, even a pushed one, is
invisible downstream until each `flake.lock` moves. **Never hand-walk that
ripple, and never suggest it** — `bench` does it:

- `bench status` — what this machine is running, every stale lock edge, dirty
  or unpushed repo and agent lane — scruff's registry, never `git worktree
  list`, filtered to the workshop dir plus the host config, so a hand-run
  `git worktree add` is not in it at all. It also prints a read-only row for
  every lock source that is not `FAMILY` (trill, snug, factory), because a
  STALE edge's next question is what that checkout is doing. It flags an
  **OFF-MAIN** edge, a lock pinned at a rev not on that
  repo's `main` — what a hand-run `nix flake update` in a PR produces. It
  resolves until the branch is deleted on merge, after which the downstream repo
  can't fetch its input at all. Land the upstream PR first, or shipping repins
  to main and silently drops that work.
- `bench try [switch]` — build, and with `switch` activate, this machine against
  the local checkouts (`--override-input`), no pushes; from a lane it
  substitutes that worktree, so `try switch` feels ONE unmerged branch. The gate
  is who, not where: an agent is refused a worktree `switch` unless
  `BENCH_AGENT_SWITCH=1`.
- `bench rebuild` — put the pinned build back. It draws a trill card while
  building (`BENCH_NO_BANNER=1` off); `try` draws one only under
  `BENCH_BANNER=1`. Activating a terminal edit is cheap and safe: Ghostty
  applies config live, and every window's shell lives in a `zmx` session that
  outlives it, so windows, sessions and live agents stay put
  (`haus.terminal.restoreWindows` reopens one window per parked session).
- `bench try-batch [switch] [repo…]` — every open PR merged onto a throwaway
  tree per repo and built in ONE rebuild, main untouched; merge only what
  passes its checklist.
- `bench try lane [switch]` — that, plus every repo a `scruff child` spawned
  from this pane, in one rebuild. Same gate.
- `bench overlap [--brief] [--path <f>]` — where the other lanes' edits and
  yours land in the same region, read from the object store. Advisory; exit 0
  clear · 3 same file · 4 same region. Flow:
  [`/earshot`](./.agents/skills/earshot/SKILL.md).
- `bench ship [repo…]` — fast-forward every checkout, then push
  upstream→downstream with a lock-bump commit at each hop. Refuses to end on
  `shipped` if an edge didn't move (three `--refresh` retries 5s apart; a rev
  not on the upstream's `origin/main` fails fast). Named repos narrow it to
  their downstream closure along `EDGES`.
- `bench pull [repo…]` — fast-forward the checkouts, or the named ones;
  `bench clone` fetches a family repo missing here.
- `bench docs-since [--mark [--pending <repo>…] | --landed [<repo>…]]` —
  commits since the docs were reconciled; the input to `/docs-sync`.
- `bench release <repo> [version] [--ship]` — under **Rules** below.

## Agent worktrees

⌘↵ runs `scruff new` for whichever client `haus.ai.default` names (`claude`,
`codex`, `opencode`, `pi`) — never `claude --worktree`, which skips scruff's
`[hooks] open`. The checkout is `~/.cache/scruff/<repo>/<name>` on branch
`worktree-<name>`, branched from the repo's **local HEAD** and outside the repo
so `bench try`'s `path:` overrides never
swallow it; closing a pane parks the dirty tree as a `wip:` commit and reaps
only merged branches. (A machine older than scruff 1.1.0 keeps its whole base at
`~/.cache/claude-worktrees`; `scruff doctor --migrate-base` moves it, refusing
with exit 2 while anything stands in the base — so run it from a pane that is
not a lane. One agent per window editing the real checkout is `c` in that
window's own shell.) `scruff` lists the lanes, `scruff <name>` (or
`scruff <repo>/<name>`) resumes one, `scruff reap` sweeps landed ones, and
`scruff reship [name]` pushes commits made after the PR merged (`live+N`).
**`scruff park [label]` / `scruff unpark` replace `git stash`** — one stash
stack is shared by every worktree of a repo.

In a worktree (`git rev-parse --git-common-dir` points outside your toplevel):

- **Commit, push and open the PR without asking.** Merging waits for the user:
  "ship / land / merge" is the go-ahead, then `gh pr merge` — never a local
  `git merge` or a direct push into `main`. The one other standing go-ahead is
  a live factory lease, tier 1 only.
- Build with `bench try` and stop; activation is the user's unless they asked.
  `bench ship` is fine from a worktree — it moves the *main* checkouts, never
  your branch, and never activates.
- `bench overlap` at lane start, before a big edit to a shared file, and before
  every `gh pr create`: `⚠` means
  move your edit or copy the printed landing order into **Watch out** verbatim;
  `·` needs nothing.
- **Pre-PR assurance pass, every PR**: a clean-context subagent gets `git diff
  main...HEAD` and the edited repo's `AGENTS.md` (checklist: ship skill **Step
  2.5**). Advisory — fix anything ≥3/5, carry the rest into **Watch out**. This
  instruction IS the user request to spawn it; with no subagent, say so.
- PR body: **What / Why / Verify / Watch out** (ship skill Step 3), so a bug
  found later is recoverable from `gh pr view` alone.
- `/ship` ([`.agents/skills/ship/SKILL.md`](./.agents/skills/ship/SKILL.md) —
  with no `/ship`, read the file and follow it) finishes the job: merge, `bench ship`, merge and `git worktree remove` every
  child worktree this session made, then — once nothing ≥3/5 needs attention,
  and without waiting on CI unless CI is the point — `cd "$main" && bench try
  switch`, report, stop. It never opens or closes a pane.
- **A workshop worktree holds only the workshop's files** — the child repos are
  not there, and not hidden by gitignore. Standing permission to make a child
  worktree with `scruff child`, never a raw `git worktree add` (it skips the
  registry, so the PR is invisible in the bar):

  ```sh
  workshop_root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
  cd "$(scruff child "$workshop_root/<repo>")"
  ```

  Commit, push and PR there without asking; after merge, `git -C
  "$workshop_root/<repo>" worktree remove …`. Report repo, branch and PR.

From the workshop's **main checkout** the worktree restrictions lift: `cd` into
a child and commit / push / ship under its own rules, since gitignored up here
says nothing about git ops down there. **Landing still goes through the PR** —
`gh pr merge`, never a local `git merge` + push to `main`. Asked for the whole
flow, batch-test first: `bench try-batch [switch]` feels every open PR in one
rebuild, main untouched; then merge only what passed, `bench ship` the ripple,
rebuild. Once the user has asked, don't re-confirm each repo word for word.

## Cloud sessions

A bare Linux container with no Nix. [`.agents/setup.sh`](./.agents/setup.sh)
installs Determinate Nix and sets `PATH` and `NIX_SSL_CERT_FILE` at the
agent-proxy CA; idempotent, no-op on macOS. Each client fires it its own way
([`.agents/README.md`](./.agents/README.md)) — with no hook, run
`./.agents/setup.sh` yourself.

- ✅ Edit modules, `nixfmt`, resolve flakes, regenerate `flake.lock` entries for
  hausfold-org inputs.
- ⚠️ A full `nix eval`/build 403s: third-party `github:` flakerefs resolve
  through `api.github.com`, and `add_repo` refuses cross-owner adds. Probe with
  `nix flake metadata github:NixOS/nixpkgs`; a real eval also wants
  `cache.nixos.org`, `channels.nixos.org` and `releases.nixos.org`.
- ✅ `git+https://github.com/…` is a plain anonymous read the proxy serves, so a
  source tree is always reachable — enough for
  `script/probes/namespace-collision.nix`, whose header carries the sparse
  clone, and for `source-shapes.sh`, which needs less still; never for
  `nix flake check`.
- ❌ `bench try switch` / `darwin-rebuild switch` — macOS only.

## Rules for working here

- **Speak in the family's verbs — in what you suggest, not just what you run**:
  `bench ship [repo…]`, `bench pull [repo…]`, `bench rebuild`, `bench try
  [switch]`; on a haus machine `haus update` / `haus rebuild` / `haus rollback`.
  Raw `nix` / `darwin-rebuild` / per-repo `git` only when no verb covers it, and
  say "no wrapper for this". For an end user of haus, `haus` is the whole
  vocabulary — a step it cannot express is a missing verb to report, never a nix
  command to paste.
- **Verify by actually running it**: `bench try`, then `bench try switch` from a
  main checkout. Testing in prod is house style.
- **Ship by default, sized to the change.** Small (bugfix, typo, config, docs):
  commit, verify, ship without asking. Big (feature, refactor, anything a user
  could feel break): verify, then ask. Unsure, ask.
- **Releases are always gated** — never `bench release` unprompted, but do
  propose one after user-facing changes to a tagged repo
  ([`/release`](./.agents/skills/release/SKILL.md)). CalVer: it stamps
  `YYYY.MM.DD` (`-N` on a same-day repeat), commits, tags `v<date>`, and CI
  publishes and bumps `homebrew-tap`, never hand-bumped. It **blocks** until the
  run ends (perch's and pounce's commit `nix/release.nix` back), exits non-zero
  if the run goes red, and fast-forwards on green. Ship, release, then
  `bench ship` again — or `--ship`.
- **`scruff` is the one semver repo, forced**: `bench release scruff 0.2.0`
  publishes five SDKs (npm, PyPI, crates.io, SwiftPM, Go proxy) on one number no
  registry lets you withdraw. `bench` refuses a version for the CalVer repos and
  demands one for scruff; deciding it means reading `git diff <last-tag>..main
  -- sdk/` — what `/release` is for.
- Commit in the repo you edited; `bench ship` refuses dirty trees. Don't
  cross-edit: a color hex in `haus`, or launchd logic in `pounce`, is the wrong
  repo even if it works.
- The life of a change: **hack** (`worktree-*`) → **test** (`bench try`) →
  **assure** (Step 2.5 + `bench overlap`) → **PR** → **batch-test** (`bench
  try-batch`) → **merge** → **try switch** → **ship** → **release**. A lone
  editor on the main checkout can drive a small fix straight to ship.
