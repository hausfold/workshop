# Bug reports — one door per repo, one shape for all of them

**What a stranger meets when something we made breaks.** The forms are
**generated**, not written: [`script/issue-templates.sh`](../script/issue-templates.sh)
renders them from one table into nine repos. Read this before editing a heredoc
there.

There is no telemetry in anything we ship and there never will be, so **the
issue form is the entire feedback channel** — not one of several, the only one.
The form is a product surface, it has to work for someone who has never opened
an issue before, and every field it asks for is a field that can lose us the
report.

## What a reporter sees

Three forms, plus a chooser with three exits.

| | for | required fields |
|---|---|---|
| **Bug report** | something is broken | What happened · Where in \<tool\> |
| **Idea** | something should exist or work differently | What would you want to do · What do you do today instead |
| **Task (for maintainers)** | work we've already decided to do | What · Why · Verify |

And three contact links on the chooser that are *not* forms:

- **A security or privacy problem** → that repo's `/security/advisories/new`.
  First in the list, because the one report we must not receive publicly is the
  one a stranger is most likely to file publicly.
- **The docs** → the tool's docs, worded so it can't read as a brush-off: *a bug
  report that turns out to be documented is still a docs bug, so file it anyway.*
- **Made by us, but a different tool?** → the org page, which **lists** the
  repos. ⚠️ That link is a directory, not a door — `github.com/hausfold` has no
  **New issue** button. So it offers listing and nothing more; the permission to
  file in the wrong place belongs on the **bug form**, which is a place you can
  actually file, and is already the first thing that form says. A contact link
  can only honestly offer what its destination can do.

**Blank issues are off.** Templates only apply in the web UI, so `gh issue
create` from a terminal still opens anything we want, including from an agent
lane. What it buys is that a report from a stranger arrives in a shape.

## The four decisions

### Short, and the same everywhere

The bug form is four fields, two of them optional. **The count is load-bearing,
not incidental** — longer forms come back empty, and a stranger with a broken
Mac has agreed to nothing. Adding a fifth field is a decision made here, in
prose; it is not a tweak to a heredoc.

### "Wrong repo? File it anyway."

Every bug form opens with it. hausfold is one product split across nine
repositories and a reporter cannot be expected to know which one owns a
symptom — a tiling bug could be `haus` or the AeroSpace wiring, a banner that
won't dismiss could be `trill` or haus's notifications room, a broken install
link could be `hausfold.co`'s worker or haus's bootstrap. GitHub moves issues
between repos in one click. **Routing is our job and it is cheap; guessing is
theirs and it is expensive**, and the expensive version ends in no report at all.

### The diagnostics field is per-repo, and honest about absence

| repo | what it asks for |
|---|---|
| haus | `haus doctor` |
| pounce | `pounce doctor` |
| trill | `trill doctor` |
| workshop | `bench status` |
| perch | version + macOS + Mac model — **no doctor exists** |
| holt | `holt --version` + OS + which client spawned the lane |
| nebelung, hausfold.co | *(field omitted entirely)* |

A repo with no diagnostic command gets **no field**, rather than a field asking
for something that doesn't exist. A form that tells a reporter to run `nebelung
doctor` teaches them the project doesn't know itself.

Each hint says what the command does *not* do — *it only reads; it changes
nothing, prompts for nothing, and sends nothing anywhere.* **If a doctor ever
grows a write, that sentence is a lie in nine repos and this table is where to
come.**

### Task = the PR body, written first — and it says out loud that it's ours

The **Task** form's four blocks are **What / Why / Verify / Watch out** — the
same four the ship skill's Step 3 requires of every PR body in the family. An
issue filled in this way *is* the PR body, written before the work instead of
after; whoever does the work opens a PR whose body is that issue with Verify
ticked. **Verify** matters most, because `bench try-batch`'s tick-off checklist
sends the user back to exactly that list, and by then the session that wrote the
code is gone.

⚠️ It is the one maintainer-facing form on a chooser strangers read, so its
title and description have a job before they describe anything: let a reporter
rule it out at a glance. It is titled **Task (for maintainers)** and opens with
*"This one's for us"* plus a pointer to the right form.

The general rule, worth more than this instance: **internal vocabulary is free
in a comment and expensive in a form.** Where two audiences share a surface, the
copy is written for the one that doesn't know us. (The generator's comments keep
the vocabulary; they have one audience.)

## The three artifacts

| | what | where |
|---|---|---|
| **generator** | renders four YAML files into nine repos from one table | [`script/issue-templates.sh`](../script/issue-templates.sh) |
| **GitHub state** | the labels the forms apply, and the security destination they link | [`script/issue-labels.sh`](../script/issue-labels.sh) |
| **gate** | the only thing that notices when a repo stops matching | [`.github/workflows/issue-templates.yml`](../.github/workflows/issue-templates.yml) |

**Why a generator.** Four forms hand-maintained across nine repos fails silently
and asymmetrically: the day pounce's bug form asks for something haus's doesn't,
a reporter's answer depends on which repo they happened to land in, and nothing
anywhere fails. `--check` is the thing that fails. Every rendered file carries
`Generated by workshop/script/issue-templates.sh — edit the generator, not
this.` as its first line; that is advisory, the gate is the check.

**Why the labels script exists.** `bug.yml` declares `labels: ["bug",
"triage"]`, and **GitHub silently drops a label that doesn't exist in that
repo** — the issue opens, the label isn't on it, nothing says so. So the form
and the label set are one artifact split across two places, and only one of them
is in git. Three labels are ours (`triage`, `idea`, `task`), coloured from
nebelung's palette; `bug` is deliberately not in the set, since it ships with
every repo and already means the right thing.

Same shape for the security link: `config.yml`'s first contact link is
`/security/advisories/new`, which **404s unless private vulnerability reporting
is enabled** for that repo. A security contact link that 404s is worse than
none — it fails closed for exactly the reporter who was doing the right thing.

The script is **read-only by default**; everything it touches is a public org,
so `--apply` is a deliberate second run.

**What the gate catches.** The workflow clones the family (all public,
anonymous shallow reads, no token), runs `--check`, then parses every rendered
YAML — because **a form that doesn't parse is a form GitHub silently refuses to
render**, falling back to a blank issue with no message.

⚠️ **A hand-edit landing in a child repo is invisible until the next run here.**
That repo's own CI knows nothing about the generator. The weekly schedule bounds
the window; the header comment bounds the mistake. Neither is a gate. Known
hole, stated rather than papered over.

## The org-wide fallback

`hausfold/.github` (checked out as `org-profile/`) gets the same four files, and
GitHub serves them to **any repo in the org with no templates of its own** —
`homebrew-tap`, `holt-swift`, and whatever gets created next. That fallback is
the difference between "every repo" being a list we maintain and being true.

Its form differs in exactly two ways, both forced: it **can't** ask for a
diagnostic command, because it doesn't know what the reporter is running; and
its "where" dropdown is **the tool list**, not one tool's insides — which makes
it the routing form, and routing is what a reporter who landed in an unlabelled
repo needs. Its security link points at haus's advisories: advisories are
per-repo, there is no org-wide form, and the family's front door is the honest
destination.

## What this deliberately does NOT do

- **No Projects board.** A board for a queue that doesn't exist is furniture.
- **No Discussions.** Off on all fourteen repos — GitHub Discussions before a
  Discord, and neither before there is recurring conversation to house.
- **No auto-triage bot, no stale-bot, no issue→PR automation.** Every one of
  those speaks to a stranger in our voice without us reading what it is
  answering.
- **No `bench` verb.** Both scripts run by hand or by CI a handful of times a
  year. `bench` is for the flake chain; a verb per script is how a CLI gets fat.

## How to change it

1. Edit the table in `script/issue-templates.sh` — never a rendered file.
2. `./script/issue-templates.sh` to write them, `--check` to verify.
3. New label, or a new repo? `./script/issue-labels.sh` (dry run), then `--apply`.
4. Commit **in each repo you touched** — this is nine repos, and `bench ship`
   refuses dirty trees on purpose.
