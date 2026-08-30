# The factory — the night shift, level 0

**What runs when nobody is at the keyboard.** The bottleneck this removes is
the human merge: on an ordinary week the org lands ~100 PRs and every one of
them waited for a person. The factory merges the fraction of those that code
alone can vouch for, watches main CI, and leaves everything with taste in it
for the morning. It is built from four scripts and one skill, all in this
repo; there is no daemon, no webhook, no new repo. (The wider design — tiers
above 1, the foreman daemon, VM-verified merges — is a plan, and lives in
`ops/todo/`, not here.)

## The pieces

| | |
|---|---|
| `script/factory-lease` | the standing merge grant: `grant 12h` / `status` / `revoke`. One TSV line in `~/.cache/hausfold-factory/`, machine-local so no PR can grant itself authority. Expired == revoked == today's ordinary workflow — the factory's failure mode is the status quo |
| `script/factory-tier` | is a PR **tier 1** — mergeable by code alone? Docs-only (`*.md`, `docs/`), by the org owner, from a `worktree-*` branch onto `main`, green, conflict-free, ≤2000 changed lines, **no renames** (a rename is a delete wearing a docs name), file list read paginated so nothing hides past GraphQL's 100-file cutoff. Agent-steering files (`AGENTS.md`, `CLAUDE.md`, any `SKILL.md`, `.github/`, `.claude/`, `.agents/` — any case, APFS being case-insensitive) are never tier 1 however docs-shaped: a policy change always meets a person. `hausfold.co`'s `content/` is out too — its `main` deploys the public site, and a user-facing publish is always gated. The filter IS the definition — widening it is a reviewed edit to that script plus this file |
| `script/factory-shift` | one deterministic pass: answer whether a fixer lane is affordable (the `budget:` line — see below), run every open org PR through the tier check, merge tier 1 under a live lease (`gh pr merge --squash`, pinned to the head SHA the verdict saw, so a push in the gap fails closed), `bench pull` + `bench ship` if anything landed, flag a red latest run on any repo's `main` as `CI-RED` (+ a trill fault card, `--source factory`; superseded-run cancels don't count). A run it could not **read** is `ci-unknown`, and a pass that could not list the org at all **aborts non-zero** rather than ending on `pass done: 0 merged` — see *A pass that cannot see* below. Appends every line to `~/.cache/hausfold-factory/shift-YYYYMMDD.log` — the morning report is that file. `--dry-run` senses and merges nothing |
| `script/factory-watchdog` | the liveness check on the FOREMAN, which no pass can perform: a poller `factory-lease grant` starts, the shift's loop re-`ensure`s, and `revoke` stops. It reads the LATER of the newest shift log's mtime and the lease's own grant stamp as "the last moment the shift was demonstrably alive". Quiet past 45m → `foreman-stalled` in that same log and one trill card; past 90m → `foreman-gone` and **the lease is revoked**. Both thresholds count time the poller was AWAKE for, so a suspended Mac is `machine-slept` and costs the foreman nothing. `once` is the same check as a single command (0 healthy · 3 stalled · **4 live lease with no poller** · 1 no lease); `ensure` is `once` that also starts a missing poller |
| `/nightshift` | the foreman: a Claude session on the main checkout that grants the lease, loops `factory-shift` on a ~20 min cadence, spawns capped fixer lanes on `CI-RED`, spawns them only on the budget line's `fixer: yes`, and stops when the lease expires. [`.agents/skills/nightshift/SKILL.md`](../.agents/skills/nightshift/SKILL.md) |

## Tier 1, and why it is code and not judgement

The merge decision is the one act with no undo-by-default, so at level 0 it is
made by a path filter a person reviewed, not by a model's read of the diff.
An agent's judgement enters exactly twice, both bounded: writing the PRs in the
first place (unchanged from today), and deciding whether a `CI-RED` warrants a
fixer lane. Everything `factory-shift` refuses is *queued*, never closed — the
verdict and reason land in the shift log, and the PR waits where it always has.

## A pass that cannot see

The shift's product is a log somebody reads instead of having watched, so
**silence in it is a claim** — the claim that something was looked at and was
fine. Four lines exist so that claim is never made on the shift's behalf by a
step that failed:

| line | what could not be seen | exit |
|---|---|---|
| `prs-unknown: <repo>` | that repo's open PRs would not list, so none of them was judged this pass | 0 |
| `tier-unknown: <repo>#<n>` | `factory-tier` returned neither 0 nor 3, so this PR has no verdict. **Distinct from `queued`,** which is a verdict: a named refusal | 0 |
| `ci-unknown: <repo>` | that repo's latest `main` run would not read, so it is not known to be green | 0 |
| `pass ABORTED` | the org listing failed or came back empty, so nothing was sensed at all | **non-zero** |

Each carries the failing command's first line of stderr, because the foreman's
only judgement here is whether a repeat is a story, and a rate limit, an expired
token and a dropped connection are the same line without it.

`pass ABORTED` is the one that draws a trill card, and the asymmetry is blast
radius rather than cause: the other three are one repo or one PR unseen inside a
pass that otherwise ran, and this is the whole pass dead. Nothing about it
weakens *the failure mode is the status quo* — an aborted pass merges nothing
and leaves every PR where it was, which is the same place a revoked lease leaves
them.

The rule is the one the budget line already states about itself: degrade to a
named unknown, never to an answer that happens to parse.
`test/factory-shift.bats` stubs `gh`, `trill` and `factory-tier` and pins all of
it, including three controls that must not move — a green main says nothing, a
red one says `CI-RED`, and a judged refusal is still `queued` with its reason.

## The budget governor

The aiusage pill's own feed (`~/.cache/claude-statusline/usage-claude.tsv`,
written from `api.anthropic.com/api/oauth/usage`, so it counts every client of
the account) already carries the four numbers that matter: 5-hour %, weekly %,
and both reset stamps. `factory-shift` turns them into one line, and that line
ends in the answer rather than in the inputs —

    budget: 5h 13% · week 16% · reserve 59 pts · headroom 20 pts · fixer: yes

Exactly one thing is being decided: **can the account afford a fixer lane right
now.** Merging and sensing are `gh` calls and cost no tokens, so nothing else in
the shift throttles — the verdict gates fixer lanes and nothing besides.

Two conditions, both protecting the human's hours:

- **the 5-hour window under 80%.** A factory that saturates the rolling window
  at 4 a.m. is rate-limiting the person who sits down at 9. It outranks the
  weekly half and is checked first: a week with room to spare says nothing
  about the next four hours.
- **enough weekly headroom left for one lane.** `RESERVE` (70) points of the
  weekly window are the human's, draining evenly as the week runs off — so the
  reserve right now is `70 × (fraction of the week remaining)`. What sits
  between that and the `CEILING` (95; the top five points are nobody's) is the
  factory's to spend: `headroom = 95 − week% − reserve`, and a lane needs
  `FIXER` (5) points of it.

The question is **forward-looking**, and that is the load-bearing part. "Is the
week spent no faster than the clock so far" is a question nobody has, and it
cannot be answered yes by anything but an idle week: spend only rises and the
clock does not rewind, so one honest burst on Monday reads over-budget until
the reset however much is left. On an account spent in bursts that is a gate
with no reachable yes. Asking instead whether a lane *still leaves enough to
finish the week* forgives the burst and keeps the bound — 50% gone with 90% of
the week still to come is refused, 90% gone with a day left is refused, and 16%
gone with 84% of the week left is 20 points clear.

`FIXER` is an allowance, not a measurement: nothing meters a lane. It does not
need to be exact, because headroom is re-read from actual spend every pass, so
a lane that overruns its allowance shows up as less headroom for the next one.
All three numbers are dials, and turning one is a reviewed edit to
`script/factory-shift` **and** to this paragraph — the same way widening
`factory-tier`'s filter is. `test/factory-shift.bats` pins the values so the
two cannot drift apart silently.

**Every arm that could not do the arithmetic ends `fixer: no (budget unknown)`:**
a missing feed, a column reorder upstream, an absent reset stamp. An unknown
budget is not permission, for the same reason `ci-unknown` is not a green main.
And the foreman does not re-derive any of it — its rule is *spawn only on
`fixer: yes`*. A threshold written out in prose in a second file, over numbers
only the script can see, is one no test can reach; and because a gate's refusal
is the same word whether it is working or stuck, a gate that can never say yes
looks exactly like a gate doing its job.

## When the foreman dies

`factory-shift`'s unknown lines (above) keep a pass that could not *see* from
reading as a quiet night. This is the layer under them, and it exists because
every one of those lines has to be written by a pass that RAN.

The foreman is a Claude session driving a dynamic loop, and that loop continues
only if a turn completes and schedules the next wakeup. A turn that ends in an
error schedules nothing. Nothing is then left running, so nothing is left to
report it: the log's last line is an ordinary `pass done: 0 merged`, and the
lease goes on standing for hours with nobody exercising it. That is the shape
`script/factory-watchdog` exists for, and it is measured rather than imagined —
the 2026-08-29 shift ended six and a half hours early on one unreachable API
server, on a machine that never slept.

The heartbeat is the shift log's mtime, because every `say` in `factory-shift`
appends to it: the signal costs that script nothing and adds no second artifact
that could disagree with the first. It is read as the LATER of that mtime and
the lease's own grant stamp, never the log alone — logs are per-day and never
swept, so a fresh grant judged against yesterday's file would be revoked
milliseconds after being made, every night after the first. The same pairing is
what covers a foreman that died before writing anything: it is exactly as dead
as one that died after ten passes, and leaves no log to say so.

The watchdog's own lines go in that same log — one morning report, not two —
which means it restores the mtime after appending. A `foreman-stalled` line
that reset the clock it reads would make the next poll look healthy, write
`foreman-resumed`, and alternate forever without the quiet time ever reaching
90 minutes.

Two thresholds, because a blip and a death want different answers. At 45
minutes quiet the watchdog writes `foreman-stalled` and cards it once, and the
lease stands: a foreman whose network dropped for one turn may still be
mid-retry, and revoking under it turns a recoverable blip into a shift that
needs a person. At 90 it writes `foreman-gone` and revokes, and the morning
finds the ordinary human-in-the-loop workflow rather than a standing grant
nobody is exercising — the failure mode is the status quo, which is the whole
promise, and a lease outliving its foreman was the one place that promise was
not being kept.

Both thresholds count time the poller was **awake** for, not wall clock. A
machine that suspended has a stale log through nobody's fault — the watchdog
was not running either — so the loop measures how long its own `sleep` actually
took and subtracts the excess, writing `machine-slept` for the record. The
discount resets only when the heartbeat genuinely advances, which is the one
signal that distinguishes a shift that came back from a clock that merely moved.

Subtracted rather than forgiven with a grace window, which is what this did
first and got wrong: a laptop that suspends and wakes all night — the default,
`haus.power.lidAwake` being off — renews a window faster than it expires, so a
genuinely dead foreman kept its lease until morning and never even drew a stall
card. Awake time accumulates across any number of naps; only the naps are free.

`factory-watchdog once` answers the same question as one command, and has a
fourth exit for the case `grant` cannot otherwise report: **4, a live lease with
no poller watching it.** `grant` spawns the poller with its output discarded, so
a lost exec bit would be silent, and silent is the one thing this may not be —
which is why the shift's Start step runs `once` before its first pass.

`grant` establishes the invariant; it does not maintain it. A poller can still
be lost to a reboot, a panic or an OOM kill, and that is the likeliest overnight
foreman-killer after an API error precisely because it takes both of them at
once — leaving exactly the state this section says is now fixed. So the shift's
loop opens each wakeup with `factory-watchdog ensure`, which is `once` plus
starting a poller that is missing.

The watchdog deliberately does not run `factory-shift` itself. It could; the
script is deterministic and the lease is the authority it would run under. But
merging with no foreman means a `CI-RED` nobody reads and a `merge-failed`
nobody retries — a factory that keeps its hands moving after its eyes have
closed. Widening it into a headless foreman is a change to this file first.

## Overnight on a closed lid

macOS sleeps on lid-close regardless of `caffeinate` — `awake 3h` says so in its
own help, and the coffee pill is that command. The lever that actually crosses a
lid close is `pmset disablesleep`, and haus owns it: **`haus.power.lidAwake`**,
off by default because closing the lid is the one gesture everybody reads as
"stop". A shift wants `while = "always"`; the default `while = "agents"` holds
only while an agent is mid-turn and lingers 5 minutes after, so it drops in every
one of the loop's ~20 minute gaps. `requirePower` defaults true, so the Mac has
to be plugged in.

Asleep, the loop pauses rather than stops — but "pauses" is a claim about the
scheduler, not about the network. A wakeup that fires into an interface that has
not reassociated is a turn that errors, and that turn is the end of the shift
unless the watchdog above is running. Both halves are needed: the lid setting
keeps the machine there, and the watchdog is what notices when being there was
not enough. The watchdog counts only awake time — see `machine-slept` above —
so running without the lid setting costs coverage, not correctness: a shift on a
suspending laptop gets fewer passes, and a foreman that dies is still caught,
just after 90 minutes of *its* time rather than 90 minutes of the clock's.
