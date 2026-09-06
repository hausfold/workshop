# AGENTS.md

**The hausfold workshop** — the parent directory holding every repo in the
hausfold family, plus `bench`, the script that moves changes between them. This
repo owns the README, this file, `bench` (+ `_bench`, its zsh completion),
`docs/`, `script/`, `assets/`, `test/`, `.agents/`, `FOUNDING.md` and `LICENSE`.
The subdirectories are independent git repos.

`FOUNDING.md` is public on purpose and does not route to `ops`: the promise to
the early-alpha testers lives here in the open, the roster stays in `ops`, and no
tester's name ever appears here — only in the `THANKS.md` of the repo they
tested, put there by themselves.

**This file is the one set of instructions, for every agent.** Per-client wiring
lives in that client's own file (`CLAUDE.md`, `.github/copilot-instructions.md`)
or in [`.agents/`](./.agents/README.md); project rules stay here.

## Naming

- **`haus`** is the nix-darwin layer: the `haus.*` namespace, the CLI verb, the
  repo `hausfold/haus` at `./haus`, the page `hausfold.co/haus`. **`hausfold`**
  is the org, maker and seller, never the layer; a bare `hausfold` is the org,
  the brand or a bundle id (`GH_ORG="hausfold"`, `com.hausfold.*`,
  `hausfold.co`). Grep the bare word separately from `haus.` — a desktop file's
  top-level key is `{ haus = { … }; }`, with no dot.
- The desktop the layer ships is **`hacker`**.
- Say **desktop**, not "rice", for an installable `{ haus = { … }; }`
  configuration; keep "rice" only in quotations, URLs, filenames and code
  identifiers.

**`_bench` is a hand copy and can rot.** It reaches fpath by
`ln -s ~/code/workshop/_bench ~/.zsh-completions/_bench`; `exec zsh` reloads it.
Its subcommand descriptions follow `bench`'s usage header (`bench:2-54`). Only
`FAMILY` and `OVERRIDABLE` are drift-proof (sed'd out of the script at
completion time), and they are different lists: trill, snug and factory are
overridable without being family. Everything else is copied by hand — `pull`'s
nine repos bench doesn't walk, `ship`'s four extras (trill, snug, factory,
consumer; `LOCK_ONLY` is derived from `EDGES` at runtime), `release`'s five
repos (the arms of `version_file`), `docs-since`'s seven non-family repos, and
the fallbacks beside both sed'd lists. Add a repo to `version_file` and the
completion silently omits it.

## Master routing table

Every task belongs to exactly one repo. Go there first; each carries its own
`AGENTS.md` with the deep rules and a `CLAUDE.md` that is the `@AGENTS.md`
import plus that client's wiring — project rules go in the former, never the
latter.

| Want to change… | Repo |
|---|---|
| colors / palette / how a tool is themed | `./nebelung` |
| the pounce app (UI, ranking) or a generic command script | `./pounce` |
| the perch notch file shelf (UI, staging, drag/drop) | `./perch` |
| the desktop: macOS defaults, tiling (`windows`), the menu bar (`bar`), the shell (`terminal`), Touch ID + firewall (`security`), Pounce wiring (`launcher`), the notch shelf (`shelf`), Focus/DND (`focus`) | `./haus` — the layer `hausfold/haus`. The directory is named for its repo, not for the desktop it carries |
| the org's GitHub front page | `./org-profile` — the checkout of `hausfold/.github` (`bench clone` maps the alias; this repo's own `./.github` is the workshop's CI) |
| the **trill** notification compositor (quiet banners, rules, `trill` CLI) | `./trill` ([hausfold/trill](https://github.com/hausfold/trill)). **A flake input that is not a `FAMILY` repo**: in `OVERRIDABLE`, `EDGES` (`haus → trill`, gating `haus.notifications.compositor`), `DOCS_REPOS`, `bench clone` and `bench pull`, so `bench try` builds your branch and `bench ship` ripples its lock — but `bench ship` never pushes it; it lands through its own PRs, and `bench status` prints a read-only row for it. Releasable with `bench release trill` (CalVer, notarized ZIP + CI-owned `nix/release.nix` pin) |
| **snug** — the terminal-presentation runtime (roles, glyphs, tables, live regions) | `./snug` ([hausfold/snug](https://github.com/hausfold/snug)). Trill's footing — `OVERRIDABLE`, `DOCS_REPOS`, `bench clone`/`pull`, not `FAMILY` — with two edges, `haus → snug` and `factory → snug`. `bench ship` ripples only haus's: the factory pin moves in factory's own PR, and `bench try`'s `--override-input` does not reach inside factory's flake either. **Its README and AGENTS.md ARE the family's presentation standard.** Deliberately not releasable: every consumer pins it by rev, it has no `version_file()` arm, and `bench release snug` refuses; its `VERSION` only names the derivation (`snug-0.1.0`) |
| scruff — the worktree-lifecycle substrate | `./scruff` ([hausfold/scruff](https://github.com/hausfold/scruff)). A flake input of haus, shipped on PATH; ⌘↵ runs `scruff new` for every client, and the Claude Code `WorktreeCreate`/`WorktreeRemove` hooks call `scruff hook create` / `scruff hook remove` |
| this machine's apps / identity / secrets | `~/.config/nix` (not in this dir) |
| the cross-repo workflow itself (`bench`, this README) | here |
| **the night shift** — the merge lease, what counts as tier 1, the foreman loop | the tool is [hausfold/factory](https://github.com/hausfold/factory): its README is the manual, and haus puts it on `PATH` (`haus.ai.enable`) with its two skills, `factory` and `/nightshift`. Trill's footing — `OVERRIDABLE`, `EDGES` (`haus → factory`), `DOCS_REPOS`, `bench clone`/`pull`, not `FAMILY` — and the only repo that HOLDS an edge bench does not walk (`factory → snug`), so `bench status`'s row names factory's own PR. Its reports source snug's `share/ui.sh` off `FACTORY_UI_SH` (set by its Nix wrapper) and degrade to plain text without it. Nothing about the night shift lives here: what a person sets and runs is hausfold.co's `docs/haus/night-shift`, the seams are `./haus`'s `docs/night-shift-internals.md`, and the policy is machine-local — `factory config print` is its only statement. A live lease (`factory lease status`) is the standing go-ahead for **tier-1** merges as the policy decides them; everything else waits at "PR open" |
| **how one of our tools puts a line on screen** | the tool's OWN repo, through **trill**, with Apple's banner as the fallback — never a bare `osascript -e 'display notification …'`. haus has `haus-notify` (`modules/core/haus-notify.sh`, beside a `trill` wrapper), pounce a `notify()` per command (it installs standalone), `bench` one for the verbs you walk away from, scruff `scruff hook notify`. Every caller gets its own `--source`: that string is what `~/.config/trill/rules.json` matches on. No `haus.*` option gates any of it |
| **a write-up that turned out to be wrong** — a stale README claim, a comment that outlived its code, a check that passes while what it protects rots | [`docs/drift.md`](docs/drift.md): thirty-two numbered shapes and, beside each, the only thing that catches it. **Row numbering is frozen** — docs and commit messages cite rows by number. Append a shape, or put it under *Seen once, not yet a row* until a second sighting |
| **how one of our CLIs looks on screen** — a colour, a glyph, a column, a spinner | the standard is **snug**'s own `README.md` and `AGENTS.md`; this repo's `docs/` has no CLI half (`docs/design.md` is the brand's). Colour roles resolve against **nebelung**, never a hand-picked 256-colour index. Every user-driven CLI surface aliases snug's generated roles: `bench`; haus's `haus.sh`, `haus-show.sh`, `focus`, `github-signal`, `haus-secret`, `awake` (prose only — `status --raw` never loads the painter; the bar's coffee pill parses it), `statusline.sh`, `image-preview.sh`, `lane-open.sh`; scruff imports the package; factory sources `share/ui.sh` off `FACTORY_UI_SH`. Every row with columns is budgeted from `ui_col` + `ui_trow` + `ui_table_data`, never a `%-44s`; the named exceptions are `haus-show`'s `field` and `haus set`'s picker padding (haus's `test/phase-painter.bats` counts them per file), and the statusline's row tint, a background gated on truecolor. haus's suite bans literal escapes in `haus.sh`/`haus-show.sh` and SGR colour forms outside the three painters. **Installers are exempt from the runtime, not the palette**: haus's `bootstrap.sh` and `haus-activate.sh` inline snug's numbers, and `haus/test/installer-palette.bats` diffs them back at the pinned rev — **nothing is inlined without a drift test**. Out by settled decision: maintenance and probe scripts (haus's `script/build-golden-vm.sh`, trill's `scripts/dev-install.sh`, this repo's `script/issue-labels.sh` and `script/probes/*.sh`); rows not drawn on a terminal (haus's `find.sh` pads for `fzf`; a bar plugin's `printf` is read by sketchybar); trill's CLI (Swift, cannot import the package) and pounce's commands (stdout is the launcher's input); haus's ten one-file Swift helpers (`hausdisp list` included); the stdout-is-a-parser group (`awake --raw`, `scruff-cache`, `agent-state`, `hausrect`, `barvitals`, `hausocr`, `hausax`, `haustabs`, `agent-desktop-guard`, `haus-vm-shot`, `haus-fix`/`haus-fix-github`); the no-terminal group (`floatpin`, `floatring`, `barpop`, `haus-notify`, `trill.sh`, `lidawake`, `haus-github-receiver`, `statusline-refresh`, `portless`, `haus-nix-gc`); and `portless-lane`, a preamble to a dev server that then owns the terminal. **This row owns that scope** — re-open an exemption by editing it here, never by quietly converting a file |
| **how the brand looks off the terminal** — a logo, a lockup, a hue, a banner, an OG card, a README hero | [`docs/design.md`](docs/design.md): two registers (the house — org, layer, desktops, site — is grey and borrows; a product owns one hue), two surfaces (an artifact is Space Grotesk and dark only; a page is the Mac's own faces in both themes), the ears mark, the house glyph, the tile, per-product marks and hues, typography, the lockup geometry, the page column. A desktop never has a mark; the hacker desktop's pink is an accent. The front matter is Google Stitch's DESIGN.md format (`npx @google/design.md lint docs/design.md`). Values resolve against **nebelung**; how **hausfold.co** implements it is that repo's `AGENTS.md`; the master SVGs live in the *Logo system* design project |
| **how an agent learns to drive one of our tools** — the `ai/SKILL.md` an end user's agent loads (and sibling `ai/<name>/SKILL.md`), the `<tool> skill` verb, `--json`/exit-code shape | the tool's OWN repo, to [`docs/agent-surface.md`](docs/agent-surface.md). A `SKILL.md` is for an agent *using* the tool with no checkout; `AGENTS.md` is for one working *on* it. Which skills a machine gets is `./haus`'s `haus.ai.skill` |
| **what a stranger meets when something we made breaks** — an issue form's fields, the chooser, the labels, the private security link | **the generator, never the rendered file**: [`script/issue-templates.sh`](script/issue-templates.sh) writes `.github/ISSUE_TEMPLATE/` into ten repos from one table, and [`script/issue-labels.sh`](script/issue-labels.sh) is its GitHub-side half (a form's `labels:` are silently dropped if the label doesn't exist, and the security link 404s until private vulnerability reporting is on). The design, and why the field count is four, is [`docs/bug-reports.md`](docs/bug-reports.md). A hand-edit in a child repo is invisible until the weekly `issue-templates` workflow sweeps — edit the table, re-run, ship each repo. The in-product door (perch's and trill's *Report a Bug…* row, `trill report`, `pounce report`, `haus report` — `haus/modules/core/haus.sh`'s `cmd_report`, with `modules/launcher/commands/report-issue-haus.sh` one `exec` into it) lives in each app's own repo, to that doc's four-point standard. A door and its repo's `DIAG_HINT` change in the same round — `--check` compares only generator to YAML, nothing checks they agree. The third half is `haus/modules/ai/agents/hausfold/SKILL.md`, which names each repo's diagnostics verb: a verb added, renamed or dropped is three edits |
| **the install one-liner** — the URL, which desktop it resolves, the ref pinning | `./hausfold.co`'s `worker.js`, only there: `curl -fsSL https://hausfold.co/hacker.sh \| bash`. The *script* is `./haus`'s `bootstrap.sh` |
| the hausfold.co site | `./hausfold.co` ([hausfold/hausfold.co](https://github.com/hausfold/hausfold.co)), **public**, keep the `.co`. Next 16 + Fumadocs, statically exported onto a Cloudflare Worker, deployed by CI on push to its `main`; `worker.js` serves the installer, download and release-metadata routes. `bench clone` fetches it; not a flake input, not `FAMILY` |
| the hausfold **name register**, the launch plan, anything still to be decided | [hausfold/ops](https://github.com/hausfold/ops), **private**: `PRESENCE.md` for the register, `todo/` for every open workstream. **Never copy it, or a summary of it, into this repo** — which names are *free* is the sensitive half; trademark findings are public records and fine. In `DOCS_REPOS`, `bench clone` and `bench pull [ops]` only, both needing its credentials (clone warns, pull skips); the dir is `.gitignore`d |
| pounce's Homebrew formula / perch's cask | `./homebrew-tap` — **CI-owned**; hand-edit only to bootstrap a new formula/cask |
| scruff's Swift SDK | `./scruff`'s `sdk/swift`. [`hausfold/scruff-swift`](https://github.com/hausfold/scruff-swift) is a generated mirror (`git subtree split --prefix=sdk/swift`) that moves only on a `v*` tag, via `sdk/swift/sync-mirror.sh --tag <version>` — run it by hand from scruff's `main` to publish sooner. Never hand-edit the mirror |

## Where a write-up goes

**One fact, one place.** No `notes/` anywhere.

| kind of write-up | where |
|---|---|
| what a user reads | `hausfold.co`'s `content/docs/`, the source of truth |
| a repo's `README.md` | a **door** where the manual is elsewhere; the front page, and maybe the manual, where the repo has no tree on the site |
| how a thing works **now**, for someone working *on* it | that repo's `docs/<topic>.md` |
| a standard that binds every repo | this repo's [`docs/`](./docs/): `agent-surface.md`, `bug-reports.md`, `design.md`, `drift.md`, `agent-vm.md` |
| work that still has steps in it | [hausfold/ops](https://github.com/hausfold/ops)'s `todo/` |

haus, pounce, perch and scruff have trees on the site and keep no manual of
their own; their `docs/` hold only what a contributor needs (haus's `model.md`,
`macos-settings.md`, `focus.md` and `docs/site-data/`, which `hausfold.co`'s
`npm run options` reads — never prune it; perch's `cli.md`, `app-store.md`,
`feel-testing.md`; scruff's `releasing.md`, plus `SPEC.md` at its root). trill's
manual is `trill/docs/`, its site page a single incubator stub. snug and
nebelung have no tree, so their README is the front page and the manual — never
cut either down to a door. The test: a sentence still true after the reader has
installed the thing belongs in the manual, not the door.

Three rules for every doc surface:

1. **State what is true now, not how it got that way.** No dates, no "used to",
   no "was retired", no PR number standing in for a fact — the commit message
   carries those. Three things stay: a date that stamps a measurement
   (`script/probes/**`), "used to" / "no longer" naming a *shape*
   (`docs/drift.md`, the `/docs-sync` cut-list), and a fact about a stale config
   a reader may still hold ("`adopt = false` does nothing").
2. **A plan is not a doc.** Mostly unchecked boxes belongs in `ops/todo/`.
3. **Fix it in the same change.**

## The one gotcha that explains everything

The repos are a chain of pinned flake inputs. The spine is
`nebelung → pounce → haus → ~/.config/nix`; `perch`, `trill`, `scruff`, `snug`,
`factory` and `nebelung` (directly) are inputs of `haus` too, and `factory`
takes `snug`. That is **ten** lock edges, enumerated in `bench`'s `EDGES`.
`factory → snug` is the one edge whose holder `bench ship` does not walk —
factory is not `FAMILY` — so that pin moves in factory's own PR; `bench status`
still reports it. A commit, even a pushed one, is invisible downstream until
each `flake.lock` moves. **Never hand-walk that ripple, and never suggest it**;
`bench` does it:

- `bench status` — what this machine is running (the pinned build, or the local
  branches a `try switch` put on it), every stale lock edge, dirty/unpushed
  repo, and agent lane — read from scruff's registry, never `git worktree
  list`. Flags an **OFF-MAIN** edge: a lock pinned at a rev not on that repo's
  `main`, which a hand-run `nix flake update` inside a PR produces. Land the
  upstream PR first, then ship — shipping anyway repins to main and silently
  drops the unmerged work.
- `bench try [switch]` — build (and activate) this machine against the local
  checkouts via `--override-input`, without pushing. Worktree-aware: from a
  lane it substitutes that worktree, so `try switch` is the way to feel ONE
  unmerged branch. The activation gate is on who, not where: an agent is
  refused a worktree `switch` unless `BENCH_AGENT_SWITCH=1`. `bench rebuild`
  puts the pinned build back. `rebuild` draws one trill card while it builds
  (`BENCH_NO_BANNER=1` turns it off); `try` draws one only under
  `BENCH_BANNER=1`, because its `--dry-run` is a second full eval.
- `bench try-batch [switch] [repo…]` — merge every open PR onto a throwaway
  tree per repo and build/activate the whole queue in ONE rebuild, main
  untouched. Ends with a checklist; merge only the PRs that pass.
- `bench try lane [switch]` — `bench try` plus every repo a `scruff child`
  spawned from this pane, transitively, in one rebuild. Same gate.
- `bench overlap [--brief] [--path <f>]` — what the OTHER lanes on this repo
  have changed and where their edits and yours land in the same region,
  measured from the object store (uncommitted work included, what main already
  landed subtracted). Advisory; exit 0 clear · 3 same file · 4 same region.
  Flow: [`/earshot`](./.agents/skills/earshot/SKILL.md).
- `bench ship [repo…]` — fast-forward every checkout, then push
  upstream→downstream with a lock-bump commit at each hop. Refuses to end on
  `shipped` if an edge didn't move (three `--refresh` retries 5s apart; a rev
  not on the upstream's `origin/main` fails fast). Named repos narrow it to
  them plus their downstream closure along `EDGES`.
- `bench pull [repo…]` — fast-forward every checkout, or the named ones, no
  closure. `bench clone` — fetch any family repo missing here.
- `bench docs-since [--mark [--pending <repo>…] | --landed [<repo>…]]` —
  commits since the docs were last reconciled; the input to `/docs-sync`.
- `bench release <repo> [version] [--ship]` — under **Rules** below.

A terminal edit costs nothing to iterate — `bench try switch`, and Ghostty
applies the config to every running window. Windows survive in `zmx` sessions
(`haus.terminal.restoreWindows`); ⌘N is a new shell, and the palette's
**Restore Terminal Windows** brings parked ones back while something is
attached.

## Agent worktrees

⌘↵ runs `scruff new` for whichever client `haus.ai.default` names (`claude`,
`codex`, `opencode`, `pi`) — never `claude --worktree`, which skips scruff's
`[hooks] open` (it still lands in the registry through the hooks). The checkout
is `~/.cache/scruff/<repo>/<name>` on branch `worktree-<name>`, branched from
the repo's local HEAD, outside the repo so `bench try`'s `path:` overrides never
swallow it. A base still at `~/.cache/claude-worktrees` moves with `scruff
doctor --migrate-base`, run from a pane that isn't a lane (exit 2 otherwise).
Closing a pane parks uncommitted edits as a `wip:` commit and reaps only merged
branches; `scruff` lists every lane, `scruff <name>` (or `scruff <repo>/<name>`)
rebuilds it and resumes the client it was made with. **`scruff park [label]` /
`scruff unpark` replace `git stash`** — the stash stack is shared by every
worktree of a repo. `scruff reship [name]` pushes commits made after the PR
merged (`live+N` in the state column) and opens the follow-up PR.

If you are in a worktree (`git rev-parse --git-common-dir` points outside your
toplevel):

- **Commit, push and open the PR without asking.** Merging waits for the user:
  "ship / land / merge" is the go-ahead, then `gh pr merge` — never a local
  `git merge` or a direct push into `main`. The other standing go-ahead is a
  live factory lease, for tier-1 merges only.
- Build with `bench try` and stop; activation is the user's unless they asked
  (`BENCH_AGENT_SWITCH=1`). `bench ship` is fine from a worktree: it pushes
  only committed work on the *main* checkouts, never your branch, and never
  activates. `bench release` is always gated.
- `bench overlap` at lane start and before every `gh pr create`. A `⚠` means
  move your edit or put the printed landing order in the PR's **Watch out**
  verbatim; a `·` needs nothing.
- **Pre-PR assurance pass, every PR**: hand `git diff main...HEAD` and the
  edited repo's own `AGENTS.md` to a clean-context subagent (checklist: the
  ship skill's **Step 2.5**). Advisory — fix anything ≥3/5 before opening, carry
  the rest into **Watch out**, say in one line when it came back clean. This
  instruction IS the user request to spawn it; if your client has no subagent,
  say so in one line.
- PR body: **What / Why / Verify / Watch out** (ship skill Step 3) — a bug found
  later must be recoverable from `gh pr view` alone.
- `/ship` ([`.agents/skills/ship/SKILL.md`](./.agents/skills/ship/SKILL.md))
  finishes the job: merge, `bench ship`, merge and `git worktree remove` every
  child worktree this session made, then `cd "$main" && bench try switch`,
  report, stop. It never opens or closes a pane; the current worktree goes when
  the pane closes.
- **A workshop worktree holds only the workshop's files.** The child repos are
  not there and not hidden by gitignore. For a child task, make a child
  worktree — standing permission — with `scruff child`, never a raw `git
  worktree add` (it skips the registry, so the PR is invisible in the bar):

  ```sh
  workshop_root="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
  cd "$(scruff child "$workshop_root/<repo>")"
  ```

  Commit, push and open the PR there without asking; remove it after merge with
  `git -C "$workshop_root/<repo>" worktree remove …`. Report the repo, branch
  and PR.

From the workshop's **main checkout** none of that applies: `cd` into a child
and commit / push / ship under its own rules — gitignored up here says nothing
about git ops down there. For the whole flow, `bench try-batch [switch]` first,
merge only the PRs that pass (`gh pr merge`), `bench ship`, rebuild, without
re-confirming each repo.

## Cloud sessions

A bare Linux container with no Nix. [`.agents/setup.sh`](./.agents/setup.sh)
installs Determinate Nix, sets `PATH` and `NIX_SSL_CERT_FILE` at the
agent-proxy CA; idempotent, no-op on macOS. Each client fires it its own way
([`.agents/README.md`](./.agents/README.md)); with no hook, run
`./.agents/setup.sh` before touching a flake.

- ✅ Edit modules, `nixfmt`, resolve flakes, regenerate `flake.lock` entries for
  hausfold-org inputs.
- ⚠️ A full `nix eval`/build 403s: third-party `github:` flakerefs resolve
  through `api.github.com`, and `add_repo` refuses cross-owner adds. Probe with
  `nix flake metadata github:NixOS/nixpkgs`.
- ✅ `git+https://github.com/…` is a plain anonymous read the proxy serves, so a
  source tree is always reachable: nixpkgs' `lib/` is one `git clone --depth 1
  --filter=blob:none --sparse` + `sparse-checkout set lib` away (15 MB), enough
  for `script/probes/namespace-collision.nix` and `source-shapes.sh`. Not
  enough for `nix flake check`.
- ❌ `bench try switch` / `darwin-rebuild switch` — macOS only.

## Rules for working here

- **Speak in the family's verbs in what you suggest, not just in what you run**:
  `bench ship` (or `bench ship <repo>`), `bench pull [repo…]`, `bench rebuild`,
  `bench try [switch]`, and on a haus machine `haus update` / `haus rebuild` /
  `haus rollback`. Raw `nix` / `darwin-rebuild` / per-repo `git` only when no
  verb covers it, flagged "no wrapper for this". For an end user of haus,
  `haus` is the only vocabulary; a step it cannot express is a missing verb to
  report, never a nix command to paste.
- **Verify by actually running it**: `bench try`, then `bench try switch` from a
  main checkout. Testing in prod is house style.
- **Ship by default, sized to the change.** Small (bugfix, typo, config, docs):
  commit, verify, ship without asking. Big (feature, refactor, anything a user
  could feel break): verify, then ask. Unsure: ask.
- **Releases are always gated.** Never `bench release` unprompted; do propose
  one after user-facing changes to a tagged repo. Flow:
  [`/release`](./.agents/skills/release/SKILL.md). Versions are CalVer:
  `bench release <repo>` stamps `YYYY.MM.DD` (`-N` on a same-day repeat) into
  the repo's version source, commits, tags `v<date>`; CI publishes and bumps
  `homebrew-tap`. It **blocks** until the CI run ends (perch's and pounce's
  commit `nix/release.nix` back) and fast-forwards on green. Ship first, then
  release, then `bench ship` again (or `--ship`). Never hand-bump the formula.
- **`scruff` is the one semver repo, forced**: `bench release scruff 0.2.0`
  publishes five SDKs (npm, PyPI, crates.io, SwiftPM, Go proxy) on one number,
  none of which lets a number be withdrawn. `bench` refuses a version for the
  CalVer repos and demands one for scruff; deciding it means reading `git diff
  <last-tag>..main -- sdk/`, which is what `/release` is for.
- Commit in the repo you edited; `bench ship` refuses dirty trees.
- Don't cross-edit: a color hex in `haus`, or launchd logic in `pounce`, is the
  wrong repo even if it works.
- The life of a change: **hack** (`worktree-*`) → **test** (`bench try`) →
  **assure** (Step 2.5 + `bench overlap`) → **PR** → **batch-test**
  (`bench try-batch`) → **merge** → **try switch** → **ship** → **release**. A
  lone editor on the main checkout can drive a small fix straight to ship.
