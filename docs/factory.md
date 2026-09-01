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

**`afterMerge` is the lock ripple, and it is why the merge cannot end at the
merge.** The repos form a chain of pinned flake inputs (the README's "one
gotcha"), so a commit is invisible downstream until each `flake.lock` moves.
`bench ship` is that ripple, and it carries its own guard: it fast-forwards
every checkout an edge reads before it computes a single rev, and dies rather
than bump a lock from a diverged tree.

`bench pull` runs first for the four checkouts that guard never reaches — the
workshop itself, `org-profile`, `homebrew-tap` and `hausfold.co`. None of them
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
`~/.config/trill/rules.json` matches if a night of them is too many — and the
lane's row in the agents pill.

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
