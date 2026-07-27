---
name: ship
description: >-
  Finish a piece of work in the nebelhaus family and land it: commit stragglers, verify
  with `bench try`, open a PR and merge it, clean up every worktree the session spun up,
  ripple the flake locks with `bench ship`, then activate on the main checkout with
  `bench try switch`. Use when I say /ship, "ship it", "land this", or want to wrap up a
  change across the nebelung → pounce → nebelhaus → config chain. Worktree-aware: invoking
  /ship is the go-ahead to merge the PR and activate on main (by `cd`-ing there); `bench
  release` stays gated. Never opens or closes a zellij pane.
---

# Ship (nebelhaus workshop): verify → PR → merge → clean up → ripple → activate

The nebelhaus repos form a chain of pinned flake inputs
(`nebelung → pounce → nebelhaus → ~/.config/nix`). A commit is invisible downstream until
each downstream `flake.lock` is bumped — `bench ship` does that ripple. Never hand-walk it.
`bench` lives at the workshop root and is available as `bench`; run it from anywhere.

End-state: the work is merged **through a PR**, the locks are rippled, every worktree this
session created (except the one I'm in) is reaped, and the change is activated on main. Then
`/ship` stops and leaves me where I am — it never opens or closes a zellij pane.

## Why a PR, and why /ship merges it

Land through a PR (never a direct push or a local `git merge` into `main`) so parallel
agents can't clobber each other — a PR is atomic and conflict-detected. "Merging is my
call" means *don't merge unprompted*. **Invoking /ship IS that prompt:** open the PR for
the safety, then merge it. Only *activation* and *release* still wait for me.

## Step 0 — am I in a worktree? (decides how far you go)

```bash
git rev-parse --git-common-dir   # points OUTSIDE your toplevel → linked worktree
```

Everything through **ripple** is yours to drive from a worktree. The only lines you may
NOT cross from a worktree are `bench try switch` (activation) and `bench release` (always
gated) — both are main-checkout jobs. From the main checkout you can do those too.

## Step 1 — commit stragglers

`git status` in the repo you edited. Commit changes that belong to this work, in that repo
(imperative message; commits are GPG-signed). Don't sweep unrelated files in; if unsure a
file belongs, ask. `bench ship` refuses dirty trees on purpose — feature commits are
yours/mine, lock bumps are its.

## Step 2 — verify it builds

```bash
bench try            # build the machine against the LOCAL checkouts (worktree-aware)
```

`bench try` overrides whichever repo your worktree belongs to with YOUR checkout, so it
proves the branch before anyone merges. Read Nix errors bottom-up; don't proceed on a
broken build.

## Step 3 — open the PR (with a cold-boot body) and merge it

Push the branch and open the PR against `main` **in the repo you edited** (a workshop
worktree that spawned a child-repo worktree opens the PR in that child repo). Give it a
body a **cold thread can boot from**: the session that wrote this code will be gone by the
time it's feel-tested (panes close, worktrees get reaped), so if a bug turns up, the
recovery context has to live in `gh pr view` — not in a transcript that no longer exists.
Don't `--fill` from commit messages; write the distillation:

```bash
git push -u origin HEAD
gh pr create --base main --title "<imperative one-liner>" --body-file - <<'MD'
## What
<1–3 sentences: the change in plain terms>

## Why
<the bug or need this addresses — the motivation, not a diff restatement>

## Verify
- <concrete, observable step> → <expected result>
- <…>

## Watch out
<known risks, fragile spots, edge cases, follow-ups deliberately deferred —
and `path:line` anchors for the load-bearing bits>
MD
gh pr merge --squash --delete-branch
```

The **Verify** block is the single source of truth for the test steps: Step 7's verify-list
and `bench try-batch`'s checklist both send me back to it, so write the checks *here, once*,
where they outlive the pane. Keep the whole body dense — it's a handoff, not a changelog.
A fresh agent should be able to `gh pr view <n>`, read the diff, and be productive with no
other context.

Not mergeable (conflicts / non-fast-forward)? `git fetch origin && git rebase origin/main`,
push, retry. On conflicts you can't cleanly resolve, **stop and show them** — never
force-push `main`. On the current worktree's own branch the *local* delete may be skipped
because you're standing on it — fine, leave it: the merged branch + checkout are reaped when
I close this pane myself (the `wt` remove hook fires on Claude's graceful teardown) or by a
later `wt reap`. `/ship` no longer closes the pane, so there's nothing to race here.

## Step 4 — clean up every worktree this session spun up

A workshop worktree can't see the child repos, so when a task belongs to one you
hand-create a child-repo worktree (`wt child …`) to do the work. The `WorktreeRemove` hook
never reaps children, so confirm each one's branch is merged (open + merge its PR as in
Step 3), then let `wt reap` sweep them all at once:

```bash
wt reap        # removes every LANDED worktree across all repos: parked ones + clean,
               # merged live checkouts (dirty / unmerged / the pane you're in are kept)
```

`wt reap` is idempotent and safe — it only touches checkouts whose PR has merged and whose
tree is clean, so it can't drop live work. Fall back to a targeted
`git -C <child-repo-main-checkout> worktree remove <path>` only if you need to
force-remove a child you *know* is clean. `wt` lists every agent worktree across all
repos — run it after to confirm nothing you created is left. Don't delete worktrees you
didn't create.

## Step 5 — ripple the locks

If the merge moved an upstream repo's HEAD that downstreams pin, walk the bump down the
chain:

```bash
bench ship           # push upstream→downstream, nix flake update + lock-bump commit per hop
```

`bench ship` is allowed from a worktree (standing permission) — it only pushes
already-committed/merged work and operates on the MAIN checkouts, never your branch and
never activating. Size it to the change: small (bugfix/typo/config/theme/docs) — just ship;
big (feature/refactor/anything a user could feel break) — you'll already have paused before
merging, so confirm it's approved before you ripple.

## Step 6 — activation happens on main directly; release stays gated

- **Activation** (`bench try switch` → `darwin-rebuild switch`) is what makes the shipped
  change live. A worktree can't run it *in place*, but you **no longer surface it as a
  follow-up and stay open** — Step 7 does it for me by `cd`-ing to the main checkout and
  running `bench try switch` there directly (the PR has merged, so main holds the work;
  activation is passwordless and testing-in-prod is house style, so "you need to rebuild to
  see it" is not news worth halting on). **No pane is spawned, and this pane is not closed.**
  Only flag an activation when it's genuinely *risky* — something a user could feel break, or
  a change that's hard to roll back.
- **Release** (`bench release <repo>`: stamps today's CalVer date → tag → CI publishes →
  bumps `homebrew-tap`; releasable repos are pounce, trill, nebelhaus) is **always gated.**
  Never run it unprompted — but if this ship touched user-facing behavior in a tagged repo,
  **propose one** (nudging is expected, tagging is my call). Ship first, then release.

## Step 7 — report, land the verify-list, then settle-or-surface

Print the report, then a bottom-anchored **verify-list**, then activate (or surface a blocker).

**1. Report** — print it first so it's not lost to scroll: which repos shipped and their new
SHAs, what `bench try` verified, which PRs merged, which worktrees you removed.

**2. The verify-list — ALWAYS the last thing in the thread**, so it's easy to find later
and is my test checklist. A single session often opens more than one PR (a workshop PR plus
child-repo PRs) — list **every** one, oldest first:

```
## 🧪 To verify — live on `main`, not released. Break something? Fresh agent + the link + what broke.

- [pounce#35](https://github.com/nebelhaus/pounce/pull/35) — <one line: what changed> · **check:** <1–3 concrete, observable steps>
- [nebelung#12](https://github.com/nebelhaus/nebelung/pull/12) — <what changed> · **check:** <steps>

Activate (idempotent; /ship already ran this on main — re-run if needed): `bench try switch`
```

Rules for the list: each entry is a `[repo#N](url)` markdown link — repo-qualified, never
the word "PR", the link itself is the highlight. The `**check:**` is a one-line echo of the
PR body's **Verify** block (Step 3) — concrete and observable ("⌘Space 5×, no filter flash";
"hover the hidden bar, pill is opaque"), never "confirm it works." Keep the *full* steps in
the PR body, so a bug found after this pane is gone is recoverable from `gh pr view` alone;
the verify-list is the convenience index, not the system of record. Then **open every one of
those PR URLs in Chrome** via the browser tools if they're
loadable (ToolSearch them first); skip silently in a headless/cron ship — the block above
is the reliable copy.

**3. Settle-or-surface.**

- **Something genuinely ≥ ~3/5** — a broken build you worked around, a decision I owe you, a
  *risky* activation (something a user could feel break), a release worth proposing —
  **surface it and stop.** Routine activation is NOT this; just do it (below).
- **Otherwise it's settled — activate the change, then stop and leave the pane alone.**
  Activation is a main-checkout job, so `cd` there and run it directly — the PR has merged, so
  `main` now holds the work. Do **not** spawn a landing pane, and do **not** close this pane:
  I open and close my own panes.

  ```bash
  main="$(dirname "$(git rev-parse --path-format=absolute --git-common-dir)")"
  ( cd "$main" && bench try switch )      # activate the merged change on main
  ```

  When the shipped change needs no activation at all (docs, a lock-only ripple), skip the
  `bench try switch` — there's nothing to make live. Either way, **don't touch the pane.**
  The now-merged worktree you're sitting in is left exactly as-is — reaping it would pull the
  checkout out from under this live pane — and gets cleaned up when I close the pane myself
  (the `wt` remove hook), or by a later `wt reap`. (Other landed worktrees this session
  spawned were already swept in Step 4, which runs from the worktree cwd so its guard keeps
  *this* one.) Don't wait on CI unless CI is what this thread was about.

## The whole lifecycle (for context)

**hack** (agents draft on `worktree-*` branches) → **test** (`bench try`, worktree-aware) →
**PR** (push + `gh pr create`) → **merge** (/ship merges the PR — `gh pr merge`) →
**try switch** (activate; main checkouts only) → **ship** (`bench ship` ripples locks) →
**release** (tagged repos only; CI does the rest). A small fix runs straight through; big
changes pause before merge; release always waits for me.
