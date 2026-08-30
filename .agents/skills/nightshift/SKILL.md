---
name: nightshift
description: >-
  Run the factory's night shift from this session: grant the merge lease, loop
  `script/factory-shift` until it expires, spawn capped fixer lanes on red main
  CI, and throttle everything against the token budget. Use when I say
  /nightshift, "run the night shift", "take the shift", "keep shipping while
  I'm away/asleep", usually with a duration ("/nightshift 12h"). The full
  design is docs/factory.md; this skill is the foreman — the judgement half
  the deterministic scripts refuse to carry.
---

# nightshift — the foreman loop

You are taking the shift. The user is away; everything below runs without
them, and the shift log is your handover. Read `docs/factory.md` once before
your first shift.

## Start

1. `./script/factory-lease grant <duration>` — the duration from the
   invocation (`/nightshift 12h`); no duration given means **1h**. Tell the
   user in one line what authority you now hold and until when.
2. `./script/factory-watchdog once` — confirm the poller `grant` just started
   is watching you. It is what turns your own death into something the user
   finds in the morning instead of a lease that stood all night with nobody
   exercising it. Exit **0** is what you want. **4** is `NO POLLER` — a live
   lease nothing is watching; say so in your start line, since the shift can
   run but its safety net did not start. **1** means the grant did not take
   and there is no shift to run.
3. `./script/factory-shift --dry-run` — one sensing pass so your first real
   pass holds no surprises. If it shows `would-merge` rows the user can still
   see, name them in your start line.

## The loop

Use the dynamic loop mechanism (ScheduleWakeup), cadence **~20 min**. Each
wakeup:

1. `./script/factory-watchdog ensure` — the lease check and the liveness check
   in one, and it restarts a poller lost to a reboot or an OOM kill. Exit
   **1 → jump to Shift end** (the lease is gone). **3** means the watchdog
   thinks *you* have been quiet too long, which on a wakeup you are running
   means the last pass failed to log — read the shift log before doing
   anything else.
2. `./script/factory-shift`. The script merges, ripples and logs on its own;
   your job is only what it printed:
   - **`CI-RED <repo> <url>`** → maybe spawn a fixer (rules below).
   - **`merge-failed` / `ripple-failed`** → **the line carries the reason;
     read it before doing anything.** A merge refused on `--match-head-commit`
     is the pin working — the branch moved after the verdict was computed —
     and needs nothing at all: the next pass re-judges it against the new head.
     Anything else, try the action once yourself (`bench pull` then `bench
     ship` for a ripple; `ripple-failed` names which of the two stopped, and
     re-running the other is not the fix). Still stuck → leave it, it is in the
     log. `ripple-failed` carded; `merge-failed` deliberately did not, an
     unmerged PR being exactly where the morning expects to find it.
   - **`queued` rows need nothing** — they are the morning's, by design.
     Never merge one yourself, whatever the reason column says: the lease
     covers tier 1 as `factory-tier` decides it, not as you would.
   - **`prs-unknown` / `tier-unknown` / `ci-unknown`** → the pass could not
     SEE that thing; it is not a verdict and it is not a quiet result. Run
     the pass again once. If the same line comes back, say so in your next
     message and, for a `ci-unknown`, check that repo's `main` yourself
     (`gh run list -R hausfold/<repo> -b main -L1`) rather than carrying an
     unknown through the night — the whole point of the shift is that a red
     main gets noticed. Never spawn a fixer off an unknown: you have not seen
     a failure, only a gap.
   - **`pass ABORTED`** (the script exits non-zero) → nothing was sensed and
     nothing merged. Retry once; if it aborts again, stop retrying, keep the
     loop alive at the normal cadence, and report it — this is the one shape
     where the whole pass is missing rather than one row of it.
   - **`foreman-stalled` / `foreman-resumed`** in the log → the watchdog saw
     you go quiet and you are back. Say so in your next message with the gap
     it names: a stall you recovered from is the shape that ends a shift when
     it does not recover, and the user is testing whether it does.
     **`machine-slept`** is the same line for a gap that was the Mac's, not
     yours, and needs no more than a mention. **`foreman-gone`** you will
     never read — it is written as your lease is revoked, which is the
     watchdog's verdict that you are not coming back.
3. `noop: true` when the pass only sensed; `noop: false` when anything
   merged, spawned or failed. **An `unknown` line or an abort is `noop:
   false`** — a pass that could not look is not a quiet night, and collapsing
   it into the noop streak is exactly the mistake those lines exist to
   prevent.

## Fixer lanes

On `CI-RED <repo> <url>`, all four must hold:

- **budget**: the pass's `budget:` line ends **`fixer: yes`** — else append a
  `fixer-skipped: budget — <why>` line to today's shift log and move on, where
  `<why>` is the text in the parentheses after `fixer: no`. Do **not** redo the
  arithmetic or reason around it: the
  script has already asked whether a lane still leaves the human enough to
  finish the week, and a threshold re-derived in prose is a threshold nothing
  can test and nobody can see is stuck. `fixer: no (budget unknown)` is a
  refusal like any other — an unreadable quota is not permission;
- **cap**: fewer than **2** fixers for this repo tonight (count your own
  `fixer-spawned: <repo>` lines in today's shift log);
- **novelty**: no earlier fixer tonight was spawned for this same head SHA —
  a fix that broke CI again does not get a third machine;
- the failure is on **main**, not a PR branch (the script only reports main).

Spawn it as a real background lane through the **handoff skill** — never a
raw headless `claude -p`, which stalls on its first permission prompt with
nobody watching, where a lane runs under the pane permission mode lanes
already have:

1. Write the fixer's brief with `/handoff`: the run URL, then "diagnose from
   the run log, fix it, verify, commit, push, open a PR titled
   `fix(ci): …`. Stop at PR open."
2. Spawn it with `HAUS_LANE_BACKGROUND=1` in front of the handoff skill's
   spawn step (`/handoff spawn <repo>`), so the window is born off-screen
   and focus stays wherever the user left it.
3. Append `fixer-spawned: <repo> <head sha>` to today's shift log
   (`~/.cache/hausfold-factory/shift-*.log`) — the same file `fixer-skipped`
   goes in. Both lines are yours to write: nothing in `factory-shift` knows a
   lane was considered, so a decision you only put in a message is one the
   morning cannot read and the cap cannot count.

A fixer's PR is not special: if it is docs-only the next pass merges it; a
code fix waits for the morning like every other tier-2 shape.

## Shift end

Lease expired (or the user says "end the shift" / revokes):

1. Final `./script/factory-shift --dry-run` so the log's last lines are the
   open state of the world.
2. Write the handover from today's `~/.cache/hausfold-factory/shift-*.log`:
   merged (count + list), queued (with reasons), CI reds and what each fixer
   did, budget at close. Post it as your final message AND
   `trill send --source factory --kind done --title "night shift over: <one line>"`.
3. Stop the loop (`stop: true`). Do not renew your own lease — only the
   user grants one. `factory-lease revoke` stops the watchdog with it; a
   lease left to expire on its own takes the watchdog down at its next poll,
   so neither needs stopping by hand.

## What this skill never does

Merge outside `factory-shift`, widen `factory-tier`, activate the machine
(`try switch` is the user's), touch releases, or spawn anything the budget
line has not said `fixer: yes` to. Quiet nights are good nights.

It also never stops the watchdog to quiet a `foreman-stalled` line, and never
re-grants a lease the watchdog revoked. Both are the shift reporting that it
stopped being able to do its job, and a foreman that silences either is the
exact failure the lines were added to make visible.
