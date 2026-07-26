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

- [ ] Open question: does *writing* it take effect, or does only the System
      Settings path work? Needs an FDA terminal: set Text size back to Default,
      then `defaults write com.apple.universalaccess FontSizeCategory -dict-add
      global AX1` and see whether Notes/Mail actually change.
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

- [ ] `nebelhaus` should own a post-activation restart map (which domain → which
      `killall` / "needs logout"), since upstream won't

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
   `locked-domain` · `manual-only`. Verified by effective-state probe, not plist
   read-back.
5. **`haus diff` must compare effective state, not plists** (§5.11). A
   plist-only diff would have called both no-op writes above "applied".

---

## Reusable probes

Worth committing so this is re-runnable on every macOS bump — the whole matrix
is one OS release away from being wrong.

- `ax.swift` / `probe.swift` — effective accessibility state via `NSWorkspace`
- `disp.swift` — displays, persistent UUIDs, deduped HiDPI mode list

- [ ] Move these into `nebelhaus/notes/probes/` and have `haus doctor --matrix`
      run them, so "does this still hold on 27?" is one command
