# workshop workflows

The long-form version of the README's command table — every flow, and why it's
shaped the way it is.

## The three CLIs

Three command-line tools, two jobs — keeping them straight is half the battle:

| tool | for | does | ships in |
|------|-----|------|----------|
| **`haus`** | *using* a haus machine | rebuild / update / rollback / doctor — drives **your Mac** | haus (every install) |
| **`scruff`** | *any agent user* | agent worktrees for **any repo** — spawn, resume, park, reap, `scruff child` | haus (every install) |
| **`bench`** | *developing* the family | try / try-batch / ship / release / status — moves changes **across these repos** | the workshop (here) |

`haus` and `bench` never overlap — named apart on purpose so they can't shadow
each other (`haus` = your machine; `bench` = these repos). `scruff` is a dev tool
haus puts on `PATH` regardless of whether you contribute, and has
[its own repo](https://github.com/hausfold/scruff); haus takes it as a flake
input.

## Daily driving

You only touch your machine (a new app, an alias):

```sh
# edit ~/.config/nix/hosts/<host>/default.nix, then:
./bench rebuild        # build first, switch second — a failed build never touches the system
```

## Hacking on haus / theme / pounce

The important one. You never need to push to "see" a change; `try` builds your
real machine config against the **local checkouts**, uncommitted edits and all:

```sh
# edit anything in nebelung/, pounce/, haus/…
./bench try            # does it build?  (nothing pushed, nothing activated)
./bench try switch     # run it on this Mac  (still nothing pushed)
# happy? commit in the repo(s) you touched, then:
./bench ship           # pushes upstream→downstream, updating each lock along the way
                       # (a repo arg narrows it: `bench ship pounce` ripples just
                       # pounce + its downstream consumers)
```

## Parallel agents

**⌘↵** over a Ghostty window spawns an agent lane in its **own git
worktree** — own checkout, own `worktree-*` branch, branched from local HEAD — so
agents never yank the branch out from under each other, or you. The worktrees
live *outside* the repos, in `~/.cache/scruff/<repo>/<name>`, whichever client
made them. The chord is scoped to Ghostty, so ⌘↵ still means *send* everywhere
else — and a lane can't be started from a
browser; the palette's **Spawn Agent** row is the answer there.

**Which client** is whatever `haus.ai.default` names — `claude`, `codex`,
`opencode` or `pi`. **All four go through `scruff new`**, including Claude:
`claude --worktree` would run the client in the pane it was launched from and
never ask scruff's `[hooks] open`, which is the seam a lane's own window arrives
through. The `WorktreeCreate`/`WorktreeRemove` hooks in `~/.claude/settings.json`
still delegate to `scruff hook create` / `scruff hook remove`, so a hand-run
`--worktree` is registered too — it just isn't what the chord does. Either way
the plumbing is `scruff` — the standalone tool haus ships on `PATH`, **not** a
`bench` command. That's what keeps `git status` and `bench try`'s overrides clean.
`c` in a window's own shell runs the one agent allowed to edit the checkout
you're looking at. There is no chord and no palette row for it — typing `c` is
the whole interface.

```sh
# ⌘↵ lanes hack away on their own branches; meanwhile:
./bench status               # …also lists agent lanes + unmerged worktree-* branches
# an agent (or you, cd'd into its worktree) can prove its branch builds:
./bench try                  # from inside a worktree: that repo's override points AT the worktree
# an agent lands work by opening a PR — never by pushing to or merging into main:
git -C nebelung push -u origin worktree-<name> && gh pr create -R hausfold/nebelung
```

A PR is conflict-detected and atomic, so parallel agents can't clobber each
other's commits. Closing the pane removes the *checkout*, never the work: `scruff`
parks any uncommitted edits as a `wip:` commit on the branch first, and only
*merged* branches get reaped. The branch and PR survive until merged.

```sh
scruff                  # every parked/live agent worktree, across all repos
scruff <name>           # rebuild a parked checkout and drop back into the client
                      # it was made with (claude --resume / codex resume /
                      # opencode --continue / pi --continue)
scruff park [label]     # set the dirty tree aside as one wip: commit — NEVER git stash
scruff unpark           # …and put it back
scruff reship [name]    # a session that kept committing after its PR merged: push
                      # the branch and open the follow-up PR (shown as live+N)
scruff reap             # sweep every LANDED worktree; keeps dirty/unmerged/occupied ones
```

`bench status`'s lane table **is** scruff's registry, filtered — not `git worktree
list`. git's answer is "what trees exist", which includes hand-made ones (a
scratch checkout for a before/after compare, a `/tmp` tree) that scruff never made
and `scruff reap` will never sweep; listing those as lanes would make the two
tools look permanently out of sync. bench keeps the rows whose repo sits
under the workshop dir — family or not, so `trill`, `snug`, `hausfold.co` and
the workshop itself all count — plus the host config (`~/.config/nix`, shown as
`consumer`). A lane in an unrelated repo on the same machine is scruff's business,
not bench's. Use `scruff child` for cross-repo work and it lands in that table;
a raw `git worktree add` is invisible to both bench and the bar.

A lane spawned from a pane — `scruff child` reaching into a second repo, or ⌘↵
pressed inside another lane — is drawn indented under the lane that made it,
marked `└`. It is nested, never dropped: its branch and its PR are its own, and
closing the parent's pane does not reap it, so this table and `scruff` are the
only places it surfaces once that pane is gone. (The palette's **Lanes** picker
is the one surface that does drop them, because it exists to jump to a window
and those have none.)

Never `git stash` in these repos: the stash stack lives in the shared `.git`
dir, so every worktree *and* the main checkout pop the same one, and parallel
agents routinely pop each other's entries. `scruff park` is per-branch, so it can't.

### Lanes noticing each other (`bench overlap`)

Lanes conflict by accident: two of them append to `AGENTS.md`, or rewrite the same
paragraph of a note, and nobody finds out until a PR won't merge. `bench overlap`
finds it early, and does it **without any coordination at all** — no claims file, no
lock, no registry to keep current. Lanes are branches of one repo in one shared
object store, so every fact a claims ledger would ask an agent to *declare* is just
measured instead, offline, in milliseconds.

```sh
./bench overlap                  # who is in your files, and where — from inside a lane
./bench overlap --brief          # one line per lane; run it when a lane starts
./bench overlap --path AGENTS.md # just that file; prints NOTHING when it's clear
./bench overlap                  # from the MAIN checkout: every pair of lanes that share a file
```

Two signals, on purpose:

- **the hunk index** — every lane's changed line ranges since the common ancestor,
  in the *ancestor's* coordinates (the one numbering two diverging trees share),
  including **uncommitted and untracked** work, and minus whatever **main landed**
  into that side since the ancestor (a squash merge puts the ancestor behind main,
  and the lane that was squashed would otherwise claim every line it shipped for as
  long as its branch exists). `⚠` means the same region, within
  git's own 3-line context; `·` means the same file, somewhere else in it. Co-editing
  a long shared file is normal here, and a tool that shouted about it would be muted
  inside a day.
- **`git merge-tree`** — a real three-way merge of the two branches, no working tree
  touched. Exact, but committed work only. Reported apart from the index, never folded
  into it: the two disagreeing is information.

Exit codes are `0` clear · `3` same file · `4` same region, and it refuses nothing —
it reports. The `↳` line names which branch should land first, reading only facts both
lanes can see (who has pushed, whose diff is bigger), so two agents reach the same
answer without talking to each other. Put that line in the PR body's **Watch out**
block and the collision reaches the review queue as text.

It is the pre-emptive form of what `bench try-batch` discovers below by merging the
whole open-PR queue — same verdict, minus the PRs, the merges and the rebuild.

## Feel-testing one branch, alone

`bench try switch` works **from inside an agent worktree**, and that's the point:
it's the only way to put ONE unmerged branch on the machine. Batch-testing (next
section) always feels the whole open-PR queue combined, and it can't see
uncommitted work at all — so when an agent hands you "this fixes the popup blink,
`bench try switch` to feel it", you open a pane in its worktree and run exactly
that:

```sh
scruff                      # lists every worktree with its path (bench status does too)
cd ~/.cache/scruff/<repo>/<name>
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
  nagging about a build that is no longer mounted. `bench rebuild` is the way
  back to pinned; landing the branch via its PR + `bench ship` is the way to make
  what you're running reproducible.

### …and a cross-repo lane, in one rebuild

`bench try` substitutes the ONE repo your worktree belongs to. When a session has
spawned children in other repos with `scruff child` — a haus worktree plus its
pounce and nebelung lanes, say — plain `try` builds your branch against the
*pinned* copies of the rest, which is a green build of the wrong thing.

```sh
bench try lane            # override every repo this pane's lane touches
bench try lane switch     # …and activate the whole lane together
```

It walks scruff's registry transitively from the current worktree, so no PR has to
exist first and no lock has to move. Same who-not-where activation gate as plain
`try switch`.

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

Five repos are releasable — pounce, perch, trill, haus (the layer) and scruff —
each with a real audience. **snug is deliberately not one of them**: every
consumer pins it by rev as a flake input, so a tag would name nothing anyone
fetches, and `bench release snug` refuses. Four are CalVer; **scruff alone is semver**, and that
split is the only thing about releasing you have to hold in your head.

Versions are **date-based** (CalVer): a release is stamped with the day it's cut
— `2026.07.18`, or `2026.07.18-1`, `-2`, … for a second release the same day. No
number is ever typed by hand; `bench release` computes the date, writes it into
the repo's version source, commits, and tags it. It **refuses** a version
argument for these three, to make that unarguable.

```sh
./bench ship                # everything pushed & locks current first
./bench release pounce      # date-stamps pkgs/pounce/default.nix + tags v<date> —
                            # CI publishes the release + bumps the homebrew formula
./bench release perch       # date-stamps VERSION + tags v<date> — CI bumps the
                            # homebrew cask AND haus's flake pin (nix/release.nix)
./bench release haus        # date-stamps VERSION + tags v<date> — this is what
                            # hausfold.co/hacker.sh serves to new installs
./bench release scruff 0.2.0  # SEMVER, and required: five SDKs (npm, PyPI,
                            # crates.io, SwiftPM, the Go proxy) share one number
```

scruff is forced into semver, not styled into it: three registries already hold
`0.1.0` and none of them ever lets a published number be withdrawn, so the
number is a compatibility contract — and CalVer would force the Go SDK's import
path to end in `/v2026` and change it every January. Deciding the bump means
reading `git diff <last-tag>..main -- sdk/` against the published SDK surface;
that judgement is what [`/release`](../.agents/skills/release/SKILL.md) is for.

`bench release` **blocks** until the CI run finishes, drawing its jobs live, and
exits non-zero if the run goes red. That wait is load-bearing: perch's run
commits `nix/release.nix` back to the repo, so returning early would leave your
checkout behind origin and a `bench ship` that ripples a superseded rev. It
fast-forwards for you when the run goes green.

The haus one matters more than it looks: the install one-liner serves the
**latest haus release**, so until you cut one, new users bootstrap from the
previous tag no matter what's on `main` — and if `main` renames an option, the
host file that tag scaffolds stops evaluating against it. Ship
user-visible haus changes, then release. (The date-stamp moves the repo's HEAD, so `bench ship` once more
afterward to ripple that lock downstream — or `bench release <repo> --ship` to do
both.)

## Keeping the docs honest

Code moves all day; docs don't follow on their own. The **`/docs-sync`** sweep
([`.agents/skills/docs-sync/SKILL.md`](../.agents/skills/docs-sync/SKILL.md))
closes that gap once a day, and `bench` gives it its input:

```sh
./bench docs-since                          # every commit past each repo's watermark
./bench docs-since --mark --pending haus    # …record where the next sweep starts
./bench docs-since --landed haus            # …haus's doc PR merged; the docs caught up
```

**Two watermarks per repo, and the gap between them is the point.** `read` is
the last commit a sweep has looked at; `landed` is the last one whose
corrections are merged on `main`. `--mark` advances `read`, and `--pending`
names the repos whose fixes are still sitting in an open PR so their `landed`
stays put. Anything between the two prints as a ⚠ — *`haus`: 14 commits READ but
not landed*. Without that split a sweep could open a PR nobody merged, mark
those commits read forever, and never look at them again: the docs stayed wrong
and the run reported itself clean, which is indistinguishable from a quiet day.
Only `--landed` ever closes a gap: a `--mark` that forgets to name a repo leaves
its gap standing rather than quietly claiming it documented.

It is **watermark-based, not "since yesterday"**: a sweep that slept for four
days still picks up all four, and a day that fires two runs reads each
commit exactly once. The watermarks live in `.docs-sync.json`, which is
committed on purpose — the sweep runs as a scheduled routine in a throwaway
container, so anything it must remember between runs has to be in the repo. The
same file carries the rolling **comment pass**'s ledger: one over-commented
source file a run, recorded so the next run doesn't re-read it.

Its editing order is **cut, correct, fold in, add** — in that order. The docs
are too long before they are too short, and a new page is the last resort. The
skill keeps **one open PR per repo**, growing until you merge it, rather than
opening a fresh one each run.

Three things about its repo list are deliberate and get "tidied" wrong:

- **`DOCS_REPOS` is not `FAMILY`.** It adds `trill`, `snug` and `hausfold.co` —
  repos with docs and an audience that `FAMILY` doesn't cover. Docs coverage and
  lock coverage are different questions. `bench clone`/`pull` plant and refresh
  all three for the same reason. `hausfold.co` has no flake input at all;
  `trill` and `snug` each have one
  (`haus → trill`) without being family, so `try`/`try-batch` DO build it from a
  local checkout while `ship`/`status` still don't walk its git state — see
  bench's 🚨 by `FAMILY` for the three-list split.
- **A missing checkout and an unswept repo look identical in the output**, so
  `docs-since` warns loudly for both (`no checkout at …`, and either
  `first sweep — no watermark, reading its FULL history` or `watermark … is gone
  (rebased away?)`). Those lines are holes in the sweep, not clean repos.
- 🔒 **`ops` is in the list, and it is one-way.** The private repo carries the
  name register, the gap list and real testers' names, and a repo renamed or a
  package published leaves a claim in there wrong — so the sweep reconciles it.
  It may never carry a line *out* of `ops` into a public repo. It is private, so
  its clone needs credentials and warns rather than dying without them.

The sweep never lands on `main` — one PR per affected repo, each commit carrying
a `Docs-Sync:` trailer so tomorrow's run doesn't read today's output as its input.
The one exception is the watermark commit itself, which is trailered for the same
reason.

## The whole life of a change

```
hack ──► test ──► assure ──► PR ──► batch-test ──► merge ──► ship ──► release
```

1. **hack** — edit in place, or let ⌘↵ agent lanes draft on `worktree-*`
   branches in parallel; the main checkouts never move.
2. **test** — `./bench try` from wherever you are: it builds your real machine
   against the local checkouts (from inside an agent worktree, against *that*
   branch). `./bench try switch` activates it — **from a worktree too**, which is
   the only way to feel ONE unmerged branch on its own. What's gated is an *AI
   agent* switching from a worktree — see
   [Feel-testing one branch, alone](#feel-testing-one-branch-alone).
3. **assure** — before `gh pr create`, on **every** PR here and not just `/ship`ed
   ones: hand `git diff main...HEAD` to a **clean-context subagent** whose only
   other input is the edited repo's own `AGENTS.md`. The session that wrote the
   diff is the worst reviewer of it. It hunts the family invariants that only
   bite after merge — wrong-repo routing, docs drift on a user-facing option or
   keybind, a breaking option rename split across PRs, hotkey collisions, raw
   `git worktree add` callers, release blast radius. Advisory, never a gate: fix
   anything ≥3/5 now, carry the rest into the PR's **Watch out** block. Checklist:
   [`/ship` Step 2.5](../.agents/skills/ship/SKILL.md).
4. **PR** — an agent lands its branch by opening a PR against `main`, never by
   pushing to or `git merge`-ing into `main` (parallel agents doing that clobbered
   each other — a PR is conflict-detected and atomic). Give it a **What / Why /
   Verify / Watch-out** body so it's testable long after the session is gone.
5. **batch-test** — `./bench try-batch` feels every open PR together in ONE
   rebuild, `main` untouched, so you verify the whole queue before landing any of
   it (test-then-merge, not merge-then-test).
6. **merge** — review and merge the PRs that pass (`gh pr merge`); the branch, and
   a nagging `bench status` line, survive until you do.
7. **ship** — commit, then `./bench ship` pushes upstream→downstream, rippling
   every `flake.lock`.
8. **release** — `./bench release <repo>` stamps the version (today's date, or
   scruff's hand-picked semver) and tags it; CI does the rest (pounce: GitHub
   release + Homebrew formula; haus: the tag `hausfold.co/hacker.sh` serves to
   new installs; scruff: five SDK registries). Always the user's call.
