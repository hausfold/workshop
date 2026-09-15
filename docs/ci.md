# CI

One gate per repo, all of it GitHub Actions. Every repo in the family is
public, so runner minutes are free and **the only thing CI costs is the wall
clock between pushing and knowing**. Everything below is written to keep that
number small, and it binds every repo here.

The gate's job is unchanged by any of it: a PR that goes green is a PR whose
claims were checked. Speed is never bought by dropping a check — it is bought
by not paying twice for the same one.

## The gate, repo by repo

| repo | workflow | where it runs | what it can only prove there |
| --- | --- | --- | --- |
| `haus` | `check` | ubuntu ×7 | evaluating a whole darwin system, plus twenty-nine platform-independent flake checks. Seven jobs, both halves grouped by what a step needs: the nix half is three (`nix eval` with the two bash suites that read what it builds, `nix flake check` alone, `haus add` alone), the shell half four (the lint, the suites that read snug's painter, the agent surface, every other room) |
| `pounce` | `build` | macOS ×2, ubuntu ×2 | the app is built by `xcrun swiftc` through Nix, so it wants a real Mac; the skill guards and the command lint do not |
| `perch` | `build` | macOS ×3, ubuntu | Xcode test + analyze on one Mac, Release plus the arm64 slice guard on another — cut at the `-derivedDataPath` the steps already divided on — and the iOS companion on a third; the skill guards are the one job off the Mac |
| `trill` | `build` | macOS | Xcode test + analyze + Release, and the no-instrumentation guard on the built bundle |
| `scruff` | `check` | ubuntu ×3, macOS ×2 | the acceptance suite on both OSes (occupancy and reflink diverge), five SDKs against one fixture, and `vendorHash` |
| `snug` | `ci` | ubuntu ×3, macOS | the Go width sweeps on both OSes, the bash painter on Linux only (it needs bash 4), and `vendorHash` |
| `nebelung` | `check` | ubuntu ×2 | that `dist/` and `preview/` still equal what the flake renders |
| `factory` | `Tests` | ubuntu | bats over the shift, the tier filter, the watchdog and the lease |
| workshop | `Tests` | ubuntu | `bench` itself — bats plus shellcheck |
| workshop | `issue templates` | ubuntu | that ten repos still match one generator; weekly, because the child half can only be caught by a sweep |
| `homebrew-tap` | `check` | macOS | that `Formula/scruff.rb` still installs: `brew style`, `brew audit --online`, a source build and its test block. The tap's one entry that compiles rather than placing a notarized `.app`, and the one a bot rewrites unattended on every scruff release |
| `hausfold.co` | `Docs`, `Preview`, `Deploy`, `Worker`, `DNS`, `Palette`, the preview sweep and four drift jobs | ubuntu | the site builds, its tables still match the data the layer publishes, and its palette still matches nebelung's |

`org-profile`, `producer-desktop` and `scruff-swift` have no gate: the first
two carry no code of their own that a test could fail, and the third is a
generated mirror. The tap's gate reaches `Formula/scruff.rb` alone — pounce's
and perch's entries place an artifact their own release gate already built,
signed and notarized, so there is nothing left there for a runner to fail.
`ops` runs a scheduled `scoreboard` and nothing on a push.

Release workflows are a different animal and are not on this list: they fire on
a `v*` tag, they publish something that cannot be withdrawn, and none of the
**speed** rules below are worth a risk there. **Rule 4 is not a speed rule and
is not exempt** — a floating action on the job that signs and notarises what
users install is the worst place in the repo to have one.

## Five rules

**1. Ask the runner image before you ask a package manager.** `shellcheck`,
`jq`, `git`, `node`, `npm`, `go` and `python` are already on `ubuntu-latest`.
`bats` is the one thing the family regularly needs that is not — it comes from
`sudo npm install -g bats`, never from apt, and on a macOS runner without the
`sudo` (that image's npm prefix belongs to the runner user). Print the version
of anything taken from the image, so an image that drops it fails loudly
instead of as `command not found` halfway through a lint.

**Never `apt-get update`.** The Azure mirrors the runners point at fail in a
way apt does not treat as failure, so the step can look alive for hours while
getting nowhere — `haus`'s `.github/workflows/check.yml` carries the full
account of the afternoon that taught us, and `Acquire::http::Timeout` is not
the fix. If apt ever becomes genuinely necessary, wrap the whole call in
`timeout 120 …`; a per-request option cannot bound a step that retries.

**2. One run per commit.** The trigger is:

```yaml
on:
  push:
    branches: [main]
  pull_request:
  workflow_dispatch:
```

`branches: ['**']` fires the same workflow twice for every push to a PR branch
— once as `push`, once as `pull_request` — for one commit and one answer.

`workflow_dispatch` is the third line's whole job: narrowing `push` to `main`
takes away the only way a branch with no PR yet was ever checked, and the
dispatch button hands it back. Drop it and the gate is one run per commit *and*
no run at all for work that isn't a PR. Dispatching a branch and then opening a
PR on the same tree does produce two runs, which is the one hole in the rule's
own headline — it takes a deliberate button press, so it stays.

That block is the floor, not the whole `on:`. `scruff`'s `check.yml` also
carries `workflow_call`, because its release workflow calls the gate at a tag.

The one line that may be dropped is `workflow_dispatch`, and only by a
workflow triggered by `pull_request` alone: it narrowed no `push`, so it took
nothing away to hand back. `hausfold.co`'s `preview.yml` is the family's only
one. It deploys a preview Worker named from `github.event.pull_request.number`
and keys its concurrency group on the same number, and both its jobs are gated
on `head.repo.full_name`, so a branch with no PR has nothing there for it to
check. Adding the line would hand someone a button whose run groups as
`preview-` with both jobs skipped, which is a worse answer than no button.

**3. Cancel a superseded PR run.** A second push to a branch has already made
the first run's answer worthless, and the abandoned run still holds its
runners. On the macOS ones that is a queue slot the next PR waits behind, which
is most of what a Mac job's start time is.

```yaml
concurrency:
  group: <workflow>-${{ github.event_name == 'pull_request' && github.ref || github.sha }}
  cancel-in-progress: ${{ github.event_name == 'pull_request' }}
```

**Only a PR run is ever in a shared group**, and the ternary is the whole
point of the line. Keying every event on `github.ref` would put all main pushes
in one group, where two things go wrong even with cancelling off: they
serialize, and GitHub cancels a *pending* run outright when a newer one joins
the group. Three merges inside one build's wall clock would then leave the
middle commit with no run at all — the exact tick the rule is protecting.
Everything that is not a PR keys on the commit instead, so it gets a group of
its own and cancels nothing.

The same reasoning is why `scruff`'s `check` is safe: its release workflow
calls it at a tag, a called run reports the caller's event (`push`), and a
cancel there would be a half-published release.


**A run that produces no per-commit answer is outside what the rule is
protecting.** Three workflows in the family key every run into one constant
group with no `github.sha` in it, all in `hausfold.co`: `deploy.yml`,
`dns.yml` and `preview-sweep.yml`, each group named for its own workflow.
What a gate loses when an intermediate run is dropped is that commit's answer,
which nothing else will produce. These three converge something outside the
repo instead — the deployed site, the DNS zone, this repo's own preview
Workers — and a converge has no answer to lose: the surviving run redoes the
whole job from the current state, so a run skipped in the middle is one whose
work the next one does anyway. For them the constant group is the point of the
line rather than a cost of it, because what it serializes is the resource.

**The property decides this, not the count.** Check for a `pull_request`
trigger first: none of the three has one, and a workflow that does produces a
per-commit answer for that run whatever else it does. `preview.yml` is the
standing example — it deploys and tears down a preview Worker, as external as
anything `deploy` touches, and still keys on
`github.event.pull_request.number` and cancels, which is this rule's ternary
with only the PR arm left. A fourth constant group, `pounce`'s job-level
`bump-pin`, sits in a release workflow and is off this list entirely; its own
comment makes the argument above.

`cancel-in-progress` is then a second and separate question, about what a
stopped run leaves behind. `deploy` cancels, a newer build superseding an
older one outright. `dns` does not, because a converge stopped between two
tables leaves the zone half-way between them. The preview sweep does not for a
different reason: its deletes are independent and a Worker that is already
gone counts as success, so nothing is left half-written. There is simply
nothing for a later run to supersede — killing one only delays the deletions
to the next cron, and a `dry_run` dispatch would otherwise take out a live
sweep.

The one place a constant group does cost something is `dns`'s scheduled
`check`, the Monday comparison of the zone against the table, which shares the
group with `publish`. A *pending* run is cancelled outright when a newer one
joins, whatever `cancel-in-progress` says, so a check queued behind a running
converge can be dropped — and that week's drift answer is produced by nothing
else until the next Monday. One writer on the zone is worth more than one
week's report. That is a trade made once, for a converge; it is not a reason
to key a gate this way.

`hausfold.co` is where to look for the rule that is NOT on this list: most of
its workflows carry a `paths:` filter, so a PR that touches no content runs no
content check. That is the rule the rest of the family has the least of — most
of these gates are small enough that a filter would cost more reading than it
saves, but it is the first thing to reach for when one is not. Its four drift
jobs are where a filter is paired with the thing that covers for it: each
checks the site's copy against a checkout of `hausfold/haus`, and a `paths:`
filter cannot see a change made in another repo. So each carries a weekly
`schedule:` beside its filtered `push` and `pull_request` — the filter keeps
the gate quiet while only this site moves, and the cron is the half that
catches an upstream that moved without it. The pairing is what to copy; the
rest of that repo is read the same as any other against the five rules.

**4. Pin third-party actions to a tag.** `@main` is whatever that vendor
pushed this morning, running on the machine that compiles what we ship.

**5. Group parallel jobs by what they need, never by how many steps each
has.** The gate is the longest job rather than the total, so a split is worth
exactly what it takes off the longest one. Everything else it does is cost:
each job pays checkout and its own tool install over again, and where runners
queue it takes a slot to do that on.

haus's shell half is where the family measured it. It was fifty steps in one
job at 2m28s, which made it the slowest gate we had. Grouped by what a suite
needs it is four jobs — `lint` the runner image alone, and the one of the four
that needs no `bats`; `draw` bats plus snug's `share/ui.sh` at the rev
`flake.lock` pins; `agents` and `rooms` bats and the image — and the longest of
them is 58s. That half went 2m28s → 58s and the whole `check` run 2m30s →
1m43s; the nix half's own split took it down again from there.

Fifty jobs would have been slower than one. A job on a Linux runner costs about
ten seconds of its own around the steps that do its work — checkout plus `sudo
npm install -g bats` is about 4s of it, already more than most of those suites
take to run — and the ten is what a step is measured against before it earns a
job of its own: under it, join an existing job. *A job costs more than its tool
install*, below, is the account of the rest. It is not one number across a
repo, and on a repo that caches its store it is not one number across a week
either — haus's nix half measures against a cache restore, which scales with
what the entry happens to be carrying. *The Nix store cache* below.

Count enters in one place only, and as a tiebreaker. `agents` and `rooms` both
want bats and nothing else, so the cut between them is by subject — the AI room
and the two surfaces an agent reads through it, against every other room — and
a suite that could sit in either goes to whichever is shorter that week. Both
halves still have to clear the fixed cost, which at 53s and 58s they do
several times over. That is size settling a toss-up, not size drawing the line.

**The fixed cost is the first gate, not the only one.** A suite can clear it
comfortably and still be worth nothing to move, because a split is worth the
distance to the *runner-up* and not one second more. So the number to measure is
the **gap** between the longest job and the one behind it, never the longest job
alone. A pole five seconds clear of its runner-up has five seconds in it however
the job is cut; the same pole twenty-five seconds clear has twenty-five. haus's
`agents` is the worked example and the answer there was no —
`.github/workflows/check.yml`'s shell-half banner carries that arithmetic, and
`script/probes/README.md` the stamped figures. A gap can also be wide enough
that the question is worth asking and the answer comes out the other way:
*What those Mac jobs are made of*, below, is the family's other worked example,
and perch's split is the one place in the family where a gate was cut in two
and both shapes then measured against each other.

Two things that measurement turned up, both of which generalise:

- **A job costs more than its tool install.** The rest of the ten above is
  queueing, a lead-in before the first step runs, `Set up job`, and a teardown
  after the last one. Most of it shows nowhere in a step list, which is why the
  tool install is the number that gets quoted and the wrong one to measure
  against.
- **Read the runner-up before you trust it.** A step whose duration repeats to
  within a second across ten runs is a clock rather than a cost. haus had one,
  and the mechanism generalises further than the instance: a test harness
  prints on a descriptor above 2, anything detached under it inherits that
  descriptor along with the rest, and a holder that outlives the harness goes
  on holding the STEP open after every test has reported ok and the harness
  itself has exited. The long sleep inside such a case is not the thing to
  shorten — the inherited descriptor is the thing to close. Padding like that
  moves the gap in whichever direction the job carrying it sits, so it can
  argue a split for or against on time nothing spent. `gh api
  repos/<owner>/<repo>/actions/jobs/<id>/logs` timestamps every line, which is
  where a job total stops being the whole story.

The rest of the family's splits are needs. `scruff` runs four SDKs in one Linux
job, each with its own toolchain setup in front of it, and gives Swift a job of
its own only because it wants a Mac. `snug`'s three ubuntu jobs are three
toolchains — Go, bats with shellcheck, Nix — and the bash one is Linux-only
because `share/ui.sh` needs bash 4 while macOS ships 3.2, a need that decides
*where* a job runs and not only whether it exists.

A need also survives as a boundary in a way it does not as a comment. Every
suite in haus's `draw` reads what that job fetches before any of them runs, and
one that runs without the painter skips rather than fails, which reads as a
pass. Keeping them below that fetch used to be three "MUST stay below" comments
spread through one long job; as a job boundary it is the one form of the rule
that appending a step in the wrong place cannot break. The other half is still
the reader's: a painter suite added to `agents` or `rooms` goes green having
checked nothing, so the grouping has to be got right when a suite is ADDED, and
`draw` still marks the order inside itself.

**The failure mode is a split balanced by step count.** It buys a runner
request per job and moves the gate nowhere, because the steps it shifted off
the longest job were not what made it the longest. If you cannot name which job
was the gate before and which is after, the split has not been measured — only
spread.

## The Nix store cache

`haus` and `nebelung` keep `/nix` between runs with
[`nix-community/cache-nix-action`](https://github.com/nix-community/cache-nix-action),
sitting behind `nixbuild/nix-quick-install-action` — one of the three
installers that action documents itself as compatible with, and the fastest of
them to land: about a second on Linux, against the eight or nine
`DeterminateSystems/nix-installer-action` took there. Neither figure travels to
a Mac, where the gap is *wider* rather than narrower: **5.1s against 68.2s**,
measured on pounce over eight paired runs. As of 2026-09-15 every `nix` job in
the family installs this way — scruff and snug swapped the same day pounce did —
and only pounce's swap came with a store cache attached to the question, which
it still answers no. *No third-party runner fleet* below has the macOS
breakdown.

The key is `flake.lock` plus every `*.nix`, so a lock bump or a module edit
pays full price and nothing else does. On haus that key sits behind a
**lineage** prefix as well — see the creep below.

**`save: ${{ github.ref == 'refs/heads/main' }}` is the line that matters
most, and it is not the default.** GitHub's ref scoping governs *reads*: a
branch may read its base's cache, which is what lets a PR restore what `main`
saved. It says nothing about writes. Left on the default, every PR uploads its
own gigabyte-class copy scoped to `refs/pull/N/merge`, a handful of open PRs
push the repo past GitHub's 10 GB budget, and its LRU eviction takes the `main`
entry the whole thing exists for.

**The test reads the ref and not the event, and rule 2 is why.**
`github.event_name != 'pull_request'` bounds only one of the two cases a write
can come from. A `workflow_dispatch` — which rule 2 requires of every workflow
whose `push` was narrowed to `main`, as the only way a branch with no PR gets
checked at all — is not a pull request, so a dispatch from a feature branch
passes that test and saves a whole store scoped to that branch. No run on
`main` can purge it, because the sweep below is scoped to the run's own ref
too; GitHub drops a cache only after seven days with nothing reading it, and
every further dispatch from that branch restarts that clock. The ref form is
the one that says it: a push to main writes, everything else only reads.

It is one such line in nebelung and two in haus, on `eval` and `checks`; *One
key per JOB* below is why the two do not share a key. haus's third nix job,
`acquire`, keeps no store at all — *The trade has to be re-tested* below is the
measurement that took it away.

**What bounds the store is `purge`, not a size cap.** `purge: true` with
`purge-created: 0` and a `purge-prefixes` that is a prefix of the key
(`nix-<os>-` on nebelung) sweeps every older entry under that prefix, so a repo
holds one store entry per ref per prefix rather than one per key it has ever
had. The sweep runs **after** the save, not before — it takes what was created
before the post phase, which the entry just written is not — so an old and a
new gigabyte-class entry do both sit against the budget for the length of an
upload. `purge-primary-key: never` governs the other pass,
the one that does run first, and keeps it off the entry being reused when the
key already hits. Both are scoped to the run's own ref, which is why a PR run
can never reach the entry `main` saved.

**No `gc-max-store-size-*` is set either, which is also not the obvious
choice.** The action collects garbage before saving, and `keep-outputs` does
not rescue you: `nix build` roots its own outputs through `./result` but not
the flake inputs, and a job that only evaluates (`nix eval`, `nix flake check`)
creates no root at all — and neither does one whose every `nix build` is
`--no-link`, so a collector run before the save takes exactly the paths the
next run wants. The store is saved whole instead, which means a restore unions
and each save carries forward everything the last one held.

**Which is why haus's store has a lineage, and resets it twice a week.** Its
entry went 472 → 688 MiB over its first six saves — ~36 MiB a save,
reconstructed from the size each saving run logs — on a key that three pushes
in four move, and haus takes a dozen or more a day. At that rate 10 GB is weeks
out, not years, and arriving there is not a warning: a save that no longer fits
means every run pays full price again, the exact surprise the arrangement
exists to avoid. So haus's prefix carries an ISO week, a first-or-second half
of it off `date -u +%u`, and the nixpkgs rev; a change in any of the three
starts a new lineage. The first main push of the half-week builds cold, saves
fresh entries, and the `purge-prefixes` sweep — broader than the key, so it
reaches across lineages — deletes the lineage it replaces. Two cold runs a week
is the whole cost, plus any PR opened in the gap before each push. The nixpkgs
rev is in there because a bump is the one change that would union a second
stdenv onto the first.

nebelung needs none of it — its key moves only when the lock or a `.nix` file
does, which is seldom — so it keeps the plain prefix.

**One key per JOB, the moment a repo's nix half is more than one job.** haus's
is three, and jobs sharing one primary key race on `main` in two ways, both
silent. The *save*: whichever job reaches its post phase first writes the
entry and the others are refused it as already present — and their stores are
not each other's, so the losers come back to a store missing what they need
and rebuild it every run, which reads not as a race but as a cache that
quietly stopped paying. The *purge*: `purge-primary-key: never` protects only
a job's own key, so jobs sweeping the broad `nix-<os>-` prefix together each
delete the others' fresh entries.

So haus's job token sits between the OS and the week — `nix-<os>-<job>-<ISO
week><half>-<nixpkgs rev>-<hash>` — and each job purges `nix-<os>-<job>-`
alone. The reset still works inside each family, and no job can reach
another's.

⚠️ **Entries do not creep at one entry's rate, and a weekly reset stops
bounding them.** Measured over one whole haus lineage — eleven saves, ten
intervals, each save logging the entry it uploaded — its three entries put on
30.8, 13.4 and 30.2 MiB a save, so 74.4 MiB per push that saves against ~36
before the split. That lineage started near 847 MiB cold and, with the 45 MiB
nix-installer entry that counts against the same ceiling, cleared 10 GiB at 126
saves; haus's last five full weeks ran 145, 106, 128, 126 and 116 *saves*, so
the median week landed on the line and three of the five went over — a
W32-shaped week would have ended near 11.4 GB. The verdict did not turn on the
cold start: at 974 MiB the median week is 10.2 GB and at 600 it is 9.8.

**Two things answer that, and haus carries both.** Dropping `acquire`'s cache
(below) takes 30.2 MiB a save and a cold 202.3 MiB out of the arithmetic as a
side effect, leaving two entries at 44.2 a save off 670.6 cold — 10 GiB at 215
saves against a median week's 126. And the reset is halved anyway, the ISO week
plus a first-or-second half, which puts a median lineage at ~3.4 GB and a
W32-shaped one at ~3.9. Belt and braces on purpose: the reset is the half that
keeps working if a cached job is ever added back. The second reset costs one
more cold run a week plus the PRs opened in the gap ahead of it, and the purge
stays a sweep of the job prefix, so it still reaches across lineages.

**Splitting a job pays the restore again, which is what decides the split.**
That restore is this half's fixed cost under rule 5 — the number a step is
measured against before it earns a job of its own — and haus's is 34-50s.

⚠️ It is not a constant, but it does not scale with the entry either, and
both readings set the bar wrong. Across 63 haus restores spanning 472-885 MiB
— the whole life of that cache — the download-and-extract phase is 32.4s flat,
Pearson r = -0.075, with the entries under 520 MiB averaging 33.5s against
32.3s for those over 800. The step around it is 34-50s with no trend. What
bounds it is path count and GitHub, not bytes, which is why nebelung's 332 MiB
in 17s does not extrapolate onto a store that is mostly `.drv`s. So the bar is
per JOB and roughly fixed, a lineage reset buys back store SIZE rather than
seconds, and the number to quote is the restore step of the run in front of
you. ⚠️ 472 MiB is as low as that fit reaches, and a reset — the half-week one
above most of all — makes entries below it. Re-run the probe on the first cold
run rather than extending the flat line down.

**Read the ceiling off the entry, not off the store.** GitHub's 10 GB is
compressed cache bytes, and a Nix store compresses hard. The action logs
`Current store size in bytes` on the runs that save — nar totals, which go out
as an entry several times smaller. `du -sh /nix/store` reads high in the other
direction, which is why no job prints it: reading the ceiling off `du` is how
several times of headroom came to look like pressure. `gh cache list --repo
hausfold/<repo>` is the number that counts, and
`script/probes/ci-cache-value.sh` puts it beside the job times. The sizes
themselves move week to week and are not quoted here — `script/probes/README.md`
carries them, stamped.

**A restore is not free, and that is the whole test**: not whether a job builds
something, but whether what the restore removes is bigger than the restore. What
it removes is two things: the bytes the job would have fetched — inside an eval
step as readily as a build step — and the derivations whose inputs the change
left alone. What it cannot remove is building the thing that just changed.
haus's entry comes back in ~35s and takes `nix eval` from 55s to 6s and `nix
flake check` from 57s to 1s. ⚠️ Those are the two numbers a reader most often
mixes: 55 and 57 are the COLD figures for those steps and are not additive with
the warm ones, so any re-measure starts by reading the "Restore the Nix store"
step. 30s-plus means warm; under a second means the key missed and everything
below it paid full price.

⚠️ A cold figure also belongs to the JOB it was measured in. `nix flake check`
reads 37s cold behind a `nix eval` that has already paid for nixpkgs, and 57s
as the first thing in a job of its own — the same step, and the split between
them is the whole difference. Re-measure a cold number after any split, and
never carry one across one.

It is on those two repos because that is where the trade lands:

- `nebelung` renders every port with **whiskers**, a Rust CLI in neither
  nixpkgs nor `cache.nixos.org`, which moves only when the lock does while the
  palette under it changes every PR. A hit costs nothing; a miss no longer
  costs a rustc closure either, because that job reads catppuccin's own cachix
  — *Reading someone else's public cache*, below.
- `haus` evaluates nixpkgs and then *builds* twenty-nine check derivations, and
  most PRs touch none of their inputs.

**The trade has to be re-tested after the cache is in, and it can go
negative.** The test above is usually run once, to decide whether to add a
cache, and then never again — but an entry only grows, and a job whose store is
bigger than the job is paying a restore for paths it never opens. That is not a
slow cache but a cache costing the gate more than no cache would, and the
restore being roughly FIXED is what makes it inevitable rather than gradual:
the cost of the restore does not rise with the entry, so what decides it is how
little of the entry the job opens. haus had a job in that state and it is the
worked example: `acquire` ran **45s cold against 71s warm** — 50s of restore in
front of a 13s step — so its cache cost the run 26s every time it worked, on a
job whose whole cold store is 202.3 MiB. A lineage reset would not have rescued
it either, because the restore is the cost and the restore does not shrink with
the entry. Its cache, its lineage step and its `actions: write` are all gone,
and the nix half's gate went from 81s cold with `eval` and `acquire` tied on it
to `eval`'s 71s alone.

Seeing it takes running the job twice — once from an empty store, which is what
the job needs, and once restoring the live entry and reading nothing, which is
what the entry carries — and diffing the two path lists. That is a temporary
workflow on a branch, not a probe flag, because it has to run the real steps;
`script/probes/README.md` has the last one and what it found. Two causes with
different lifetimes come out of it: work inherited from a job that has since
been split, which one lineage reset clears for good, and the save creep, which
comes straight back. Only the second is an argument for changing anything.

⚠️ And before narrowing a store that *is* paying, re-check rule 5: the answer
on haus's remaining two was to leave them alone, because past the reset that
half drops under the same repo's shell jobs and every second still on the table
belongs to a job the change would not touch. Shave the pole, then re-measure
which job that is — the answer moves.

It is **not** on the repos that build their own Swift on a Mac. There the
expensive derivation is the one whose source just changed, so a restore buys
the dependencies and nothing else, and a large `/nix` restore on a macOS runner
can cost more than it saves. `pounce` is the measured case and settles the
derivations half of it outright: what `cache.nixos.org` substitutes there is
114 MiB in 1.2s, and no restore is cheap enough to beat that.

⚠️ **That is a floor on what a warm store would remove, not a ceiling.** A
locked flake input's source tree is a store path like any other, so an
unmeasured part of the ~31s of flake resolution in front of that substitution
is restorable too — while nix's eval cache, which is not in `/nix`, is not.
What is certainly outside a restore is the installer, and that was the sharper
question this used to leave open: `cache-nix-action` sits behind
`nix-quick-install-action`, so a cache here would have had to carry an installer
swap with it, and nobody had measured that installer on a Mac.

**Now somebody has, and it closes the question from the other end.**
quick-install runs pounce's impure `xcrun` build unchanged — same derivation
hash, `…-pounce-2026.09.13.drv`, under both — for 5.1s against Determinate's
68.2s. So pounce took the 63s on its own, in `build.yml`, and the cache never
had to carry it. What that leaves a restore to beat is *smaller* than what it
faced before: 1.2s of substitution, in a job the swap alone took 63s out of.
The answer for pounce is still no, and it is now a no with the installer
question closed rather than open. *No third-party runner fleet*, below, has the
breakdown.

`scruff` and `snug` run Linux `nix` jobs and are the case that had to be
measured rather than reasoned about. Neither has one. scruff's job is ~16s
beside a two-minute macOS test job in the same run, so even a free restore takes
nothing off that gate. snug's ~34s *is* the longest job in its run, which is the
whole argument for caching it — and the argument dies on the phase split,
because almost none of those seconds are store.

⚠️ Both figures are one post-swap run each on `main`, 2026-09-15. They were ~28s
and ~41s with Determinate in front of them, and the swap took 7-9s out of each
without touching a phase below; the phase split under them is the pre-swap
sample and is unchanged by an installer. Re-read them before quoting either as a
mean.

**Split the step before you size the entry.** snug's `nix build` is 6.5-14.2s
evaluating nixpkgs, **2.3-3.5s** substituting the 69 paths it needs (216 MiB
from `cache.nixos.org` at 60-95 MiB/s), and 12-15s building two derivations —
~6s of `go build`, ~7s of `go test`. Both take the source as an input, so the
source change invalidates both on every run: snug's build row is worth nothing
to a restore, and that is the whole difference from haus, whose twenty-nine
checks mostly survive a PR untouched. What is left is the substitute row plus
the 47 MiB nixpkgs `-source` the eval pulls — **262 MiB of download, 3-4s of a
41s job**, and of a 34s one now that the installer in front of it is gone. That
source arrives in under a second at the rate the substitute row runs at, so the
rest of the eval row is evaluation, which no store holds.
Against those 3-4s stands a restore: 32.4s flat on haus by the fit above, and
17s at the family's cheapest, nebelung's — the nearest measured point to an
entry of snug's size, and the one the fit says not to extrapolate past.
**Thirteen seconds the wrong way on the best case the family has, twenty-nine on
the typical one.** Across eleven runs, PR and main alike, the substitute row
stayed inside 2.3-3.5s and the build row inside 11.7-15.4s.

⚠️ **A long job is not evidence of a large restorable part.** snug's is the
longest in its run and 3-4s of it is restorable, because a step is not a phase:
`nix build` evaluates, substitutes and builds, and the seconds pile up in the
two rows a restore cannot hand back. Read the phases, not the step —
`ci-cache-value.sh` prints them, and labels which row is which.

Measure before adding it anywhere new: `script/probes/ci-cache-value.sh <repo>`.

## What we deliberately don't do

**No third-party runner fleet.** Blacksmith, BuildJet and the rest are free for
open source and genuinely faster per core, but they are x86-64 Linux: they
cannot run a single one of the Mac jobs, which is where most of the family's
wall clock actually goes. That makes the trade a vendor in the critical path of
every merge, for minutes we do not pay for, on the half of CI that is already
the fast half.

**What those Mac jobs are made of.** That paragraph is a claim about steps, so
here are the steps. The shares below are means over eight PR runs of each repo;
`script/probes/README.md` carries the sample, stamped, and the commands that
take it again.

Rule 5's question about the *other* jobs is already answered in both repos.
pounce's other three are a 40s Swift unit-test job on a Mac and two Linux jobs
at ~12s and ~5s, against a 215s pole — which the installer swap below takes
~63s out of without moving which job the pole is; perch's were a 74s iOS build
and a ~5s Linux job against a 182s one. Neither pole loses the title in a single run of
that sample, so no regrouping among them reaches either gate. Whether the poles
themselves divide is the other half of rule 5's question, and these two repos
answer it differently — *It is also not all Xcode*, below.

`pounce` — `nix build (aarch64-darwin)`, 215s mean, and under half of it is a
compiler. This is the shape **before** the installer swap, and the reason there
was one:

| | mean | share |
| --- | --- | --- |
| set up + checkout | 4s | 2% |
| `DeterminateSystems/nix-installer-action` | 65s | 30% |
| `nix build` — flake resolution and fetching the inputs | 28s | 13% |
| `nix build` — substituting the darwin stdenv, 104 MiB | 3s | 1% |
| **`nix build` — one `xcrun swiftc -O` over every source file** | **102s** | **47%** |
| `nix build` — fixup and the small command derivations | 5s | 2% |
| post and cleanup | 5s | 2% |

⚠️ **Installing Nix costs more than substituting anything it fetches**, and it
is the half of that job an installer number quoted from a Linux runner hides
completely. The step's own log says where the 65s goes: ~13s creating an
encrypted APFS volume for `/nix` on a VM with three minutes to live, ~7s
creating thirty-two build users, **22.3s configuring Time Machine exclusions**
— 22.2 to 22.4s across all eight runs, so a fixed cost rather than load, and
nothing in the action's inputs exposes it — and ~20s for the daemon, the
shell hooks and three self-tests. The darwin stdenv under it arrives in ~3s,
and the compiler itself is the runner image's Xcode CLT, reached through
`xcrun` and never built.

⚠️ **And none of those 65s bought anything this build needs.** The workflow
comment credited Determinate with relaxing the macOS build sandbox, which the
impure `xcrun` build was said to require. Nix does not sandbox on macOS at all:
`sandbox` is `true` on Linux and `false` on every other platform, and *neither*
installer writes a `sandbox` line — Determinate's `/etc/nix/nix.conf` has none
and quick-install's `~/.config/nix/nix.conf` has none. The relaxation was never
granted because it was never needed, and `relaxed` is in fact the setting that
would have broken it: it exempts fixed-output and `__noChroot` derivations only,
and pounce's is neither. Run both ways on a probe branch, `sandbox = relaxed`
and `sandbox = true` each died on `/usr/bin/xcrun: Operation not permitted`,
exit 126, while the default ran green.

⚠️ **Do not read that as "quick-install does not sandbox".** The same action,
the same nix 2.34.7, reports `sandbox = true` on `ubuntu-latest` — single-user,
`build-users-group` empty, and sandboxed anyway, because the runner allows
unprivileged user namespaces. The platform default is the whole mechanism, which
is exactly why the installer was never the variable. **A comment that names a
mechanism is a claim; this one had gone unread for as long as the build stayed
green.**

`pounce` — the same job on `nixbuild/nix-quick-install-action@v35`, eight runs
on `macos-15`, 2026-09-15. Same derivation hash, same everything below the
installer:

| | mean | share |
| --- | --- | --- |
| set up + checkout | 4s | 2% |
| `nixbuild/nix-quick-install-action` | 5.1s | 3% |
| `nix build` — flake resolution and fetching the inputs | 31s | 17% |
| `nix build` — substituting the darwin stdenv, 114 MiB | 1.2s | 1% |
| **`nix build` — one `xcrun swiftc -O` over every source file** | **129s** | **70%** |
| `nix build` — fixup and the small command derivations | 11s | 6% |
| post and cleanup | ~2s | 1% |

⚠️ **The installer row is the only one to read absolutely, and it is the only
one that is paired.** Both arms ran as sibling jobs of the same run, on the same
fleet, at the same minute, in every one of the eight — so the installer figures
compare directly, and they never overlap: 3-13s against 61-75s. Nothing else
here is that clean. The `swiftc` row is the widest-spread number in the family
and it reads 13s *higher* under quick-install on this sample — 98-151s against
84-186s, ranges that overlap with Determinate holding the extreme — and there is
no mechanism for an installer to reach it: the compiler is the runner image's
Xcode CLT in both arms, reached through `xcrun` and never built. Unattributed,
and already inside the job totals: 234s against 183s over the same eight runs,
**51s off the pole**.

⚠️ This is a different sample from the eight-run `pull_request` one above, taken
on a probe branch two days later, and the two should not be pooled — the 215s
and the 234s are both means of the same job under the same installer, 19s
apart. Read the shares across them, and the 51s from inside this one.

The compile under that is one `/usr/bin/xcrun swiftc` over `*.swift` with `-O`
(`pkgs/pounce/build.sh`): a single module, so nothing about it is incremental
and there is no target graph to spread across cores. Nix prints the figure
itself (`buildPhase completed in …`, in the build log), and it is the only line
in the job whose length is about pounce's own source.

`perch` — `Native build and tests`, 182s mean, Xcode the whole way down. This
is the shape **before** the split: one job, and the reason there is now more
than one. Read it as the measurement that found the boundary, not as the
workflow:

| | mean | share |
| --- | --- | --- |
| set up, checkout, `xcodebuild -version` | 9s | 5% |
| **`Test` — Debug compile of the target graph** | **70s** | **39%** |
| `Test` — `xcodebuild` bringing the test host up | 21s | 12% |
| `Test` — the tests executing, and the results written | 8s | 4% |
| `Analyze` — incremental off the Debug `DerivedData` | 8s | 4% |
| **`Release build` — the same sources, from nothing** | **51s** | **28%** |
| the three guards on the Release bundle | 9s | 5% |
| post | 3s | 2% |

Two things a run total cannot show. The `Test` step is 99.5s of which the
assertions are 6.1s — the rest is one Debug build and then ~21s of `xcodebuild`
starting the test host before the first test runs, the figure
`IDETestOperationsObserverDebug` prints as `elapsed`. And the sources compile
**twice**: `Analyze` is nearly free because the three steps share one
`-derivedDataPath` and it reads what `Test` already built, while `Release build`
shares nothing with either — its own `SwiftDriver`, `SwiftCompile`, `Ld` and
`GenerateDSYMFile` for all three targets. 121s of the 182s is compiling and
linking, and 51s of that is the second configuration.

**So the verdict stands, and its reason is measured rather than inferred.** An
x86-64 fleet can take none of the above. Not the compiles, which are `swiftc`
against the macOS SDK; and not the half of pounce's pole that is not a compile
either, since installing Nix onto a Mac and substituting a darwin stdenv are
macOS-runner work by definition. What a fleet could run is pounce's ~12s
shellcheck and ~5s skill check and perch's ~5s one: call it a third off twenty
seconds, spread over three jobs that are not the gate in any run. That is the
"already the fast half" clause with numbers under it.

⚠️ **It is also not all Xcode, and "irreducible" is a claim about steps that
only one of these two supports.** pounce's pole is one installer and one
`nix build`, and one `swiftc` call does not divide into two jobs — there is no
boundary in it for rule 5 to find, whatever levers the invocation itself may
still have. perch's had one, and it is rule 5's kind rather than a step
count: `Test` and `Analyze` share a Debug `DerivedData`, `Release build` and
the three guards share the Release bundle, and nothing crosses. perch was split
there and then run both ways, so the paragraph that used to estimate this now
reports it: **a median 60s off the gate** (mean 58s, range 0-99s), and
`Debug tests and analyze` took the title in all seven post-split runs, ahead of
the iOS build that would inherit it next. Rule 5 asks which job was the gate
before and which is after; for perch that is `Native build and tests` and then
`Debug tests and analyze`, measured rather than reasoned.

**The third macOS runner does not queue behind the other two**, which was the
one thing that could have made the split a loss. Going from two concurrent
macOS jobs to three, the mean wait from a job being created to it starting went
7.4s to 6.4s — no serialization at all, on a public repo. Measure that before
copying the split anywhere; it is the half of the trade that belongs to the
account rather than to the workflow.

⚠️ **An arm mean would have got this wrong, and by enough to matter.** perch's
runners are not stable: `Test` alone ran 59-147s across the fourteen runs of
that sample with no source change between them. Comparing the arms straight
gives 164s against 141s, a 23s difference most of which is which half-hour a
run landed in. The 60s above instead compares **the two shapes inside each
run** — for a pre-split run, what the split would have given that same run;
for a post-split one, what the single job would have cost it — which cancels
runner speed almost entirely. On a pole this noisy that is the only comparison
worth making, and `script/probes/README.md` carries the per-run table.

⚠️ **The prize is capped by the runner-up, and once in seven it was zero.** One
pre-split run had the iOS companion at 119s against a Debug half of 71s: the
companion was already the pole, and the split would have bought that run
nothing. One post-split run closed to a 1s gap between its two halves, which is
the same fact from the other side. This is rule 5's own test biting on rule 5's
worked example — there is no second cut to make inside perch's Debug half,
because whatever comes off it lands on the iOS build.

⚠️ **Two carries these numbers will not take.** pounce was measured on
`macos-15` and perch on `macos-26`, and the installer figure above belongs to a
runner image as much as to an action — re-read it rather than moving it. And
`trill`'s gate is the same Xcode test + analyze + Release shape as perch's on
the same kind of runner, so the double compile is very likely there too; it is
**unmeasured**, and the boundary above is a claim about perch's jobs only.

**No hosted binary cache.** Cachix's open-source tier and FlakeHub Cache would
both beat the GitHub cache on a cold store, and both mean an account, a token
in nine repos, and a service that can be down when a PR cannot wait. The
Actions cache is already there, already free, and already scoped per repo.

All three grounds are about a cache we would *rent and push to*, which is what
Cachix's OSS tier and FlakeHub sell. Reading someone else's public cache is a
different trade, and it is allowed: a read-only `extra-substituters` entry
needs no account and no token, and a substituter Nix cannot reach is treated as
absent, so the run builds from source exactly as it would without one. It
cannot turn a green PR red, only a fast one slow — which is why "can be down
when a PR cannot wait" does not carry over.

The family has one, and it is the shape to copy: `nebelung`'s build job adds
`catppuccin.cachix.org` for whiskers, read-only, through `nix_conf` on the
installer step. `extra-substituters` adds to `cache.nixos.org` rather than
replacing it, and cachix answers Priority 41 against cache.nixos.org's 40, so
it is asked second and nothing else moves cache. Coverage does not have to be
total either: `x86_64-darwin` 404s there, which costs nothing while the Linux
job is the only one that builds.

⚠️ **What it is not is bounded to one path.** `trusted-public-keys` is a key
list, not a per-path grant, so a key added for one dependency can supply *any*
path that job substitutes. That is the whole cost, it is a real one, and it is
why this stays a per-job `nix_conf` rather than anything repo-wide — name the
dependency, the key and the job in the PR.

**No `paths-ignore` on a repo's gate.** This is the denylist, and it is the
opposite of the allowlist `paths:` above: a `paths:` says what one task
workflow is *about*, and a `paths-ignore:` on the gate says which changes the
whole repo will merge unchecked. The second is the one we don't write.

The idea is that a docs-only PR should skip the build. Measured over each
repo's last 40 merged PRs, against the ignore list a filter would actually
ship —

```
docs/**  (except **/SKILL.md)
README.md  AGENTS.md  CLAUDE.md  CHANGELOG.md  CONTRIBUTING.md
SECURITY.md  THANKS.md  FOUNDING.md  LICENSE
.github/ISSUE_TEMPLATE/**  .github/FUNDING*
```

— the share that would skip is haus 1, trill 6, scruff 10, perch 11,
nebelung 12. A quarter at the top of the range, one PR in forty at the bottom,
saving two or three minutes each.

That does not buy what it costs. A filter is a second, silent copy of the
answer to "which files does this job protect?", and the copy rots — that is
`docs/drift.md`'s whole subject. Prose here is *guarded* prose, so the copy has
real work to do and real ways to be wrong: `embed-skills.sh --check`, the two
`check-skills.sh`, the generated issue forms.

The sharp end is `scruff`, and only for one implementation. A `paths-ignore:`
under its `on:` is harmless at a tag — a `workflow_call` invocation does not
evaluate the called workflow's own triggers, so `release.yml` still runs the
full gate. An in-job changed-files filter (`dorny/paths-filter` plus an `if:`)
is evaluated every time the job runs, including that one, so *there* a docs
path can skip a job for a tag that publishes to npm, PyPI and crates.io, none
of which have an undo. If a filter is ever worth it somewhere, it goes on the
trigger, never in the job.

Cache the slow step instead. It helps every PR rather than one in four, and a
cold miss still runs the real gate.

The loose version of this measurement is how the idea keeps coming back. A
classifier that counts `modules/**/*.md` and `dist/**/README.md` as docs says
80%, which for haus is wrong by a factor of thirty. Re-run it against the list
above with `gh pr list --state merged --limit 40 --json number,files`, or don't
quote a number.
