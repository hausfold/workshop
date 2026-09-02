# Bug reports — one door per repo, one shape for all of them

**What a stranger meets when something we made breaks.** The forms are
**generated**, not written: [`script/issue-templates.sh`](../script/issue-templates.sh)
renders them from one table into ten repos. Read this before editing a heredoc
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

## The in-product door

Everything in the family a stranger has in front of them carries one door onto
its own bug form, with the diagnostics field already answered: a menu row and a
palette row where there is an app to click, a verb where the thing that broke is
a command. Nothing about the forms changes; what goes is the trip — "open
github.com/hausfold, pick the right repo out of all of them, find its Issues
tab" — for anyone already inside the thing that just broke.

| | where the door is | what it prefills |
|---|---|---|
| **perch** | menu bar ▸ *Report a Bug…* | version · macOS + build · Mac model · install cohort |
| **trill** | menu bar ▸ *Report a Bug…* · `trill report [--print]` | the same four, plus whether the notification store it audits could be read |
| **pounce** | palette ▸ *Report Pounce Issue* · Settings ▸ app menu ▸ *Report a Bug…* · `pounce report [--print]` | the same four, plus the whole `pounce doctor` report |
| **haus** | palette ▸ *Report haus Issue* · `haus report [--print]` | the pinned haus revision · macOS + build · Mac model · the selected desktop, plus the whole `haus doctor` report, with the reporter's home directory rewritten to `~` |
| everything else | *(no door yet — the workshop, scruff and snug are CLIs with no `report` verb; nebelung and hausfold.co have forms and nothing to put a row in)* | |

Each app implements its own `BugReport` — pounce installs standalone and perch
is sandboxed, so there is nothing to share a library through. haus's is a fourth
copy and the only one that isn't Swift, for a reason of its own: what it reports
on is a *machine*, not a bundle, so the door is a verb of the CLI that already
drives that machine (`cmd_report` in `modules/core/haus.sh`), and the palette row
is one `exec` into it. That verb is also what gives the `curl | bash` user a
door, which a palette script could never be: it exists only where pounce does.
What they share is this page. Four things are the standard, and each of them is
a bug that fails **silently** if you get it wrong:

1. **`?template=bug.yml`, never `?title=&body=`.** A `body=` prefill opens
   GitHub's *blank* editor and walks straight past the form — its fields, the
   "wrong repo? file it anyway" preamble, the `bug`/`triage` labels. An issue is
   still filed, so nothing anywhere fails. A door built this way delivers a
   shapeless report every time and never tells you it did.

2. **Only `diagnostics` is prefilled.** `what` is the report, `area` is the
   reporter's guess, `anything` is optional by design — filling any of them in
   is putting words in their mouth. `diagnostics` is the one field the app
   answers better than the person can, which is the whole argument for the door.

3. **Encode strictly — `URLComponents.queryItems` is not enough.** Its
   `CharacterSet.urlQueryAllowed` *contains* `+`, so it leaves it literal, and
   the receiving server decodes a literal `+` back as a space. `pounce doctor`
   prints `cmd+space` on nearly every line it draws. Percent-encode everything
   that isn't RFC 3986 unreserved.

4. **Nothing in the block should want redacting.** It lands in a public issue,
   and a field the app filled in is a weaker kind of consent than one the
   reporter typed. No bundle paths, no home directory (pounce rewrites it to
   `~` before the doctor report goes anywhere), nothing off the user's shelf or
   inbox. **Nothing is sent until the reporter presses Submit** — the door opens
   a page, it does not file anything. It is not quite *"it only reads"*, the
   promise the doctor hints make: a door whose block overran the URL writes the
   block to the pasteboard when it has nowhere else to put it — a menu row, or
   haus's palette row, which has a stdout nobody will ever read. That is the
   door's one write, it is the reporter's own clipboard, and for pounce and haus
   it is a live path rather than a guard rail. **A clipboard write nobody is told
   about is that same silent failure one layer along**, so it comes with a
   banner: haus's palette row raises one through `haus-notify`, because the
   person is about to be looking at a form whose diagnostics field is empty. A
   CLI with a terminal in front of it writes nothing at all — the block is
   already on stdout, and `haus report --print` stays off the clipboard even
   when it overflows, because a caller asking for the text is a caller with
   somewhere to put it.

And one size limit: each door drops the prefill above ~6 KB of URL and puts the
block on the pasteboard (a menu row) or on stdout (a CLI) instead. For perch and
trill that is a guard rail against a block that grows later; for pounce and haus
it is a live path, because both doctors grow a line per thing they check: a
finished hacker machine's `haus doctor` is 4.6 KB of text, which is ~6.9 KB once
percent-encoded, so most haus reports take that branch rather than the prefill.

⚠️ **The ~8 KB GitHub 414s past is not the number that bites first.** A reporter
who is signed OUT is bounced to `/login?return_to=<the whole URL again>`, and
that redirect breaks earlier — with a **500**, GitHub's own error page, for
exactly the person filing their first issue. Measured against the real form
(2026-09-01, `haus`): 6.6 KB of URL redirects fine, 6.9 KB of URL comes back
500, and the raw 414 doesn't start until 8.3 KB. ~6 KB is the margin that covers
both. (That the encoded block above is also ~6.9 KB is arithmetic, not the same
number: one is a block, this is a whole URL.)

**A door and its hint are one artifact, and nothing checks that.** Each repo's
`DIAG_HINT` leads with the door — *"pounce report fills this in for you"* — so a
reporter who arrived the long way learns the short one. `--check` does **not**
catch it when they stop agreeing: it compares the generator's output to each
repo's rendered YAML, and it knows nothing about whether the menu row still
exists. Delete `trill report` tomorrow and the hint renders byte-identical and
the gate stays green, while the form promises a verb that is gone.

So the discipline is the whole guard: add or remove a door, and the hint is the
second half of the change, in the same round. Another known hole, stated rather
than papered over — and the same shape as the one below, a check that passes
while the thing it protects rots.

## The four decisions

### Short, and the same everywhere

The bug form is four fields, two of them optional. **The count is load-bearing,
not incidental** — longer forms come back empty, and a stranger with a broken
Mac has agreed to nothing. Adding a fifth field is a decision made here, in
prose; it is not a tweak to a heredoc.

### "Wrong repo? File it anyway."

Every bug form opens with it. hausfold is one product split across ten
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
| trill | the environment its menu row fills in, plus `trill doctor` for a double-banner report |
| workshop | `bench status` |
| perch | the first two lines of `perch doctor` — **that output is sliced, not pasted whole** |
| scruff | `scruff --version` + OS + which client spawned the lane |
| nebelung, hausfold.co | *(field omitted entirely)* |

A repo with no diagnostic command gets **no field**, rather than a field asking
for something that doesn't exist. A form that tells a reporter to run `nebelung
doctor` teaches them the project doesn't know itself.

perch is the one repo that asks for a **slice**. `perch doctor`'s header pair
carries the four facts the field wants — version, install cohort, macOS build,
Mac model — while the check rows under it name folders on the reporter's own
Mac. The block lands in a public issue, so the hint asks for the two lines and
says to leave the rest unless one of those rows is the bug. Ask for a whole
output only where the whole output is safe to publish.

perch's hint is also the only one that keeps a **route for a reporter with no
CLI**: `perch` reaches PATH through the cask, the flake or haus, and a copy
dragged out of the ZIP has none of them until its owner runs the `ln -s`. So the
hint names Settings' sidebar as the fallback. A by-hand instruction that assumes
an install cohort is a dead end for the cohorts it left out.

Each hint says what the command does *not* do — *it only reads; it changes
nothing, prompts for nothing, and sends nothing anywhere.* **A doctor that grows
a write makes that sentence a lie, and this table is where to come.** `perch
doctor` is the one that has: its liveness check knocks on the running app
through the group-container mailbox, which opens a request directory and closes
it again. Nothing of the reporter's changes and nothing survives the call, but
*"it only reads"* is not the sentence to make about it — so perch's hint says
what the knock is instead. Claim read-only where it is true; describe the write
where it isn't.

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

## The artifacts

| | what | where |
|---|---|---|
| **generator** | renders four YAML files into ten repos from one table | [`script/issue-templates.sh`](../script/issue-templates.sh) |
| **GitHub state** | the labels the forms apply, and the security destination they link | [`script/issue-labels.sh`](../script/issue-labels.sh) |
| **gate** | the only thing that notices when a repo stops matching | [`.github/workflows/issue-templates.yml`](../.github/workflows/issue-templates.yml) |
| **the doors** | the menu row / CLI verb in each app that opens the form prefilled | each app's own `BugReport` — perch `Perch/Platform/`, trill `Trill/Platform/`, pounce `pkgs/pounce/`; haus's is a CLI verb, `haus/modules/core/haus.sh`'s `cmd_report`, with `modules/launcher/commands/report-issue-haus.sh` as the one-line palette row into it |

**Why a generator.** Four forms hand-maintained across ten repos fails silently
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
`homebrew-tap`, `scruff-swift`, and whatever gets created next. That fallback is
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
4. Commit **in each repo you touched** — this is ten repos, and `bench ship`
   refuses dirty trees on purpose.

⚠️ Changing a `DIAG_HINT` that names an in-product door? The door is in that
app's own repo, and only `--check` notices when the two stop agreeing — so both
halves move in the same round. See *The in-product door*.
