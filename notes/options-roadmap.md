# Option-surface roadmap — from "Julien's dev rice" to a shareable rice format

Working doc. The end goal: people publish **nebelhaus configs** of wildly
different kinds — a large-print Mac for a parent, a writer's machine, a
mouse-first creative setup — by changing `nebelhaus.*` and nothing else. When
this was written the option surface could express none of them; `everyday` now
works, and the rest are tracked against the readiness test in §6.

This refines an earlier brainstorm against what's actually in the repos as of
2026-07-25. Read §1 first — several things the brainstorm proposed building
already exist, and one it treated as a detail is the actual root blocker.

> **Status, 2026-07-26.** §3 (structure) and §4 (spikes) are **done**; §3's four
> items landed as nebelhaus#92/#96/#98/#93 + workshop#81, and the macOS spikes
> settled in the matrix. Also shipped from §5: fonts (#91) and the two working
> accessibility keys (#90).
>
> The live edge is **Phase 3, the expression layer** — theme flavors, `ui.*`
> tokens, `keys.*`, and apps v2. Those are what a `large-print` preset needs,
> and `large-print` is the next entry on the readiness test at the end of §6.

---

## 1. Ground truth (verified, not remembered)

| Claim | Reality |
|---|---|
| "~40 first-class options" | ✅ ~44 leaves in [`modules/options.nix`](nebelhaus/modules/options.nix) — but 13 of those are the `sill.items` pill bools and 5 are `hush.slack.*`. The *shape* surface is more like 25. |
| "rice sets ~19 macOS defaults" | ✅ 19 keys in [`den/default.nix:144-183`](nebelhaus/modules/den/default.nix:144). nix-darwin types **193** (counted, see the matrix) — not "several hundred" as this doc first said. |
| "replace `prowl.apps` with a general app registry" | ⚠️ **Already done.** It's `nebelhaus.apps` — `attrsOf` a submodule, merges across modules, has `enable`/`order`/`cask`. Don't rebuild it; **extend** it (§3.4). |
| "add `haus plan` / `capture` / `diff` / `undo`" | ⚠️ **Partly exists in the installer.** `bootstrap.sh` has a read-only preflight audit, `NEBELHAUS_KEEP=dock,keyboard,finder` current-value capture, and cask adoption. The job is *promoting* those into `haus`, not greenfield. |
| "minimal still imports the developer foundation" | ✅ **Confirmed, and it's the root blocker.** [`modules/default.nix`](nebelhaus/modules/default.nix) unconditionally imports `den`+`theme`+`hearth`+`collar`+`secrets`+`snippets`. Turning off all three optional rooms still installs `bun`, `fnm`, `nixfmt`, `opencode`, `zellij`, `yazi`, `lazygit`, `delta`, `gh`, `jq`, `ttyd`, `wt`, `zscratch`, and a git-alias vocabulary. |

**Two mechanisms already in the repo that the brainstorm missed, and that change the plan:**

1. **Machine-writable config already works.** `mkNebelhaus` auto-imports every
   `.nix` in `hosts/<host>/packages/` ([`flake.nix:76-95`](nebelhaus/flake.nix:76)) —
   that's how pounce's "Install App" command writes config without a parallel
   JSON store. **This is the mechanism for a GUI-editable rice** (§3.7). It
   exists; it just needs generalizing past packages.
2. **`nebelhaus.apps` merging means an app pack is shareable *today*.** A file
   that only sets `nebelhaus.apps.*` composes cleanly across modules. That's a
   zero-architecture v0 of the community (§6, Phase 0).

---

## 2. The reframe

The current options expose **implementation** (Pounce, Sill, AeroSpace, Homebrew).
Community rices want to express **intent**:

- "Make everything easier to see."
- "I use a mouse and hate keyboard launchers."
- "This is a quiet writing machine."
- "This Mac lives docked to two displays."
- "Make this usable by my parents without ever showing them a terminal."

Every option below is judged by: *does it move a rice from the first vocabulary
to the second?*

---

## 3. Structural blockers — land these before adding breadth

Adding 60 options on top of today's structure makes the next refactor 3× worse.
These four are cheap now and expensive later.

### 3.1 Split `options.nix` per room · ✅ **DONE** (nebelhaus#92)
656 lines in one file for every room. Move to `modules/<room>/options.nix`,
keep `modules/options.nix` as the cross-cutting/identity file. Purely
mechanical, no behaviour change. **Do this first or everything else compounds.**

- [x] `modules/{den,hearth,prowl,sill,pounce,hush,theme,trill,secrets,snippets}/options.nix`
- [x] `modules/options.nix` keeps `apps` + `developer` (752 → 122 lines). `git`/`claude` went to hearth, which owns them.
- [x] Verified as a pure move: the example host's derivation is byte-identical and all 39 leaf option paths are unchanged.

### 3.2 Make `developer` a real pack, not the foundation · ✅ **DONE** (nebelhaus#96)
The single highest-leverage change in this doc. Today "minimal" is a lie.

```nix
nebelhaus.developer = {
  enable = true;          # the whole dev pack — off means a non-dev Mac
  shell.toolbelt = true;  # bat/delta/lazygit/lsd/fzf/zoxide/yazi
  multiplexer = "zellij"; # zellij | none
  agents.enable = true;   # wt, zscratch, claude statusline, worktree binds
  git.enable = true;      # aliases, delta, lazygit, signing
  languages = [ "node" ]; # fnm/bun; extensible
};
```

- [x] Audited hearth and den; gated packages, `programs.*`, aliases, the fnm hook, Claude settings and nix-index
- [x] Gated `home.packages` and `environment.systemPackages`
- [x] `haus` / `awake` / `mas` / theme stay unconditional (they're the *product*)
- [x] Proved by measurement: `developer.enable = false` drops 16 system + 17 home packages.
      **Not literally zero** — `gh`/`blueutil`/`switchaudio-osx` remain as pounce
      command-plugin deps, which is correct while pounce is on.

**Non-obvious consequence:** with dev off, `hearth.editor = "hx"` is the wrong
default and Ghostty may not even be wanted. Decide what a non-dev nebelhaus
*terminal story* is (probably: no terminal at all, and `haus` reached only via
pounce).

### 3.3 Presets become the community format, from day one · ✅ **DONE** (nebelhaus#98)
The earlier plan put "define the community rice format" at step 9. Invert it.
Make the repo's own presets use the exact mechanism a stranger's rice would —
otherwise you'll build eight layers and discover the format can't express them.

- [x] `presets/{full,minimal,everyday}.nix` — each sets **only** `nebelhaus.*`.
      `large-print` deferred: it needs §5.1/§5.2/§5.3, which don't exist yet.
- [x] `bootstrap.sh` offers Everyday and emits `extraModules = [ nebelhaus.presets.X ]` —
      the same line a person writes to import a rice found online. "Custom" emits none.
- [x] `nix flake check` runs `checkRice` over every preset **and** evaluates a real
      system with each — trust half and usefulness half
- [x] `nebelhaus.lib.checkRice` exposed, with `presets/README.md` defining the format

### 3.4 Generate the options reference · ✅ **DONE** (nebelhaus#93 + workshop#81)
[`web/src/content/docs/reference/options.md`](web/src/content/docs/reference/options.md)
is 389 hand-written lines. At 5× the surface it rots within a month.

- [x] `nix build .#options-json` → `web/scripts/gen-options.mjs` → the page
- [x] Narrative guides stay hand-written; only the reference is generated
- [x] `options-drift.yml` fails if the page is stale.
- [x] Found on the way: the old page documented `git.shellAliases` **twice** with
      two different descriptions, and covered 33 of 71 options.

---

## 4. Spikes — ✅ RUN 2026-07-25, results in [`macos-settings-matrix.md`](macos-settings-matrix.md)

Run on macOS 26.6 with an `NSWorkspace` effective-state probe (a plist read only
proves the *file* changed). Every domain exported before and byte-compared
after — zero net change to the machine.

**They invalidated part of §5.12 and §5.2, and de-risked §5.10.**

- [x] **`com.apple.universalaccess` writability** → ❌ **hard-locked on 26.6.**
      `Could not write domain`. Control: `dock`/`finder`/`screencapture`/
      `Accessibility` all accept the identical write from the same shell, so
      it's the domain, not a sandbox. **All 5 of nix-darwin's
      `system.defaults.universalaccess.*` options are in that domain.**
- [x] **Is there another backend?** → `com.apple.Accessibility` *is* writable and
      holds the modern keys — but writes are a **silent no-op**: plist flips,
      `NSWorkspace` effective state does not. Worst possible failure mode for a
      shared rice: it reports success and does nothing.
- [x] **Restart behaviour** → nix-darwin restarts **only Dock**, only when a
      `dock` option changed, and never calls `activateSettings`. Finder /
      WindowManager / ControlCenter changes silently wait for a logout. **The
      rice must own a restart map.**
- [x] **Display scaling** → ✅ **de-risked.** `displayplacer` isn't even in
      nixpkgs, but public CoreGraphics covers it: a **persistent display UUID**
      exists (`CGDisplayCreateUUIDFromDisplayID`), 9 distinct HiDPI "looks-like"
      modes are enumerable, and `CGDisplaySetDisplayMode` is public API. A ~40-line
      Swift helper replaces the Homebrew dependency. Stable-ID risk retired.
- [x] **Typed surface** → **193** keys, not "several hundred".
- [x] **Does root punch through?** → ⚠️ **The question was wrong.** A real
      `haus rebuild` did fail from root — but it's **Full Disk Access on the app
      responsible for the rebuild**, not euid, that gates the domain. Every
      command in the spike ran under Claude.app, which lacks FDA, so the whole
      chain lacked it. An earlier revision of this doc concluded "locked even as
      root"; **that was wrong** and is retracted in the matrix.
      → ✅ **Positive case now measured** (Ghostty + FDA, 2026-07-25):
      `reduceMotion` **writes and takes effect** — `motion_reduced=true`. So
      `system.defaults.universalaccess.*` is real on 26, gated on FDA.
      → ⚠️ **Asymmetry that matters here:** the grant is on the *responsible
      app*. Ghostty has FDA; Claude Code does not. Set one of these and Julien's
      own rebuilds work while **every agent rebuild aborts activation partway** —
      "works on my machine" in the most literal sense.
- [x] **The blast radius holds regardless.** That write is emitted *unguarded*
      into an activation script running under `set -e`, at line 559 of 877. So
      *whenever it fails* — missing FDA being the common way — activation
      **aborts** and skips every later step, including all launchd daemon/agent
      setup. The symptom lands nowhere near the cause.
      → nebelhaus **warns** (nebelhaus#89 — a warning, not an assertion: with FDA
      these work, so blocking would be wrong), and it's reported on
      [nix-darwin#1049](https://github.com/nix-darwin/nix-darwin/issues/1049).

---

## 5. The option families, ranked

Ranked by *(unlocks a genuinely different rice) ÷ (effort)*.

### 5.1 `nebelhaus.theme` — break out of the Mocha-grey monopoly · L · risk M · ◐ **contrast half shipped**
**★ Biggest miss in the earlier brainstorm.** `theme.accent` is an enum of 14
Catppuccin Mocha names; the base palette is always Nebelung grey-dark
([`options.nix:335`](nebelhaus/modules/options.nix:335)). So:

- There is **no light mode** anywhere in the rice.
- There is **no high-contrast mode** — the root requirement for the
  "old people" rice that started this whole thread. **(✅ shipped — see boxes.)**
- A community rice cannot ship its own colours at all.

Nebelung is whiskers-based, so it can render *any* palette — the ceiling is
the option surface, not the renderer.

```nix
nebelhaus.theme = {
  flavor  = "mocha";        # mocha | latte | high-contrast-dark | high-contrast-light | custom
  scheme  = "auto";         # light | dark | auto (follows macOS appearance)
  palette = null;           # attrs of name → hex, for flavor = "custom"
  accent  = "mauve";
  contrast = "normal";      # normal | high  — a WCAG-checked palette transform
};
```

- [ ] nebelung: parameterize the flavor, not just the accent — ◐ **partial**: the
      high-contrast **variant** shipped (`palette/nebelung-high-contrast.json`, rendered
      across ~20 tools), but `flavor` proper (latte / light) is still open.
- [x] nebelung: a contrast-boost transform with a contrast-ratio assertion in CI
      — **nebelung#11**: OKLCH neutral-ramp transform + `test/palette.test.mjs`.
- [x] rice: honest scope — which tools follow `flavor` vs bake their own
      — **rice#103**: `theme.contrast = normal | high`; the option description names what
      it recolours (Ghostty/bat/…/Zen) vs what bakes its own (pounce, macOS).
- [ ] `scheme = "auto"` needs a runtime appearance watcher (sill can host it)
- [ ] ✅ **Pair `contrast = "high"` with the OS lever.** The sweep proved
      `increaseContrast` (and `differentiateWithoutColor`) write *and take
      effect* — and neither is typed by nix-darwin, so they're reachable today
      via `system.defaults.CustomUserPreferences."com.apple.universalaccess"`,
      no upstream change needed. That makes a high-contrast rice cover *native*
      apps too, not just the tools nebelung themes — the missing half.
      Carries the FDA caveat (§5.12), so it must degrade cleanly: the palette
      side works for everyone, the OS side sharpens it when FDA is granted.

### 5.2 `nebelhaus.ui` — semantic scale tokens · M · risk M
The missing abstraction. One set of tokens, fanned out with `mkDefault` into
every room, so a rice says "spacious" once instead of tuning nine numbers.

```nix
nebelhaus.ui = {
  scale = 1.35;            # 1.0 = today
  density = "spacious";    # compact | comfortable | spacious
  motion = "reduced";      # full | reduced | none
};
```

Fans out to: Dock icon size · Finder icon/sidebar size · Sill height/padding/
font/icon size · Pounce window width, row height, result count · Ghostty font
size + line height · zellij bar density · prowl gaps and borders · wallpaper
contrast.

- [ ] Every consumer reads `ui.*` through `mkDefault` so a host can still pin one number
- [ ] `motion = "none"` is **ours to implement** — kill prowl's animations and
      Sill's transitions directly. The macOS reduce-motion knob is locked
      (§4), so there is nothing to delegate to.
- [ ] ~~`cursorScale`~~ **cut** — `mouseDriverCursorSize` is in the locked
      `universalaccess` domain. Cursor size is `haus doctor` checklist only.
- [ ] **Honest scope line:** this changes *nebelhaus's own* UI reliably and Dock/
      Finder sizes reliably. System-wide text size is reachable **only** via
      display mode (§5.10) — macOS 26's per-app `FontSizeCategory` is locked.

### 5.3 `nebelhaus.fonts` · S · risk L
**Cheapest big win in the doc, and nobody has asked for it because it's
invisible until you try to change it.** JetBrains Mono Nerd Font is hardcoded in
[`den:125`](nebelhaus/modules/den/default.nix:125); Ghostty's size is hardcoded in hearth.

```nix
nebelhaus.fonts = {
  mono = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font"; size = 14; };
  sans = { name = "SF Pro"; };              # e.g. "Atkinson Hyperlegible" for large-print
  extraPackages = [ ];
};
```

- [ ] Assert the mono font is a Nerd Font (or warn loudly) — starship/lsd/yazi tofu otherwise
- [ ] `ui.scale` multiplies `fonts.*.size` by default

### 5.4 `nebelhaus.apps` v2 — install sources + a real workspace model · M · risk M
The registry is good. Two concrete gaps:

**(a) `cask` is the only install source.** Make it a tagged union:

```nix
install = { source = "homebrew-cask"; package = "obsidian"; };
# nix-package | homebrew-cask | homebrew-formula | mas | builtin | flake | pwa | manual
```
`mas` is already in `systemPackages` and unused by the registry — free win.

**(b) `workspace` is a *field on an app*, which bakes "one app per workspace"
into the schema itself.** Role workspaces ("communication" = Mail + Slack +
Messages) and project workspaces are literally unrepresentable. Invert it:

```nix
nebelhaus.workspaces.comms = {
  key = "c"; icon = ":slack:"; monitor = "main"; layout = "tiles";
  apps = [ "slack" "mail" "messages" ];
};
```
…with `apps.<id>.workspace` kept as sugar that desugars into the above, so
existing hosts don't break.

- [ ] Tagged-union `install`
- [ ] First-class `workspaces`, `apps.*.workspace` becomes a back-compat alias
- [ ] Window rules beyond assignment: `float`, `center`, `sticky`, title/role matchers
- [ ] Non-app installables the registry can't express: fonts, browser extensions,
      Quick Look / Finder / Share extensions, printers, network shares, VSTs

### 5.5 `nebelhaus.keys` — the keymap is currently closed · M · risk M
Caps-Lock leader, ⌘Space, and every zellij bind are generated or baked. This
single-handedly makes **mouse-first**, **one-handed**, and **non-QWERTY /
international layout** rices impossible — a real accessibility *and*
internationalization gap the earlier brainstorm didn't name.

```nix
nebelhaus.keys = {
  leader = "caps";           # caps | hyper | none  (none = mouse-first rice)
  palette = "cmd-space";     # or "none" to keep Spotlight
  windowNav = "alt";         # the modifier vocabulary, not individual binds
  bindings = { };            # per-action overrides
};
```

- [ ] Split `prowl.enable` into `prowl.tiling.enable` / `prowl.launcher.enable` /
      `prowl.capsRemap.enable` — today they're one switch
- [ ] Assertion on duplicate leader letters *and* cross-room conflicts
      (currently a duplicate `apps.*.key` silently loses)
- [ ] Ship the generated cheatsheet from the same data (it already half-does this)

### 5.6 Curate macOS settings into behaviour groups · M · risk M (gated on §4)
Do **not** mirror every nix-darwin default into `nebelhaus.*`; `system.defaults`
stays the escape hatch. Curate the groups where a *rice* has an opinion:

| Group | Notable gaps today |
|---|---|
| **Hot corners** | `dock.wvous-*` is typed by nix-darwin and the rice sets **none** — zero-risk, very ricer-y, ship it early |
| **Screenshots** | folder, format, shadow, thumbnail — pure quality-of-life, all typed |
| **Lock / login / screensaver** | idle lock delay, login window text, screensaver — matters for family + public-machine rices |
| **Menu bar & Control Center** | clock format, seconds, battery %, Focus, Now Playing (only relevant when `sill.enable = false`) |
| **Sound** | alert sound, volume feedback, startup chime (`nvram StartupMute`) — the whole audio layer is untouched |
| **Locale / input sources** | language, keyboard layouts, 12/24h, units, first day of week — **blocks every non-English community rice entirely** |
| **Power** | battery vs charger sleep, Low Power Mode, lid/docked behaviour |
| **Security posture** | firewall, guest user, remote login, AirDrop — the "public Wi-Fi" rice |
| **Windows** | Stage Manager, native tiling, edge drag (must interlock with prowl) |

Each entry carries metadata from the §4 matrix:

```nix
{ domain = "com.apple.finder"; key = "FXDefaultSearchScope"; value = "SCcf";
  restart = [ "Finder" ]; support = "tested-macos-26"; risk = "low"; }
```

### 5.7 `haus set` + a machine-writable settings overlay · M · risk M
**The mechanism that makes a non-technical rice possible**, and it's a small
generalization of something that already ships.

`hosts/<host>/packages/*.nix` is already auto-imported and already written by a
pounce command. Extend that to a general `hosts/<host>/settings/*.nix`, and:

- [ ] `haus set theme.accent teal` → writes one small ordinary Nix file → rebuild
- [ ] `haus get` / `haus unset` / `haus reset <path>`
- [ ] Pounce commands wrapping it: **"Make text bigger"**, "Switch to light mode",
      "High contrast on" — the palette becomes the settings app
- [ ] Guard: only `nebelhaus.*` paths are settable this way (same boundary as §3.3)

This is what lets someone use a nebelhaus rice for a year without ever opening
a text editor — the actual bar for "a Mac for my parents".

### 5.8 Generalize `hush` into scenes · M · risk M
`hush` is already a scene with one member: it has hooks, an external
integration (Slack), a bar pill, a CLI, and transient state. Generalize rather
than invent:

```nix
nebelhaus.scenes.recording = {
  dnd = true; preventSleep = true;
  audio.input = "Studio Mic";
  apps.open = [ "OBS" ];
  hooks = [ ./key-light-on.sh ];
  restorePreviousState = true;
};
```
with `hush` shipped as the built-in `quiet` scene (keep `nebelhaus.hush.*` as
an alias so no host breaks).

Good scenes: meeting · recording · presentation · reading · travel · docked ·
deep-work · away. Triggers worth having: Pounce command, time, Wi-Fi SSID,
power source, display attach.

- [ ] Only build the trigger engine *after* one hand-written scene proves useful —
      the declarative half is cheap, the trigger daemon is not

### 5.9 Open up Sill widgets and Pounce commands · M · risk M
`sill.items` is a closed submodule of 13 bools; Pounce commands are
script-discovery only, with **no Nix option at all**.

```nix
nebelhaus.sill.widgets.backup = {
  command = ./backup-status.sh; interval = 300;
  icon = "󰁯"; placement = "right"; permissions = [ "full-disk-access" ];
};

nebelhaus.pounce.commands.callAnna = {
  name = "Call Anna"; run = "open facetime://+15550100";
  mutates = false; needsConfirm = false;
};
nebelhaus.pounce.packs = [ "everyday" "people" ];   # vs the dev pack
```

Non-dev widget ideas the current set has no room for: Time Machine health ·
mic/camera-in-use · VPN state · Bluetooth device battery · next reminder ·
break timer · storage pressure · NAS reachability · world clocks.

- [ ] `sill.items` becomes sugar over `sill.widgets` (bundled widgets pre-declared)
- [ ] Pounce command packs, with the *dev* commands moved into an opt-in pack
- [ ] Commands declare: mutates state? needs confirm? needs network/permission?

### 5.10 `nebelhaus.displays` — **promoted: this is now the large-print rice** · M · risk M
The spike de-risked this and the accessibility spike gutted its alternative, so
it moves up sharply. It is the **only** working path to "make everything bigger"
on macOS 26. Don't expose `1920×1200`; expose intent:

```nix
nebelhaus.displays.internal.uiScale = "larger-text";
# more-space | default | larger-text | largest-text
```

- [x] Persistent display UUID exists → key profiles by UUID, not index
- [x] `CGDisplaySetDisplayMode` is public API → ship a small Swift helper,
      **no `displayplacer` / Homebrew dependency** (it isn't in nixpkgs anyway)
- [ ] Helper must dedupe modes by point size (they repeat ~6× across refresh
      rate × colour depth) and prefer the highest refresh
- [ ] Still untested: *applying* a mode, and multi-display arrangement (only one
      display was attached). Test on the dock before designing `profiles.docked`

### 5.11 Reversibility — the trust prerequisite for *any* community · M · risk M
Before strangers' configs run arbitrary `defaults write` and activation scripts:

- [ ] `haus plan` — promote bootstrap's preflight audit; show exact settings,
      packages, and scripts that will change
- [ ] `haus capture` — promote the `NEBELHAUS_KEEP` current-value reader into a
      general "turn this Mac into config" command
- [ ] `haus diff` — declared vs live
- [ ] `haus revert-settings` — restore the pre-activation preference snapshot
      (the installer already admits Nix rollback doesn't undo macOS defaults)
- [ ] `haus doctor` grows a permission checklist with System Settings deep links
- [ ] Restart/logout/reboot annotations from the §4 matrix

### 5.12 Accessibility — ✅ **back on the table, with an FDA caveat** · M
Twice-corrected. It's buildable: `universalaccess` writes and takes effect —
**if the app invoking the rebuild holds Full Disk Access**. So the option tree is
viable, but the caveat is load-bearing and has to be designed *into* it.

- [ ] Model these as **`reachability = "needs-fda"`** options (§5.6's designation
      scheme), not as ordinary settings. A rice that silently behaves differently
      on two machines is exactly the failure a shared-rice format must not have.
- [ ] `haus doctor` should **detect** FDA (strict read of an FDA-gated path — no
      `ls` fallback, that bug cost a whole spike) and say plainly whether the
      accessibility half of the current config can apply at all.
- [ ] **Do not** add options that write `com.apple.Accessibility` — that domain
      writes and does nothing. Still true, still the worst failure mode.
- [ ] ⚠️ **Agent asymmetry:** Claude Code lacks FDA, Ghostty has it. Any of these
      options set in a host makes agent-driven `haus rebuild` abort activation
      while manual rebuilds succeed. Whatever `haus doctor` says, this needs to be
      impossible to hit by accident — it's the sharpest edge in the whole set.
- [x] Swept 2026-07-25. **`increaseContrast` and `differentiateWithoutColor`
      write and take effect**, and neither is nix-darwin-typed → reach them via
      `CustomUserPreferences`. `increaseContrast` is the OS-level half of the
      high-contrast rice (§5.1), available with no upstream change.
- [ ] `mouseDriverCursorSize` / `closeView*` persist but their **effect is
      unconfirmed** — no oracle exists, so they need an eyeball before
      `ui.cursorScale` comes back.
- [x] **`FontSizeCategory` resolved, and it's narrower than hoped.** Real
      vocabulary is `DEFAULT` / `AX1`… (read back after setting Text size in
      System Settings — my earlier `LARGE` guess would have been stored and
      ignored). But it only affects apps that adopted Dynamic Type — a short
      all-Apple list (Mail, Messages, Notes, Calendar, Finder, Reminders,
      Books, News, Stocks, Weather, Journal, Magnifier). With `AX1` live, a
      non-participant still reports 13pt body text.
      → ❌ **And it is not declarable at all.** Writing it lands in the plist but
      posts no change notification: running apps never re-read it, and System
      Settings renders a desynced view of its own rows. Only dragging the slider
      by hand works. An option backed by this ships a Mac where Settings says
      20 pt, every app renders 13 pt, and the pane looks broken. **Don't wire it.**
      → **Heuristic:** in this domain the **scalar** keys work and notify; the
      **structured** (dict) one lands and lies. Treat dict-valued accessibility
      keys as GUI-only until proven otherwise.

**But the large-print rice still shouldn't be built on it.** Display mode
(§5.10), fonts (§5.3), `ui.*` tokens (§5.2), a high-contrast flavor (§5.1) and
Dock/Finder sizes work for everyone, unconditionally. Treat `universalaccess` as
a **bonus layer** that sharpens the result when FDA happens to be granted — never
as the foundation. That ranking survived all three revisions of this finding,
which is the main argument for it.

### 5.13 Authorable tour steps · S · risk L
Small, and **nobody else can ship this**. `tour.enable` teaches the four moves
of *this* rice. A community rice teaches its own:

```nix
nebelhaus.tour.steps = [
  { hint = "Press ⌘Space to find anything"; detect = "pounce-opened"; }
];
```
The detection signals already exist (the leader-mode scripts). This is the
difference between downloading someone's config and *learning* it.

---

## 6. Phasing

**Phase 0 — ship this week, no architecture required**
- [x] `nebelhaus.fonts` (§5.3) — nebelhaus#91. Turned up a real bug on the way:
      sill named `Hack Nerd Font` in seven places and **nothing installed it**,
      so every fresh install had been drawing tofu across the whole bar.
- [ ] Publish one shareable **app pack** `.nix` (only sets `nebelhaus.apps.*`) and
      a short guide. Now cheaper than when this was written — `presets/README.md`
      already defines the data-only format an app pack would use.
- [ ] Hot corners + screenshot settings (§5.6) — typed, reversible, instantly felt

**Phase 1 — structure (blocks everything else)** ✅ **done 2026-07-26**
- [x] §3.1 split options (nebelhaus#92) — 752 → 122 lines, byte-identical derivation
- [x] §3.2 `developer.enable` (nebelhaus#96) — "minimal" is no longer a lie
- [x] §3.3 presets-as-format (nebelhaus#98) — `checkRice` + `nix flake check`
- [x] §3.4 generated docs (nebelhaus#93 + workshop#81) — page rendered from the module system

  Worth recording: **§3.1 paid for §3.4 immediately.** Splitting options into
  pure `{ lib, ... }` modules is what let the docs generator evaluate them
  standalone on Linux CI, with no darwin system. That dependency wasn't
  predicted here — it's now a comment in the flake, because it's load-bearing
  and its failure mode (docs CI breaks) points nowhere near its cause.

**Phase 2 — know what's possible** ✅ **done 2026-07-25**
- [x] §4 spikes → [`macos-settings-matrix.md`](macos-settings-matrix.md)
- [x] `universalaccess` confirmed dead via a real `darwin-rebuild` — fails as
      root, and aborts activation when set
- [x] Guardrail shipped: nebelhaus **warns** when `system.defaults.universalaccess.*`
      is set (nebelhaus#89), and it's reported upstream on nix-darwin#1049.
- [x] **Positive case settled** (Ghostty + FDA): `reduceMotion` writes *and*
      takes effect. The sweep then proved `reduceTransparency`,
      `increaseContrast` and `differentiateWithoutColor` too — the last two
      aren't nix-darwin-typed, so they ship via `CustomUserPreferences`
      (nebelhaus#90) and give §5.1 an OS-level high-contrast lever.
- [x] `FontSizeCategory` resolved and **rejected**: writes land but post no
      change notification, so apps never re-read them and System Settings
      renders a desynced view. Third member of the write-that-lies family.

**Phase 3 — the expression layer** *(the spike raised this phase's priority: it's
everything macOS can't veto)*
- [ ] §5.1 theme flavors · §5.2 `ui.*` tokens · §5.5 `keys.*` · §5.4 apps v2 + workspaces
- [x] §5.3 fonts (nebelhaus#91)
- [ ] §5.10 displays — **promoted from Phase 5**; the only working "make it bigger" lever

**Phase 4 — the non-dev Mac**
- [ ] §5.7 `haus set` · §5.9 pounce packs + sill widgets · §5.6 curated settings groups
- [ ] the restart map (§4) — nix-darwin only restarts Dock, so this is ours

**Phase 5 — trust and breadth**
- [ ] §5.11 plan/capture/diff/revert — **`diff` must compare effective state, not
      plists**; a plist-only diff would have called both no-op writes "applied"
- [ ] §5.8 scenes · §5.13 tour steps · §5.12 accessibility doctor checklist

**The readiness test:** three reference rices that are deliberately far apart —
today's developer rice, `large-print` + `everyday`, and a mouse-first
writer/creative setup — each expressible **without reaching around
`nebelhaus.*` even once.**

Scoreboard: `full` and `everyday` now exist and pass (`nix flake check` proves
they touch nothing outside `nebelhaus.*`). `large-print` is the next one, and it
is blocked on §5.1/§5.2/§5.3 — deliberately not faked with a `system.defaults`
escape hatch, because doing so would make the test meaningless. If any needs a raw `system.defaults` or a
hand-written activation script, the model isn't ready.

---

## 7. Repo routing

Per the workshop's routing table, this work is **not** one repo:

| Work | Repo |
|---|---|
| every `nebelhaus.*` option, `developer.enable`, presets, `haus` | `nebelhaus` |
| theme flavors, light mode, high-contrast palette, contrast CI | `nebelung` |
| command packs, typed commands, palette-as-settings-app | `pounce` |
| generated options reference, community rice gallery | `web` |

Breaking option renames (e.g. `apps.*.workspace` → `workspaces`) couple a
consumer lock-bump and a config edit into one PR — `bench ship` can't split
them without breaking main mid-ripple.

---

## 8. Naming (optional, low stakes)

The family speaks cat-and-house (`nebelung`, `pounce`, `prowl`, `sill`, `den`,
`hearth`, `collar`, `hush`, `trill`, `perch`, `haus`, `wt`). New rooms could
keep it:

| Room | Candidate | Why |
|---|---|---|
| accessibility — vision | `eyes` | cats' defining sense; `nebelhaus-ears.png` already exists in sill |
| accessibility — motor | `paws` | |
| accessibility — hearing | `ears` | |
| keymap | `claws` | what the leader key is |
| displays / multi-monitor | `perch` | where the cat sits and looks out |
| scenes | `moods` | the states the cat is in; `hush` becomes one |
| dev pack extracted from hearth | `quarry` / `kit` | weakest of the set — probably just call it `developer` |

Not a blocker. `nebelhaus.accessibility.vision.*` is clearer to a stranger than
`nebelhaus.eyes.*`, and strangers are the point.
