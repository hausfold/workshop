# The factory — the night shift, as this org runs it

**What runs when nobody is at the keyboard.** The bottleneck it removes is the
human merge: on an ordinary week this org lands ~100 PRs and every one of them
waits for a person. The factory merges the fraction a filter can vouch for,
watches each default branch's CI, and leaves everything with taste in it for the
morning.

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
| excluded | `ops` · `website` · `producer-desktop` |
| after a merge | `bench pull` then `bench ship`, in `~/code/workshop` |
| budget feed | `~/.cache/claude-statusline/usage-claude.tsv` |
| everything else | factory's own defaults — `factory config print` shows the effective policy, so *unset* is always distinguishable from *set to the default* |

**`ops` is excluded because it is the private one.** It holds the name register
and real people's names, and which names are *free* is the sensitive half —
`AGENTS.md`'s routing row is the whole argument. A docs-shaped PR there is
exactly the kind the filter would otherwise wave through, and it is the one
place a merge nobody read could put a line somewhere it may not go.
`website` is archived. `producer-desktop` is nobody's night-shift business.

**`hausfold.co` is deliberately NOT excluded.** Its `main` deploys the public
site, so a docs merge there is a *publish* — but factory's own floor already
denies `content/`, which is the half that deploys. What is left in that repo is
ordinary contributor prose, and gating the repo rather than the paths would be a
second, weaker copy of a rule the tool already enforces.

**`afterMerge` is the lock ripple, and it is why the merge cannot end at the
merge.** The repos form a chain of pinned flake inputs (the README's "one
gotcha"), so a commit is invisible downstream until each `flake.lock` moves.
`bench pull` first, because a lock bump computed from a checkout that is behind
origin pins the pre-merge rev and reports success; `bench ship` second, which is
the ripple itself. A failure in either lands as `after-merge-failed` naming
which command stopped — the first leaves the checkouts behind with nothing
shipped, the second leaves them current with the edges stale, and the morning's
move differs.

## Overnight on a closed lid

macOS sleeps on lid-close regardless of `caffeinate` — `awake 3h` says so in its
own help. The lever that crosses a lid close is `pmset disablesleep`, and haus
owns it: **`haus.power.lidAwake`**, off by default because closing the lid is
the one gesture everybody reads as "stop". A shift wants `while = "always"`; the
default `while = "agents"` holds only while an agent is mid-turn and lingers 5
minutes after, so it drops in every one of the loop's ~20 minute gaps.
`requirePower` defaults true, so the Mac has to be plugged in.

Running without it costs coverage, not correctness. The watchdog counts only
awake time, so a shift on a suspending laptop gets fewer passes, and a foreman
that dies is still caught — just after 90 minutes of *its* time rather than 90
minutes of the clock's.

## Driving it

`/nightshift` is the foreman: grant the lease, loop `factory shift`, spawn
capped fixer lanes on red CI, write the handover. **The skill ships with the
tool** and arrives on this machine through haus, so there is no copy in
`.agents/skills/` to keep in step. `factory skill` prints the other one.

A live lease is the user's standing go-ahead for **tier-1** merges exactly as
the policy decides them — see the night-shift row in
[`AGENTS.md`](../AGENTS.md).
