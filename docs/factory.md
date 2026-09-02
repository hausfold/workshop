# The factory — the night shift, as this org runs it

**What runs when nobody is at the keyboard.** The bottleneck it removes is the
human merge: on an ordinary week this org lands ~300 PRs across the twelve
repos in scope, and every one of them waits for a person. The factory merges
the fraction a filter can vouch for, watches each default branch's CI, and
leaves everything with taste in it for the morning.

**The tool is [hausfold/factory](https://github.com/hausfold/factory)** — one
CLI, a machine-local JSON policy and a log. Its README is the manual: the four
verbs, the exit codes, tier 1 and the floor under it, the four *unknown* lines,
the budget governor, and what the watchdog does when the foreman dies. Nothing
about any of that is repeated here.

**Nothing in this repo implements it.** `factory` is a flake input of `haus`,
which puts it on `PATH` with `haus.ai.enable` and installs its two agent skills
(`factory`, `nightshift`) into every client. There is no `script/factory-*`
here; a step that reaches for one is reading a stale page.

## What this repo owns about it

Two things, and only two: **the policy this machine runs under**, and the
**scope decisions** behind it. The policy file itself is machine-local — it is
authority, so a copy in a watched repo would be a file a pull request could edit
to widen the filter that judges it. `factory config path` is where it lives.

| | |
|---|---|
| scope | `orgs: ["hausfold"]` — every repo in the org, so a new one is covered the day it exists rather than the day somebody remembers this list |
| excluded | `.github` · `ops` · `website` · `producer-desktop` |
| after a merge | `bench pull` then `bench ship`, in `~/code/workshop` |
| budget feed | `~/.cache/claude-statusline/usage-claude.tsv` |
| everything else | factory's own defaults — `factory config print` shows the effective policy *plus the floor a config cannot lower*, so what it prints is what `factory tier` will actually do |

**`ops` is excluded because it is the private one.** It holds the name register
and real people's names, and which names are *free* is the sensitive half —
`AGENTS.md`'s routing row is the whole argument. A docs-shaped PR there is
exactly the kind the filter would otherwise wave through, and it is the one
place a merge nobody read could put a line somewhere it may not go.
`website` is archived. `producer-desktop` is nobody's night-shift business.

**`hausfold.co` is deliberately NOT excluded.** Its `main` deploys the public
site, so a docs merge there is a *publish* — but nothing that publishes is
reachable. `content/` is denied by factory's floor, and the site's other served
routes are hand-written under `src/app/`, which is neither prose nor markdown,
so `tier1.allow` never matches them. What is left is that repo's README and
`docs/`, the contributor half. Gating the repo rather than the paths would be a
second, weaker copy of a rule the tool already enforces.

**`.github` is excluded because everything the filter can reach in it is the
org's front page.** That repo is the workshop's `org-profile` checkout, and its
whole tier-1 surface is one file — `profile/README.md`, which is what
github.com/hausfold renders. Nothing else in the tree is even a candidate:
`AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.agents/README.md` and everything under
`.github/` are floored, and `profile/assets/*.png` is not prose. Four of the 26
PRs the repo has ever merged clear paths, head and author together, and all
four change that one file and nothing else — which products the page sells,
whether the family calls itself pre-release. A front page is nothing but
positioning, which is the work with taste in it that the top of this page
leaves for the morning.

**It is also the one repo where excluding it and denying a path are the same
rule.** hausfold.co keeps its place in scope because `content/` is a real seam
between the published half and the contributor half. `.github` has no such
seam: a `deny` of `^profile/` would be that seam spelled as one repo's
directory name, and it would land on any other repo that ever grew one.

**An exclusion is not only "don't merge here" — it is "don't look here."** One
filtered repo list feeds the merge walk and the default-branch CI watch alike,
so an excluded repo's red `main` goes unreported too. `.github` ships no
workflow, so that costs nothing here — and it is the second reason hausfold.co
could not have been excluded instead of floored: its `main` is the deploy, and
a red one there is exactly what a night pass exists to catch.

**Two other repos in scope have a single README for a tier-1 surface, and both
stay.** `homebrew-tap` is CI-owned, but a formula and a cask are Ruby, so the
filter reaches only the tap card. `scruff-swift` is the generated SwiftPM
mirror that [`AGENTS.md`](../AGENTS.md) says is never hand-edited: a commit
landing only there makes the next `sync-mirror.sh` push a non-fast-forward, so
the next release stops at the mirror step. It stays in scope because that
failure is loud and arrives before SwiftPM sees anything, and because no PR has
ever been opened against the mirror — an exclusion should name a decision, not
a hypothesis.

**`requireGreen` stays at `if-present`, and here that is a decision about three
repos rather than a setting.** Nine of the twelve run a `pull_request` workflow
with no path filter at all, so every PR reports checks whatever it changed — a
docs-only PR against `haus` runs the same bats suite a module change does, and
`always` would not alter a single verdict there. The other three can present a
tier-1 PR that reports nothing, and they are the three whose tier-1 surface
this page has already had to reason about.

Two of them ship no workflow: `homebrew-tap`, whose CI lives in the repos that
push to it, and the `scruff-swift` mirror. **hausfold.co is the one that is not
obvious.** All six of its PR-triggered workflows are path-filtered, and no
filter names its `README.md` or its root `docs/`. What they watch is the
published half and the build around it — `content/`, `src/`, `public/`,
`worker.js`, `scripts/`, `test/`, the wrangler and Next configs, and each
workflow's own file — which is the half tier 1 could never reach anyway:
`content/` because the floor denies it, the rest because `tier1.allow` matches
neither a `.ts` route nor a `.mjs` script. The two lists are drawn for opposite
reasons and land on the same line, so the surface left to tier 1 is exactly the
surface no workflow watches — and a green there would have meant a preview
worker deployed, not a word being right.

**`always` would not make those three safer; it would refuse them
permanently.** The setting can require that a check exists, not that a relevant
one ran — so where no workflow will ever trigger, the choice is not between a
verified merge and an unverified one but between merging a README and never
merging one. What stands in for CI in those repos is the `^worktree-` head: a
lane that came through the pre-PR assurance pass. That is the reviewer the
policy leans on everywhere; in these three it is the only one.

**`authors` stays `["@me"]`, the one clause in the policy that asks *who*.**
Everything else tier 1 weighs is the shape of a pull request — its paths, its
size, its base, its head, its checks — and a shape is something anyone with a
fork can produce. All twelve repos in scope are public, and nothing ahead of
this clause distinguishes a fork's head from the repo's own, so a branch named
`worktree-typo` clears `tier1.head` exactly as a lane does. That is the
condition the head rests on everywhere else on this page: as the stand-in for
CI in the three repos above, and as the shape that arrives with a reviewer
further down, `^worktree-` is a claim about who pushed it — and this clause is
the only thing checking.

**It has never refused a PR, which is the reason to write it down rather than
the reason to drop it.** Across the org's sixteen repos, five PRs to date are
not `@me`'s: all five a CI bot's, in two repos that are in scope, and each
turned away a clause earlier — three on a denied path, two on a `ci/` head. So
no verdict in any log names an author, and `*` reads as free: same repos, same
counts, a new digest. The first PR this clause ever refuses is the one that
would otherwise have been merged unread. (Counted 2026-09-01 against policy
digest `7de05b3b` — which clause stops a PR is a property of the policy, so a
config change moves that half.)

**`tier1.allow` stays at its default, and in this family that default reaches
three surfaces nobody writes by hand.** `^docs/` and `\.md$` are shapes; neither
is a claim about prose. Across the twelve repos in scope `docs/` holds 27
markdown files and four JSON, and all four JSON are haus's `docs/site-data/` —
9,625 lines of the `haus.*` option surface, the tiling binding table and the
launch keys, `nix build .#site-data` committed so hausfold.co can render its
options reference without Nix. The other two are markdown, so they match
wherever they sit: nebelung's `docs/ports.md` and the port board inside its
own `README.md`, both written by `scripts/gen-ports-doc.mjs` out of
`ports.meta.json`.

**What keeps each of them honest is a drift check in the repo that holds it,
never the filter.** haus's `site-data-current` diffs the committed directory
against the derivation, and it sits in the all-systems check set rather than
being darwin-gated like the `*-reach` checks beside it, so `nix flake check`
runs it *built* on the Linux runner every PR takes. nebelung re-renders both of
its surfaces in `test/ports.test.mjs` and fails on a stale one, under the `node
--test` its `unit` job runs. Both repos are in the nine that report checks on
every PR, so `if-present` is the clause carrying all three. The one file in
`docs/site-data/` the check excludes is its `README.md`, which is the one file
in there a person wrote.

**The shape that would reach tier 1 has never been pushed.** Of the 148 commits
that touched `docs/site-data/` since 2026-06-01, not one touched it alone, and
the same holds for all eight that have ever touched `docs/ports.md`: a
regeneration rides with whatever caused it — a `.nix` module, a
`ports.meta.json` — and neither matches `tier1.allow`, so the PR is refused on a
path before its size, its base, its head or its author is asked about. What
*could* arrive alone is the catch-up regen for a `main` that merged red, and
that one is the merge tier 1 is for: what the check prints when it goes red is
that nothing in the directory is hand-written, so the fix is to regenerate and
commit.

**`maxLines` is not what defends any of it, and the numbers say so plainly.**
The median `docs/site-data/` commit moves 9 lines and the 90th percentile 169;
two of the 148 clear 2000. Widen the frame and it is emptier still — 223 merged
PRs across the twelve since 2026-06-01 carry nothing but files that clear the
paths, and the largest of them is 1,019 lines, so the cap has yet to be the
reason for anything. It stops a whole-file regeneration and waves the one-option
one through, which is the right way round for a size limit and the wrong thing
to lean on. (Every count in this block was taken 2026-09-02, against policy
digest `7de05b3b`.)

**Merging a regenerated `site-data` is still not a publish.** hausfold.co
renders `content/docs/haus/reference/options.mdx` out of a *checkout* of haus
and commits the result; the site's build is a plain `next build` over that
committed page, and the drift workflow's push and pull-request triggers name
only the generator, that page and itself — so a merge here leaves the site's
page stale rather than red, and the change reaches the public one as the Monday
cron's long-lived `ci/options-drift` PR. Two of the five non-`@me` pull requests
counted above are that PR, and both are turned away on `content/` before the
`ci/` head is ever read. The family's fourth generated doc surface is the one
the floor already denies — for the publish reason, not the generated one.

**`afterMerge` is the lock ripple, and it is why the merge cannot end at the
merge.** The repos form a chain of pinned flake inputs (the README's "one
gotcha"), so a commit is invisible downstream until each `flake.lock` moves.
`bench ship` is that ripple, and it carries its own guard: it fast-forwards
every checkout an edge reads before it computes a single rev, and dies rather
than bump a lock from a diverged tree.

`bench pull` runs first for the checkouts that guard never reaches — the
workshop itself, `org-profile`, `homebrew-tap` and `hausfold.co`, plus the
private `ops`, which the shift never merges into and which pull skips outright
where it isn't cloned. None of them
is on the ship chain, and the workshop is the one that bites: a docs PR merged
*here* leaves this checkout behind by exactly the squash commit, which is how a
merged PR ambushes the next push.

**Only `bench ship` can end the chain.** A checkout that won't fast-forward is a
warning inside `bench pull`, which exits 0 regardless, so as long as both
commands ran at all it is the ripple `after-merge-failed` names — and the stderr
it quotes is what says which morning this is. Ship refuses a dirty tree before
it advances anything, dies on a checkout that has diverged, and fails the ripple
itself last. Only the third leaves the merges landed, the checkouts current and
the edges stale, and only the third is `bench status` for the edge that didn't
move and a second `bench ship`; the other two want the tree cleared first.

**The merge is a squash, so the lanes outlive it.** `mergeMethod` is `squash`,
factory's own default and the family's method everywhere: a merged lane's own
commits stay unreachable from main, so its local branch survives its PR and its
merge base stays where it was. `afterMerge` catches the checkouts up and stops
there; factory merges through the forge and knows nothing about lanes, so a
morning after a productive night opens on a registry still holding the night's
landed ones. That is the condition `bench overlap`'s per-side subtraction exists
for, at its sharpest — several squashes at once with nobody awake to close a
pane — and the comment where it does that subtraction is the whole argument. The
sweep is `scruff reap`, which is not one of the `afterMerge` commands.

**The budget feed is haus's, not factory's.** Nothing here writes that TSV.
haus's `modules/ai/statusline.sh` stashes the account's 5-hour and weekly
percentages on every Claude Code statusline render — the client hands both to
each render, so the primary source is also the cheapest there is: no keychain
read, no API call. `modules/ai/statusline-refresh.sh` fills the hole under it,
polling `api.anthropic.com/api/oauth/usage` on a 120-second TTL, kicked by the
bar's own pill rather than by a session.

The hole is that a statusline is a TUI feature, **which is why the shift keeps
its own feed fresh by being one**. The Claude Code macOS app renders none and
pushes nothing; and what gates the pull is not its caller but its bearer — the
`Claude Code-credentials` keychain item, which the macOS app never writes and a
terminal `claude` renews in place whenever a pane runs, good for about nine
hours after the last one. A foreman that was not a pane would spend against
percentages from whenever one last was.

## The docs sweep is not the intake

The obvious customer for a filter that admits docs-only PRs is `/docs-sync`,
which lands one PR per affected repo most days and writes nothing but prose. It
is refused every night, in every repo, by one of two independent rules. The
sweep pushes `docs-sync-<date>` branches
([its `SKILL.md`](../.agents/skills/docs-sync/SKILL.md)) where `tier1.head` is
`^worktree-`; and paths are judged before the head is, so what `factory tier`
prints for one of these is usually a filename rather than the branch.

**Widening `tier1.head` would buy back about one PR a week, and would not touch
what refuses the rest.** Of the 41 sweep PRs merged since 2026-08-01 across the
eleven repos the sweep walks that are also in scope (`DOCS_REPOS` less `ops`
and `org-profile`), 7 are path-clean — two of those seven from before the site
moved out of this repo, a layout that no longer exists. Of the 34 refused on
paths, 26 hit the floor, carrying an `AGENTS.md`, a `CLAUDE.md`, a `SKILL.md`
under `.agents/` or `content/` on hausfold.co; the other 8 simply carried a
file `tier1.allow` does not match at all — a `.nix` module whose comment the
sweep corrected, a Homebrew cask, a Swift test, and four `.mdx` pages from when
the site still lived here. Measured against policy digest `7de05b3b`, which is
the instrument those numbers are a reading from: a config change moves them.

That is not a filter tuned wrong. **A docs sweep's job includes keeping the
agent-instruction files current, and those files are the authority an unread
merge must not be able to edit.** The sweep and the floor want the same files
for opposite reasons, and the floor wins — which leaves the sweep waiting for
the morning, where a change to what agents are told belongs.

What the shift lives on instead is the lane: a `worktree-*` branch, one agent,
one subject, already through the pre-PR assurance pass. `^worktree-` is not a
naming convention the policy happens to match on — it is the shape that arrives
with a reviewer.

## Overnight on a closed lid

factory's README asks for `disablesleep`; on this machine that lever is haus's.
**`haus.power.lidAwake`** is off by default because closing the lid is the one
gesture everybody reads as "stop", and **this host turns it on** —
`enable = true`, `while = "always"`, in `hosts/mbp/default.nix`'s power block —
so a shift asks for nothing the host file has not already granted.
`requirePower` stays at its default, which keeps unplugging as the way to say
stop, and `maxHold` does not apply here: the 8-hour cap is a failsafe for an
agent hold that leaked, and `always` has no signal to leak, so a 12-hour shift
is not cut off at hour 8.

**`haus.ai.keepAwake` is not the shift's lever, and that is deliberate.** It is
the AI room's profile and means "while my agents work" at both its stops — even
`lid`, which switches `haus.power.lidAwake` on at `mkDefault`, rides the agents
signal rather than becoming an unconditional hold. That signal lingers 5 minutes
past the last turn, so it drops in every one of the loop's ~20 minute gaps. The
power room's `while = "always"` has to be named directly, which is what the host
file does.

This host grants the lever, so a shift here never has to weigh what a suspending
machine costs it. On a host that does not, factory's README has that — *When the
foreman dies* — and it stays there rather than being copied to a second place
that would drift from it.

## When main goes red

**The shift's fixer lane is the GitHub pill's "Fix with AI", without the
click.** `haus-fix-github` already turns a red default branch into one
background agent lane, and a `CI-RED <repo> <url>` line is its contract already
filled in — the verdict is `ci`, the selector is the default branch, and the URL
carries the repo:

```sh
haus-fix-github main ci "$url"
```

Calling that rather than improvising a spawn is the decision this page owns.
Resolving the local checkout, picking a client and cleaning up a lane the open
seam refused are all haus's to document and to change, and none of them is worth
a foreman re-deriving in prose at 3 a.m. A repo with no local checkout gets a
banner and no lane, which is the whole of what the shift can do about a red
branch it cannot reach.

**What stays the foreman's is everything before the spawn.** The binary's own
guard is a short lock against a double-click; the night's counters — the budget
verdict, how many lanes this repo has already had, whether this head SHA has had
its turn — are the nightshift skill's, read out of the shift log. That is why
the log gets a line even when the answer is no: nothing else knows a lane was
considered. Calling the binary twice in a night is safe on its own terms,
because `scruff spawn` takes the next free name where `scruff child` would
refuse — a spawner has nobody to tell.

**The spawn is a background one, and that is not a nicety.** The machine is
somebody's desk whether or not they are asleep at it, so a lane must not raise a
window or take focus, and `HAUS_LANE_BACKGROUND=1` is what the binary already
sets. The receipt is a banner — `--source haus.github.fix`, the string
`~/.config/trill/rules.json` matches on — and the lane's row in the agents
pill. What a rule there costs is below.

**The lane is a Claude Code one here, which is what keeps it from stalling
unattended.** Those panes run in permission mode `auto`, and the only hook that
re-raises a prompt is `agent-desktop-guard`, which fires on calls that move the
pointer, take focus or redraw the desktop — nothing a CI fix has reason to do.
The binary falls back to whichever client is actually installed, so this holds
because `haus.ai.default` is `claude` on this machine, not because an unattended
lane is safe in general.

**It can build; it cannot activate.** The repo's own tests run in the lane's
checkout and `bench try` builds against its branch, but `bench try switch` is
refused to an agent in a worktree unless told `BENCH_AGENT_SWITCH=1`, and the
shift never sets it — activation is machine-wide and serial. A red `main` that
only reproduces on activation is therefore diagnosed and proposed, never
confirmed; the confirmation is the morning's.

**The fixer's own PR gets no special treatment, and for a CI fix that is
arithmetic rather than a rule.** Its head matches `^worktree-` and its author
is `@me`, so only the paths decide — and a red default branch in this family is
a bats failure, a shellcheck finding, a nix eval, or a Go or Swift test, none
of which `^docs/` or `\.md$` matches. What would *not* wait is a check whose
fix is markdown. The family's docs-shaped checks point at files the floor
denies anyway: factory's `check-skills.sh` at `ai/SKILL.md`, haus's painter and
installer-palette counts at `.sh` files — but that is where those tests happen
to point, not a guarantee. A check that reddened over a `docs/` page would let
the shift merge the fix to the thing that made it red, unread. Worth knowing
before writing one.

## What a night puts on screen

**Two `--source` strings are the shift's own, and a spawned lane adds two that
are not.** The shift's are `factory` and `haus.github.fix`; a fixer lane then
draws under `haus.lane` and `claude`, which belong to the lane machinery and
carry every other lane with them. Nothing routes any of the four until
`~/.config/trill/rules.json` names one, because no match means banner. `bench`
is the reasonable guess that is wrong: `afterMerge` runs `bench pull` and `bench
ship`, and bench cards only from `try` and `rebuild` and notifies only from
`try-batch` and `release`, none of which a pass runs.

**`factory` is every card the shift itself draws** — the policy's
`notify.source`, behind the one `trill send` in factory's `lib/common.sh` that
all six call sites reach. Five are `fault`: the pass aborted, a default branch
found red (that one carries the failed run's URL), the after-merge ripple
failed, and the watchdog's two — the shift stalled, and the shift died with the
lease revoked. The sixth is the only `done`, the count of tier-1 PRs a pass
merged.

**Dropping that source costs nothing the shift log does not already hold.**
Every one of the six has a `say` or a `note` beside it, the red branch's URL
included, so `{"match": {"source": "factory"}, "delivery": "drop"}` loses the
interruption and keeps the record — and the handover is written from the log,
not from the screen. The card worth splitting off first is the `done`, the only
non-fault of the six: a rule matching `kind` ahead of a broader one tallies the
merges into a digest and leaves the five faults to bang on the door. A Focus is
not that dial. trill's shipped `focus` block already inboxes a `done` and
banners a `fault`, which is the shape but not the tally, and only for as long as
a Focus is on.

**`haus.github.fix` is the fixer lane's, and silencing it is not only a night's
decision.** The same binary is behind the GitHub pill's *Fix with AI*, so a rule
there covers a click at the keyboard exactly as it covers the 3 a.m. spawn. Nor
is it reachable from a rule on `haus`: trill matches `source` exactly, so the
dotted name is a convention this family writes rather than a namespace trill
walks.

**It is also the source where `drop` genuinely loses something.**
`haus-fix-github` forks its work and exits 0 before any of it happens, so no
caller learns the outcome from a status — and three of the endings that produce
no lane leave nothing behind but the card: nothing in `haus.ai.clients` on
`PATH`, no local checkout of the repo, and a lane already running under the
lock. Only the spawn failures reach `~/.local/state/haus/github-fix.log`. For
those three the banner is the entire record, against a shift log whose last word
on the subject is that a lane was asked for. `inbox` or a digest keeps them
findable where `drop` does not.

**The other two are the lane's, and a rule on either reaches well past the
night.** `haus.lane` is how a lane that could not be tiled says so, and one of
its two cards exists for the silent birth this spawn uses — the lane opened out
of sight. `claude` is scruff's per-lane fin: an `ask` when a lane blocks on a
question, a `done` when it finishes a turn. Both fire for every lane on this
machine, the ones spawned at the keyboard included, so quieting a loud night
through either is quieting the lanes themselves.

## Driving it

`/nightshift` is the foreman: grant the lease, loop `factory shift`, spawn
capped fixer lanes on red CI, write the handover. **The skill ships with the
tool** and arrives on this machine through haus, so there is no copy in
`.agents/skills/` to keep in step. `factory skill` prints the other one.
Drive it from a terminal pane rather than the desktop app — the budget feed
above is why.

A live lease is the user's standing go-ahead for **tier-1** merges exactly as
the policy decides them — see the night-shift row in
[`AGENTS.md`](../AGENTS.md).
