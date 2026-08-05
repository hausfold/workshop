# workshop workflows

The long-form version of the README's command table — every flow, and why it's
shaped the way it is.

## The four CLIs

Four command-line tools, two jobs — keeping them straight is half the battle:

| tool | for | does | ships in |
|------|-----|------|----------|
| **`haus`** | *using* a nebelhaus machine | rebuild / update / rollback / doctor — drives **your Mac** | the rice (every install) |
| **`holt`** | *any agent user* | agent worktrees for **any repo** — spawn, resume, park, reap, `holt child` | the rice (every install) |
| **`bench`** | *developing* the family | try / try-batch / ship / release / status — moves changes **across these repos** | the workshop (here) |
| **`zscratch`** | *developing* the rice | feel-test a zellij edit with **no rebuild** | the rice |

`haus` and `bench` never overlap — named apart on purpose so they can't shadow
each other (`haus` = your machine; `bench` = these repos). `holt` and `zscratch`
are dev tools the rice puts on `PATH` regardless of whether you contribute.
(`holt` has [its own repo](https://github.com/nebelhaus/holt); the rice takes it
as a flake input. Its predecessor `wt` is **frozen**, still on `PATH`, and shares
the same registry — so old commands work, but write new ones against `holt`.)

## Daily driving

You only touch your machine (a new app, an alias):

```sh
# edit ~/.config/nix/hosts/<host>/default.nix, then:
./bench rebuild        # build first, switch second — a failed build never touches the system
```

## Hacking on the rice / theme / pounce

The important one. You never need to push to "see" a change; `try` builds your
real machine config against the **local checkouts**, uncommitted edits and all:

```sh
# edit anything in nebelung/, pounce/, nebelhaus/…
./bench try            # does it build?  (nothing pushed, nothing activated)
./bench try switch     # run it on this Mac  (still nothing pushed)
# happy? commit in the repo(s) you touched, then:
./bench ship           # pushes upstream→downstream, updating each lock along the way
```

## Parallel Claude agents

`Super a` (⌘A) in any repo tab spawns a Claude session in its **own git
worktree** — own checkout, own `worktree-*` branch, branched from local HEAD — so
agents never yank the branch out from under each other, or you. The worktrees
live *outside* the repos, in `~/.cache/claude-worktrees/<repo>/<name>`.

Claude Code's `WorktreeCreate` / `WorktreeRemove` hooks (in
`~/.claude/settings.json`) delegate to `holt hook create` / `holt hook remove` —
the standalone `holt` tool the rice ships on `PATH`, **not** a `bench` command.
That's what keeps `git status` and `bench try`'s overrides clean.
`Ctrl Alt Shift a` spawns the one agent allowed to edit the checkout you're
looking at.

```sh
# Super-a (⌘A) panes hack away on their own branches; meanwhile:
./bench status               # …also lists agent worktrees + unmerged worktree-* branches
# an agent (or you, cd'd into its worktree) can prove its branch builds:
./bench try                  # from inside a worktree: that repo's override points AT the worktree
# an agent lands work by opening a PR — never by pushing to or merging into main:
git -C nebelung push -u origin worktree-<name> && gh pr create -R nebelhaus/nebelung
```

A PR is conflict-detected and atomic, so parallel agents can't clobber each
other's commits. Closing the Claude pane removes the worktree; the branch and PR
survive until merged.

Run `holt` bare to list every parked/live agent worktree across all repos, and
`holt <name>` to rebuild a parked checkout and drop back into `claude --resume`.

## Feel-testing one branch, alone

`bench try switch` works **from inside an agent worktree**, and that's the point:
it's the only way to put ONE unmerged branch on the machine. Batch-testing (next
section) always feels the whole open-PR queue combined, and it can't see
uncommitted work at all — so when an agent hands you "this fixes the popup blink,
`bench try switch` to feel it", you open a pane in its worktree and run exactly
that:

```sh
holt                      # lists every worktree with its path (bench status does too)
cd ~/.cache/claude-worktrees/<repo>/<name>
bench try switch          # builds against THIS branch and activates it
# …feel it…
bench rebuild             # back to the pinned build
```

Nothing about a worktree makes the build special — the derivation is identical
wherever the source sits. Two things *are* different, and each has its own answer:

- **Who activates.** Activation is machine-wide and serial, so five parallel
  agents each with a good reason to switch would silently overwrite one another.
  So the gate is on **who, not where**: an AI agent is refused a worktree switch
  (`BENCH_AGENT_SWITCH=1` overrides it when you've explicitly asked for one); a
  person at the keyboard just runs it. An agent should build with `bench try` and
  hand you the command.
- **Remembering.** Every switch writes a receipt, and `bench status` leads with
  it — "running LOCAL code — activated <when>", naming each repo, branch and
  checkout, and flagging a source whose worktree has since been reaped. The
  receipt pins the system store path it described, so a `haus rollback`, a
  `bench rebuild`, or anyone else's switch retires it automatically instead of
  nagging about a build that isn't mounted any more. `bench rebuild` is the way
  back to pinned; landing the branch via its PR + `bench ship` is the way to make
  what you're running reproducible.

## Batch-testing (test-then-merge)

Activating a Mac is **serial** — one `darwin-rebuild switch` = one machine state
— so with a stack of PRs waiting you can only feel-test one at a time. The trap
is to merge them all to `main` first, then rebuild and tick them off: now
unverified code is on `main` before you've felt it.

`bench try-batch` inverts that. It merges every **open PR** onto a throwaway
integration tree per repo, overrides the flake at those trees, and builds (or
activates) the whole queue in ONE rebuild, `main` untouched:

```sh
./bench try-batch            # build every open PR together; prints a tick-off checklist
./bench try-batch switch     # …and activate the combined tree on this Mac
# verify each PR (its body carries the Verify steps), then merge only the winners.
```

Each PR's body doubles as the checklist entry, so give PRs a **What / Why /
Verify / Watch-out** body: the session that wrote the code is gone by the time
it's tested, so a bug found later has to be recoverable from `gh pr view` alone.

## Catching up

On another machine, or after shipping from elsewhere:

```sh
./bench pull && ./bench rebuild
```

## Releasing

Three repos are releasable — pounce, perch, nebelhaus — each with a real
audience.

Versions are **date-based** (CalVer): a release is stamped with the day it's cut
— `2026.07.18`, or `2026.07.18-1`, `-2`, … for a second release the same day. No
number is ever typed by hand; `bench release` computes the date, writes it into
the repo's version source, commits, and tags it.

```sh
./bench ship                # everything pushed & locks current first
./bench release pounce      # date-stamps pkgs/pounce/default.nix + tags v<date> —
                            # CI publishes the release + bumps the homebrew formula
./bench release perch       # date-stamps VERSION + tags v<date> — CI bumps the
                            # homebrew cask AND the rice's flake pin (nix/release.nix)
./bench release nebelhaus   # date-stamps VERSION + tags v<date> — this is what
                            # nebelhaus.com/init.sh serves to new installs
```

The rice one matters more than it looks: the install one-liner serves the
**latest rice release**, so until you cut one, new users bootstrap from the
previous tag no matter what's on `main`. Ship user-visible rice changes, then
release. (The date-stamp moves the repo's HEAD, so `bench ship` once more
afterward to ripple that lock downstream.)

## zscratch — iterating on zellij without a rebuild

The rice's `modules/den` ships one more dev CLI worth knowing here. `zscratch`
feel-tests a zellij edit (`config.kdl`, a layout, a freshly-built plugin `.wasm`,
or a candidate binary) in a throwaway session in its own Ghostty window, so you
skip the `bench try switch` + `main`-session restart that would nuke every open
tab.

```sh
zscratch --config FILE
zscratch --layout FILE
zscratch --theme FILE
zscratch --plugin tab-bar=WASM
zscratch --bin /path/to/zellij
zscratch clean            # reap the throwaway session
```

The real activation still happens once via `bench try switch`, at the end. Full
flag set in the rice's `CLAUDE.md`
([nebelhaus#69](https://github.com/nebelhaus/nebelhaus/pull/69)).

## The whole life of a change

```
hack ──► test ──► PR ──► batch-test ──► merge ──► ship ──► release
```

1. **hack** — edit in place, or let `Super a` (⌘A) agents draft on `worktree-*`
   branches in parallel; the main checkouts never move.
2. **test** — `./bench try` from wherever you are: it builds your real machine
   against the local checkouts (from inside an agent worktree, against *that*
   branch). `./bench try switch` activates it — **from a worktree too**, which is
   the only way to feel ONE unmerged branch on its own. What's gated is an *AI
   agent* switching from a worktree — see
   [Feel-testing one branch, alone](#feel-testing-one-branch-alone).
3. **PR** — an agent lands its branch by opening a PR against `main`, never by
   pushing to or `git merge`-ing into `main` (parallel agents doing that clobbered
   each other — a PR is conflict-detected and atomic). Give it a **What / Why /
   Verify / Watch-out** body so it's testable long after the session is gone.
4. **batch-test** — `./bench try-batch` feels every open PR together in ONE
   rebuild, `main` untouched, so you verify the whole queue before landing any of
   it (test-then-merge, not merge-then-test).
5. **merge** — review and merge the PRs that pass (`gh pr merge`); the branch, and
   a nagging `bench status` line, survive until you do.
6. **ship** — commit, then `./bench ship` pushes upstream→downstream, rippling
   every `flake.lock`.
7. **release** — `./bench release <repo>` date-stamps the version and tags it, and
   CI does the rest (pounce: GitHub release + Homebrew formula; nebelhaus: the tag
   `init.sh` serves to new installs).
