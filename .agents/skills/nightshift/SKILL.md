---
name: nightshift
description: >-
  Run the factory's night shift from this session: grant the merge lease, loop
  `script/factory-shift` until it expires, spawn capped fixer lanes on red main
  CI, and throttle everything against the token pace line. Use when I say
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
2. `./script/factory-shift --dry-run` — one sensing pass so your first real
   pass holds no surprises. If it shows `would-merge` rows the user can still
   see, name them in your start line.

## The loop

Use the dynamic loop mechanism (ScheduleWakeup), cadence **~20 min**. Each
wakeup:

1. `./script/factory-lease status` — **expired → jump to Shift end.**
2. `./script/factory-shift`. The script merges, ripples and logs on its own;
   your job is only what it printed:
   - **`CI-RED <repo> <url>`** → maybe spawn a fixer (rules below).
   - **`merge-failed` / `ripple-failed`** → try once yourself (`gh pr view`
     for the why; `bench pull` then `bench ship` for a ripple). Still stuck →
     leave it, it is in the log and trill already carded it.
   - **`queued` rows need nothing** — they are the morning's, by design.
     Never merge one yourself, whatever the reason column says: the lease
     covers tier 1 as `factory-tier` decides it, not as you would.
3. `noop: true` when the pass only sensed; `noop: false` when anything
   merged, spawned or failed.

## Fixer lanes

On `CI-RED <repo> <url>`, all four must hold:

- **budget**: the pass's `budget:` line shows 5h **< 80%** and the week
  **under** the pace line — else log `fixer-skipped: budget` and move on;
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
   (`~/.cache/hausfold-factory/shift-*.log`).

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
   user grants one.

## What this skill never does

Merge outside `factory-shift`, widen `factory-tier`, activate the machine
(`try switch` is the user's), touch releases, or spawn anything when the
budget line says OVER. Quiet nights are good nights.
