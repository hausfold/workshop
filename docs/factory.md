# The factory — the night shift, level 0

**What runs when nobody is at the keyboard.** The bottleneck this removes is
the human merge: on an ordinary week the org lands ~100 PRs and every one of
them waited for a person. The factory merges the fraction of those that code
alone can vouch for, watches main CI, and leaves everything with taste in it
for the morning. It is built from three scripts and one skill, all in this
repo; there is no daemon, no webhook, no new repo. (The wider design — tiers
above 1, the foreman daemon, VM-verified merges — is a plan, and lives in
`ops/todo/`, not here.)

## The pieces

| | |
|---|---|
| `script/factory-lease` | the standing merge grant: `grant 12h` / `status` / `revoke`. One TSV line in `~/.cache/hausfold-factory/`, machine-local so no PR can grant itself authority. Expired == revoked == today's ordinary workflow — the factory's failure mode is the status quo |
| `script/factory-tier` | is a PR **tier 1** — mergeable by code alone? Docs-only (`*.md`, `docs/`), by the org owner, from a `worktree-*` branch onto `main`, green, conflict-free, ≤2000 changed lines, **no renames** (a rename is a delete wearing a docs name), file list read paginated so nothing hides past GraphQL's 100-file cutoff. Agent-steering files (`AGENTS.md`, `CLAUDE.md`, any `SKILL.md`, `.github/`, `.claude/`, `.agents/` — any case, APFS being case-insensitive) are never tier 1 however docs-shaped: a policy change always meets a person. `hausfold.co`'s `content/` is out too — its `main` deploys the public site, and a user-facing publish is always gated. The filter IS the definition — widening it is a reviewed edit to that script plus this file |
| `script/factory-shift` | one deterministic pass: print the budget line, run every open org PR through the tier check, merge tier 1 under a live lease (`gh pr merge --squash`, pinned to the head SHA the verdict saw, so a push in the gap fails closed), `bench pull` + `bench ship` if anything landed, flag a red latest run on any repo's `main` as `CI-RED` (+ a trill fault card, `--source factory`; superseded-run cancels don't count). Appends every line to `~/.cache/hausfold-factory/shift-YYYYMMDD.log` — the morning report is that file. `--dry-run` senses and merges nothing |
| `/nightshift` | the foreman: a Claude session on the main checkout that grants the lease, loops `factory-shift` on a ~20 min cadence, spawns capped fixer lanes on `CI-RED`, throttles itself against the budget line, and stops when the lease expires. [`.agents/skills/nightshift/SKILL.md`](../.agents/skills/nightshift/SKILL.md) |

## Tier 1, and why it is code and not judgement

The merge decision is the one act with no undo-by-default, so at level 0 it is
made by a path filter a person reviewed, not by a model's read of the diff.
An agent's judgement enters exactly twice, both bounded: writing the PRs in the
first place (unchanged from today), and deciding whether a `CI-RED` warrants a
fixer lane. Everything `factory-shift` refuses is *queued*, never closed — the
verdict and reason land in the shift log, and the PR waits where it always has.

## The budget governor

The aiusage pill's own feed (`~/.cache/claude-statusline/usage-claude.tsv`,
written from `api.anthropic.com/api/oauth/usage`, so it counts every client of
the account) already carries the four numbers that matter: 5-hour %, weekly %,
and both reset stamps. `factory-shift` turns them into one line —

    budget: 5h 42% · week 8% vs pace line 12% (under)

— where the pace line is 95% of the weekly window spent evenly across it.
The script only reports; the *foreman* throttles, and its two rules protect
the human's hours: never spawn work with the 5-hour window ≥ 80% (a factory
that saturates at 4 a.m. is rate-limiting the person who sits down at 9), and
never spawn with the week OVER the pace line. Merging and sensing are `gh`
calls and cost no tokens — those never throttle.

## Overnight on a closed lid

macOS sleeps on lid-close regardless of `caffeinate`; the setting that
actually holds is `sudo pmset -a disablesleep 1` (and `0` to undo — no wrapper
for this, and it belongs in a `haus` option before it belongs in anyone's
muscle memory). Plugged in, lid shut, the loop runs; asleep, it simply
pauses — a wakeup fires late, reads the same lease, and carries on, which is
the other face of "the failure mode is the status quo".
