---
name: earshot
description: >-
  Find out what the OTHER agent lanes on this repo have already changed, before you
  collide with them — `bench overlap`. Use at the start of a lane, before a big edit
  to a file the whole family touches (AGENTS.md, a README, flake.lock, notes/), and
  once more before opening a PR. Also use when I say /earshot, "who else is in here",
  "is anyone else touching this", "will this conflict", or when a rebase turns up a
  conflict you want to understand rather than just resolve. Nothing is claimed,
  locked or declared — it measures the other lanes' actual work.
---

# Earshot: staying aware of the other lanes without coordinating with them

Parallel lanes are branches of ONE repo in ONE shared object store, all on this
machine. That makes coordination unnecessary. Every fact a claims-ledger would ask
an agent to *declare* — which files, which regions, who is where — can just be
**measured**, offline, in milliseconds:

```bash
bench overlap                 # the full read: who is in your files, and where
bench overlap --brief         # one line per lane — the lane-start version
bench overlap --path <file>   # just that file; silent when it's clear
```

There is no lock, no claim, no registration and no state file. Nobody can forget to
claim, nobody can lie, and a lane whose agent never runs this costs its siblings
nothing. **It is advisory and refuses nothing.** It is also not a review: `/code-review`
finds bugs, this finds neighbours.

## The three moments worth spending it on

| When | Run | What it saves you |
|---|---|---|
| **Lane start**, before you plan | `bench overlap --brief` | the expensive collision isn't textual — it's two lanes writing the same paragraph twice. Read the neighbours' commit subjects and pick different work. |
| **Before a big edit** to a shared file — `AGENTS.md`, a README, `notes/*.md`, a docs page | `bench overlap --path <file>` | it prints nothing when the file is clear, so this is cheap enough to make a habit. |
| **Before `gh pr create`** — every PR, not just `/ship`ed ones | `bench overlap` | catches the conflict while it's still one small rebase, instead of at merge time against a pile. This is Step 2.5's neighbour: assurance reads YOUR diff, earshot reads everyone else's. |

Don't run it on a loop. Nothing here changes second to second, and a check you run
forty times a turn is one you stop reading.

## Reading it

```
🌫  earshot — 3 other lane(s) on workshop; 1 in your way, 1 nearby
  ⚠  tidy-raccoon      AGENTS.md  L212-240
     “notes: step B is built — fetch and read, and a third thing to protect”
     ↳ tidy-raccoon lands first (already pushed) — then cuddly-sparrow rebases onto main
  ·  wobbly-weasel     README.md — elsewhere in the file
  merge-tree: clean against every lane and main
```

| | Means | Do |
|---|---|---|
| `⚠` | you and that lane changed the **same region** of the same file (within git's own 3-line context, so this is what a merge would present as one conflicted hunk) | act — see below |
| `·` | same file, different regions | nothing. Co-editing a long shared file is normal here; note it and carry on |
| `✗` | `merge-tree` says the two branches **already** conflict | rebase onto main once the other lands, or split the file |
| the quoted line | that lane's last commit subject — its intent, for free | read it before you decide whose work moves |

Exit codes: **0** clear · **3** same file · **4** same region. `--path` prints nothing
at all on a clear file, which is what makes it usable as a reflex.

## What to do about a `⚠`

In order of preference — the first one that applies:

1. **Move.** If their commit subject says they're already doing what you were about
   to do, do something else and say so. Cheapest resolution there is.
2. **Narrow.** Make your edit somewhere else in the file, or in a new file. Two lanes
   appending to the same `notes/*.md` should be two notes.
3. **Sequence.** Take the `↳` line's landing order and put it in your PR body's
   **Watch out** block, verbatim: `conflicts with #418 in AGENTS.md — land #418 first,
   then this rebases.` That turns a merge-time surprise into a line the review queue
   already has, and it's what `bench try-batch`'s checklist sends the reader back to.
4. **Rebase.** Once theirs lands: `git fetch origin && git rebase origin/main`, then
   force-push. **Never `git merge origin/main` into your branch** — it puts commits
   you didn't write into your PR's commit list.

The `↳` order is a default, not a rule anyone enforces. It reads only facts both
lanes can see — who has pushed, and whose diff is bigger — precisely so two agents
reach the *same* answer without talking to each other. Override it freely when you
know better; just say why in the PR body.

## The collision surfaces we actually hit, and the house answer for each

| File | What to do when two lanes are in it |
|---|---|
| `flake.lock` | never hand-merge. Take main's wholesale (`git checkout --theirs flake.lock`), then re-run `nix flake update <input>` if your branch genuinely needed the newer pin. |
| `AGENTS.md`, `CLAUDE.md`, `README.md` | keep **both** sides — these grow by section, and a conflict here is nearly always two additions, not two rewrites. |
| `notes/*.md` | one note per file. If two lanes are appending to the same note, split the note rather than resolving. |
| generated pages (`reference/options.md` and friends) | regenerate, never resolve. Whoever lands second re-runs the generator. |
| `bench`, a `SKILL.md`, any single-file tool | genuine sequencing problem — use the `↳` order, don't try to merge two halves of a rewrite. |

## What it can't see (say so rather than implying coverage)

- **Semantic collisions.** Two lanes can change different files and still break each
  other — a renamed `haus.*` option and its consumer, a changed function signature and
  its callers. Nothing textual finds those; the routing rules and Step 2.5 do.
- **Renames.** The index doesn't follow them, so a rename on one side and an edit on
  the other can read as quiet and still conflict. `merge-tree` catches it once both
  sides have committed — one more reason the two signals are reported apart.
- **Other repos.** Overlap is only defined within one repo: a `holt child` lane on
  another repo has its own object store and cannot textually collide with this one.
  That's the whole scoping rule, and it needs no flag.
- **Uncommitted work in a lane whose checkout is gone.** A parked lane is read from its
  branch, so only its commits are visible.
- **A merged lane that never rebased is still quietly present.** What main landed is
  subtracted from a side only when that side actually CONTAINS main's commit — subtracting
  from a lane that never rebased would delete work it really did author. So a lane whose
  PR was squash-merged and then left alone can still show as a `·` on a file main has
  since moved past. The loud half is gone; a `·` there may mean nothing is left to
  coordinate. `git diff origin/main <branch>` settles it in one line.

## From the main checkout

`bench overlap` run outside a lane reports **lane against lane** instead — every pair
that shares a file. That's the verdict `bench try-batch` reaches by merging the whole
open-PR queue, minus the PRs, the merges and the rebuild. Worth a glance before a batch
merge: the `⚠` pairs are the ones try-batch would drop.
