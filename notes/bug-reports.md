# Bug reports — one door per repo, one shape for all of them

Working design, 2026-08-26. What a stranger meets when something we made
breaks, in every repo in the family, and the three artifacts that keep those
doors identical.

The forms are **generated**, not written:
[`script/issue-templates.sh`](../script/issue-templates.sh) renders them from
one table into nine repos. Read this before editing a heredoc there.

## 0. The claim

There is no telemetry in anything we ship and there never will be, so **the
issue form is the entire feedback channel**. Not one of several — the only one.
That single fact decides most of what follows: the form is a product surface,
it has to work for someone who has never opened an issue before, and every
field it asks for is a field that can lose us the report.

Before this, every repo's "Open a new issue" button gave a blank textarea. Nine
public repos, zero templates, and the docs' own closing line
(`troubleshooting.mdx`: *"Open an issue with the output of `haus doctor`"*) was
the only thing anywhere that told a reporter what to include — one page, one
repo, easily missed.

## 1. What a reporter sees

Three forms, plus a chooser with three exits.

| | for | required fields |
|---|---|---|
| **Bug report** | something is broken | What happened · Where in \<tool\> |
| **Idea** | something should exist or work differently | What would you want to do · What do you do today instead |
| **Task (for maintainers)** | work we've already decided to do | What · Why · Verify |

And on the chooser itself, three contact links that are *not* forms:

- **A security or privacy problem** → that repo's `/security/advisories/new`.
  First in the list, because the one report we must not receive publicly is the
  one a stranger is most likely to file publicly.
- **The docs** → the tool's docs. Worded so it can't be read as a brush-off:
  *a bug report that turns out to be documented is still a docs bug, so file it
  anyway.*
- **Made by us, but a different tool?** → the org page, which **lists** the
  repos: *open its repo and use its Issues tab. Or just file here; moving an
  issue between our repos is one click for us.*

  ⚠️ **That link is a directory, not a door**, and the first wording forgot it.
  It read *"Don't spend time working out which repo. File here and we'll move
  it"* while pointing at `github.com/hausfold` — a page with no **New issue**
  button anywhere on it. So the one sentence that was meant to spare a reporter
  the routing problem *was* the routing problem: click it and you land somewhere
  you cannot file, having been told to file. The permission to file in the wrong
  place belongs on the **bug form**, which is a place you can actually file, and
  it is already the first thing that form says. A contact link can only honestly
  offer what its destination can do — here, listing.

**Blank issues are off.** This costs us nothing: templates only apply in the web
UI, so `gh issue create` from a terminal still opens anything we want, including
from an agent lane. What it buys is that a report from a stranger arrives in a
shape.

## 2. The four decisions

### Short, and the same everywhere

`launch-phase-1.md` §3 fixed the tester report form at **five questions**, with
the reason stated flat: *longer forms come back empty*. The bug form is four
fields and two of them are optional, which is the same judgement applied to a
colder audience — a tester agreed to spend an afternoon on us, a stranger with a
broken Mac did not.

The count is therefore **load-bearing, not incidental**. Adding a fifth field is
a decision to be made here, in prose, against that finding; it is not a tweak to
a heredoc.

### "Wrong repo? File it anyway."

Every bug form opens with it. hausfold is one product split across nine
repositories and a reporter cannot be expected to know which one owns a
symptom — a tiling bug could be `haus` or the AeroSpace wiring, a banner that
won't dismiss could be `trill` or `haus`'s notifications room, a broken install
link could be `hausfold.co`'s worker or `haus`'s bootstrap. GitHub moves issues
between repos in one click. **Routing is our job and it is cheap; guessing is
their job and it is expensive**, and the expensive version ends in no report at
all.

This is the one line in the whole flow that most directly protects the report
count, and it is why the org-wide fallback form (§4) exists at all.

### The diagnostics field is per-repo, and honest about absence

Each bug form asks for the one command that repo actually has:

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
for something that doesn't exist. A form that tells a reporter to run
`nebelung doctor` teaches them the project doesn't know itself.

Each hint says what the command does *not* do — *it only reads; it changes
nothing, prompts for nothing, and sends nothing anywhere.* Every one of these is
true today and each is checkable: `haus doctor` is explicitly the read-only half
of `haus permissions`, `trill doctor` reads macOS's notification store, `bench
status` reads git and locks. **If a doctor ever grows a write, that sentence is
a lie in nine repos and this table is where to come.**

⚠️ The two gaps are worth naming rather than smoothing over: **perch has no
doctor** (it is also the family's one A5 failure — `UserDefaults`, not a config
file, per `agent-surface.md` §8), and **holt has `--version` but no health
check**. Both forms currently substitute "tell us your version by hand", which
is the weakest field in the set and the one most likely to come back empty.

### Task = the PR body, written first — and it says out loud that it's ours

The **Task** form's four blocks are **What / Why / Verify / Watch out** — the
same four the ship skill's Step 3 requires of every PR body in the family.

That is the whole of the "issues as the new PRs" idea, applied to our shape: an
issue filled in this way *is* the PR body, written before the work instead of
after. Whoever does the work opens a PR whose body is that issue with Verify
ticked. **Verify** is the block that matters most, because `bench try-batch`'s
tick-off checklist sends the user back to exactly that list, and by then the
session that wrote the code is gone.

⚠️ **It is the one maintainer-facing form on a chooser strangers read**, which
is a cost the other two don't have: every reporter meets it, and none of them
wants it. Its title and description therefore have a job before they describe
anything — let a reporter rule it out at a glance. The first wording did the
opposite, reading *"Work we've already decided to do — the spec a lane picks
up"*: **lane** is workshop vocabulary for an agent's worktree, **spec** invites
a stranger to think this is where feature requests go, and neither word tells
them the form isn't for them. It is now titled **Task (for maintainers)** and
opens with *"This one's for us"* plus a pointer to the right form.

The general rule, worth more than this instance: **internal vocabulary is free
in a comment and expensive in a form.** Nobody filling in a Task needs the word
"lane" — they already know the flow — while everybody *not* filling one in pays
a re-read for it. Where the two audiences share a surface, the copy is written
for the one that doesn't know us. (The generator's comments keep the vocabulary;
they have only one audience.)

## 3. The three artifacts

The forms are not the whole flow. Two thirds of what makes them work is not a
YAML file.

| | what | where |
|---|---|---|
| **generator** | renders four YAML files into nine repos from one table | [`script/issue-templates.sh`](../script/issue-templates.sh) |
| **GitHub state** | the labels the forms apply, and the security destination they link | [`script/issue-labels.sh`](../script/issue-labels.sh) |
| **gate** | the only thing that notices when a repo stops matching | [`.github/workflows/issue-templates.yml`](../.github/workflows/issue-templates.yml) |

### Why a generator

Four forms hand-maintained across nine repos is `_bench`'s standing hazard with
a wider blast radius (`AGENTS.md`: *"a hand copy and can rot"*). The failure is
silent and asymmetric: the day pounce's bug form asks for something haus's
doesn't, **a reporter's answer depends on which repo they happened to land in**,
and nothing anywhere fails. `--check` is the thing that fails.

Every rendered file carries `Generated by workshop/script/issue-templates.sh —
edit the generator, not this.` as its first line. That is advisory; the gate is
the check.

### Why the labels script exists at all

`bug.yml` declares `labels: ["bug", "triage"]`, and **GitHub silently drops a
label that doesn't exist in that repo.** The issue opens, the label isn't on it,
nothing anywhere says so. So the form and the label set are one artifact split
across two places, and only one of those places is in git.

Measured 2026-08-26, before anything was applied: all nine repos carried
GitHub's nine stock labels and **none of `triage`, `idea` or `task`**. So every
form as first written would have applied `bug` and dropped the rest.

Three labels are ours, coloured from Nebelung's palette. `bug` is deliberately
*not* in the set — it ships with every repo and already means the right thing,
and restyling a default label is churn on nine repos that buys nothing.

Same shape for the security link: `config.yml`'s first contact link is
`/security/advisories/new`, which **404s unless private vulnerability reporting
is enabled** for that repo. Measured the same day: **off on all nine.** A
security contact link that 404s is worse than none, because it fails closed for
exactly the reporter who was doing the right thing.

The script is **read-only by default** — everything it touches is a public org,
so `--apply` is a deliberate second run.

### What the gate does and does not catch

The workflow clones the family (all public, anonymous shallow reads, no token)
and runs `--check`, then parses every rendered YAML — because **a form that
doesn't parse is a form GitHub silently refuses to render**, falling back to a
blank issue with no message. That is the same class of failure as the dropped
label: a live surface degrading with nothing red anywhere.

⚠️ **A hand-edit landing in a child repo is invisible until the next run here.**
That repo's own CI knows nothing about the generator. The weekly schedule bounds
the window; the header comment bounds the mistake. Neither is a gate. This is
the known hole, stated rather than papered over.

## 4. The org-wide fallback

`hausfold/.github` (checked out as `org-profile/`) gets the same four files, and
GitHub serves them to **any repo in the org with no templates of its own** —
`homebrew-tap`, `holt-swift`, `producer-desktop`, and whatever gets created
next. That fallback is the difference between "every repo" being a list we
maintain and being *true*.

Its form differs in exactly two ways, both forced:

- It **can't ask for a diagnostic command**, because it doesn't know what the
  reporter is running. No field.
- Its "where" dropdown is **the tool list**, not one tool's insides. Which makes
  it the routing form — and routing is precisely what a reporter who landed in
  an unlabelled repo needs.

Its security link points at `haus`'s advisories: advisories are per-repo, there
is no org-wide form, and the family's front door is the honest destination.

## 5. What this deliberately does NOT do

- **No Projects board.** goose's *"issues as the new PRs"* runs on one — and
  that is a board for a team triaging a public queue that exists. Ours is empty
  by construction (four open issues across nine repos, all ours). A board before
  a queue is furniture. The Task form is the half of that idea that pays off
  before there are strangers; the board is the half that needs them.
- **No Discussions.** Off on all fourteen repos, and `go-to-market.md` §8 says
  why: GitHub Discussions before a Discord, and neither before there is
  recurring conversation to house.
- **No auto-triage bot, no stale-bot, no issue→PR automation.** Every one of
  those is a thing that speaks to a stranger in our voice without us reading
  what it is answering.
- **No `bench` verb.** Both scripts are run by hand or by CI, a handful of times
  a year. `bench` is for the flake chain; a verb per script is how a CLI gets
  fat.

## 6. What is still open

- [ ] **Run `script/issue-labels.sh --apply`** — until it runs, the forms apply
      one of three labels and the security link 404s in all nine repos. It is
      gated because it writes to a public org.
- [ ] **perch's diagnostics field is a placeholder for a command that should
      exist.** A `perch doctor` would close it, and perch is already the A1/A5
      laggard in `agent-surface.md` §8 — the shelf you can write to and not read
      from. Same for `holt`, more cheaply.
- [ ] **Nothing points a user at these forms from inside the products.** The
      READMEs' *"tell us what breaks"* links go to `/issues`, which now lands on
      the chooser, so that half works by accident. A `haus doctor` that ended
      with *"found something wrong? here's the URL"* would be the deliberate
      version.
- [ ] **The first real report is the only test that counts.** Everything above
      is reasoning about a form nobody outside this machine has filled in.

## 7. How to change it

1. Edit the table in `script/issue-templates.sh` — never a rendered file.
2. `./script/issue-templates.sh` to write them, `--check` to verify.
3. New label, or a new repo? `./script/issue-labels.sh` (dry run), then
   `--apply`.
4. Commit **in each repo you touched** — this is nine repos, and `bench ship`
   refuses dirty trees on purpose.
