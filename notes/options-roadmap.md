# Option-surface roadmap — from "Julien's dev rice" to a shareable rice format

Working doc. The end goal: people publish **nebelhaus configs** of wildly
different kinds — a large-print Mac for a parent, a writer's machine, a
mouse-first creative setup — by changing `nebelhaus.*` and nothing else. When
this was written the option surface could express none of them; `full`,
`everyday` and `large-print` now all pass the readiness test in §6, and what's
left is tracked against it there. (Passing is not finishing — §6 records the two
limits `large-print` exposed, which are the most useful findings in this doc.)

This refines an earlier brainstorm against what's actually in the repos as of
2026-07-25. Read §1 first — several things the brainstorm proposed building
already exist, and one it treated as a detail is the actual root blocker.

> **Status, 2026-07-30.** §3 (structure) and §4 (spikes) are **done**, Phase 3 is
> mostly done, and all three reference rices pass the readiness test (§6).
>
> What moved since the last pass is **pounce**, and it moved somewhere this doc
> didn't predict. The palette reads its theme from **runtime files** now
> (pounce#37 + rice#139), follows macOS Light/Dark **by itself** (pounce#42 +
> rice#142, `pounce.followSystemAppearance`), and has a **per-item settings
> schema** keyed by frecency key (pounce#43) — which is the action vocabulary
> §5.5 said `bindings` was waiting for. Two consequences worth carrying: pounce
> is no longer on the "bakes its own colours" side of §5.1's honest-scope line,
> and `scheme = "auto"` now has one shipped implementation to copy rather than a
> design.
>
> Alongside it, **`theme.ports.enable`** (rice#136 + nebelung#17/#18/#19) themes
> the apps in your roster from **port metadata** — so §5.6's "each setting carries
> a reachability designation" idea now ships as data for 53 ports, in a different
> room than the one that proposed it.
>
> **Still open, in this order:** pounce/sill **sizing** (§5.2, which the theming
> work did *not* touch) · §5.4 apps v2 (the schema migration, deliberately last).
> §5.10 displays shipped in rice#147 and the rice-side pounce options in rice#149;
> displays still wants a docked multi-monitor proof before growing profiles, but
> that validation no longer blocks `large-print`.
>
> **Earlier history.** §3's four items landed as nebelhaus#92/#96/#98/#93 +
> workshop#81 and the macOS spikes settled in the matrix; fonts (#91), the two
> working accessibility keys (#90), `ui.scale` (§5.2), the contrast axis
> (nebelung#11 + rice#103), light mode (nebelung#12 + rice#108) and `keys.*`
> (#108, which also ships `presets/large-print.nix`) are all in. Read §6's
> scoreboard and the two limits `large-print` exposed before celebrating.

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

### 5.1 `nebelhaus.theme` — break out of the Mocha-grey monopoly · L · risk M · ✅ **flavor + contrast + roster ports shipped**
**★ Biggest miss in the earlier brainstorm.** `theme.accent` is an enum of 14
Catppuccin Mocha names; the base palette is always Nebelung grey-dark
([`options.nix:335`](nebelhaus/modules/options.nix:335)). So:

- ~~There is **no light mode** anywhere in the rice.~~ **(✅ shipped — nebelung#12
  + nebelhaus#108: `theme.flavor = "latte"`.)**
- There is **no high-contrast mode** — the root requirement for the
  "old people" rice that started this whole thread. **(✅ shipped — see boxes.)**
- A community rice cannot ship its own colours at all. **(still true: `palette`
  for `flavor = "custom"` is not built. A rice can pick a flavor, not supply one.)**

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

- [x] nebelung: parameterize the flavor, not just the accent — **nebelung#12**.
      Four variants now: the flavor axis (mocha = dark, latte = light) crossed with
      contrast. Light mode is a different **source palette**, not a transform of the
      dark one, which is what the "point the same two rules at Latte" framing buys —
      and there's a test that fails if anyone later reimplements it as an inverted
      ramp. Plain latte lands at 7.0:1 for body text on its own, so
      `contrast = "high"` (9.9:1) is a sharpening rather than a rescue.

      Two findings worth keeping, both now asserted rather than commented:
      **(a)** each variant has to render as **its own catppuccin flavor**
      (`whiskers -f latte`) — templates branch on `flavor.dark` (Ghostty's ANSI
      0/7/8/15, Kitty's tab colours, Zen's `prefers-color-scheme`, delta's
      `light = true`) and name their output after it, so a latte palette rendered
      `-f mocha` emits light colours wearing dark-mode structure under mocha's
      filenames. **(b)** the two contrast boosts **must differ**: a boost pushes the
      ramp out from its midpoint, and Mocha has ~0.2 of OKLCH headroom below `base`
      where Latte has ~0.04 above its, so Mocha's 0.35 melts Latte's
      base/mantle/crust into one white. Mutation-checked — forcing them equal fails
      the ramp-collapse test.
- [x] rice: the flavor is in the **paths**, not just the colours — **nebelhaus#108**.
      whiskers names its output after the rendered flavor, so `latte` moves ghostty,
      bat, lsd, yazi, zen and zsh-syntax-highlighting filenames as well as hexes.
      The subtlest one: delta's single gitconfig carries **all four** flavor
      sections and only the rendered one holds Nebelung colours, so `features` must
      name the same flavor as the include's root or delta silently themes itself
      stock. Selection is factored into `modules/lib/nebelung.nix` (it had been
      duplicated in hearth/sill/theme; a second axis would have made that six
      blocks) and `nix flake check`'s new `theme-variants` pins the
      flavor/contrast → variant/subdir table as a golden file, because that rule
      mirrors nebelung's `variantDir` across a repo boundary and its failure mode is
      **silent** — a wrong subdir is just a store path that doesn't exist, found at
      activation rather than eval.
- [x] nebelung: a contrast-boost transform with a contrast-ratio assertion in CI
      — **nebelung#11**: OKLCH neutral-ramp transform + `test/palette.test.mjs`.
- [x] rice: honest scope — which tools follow `flavor` vs bake their own
      — **rice#103**: `theme.contrast = normal | high`; the option description names what
      it recolours (Ghostty/bat/…/Zen) vs what bakes its own (pounce, macOS).
      **Half-superseded 2026-07-29: pounce came off that list** (see the two boxes
      below). What's left on the "does not follow" side is macOS's own appearance
      and the three hand-made wallpapers — a much better place for the line to sit,
      because both of those are honestly *not ours*, whereas pounce baking its own
      was only ever a limitation of how it was built.
- [x] ✅ **Felt on the real machine, 2026-07-27: 19.9:1 reads CRISP, not harsh.**
      That was the one open question a ratio couldn't answer, and it's the answer
      the high-contrast axis needed before anything could be built on it — so
      `large-print` shipping with `contrast = "high"` is now a felt choice rather
      than a measured guess. Worth recording because the doubt was reasonable:
      AAA-on-paper palettes routinely read as glare.
- [x] ✅ **Latte felt on the real machine, 2026-07-28: reads great.** Flipped
      `theme.flavor = "latte"` on mbp with macOS appearance set to Light, one
      `bench try switch`, and the whole hearth/sill/Zen surface came over — so light
      mode is a felt option now, not just a rendered one.
- [ ] ◐ `scheme = "auto"` — **one consumer shipped it, and it wasn't the one this
      box expected.** No sill-hosted watcher was needed: pounce#42 + rice#142 give the
      palette `theme`/`themeLight` and it picks per open, exposed as
      `nebelhaus.pounce.followSystemAppearance` (default **true**). Three things
      that generalise:
      **(a)** the unit that follows appearance is a *tool*, not the rice — anything
      that can re-read a palette at draw time can opt in on its own, and only tools
      that can't need a watcher;
      **(b)** it needed the **runtime-file seam first** (pounce#37 + rice#139 install
      every rendered variant into `~/.config/pounce/themes/`), so "follow the system"
      turned out to be a cheap consequence of "stop baking the palette into the
      binary" — which is the actual reusable move;
      **(c)** it forced a real product decision into the option: a `flavor` pin is a
      *palette* choice, but asking to follow the system says the *polarity* is
      macOS's call, so the two can't both win. The rice resolves it by letting
      `contrast` reach both halves while `flavor` reaches neither.
      Still open: **ghostty**, the other tool that can switch on appearance. Its
      config used to read `theme = dark:nebelung,light:Catppuccin Latte` — i.e. it
      already followed macOS appearance and fell back to **stock** Catppuccin in
      light mode, so a Mac on light appearance never got the Nebelung palette. #108
      collapsed that to a single `theme = nebelung` decided by `theme.flavor`;
      bringing the split back with Nebelung on both sides is now a two-line change
      plus the same policy question (c) already answered, so it should reuse
      `followSystemAppearance`'s shape rather than invent `scheme` as a third axis.
      **Decide before building:** whether `scheme = "auto"` is a rice-wide option at
      all, or just the name for "every appearance-capable tool follows the system",
      which is what shipping it per-tool has quietly made it.
- [x] `theme.ports.enable` — **roster apps theme themselves, from metadata**
      (rice#136 + nebelung#17/#18/#19). Nebelung went 21 → 53 ports and now ships
      `ports.meta.json` describing each one: `dest`, `install`
      (copy 42 / paste 5 / merge 5 / compile 1), how the theme is *selected*, and a
      `tier`. The rice reads that and drops the theme file for any app in
      `nebelhaus.apps` it has a port for, in your flavor+contrast, on every rebuild.
      Why it matters beyond theming: **this is §5.6's `reachability` designation,
      shipped as data** — the option promises the *file*, not the *effect*, because
      the metadata knows Ghostty reads a config key we own while Xcode/Warp/OBS need
      one human click, and `haus doctor` lists exactly who is waiting on it. Ports
      whose install is a merge or needs a compile are **reported, never written**.
      Two lessons: a designation scheme is worth more when it lives with the thing
      it describes (nebelung, not the rice) than when the consumer maintains a table,
      and `theme.ports.handled` — rooms declaring what they already wire by hand,
      with an assertion that every id is a real port — is the pattern to copy for any
      future "generic pass plus hand-tuned exceptions" option.
- [ ] **macOS's own Light/Dark is NOT flipped by `flavor`, and can't be, one way.**
      Turning dark mode on is one typed setting
      (`NSGlobalDomain.AppleInterfaceStyle = "Dark"`); turning it **off** means
      DELETING a default rather than writing one, and nix-darwin skips null-valued
      keys rather than removing them. So there is no symmetric declarative lever and
      the rice leaves system appearance alone in both directions — a latte rice on a
      dark macOS looks half-done. Fixing it means an activation-script
      `defaults delete -g` plus the restart map (§4), i.e. it belongs with Phase 4,
      not here. Documented in the option so it isn't discovered as a bug.
- [ ] `flavor = "custom"` + `theme.palette` — the "a community rice ships its own
      colours" half. Untouched: a rice can pick a flavor, not supply one. Note the
      **format** wrinkle before designing it — a data-only preset can hold an attrs
      of hexes fine, but nebelung renders ports in a derivation, so a custom palette
      either re-renders at rebuild time or is limited to the Nix-injected tools.
- [ ] ✅ **Pair `contrast = "high"` with the OS lever.** The sweep proved
      `increaseContrast` (and `differentiateWithoutColor`) write *and take
      effect* — and neither is typed by nix-darwin, so they're reachable today
      via `system.defaults.CustomUserPreferences."com.apple.universalaccess"`,
      no upstream change needed. That makes a high-contrast rice cover *native*
      apps too, not just the tools nebelung themes — the missing half.
      Carries the FDA caveat (§5.12), so it must degrade cleanly: the palette
      side works for everyone, the OS side sharpens it when FDA is granted.

### 5.2 `nebelhaus.ui` — semantic scale tokens · M · risk M · ◐ **`scale` shipped**
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

- [x] Every consumer reads `ui.*` through `mkDefault` so a host can still pin one
      number — verified end to end while writing `large-print`: `ui.scale = 1.4`
      resolves `fonts.mono.size` to 27, and pinning the font size afterwards wins.
- [ ] **The fan-out is still THREE targets, not nine**: terminal font size, Dock
      `tilesize`, prowl gaps. `density` and `motion` don't exist yet. The two
      absences that matter most for `large-print` are deliberate-but-unfinished
      rather than decided: **sill's bar** and **pounce's palette window** are sized
      by geometry tuned to the macOS menu-bar band and to their own layouts, so a
      multiplier breaks alignment instead of enlarging — they each need a sizing
      pass. On a non-dev Mac the palette is *how you launch things*, so pounce is
      the higher-value one.
      ⚠️ **Do not read pounce's theming work as progress here.** Colour and size are
      separate seams and only colour got one: the palette follows `flavor`/`contrast`
      and macOS appearance now (§5.1), while its geometry is still `windowMode =
      "compact"` written straight into `config.json` by
      [`modules/pounce/default.nix:340`](nebelhaus/modules/pounce/default.nix:340) —
      no option, no `ui.scale` term. Worth stating because "pounce follows the theme"
      reads like the pounce gap closed, and the `large-print`-relevant half of it
      didn't move at all.
- [ ] Finder icon/sidebar size — typed and writable per the matrix, still unwired.
      Note it needs the restart map (§4): nix-darwin restarts only Dock.
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

- [x] Assert the mono font is a Nerd Font (or warn loudly) — starship/lsd/yazi tofu
      otherwise. Shipped as a warning when `name` is set without `package`.
- [x] `ui.scale` multiplies `fonts.*.size` by default
- [ ] ⚠️ **`sans` never landed, and the reason now matters.** The example in the
      block above — Atkinson Hyperlegible for a large-print machine — is **not
      expressible as a preset at all**, because `fonts.mono.package` takes a
      `types.package` and reaching `pkgs` is exactly what a data-only rice forbids
      (§3.3). So a shared rice can make the existing font bigger but cannot change
      the family. This is the sharpest limit the readiness test has found, and it's
      a *format* limit rather than a missing option: the fix is a way to name a
      package without evaluating one (a string resolved against `pkgs` by the
      module, with the obvious injection question to answer first), not another
      `types.package` option.

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

### 5.5 `nebelhaus.keys` — the keymap is currently closed · M · risk M · ✅ **shipped (nebelhaus#108)**
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

- [x] `keys.{leader,palette,windowNav}` shipped, resolved once in
      `modules/lib/keys.nix`, with `"none"` a real value on all three. `windowNav`
      is a **modifier vocabulary** rather than a bind-per-action: what people need
      to move is the modifier, not the letters, and one value moves all fifteen main-mode
      chords plus service-mode entry. `bindings` (per-action overrides) is still
      open — it needs an action vocabulary first, and none of the motivating cases
      needed it.
      **Update 2026-07-30: half that vocabulary now exists, from pounce.** pounce#43
      addresses every palette row by its frecency key — `cmd:emoji`,
      `app:/Applications/Ghostty.app`, `mode:clipboard` — and takes per-item
      `alias` / `hotkey` / `enabled`, with `hotkey` accepting **leader sequences**
      (`"opt+space e"`: whitespace separates steps, `+` separates modifiers, the
      Emacs/VS Code notation). So `bindings` should be designed as *two* namespaces,
      not one: pounce items already have stable ids, prowl actions still don't.
      Three constraints that came with it and would otherwise be discovered late:
      a second step is registered as an ordinary modifier-less global hotkey for
      ~2s rather than a CGEventTap, so **sequences need no Accessibility grant**
      (worth preserving — it's why the palette key needs none either);
      `enabled = false` hides a row but does **not** disarm its hotkey, so an option
      that means "turn this off" has to say which of the two it does; and
      `pounce run <item-key>` exists as the escape hatch for keys another tool
      already owns, which is the honest answer for a rice whose leader is `"none"`.
- [ ] ~~Split `prowl.enable` into `prowl.tiling.enable` / `prowl.launcher.enable` /
      `prowl.capsRemap.enable`~~ — **superseded, not done.** `keys.leader = "none"`
      is capsRemap-off + launcher-off and `keys.windowNav = "none"` is
      tiling-chords-off, which covers every case that motivated the split, from the
      keymap side rather than by multiplying room switches. Revisit only if someone
      wants AeroSpace to *stop tiling* while keeping its launcher.
- [x] Assertion on duplicate leader letters *and* cross-room conflicts. The
      cross-room one was the real gap: `keys.leader` is prowl's AeroSpace chord and
      `keys.palette` is pounce's in-process hotkey, so **nothing compared them** and
      a clash is silent — whoever registers first wins. `leader = "alt-space"` with
      `palette = "alt-space"` is the reachable case; asserted, and pinned in
      `nix flake check`'s new `keymap` golden table.
- [x] Ship the generated cheatsheet from the same data — the modifier was the LAST
      part of a `wm-bindings.nix` row still written twice ("⌥ hjkl" as a caption
      beside `alt-h` as a chord, in a table whose entire purpose is that those can't
      drift). Both now come from the resolved keymap, and `"none"` empties the
      cheatsheet page along with the bindings so it never advertises an unbound key.
      The first-run tour's prompts follow too, via the generated `tour_config.sh`.
- [ ] **Non-QWERTY is addressed but not TESTED.** `windowNav = "ctrl-alt"` exists
      precisely because ⌥+letter types accented characters on many layouts, but
      nobody has run the rice on such a layout. The launch-mode LETTERS
      (`apps.*.key`) are still assumed to be where QWERTY puts them, which is the
      next thing an international rice would hit.
- [ ] **Found, not fixed** (predates this, and it's a product call): the shipped
      `everyday` preset sets `prowl.enable = false` with `tour.enable = true`, and
      three of the tour's four steps wait on AeroSpace mode events that can then
      never fire — so that tour hangs at step 1. #108 warns about the equivalent new
      combination (`tour.enable` + `keys.leader = "none"`) and leaves the preset
      alone.

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

### 5.9 Open up Sill widgets and Pounce commands · M · risk M · ◐ **pounce built its half**
`sill.items` is a closed submodule of 13 bools. Pounce commands were
script-discovery only with **no Nix option at all**; as of pounce#43 the
*app* has the schema and the **rice** is what's missing — which flips this item
from "design a surface" to "generate a file", the cheapest it will ever be.

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
- [ ] While here: pounce has **no option for its own window sizing** (`windowMode`
      is written straight into `config.json` by the rice), which is why `ui.scale`
      can't reach the palette (§5.2). On a non-dev Mac the palette is how you launch
      things, so this is the highest-value missing knob for `large-print`. Still true
      after the theming work — see the warning in §5.2.
- [x] **pounce side: `config.json` grew an `items` map** (pounce#43), keyed by the
      frecency key so commands, apps and built-in modes share **one address space**
      (`cmd:` / `app:` / `mode:`), each taking `enabled` / `alias` / `hotkey`. The
      design fork recorded there was *one schema now* vs *a key per stage*, resolved
      to one **because these ripple into `nebelhaus/modules/pounce` either way** —
      i.e. the rice-side option was a known consequence, not an afterthought.
- [ ] **rice side, and it is the next cheap win in this section:**
      `nebelhaus.pounce.items` (or `commands`) generating that map. Two facts decide
      its shape: on the rice `config.json` is a **`/nix/store` symlink** (read-only,
      so Nix is the only writer and there is no overlay/merge problem to solve),
      while under Homebrew it is a plain writable file that a future settings UI
      edits — so the rice must generate the *whole* map and never assume it can
      round-trip user edits. `enabled = false` hiding a row **without** disarming its
      hotkey is the wrinkle to name in the option description rather than paper over.
- [ ] Pounce command packs, with the *dev* commands moved into an opt-in pack. Now
      partly expressible without new mechanism: a pack is a set of `items.*.enabled`
      values, which is data — so "packs" may reduce to shipping preset fragments
      (§3.3) rather than a `packs` enum. Decide that before adding the enum.
- [ ] Commands declare: mutates state? needs confirm? needs network/permission?
      Unbuilt, and the metadata that *did* ship went to nebelung's ports instead
      (§5.1) — same idea, other room. Copy that shape: the declaration lives with the
      command, the consumer reads it.

### 5.10 `nebelhaus.displays` — ✅ **shipped in nebelhaus#147** · M · risk M
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
- [x] Helper dedupes modes by point size (they repeat ~6× across refresh
      rate × colour depth) and prefer the highest refresh
- [x] Applying a mode is proven end-to-end on the internal panel: `default`
      (`1512×982`) → `larger-text` (`1147×745`) → `default`, with CoreGraphics
      reporting the requested mode current after each change (2026-07-30)
- [ ] Multi-display arrangement is still untested (only one display was attached).
      Test on the dock before designing `profiles.docked`

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

### 5.13 Authorable tour steps · ◐ **implemented in nebelhaus#156** · S · risk L
Small, and **nobody else can ship this**. `tour.enable` teaches the four moves
of *this* rice. A community rice teaches its own:

```nix
nebelhaus.tour.steps = [
  { hint = "Press ⌘Space to find anything"; detect = "pounce-opened"; }
];
```
The detection signals already exist (the leader-mode scripts). This is the
difference between downloading someone's config and *learning* it.

nebelhaus#156 kept `steps = null` as the unchanged built-in lap; supplying a
non-empty list replaces it. `detect` is deliberately the existing outcome
vocabulary (`launch`, `workspace`, `navigate`, `resize`, `palette`), so the
community file remains data-only, and the module warns when a step names a
signal whose room is disabled.

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
everything macOS can't veto)* — **mostly done 2026-07-27**
- [x] §5.3 fonts (nebelhaus#91)
- [x] §5.2 `ui.scale` — shipped, but the fan-out is three targets, not nine
      (`density`/`motion` unbuilt; sill + pounce need their own sizing pass)
- [x] §5.1 theme: **contrast** (nebelung#11 + nebelhaus#103) and **flavor / light
      mode** (nebelung#12 + nebelhaus#108), then **roster theming from port
      metadata** (nebelung#17/#18/#19 + nebelhaus#136) and **pounce off the
      "bakes its own" list** (pounce#37/#42 + nebelhaus#139/#142). `scheme = "auto"`
      is now *partly* shipped — per-tool rather than rice-wide, which is a design
      answer as much as progress; `flavor = "custom"` remains untouched.
- [x] §5.5 `keys.*` (nebelhaus#108) — leader / palette / windowNav, each with a real
      `"none"`. Per-action `bindings` deferred; it wants an action vocabulary first.
- [ ] §5.4 apps v2 + workspaces — **the last one, deliberately.** It's a schema
      migration needing back-compat (`apps.*.workspace` desugaring into
      `workspaces`), so it's the one item here that can break a live host, and it's
      worth doing after the option surface stopped moving around it. Nothing else in
      Phase 3 blocks on it.
- [x] §5.10 displays (nebelhaus#147) — the only working system-wide "make it
      bigger" lever, now part of `large-print`; docked multi-display validation
      remains before any `profiles.docked` design

**Phase 3.5 — the docs debt Phase 3 created** *(found while shipping it, 2026-07-27)*

Every user-facing option family needs a hand-written guide; only
`reference/options.md` is generated. Landing four option families at once made
that visible, and turned up two things that were already broken:

- [x] `reference/options.md` regenerated — it was **already stale from #103**, so
      `options-drift.yml` was red before this phase even started. `theme.contrast`
      had never reached the page.
- [x] `guides/theming.mdx` gains contrast + light mode; it still described nebelung
      as "low-contrast" and documented neither. Same phrase corrected in
      `start/what-is-nebelhaus.md` and `reference/palette.mdx`.
- [x] `guides/window-management.mdx` + `reference/keybindings.md` say the keymap is
      configurable, and that `⇪`/`⌥` in the tables mean "the leader" and "the nav
      modifier" on a rice that moved them.
- [x] ⚠️ **The keybinding tripwire was BROKEN by #108** and nothing in the rice
      could have caught it: `web/scripts/check-rice-bindings.mjs` did
      `nix eval --json --file modules/prowl/wm-bindings.nix`, which stopped working
      the moment that file became a function ("cannot convert a function to JSON").
      It runs on a weekly cron, so it would have surfaced as a mystery Monday
      failure in a different repo. Fixed by exposing `wm-bindings-json` from the
      rice's flake — the same seam `options-json` already uses, and the general
      lesson: **when the docs repo reads the rice's internals directly, a rice
      refactor is a cross-repo break with no local signal.** Worth auditing for
      other direct reads.
- [x] **Presets and community rices have their own guide.**
      `guides/sharing-a-rice.mdx` covers the data-only boundary, `checkRice`,
      composition testing, publishing, and the line between a rice and a power
      module; `guides/making-it-yours.mdx` keeps the shorter consumer story.

**Phase 4 — the non-dev Mac**
- [ ] §5.7 `haus set` · §5.9 pounce packs + sill widgets · §5.6 curated settings groups
- [ ] the restart map (§4) — nix-darwin only restarts Dock, so this is ours
- ◐ **§5.9's pounce half arrived early, from the app side** (pounce#43), because
  pounce wanted a Raycast-style settings list for its own reasons. That's the second
  time an app shipped a piece of this roadmap ahead of its phase (the first:
  nebelung's port metadata, §5.1) — both times because the app needed the data
  structure anyway and the rice was the *downstream* consumer. So read these phases
  as an ordering of **rice** work; the family's other repos will keep landing pieces
  out of order, and the cheap move is to notice and consume them rather than to
  design the option first.

**Phase 5 — trust and breadth**
- [ ] §5.11 plan/capture/diff/revert — **`diff` must compare effective state, not
      plists**; a plist-only diff would have called both no-op writes "applied"
- [ ] §5.8 scenes · §5.12 accessibility doctor checklist
- ◐ §5.13 authorable tour steps — implemented in nebelhaus#156; awaiting feel-test + merge

**The readiness test:** three reference rices that are deliberately far apart —
today's developer rice, `large-print` + `everyday`, and a mouse-first
writer/creative setup — each expressible **without reaching around
`nebelhaus.*` even once.**

Scoreboard, 2026-07-27: **all three now exist and pass.** `full`, `everyday` and
`large-print` are data-only (`nix flake check` proves they touch nothing outside
`nebelhaus.*`), and none needed a `system.defaults` escape hatch or a
hand-written activation script — which was the whole point of not faking it.

`presets/large-print.nix` is three options (`ui.scale`, `theme.contrast`,
`accessibility.increaseContrast`) and it is a **layer, not a whole rice**: it
describes seeing, not the person, so `[ everyday large-print ]` composes with
nothing lost either way (measured: stock `1.0 / 19pt` → large-print `1.4 / 27pt /
contrast high` → stacked, plus developer off, prowl off, pounce on). That layer
shape needed no new mechanism, and it's a better answer than a monolithic preset:
had large-print been forced to restate `everyday`, the surface still couldn't
separate "a Mac for someone who doesn't write code" from "a Mac you can read".

**Passing is not the same as finished, and the test's real value was the two
limits it exposed:**

1. **A shared rice cannot change the font family.** `fonts.mono.package` takes a
   `types.package`, and reaching `pkgs` is precisely what data-only forbids — so
   §5.3's own motivating example (Atkinson Hyperlegible for a large-print machine)
   is unexpressible as a preset. This is a **format** limit, not a missing option,
   and it generalises: any option typed as a package, derivation or path-to-store
   is invisible to the community format. Worth auditing the whole surface for
   others before publishing it.
2. **There was no system-wide size lever in the preset.** macOS's own workable
   lever is display resolution (§5.10), not its broken declarative text-size
   setting. That gap is now closed by `displays.main.uiScale = "larger-text"` in
   rice#147. It is deliberately coarse — everything grows and desktop space
   shrinks — but it reaches third-party apps that `ui.scale` cannot.

So the honest reading now: the option surface can express all three reference
rices, and `large-print` reaches both the rice and the whole Mac. Its remaining
visible gaps are pounce/sill sizing (§5.2/§5.9) and the font-package format limit
above, not §5.4.

**Re-checked 2026-07-30 after rice#147/#149.** Displays and the rice-side pounce
item generator both landed. That leaves the sizing pass as the next coherent
piece: the menu bar and palette are the two rice-owned surfaces `large-print`
still cannot enlarge. The dock is now a validation dependency only for future
multi-display profiles, not an ordering dependency for the shipped scale option.

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

**Ordering, learned on §5.1.** A rice change that consumes a new nebelung output
can't carry its own lock bump — the bump isn't computable until nebelung's PR
lands. The way to keep the rice PR independently reviewable is to make the
**default path** need nothing new: `modules/lib/nebelung.nix` re-derives the
variant-subdir rule rather than reading nebelung's `variants` output, so
`flavor = "mocha"` still evaluates against the old lock and CI stays green, while
`flavor = "latte"` throws a message naming `nix flake update nebelung`. The cost
is one rule mirrored across the repo boundary; the mitigation is that both sides
hold it in exactly one place and `nix flake check`'s `theme-variants` pins the
table, because that mirror's failure mode is silent (a wrong subdir is a store
path that doesn't exist, discovered at activation).

**The better answer to the same problem, found on §5.1's next PR: ship the rule as
DATA from the upstream repo.** `theme.ports` needed far more cross-boundary
knowledge than `variantDir` did — 53 ports × where each theme goes, how it
installs, whether dropping the file is enough — and mirroring *that* would have
been unmaintainable. nebelung#19 ships `ports.meta.json` instead and the rice
reads it, so there is no second copy to drift and a port rename surfaces as an
eval-time assertion (`theme.ports.handled` checks every id is real) rather than a
missing store path at activation. The rule of thumb this leaves: **mirror only what
fits in one expression and can be pinned by a golden test; anything table-shaped
becomes an output of the repo that owns it.** Phase 3.5's tripwire break is the
same lesson from the failure side — when a downstream repo reads an upstream's
internals directly, a refactor upstream is a break with no local signal, so the
seam should be a declared output (`options-json`, `wm-bindings-json`,
`ports.meta.json`) every time.

---

## 8. What a cloud session can actually verify here

Recorded because §5.1/§5.5 were done from Claude Code on the web, and the house
rule is to *diff derivations rather than assert no-change* — which needs some
care when a full `nix eval` is off the table.

**Doesn't work** (as the workshop CLAUDE.md says): a darwin evaluation, `bench
try`, `nix flake check`, or nebelung's `nix build`. nixpkgs, nix-darwin,
home-manager and catppuccin all resolve through the session's GitHub gate and
only nebelhaus-org repos are in scope.

**Does work, and was enough for real proofs:**

- **nixpkgs via the channel tarball.** `https://channels.nixos.org/nixpkgs-unstable/nixexprs.tar.xz`
  is not GitHub, so it fetches, and `cache.nixos.org` is reachable. That gives
  `pkgs`/`lib`, `nixfmt`, `shellcheck` and `runCommand` — everything except the
  darwin module set.
- **The options surface, diffed as a derivation.** `packages.<linux>.options-json`
  evaluates only the per-room `options.nix` files (that's why §3.1 mattered), so it
  can be built standalone before and after a change and every leaf's type +
  default compared. "Exactly four new options and nothing else moved" is a diff,
  not a claim.
- **The generated artifacts, diffed.** `aerospace.toml` and the pounce cheatsheet
  are pure functions of a few config values, so a harness can call the real tables
  and render both revisions. That's what proved the §5.5 refactor byte-identical at
  the default keymap — and it earned its keep by catching two bugs a patch read
  wouldn't have: token names written in `aerospace.toml`'s own **prose** (the
  substitution is blind to comments, so generated bindings landed mid-sentence),
  and a stray blank line from a newline-terminated token above a blank template
  line.
- **nebelung end to end.** `node --test` runs natively, and `whiskers` builds from
  crates.io (`index.crates.io` bypasses the proxy). Version 2.9.0 reproduces the
  committed `dist/` byte-for-byte, which is what makes "the latte variants are a
  pure addition" a `git status` observation rather than an assertion.
- **New checks written to be Linux-capable on purpose.** `theme-variants` and
  `keymap` are pure `lib`, like `options-json`, so they run in this environment AND
  in the docs repo's Linux CI. Anything needing a darwin system stays guarded
  behind `optionalAttrs isDarwin`.

**One trap.** `nixfmt` from the tarball is 1.4.0 and the repo is formatted with an
older one — 137 lines of churn on `flake.nix` at `HEAD` alone. Running it would
bury a change in reformatting, so: check new files for cleanliness, match the
surrounding style by hand, and don't reformat existing ones.

---

## 9. Naming (optional, low stakes)

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
