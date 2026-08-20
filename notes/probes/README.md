# Capability probes

Re-runnable evidence for [`../macos-settings-matrix.md`](../macos-settings-matrix.md).
The matrix is one macOS release away from being wrong — rerun these on every bump.
(Six probes here aren't about macOS at all — `pack-priority.nix`,
`preset-composition.nix`, `scale-reach.nix`, `namespace-collision.nix`,
`source-shapes.sh` and `machine-diff.sh`, at the bottom — but they earn the same
shelf: a claim in a notes file, with the command that proves it beside it.)

```sh
swift notes/probes/accessibility-effective.swift   # effective a11y state (NSWorkspace)
swift notes/probes/locale-effective.swift          # resolved locale + enabled input sources
swift notes/probes/displays.swift                  # displays, persistent UUIDs, HiDPI modes
./notes/probes/ncprefs-flags.sh                    # per-app notification switches
./notes/probes/sound-sweep.sh                      # alert volume, beep sound, startup chime
./notes/probes/locale-sweep.sh                     # region keys, input sources
./notes/probes/power-sweep.sh                      # sleep/pmset (section C needs root)
```

`accessibility-effective.swift` reports what macOS *actually* honours, not what
the plist says. That distinction is the whole point: on 26.6, writing
`com.apple.Accessibility` changes the plist and nothing else.

## The open question — `universalaccess-fda-test.sh`

**Run this from a terminal that holds Full Disk Access.** It's the one thing the
matrix can't settle on its own: whether `com.apple.universalaccess` writes work
when the invoking app has FDA.

```sh
./notes/probes/universalaccess-fda-test.sh
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
./notes/probes/accessibility-sweep.sh   # from an FDA terminal
```

It separates keys with an `NSWorkspace` oracle (definitive: writes *and* takes
effect) from keys with none (persistence only — it pauses ~10s so you can look).
That split is deliberate: "the write succeeded" was never sufficient evidence
here, since `com.apple.Accessibility` writes succeed and change nothing.

## `sound-sweep.sh` · `locale-sweep.sh` · `power-sweep.sh` — §5.6's last three groups

Added 2026-08-08 to settle the three curated-settings groups the roadmap had
deferred *because nothing had been spiked*. Full results in
[`../macos-settings-matrix.md`](../macos-settings-matrix.md#sound--localeinput-sources--power--swept-2026-08-08);
the short version is that all three are reachable and the stated reason for
deferring each one was wrong — Sound, Locale and Power have 2, 4 and 6 typed
options respectively.

```sh
./notes/probes/sound-sweep.sh              # add --audible to hear the beep rows
./notes/probes/locale-sweep.sh
./notes/probes/power-sweep.sh              # A/B/D read-only
POWER_SWEEP_WRITE=1 ./notes/probes/power-sweep.sh   # + the root write test
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

Evidence for [`../options-roadmap.md`](../options-roadmap.md) §6's limit 3
instead of the matrix: what a shared **pack** must ship so a consumer's own host
wins, rather than colliding with it.

```sh
nix-instantiate --eval --strict --json notes/probes/pack-priority.nix
nix-instantiate --eval --strict --json notes/probes/pack-priority.nix \
  --arg rice ~/code/workshop/hausfold      # from a workshop worktree
```

No machine, no darwin system, no build — it evaluates the rice's pure-lib option
surface with the real `packs/writing.nix` and a fake host, in seconds. It is
here because it belongs to the same family as the rest: **the obvious answer is
the one that fails silently.** `mkDefault` on the whole `roster` attrset looks
like the cheap version and drops three of the pack's four apps without an error;
only per-leaf priority does what the roadmap wanted. Six compositions, verdicts
in the file header.

## `preset-composition.nix` — the other half of the same question

What happens when two whole **rices** meet, rather than a pack and a host.
`lib.pack` fixed host-vs-pack; this measures the case the roadmap left open and
the one a gallery produces.

```sh
nix-instantiate --eval --strict --json notes/probes/preset-composition.nix \
  --arg rice ~/code/workshop/hausfold
```

All six pairs of the four shipped presets, both escape hatches, and two candidate
seams. Same family lesson as the rest of this shelf, twice: **the assumption
nobody ran was wrong** (overlap isn't collision, and the conflict error names
both files), and **the quiet outcome is the dangerous one** — two rices' list
options merge with no error at all, so a pair that "composes" may just be one
that blends.

✅ **The pinnable subset of this moves into the rice** as `nix flake check`'s
`preset-composition` (rice#239, merged 2026-08-06), so the pairs the
docs advertise as stackable can't quietly stop stacking. The probe stays for the questions a golden table
can't ask — it prints resolved values and the `compose []` ordering experiment,
which is what you want the first time, not the hundredth.

## `scale-reach.nix` — what `ui.scale` reaches, and where it stops

The third non-macOS probe, and the one that needs a Mac anyway: it evaluates four
whole darwin systems rather than the pure-lib option surface. **Rerun it on a
macOS bump too** — two of its rows are nix-darwin defaults (`dock.tilesize`,
`NSTableViewDefaultSizeMode`), which is exactly the kind of thing a release moves.

```sh
nix-instantiate --eval --strict --json notes/probes/scale-reach.nix \
  --arg rice ~/code/workshop/hausfold
```

Evidence for [`../options-roadmap.md`](../options-roadmap.md) §5.2's two
unmeasured claims — that every point-valued option is silently coupled to
`haus.displays`, and the "honest scope" paragraph naming what `ui.scale`
does and doesn't move. Both turned out to be one measurement apart:

- **the point-valued surface is ONE option** (`fonts.mono.size`). Six numeric
  leaves in the 130 the options page renders (plus four internal mirrors it
  doesn't), and the rest are multipliers, ids, an ordering and a percent —
  every other point-valued number in the rice is internal to a module;
- **that one can't clip while prowl tiles it** — floating windows and
  `prowl.enable = false` are the precondition, and it's read off the code. The
  coupling only bites something that *sizes itself* in points, which is pounce
  (clamped), perch (proportional to the screen, and blind to `ui.scale`) and the
  bar (bounded by a band that is itself in points);
- **the reach table needs a third verdict.** Two surfaces change and then STOP,
  and a ceiling reads as `PARTIAL` under `accent-reach`'s vocabulary while being
  the deliberate answer.

✅ The pinnable subset shipped the same day as the rice's `scale-reach` check —
four scales, `moves` / `ceiling` / `pinned`, darwin-guarded beside `accent-reach`.
This file keeps the census and the resolved values.

## `namespace-collision.nix` — who owns `haus.<name>`

```sh
nix-instantiate --eval --strict --json notes/probes/namespace-collision.nix
nix-instantiate --eval --strict --json notes/probes/namespace-collision.nix \
  --arg haus ~/code/workshop/haus
```

Evidence for [`../rooms-desktops.md`](../rooms-desktops.md)'s Acquisition plan,
step E — namespace arbitration. It measures three things the note had been
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
./notes/probes/source-shapes.sh                                     # local fixtures, no network
PROBE_REMOTE=git+https://github.com/hausfold/workshop \
  ./notes/probes/source-shapes.sh                                   # + one real remote lock node
```

Evidence for [`../rooms-desktops.md`](../rooms-desktops.md)'s Acquisition plan,
step B. Step A shipped a sandbox for reading a **local** desktop file; step B
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
./notes/probes/machine-diff.sh                                      # module system + Nix, anywhere
PROBE_CONSUMER=~/.config/nix PROBE_HOST=mbp \
  ./notes/probes/machine-diff.sh                                    # + a real haus machine
```

Evidence for [`../rooms-desktops.md`](../rooms-desktops.md)'s Acquisition plan,
step C. A and B read the stranger's **file**; C is the first step that has to
look at the **reader's machine**, so the question is whether the module system
answers a leaf-by-leaf question cheaply, honestly and without writing anything.
Eight rows. `lib` comes from `$PROBE_LIB` or from the copy every haus machine
already ships beside the desktop checker; sections 5 and 8 need a real consumer
and skip loudly without one.

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
  is unreachable under `options` — measured against a real machine that has
  exactly that key — so everything under a recursive container can be compared
  by value and never by priority;
- **`nix eval` on a consumer flake writes its lock** when the lock needs changes.
  `--no-write-lock-file` computes one in memory and answers; `--no-update-lock-file`
  refuses. A command that promises to write nothing has to pick one on purpose;
- **`--apply` may not `import` an absolute path in pure mode**, so the query is
  an inlined string — which makes every option path taken out of a stranger's
  desktop an injection surface in the reader's own evaluation;
- **under lazy trees a store path out of an evaluation is a name, not a
  location.** Three evaluations of one pinned input give three different
  `…-source` paths, none of which exists on disk, while `builtins.readFile` on
  them works *inside* the evaluation that produced them. Every diagnostic that
  prints such a path — the module system's duplicate-declaration throw, haus's
  own unclaimed-namespace warning — is telling a person to look somewhere they
  cannot go, twice by two different names.

⚠️ Rows 1–8 are the **module system and Nix**, not haus. Rerun on a Nix or
nixpkgs bump; the lazy-trees row in particular is a property of Determinate
Nix's defaults rather than of every Nix. One trap it hit while being written is
worth keeping: `lib.getAttrFromPath` **`abort`s** on a missing attribute, and
`abort` is not something `tryEval` catches — so the probe for "this attribute is
absent" died of the absence it was measuring, and walks the tree by hand instead.
