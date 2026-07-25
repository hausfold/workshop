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

## Headline: the accessibility plan in the roadmap does not survive contact

**`com.apple.universalaccess` is not writable on macOS 26.6.** Not "flaky", not
"needs a restart" — a hard refusal:

```
$ defaults write com.apple.universalaccess nebelhausProbe -int 42
Could not write domain com.apple.universalaccess; exiting
```

**Control (same shell, same moment):** `com.apple.dock`, `com.apple.finder`,
`com.apple.screencapture`, `com.apple.Accessibility`, `com.apple.TimeMachine`
and a junk domain all accepted the identical write and read back `42`. So this
is domain-specific protection, **not** a sandboxed shell.

### What that costs

All **five** of nix-darwin's `system.defaults.universalaccess.*` options live in
that locked domain:

| nix-darwin option | Rice use it was wanted for | Status on 26.6 |
|---|---|---|
| `mouseDriverCursorSize` | `ui.cursorScale` — large-print rice | ❌ locked |
| `reduceMotion` | `ui.motion` | ❌ locked |
| `reduceTransparency` | `ui.transparency` | ❌ locked |
| `closeViewScrollWheelToggle` | scroll-to-zoom | ❌ locked |
| `closeViewZoomFollowsFocus` | zoom follows focus | ❌ locked |

Also locked, and worth knowing: **`FontSizeCategory`** — macOS 26's per-app text
size (Messages, Notes, Finder, Mail, Calendar, Books, News, Stocks, Weather,
plus a `global` key). That is *the* system "larger text" mechanism on 26, and
it is unreachable via `defaults`.

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

### The one honest unknown

nix-darwin writes user defaults as:

```
launchctl asuser "$(id -u -- ada)" sudo --user=ada -- defaults write com.apple.universalaccess …
```

I tested `sudo --user=$USER -- defaults write …` (failed, same refusal) but
**could not test the root-spawned `launchctl asuser` wrapper** — passwordless
sudo here is scoped to `darwin-rebuild`, so I can't get root for an arbitrary
command. TCC protection normally isn't bypassed by euid, so I expect it fails
too, but that is *belief, not measurement*.

- [ ] **Decisive test (main checkout, not a worktree):** put one
      `system.defaults.universalaccess.reduceMotion = true;` in a host file, run
      `haus rebuild`, then check the effective state with the probe in
      `notes/probes/`. If activation errors → nix-darwin is broken on 26 and it's
      worth an upstream issue. If it silently succeeds-but-does-nothing → worse,
      and worth an upstream issue anyway.

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
