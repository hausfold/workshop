# macOS settings matrix — what a rice can actually set

Spike results for [`options-roadmap.md`](options-roadmap.md) §4. **Run on this
machine, not recalled from docs.**

- **Host:** macOS 26.6 (25G5065a), aarch64, MacBook Pro internal display only
- **Date:** 2026-07-25
- **nix-darwin:** `LnL7/nix-darwin` @ `a1fa429`
- **Method:** `defaults` for the plist layer; a compiled Swift `NSWorkspace`
  probe for *effective* system state — a plist read only proves the file
  changed, not that macOS listened.

Every domain touched was exported first and byte-compared after. **Zero net
change to this machine** (verified: `diff` of before/after is empty).

---

## Headline: `universalaccess` works — but only from an FDA-holding app

**✅ SETTLED 2026-07-25.** Run from Ghostty with Full Disk Access granted
(`notes/probes/universalaccess-fda-test.sh`):

```
2. Q1 — does a write SUCCEED?          ✓ WRITE SUCCEEDED and read back.
3. Q2 — does the value TAKE EFFECT?
     before: motion_reduced=false
     plist:  reduceMotion=1
     after:  motion_reduced=true       ✓
```

So `system.defaults.universalaccess.*` **is real on macOS 26** — it writes *and*
macOS honours it — **conditional on the app that invokes the rebuild holding
FDA.** Both of this file's earlier conclusions ("locked even as root", then
"unproven") are now superseded; the history is kept below because the wrong one
briefly drove a rice change.

> **⚠️ The asymmetry that matters for this machine.** The grant is on the
> *responsible app*, so **an agent-driven `haus rebuild` and your own terminal
> rebuild are not equivalent.** Ghostty has FDA; Claude Code (running under
> Claude.app) does not. If a host ever sets one of these five options, Julien's
> own rebuilds succeed and every agent rebuild **aborts activation partway** —
> skipping all launchd setup — for a config that "works on my machine". That is
> the single most likely way this bites here.

### The original failure, and why it misled

**`com.apple.universalaccess` refuses writes from a process without Full Disk
Access** — which was every process in the original spike. Not "flaky", not "needs
a restart": a hard refusal, exit 1.

```
$ defaults write com.apple.universalaccess nebelhausProbe -int 42
Could not write domain com.apple.universalaccess; exiting
```

**Control (same shell, same moment):** `com.apple.dock`, `com.apple.finder`,
`com.apple.screencapture`, `com.apple.Accessibility`, `com.apple.TimeMachine`
and a junk domain all accepted the identical write and read back `42`. So the
protection is **domain-specific** — but see the correction below: that control
proves it isn't a blanket sandbox, *not* that the domain is unconditionally
locked. FDA is the gate.

### Status per key — swept 2026-07-25 (Ghostty + FDA)

Full sweep run twice, byte-identical results, clean restore both times.

**Proven end-to-end** — write lands *and* `NSWorkspace` confirms macOS honours it:

| key | Rice use | nix-darwin typed? |
|---|---|---|
| `reduceMotion` | `ui.motion` | ✅ yes |
| `reduceTransparency` | `ui.transparency` | ✅ yes |
| **`increaseContrast`** | **the high-contrast rice (§5.1)** | ❌ **no → `CustomUserPreferences`** |
| **`differentiateWithoutColor`** | colour-blind safe mode | ❌ **no → `CustomUserPreferences`** |

> The two untyped ones are the finding. `increaseContrast` is the OS-level
> high-contrast lever, it works today, and it needs no upstream change — just
> `system.defaults.CustomUserPreferences."com.apple.universalaccess"`, which
> routes through the same `launchctl asuser` path (so: same FDA gate).

**Writes and persists, effect NOT verified** — no programmatic oracle exists, and
the visual check wasn't reported back, so these stop at "the plist holds it":

| key | Rice use | Status |
|---|---|---|
| `mouseDriverCursorSize` | `ui.cursorScale` | ◻️ persists (`3.0`); effect unconfirmed |
| `closeViewScrollWheelToggle` | scroll-to-zoom | ◻️ persists; effect unconfirmed |
| `closeViewZoomFollowsFocus` | zoom follows focus | ◻️ persists; effect unconfirmed |

**`FontSizeCategory` — real, but far narrower than hoped.** ⚠️

Two corrections here, in order.

**1. The vocabulary is `DEFAULT` / `AX1`…, not size words.** The sweep originally
wrote `global = LARGE`, the key changed, and it printed "✓ accepted" — worthless
evidence, since `defaults -dict-add` stores *any* string. Setting Text size in
System Settings ▸ Accessibility ▸ Display and reading back showed what macOS
itself writes:

```
global = AX1;      # was DEFAULT; System Settings showed "Text size — 20 pt"
version = "3.0";
```

`AX1` is Apple's Dynamic Type accessibility step. `LARGE` would have been stored
and ignored — exactly the illusion this file keeps having to warn about. Reads of
this domain are **not** FDA-gated (only writes are), so discovery is cheap.

**2. It does not scale the system — only apps that adopted Dynamic Type.** The
dict enumerates its participants, and it is a short, all-Apple list:

```
com.apple.MobileSMS · Notes · Mail · finder · iCal · reminders · journal
iBooksX · news · stocks · weather · Magnifier · AccessibilityReader
```

With `global = AX1` live, a non-participating process still reports the default:

```
$ swift -e 'import AppKit; print(NSFont.preferredFont(forTextStyle: .body).pointSize)'
13.0        # not 20
```

So this is **not** a general "make everything bigger" lever. It will not touch
Ghostty, Zen, Slack, or anything third-party. (Caveat: a CLI process is weak
evidence about *app* behaviour on its own — but combined with the explicit
per-bundle-ID list, the shape is clear.)

**Consequence:** `FontSizeCategory` is worth wiring as a *nicety* for the Apple
apps a non-dev Mac actually lives in (Mail, Messages, Notes, Calendar) — which
is genuinely the "Sunday Mac" audience. It is **not** the system-level half of
the large-print rice. That half remains display scaling (§5.10) plus the rice's
own font sizes (§5.3).

**3. Writing it lands but posts no change notification — do not ship this.** ❌

Tested directly: Text size set back to Default, every app set to "Use Preferred
Reading Size", Notes open, then from an FDA terminal:

```
defaults write com.apple.universalaccess FontSizeCategory -dict-add global AX1
```

Result:

| | |
|---|---|
| plist | ✅ correct — `global = AX1`, all 13 apps `UseGlobal`, nothing lost |
| System Settings **value** | ✅ shows 20 pt |
| **Notes (running app)** | ❌ **text does not change** |
| System Settings **per-app rows** | ❌ render wrong — several show `Default`, one blank |
| after dragging the slider by hand | ✅ everything reconciles and follows |

So the write is *stored* but no change notification is posted. Running apps
never re-read it, and System Settings — if open — renders a desynced view of a
plist that is actually fine. The rows looking "corrupted" is a **display**
artifact; quitting and reopening System Settings shows the true values. (Data
verified against the original snapshot: no entries lost, four *gained* as macOS
registered more participants.)

**This is the third member of the write-that-lies family**, after
`com.apple.Accessibility` (writes, no effect) — and it was the worst until
`AppleInterfaceStyle` was measured on 2026-08-08 (see below): that one is
*read back correct* while doing nothing, so it defeats the read-back check
this one at least survives. A nebelhaus option backed by this
would produce a Mac where System Settings claims 20 pt, every app renders 13 pt,
and the settings pane looks broken — and the user would rightly blame the rice.

**Heuristic worth carrying forward:** in this domain the keys that work are
**scalar** (`reduceMotion`, `reduceTransparency`, `increaseContrast`,
`differentiateWithoutColor` — all bools, all notify correctly). The one that
fails is the **structured** one. Treat dict-valued accessibility keys as
GUI-only until proven otherwise.

- [ ] Only avenue left, untested: find the Darwin notification the slider posts
      and fire it after the write. `com.apple.accessibility.cache.ax` did not
      work for the other keys, so this is a long shot — and even if found, it
      would make the option depend on an undocumented notification name.
- [ ] Confirm the ◻️ rows by eye — is the cursor visibly bigger at `3.0`, does
      `^`+scroll zoom? Cheap, and it's the difference between "persists" and
      "works".

**Design consequence either way:** an option that works only when the user has
granted FDA to whatever terminal they happen to rebuild from is not a solid
foundation for a *shared* rice — the same config silently behaves differently on
two machines. So the ranking below still holds: build the large-print rice out
of things the rice fully controls, and treat these as a bonus, not a base.

### The nastier finding: `com.apple.Accessibility` is a silent no-op

That domain **is** writable and holds the modern keys (`ReduceMotionEnabled`,
`DifferentiateWithoutColor`, `DarkenSystemColors`, `EnhancedBackgroundContrastEnabled`,
`FullKeyboardAccessEnabled`, `InvertColorsEnabled`, `GrayscaleDisplay`,
`ButtonShapesEnabled`). Writing it changes the plist and **nothing else**:

| | plist after write | `NSWorkspace` effective |
|---|---|---|
| `ReduceMotionEnabled` | `1` ✅ | `reduceMotion=false` ❌ |
| `DifferentiateWithoutColor` | `1` ✅ | `diffWithoutColor=false` ❌ |

Unchanged after a 2s settle and after poking `com.apple.accessibility.cache.ax`.

**This is the worst possible failure mode for a shared rice** — `haus rebuild`
succeeds, the plist shows the right value, a `diff`-style check would report
"applied", and the Mac behaves exactly as before. Any accessibility option built
on this domain would ship a lie.

### ⚠️ CORRECTED — it's Full Disk Access, not an unconditional lock

**An earlier revision of this file said "locked even as root". That was wrong.**
Keeping the retraction visible because the wrong version briefly drove a rice
change (a hard assertion) that would have blocked working configs.

Measured 2026-07-25 by a real `haus rebuild`. nix-darwin writes user defaults as:

```
launchctl asuser "$(id -u -- ada)" sudo --user=ada -- defaults write com.apple.universalaccess …
```

Running **that exact command shape, from root, inside activation**:

```
SPIKE RESULT: WRITE FAILED (exit 1) — domain locked even as root
```

The observation is real; the *conclusion* was not. `com.apple.universalaccess`
is TCC-protected, and the grant that matters is **Full Disk Access on the app
responsible for the rebuild** — the terminal you invoke `darwin-rebuild` from,
not the euid it runs as. Every command in this spike ran under Claude.app,
which does **not** hold FDA (verified: every FDA-gated read is denied). So the
whole chain lacked FDA and the refusal is fully explained by the documented TCC
requirement.

[nix-darwin#1049](https://github.com/nix-darwin/nix-darwin/issues/1049) and
[#705](https://github.com/nix-darwin/nix-darwin/issues/705) report the same
failure, with several people confirming FDA on the terminal fixes it — and one
noting that on Tahoe a *stale* grant must be removed and re-added with (+).

**Not verified from this session:** the positive case. I can't grant myself FDA,
so "it works with FDA" rests on those upstream reports, not on my own
measurement.

- [ ] Confirm the positive case: grant Ghostty FDA, set one option, rebuild from
      Ghostty, and check with `notes/probes/`. **Only then** is the true status
      of these five options settled.

#### The methodological lesson

The control I ran (other domains accept the same write from the same shell)
proved the failure was *domain-specific*. I read that as "the domain is locked",
when it only ever supported "this domain needs something the others don't". A
control that rules out one confounder doesn't rule out all of them — and the
missing check here was cheap: read an FDA-gated path and see.

An early version of that check was itself buggy — `head -c 16 "$p" || ls "$p"`
reports "readable" for any file that merely *exists*, because `ls` succeeds on a
stat. It briefly showed FDA as present. Strict read-only probing (no `ls`
fallback) showed every FDA-gated read denied.

#### …and the failure mode is worse than "does nothing"

The generated write is **unguarded**, in an activation script that starts with
`set -e`:

```
line   5: set -e
line 559: launchctl asuser … defaults write com.apple.universalaccess reduceMotion '…'
line 877: (end of script)
```

`defaults` exits **1**. So *whenever that write fails* — for any reason, FDA
being the common one — `darwin-rebuild switch` **aborts at line 559 and skips
the remaining 318 lines**, which include the `SLSMenuBarUseBlurredAppearance`
write (Sill's opaque menu bar), the Dock restart, and **every launchd daemon and
user-agent setup step** (`awake`, `aerospace`, `hush-watcher`, pounce,
sketchybar…).

**This part survives the correction above** — it's the consequence of the write
failing, not a claim about *why* it fails. It's also what makes the upstream
reports so confusing: the symptom (launchd services missing, bar wrong) appears
nowhere near the cause, and nothing tells you the run stopped early.

Had we naively backed `nebelhaus.accessibility.motion = "reduced"` with that
option, a user without FDA would get a half-activated Mac and no clear reason
why.

> **How this was measured safely.** Not by setting the option — that would have
> caused exactly the aborted activation described above. Instead a
> `system.activationScripts.postActivation` hook replicated the identical command
> in the identical context (root, `launchctl asuser` + `sudo --user=`), on a junk
> key, wrapped in `if/else` so it could not abort, cleaning up after itself. Host
> config reverted and rebuilt to a clean generation afterward; verified zero
> residue in `/run/current-system/activate` and in the domain.

- [x] **Upstream**: reported on
      [nix-darwin#1049](https://github.com/nix-darwin/nix-darwin/issues/1049) —
      the FDA requirement is already known there; what wasn't is *why* it half-
      breaks the machine. Minimum fix is `|| true` on the generated writes (or a
      warning at eval time) so a missing grant costs you the setting, not the
      rest of activation.
- [x] nebelhaus **warns** when those five are set — nebelhaus#89. A warning, not
      an assertion: with FDA they work, so blocking would be wrong.

---

## What *does* work

### Writable and effective

| Domain | Restart needed | Notes |
|---|---|---|
| `com.apple.dock` | `killall Dock` — **nix-darwin does this** | 33 typed keys incl. hot corners |
| `com.apple.finder` | `killall Finder` — **nix-darwin does NOT** | 20 typed keys |
| `com.apple.screencapture` | none | 7 typed keys, applies to next capture |
| `NSGlobalDomain` | varies per key | 53 typed keys |
| `com.apple.AppleMultitouchTrackpad` | none | 22 typed keys |
| `com.apple.WindowManager` | logout | 12 typed keys |
| `com.apple.controlcenter` | `killall ControlCenter` — not done | ByHost domain |

### `NSGlobalDomain AppleInterfaceStyle` — the write-that-lies family's newest member, and the only one that lies *back*

Swept 2026-08-08 on **macOS 26.6**, with a Swift probe reading
`NSApp.effectiveAppearance` on a 1s tick *and* subscribed to
`AppleInterfaceThemeChangedNotification`. Machine started Dark; every path
restored it.

| lever | plist after | effective appearance | notification |
|---|---|---|---|
| `defaults delete -g AppleInterfaceStyle` (from Dark) | absent ✅ | **dark** ❌ | none ❌ |
| … then `activateSettings -u` | absent | **dark** ❌ | none ❌ |
| … then `killall -HUP SystemUIServer` | absent | **dark** ❌ | none ❌ |
| … then a **freshly launched** process | absent | **dark** ❌ | — |
| `defaults write -g AppleInterfaceStyle Dark` (from Light) | `Dark` ✅ | **light** ❌ | none ❌ |
| … then `activateSettings -u`, then a fresh process | `Dark` | **light** ❌ | none ❌ |
| **System Events (AppleScript) `set dark mode to false`** | **deleted by macOS** | **light ✅ in ~0.3s** | **fired ✅** |
| **System Events `set dark mode to true`** | **written by macOS** | **dark ✅** | **fired ✅** |

So this key is **inert in both directions** — and unlike
`com.apple.Accessibility` (which at least stays where you put it and does
nothing), this one is where macOS **mirrors the appearance it is showing**. That
makes it the most misleading row in this document: a plist read-back reports the
write you just made, so a naive diff calls an inert write "applied", and the
fresh-process test — the usual tiebreaker for "is this just a caching problem?" —
*also* fails. The appearance lives in session state the WindowServer owns;
`defaults` never reaches it.

Consequences already taken: `nebelhaus.theme.systemAppearance` drives it through
System Events from home-manager activation, `hausax` grew an `appearance` key so
the effect is confirmed against AppKit, and `haus diff` flags a hand-declared
`AppleInterfaceStyle` the way it flags `com.apple.Accessibility`. Note this also
means `system.defaults.NSGlobalDomain.AppleInterfaceStyle` — a *typed* nix-darwin
option — is dead on macOS 26; the `NSGlobalDomain` row above is "effective" for
its other 52 keys, not this one.

The reachability cost is an **Automation** grant for whatever app runs the
rebuild (System Settings ▸ Privacy & Security ▸ Automation) — the same shape as
`universalaccess` needing FDA, and it degrades the same way: refused means the
appearance doesn't move, not that activation dies.

### Restart behaviour is thinner than assumed

nix-darwin's entire post-write restart logic is **one line**, and only fires when
a `dock` option changed:

```nix
killall -qu <primaryUser> Dock || true
```

There is **no `activateSettings -u` call anywhere** in the module. So Finder,
WindowManager, ControlCenter and menu-bar changes land in the plist and wait for
a manual restart or logout. **The rice has to own this** — it's exactly the kind
of "it didn't work / oh, log out" papercut that makes a shared rice feel broken.

- [x] `nebelhaus` should own a post-activation restart map (which domain → which
      `killall` / "needs logout"), since upstream won't. **Done, 2026-08-07 —
      `modules/lib/restart-map.nix` (nebelhaus), keyed by exactly the domain
      names in this matrix's tables; `com.apple.controlcenter` and
      `com.apple.WindowManager` are declared (`ControlCenter` / `logout`)
      ahead of the rice ever writing into them. See
      options-roadmap.md's tenth-pass status note.**

### Display scaling: reachable, and with no Homebrew dependency

The roadmap assumed `displayplacer`. **It isn't in nixpkgs** (`nix run
nixpkgs#displayplacer` → no such attribute; it's a Homebrew formula). But the
public CoreGraphics API covers the whole spike:

```
active displays: 1
— display id=1 builtin=true main=true
  persistent UUID: 37D8832A-2D66-02CA-B9F7-8F30A301B230
  current: 1512x982 pt on 3024x1964 px @120Hz
  total modes=132  HiDPI modes=72  (9 distinct "looks-like" sizes)
```

Distinct HiDPI modes on the internal panel, largest-UI last:

`1800x1125` · `1800x1169` · `1512x945` · **`1512x982` (current)** · `1352x845` ·
`1352x878` · `1280x800` · `1147x716` · `1147x745` · `1024x640` · `1024x665` ·
`960x600`

So the intent mapping is concrete and real:

| `displays.internal.uiScale` | looks-like |
|---|---|
| `more-space` | `1800x1169` |
| `default` | `1512x982` |
| `larger-text` | `1147x745` |
| `largest-text` | `1024x665` |

- ✅ **A stable identifier exists** — `CGDisplayCreateUUIDFromDisplayID` (needs
  `import ColorSync`) returns a persistent UUID, so a `displays` option can be
  keyed by UUID rather than a reorderable index. This was the main risk and it's
  retired.
- ✅ `CGDisplaySetDisplayMode` is public API → the rice can ship a ~40-line Swift
  helper instead of taking a Homebrew dependency.
- ⚠️ **Untested:** actually *setting* a mode (would have resized the user's screen
  mid-session). Multi-display arrangement untested — only one display attached.
- ⚠️ Modes are duplicated ~6× (refresh rate × colour depth); the helper must
  dedupe by point size and pick the highest refresh.

### Typed-option surface: 193, not "several hundred"

Counted from `a1fa429`, `modules/system/defaults/*.nix`:

| domain | keys | | domain | keys |
|---|---|---|---|---|
| NSGlobalDomain | 53 | | screencapture | 7 |
| dock | 33 | | controlcenter | 7 |
| trackpad | 22 | | universalaccess | 5 ❌ |
| finder | 20 | | ActivityMonitor | 5 |
| WindowManager | 12 | | smb, screensaver | 2 each |
| loginwindow | 11 | | spaces, SoftwareUpdate, magicmouse, LaunchServices, iCal, hitoolbox | 1 each |
| menuExtraClock | 8 | | **total** | **193** |

The rice sets 19. Correcting the roadmap's "several hundred".

---

## Sound · Locale/input sources · Power — swept 2026-08-08

The three §5.6 groups that were deferred *because nothing had been spiked*.
Same method as the rest of this file: macOS 26.6.1 (25G76), nix-darwin
`a1fa429`, effective-state oracles rather than plist read-back, every domain
snapshotted and restored — and the restore then *verified* by comparing each
touched key's XML fragment (value **and** type) against the snapshot, because
`defaults read` renders a float and a string identically. Re-runnable:

```sh
./notes/probes/sound-sweep.sh      # + --audible for the one row that needs an ear
./notes/probes/locale-sweep.sh
./notes/probes/power-sweep.sh      # A/B/D read-only; C is opt-in, see below
```

**Headline: all three are reachable, and the roadmap's stated reason for
deferring each one was wrong.** Sound and Locale both *do* have typed
nix-darwin keys (six between them), and Power has six typed options of its own.
What actually blocks each group is smaller, different, and in two cases not a
key at all.

| group | verdict | what actually blocks it |
|---|---|---|
| **Sound** | ✅ **buildable today, fully settled** | the volume leaf is an exponential, not a fraction; the UI writes the same key back; and a bad `beep.sound` path is silence, so the option must validate it |
| **Locale** | ✅ buildable, with one piece nothing in nix-darwin can express | a **distributed notification**, without which running apps never see the change |
| **Power** | ⚠️ buildable on `pmset`, **not** on the typed options | `systemsetup` works, but writes ONE profile: asked for computer sleep 17 while on battery, it set AC and left battery alone — so `power.sleep.*` configures a source the config never named, silently |

### Sound — works, but the number lies

Oracle: `osascript -e 'get volume settings'` → CoreAudio's live alert volume
(0–100). Not a plist re-read.

| key | nix-darwin | reachability | notes |
|---|---|---|---|
| `com.apple.sound.beep.volume` | ✅ typed float | **typed-and-effective** | live, no restart, **no FDA gate** — an agent rebuild can set it |
| `com.apple.sound.beep.feedback` | ✅ typed bool | writable, no oracle | volume-key feedback; nothing reads it back |
| `com.apple.sound.beep.sound` | ❌ → `CustomUserPreferences` | **typed-and-effective, with a trap** | absolute path, **unvalidated** — and a bad path is SILENCE, not a fallback (heard 2026-08-08) |
| `com.apple.sound.uiaudio.enabled` | ❌ → `CustomUserPreferences` | writable, no oracle | UI sound effects |
| startup chime | — | `nvram StartupMute`, root | firmware, not a plist; outside `system.defaults` entirely |

**1. The volume leaf is `e^(slider − 1)`, not a percentage.** Measured:

| written | 1.0 | 0.7788008 | 0.6065307 | 0.5 | 0.4723665 | 0.3678794 | 0.0 |
|---|---|---|---|---|---|---|---|
| alert volume | 100 | 75 | 50 | **31** | 25 | **0** | 0 |

Everything at or below `e⁻¹ ≈ 0.3679` is silence. nix-darwin's own docstring
lists 75/50/25% as three magic constants and never says the curve, so `0.5`
reads as "half" and is 31%. A curated `sound.alertVolume` should take 0–100 and
convert; exposing the raw float would ship a silent lie.

**2. It is a two-writers key.** `set volume alert volume 60` — the path the
Sound pane and the volume keys use — writes `0.67032` into the *same*
`NSGlobalDomain` key (`e^(0.6−1)` exactly). So a declared value silently
reverts a hand-set alert volume at every rebuild, and a later drag of the
slider silently diverges from the declaration. §5.7's two-writers question,
inside a settings group.

**3. Null really is write-nothing.** Deleting the key returns the alert volume
to 100 (the OS default) rather than to 0 — the group's default policy holds.

**4. ✅ SETTLED by ear, 2026-08-08 — a bad `beep.sound` path is SILENCE, not a
fallback.** Recorded row by row:

| row | `beep.sound` | heard? |
|---|---|---|
| 0 control | unset (OS default) | ✅ yes |
| 1 | `/System/Library/Sounds/Submarine.aiff` | ✅ yes |
| 2 | `/nope/does-not-exist.aiff` | ❌ **no** |

So the key works, and a typo turns the alert beep off while the plist reads
exactly like a working configuration. **A curated `sound.alertSound` must
validate the path — at eval time if it takes a path at all, or by taking an
enum of the 14 names in `/System/Library/Sounds` and building the path
itself.** This is `screencapture.location`'s missing-directory trap (above) in
the same settings group, with a worse failure: there, screenshots quietly go to
the Desktop; here, the machine quietly stops making a sound you asked it to
make.

Getting that answer took three attempts, and the probe carries the fixes:
`--audible` restores every key first (section C leaves `uiaudio.enabled = 0`
set, so the first run beeped four times under the probe's own mute — four
silences, no information), plays a **control** at pristine settings, and per
row waits for ⏎ and asks `heard it? [y/N]` while you still know which beep it
was. The middle run produced "I heard one beep": true, unattributable, worth
nothing. **When the oracle is a human, record per row — do not batch the
question.**

### Locale / input sources — works, and the missing piece is a notification

Oracle: `notes/probes/locale-effective.swift` — Foundation + Carbon TIS in a
**fresh** process (locale, preferred languages, measurement system, temperature
unit via `MeasurementFormatter(.naturalScale)`, ICU hour skeleton, first
weekday, current + enabled input sources).

| key | nix-darwin | effect on a fresh process |
|---|---|---|
| `AppleICUForce24HourTime` | ✅ typed | ✅ hour skeleton `h a` → `HH` |
| `AppleMetricUnits` | ✅ typed | ✅ measurement system → `ussystem` |
| `AppleTemperatureUnit` | ✅ typed | ✅ 20 °C → 68 °F |
| `AppleMeasurementUnits` | ✅ typed (`Inches`/`Centimeters`) | ❌ **nothing** — no oracle here moves |
| `AppleLocale` | ❌ → `CustomUserPreferences` | ✅ moves hour format, measurement system **and** first weekday together |
| `AppleLanguages` | ❌ → `CustomUserPreferences` | ✅ `Locale.preferredLanguages`; UI language follows on app **relaunch** |
| `AppleFirstWeekday` (dict) | ❌ | ❌ **lands and lies** — stored, no error, `Calendar` ignores it |

**1. `AppleMeasurementUnits` is this group's "second key that makes the first a
lie", inverted.** It is the friendly, obviously-named, *typed* one — and it is
the inert one. macOS writes all three unit keys together when you change the
region; a rice that sets only the obvious one gets a plist that reads right and
a machine that ignores it. `AppleMetricUnits` is the load-bearing key.

**2. `AppleFirstWeekday` is the second dict-valued key in this file to land and
do nothing** (after `FontSizeCategory`). Set `AppleLocale` instead — `de_DE`
moves the first weekday to Monday on its own. Working rule: **treat
structured keys in Apple's global domain as GUI-only until one proves
otherwise.**

**3. The finding that decides the group: a running app never notices.** A
`defaults write` reaches new processes only. Watched at 2s intervals for 8s
after the write, *nothing* changed — not even `Locale.autoupdatingCurrent`, the
flavour documented to track changes. Posting
`AppleDatePreferencesChangedNotification` (a **distributed** notification)
immediately after the write flips both flavours within one sample.
`AppleMeasurementSystemPreferencesChangedNotification` works too; a made-up
name does nothing, so this is name-specific, not a generic cache poke.

So the group's missing piece is neither a key nor a `killall`, and
`modules/lib/restart-map.nix` has no vocabulary for it. This is the first
setting family whose "restart" is a **notification post** — worth a third verb
beside `killall`/`logout`.
(It does **not** rescue `AppleLanguages`: which `.lproj` a bundle loads is
decided at launch, so the UI-language half is honestly "takes effect on app
relaunch".)

**4. Input sources are settable from a plist — and the authoritative-looking
key is the decorative one.** `com.apple.HIToolbox` `AppleEnabledInputSources`
is honoured live (TIS saw a layout appear the moment `defaults import`
returned):

| entry written | result |
|---|---|
| `{Name: German}`, no ID | ❌ stored, silently nothing |
| `{ID: 3, Name: German}` | ✅ German |
| `{ID: 99999, Name: French}` | ✅ **French** — the bogus ID is never validated |
| `{ID: 1, Name: Nonexistent}` | ❌ silently nothing |

`KeyboardLayout ID` must merely be *present*; `KeyboardLayout Name` is what
resolves the layout. That is the exact inverse of the hot-corners finding,
where the integer was the truth. And the name is not derivable from the input
source ID — `com.apple.keylayout.SwissFrench` is `"Swiss French"`,
`com.apple.keylayout.ABC-QWERTZ` is `"ABC-QWERTZ"` — so a hand-typed name table
in Nix would be wrong for exactly the layouts nobody here tests. Learn each one
by letting macOS write it: `swift notes/probes/tis-toggle.swift enable <id>`
uses the documented `TISEnableInputSource`, which is live, reversible, and
writes the canonical entry for you.

### Power — typed after all, but source-blind and silent

`power.sleep.{computer,display,harddisk,allowSleepByPowerButton}` and
`power.restartAfter{PowerFailure,Freeze}` are all typed. They are **not**
`system.defaults`: like `networking.applicationFirewall`, nix-darwin shells out
in its own activation script — here to `systemsetup` — so no restart-map entry,
no plist, and none of this file's usual `defaults`-based evidence applies.

Two limits, from `<nix-darwin>/modules/power/*.nix` (its tree, not the rice's
`modules/`), `man systemsetup`, and the write test below:

1. **No power-source selector exists — and the missing selector is not neutral.**
   Every `systemsetup` sleep verb is source-blind, while macOS stores the two
   sources separately (`Wake On LAN` 1 vs 0 here, `ReduceBrightness`
   battery-only). Measured: `-setcomputersleep 17` wrote the **AC** profile and
   left battery alone, *while the machine was running on battery*. So the typed
   options cannot express "sleep at 5 min on battery, never on AC" — the only
   opinion a laptop rice has — and worse, what they do write goes somewhere the
   config never named.
2. **Every call ends in `&> /dev/null`.** A refusal, an unsupported verb and a
   success are indistinguishable, which is the failure mode §5.6 exists to
   avoid, one layer below `system.defaults`. Not hypothetical: `systemsetup`
   emits an Admin-framework `-99` on stderr on this machine even when the write
   succeeds, so there is real content in a stream nobody reads.

Not typed at all, and unreachable through `system.defaults`: Low Power Mode
(`pmset -a lowpowermode`), per-source anything (`pmset -b`/`-c`), lid and
clamshell (`lidwake`, `disablesleep`), `hibernatemode`, `womp`. All are
root-only writes into a root-owned plist, so a curated `nebelhaus.power.*`
belongs in the `security.firewall` family (an activation step of our own),
**not** in the `hotCorners`/`screenshots`/`menuBar` family.

### The write test, and the trap it set for its own author

Ran 2026-08-08 from Ghostty (an FDA-holding terminal, so none of this is the
universalaccess gate), as root. **Read this section for the method as much as
the result** — the first two runs each produced a confident wrong conclusion.

**Run 1 — `systemsetup` looked like it applied nothing:**

```
$ sudo systemsetup -setcomputersleep 17
### Error:-99 File:…/Admin/InternetServices.m Line:395
setcomputersleep: 17                      ← reads exactly like a confirmation
exit=0
before: AC=1 battery=1        after: AC=1 battery=1        ← read from the plist
```

Exit 0, a confirmation-shaped line, an internal `-99` from the Admin framework
on stderr, and no visible change — with nix-darwin sending every one of those
streams to `/dev/null`. The obvious reading is "nix-darwin's six typed options
are a silent no-op on macOS 26, file it upstream". **It was wrong**, and the
`-99` is noise: the write had landed. Keep the line in mind anyway — a genuine
failure would look identical from nix-darwin's side, because nothing is read.

**Run 2 — the `pmset` control didn't move it either**, so the reading became
"computer sleep is immutable here". **Run 3** added the full 2×2 and produced a
third story: four timer writes failed while `pmset -a lowpowermode 1` landed,
same shell, same root, same run.

**Run 4 — the oracle was the bug, and every write had been landing all along.**
Runs 1–3 read `/Library/Preferences/com.apple.PowerManagement.plist`; `powerd`
flushes that file on its own cadence. Reading `pmset -g custom` instead:

| setting | via `systemsetup` | via `pmset` |
|---|---|---|
| computer sleep | ⚠️ **AC only** (asked 17 → AC=17, battery=1) | ✅ AC=18, battery=19, as named |
| display sleep | ✅ AC=21 | ✅ AC=22, battery=23, as named |
| Low Power Mode | *(not offered)* | ✅ landed |

The probe caught the stale file in the act on its way out — `computer
AC=18(file:1) bat=19(file:1)`: live state 18/19, the file still saying 1.

★ **Four runs, three wrong conclusions, and not one of them was a macOS
surprise — they were all measurement errors.** In order: a single row read as a
verdict; a negative result with no control (*a failed write says nothing about
the writer until a second writer has failed the same way and a second setting
has succeeded*); and finally two different oracles inside one table, which is
not a cross but two experiments sharing a heading. The rule this earns, and it
generalises past power: **where a domain exposes two readable states, decide
which one is the oracle before running anything — and never let one table's
rows be judged by different readers.** The plist here is what
`com.apple.Accessibility` was to §4: the thing that reads like evidence and
isn't.

**So the real limit is not that `systemsetup` fails. It is that it writes one
profile.** Asked for computer sleep 17 while the machine was running *on
battery*, it set **AC** and left battery alone. `power.sleep.computer = 17`
therefore configures a laptop's AC profile only, silently, and a user who set
it to protect their battery gets nothing — while `pmset -b`/`-c` does exactly
what it is told. That is a determinism and correctness bug the config cannot
see, and it is worth filing upstream.

- [ ] Report to `LnL7/nix-darwin`: `power.sleep.*` writes only one power
      profile on macOS 26 (`systemsetup -setcomputersleep` moved AC while the
      machine was on battery), and `system.activationScripts.power` discards
      stderr, so nothing surfaces. `power-sweep.sh` is the reproducer.
- [ ] ◻️ One row is measured on AC only: whether `systemsetup -setdisplaysleep`
      is also AC-only was not read for the battery profile in run 4. The probe
      now prints both sources for that row, so the next run settles it.

---

## Consequences for the roadmap

1. **`nebelhaus.accessibility` as designed is mostly unbuildable.** Vision and
   motor knobs route through a locked domain or a no-op domain. Demote it from a
   full option family to: a few keys that genuinely work, plus `haus doctor`
   checklist items with System Settings deep links. **Do not ship options that
   write `com.apple.Accessibility`** — they'd report success and do nothing.
2. **Delete `ui.cursorScale`** from the `ui.*` token set (§5.2). Locked domain.
3. **The large-print rice is still absolutely buildable — just not out of macOS
   accessibility settings.** It's built from:
   - display mode (`larger-text`) — ✅ proven reachable
   - `nebelhaus.fonts` sizes — ✅ fully ours
   - Dock `tilesize` / `largesize`, Finder icon size — ✅ typed and writable
   - Sill height/padding, Pounce row height, Ghostty font size — ✅ fully ours
   - a high-contrast **theme flavor** — ✅ fully ours (nebelung)

   Which is a strong argument for the roadmap's existing ranking: **§5.1 theme
   flavors, §5.2 `ui.*` tokens and §5.3 fonts are the real levers**, because they
   are the parts macOS can't veto. The spike *raises* their priority rather than
   lowering it.
4. **Add a "reachability" designation to every curated setting** (§5.6), with a
   value macOS can't fake: `typed-and-effective` · `writable-no-op` ·
   `writable-mirror` · `locked-domain` · `manual-only`. Verified by
   effective-state probe, not plist read-back. (`writable-mirror` was added
   2026-08-08 for `AppleInterfaceStyle` — a key that *reflects* effective state,
   so its read-back is actively deceptive rather than merely uninformative. It
   is the class `haus.sh`'s `classify_key` calls `appearance`.)
5. **`haus diff` must compare effective state, not plists** (§5.11). A
   plist-only diff would have called all three no-op writes above "applied" —
   and the appearance one twice over, since that key reads back the write you
   just made.
6. **`restart-map.nix` needs a third verb: `notify`** (added 2026-08-08). The
   locale family's "restart" is a distributed notification post, not a
   `killall` and not a logout, and there is no daemon to kill — every app is
   the consumer. Without it a locale group ships settings that are correct on
   the next login and invisible today.
7. **A curated leaf may not expose a raw macOS scalar just because it is
   typed.** `com.apple.sound.beep.volume` is an exponential wearing a
   fraction's clothing, and `KeyboardLayout ID` is a required field nothing
   validates. The unit of curation is the *user's* quantity (0–100 volume, a
   `com.apple.keylayout.*` id), with the conversion in the module.
8. **Two of §5.6's three "no typed surface" claims were wrong** — Sound has two
   typed keys, Locale four, Power six. The check that would have caught it is
   `grep mkOption` over `modules/system/defaults/*.nix` plus `modules/power/`,
   which is cheaper than the spike it was used to defer.

---

## Reusable probes

Worth committing so this is re-runnable on every macOS bump — the whole matrix
is one OS release away from being wrong.

- `ax.swift` / `probe.swift` — effective accessibility state via `NSWorkspace`
- `disp.swift` — displays, persistent UUIDs, deduped HiDPI mode list

- [ ] Move these into `nebelhaus/notes/probes/` and have `haus doctor --matrix`
      run them, so "does this still hold on 27?" is one command
