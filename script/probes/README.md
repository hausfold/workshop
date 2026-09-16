# Capability probes

Re-runnable evidence for haus's [`docs/macos-settings.md`](https://github.com/hausfold/haus/blob/main/docs/macos-settings.md).
The matrix is one macOS release away from being wrong — rerun these on every bump.
(Seven probes here aren't about macOS at all — `pack-priority.nix`,
`preset-composition.nix`, `scale-reach.nix`, `namespace-collision.nix`,
`source-shapes.sh`, `machine-diff.sh` and `ci-cache-value.sh`, at the bottom —
but they earn the same shelf: a claim in a docs file, with the command that
proves it beside it.)

```sh
swift script/probes/accessibility-effective.swift   # effective a11y state (NSWorkspace)
swift script/probes/locale-effective.swift          # resolved locale + enabled input sources
swift script/probes/displays.swift                  # displays, persistent UUIDs, HiDPI modes
./script/probes/ncprefs-flags.sh                    # per-app notification switches
./script/probes/sound-sweep.sh                      # alert volume, beep sound, startup chime
./script/probes/locale-sweep.sh                     # region keys, input sources
./script/probes/power-sweep.sh                      # sleep/pmset (section C needs root)
```

`accessibility-effective.swift` reports what macOS *actually* honours, not what
the plist says. That distinction is the whole point: on 26.6, writing
`com.apple.Accessibility` changes the plist and nothing else.

## The open question — `universalaccess-fda-test.sh`

**Run this from a terminal that holds Full Disk Access.** It's the one thing the
matrix can't settle on its own: whether `com.apple.universalaccess` writes work
when the invoking app has FDA.

```sh
./script/probes/universalaccess-fda-test.sh
```

It answers **two** questions, because they're not the same — `com.apple.Accessibility`
already demonstrated that a write can succeed and still change nothing:

1. does the write **succeed**?
2. does the value **take effect**?

Only "yes" to both makes nix-darwin's five `system.defaults.universalaccess.*`
options real on macOS 26. The script prints a verdict saying which doc lines to
update either way.

Safe by construction: snapshots the domain, restores on exit via a trap (even on
Ctrl-C), and refuses to run at all — before touching anything — from a terminal
without FDA, since that can only reproduce the original refusal.

To grant FDA: System Settings ▸ Privacy & Security ▸ Full Disk Access ▸ (+), add
the terminal, then fully quit and reopen it. On macOS 26 a *stale* grant often
has to be removed and re-added with (+) before it takes.

## `ncprefs-flags.sh` — where the notification switches really live

Settled on 26.6, 2026-08-01, by holding one app's switches in a known state and
diffing — not by trusting the flag tables in circulation, all of which point at
the wrong file now.

The per-app switches in System Settings ▸ Notifications live in
`group.com.apple.usernoted`'s container prefs. **`com.apple.ncprefs` is a stale
mirror**: it still has an `apps` array with plausible `flags`, and on this
machine it sat unchanged for two weeks while the real settings moved. `--legacy`
prints the drift (9 apps disagreed the day this was written, including the one
under test). Anything built on ncprefs reports confidently wrong state.

Three bits matter, all verified against the live UI:

| bit | mask | switch |
|---|---|---|
| 3 | `0x8` | **Desktop**, Temporary style — a banner |
| 4 | `0x10` | **Desktop**, Persistent style — an alert |
| 2 | `0x4` | **Play sound for notification** |

Bits 3 and 4 are one control in two styles, and this table said only bit 3
until 2026-08-04, which reports every Persistent app as quiet while macOS is
still drawing alerts for it. Corrected against live data: no app in a 108-app
store carries both bits, and unticking Desktop on a Persistent app clears bit
4 (Reminders, `9437708310` → `9437708358`, watched as the switch moved).
**Desktop is on when either bit is set.**

All three clear = silent, drawing nothing, still reaching Notification Center. That
is the end state to steer an app to when something else is rendering its
banners; turning *Allow notifications* off instead would stop the events
reaching the store at all.

The container is TCC-protected, so this needs **Full Disk Access** — and a
terminal that already holds FDA reads it without complaint while telling you
nothing about an un-granted process. `--tcc` makes that distinction explicit.
Any checker built on this has three verdicts, not two: noisy, quiet, and
*can't tell* — and "can't tell" must never render as "all clear".

macOS 26 also retired the old alert-style radio. There is no "Banners"
checkbox to uncheck any more: it's the **Desktop** checkbox plus an
Alert Style Temporary/Persistent pair.

## `accessibility-sweep.sh`

The follow-up to the settled question. `universalaccess-fda-test.sh` proved the
*mechanism* on one key; this fills in the rest of the family, including the two
that aren't typed by nix-darwin and are the point of the exercise:

- **`increaseContrast`** — the high-contrast lever
- **`FontSizeCategory`** — macOS 26's per-app text size ("larger text")

```sh
./script/probes/accessibility-sweep.sh   # from an FDA terminal
```

It separates keys with an `NSWorkspace` oracle (definitive: writes *and* takes
effect) from keys with none (persistence only — it pauses ~10s so you can look).
That split is deliberate: "the write succeeded" was never sufficient evidence
here, since `com.apple.Accessibility` writes succeed and change nothing.

## `sound-sweep.sh` · `locale-sweep.sh` · `power-sweep.sh` — §5.6's last three groups

Added 2026-08-08 to settle the three curated-settings groups the roadmap had
deferred *because nothing had been spiked*. Full results in
haus's [`docs/macos-settings.md`](https://github.com/hausfold/haus/blob/main/docs/macos-settings.md);
the short version is that all three are reachable and the stated reason for
deferring each one was wrong — Sound, Locale and Power have 2, 4 and 6 typed
options respectively.

```sh
./script/probes/sound-sweep.sh              # add --audible to hear the beep rows
./script/probes/locale-sweep.sh
./script/probes/power-sweep.sh              # A/B/D read-only
POWER_SWEEP_WRITE=1 ./script/probes/power-sweep.sh   # + the root write test
```

Three findings this shelf's own rules predicted and one it didn't:

- **`com.apple.sound.beep.volume` is `e^(slider − 1)`, not a fraction.** `0.5`
  is 31% and anything ≤ `e⁻¹` is silence. Oracle: `osascript -e 'get volume
  settings'`, which reads CoreAudio rather than the plist. The same key is
  written back by the volume keys, so it is a two-writers leaf.
- **`AppleMeasurementUnits` — typed, friendly, inert.** Of the four typed region
  keys, the one with the nice `Inches`/`Centimeters` enum is the only one that
  moves nothing; `AppleMetricUnits` is load-bearing. The "second key that makes
  the first a lie", with the roles reversed.
- **`AppleFirstWeekday` lands and lies** — the second dict-valued key here to do
  so after `FontSizeCategory`. Structured keys in Apple's global domain are
  GUI-only until one proves otherwise.
- **A bad `com.apple.sound.beep.sound` path is silence, not a fallback** —
  settled by ear (control ✅, Submarine ✅, `/nope/does-not-exist.aiff` ❌). A
  curated alert-sound option has to validate its path, or take an enum over
  `/System/Library/Sounds`. `--audible` asks per row now, because batching the
  question at the end produced "I heard one beep" — true and unattributable.
  **When the oracle is a human, record per row.**
- **The one nobody predicted: the missing piece is a *notification*.** A
  `defaults write` reaches new processes only; a running app never notices, not
  even through `Locale.autoupdatingCurrent`. Posting
  `AppleDatePreferencesChangedNotification` right after the write flips it
  within one sample, and a made-up notification name does nothing — so it is
  name-specific, not a cache poke. `restart-map.nix` can say `killall` and
  `logout`; this family needs a third verb.

`locale-effective.swift` is the oracle (resolved locale, languages, measurement
system, temperature unit, ICU hour skeleton, first weekday, current + enabled
input sources), and `--watch N` is what makes the running-app question visible.
`tis-toggle.swift` enables/disables ONE keyboard layout through the documented
`TISEnableInputSource` — used both as a control and as the way to learn what
macOS writes, since `AppleEnabledInputSources` resolves layouts by
`KeyboardLayout Name` while never validating the `KeyboardLayout ID` beside it.

Power's write test needs root — a Touch ID prompt here — so section C is opt-in
behind `POWER_SWEEP_WRITE=1` (an env gate, not a `sudo -n` check, so a warm sudo
timestamp can't make it run unattended). **It is also the probe on this shelf
that has been wrong the most times, and its shape is the lesson.**

Run 1: `sudo systemsetup -setcomputersleep 17` exits 0, prints
`setcomputersleep: 17` like a confirmation, logs an internal `-99` on stderr,
and moves `System Sleep Timer` on neither source — while nix-darwin discards
all three streams. Conclusion drawn: nix-darwin ships six silent no-ops.

Run 2, with a `pmset` control added: pmset didn't move it either. So the
*setting* is pinned on this Mac and run 1 was never evidence about
`systemsetup`. **A failed write says nothing about the writer until a second
writer has failed the same way and a second setting has succeeded** — the
negative-result twin of this shelf's "the write succeeded ≠ it took effect".

Run 3, the full 2×2 (setting × caller): four timer writes failed and `pmset -a
lowpowermode 1` **landed**, same shell, same root, same run — except the four
failures were read from the plist file and the one success from `pmset -g
custom`. **Two oracles, opposite verdicts.**

Run 4, reading `pmset -g custom` throughout: **every write had been landing all
along.** The plist is a file `powerd` flushes on its own cadence, and the probe
caught it mid-lag on the way out — `computer AC=18(file:1)`.

**Four runs, three wrong conclusions, none of them a macOS surprise.** The rule
this shelf takes from it: *where a domain exposes two readable states, decide
which one is the oracle before running anything* — and a table whose rows are
judged by different readers is not a cross, it's two experiments sharing a
heading. `timer()` reads `pmset -g custom`; the plist is a cross-check column
that flags a split as `10(file:21)`.

The finding that survived all four: **`systemsetup` writes ONE power profile.**
Asked for computer sleep 17 while the machine was on battery, it set AC. So
nix-darwin's `power.sleep.*` configures a source the config never named, and
`pmset -b`/`-c` is the only honest way to build the group.

## `pack-priority.nix` — the first probe that isn't about macOS

Evidence for the option surface's composition limit rather than for the
matrix: what a shared **pack** must ship so a consumer's own host
wins, rather than colliding with it.

```sh
nix-instantiate --eval --strict --json script/probes/pack-priority.nix
nix-instantiate --eval --strict --json script/probes/pack-priority.nix \
  --arg haus ~/code/workshop/haus      # from a workshop worktree
```

No machine, no darwin system, no build — it evaluates haus's pure-lib option
surface with the real `packs/writing.nix` and a fake host, in seconds. It is
here because it belongs to the same family as the rest: **the obvious answer is
the one that fails silently.** `mkDefault` on the whole `roster` attrset looks
like the cheap version and drops three of the pack's four apps without an error;
only per-leaf priority does what the roadmap wanted. Six compositions, verdicts
in the file header.

## `preset-composition.nix` — the other half of the same question

What happens when two whole **desktops** meet, rather than a pack and a host.
`lib.pack` fixed host-vs-pack; this measures the case the roadmap left open and
the one a gallery produces.

```sh
nix-instantiate --eval --strict --json script/probes/preset-composition.nix \
  --arg haus ~/code/workshop/haus
```

All six pairs of the four shipped presets, both escape hatches, and two candidate
seams. Same family lesson as the rest of this shelf, twice: **the assumption
nobody ran was wrong** (overlap isn't collision, and the conflict error names
both files), and **the quiet outcome is the dangerous one** — two desktops' list
options merge with no error at all, so a pair that "composes" may just be one
that blends.

✅ **The pinnable subset of this moves into haus** as `nix flake check`'s
`preset-composition` (haus#239, merged 2026-08-06), so the pairs the
docs advertise as stackable can't quietly stop stacking. The probe stays for the questions a golden table
can't ask — it prints resolved values and the `compose []` ordering experiment,
which is what you want the first time, not the hundredth.

## `scale-reach.nix` — what `ui.scale` reaches, and where it stops

The third non-macOS probe, and the one that needs a Mac anyway: it evaluates four
whole darwin systems rather than the pure-lib option surface. **Rerun it on a
macOS bump too** — two of its rows are nix-darwin defaults (`dock.tilesize`,
`NSTableViewDefaultSizeMode`), which is exactly the kind of thing a release moves.

```sh
nix-instantiate --eval --strict --json script/probes/scale-reach.nix \
  --arg haus ~/code/workshop/haus
```

Evidence for two claims about `haus.ui.scale` that nobody had measured — that every point-valued option is silently coupled to
`haus.displays`, and the "honest scope" paragraph naming what `ui.scale`
does and doesn't move. Both turned out to be one measurement apart:

- **the point-valued surface is ONE option** (`fonts.mono.size`). Six numeric
  leaves in the 130 the options page renders (plus four internal mirrors it
  doesn't), and the rest are multipliers, ids, an ordering and a percent —
  every other point-valued number in haus is internal to a module;
- **that one can't clip while prowl tiles it** — floating windows and
  `prowl.enable = false` are the precondition, and it's read off the code. The
  coupling only bites something that *sizes itself* in points, which is pounce
  (clamped), perch (proportional to the screen, and blind to `ui.scale`) and the
  bar (bounded by a band that is itself in points);
- **the reach table needs a third verdict.** Two surfaces change and then STOP,
  and a ceiling reads as `PARTIAL` under `accent-reach`'s vocabulary while being
  the deliberate answer.

✅ The pinnable subset shipped the same day as haus's `scale-reach` check —
four scales, `moves` / `ceiling` / `pinned`, darwin-guarded beside `accent-reach`.
This file keeps the census and the resolved values.

## `namespace-collision.nix` — who owns `haus.<name>`

```sh
nix-instantiate --eval --strict --json script/probes/namespace-collision.nix
nix-instantiate --eval --strict --json script/probes/namespace-collision.nix \
  --arg haus ~/code/workshop/haus
```

Evidence for desktop acquisition's namespace arbitration. It measures three things the note had been
asserting: what the module system does when two rooms claim one namespace, what
haus's real desktop validator says to a desktop naming a stranger's room, and
whether a fifteen-line consumer-side claim check can see any of it.

- **the loud collision is the lucky one.** Two fully-described declarations of
  one leaf throw, naming two store paths and no publisher; one *bare*
  `mkOption`, or two rooms owning different leaves under the same namespace,
  **merge silently** — and the second of those is what two independently written
  rooms actually look like. One room ends up steering the other's switch with
  nothing on the machine saying so;
- **`_file` cannot name a publisher**, because an input's origin is gone by the
  time it's a file in the store. Only `flake.lock` still knows, which is what
  puts the naming job in `haus add` rather than in the module system;
- **the desktop half needs no new machinery.** `modules/lib/desktop.nix` is
  already parameterised on `registry`, so a room shipping its own registry
  fragment is a merge at the call site. A fragment may reuse one of haus's
  thirteen `hostOnlyReasons` keys and inherit its sentence, or name its own and
  get the generic fallback — the default written for consumers pinned to an
  older registry turns out to be the extension point.

Also the first probe here to have RUN in a cloud container, which is a finding of
its own: `github:` inputs 403 there, but the git proxy serves anonymous reads,
so nixpkgs' pure `lib/` is one sparse clone away. The header says how.

## `source-shapes.sh` — what a stranger's desktop costs to fetch, and to read

```sh
./script/probes/source-shapes.sh                                     # local fixtures, no network
PROBE_REMOTE=git+https://github.com/hausfold/workshop \
  ./script/probes/source-shapes.sh                                   # + one real remote lock node
```

Evidence for desktop acquisition, step B. Step A shipped a sandbox for reading a **local** desktop file; step B
fetches one instead, and this measures what changes when the file arrives in the
store rather than in `~/Downloads`. Twenty-four rows (twenty-six with
`PROBE_REMOTE`), seconds, no Mac — it builds throwaway git repos under one
`mktemp` dir and runs real `nix eval` and `nix flake lock` against them.

The shelf's usual lesson, in its usual place — the quiet outcome is the
dangerous one:

- **the guard cannot fetch, and that is the design.** `builtins.fetchTree` under
  `allowed-uris = ""` is refused by URI, so `show` is two acts: fetch unguarded
  (no publisher code runs during a `git clone`), then read guarded. Neither can
  do the other's job, which is a cleaner trust story than one act doing both;
- **`restrict-eval`'s unit is the store path, not the file.** Naming one file
  allows exactly it *outside* the store and its whole store **root** inside, so
  a fetched repo's desktop can read everything its publisher shipped beside it.
  It still cannot reach another store path or anything outside the store — the
  half that was load-bearing holds, and the half the note had been describing
  does not;
- **the lock has never recorded a fetch date.** `lastModified` is the source's
  own commit date — matched exactly against the fixture, and measurably older
  than the fetch on the remote node. The raw-URL shape's whole node is `narHash`,
  `type`, `url`, so it carries no date on either reading;
- **and the update line for that shape reads like a no-op**: an arrow with the
  *same URL on both ends*, no rev and no date, printed while the content changed
  underneath — while a genuine no-op prints no line at all. This row said "no
  left-hand side" until 2026-08-20, because it grepped the arrow line out of a
  three-line block and reported the half it had not asked for as missing;
  **a probe that greps one line out of a multi-line block measures the grep**,
  and this one wrote its grep into the note twice over. It now reads the
  whole block, and pins the contrast: a `git` node's two ends differ;
- **"fetching runs no publisher code" is a property of `flake = false`, not of
  fetching.** A desktop locks inert; a *room* is an ordinary flake input, and
  locking one evaluates its `flake.nix` to find its own inputs — measured with a
  room whose `inputs` attrset throws. So pinning a room already runs its code,
  and step F's code prompt is owed before the lock, not before the rebuild.

⚠️ It measures **Nix, not haus** — `share/haus/desktop-check` isn't reachable
from the workshop, so these are claims about the mechanism `haus show` stands on.
Rerun on a Nix bump: the granularity rows are evaluator behaviour, which is
exactly what a release moves. It is the second probe here to have run in a cloud
container, and it needed no sparse clone — only `git+https://` and local repos,
which is the fetch path `namespace-collision.nix`'s header discovered. It also
runs green on macOS now: `mktemp -d` there returns a `/var/folders/…` path
through the `/var → /private/var` symlink, Nix reports a `-I` entry spelled that
way as "does not exist", and the guard's *outside-the-store* rows then failed
**closed** — which only one row is shaped to notice, since the rest expect a
refusal and got one for the wrong reason. (The `in store:` rows allow a
`/nix/store` path, which no `/var` symlink touches, so they were never at
risk.) The lab dir is resolved with `pwd -P` before anything is written into it.


## `machine-diff.sh` — what a consumer's own option tree can be asked

```sh
./script/probes/machine-diff.sh                                      # rows 1-7, on synthetic modules
PROBE_CONSUMER=~/.config/nix PROBE_HOST=mbp \
  ./script/probes/machine-diff.sh                                    # + rows 5 and 8 on a real machine
```

Evidence for desktop acquisition, step C. A and B read the stranger's **file**; C is the first step that has to
look at the **reader's machine**, so the question is whether the module system
answers a leaf-by-leaf question cheaply, honestly and without writing anything.
Eight rows. `lib` comes from `$PROBE_LIB` or from the copy every haus machine
already ships beside the desktop checker. Row 5 is measured both ways — on a
synthetic container by default, and against a real machine's own
`haus.roster.<app>.key` when a consumer is given; row 8 needs the real consumer
and skips loudly without one, including when the consumer is there and its
evaluation fails, which is the case a swallowed `2>/dev/null` would otherwise
have rendered as three confident rows measuring nothing.

- **`highestPrio` is the arbitration, and it is exposed.** One number per option
  — 100 a plain definition, 900 the desktop seam, 1000 a room's `mkDefault`,
  1500 the declared default — so "will this desktop's value actually land here?"
  is read off the module system rather than modelled by a command that would
  then have to be kept in step with it;
- **a list at a higher priority is replaced, not concatenated.** Lists merge
  only among definitions at the *same* priority. A host naming a list the
  desktop also names drops every one of the desktop's entries, with no error and
  nothing in the merged value to show it happened;
- **losing definitions are invisible.** `definitionsWithLocations` and `files`
  carry only the winners, so what a leaf would revert to when a desktop *stops*
  setting it cannot be read out of the current tree at all — the half of a
  swap diff that nothing on the machine can answer;
- **`files` at priority 1500 names the declaration, not a definition.** Read as
  "who set this", it accuses a module of setting an option nobody set;
- **a dynamic `attrsOf` sub-path has no option node.** `haus.roster.slack.key`
  is unreachable under `options` — measured on synthetic modules, and again
  against a real machine that has exactly that key — so everything under a recursive container can be compared
  by value and never by priority;
- **`nix eval` on a consumer flake writes its lock** when the lock needs changes.
  `--no-write-lock-file` computes one in memory and answers; `--no-update-lock-file`
  refuses. A command that promises to write nothing has to pick one on purpose;
- **`--apply` may not `import` an absolute path in pure mode**, so the query is
  an inlined string — which makes every option path taken out of a stranger's
  desktop an injection surface in the reader's own evaluation;
- **under lazy trees a store path out of an evaluation is a name, not a
  location.** Three evaluations of one pinned input give three different
  `…-source` paths and none of the three is on disk, while `builtins.readFile`
  on one works *inside* the evaluation that produced it. Every diagnostic that
  prints such a path — the module system's duplicate-declaration throw, haus's
  own unclaimed-namespace warning — is telling a person to look somewhere they
  cannot go, twice by two different names.

⚠️ Rows 1–8 are the **module system and Nix**, not haus. Rerun on a Nix or
nixpkgs bump; the lazy-trees row in particular is a property of Determinate
Nix's defaults rather than of every Nix. One trap it hit while being written is
worth keeping: `lib.getAttrFromPath` **`abort`s** on a missing attribute, and
`abort` is not something `tryEval` catches — so the probe for "this attribute is
absent" died of the absence it was measuring, and walks the tree by hand instead.


## `ci-cache-value.sh` — what a CI job costs, and what the store cache holds

```sh
./script/probes/ci-cache-value.sh                    # haus, nebelung, scruff, snug
./script/probes/ci-cache-value.sh snug               # one repo
RUNS=20 ./script/probes/ci-cache-value.sh haus       # a wider sample
BRANCH=worktree-x ./script/probes/ci-cache-value.sh nebelung
RUN=34948718808 ./script/probes/ci-cache-value.sh pounce   # one named run, one repo
```

Evidence for [`docs/ci.md`](../../docs/ci.md)'s *The Nix store cache*, which put
`cache-nix-action` on haus and nebelung and left two questions to measurement:
whether scruff's and snug's `nix` jobs earn one too, and whether the store
creeps toward GitHub's 10 GB per-repo ceiling. Three sections per repo, all out
of the GitHub API and none of it guessed: job wall clock over the last N runs,
the step breakdown of one run's nix jobs — **every** one of them — with each
nix step split again into evaluate / substitute / build, because a restore
replaces the substitute row outright and the build row only where the change
left the inputs alone; and the cache entries the repo is holding with their
real sizes.

Every matching job, not the busiest one: several nix jobs in a run is the normal
case, not the exotic one. haus's gate has three, two of them holding a store
entry, and an A/B probe's arms are sibling jobs of a single run, which is the
whole reason they are paired. The uncached third is exactly the job a
busiest-wins rule hides, and it is the one whose verdict gets re-opened.
`RUN=<id>` points section 2 at a named run when the newest on the branch is not
the one you mean — the branch still governs sections 1 and 3, and a run belongs
to one repo, so `RUN=` takes exactly one repo and refuses a list.

Measured 2026-09-12, the day the cache first saved:

- **The instrument the jobs carried read the wrong number.** `du -sh /nix/store`
  printed 2.8 G for haus and 4.9 G for nebelung; the entries that count against
  the 10 GB ceiling are **472 MiB** and **1.2 GiB**. The action's own `Current
  store size in bytes` (nar totals, 1.59 GiB and 4.16 GiB) sits between the
  two. About six times of headroom was reading as pressure, so the `du` steps
  went and the doc points at `gh cache list` instead;
- **a restore is not free, and the test is the ratio.** haus's 472 MiB entry
  comes back in **35s**, and takes `nix eval` from 55s to 9s and `nix flake
  check` from 37s to 1s. Nothing about "this job builds something" predicts
  that;
- **scruff: no.** Its `nix` job is 28s (8s installer, 13s `vendorHash`) beside a
  138s macOS test job in the same run. Even a free restore takes nothing off
  that gate;
- **snug: no, and it looked like the closer call.** Its `nix` job is 41s and
  *is* the longest in its run; 9s of that is the installer and the rest is one
  `nix build` step that fetches 216 MiB from `cache.nixos.org` and then builds
  the two derivations the source change just invalidated. How those seconds
  divide inside the step is the 2026-09-13 measurement below, and it is what
  settles the verdict;
- **the store creeps, and faster than it looks.** `purge` holds each repo to
  one store entry per ref — sweeping after the save, not before — so what grows
  is that single entry: haus's first six saves went 472, 507, 514, 546, 576,
  614 MiB, because a restore unions and nothing collects. About 24 MiB a save,
  on a key that moves with nearly every push to main, of which haus took 13 a
  day over the preceding week — 10 GB is weeks out, not years, which is what
  put an ISO week and the nixpkgs rev into haus's cache prefix. The drip is
  family revs (`flake.lock` alone moved 445 times in the preceding 90 days,
  though its nixpkgs rev not once) and the step change would be a nixpkgs bump
  unioning a second stdenv onto the first. nebelung, whose lock did not move at
  all in those 90 days, is not in the same position;
- **the family runs two Nix installers 8s apart, on Linux.**
  `nix-quick-install-action` lands in about a second on haus and nebelung;
  `DeterminateSystems/nix-installer-action` takes 8-9s on scruff and snug.
  Neither figure travels to a macOS runner — see *The two macOS poles* below,
  where the same Determinate action is 65s.

Measured again 2026-09-12, after haus split its nix half into three jobs with a
cache key each:

- **an entry can carry what no job in it reads, and one run cannot show it.**
  Each of the three jobs ran its real steps from an empty store, then again
  restoring the live entry and reading nothing. Cold against warm, as nar:
  `eval` 1100/1877 MiB, `checks` 1126/1826, `acquire` 685/1876 — **38-64% of
  every restore never opened**. Diffing the three cold path lists splits that
  in two: most is the work of the single job the three were split out of,
  inherited through a transitional key prefix and cleared for good by one
  lineage reset; about 496 MiB of `acquire`'s is in no job's cold store at all
  — the same `-source` unpacked at a dozen revs plus 175 `.drv`s, which is the
  ~24 MiB a save creep above, and it comes straight back;
- **a restore scales with the entry, and a cached job can be slower than an
  uncached one.** nebelung's 332 MiB entry comes back in 17s and haus's
  600-odd MiB ones in 34-48s — about 0.05-0.06s per compressed MiB, slightly
  worse as the entry grows. haus's `acquire` was at that point **faster with no
  cache at all**, 44s cold against 54s at its warm best: the 233 MiB it needs
  from `cache.nixos.org` costs less than the 637 MiB it holds from GitHub.
  Entries then: haus 637 / 597 / 637 MiB, nebelung 332 MiB, 1.9 GB and 0.3 GB
  of the 10 GB;
- **a cold figure belongs to the job it was measured in.** `nix flake check`
  was 37s cold behind a `nix eval` that had already paid for nixpkgs; as the
  first step in a job of its own it is 57s. `nix eval`, first either way, is
  55s in both. Nothing about the step changed.

Measured 2026-09-13, on the shell half those nix jobs drop under — ten PR runs
of haus's `check` for job totals through the jobs API, then the per-line
timestamps of run 34741464030's own job logs for everything below job level:

- **the shell half's pole has ~5s in it, and no fifth job can take more.**
  `agents` 58s (min 53, max 63), `rooms` 53s (44-59), `draw` 53s (50-58), `lint`
  23s (18-27). Splitting the pole is worth the distance to the runner-up and
  stops there, so `agents` cut anywhere leaves `rooms` at 52.8s as the gate. The
  gap, not the pole, is the number;
- **a Linux job's fixed cost is ~10s, not the ~4s of its tool install.**
  Checkout 1.7s and `npm install -g bats` 2.7s are the 4s `docs/ci.md` quotes;
  the rest is ~2s from `created_at` to `started_at`, ~1s before the first step
  runs, 0.6s of `Set up job` and ~2s from the last step to the job closing;
- **`agents` has no separable chunk, but it is not flat either** — and the
  second half of that sentence corrects a first draft of this entry. 238 tests,
  median 0.087s, mean 0.190s: 19 tests at or over a second carry 21.7s, just
  under half the job's 45.2s of test time, and the other 219 carry 23.5s
  between them. The tail is deliberate (clock assertions in `vm-runtime.bats`
  and `github-signal.bats`), it is spread across three suites, and taking all
  of it would still leave `rooms` as the gate. "No hot spot" is a claim about
  the SUITES — the largest is 14.5s of a ~50s job — never about the tests;
- **a step can be a clock rather than a cost, and a job total cannot show it.**
  `draw`'s `rebuild fix CTA` step reports all 38 of its tests ok at 10.3s and
  then closes at 32.3s, because `test/rebuild-fix-cta.bats:268` stubs `trill` as
  a `sleep 30` whose holder outlives the test by design. What it held open was
  not that stub's stdout — `fault_hold` detaches with 0/1/2 on `/dev/null` — but
  bats' fd 3, a dup of the RUNNER's stdout that every process in the detached
  tree inherits. The signature is 32s ± 1s across all ten runs while the work
  inside it varies. It changes no decision here — `rooms` is what `agents` is
  measured against either way. ⚠️ The cause is fixed — `exec 3>&-` at the top of
  that suite's `haus_sh`, the one process above the whole detached tree — so the
  32.3s above is a record of this sample and not a live cost. Re-measuring
  `draw` wants its own ten runs, never a number lifted from the run that fixed
  it.

Measured 2026-09-13, splitting snug's `nix build` at its own log's phase
boundaries — 11 runs, 8 on `main` and 3 on PR branches, the split stable across
all of them:

- **snug: no, by 13s at best and ~29s typically, and the closeness was an
  artifact.** The step divides into 6.5-14.2s evaluating nixpkgs, **2.3-3.5s**
  substituting the 69 paths it needs (215.7 MiB at 60-95 MiB/s), and 12-15s
  building the two derivations — ~6s of `go build`, ~7s of `go test`. Both take
  the source as an input, so a source change invalidates both every run and the
  build row is worth nothing to a restore — the difference from haus, whose
  checks mostly survive a PR. What is restorable is that 215.7 MiB plus the 46.7
  MiB nixpkgs `-source` the eval pulls, which is **262 MiB of download, 3-4s of
  a 41s job**. The entry that would replace it is ~280 MiB — 719.6 MiB of
  fetched paths unpacked plus the source's 202.8 MiB `NarSize` is ~922 MiB of
  nar, at the 0.30 nar-to-entry ratio both cached repos show — which is below
  where the flat-restore fit reaches, so the honest comparison is the measured
  pair around it: 17s at nebelung's cheapest, 32.4s on haus. **17 − 3.5 = 13.5s
  the wrong way on the best case, ~29s on the typical one**;
- **the 12s was never the fetch.** It is `go build` plus `go test`, read off a
  step named `nix build`. What generalises is that job length predicts nothing
  about the restorable part — not that only downloads are restorable, which
  would refuse haus its cache, whose whole case is the build row;
- **scruff's `13s vendorHash` was the same misreading, and its verdict still
  holds.** That step splits 8.6-11.2s evaluating, 2.1-2.7s substituting the
  same 216 MiB and ~1s building. Nothing there is worth a restore either, and
  the job sits beside a two-minute macOS test job regardless;
- **the lever on snug's gate is not a cache.** `nix-quick-install-action` lands
  in about a second on haus and nebelung where
  `DeterminateSystems/nix-installer-action` takes 7-9s here — bigger than
  anything a cache offers. ✅ Taken: snug#20 and scruff#130 swapped both on
  2026-09-15, snug's job to ~34s and scruff's to ~16s on the first post-swap run
  of each;
- **the probe prints the split now**, so the next verdict starts from it:
  section 2 splits every nix step at the markers nix writes into the log, and
  says which rows a restore replaces. It is still one run — the newest, or
  `RUN=<id>` — like the step list it sits under, and `RUNS=` does not reach
  section 2: the eleven-run stability above was eleven logs by hand. Checked
  against all four repos and against fixtures for the shapes they do not
  cover: a warm store reads
  `nothing fetched`, a step that neither fetched nor built says it has nothing
  to split, `gh`'s two log shapes (a real step name in field 2, or `UNKNOWN
  STEP`) both close the last step at the post phase rather than swallowing it,
  and a build before the fetch plan is attributed to the invocation it belongs
  to.

haus's answer was still to leave the workflow alone — past the reset its nix
jobs drop under the same repo's shell jobs, so the seconds a narrower store
could give back belong to a job nothing there would touch. The method, and why
a narrower store is not the lever it looks like, is *The Nix store cache* in
`docs/ci.md`.

Measured 2026-09-13, reconstructing haus's W37 lineages from the run history —
every saving run logs the entry it uploaded, so the chain of saves rebuilds
exactly, purged entries and all. ⚠️ W37 holds three lineages, not one: the
cache landed mid-morning on 2026-09-12 and saved 472.1 → 687.6 over six, the
lineage prefix landing an hour later reset that to 471.9 and ran to 577.0, and
the three-way split an hour after THAT started the three this section is
about. "W37 ran 67 saves" below is the week; the slope is the third lineage:

- **the three entries came back at their own key, and at the old job's size.**
  Every restore since the split logs a key under its own job token, so nothing
  is reading another job's entry. All three were nonetheless born at the one
  pre-split entry's 577.0 MiB and saved 606.6 / 586.7 / 607.0 off it, exactly
  as the workflow's banner predicted: the store is saved whole, so the split
  becomes three sizes only at the next lineage reset;
- **the creep is per SAVE, linear, and steeper than 24 MiB.** Eleven saves
  over the 19 hours from 2026-09-12T10:44 — the first of them the split's own,
  so ten intervals — compressed: `eval` 606.6 → 915 (+30.8 a
  save), `checks` 586.7 → 721 (+13.4), `acquire` 607.0 → 909 (+30.2) — 74.4 MiB
  per push that saves, to ±1 MiB and with no saturation. The single pre-split
  entry over the same reconstruction reads 472.1 → 687.6 in six, ~36 MiB a
  save, so the 24 MiB above was low and the split doubled the slope rather than
  tripling it — `checks` creeps at under half what the other two do;
- ⚠️ **the unit is the save, not the day.** A push that leaves `flake.lock` and
  every `*.nix` untouched hits the primary key and saves nothing: 793 of
  haus's last 1048 main pushes touched one — 76%, steady across seven weeks.
  Reading
  the creep per day is what made it look like 80-250 MiB an entry;
- **the weekly reset no longer bounds it, and W37 is what makes it look like
  it does.** A cold store of this shape compresses at ~3.4:1 — haus's very
  first save put 1623.0 MiB of nar out as a 472.1 MiB entry — so a lineage
  starts near 847 MiB across the three and, with the 45 MiB nix-installer
  entry that counts against the same ceiling, clears 10 GiB at 126 saves. haus's
  last five full weeks ran 145, 106, 128, 126 and 116 saves: the median lands
  on the line and three of the five go over, a W32-shaped week ending near
  11.4 GB. W37, the week this slope was reconstructed in, is the quiet outlier
  at 67, which is why the live entries read as comfortable. The cold start is
  the only projected term and it does not decide anything — at 974 MiB the
  median week is 10.2 GB, at 600 it is 9.8. A half-week token (ISO week plus a
  first/second half, resetting Monday and Thursday) puts even a W32-shaped
  lineage near 6.2 GB for one more cold run a week;
- ⚠️ **the restore does not scale with the entry, which retires the line
  above.** Over 63 haus restores spanning 472-885 MiB — the whole life of that
  cache, and a 1.9x range because the lineage prefix landing mid-morning on
  2026-09-12 reset one entry from 687.6 to 471.9 MiB — the download-and-extract
  phase is 32.4s flat: Pearson r = -0.075, entries under 520 MiB averaging
  33.5s against 32.3s for those over 800, and the step around it 34-50s with no
  trend. Path count and GitHub bound it, not bytes — which is why nebelung's
  332 MiB in 17s never extrapolated onto a store that is mostly `.drv`s. So a
  reset buys back store SIZE, not seconds, and the projection that it would
  take `acquire`'s restore to ~10s has nothing behind it. 472 MiB is as low as
  the evidence reaches and the post-reset entries land below it, so haus's
  first run of W38 is still the one to read for the slope;
- **`acquire` keeps no cache, decided 2026-09-13 on a clean A/B.** Changing the
  nixpkgs half of the lineage key built one PR run cold while a comment-only
  run minutes earlier on the same base restored the live entries — two PR runs,
  so neither paid a save. Cold against warm: `eval` 81s/71s (the cache buys
  10s), `checks` 75s/42s (buys 33s), `acquire` 45s/71s — 50s of restore in
  front of a 13s step, so it **cost 26s** every time it worked. The reset would
  not have rescued it: at the flat ~32s restore, a post-reset ~199 MiB entry
  still puts it near 48s against 45s cold. Its cache, lineage step and
  `actions: write` are gone, and haus's nix gate is `eval` alone. The same
  cold run turned the projections into measurements — `eval` 330.2 MiB against
  ~320 projected, `checks` 340.4 against ~328, `acquire` 202.3 against ~199,
  all within 4% — so "a cold job saves only what it built" holds, and the repo
  went from 3.1 GB of entries to 1.5.

⚠️ Section 1 is wall clock as GitHub recorded it, so a queued runner and a slow
mirror are in it — read the min, not the avg, for what the work costs. A job
GitHub records as finishing before it started — a skipped A/B arm does this —
reads `-1s` across the row, which is the API's number and not a measurement. Section 2
reads a single run, the newest or the one `RUN=<id>` names, because step names
move; inside that run it reports every job that runs nix. The cache figures
above are one measurement each, taken the morning the first entries were saved,
so rerun before trusting the creep line — that is what the probe is for.

## The two macOS poles, step by step

`docs/ci.md`'s *No third-party runner fleet* says most of the family's wall
clock goes into the Mac jobs. That was read off run totals; this is what is
under them. `pounce`'s pole runs nix, so the probe reaches it —
`script/probes/ci-cache-value.sh pounce`, whose section 2 works out for itself
which jobs run nix. `perch`'s runs no nix at all, so that section prints nothing
for it and the jobs and steps come straight out of the API:

```sh
runs=$(gh api 'repos/hausfold/perch/actions/runs?event=pull_request&status=completed&per_page=8' \
       --jq '.workflow_runs[].id')
for id in $runs; do
  gh api "repos/hausfold/perch/actions/runs/$id/jobs" --jq '
    .jobs[] | "\(((.completed_at|fromdate)-(.started_at|fromdate)))s\t\(.name)",
    (.steps[] | "  \(((.completed_at|fromdate)-(.started_at|fromdate)))s\t\(.name)")'
done
```

Measured 2026-09-13, the last eight completed `pull_request` runs of each.
pounce's pole ran on `macos-15`, perch's on `macos-26`; the installer figure
below belongs to a runner image as much as to an action:

- **the pole is one job in each repo, and it is never in doubt.** pounce's
  `nix build (aarch64-darwin)` ran 175-248s (215s mean) against a 35-49s Swift
  unit-test job and two Linux jobs at 6-15s and 3-6s; perch's `Native build and
  tests` ran 124-230s (182s mean) against a 52-119s iOS build and a 3-6s Linux
  job. Neither pole lost the title in any of the sixteen runs, so there is no
  rule 5 regrouping of the *other* jobs left to make in either repo;
- **less than half of pounce's pole is a compiler.** Step means: installer 65s,
  then inside the one `nix build` — 28s of flake resolution and input fetch, 3s
  substituting 37 paths (104.1 MiB download, 492.2 MiB unpacked), **102s of
  `buildPhase`**, 5s of the twenty small command derivations; 9s of checkout,
  set-up and post around all of it. The buildPhase figure is Nix's own
  (`buildPhase completed in …`) and ran 78-127s, the widest spread in either
  repo, which is the macOS runner rather than the source;
- **`DeterminateSystems/nix-installer-action` is 65s on a macOS runner**, not
  the 8-9s it takes on the Linux jobs above. Its own log itemises it: ~13s
  creating an encrypted APFS volume for `/nix`, ~7s creating 32 build users,
  **22.3s on "Configure Time Machine exclusions"** — 22.2-22.4s across all
  eight runs, so a fixed cost and not load — and ~20s for the daemon, the zsh
  hook, the launchctl plist and three shell self-tests. No input on the action
  turns the Time Machine step off. ⚠️ pounce's workflow comment said pounce
  needed *that* installer specifically, because Determinate relaxes the macOS
  build sandbox by default and the impure `xcrun` build requires it. **Both
  halves are wrong** — *quick-install on a Mac*, below, has the run that shows
  it — and the repo has since moved to quick-install;
- **perch compiles the same sources twice.** `Test` 99.5s mean = 70.4s building
  the Debug target graph + 21.1s of `xcodebuild` starting the test host
  (`IDETestOperationsObserverDebug: N elapsed`) + 6.1s of tests actually
  executing. `Analyze` is 7.9s because it reuses that Debug `DerivedData`;
  `Release build` is 50.9s and reuses none of it — its own `SwiftDriver`,
  `SwiftCompile`, `Ld` and `GenerateDSYMFile` for Perch, PerchCLI and
  PerchUpdater. 121s of the 182s is `swiftc`;
- **perch's pole has a needs boundary and pounce's does not.** `Test` and
  `Analyze` share one Debug `DerivedData`; `Release build` and the three bundle
  guards share the Release build. Splitting there computed to ~119s beside ~71s
  against today's 182s, with the 74s iOS job next in line — and that estimate
  has since been run both ways, which is *perch's split, run both ways* below.
  pounce's pole is one installer and one `nix build`: nothing to cut. `trill`'s
  gate is the same test + analyze + Release shape on the same kind of runner,
  and *trill's gate, step by step* below is its own eight-run read — the
  boundary was a claim about perch's jobs, not about the shape wherever it
  appears, and what carried to trill was the double compile and not the
  split.

**This narrows the macOS half of the question the sections above left open.**
No repo caches a store on a macOS runner, and pounce is the only one that
could. The substitution a warm entry would replace there is 104 MiB in ~3s, and
no restore beats 3s — that half is settled. ⚠️ But 3s is a floor, not a
ceiling: a locked flake input's source tree is a store path too, so an
unmeasured part of the 28s of flake resolution in front of it is restorable as
well, while nix's eval cache, which lives outside `/nix`, is not. And the 65s
installer would itself have to move, since `cache-nix-action` sits behind
`nix-quick-install-action` and nobody had measured that installer on a Mac —
*quick-install on a Mac*, below, is that measurement, and the installer moved on
its own rather than as a cache's passenger. The answer for pounce is still no;
what a restore *costs* on a macOS runner is the one part still open.

⚠️ The run spreads here are wall clock as GitHub recorded it, same as section 1.
The shares are stable — Time Machine is 22.3s ±0.1s across eight runs — but the
totals are not: perch's `Test` step ran 70s and 127s on two runs a day apart
with no relevant source change between them. Compare shares across a
re-measure, not absolute seconds.

## perch's split, run both ways

The section above ended on an estimate: cut perch's pole at its
`-derivedDataPath` and the arithmetic gives a ~119s job beside a ~71s one
against 182s. This is that estimate run. perch#150 made the split, and it was
then measured against the shape it replaced.

**Method, and it is the part worth copying.** Seven pairs, alternating a
pre-split ref with post-split `main`, `workflow_dispatch`, **one run at a time**
so no two samples ever contended for a macOS slot and both arms saw the same
runners. Fourteen runs, 2026-09-13, `macos-26`. The pre-split arm was the
parent commit pushed to a throwaway branch and deleted afterwards — a tag or a
branch is the only ref `gh workflow run` takes, so an arbitrary sha needs one
either way.

**Why not simply compare the arms.** The caveat directly above is worse than it
reads. Across these fourteen runs `Test` alone ran **59-147s** with no source
change — a 2.5× swing. The arm means are 164s pre against 141s post, and most
of that 23s is which half-hour a run landed in. So the figure below compares
**the two shapes inside each run**: for a pre-split run, what the split would
have given that same run (`max` of its own Debug half, Release half and iOS
job); for a post-split run, what one job would have cost it (its halves added).
Runner speed multiplies both sides and cancels.

- **the split takes a median 60s off the gate** — mean 58s, range 0-99s, n=14.
  Against a 182s pole that is a third of it, and it is the number the estimate
  was reaching for. ⚠️ **Read ~52s instead**, and the correction is in *trill's
  split, run both ways* below: the seven POST rows' *other shape* is computed
  off a Release job running **cold**, which overstates what one job would have
  cost each of them by the ~30s of front end this repo's Release build pays only
  when it is the first `xcodebuild` on its runner. The seven PRE rows are
  untouched — `max(dbg, rel, iOS)` was never the Release half, even with 30s
  added — so the verdict below stands exactly as written and only the median
  moves;
- **the gate is named at both ends, which is what rule 5 asks.** Before:
  `Native build and tests`, 7/7. After: `Debug tests and analyze`, 7/7 — it
  never once lost the title to the Release half or to the iOS build. The gap to
  whichever came second ran 1-94s, median 39s;
- **a third concurrent macOS job does not queue behind the other two.** Mean
  wait from created to started went **7.4s** across 14 macOS jobs pre-split to
  **6.4s** across 21 post-split, range 5-10s. This was the one thing that could
  have made the split a loss — `docs/ci.md` rule 3 is about exactly that slot —
  and on a public repo it did not happen. It is the half of the trade that
  belongs to the account rather than the workflow, so measure it again before
  copying the split to a repo with different concurrency;
- ⚠️ **once in seven it was worth nothing, and that is rule 5 rather than
  noise.** One pre-split run had the iOS companion at 119s against a Debug half
  of 71s: the companion was already the pole and the split would have bought
  that run zero. One post-split run closed to a **1s** gap between its two
  halves (Debug 121s, Release 120s) — the same fact from the other side. A
  split is worth the distance to the runner-up and not one second more, so
  there is no second cut to make inside perch's Debug half: whatever comes off
  it lands on the iOS build. It is not a once-in-seven curiosity of the
  dispatch sample either: the `pull_request` run of perch#151, the PR that
  wrote this result into that workflow, came in at Debug 84s, Release 89s and
  **iOS 94s** — a fast runner, both halves under the companion, and neither of
  them the gate.

Per run, seconds. *gate* is what that run actually took; *other shape* is the
counterfactual described above; *dbg* and *rel* are the two halves, measured
where the run was split and summed from its steps where it was not:

| arm | run | gate | other shape | dbg | rel | iOS |
| --- | --- | --- | --- | --- | --- | --- |
| PRE | 34743981707 | 201 | 146 | 146 | 64 | 99 |
| POST | 34744129692 | 154 | 225 | 154 | 88 | 84 |
| PRE | 34744266206 | 119 | 103 | 77 | 51 | 103 |
| POST | 34744356694 | 134 | 217 | 134 | 99 | 108 |
| PRE | 34744456404 | 162 | 112 | 112 | 62 | 106 |
| POST | 34744578340 | 132 | 169 | 132 | 50 | 53 |
| PRE | 34744680055 | 119 | 119 | 71 | 48 | 119 |
| POST | 34744773410 | 121 | 220 | 121 | 120 | 83 |
| PRE | 34744879439 | 183 | 128 | 128 | 67 | 70 |
| POST | 34745016209 | 122 | 191 | 122 | 83 | 87 |
| PRE | 34745118510 | 181 | 126 | 126 | 68 | 101 |
| POST | 34745253329 | 183 | 256 | 183 | 89 | 84 |
| PRE | 34745399260 | 185 | 120 | 120 | 75 | 112 |
| POST | 34747425518 | 142 | 226 | 142 | 103 | 85 |

⚠️ Both arms are `workflow_dispatch` runs, not `pull_request` ones, which is
what makes them serialisable one at a time. Nothing in the workflow branches on
the event, and the queue figures above are the reason to believe it did not
matter — but the eight-run `pull_request` baseline in the section above is a
different sample and the two should not be pooled.

Take it again the same way: alternate the refs, one run in flight at a time,
and read jobs and steps with the snippet in *The two macOS poles* above.

## quick-install on a Mac

`docs/ci.md` put `nix-community/cache-nix-action` on haus and nebelung behind
`nixbuild/nix-quick-install-action`, quoted that installer at about a second
against Determinate's eight or nine, and said in two places that the figure was
a Linux one and that nobody had measured quick-install on a Mac. pounce is where
that mattered: 65s of its 215s pole was `DeterminateSystems/nix-installer-action`,
22.3s of it configuring Time Machine exclusions on a runner with no Time
Machine. This is that measurement.

**It was blocked on a comment, and the comment was wrong.** `build.yml` said
Determinate was there because it "relaxes the macOS build sandbox by default,
which the impure xcrun build requires" — which, if true, would have made
quick-install unusable here unless it could be made to relax the same thing.
Neither half survives:

- **nix does not sandbox on macOS at all.** `sandbox` defaults to `true` on
  Linux and `false` on every other platform — the setting documents its own
  default — and *neither* installer writes a `sandbox` line: Determinate's
  `/etc/nix/nix.conf` has none, and quick-install's `~/.config/nix/nix.conf`
  has none. Both jobs report `sandbox = false` from `nix config show`. Nothing
  was ever relaxed, because nothing was ever tightened. ⚠️ Which is not the same
  as "quick-install does not sandbox": the same action and the same nix 2.34.7
  report `sandbox = true` on `ubuntu-latest`, single-user and with
  `build-users-group` empty, because the runner allows unprivileged user
  namespaces (snug run 34948548370). Two platforms, one default, and the
  installer is the variable in neither;
- **`relaxed` is the setting that would have broken it.** It exempts
  fixed-output and `__noChroot` derivations from the sandbox and nothing else,
  and `pkgs/pounce`'s derivation is neither. Passed through quick-install's
  `nix_conf`, the build died on `pounce> ./build.sh: line 121: /usr/bin/xcrun:
  Operation not permitted` — `builder failed with exit code 126`. `sandbox =
  true` died identically, which is the control that makes the sandbox the axis
  rather than a coincidence;
- **so the installer was free to be the cheap one**, and quick-install builds
  pounce unchanged — `/nix/store/3cflx1kvkbhkmk28fkz50d3frk5jgwfl-pounce-2026.09.13.drv`
  under both arms, the same derivation hash, green.

**Method.** One temporary workflow on a branch — the variants as sibling jobs of
the *same* run, so each row below is paired by construction: the arms saw the
same fleet at the same minute, with no need to serialise runs the way *perch's
split* above did. Eight runs, 2026-09-15, `macos-15`. A is
`DeterminateSystems/nix-installer-action@v23` with `determinate: true`, B is
`nixbuild/nix-quick-install-action@v35` bare, E is B plus `nix_conf: max-jobs =
auto`; C and D are the sandbox variants above and ran once. Every arm runs the
identical `nix build .#pounce .#pounce-commands .#pounce-skill
--print-build-logs`.

| run | A inst | B inst | A total | B total | A swiftc | B swiftc |
| --- | --- | --- | --- | --- | --- | --- |
| 34948718808 | 66 | 4 | 230 | 175 | 117 | 122 |
| 34949000900 | 71 | 5 | 240 | 163 | 113 | 116 |
| 34949004083 | 69 | 3 | 216 | 138 | 102 | 98 |
| 34949006329 | 61 | 13 | 185 | 206 | 84 | 139 |
| 34949008859 | 75 | 6 | 330 | 214 | 186 | 151 |
| 34949190990 | 68 | 3 | 238 | 198 | 122 | 138 |
| 34949192968 | 65 | 3 | 219 | 189 | 101 | 131 |
| 34949196558 | 71 | 4 | 216 | 183 | 101 | 135 |
| **mean** | **68.2** | **5.1** | **234** | **183** | **116** | **129** |

All seconds. `swiftc` is Nix's own `buildPhase completed in …`. Run 34948718808
is the one that also carried C and D; 34949190990 onward also carried E.

**What moved, and what only looks like it moved.**

- **the installer row, by 63s.** 68.2s mean against 5.1s, 61-75s against 3-13s,
  no overlap in eight paired runs. Where Determinate's 65s goes is itemised in
  *The two macOS poles* above; quick-install does none of it — no encrypted
  volume, no 32 build users, no daemon, no Time Machine step. It adds a plain
  APFS volume, turns Spotlight off on it, unpacks a nix tarball and registers
  the db, single-user and unprivileged;
- **the job total, by 51s.** 234s against 183s over the same eight runs. That
  is 13s less than the installer row gives back, and the missing 13s sit in the
  `swiftc` row, which reads *higher* under quick-install here: 98-151s against
  84-186s, ranges that overlap with Determinate holding the extreme.
  ⚠️ **Unattributed, and probably not real.** There is no mechanism for an
  installer to reach that row — the compiler is the runner image's Xcode CLT in
  both arms, reached through `xcrun` and never built — and the Determinate
  eight-run sample above put the same row at 78-127s, wider than either arm
  here. Read the installer row absolutely, because it is paired; read this one
  as the runner;
- ⚠️ **`max-jobs` is the one place bare quick-install is off parity**, and it is
  worth less than it looks. Upstream nix defaults `max-jobs` to 1 where
  Determinate's `nix.conf` writes `auto`, so under B the two small derivations
  queue behind the two-minute `swiftc` instead of beside it. That buys at most
  what those two derivations cost, which the Determinate table puts at **5s**,
  and this sample cannot see 5s: paired against B in the three runs carrying
  both, E came in at 160/170/188s against 198/189/183s — two wide wins, one
  reversal, a 17s mean gap that is three times what the mechanism can produce
  and is therefore mostly the runner again. **Left unset**, so pounce's step
  stays bare like haus's and nebelung's; it is one `nix_conf` line away if
  anyone wants to chase the 5s with a bigger sample.

**Take it again the same way.** Put the variants in one workflow as sibling jobs
so they stay paired, push it to a branch — `workflow_dispatch` will not fire for
a file that is not on the default branch — and read jobs, steps and phases with
`ci-cache-value.sh`'s instrument, which reports every nix job in a run and so
reads all the arms of one at once. The probe branch and its workflow are
deliberately not kept; the run ids in the table are the record, and section 2
still reaches them — `RUN=34948718808 BRANCH=worktree-quick-install-sandbox
./script/probes/ci-cache-value.sh pounce` replays the run that carried A, B, C
and D.

## trill's gate, step by step

*The two macOS poles, step by step* above left `trill` as the one macOS gate
nobody had read: the same `Test` → `Analyze` → `Release build` → bundle-guard
shape as perch's, on the same kind of runner, all through one
`-derivedDataPath DerivedData` (`.github/workflows/build.yml`). This is that
read, and it is a **record of the one-job shape** — trill#63 has since cut it
in two along that same `-derivedDataPath`, which is *trill's split, run both
ways* below. Same snippet as that section with the repo swapped, and for what
is inside a step, the job log:

```sh
gh api --allow-escape-sequences \
  repos/hausfold/trill/actions/jobs/<id>/logs
```

The flag is not optional — without it `gh` refuses the body rather than
printing it. Measured 2026-09-15, the last eight completed `pull_request` runs,
2026-09-05 to 2026-09-12, all green, all `macos-26`:

- **it was not a pole, it was the whole gate.** `build` had exactly one job.
  pounce's and perch's figures above are a longest job read against a
  runner-up; trill's `Native build and tests` had nothing to be longest
  against, so rule 5's gap was the entire 155s mean (109-229s across the eight)
  and there was no third job to floor what a split could return;
- **yes, it compiles the same sources twice, and there are 63 of them.** Target
  `Trill` is 63 `.swift` files — the directory is the membership, since the
  project carries it as a synchronised root group. The Debug build inside
  `Test` compiles them a task each, plus a 64th for the
  `GeneratedAssetSymbols.swift` the asset catalog derives: 97 `SwiftCompile` in
  all, those 64 plus `TrillTests`' 27 and the batch jobs around them, and four
  binaries linked — `Trill`, `Trill.debug.dylib`, `__preview.dylib` and
  `TrillTests.xctest`. `Release build` compiles the same 63 again as **one**
  whole-module `SwiftCompile`, against its own configuration's copy of that
  generated file, and links one, with its own `SwiftDriver`, `Ld` and
  `GenerateDSYMFile`. It inherits nothing: `Build/Products` and
  `Intermediates.noindex/Trill.build` are per configuration, and the 69
  framework-module PCMs are precompiled all over again — Debug's 71
  `SwiftExplicitDependencyGeneratePcm` are those 69
  plus two of the test target's own, and **not one** of Release's 69 reuses a
  Debug hash, because `DerivedData/ModuleCache.noindex` keys a PCM on the flags
  that asked for it and `-O` is not `-Onone`;
- **`Test` 79.0s mean = 11.8s before the first build task + 53.0s of Debug
  build + 11.7s of test + 2.5s printing results.** The 11.7s is `Touch
  …/Debug/Trill.app` to `** TEST SUCCEEDED **`, and xcodebuild's own
  `IDETestOperationsObserverDebug: N elapsed` puts 10.8s of it inside the test
  operation. **The tests themselves are 6.8s of that** — the sum of 452-491
  cases' own durations, six and a bit seconds of testing inside a 155s job;
- **`Analyze` is 6.4s because it runs no compiler at all.** No `SwiftCompile`,
  no PCM, no `Ld`, in all eight runs — it reads the Debug `DerivedData` the
  step before it left. That is a needs boundary in rule 5's sense: move
  `Analyze` off `Test` and it has to pay for a second Debug build to read;
- **`Release build` 52.8s mean = 2.6s lead-in + 4.1s re-precompiling 69 PCMs +
  38.0s inside one `SwiftCompile` + ~1.4s of `Ld` and dSYM**, the rest asset
  catalog, plist and validation. The whole-module compile alone ran 29.0-46.4s;
- **the first `xcodebuild` of the job paid a cold start the other two did
  not** — 11.8s before the first build task in `Test` against 2.6s in `Release
  build`, the difference being project and package state the first invocation
  leaves in `DerivedData`. It held in every one of the eight runs, 5.5-10.7s.
  ⚠️ **That ~9s is what one job can see, and it is not what a second job
  pays** — *trill's split, run both ways* below measures the real figure at
  ~22s, with `Release build` at 39.6s cold as the first `xcodebuild` on its own
  runner. Read the correction before reusing the 9s: an in-job delta is not a
  job's cost. `Show toolchain` (5.6s, Xcode's first launch in the job) and the
  checkout are paid twice either way;
- **the work is identical run to run and the clock is not.** 97 Debug
  `SwiftCompile`, 71 Debug PCMs, 1 Release `SwiftCompile`, 69 Release PCMs —
  the same counts in all eight runs, while `Test` ran 49s on one and 128s on
  another. The spread is the runner, exactly as *The two macOS poles, step by
  step*'s closing caveat says. Read the shares, not the seconds.

Per run, seconds, newest first. *dbg* is step start to `Touch
…/Debug/Trill.app`; *wmo* is the single Release `SwiftCompile`. Both come from
the log's own markers rather than from a step total:

| run | job | `Test` | dbg | `Analyze` | `Release build` | wmo |
| --- | --- | --- | --- | --- | --- | --- |
| 34685020390 | 173 | 82 | 67 | 6 | 67 | 45 |
| 34581346774 | 140 | 68 | 57 | 7 | 48 | 37 |
| 34470839275 | 131 | 67 | 55 | 6 | 45 | 32 |
| 34329287695 | 109 | 49 | 43 | 4 | 39 | 29 |
| 34118942332 | 143 | 76 | 63 | 6 | 47 | 35 |
| 34107163197 | 150 | 76 | 61 | 6 | 51 | 39 |
| 34106861216 | 168 | 86 | 72 | 6 | 55 | 42 |
| 33962533286 | 229 | 128 | 101 | 10 | 70 | 46 |
| **mean** | **155** | **79** | **65** | **6** | **53** | **38** |

The steps outside those three are `Set up job` 0.8s, checkout 2.0s, `Show
toolchain` 5.6s, the agent-skill check 0s every run, the no-instrumentation
guard 2.0s, and post-checkout plus `Complete job` 4.0s. They sum with the three
above to 152s against a 155s job mean, so ~3s of it is outside any step at all.

**What a split computes to, which is not what it would measure.** The boundary
is the one perch took: `Test` + `Analyze` on the Debug `DerivedData`, `Release
build` + the instrumentation guard on the Release one. Off these means that is
a ~101s job beside a ~79s one — the Release half now carrying the ~9s cold
start it used to inherit, and both halves paying checkout and `Show toolchain`
— against the 155s gate this sample measured. ⚠️ **That is arithmetic and
nothing had been run either way when it was written**, which is a bar on using
it to decide rather than a caveat to publish beside a decision. Two things
also stop perch's measured 60s from standing in for it: trill has no third
job, so after a split the runner-up is the Release half itself and the prize
is capped by that rather than by an iOS build; and what a second concurrent
macOS job costs this repo's account is unmeasured here — perch's 7.4s → 6.4s
queue figures are perch's sample. Settle it the way *perch's split, run both
ways* did: alternate a pre-split ref with `main` under `workflow_dispatch`,
one run in flight at a time, and compare the two shapes inside each run rather
than the two arms.

✅ Run, the section below. The Debug half came in at 97s against that ~101s;
the Release half at 94s against that ~79s, because the ~9s above is the part of
the cold start this job can see and not the whole of it.

## trill's split, run both ways

The estimate directly above, run. trill#63 made the cut and it was then measured
against the shape it replaced — the second time in the family a gate has been
split and both shapes then put on runners, and the first where the two halves
came out level.

**Method, unchanged from perch's on purpose.** Seven pairs, alternating `main`
with the split branch, `workflow_dispatch`, **one run at a time** so no two
samples contended for a macOS slot. Fourteen runs, 2026-09-15, `macos-26`. The
pre-split arm is `main` itself, which needed no throwaway branch: the split
lived on the PR branch, so both refs already existed and `gh workflow run` took
each by name.

- **the split takes a median 61s off the gate** — mean 55s, range 33-74s, n=14.
  The gate goes 151s mean / 153s median to **103s / 107s**, and the eight
  `pull_request` runs in the section above sat at 155s, which is the same job on
  a different sample and is not pooled with it;
- ⚠️ **the cold start is ~22s, not the ~9s the one-job read could see, and that
  is the correction this section exists for.** `Release build` is 53.6s mean
  sitting behind the Debug build and **77.1s** as the first `xcodebuild` on its
  own runner. Measured at the markers: everything before the compile phase runs
  11.2s warm and 39.6s cold (medians), 21.9s of that once each run's own compile
  phase is used to divide the runner's speed out. The compile phase itself does
  not move. The ~9s above is real and is the *lead-in* alone — what the first
  invocation leaves in `DerivedData` for the second — and it misses the rest:
  the early tasks between the build description and the first `SwiftDriver` run
  2.7s warm against 20.0s cold, and the 69 PCMs 2.3s against 4.7s. **"It
  inherits nothing" is true of build products and false of wall clock.** Nothing
  in `DerivedData` crosses the configurations, which is what that paragraph
  measured; what crosses is the runner's page cache, and a job boundary throws
  it away;
- **so the split MOVES that cost rather than removing it, and the arithmetic has
  to subtract it.** Doing perch's sums on the old job's step list, which is what
  the estimate above is, puts the saving at 67.5s. Subtracting the measured cold
  start puts it at 61s. Both say split; only one of them is the number;
- **the pole is shared, which is new.** `Debug tests and analyze` was the gate in
  **3** of 7 post-split runs and `Release build and bundle guard` in **4**, by a
  median 11s (1-53s). perch's Debug half held the title 7/7. trill has no iOS
  companion, so the runner-up after the cut is its own Release half — and at an
  11s median gap, rule 5's "worth the distance to the runner-up and not one
  second more" says there is **no second cut to make here**: whatever comes off
  either half lands on the other. It is not an artifact of the dispatch sample:
  the `pull_request` run of trill#63 itself, the PR that made the cut, came in at
  Debug **61s** and Release **105s** — a fast Debug half, and the Release half
  the gate by 44s;
- **the second concurrent macOS job did not queue behind the first.** 8s median
  from created to started in both arms — the figure that had to be taken for
  this repo's account rather than inherited from perch's, since this is 1 macOS
  job going to 2 where perch's was 2 going to 3. One pair waited 287s and 337s,
  one run per arm and adjacent in time, so that is fleet weather rather than the
  split; the median is the number to read.

⚠️ **perch's recorded figures need the same subtraction, and its verdict does
not change.** perch's Release job pays the same thing — its front end is 15.7s
median warm against 45.6s cold, five runs each way, ~30s. Its POST rows' *other
shape* is `dbg + rel − fixed` off a **cold** Release job, so each overstates
what one job would have cost by about that; corrected, its seven POST savings
are 41/53/7/69/39/43/54 and the fourteen-run median goes **60s → ~52s**. Its
PRE rows are untouched: `max(dbg, rel, iOS)` was never the Release half in any
of the seven, even with 30s added to it. So the same measurement that corrects
the number leaves the conclusion where it was — which is the reason to publish
it rather than quietly restate the median.

Per run, seconds. *gate* is what that run actually took; *other shape* is the
counterfactual — for a PRE run, what the split would have given it; for a POST
run, what one job would have cost it — both with the cold start above applied,
which is the only difference from perch's table. *dbg* and *rel* are real job
durations on the POST rows and synthesized from that run's own steps on the PRE
rows, where *rel* carries the cold start it would newly pay:

| arm | run | gate | other shape | dbg | rel |
| --- | --- | --- | --- | --- | --- |
| PRE | 34948631600 | 90 | 57 | 57 | 55 |
| POST | 34948791632 | 94 | 142 | 77 | 94 |
| PRE | 34949007084 | 182 | 112 | 112 | 112 |
| POST | 34949738983 | 58 | 92 | 57 | 58 |
| PRE | 34950378001 | 153 | 94 | 91 | 94 |
| POST | 34950634369 | 124 | 189 | 110 | 124 |
| PRE | 34950859345 | 112 | 76 | 62 | 76 |
| POST | 34951077026 | 97 | 161 | 97 | 96 |
| PRE | 34951259145 | 148 | 93 | 93 | 82 |
| POST | 34951526822 | 119 | 184 | 108 | 119 |
| PRE | 34951736034 | 174 | 110 | 105 | 110 |
| POST | 34952043086 | 107 | 172 | 107 | 101 |
| PRE | 34952235191 | 195 | 121 | 121 | 114 |
| POST | 34952558547 | 120 | 158 | 120 | 67 |

Step means after the cut, n=7 each: `Debug tests and analyze` is 12.4s of fixed
cost + 75.6s `Test` + 6.0s `Analyze`; `Release build and bundle guard` is 11.6s
+ 0s skills + 77.1s `Release build` + 2.9s guard. `Test` itself ran 44-97s
across the fourteen with no source change, which is why the figures above come
from comparing the two shapes inside each run.

⚠️ Both arms are `workflow_dispatch`, like perch's, which is what makes them
serialisable one at a time; nothing in the workflow branches on the event. Take
it again the same way, and **measure the cold start before doing arithmetic on
any step list** — on this evidence it is a property of the macOS runner and
Xcode rather than of either project, since trill and perch pay within a few
seconds of the same ~30s.
