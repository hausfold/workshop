---
title: nebelhaus.* options
description: Every option you can set in your host file — types, defaults, and what each one changes.
tableOfContents:
  maxHeadingLevel: 2
---

<!-- GENERATED FILE — do not edit by hand.

     Rendered from the rice's own module system by web/scripts/gen-options.mjs.
     To change an option's description, edit its declaration in the rice
     (modules/<room>/options.nix) and regenerate:

         node web/scripts/gen-options.mjs --rice ../nebelhaus

     CI re-renders this and fails if it differs, so a hand edit here is
     guaranteed to be reverted. -->

These are the `nebelhaus.*` options you set in your host file at
`~/.config/nix/hosts/<hostname>/default.nix`. Everything here is optional
unless noted; the defaults are a complete, working system.

Apply changes with `haus rebuild`. Each option lists its **type** and
**default** under its name, and links to the file that declares it.

## nebelhaus.git

Your commit identity — set your own. It stays in [your host file](/internals/flakes/#your-config-is-a-thin-consumer).

### `nebelhaus.git.email`

`string` · default `""`

Git user.email for commits.

Example:

```nix
"ada@example.com"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

### `nebelhaus.git.name`

`string` · default `""`

Git user.name for commits (hearth wires it into home-manager).

Example:

```nix
"Ada Lovelace"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

### `nebelhaus.git.shellAliases`

`attribute set of (null or string)` · default `{ }`

Per-host additions and overrides for Hearth's built-in Git shell
aliases. Values are shell command strings; null removes a built-in.
Hearth deliberately owns a compact, framework-independent default
set, so this changes only Git shortcuts and does not require a shell
plugin manager.

Example:

```nix
{
  gst = "git status --short --branch"; # replace a built-in
  gsync = "git pull --rebase --autostash"; # add one
  gco = null; # remove one
}
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

### `nebelhaus.git.signingKey`

`string` · default `""`

GPG key id for signing commits/tags. Empty disables commit signing.
Key material + any YubiKey/smartcard setup live outside Nix
(gpg-agent + pinentry-mac).

Example:

```nix
"6F7BD6F43A7C1420"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

## nebelhaus.roster

One list of everything this machine has — apps, fonts, command-line tools. Each entry drives its launcher key, workspace, bar pill and cheatsheet row, and installs it from whichever source it names: a Homebrew cask or formula, a Nixpkgs package, or the Mac App Store.

### `nebelhaus.roster`

`attribute set of (submodule)` · default `{ }`

The one list of things this machine has, keyed by a stable id. It is
the canonical, composable source for AeroSpace launcher keys and
workspaces, SketchyBar pills, the pounce cheatsheet, Nebelung theme
ports — and for the install itself, from any of four sources
(`cask`, `brew`, `package`, `appStoreId`).

Every field except the id is optional, and WHICH fields you set is
what the entry means. Set `key` and it joins the launcher; set
`workspace` and it claims one, with a pill; set none of those and
it's install-only — which is how a font or a command-line tool
lives in the same list as Slack instead of in a second one beside
it. The rice's own `homebrew.casks` / `home.packages` still work and
still merge; you just shouldn't need them for an app.

Attribute-set entries merge across Nix modules, so a host, an imported
file, and pounce's "Install App" command can each contribute one app
without parsing or replacing a monolithic list. Set an entry's enable
field to false to remove it, or override individual fields by app id.

Example:

```nix
{
  # Launcher app: leader s, owns workspace S, installs itself.
  slack = {
    key = "s";
    name = "Slack";
    workspace = "S";
    appId = "com.tinyspeck.slackmacgap";
    barIcon = ":slack:";
    cask = "slack";
  };

  # Install-only: no key, so no leader binding and no pill.
  framer = { cask = "framer"; };
  orbstack = { package = pkgs.orbstack; };
  biome = { package = pkgs.biome; scope = "system"; };
  ical-buddy = { brew = "ical-buddy"; };
  xcode = { name = "Xcode"; appStoreId = 497799835; };
}
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.appId`

`null or string` · default `null`

Bundle id, used for the AeroSpace `on-window-detected`
auto-assign rule and the wake-time re-sort. null skips
auto-assignment (the app still launches, it just isn't herded
to its workspace). Find one with `osascript -e 'id of app "…"'`.

Example:

```nix
"com.tinyspeck.slackmacgap"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.appStoreId`

`null or signed integer` · default `null`

Mac App Store numeric app id (the digits in its store URL), so an
App Store app is declared in the same roster as everything else
rather than in a comment.

Recording it is always safe; INSTALLING from it is opt-in via
`nebelhaus.appStore.install`, because the App Store is the one
source that can't be fully automated: `mas` has no sign-in
command, and it cannot buy a paid app for the first time. Free
apps it can fetch; paid ones you purchase once in App Store.app
and every machine afterwards can install them.

Example:

```nix
497799835
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.barIcon`

`null or string` · default `null`

The SketchyBar workspace-pill glyph. A sketchybar-app-font
ligature like ":slack:" renders the app's logo; any other
string is drawn in the bar's Nerd Font. null falls back to the
workspace letter. Ignored when workspace is null.

Example:

```nix
":slack:"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.brew`

`null or string` · default `null`

Homebrew FORMULA that installs this entry, appended to
homebrew.brews. For the command-line half of the roster — a tool
with no .app bundle, which usually means `key`, `name` and
`workspace` are all null.

Example:

```nix
"ical-buddy"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.cask`

`null or string` · default `null`

Homebrew cask that installs this app. When set, it's appended to
homebrew.casks so declaring the app also installs it. null means
"already present / installed some other way" (e.g. Safari, Music).

Example:

```nix
"slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.enable`

`boolean` · default `true`

Whether this app participates in the shared launcher roster.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.installedBy`

`null or string` · default `null`

The nebelhaus module that puts this app on disk, when none of the
four sources above describes it: trill, pounce and perch copy a
notarized bundle into /Applications from their own activation
step, which is neither a cask nor a package you can list.

Set BY the rice, not by you. It exists so the roster can still
answer "who installed this?" for those apps — without it, a host
adding a leader key for Trill had to KNOW the rice already ships
it, leave every source field null, and leave a comment explaining
the hole. This is that comment, as data.

Example:

```nix
"nebelhaus.trill"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.key`

`null or string` · default `null`

The leader letter for this app: tap Caps Lock then this key to
launch/focus it. Must be unique across the roster.

null (the default) means the entry is INSTALL-ONLY: it still
brings its cask/formula/package, but claims no leader key, no
cheatsheet row, and no launch-mode bubble. That is what lets one
roster hold both the apps you reach for by keyboard and the ones
you just want on the machine (and fonts, and CLI tools).

Example:

```nix
"s"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.label`

`null or string` · default `null`

Cheatsheet caption for the leader key. null uses name.

Example:

```nix
"Slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.name`

`null or string` · default `null`

macOS application name, as passed to `open -a`. Required when
`key` is set (the launcher has nothing to open otherwise);
null is right for an install-only entry — a font, a CLI tool, or
an app you launch some other way.

Example:

```nix
"Slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.order`

`signed integer` · default `1000`

Roster order; lower values appear first. Ties are sorted by app id.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.package`

`null or package` · default `null`

Nixpkgs package that installs this entry. Where it lands is
`scope`'s call.

Example:

```nix
pkgs.orbstack
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.scope`

`one of "user", "system"` · default `"user"`

Which profile `package` installs into.

- "user" (default): home-manager's `home.packages`. Right for
  anything you run as yourself — apps, editors, CLI tools.
- "system": nix-darwin's `environment.systemPackages`. Installed
  once for the whole machine, so it's on PATH for root, for
  non-login shells, and for launchd jobs — which is what a tool
  invoked by a daemon, a `sudo` workflow, or an activation script
  actually needs. (It is about REACH, not about the package
  needing elevated privileges to install: `darwin-rebuild` runs
  under sudo either way.)

Ignored when `package` is null — Homebrew has no such split.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.roster.<name>.workspace`

`null or string` · default `null`

The AeroSpace workspace this app owns — its window auto-moves
here, it gets a SketchyBar pill, and the leader then ⇧<key>
throws a window to it. null makes the app "launcher-only": the
leader still opens it in the current workspace, but it claims no
workspace, pill, or auto-assign rule (e.g. Passwords).

Example:

```nix
"S"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

## nebelhaus.appStore

Whether a rebuild may install the roster's `appStoreId` entries. Off by default: it reaches the network and acts on your Apple Account, and it can never be complete — `mas` cannot sign in, and cannot buy a paid app.

### `nebelhaus.appStore.install`

`boolean` · default `false`

Install roster entries that set `appStoreId` from the Mac App
Store during activation, skipping any already installed.

Off by default: this reaches the network and acts on your Apple
ID, which shouldn't happen as a side effect of turning on a
window manager. It also can't be complete — `mas` cannot sign in
(do that once in App Store.app) and cannot make a first-time
PURCHASE, so a paid app you don't already own is reported and
skipped rather than installed.

Deliberately NOT nix-darwin's `homebrew.masApps`: that runs
`mas install` through `brew bundle` as your user, and since
macOS 13 the App Store install path requires root — so it stops
for a password prompt that a rebuild has no terminal to show,
and the rebuild hangs. The activation step this option enables
is already running as root, so it neither prompts nor wedges.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

## nebelhaus.apps

The apps the rice picks for you, and the file types they claim — the ones a finished machine has rather than the ones a room needs to work. Each is one switch you can turn off; what it installs is a roster entry like any other, so you can retune or replace it by app id.

### `nebelhaus.apps.videoPlayer.claimFileTypes`

`boolean` · default `true`

Make IINA the default handler for the everyday video extensions —
mp4, m4v, mov, mpg, mpeg, mkv, webm, avi, wmv, flv, 3gp, ogv, vob —
so double-clicking a video opens IINA instead of QuickTime Player, TV
or a browser. Ignored unless the player is installed.

A short list on purpose: it covers what you actually double-click,
not everything IINA can decode. Dead, professional and DRM'd
containers (qt, divx, asf, f4v, 3g2, ogm, rm, rmvb, mxf, dv, …) are
left alone — they still play via Open With, they just don't get the
default, and every extension the rice claims is a binding it
re-asserts on every rebuild.

Video only. Audio (mp3, flac, m4a, wav, …), `.gif` and playlists
keep whatever owns them today, since "open videos in IINA" rarely
means "and my music library too". The transport-stream extensions
`.ts`, `.mts` and `.m2ts` are excluded too: on a developer's machine
they are TypeScript far more often than video, and
`nebelhaus.hearth.hijackFileAssociations` claims them for the editor.
Claiming them here as well made macOS stop and ask which app should
win on every single rebuild, because `.mts` and `.m2ts` share one
UTI.

This sets the USER default (via `duti`) — the same record Finder's
Get Info ▸ Change All writes, so it is undoable by hand. Set false to
install the app and leave every association alone.

<small>Declared in [`modules/apps/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/apps/options.nix).</small>

### `nebelhaus.apps.videoPlayer.enable`

`boolean` · default `true`

Install IINA — the rice's video player — as the roster entry `iina`.
A nixpkgs build, so it lands in ~/Applications/Home Manager Apps
rather than /Applications.

On by default: macOS ships QuickTime Player, which refuses most of
what you actually double-click (mkv, webm, and anything not in
Apple's codec list), so "a video player that plays videos" is part
of what the rice considers a finished machine.

Set false and nothing is installed or rebound — bring your own
player via the pounce "Install App" palette command or a roster
entry. Once on it is a roster entry like any other: give it a leader
letter with `nebelhaus.roster.iina.key`, or pin a different build
with `nebelhaus.roster.iina.package`.

<small>Declared in [`modules/apps/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/apps/options.nix).</small>

## nebelhaus.theme

Colour and wallpaper.

### `nebelhaus.theme.accent`

`one of "rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach", "yellow", "green", "teal", "sky", "sapphire", "blue", "lavender"` · default `"mauve"`

The accent colour, by Catppuccin name (the Nebelung palette is a
grey-tinted Catppuccin, so the fourteen names are the same in both
flavors — the hue you pick follows nebelhaus.theme.flavor). It recolours
the tools nebelhaus injects colours into — lazygit, fzf, yazi, and the Zen
browser — via the matching Nebelung per-accent ports.

Honest scope: this moves the accent on those tools, NOT literally
everything. Single-file dotfiles that bake the palette at their own
theme slot (ghostty, starship, tmux, bat, zellij, …) keep their built-in
colour and don't follow this option. The base palette stays the same
Nebelung grey either way — only the accent hue changes.

Example:

```nix
"sapphire"
```

<small>Declared in [`modules/theme/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/theme/options.nix).</small>

### `nebelhaus.theme.contrast`

`one of "normal", "high"` · default `"normal"`

How far the interface separates from its background.

"high" swaps in the Nebelung high-contrast palette: the same hues and
the same accents, with the neutral ramp pulled apart in OKLCH so text
and background separate further at every step. Measured rather than
eyeballed — body text goes from 11.3:1 to 19.9:1 against the base,
clearing WCAG AAA (nebelung's own CI asserts it).

Composes with `flavor`, and the boost is tuned per flavor rather than
shared: light mode has far less room above its background before the ramp
clips to white, so latte goes 7.0:1 → 9.9:1 where mocha goes 11.3 → 19.9.
Both keep all twelve ramp steps distinct, which is the property nebelung's
tests actually assert.

Honest scope. This recolours what the rice injects colours into:
Ghostty, bat, delta, lsd, yazi, zellij, glow, starship, lazygit, the
bar, pounce and trill (at runtime, via ~/.config/{pounce,trill}/themes/ —
and unlike `flavor`, contrast reaches both on BOTH halves of their
light/dark pair), Zen and Obsidian. It does NOT reach:

  - macOS itself. For system-wide contrast see
    nebelhaus.accessibility.increaseContrast — a separate, FDA-gated
    setting. The two are complementary, and a genuinely high-contrast
    machine wants both.

Example:

```nix
"high"
```

<small>Declared in [`modules/theme/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/theme/options.nix).</small>

### `nebelhaus.theme.flavor`

`one of "mocha", "latte"` · default `"mocha"`

Light or dark. "mocha" (the default) is the rice as it has always been;
"latte" is light mode.

Not an inversion of the dark palette — a different SOURCE palette. Nebelung
is "Catppuccin with the blue stripped out", and those rules say nothing
about dark, so they apply to Catppuccin Latte just as well: same warm-grey
neutral ramp, same calmed accents, the other polarity. Light mode lands at
7.0:1 for body text on its own, so it's legible before you reach for
contrast = "high" (which takes it to 9.9:1).

It composes with `contrast`: the two axes give four palettes, and nebelung's
CI measures each one's contrast ratio rather than eyeballing it.

Honest scope, in two parts.

What follows it: every tool the rice injects colours into or points at a
rendered theme — Ghostty, bat, delta, lsd, yazi, fzf, glow, starship,
lazygit, helix, zellij, opencode, the bar, Zen and Obsidian.
These are genuinely re-rendered for the flavor, not recoloured in place:
whiskers takes different branches for a light flavor (terminal ANSI
0/7/8/15 swap, Zen switches its prefers-color-scheme block, delta sets
`light = true`).

What does NOT follow it:

  - pounce and trill, by default. Both read their palette at runtime and
    can pick per polarity, so nebelhaus.pounce.followSystemAppearance
    and nebelhaus.trill.followSystemAppearance (default true) hand that
    choice to macOS Light/Dark instead: the rice installs every rendered
    variant into ~/.config/{pounce,trill}/themes/ and writes the
    dark/light PAIR at your `contrast`. Set either option false to pin
    that app to this flavor like everything else.
  - macOS's own Light/Dark appearance. Turning ON dark mode is one typed
    setting, but turning it OFF means DELETING a default rather than
    writing one, which nix-darwin has no way to express — so the rice
    leaves system appearance alone in both directions and you set it in
    System Settings ▸ Appearance. A latte rice on a dark macOS looks
    half-done, and that half is currently yours — except in pounce and
    trill, which read the appearance themselves.
  - the desktop wallpaper (nebelhaus.theme.wallpaper). The three hand-made
    looks have the dark palette baked in; only "bold" is generated, and it
    follows theme.accent rather than the flavor.

Example:

```nix
"latte"
```

<small>Declared in [`modules/theme/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/theme/options.nix).</small>

### `nebelhaus.theme.ports.enable`

`boolean` · default `true`

Theme the apps in your roster (`nebelhaus.roster`) that Nebelung ships a
port for, without wiring each one by hand.

The rice already themes every tool it installs itself — the shell, the
terminal, the git stack, Zen, Obsidian. This covers the other direction:
an app YOU added to the roster that Nebelung happens to have a theme for.
Add `zed`, `warp` or `xcode` to `nebelhaus.roster` and its Nebelung theme
lands where that app looks for themes, in the flavor and contrast you
selected, following them on every rebuild. Matching is by roster id, so
the entry has to be named after the port (`zed`, not `zed-editor`).

Honest scope, and it is the whole point of the option: this drops the
theme FILE. Whether that alone makes the theme *active* is the app's
choice, not ours, and Nebelung records which is which per port. Ghostty
reads a config key we own, so it just works. Xcode, Warp, OBS and friends
offer no file interface for picking a theme — the file is put where they
look, and the one click that selects it stays yours. `haus doctor` lists
exactly which apps are waiting on that click, so the difference is
visible rather than something you discover months later.

Ports whose install is a merge into an existing config file, or that need
a compile step first, are reported but never written: silently
half-applying someone's config is worse than saying so.

<small>Declared in [`modules/theme/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/theme/options.nix).</small>

### `nebelhaus.theme.wallpaper`

`one of "none", "orbits", "constellation", "flow", "bold"` · default `"none"`

The desktop wallpaper, set at each home-manager activation (osascript,
every desktop on the current Space). Four Nebelung looks:

  orbits · constellation · flow  hand-made, the palette baked in
  bold                           generated from theme.accent, so it
                                 follows the accent (a bold pink at
                                 accent = "pink")

Default "none" leaves your current wallpaper alone — changing the
desktop is visible and personal, so nothing moves unless you ask (the
bootstrap interview offers the choice on a fresh install).

Example:

```nix
"orbits"
```

<small>Declared in [`modules/theme/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/theme/options.nix).</small>

## nebelhaus.fonts

The terminal font. The bar keeps its own font at its own tuned sizes.

### `nebelhaus.fonts.mono.name`

`string` · default `"JetBrainsMono Nerd Font Mono"`

The terminal font family, as Ghostty's `font-family` names it.

This should be a NERD FONT patched build: starship's prompt, lsd's
icons, and yazi all draw with glyphs a stock font renders as tofu.
If you change this, set `package` too — the rice can only install a
font it's been given.

Example:

```nix
"Berkeley Mono"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.fonts.mono.package`

`null or package` · default `null`

The package providing `name`. null (the default) installs the rice's
own JetBrains Mono Nerd Font, which is what `name` defaults to.

Set this whenever you change `name`, or the family simply won't exist
on the machine and Ghostty will silently fall back — the rice warns if
it spots that combination.

Example:

```nix
pkgs.nerd-fonts.fira-code
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.fonts.mono.size`

`positive integer, meaning >0` · default `19, scaled by nebelhaus.ui.scale`

Terminal font size in points. The single most useful knob for a
larger-text machine, since it moves everything the rice actually
lives in.

19 (at ui.scale = 1.0) is the base for a reason worth knowing: the Ghostty window is
tiled to a fixed pixel height by prowl, and sizes that don't divide
that height evenly used to leave a gap under zellij's status bar.
That's since been fixed properly (window-padding-balance +
`extend-always`), so any size is safe now — 19 is simply the tuned
starting point.

Example:

```nix
24
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

## nebelhaus.ui

One number for "make the interface bigger", applied across the rice's own surfaces.

### `nebelhaus.ui.scale`

`integer or floating point number between 0.5 and 3.0 (both inclusive)` · default `1.0`

One number for "make the interface bigger". 1.0 is the rice as tuned;
1.35 is a comfortable large-print setting; below 1.0 tightens things up.

It sets the DEFAULT of the sizes it drives, so anything you pin by hand
still wins:

  nebelhaus.ui.scale = 1.5;          # everything grows
  nebelhaus.fonts.mono.size = 18;    # …except the terminal, pinned here

What it currently moves:

  - the terminal font size (nebelhaus.fonts.mono.size)
  - the command palette, whole (nebelhaus.pounce.scale) — its rows,
    text and icons, and the emoji / clipboard / screenshots / camera /
    Find Files / cheatsheet panels behind it
  - the type in Sill's menu bar — pill labels, icons and popup rows —
    up to a ceiling; see below
  - the Dock icon size (system.defaults.dock.tilesize)
  - prowl's window gaps

Where it stops, and why it isn't a gap waiting to be filled:

  - Sill's bar HEIGHT. The bar is 36pt with 28pt pills so the pills sit
    inside the 32pt menu-bar band that macOS's own hover-reveal covers;
    taller pills poke out below it. That band is macOS's, fixed, and has
    no setting behind it — measured, not assumed. So the bar's type
    follows this option up to the largest that still fits a pill
    (1.25x) and then stops, silently: past that a rice simply gets the
    ceiling. The only way to make the whole bar bigger is to change what
    a point MEANS — the display's scaled resolution, below.
  - anything outside nebelhaus. macOS has no system-wide UI scale, so
    third-party apps follow only a display-resolution change.

Worth knowing if you set both: this and
`nebelhaus.displays.<name>.uiScale` MULTIPLY. A larger-text display mode
leaves a smaller desktop in points, and this asks for bigger points
inside it — so 1.4 on an already-scaled display is a bigger jump than
1.4 on the panel's default.

Example:

```nix
1.35
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

## nebelhaus.displays

Per-display overrides, keyed by which screen you mean.

### `nebelhaus.displays`

`attribute set of (submodule)` · default `{ }`

Per-display settings, keyed by which screen you mean:

  internal   the built-in panel
  main       whichever display is currently main
  <uuid>     a persistent display UUID, for a specific external monitor —
             run `hausdisp list` to print the UUIDs of what's attached

Default is the empty set, and then nothing about your displays is touched.
A key naming a display that isn't plugged in right now is skipped with a
note, not an error, so a `displays.<uuid>` entry for the monitor at the
office can't fail a rebuild on the train.

Why this option exists at all: display scaling is the only lever macOS 26
gives us for "make EVERYTHING bigger", system-wide, including apps the rice
knows nothing about. macOS's own text-size setting writes a value no running
app re-reads, while the accessibility scalars that do work affect contrast
or motion rather than system-wide size — measured, not assumed (the
workshop's notes/macos-settings-matrix.md records the sweep). So
`nebelhaus.ui.scale` and `nebelhaus.fonts` make the *rice* bigger, and this
makes the *Mac* bigger.

Example:

```nix
{
  "37D8832A-2D66-02CA-B9F7-8F30A301B230" = {
    uiScale = "more-space";
  };
  internal = {
    uiScale = "larger-text";
  };
}
```

<small>Declared in [`modules/displays/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/displays/options.nix).</small>

### `nebelhaus.displays.<name>.uiScale`

`null or one of "more-space", "default", "larger-text", "largest-text"` · default `null`

The scaled resolution, as an intent rather than a pixel count — the
same four positions System Settings ▸ Displays offers, named:

  more-space     the largest resolution the panel offers (smallest UI)
  default        the panel's own default mode
  larger-text    between the default and the smallest resolution
  largest-text   the smallest resolution the panel offers (biggest UI)

Resolved per panel from the modes that panel actually reports, so the
same value means the same *thing* on a 14" laptop and a 27" monitor
rather than the same number of pixels. On the 14" MacBook Pro this was
developed on that resolves to 1800x1169 · 1512x982 · 1147x745 ·
1024x665.

Applied at each home-manager activation and set permanently, so it
survives a reboot; re-applying an already-current mode is a no-op, so
a rebuild doesn't flash your screen. null (the default) leaves the
display alone.

When more than one selector names the same attached panel, the more
specific setting wins: UUID over internal over main. This lets a
host-specific display setting refine a broad preset such as
large-print without depending on activation order.

Honest scope: this is a real, system-wide size change — every app gets
bigger, not just the rice's own tools — and the cost is desk space,
because a larger UI means less of it. It also can't run from a rebuild
with no GUI session attached (over SSH, say); the setting applies at
the next activation you run while logged in.

Example:

```nix
"larger-text"
```

<small>Declared in [`modules/displays/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/displays/options.nix).</small>

## nebelhaus.hearth

The shell and terminal experience.

### `nebelhaus.hearth.editor`

`string` · default `"hx"`

The ONE editor the rice uses everywhere. It's the shell command for
$EDITOR / $VISUAL (git, etc.) AND what every "open in an editor" action
launches — the "Nix Config" palette command, the bar's nix-open item,
and the file-association hijack. Those open the target in a new zellij
tab running this command, so a terminal editor (hx, nvim, vim, nano) is
the natural fit for the rice; a GUI editor's CLI works too (e.g. "code"
or "code -w" to block).

Example:

```nix
"nvim"
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

### `nebelhaus.hearth.hijackFileAssociations`

`boolean` · default `false`

When true, build a small opener app and make it the default handler
for ~80 text/code extensions (json, md, ts, nix, rs, go, kdl, …), so
opening or clicking those files opens them in nebelhaus.hearth.editor in
a terminal tab. The app declares the types itself (not just `duti`) so
extensions nothing else on the machine declares still bind. Off by
default: silently rewriting your file associations is a jarring,
hard-to-undo change, so it's strictly opt-in. (Extensionless executables
like `bench` are NOT covered — macOS gates the public.unix-executable
handler behind an interactive dialog; set it by hand once if wanted:
`duti -s org.nebelhaus.editoropen public.unix-executable all`.)

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

### `nebelhaus.hearth.obsidianVaults`

`list of string` · default `[ ]`

Home-relative paths to existing Obsidian vaults that should use the
Nebelung theme. On each activation, Hearth copies the rendered
theme.css + manifest.json into each vault's .obsidian/themes/Nebelung/
directory, selects Nebelung's dark appearance in appearance.json, and
removes the obsolete "nebelung" CSS snippet from the enabled list.

Empty (the default) leaves every vault untouched. Paths must be
relative to the user's home, may not contain "..", and are skipped
with a warning unless their .obsidian directory already exists.

Example:

```nix
[
  "Library/Mobile Documents/iCloud~md~obsidian/Documents/notes"
]
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

### `nebelhaus.hearth.zellijStartLocked`

`boolean` · default `true`

When true (the default), zellij boots into Locked input mode instead of
Normal — its single-key submode leaders (pane, tab, resize, …) stay
inert until you unlock with Ctrl-g, so a stray keystroke can't jump you
into a submode. The `Super`-prefixed launchers (claude / pane / tab /
yazi-peek / fullscreen) are bound in `shared` and keep working while
locked, as do `Alt [` / `Alt ]` (cycle swap layouts) — the rest of
zellij's `Alt` row stays inert while locked, since those keys are
readline/vim word motions the pane's app wants. The bar's bottom-right
quick-hint block only shows in Locked mode. Set false to start in Normal
mode (zellij's own default).

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

## nebelhaus.agents

Which coding-agent clients this machine installs, and which one the agent keybinding spawns.

### `nebelhaus.agents.clients`

`list of (one of "claude", "codex", "opencode")` · see below

Which coding-agent clients to install. `claude` is Claude Code, `codex`
is OpenAI Codex, `opencode` is OpenCode. The ⌘A terminal binding starts
whichever one `agents.default` names — Claude Code through its own
`--worktree` hook, the others through `wt new`.

A list rather than one bool per client, matching `developer.languages`
— a fourth client later doesn't change this option's shape.

This is the option that makes `agents.default` honest. Naming a client
you have not installed used to fail *at spawn time*, inside the pane,
after the worktree already existed: a flash of
`codex is unavailable`, and litter to reap. `agents.default` must now
be a member of this list, so the same mistake fails the rebuild
instead, with both values named.

Override the package for a client the usual Nix way — an overlay on
`claude-code`, `codex` or `opencode` — rather than dropping the client
here and installing your own copy alongside; two derivations shipping
the same `bin/` name collide in one profile.

Example:

```nix
[
  "claude"
  "codex"
]
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.agents.default`

`one of "claude", "codex", "opencode"` · default `"claude"`

The coding agent started by Pounce's **Spawn Agent** commands, by the
⌘A / Super-a zellij binds and the `c` shell alias, and used to reopen
worktrees with no client recorded yet. Each spawned worktree records its
own client, so changing this affects new work but never reopens an
existing Codex or OpenCode task in Claude.

Must be one of `agents.clients` — see there.

Only `claude` can make its own worktree (its native `--worktree` flag,
which fires the `wt` create hook); for `codex` and `opencode` ⌘A runs
`wt new` instead, producing the same checkout, branch and registry entry
from the outside. Resuming follows the client too: `codex` reopens its
cwd-filtered `codex resume` picker, `opencode` continues its latest
session for that cwd. All three share one `wt` branch/parking/reap
lifecycle, and all three light up the `agents` bar pill and the zellij
tab-bar badge — the opencode plugin and the codex hooks are written for
you; only Claude Code's stay yours to wire, because Claude owns its own
settings.json (see `nebelhaus.sill.items.agents`).

Example:

```nix
"codex"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

## nebelhaus.claude

Claude Code integration.

### `nebelhaus.claude.globalMd`

`strings concatenated with "\n"` · default `""`

Contents of Claude Code's global memory file, written to
~/.claude/CLAUDE.md (hearth wires it into home-manager). This is your
personal, cross-project operating context. When set, the rice prepends
two short sections of its own — a note that the file is generated and
where to actually edit it, and the `holt` worktree etiquette, since the
rice ships `holt` and that rule is what keeps it working — then your
text. Leave it empty to manage ~/.claude/CLAUDE.md fully by hand
(nothing is written, so the rice never clobbers a by-hand file).

Example:

```nix
''
  # CLAUDE.md — global
  How I like to work across every repo…
''
```

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

### `nebelhaus.claude.skill`

`boolean` · default `true`

Install the `nebelhaus` Claude Code skill into
~/.claude/skills/nebelhaus, so an agent asked to "install Slack" or
"make everything bigger" edits your host file and runs `haus rebuild`
instead of guessing at dotfiles and `brew install`.

The skill's option reference is GENERATED from the rice revision this
machine is pinned to, so it can only ever describe options that
actually exist here — and it is regenerated by `haus update`. It also
carries this host's current state (which rooms are on, where the host
file is) and a starter AGENTS.md + CLAUDE.md pair for your config repo —
the rules in the first, a one-line import in the second, so a session
opened there is oriented whichever client it runs.

Unrelated to Claude Code's own settings, which follow
nebelhaus.developer.agents.enable. This is a plain file drop: a machine
that never runs an agent just carries an unread markdown file. Set
false to leave ~/.claude/skills alone entirely.

<small>Declared in [`modules/hearth/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hearth/options.nix).</small>

## nebelhaus.accessibility

macOS accessibility keys the rice can actually apply. These write to a TCC-protected domain, so they take effect only when the app you run the rebuild from holds Full Disk Access — otherwise the rice warns and moves on.

### `nebelhaus.accessibility.differentiateWithoutColor`

`null or boolean` · default `null`

macOS's "Differentiate without colour" — native UI adds shapes and
text where it would otherwise rely on hue alone. The setting to pair
with a rice built for colour-blind readability.


null (the default) leaves whatever you have alone — this is a
personal setting, so the rice never picks a value for you.

REACHABILITY: `com.apple.universalaccess` is TCC-protected. It writes
only when the app that runs the rebuild holds Full Disk Access
(System Settings ▸ Privacy & Security ▸ Full Disk Access; on macOS 26
a stale grant often needs removing and re-adding with (+)). Without
that grant the rice logs a warning and moves on — it does NOT fail
the rebuild. Worth knowing: an agent-driven `haus rebuild` runs under
a different app than your terminal, so it may skip this while your
own rebuild applies it.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.accessibility.increaseContrast`

`null or boolean` · default `null`

macOS's "Increase contrast" — stronger borders and reduced use of
colour alone to convey state, across native apps. This is the
system-level companion to a high-contrast nebelhaus theme: the theme
restyles the tools nebelhaus colours, this reaches everything else.


null (the default) leaves whatever you have alone — this is a
personal setting, so the rice never picks a value for you.

REACHABILITY: `com.apple.universalaccess` is TCC-protected. It writes
only when the app that runs the rebuild holds Full Disk Access
(System Settings ▸ Privacy & Security ▸ Full Disk Access; on macOS 26
a stale grant often needs removing and re-adding with (+)). Without
that grant the rice logs a warning and moves on — it does NOT fail
the rebuild. Worth knowing: an agent-driven `haus rebuild` runs under
a different app than your terminal, so it may skip this while your
own rebuild applies it.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

## nebelhaus.keys

The keys the rice owns — the leader, the palette, the window-chord modifier — and anything extra you hang off the leader.

### `nebelhaus.keys.leader`

`one of "caps", "alt-space", "none"` · default `"caps"`

What enters the launcher/leader mode — tap it, then a letter opens an
app, a digit focuses a workspace, ⇧+either throws the focused window
to that workspace and follows it there, an arrow navigates, `-`/`=`
resizes.

  - "caps" (default): Caps Lock. AeroSpace can't bind Caps Lock itself,
    so the rice remaps it to F18 with hidutil and binds that.
  - "alt-space": the leader without giving up Caps Lock. No remap at all.
  - "none": no leader. Caps Lock stays Caps Lock, launch mode is
    unreachable, and nothing is remapped — the setting for a mouse-first
    rice, or for a Mac you are handing to someone else. What the leader
    fronted is still reachable: apps through the palette, window moves
    through service mode's join-with and the palette's own commands.
    Workspace focus and the workspace throws go away with it — they
    live only in launch mode.

The remap is re-applied at every activation and does not survive a
reboot, so moving off "caps" ends it — at the latest, at next boot.

Only meaningful with nebelhaus.prowl.enable (AeroSpace owns the modes).

Example:

```nix
"none"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.keys.leaderExtras`

`list of (submodule)` · default `[ ]`

Extra launch-mode (leader) bindings beyond the app roster: tap the leader,
then `key`, to run `command`. Use it for leader actions that aren't
"launch an app" — a script, an AppleScript, opening a URL.

Only meaningful with nebelhaus.prowl.enable and keys.leader != "none"
(with no leader there is no launch mode to bind into).

Example:

```nix
[
  {
    key = "enter";
    command = "osascript -e 'tell application \"Things3\" to show quick entry panel'";
    caption = "Things Quick Entry";
  }
]
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.keys.leaderExtras.*.caption`

`null or string` · default `null`

The Launch Mode cheatsheet caption for this action. null falls back
to the raw command, which is rarely what you want — set it.

Example:

```nix
"Things Quick Entry"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.keys.leaderExtras.*.command`

`string` · no default

The shell command run when the leader is followed by `key`; launch
mode exits afterward. It's written verbatim into a small `/bin/sh`
script that AeroSpace execs, so ordinary shell rules apply — `$HOME`
resolves, and single quotes (an `osascript -e '…'`, say) are safe,
which they would not be inlined into AeroSpace's own config.

Example:

```nix
"osascript -e 'tell application \"Things3\" to show quick entry panel'"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.keys.leaderExtras.*.key`

`string` · no default

The AeroSpace key name pressed after the leader (e.g. "enter",
"space", "period", or a letter). Must not collide with a roster
app's key or a built-in launch-mode key (the digits 1-4, the
arrows, `-`/`=`, `v`/`e`/`z`, `,`, `` ` ``, `/`, esc) — nor with
the workspace throws, which are ⇧ + any of those digits or a
roster letter ("shift-1", "shift-b", …). An assertion in
modules/prowl catches a clash rather than letting one binding
silently shadow another.

Example:

```nix
"enter"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.keys.palette`

`one of "cmd-space", "alt-space", "ctrl-space", "none"` · default `"cmd-space"`

What opens the pounce command palette. Registered in-process by the
daemon, so it's near-instant and doesn't go through AeroSpace.

"cmd-space" (default) is the one value that also DISABLES Spotlight's
own ⌘Space, because the two can't share it. Every other value leaves
Spotlight alone — including "none", which hands the palette's job back
to Spotlight entirely. That's a fix as much as an option: the rice used
to take Spotlight's ⌘Space away unconditionally, even where nothing
claimed it.

Only meaningful with nebelhaus.pounce.enable.

Example:

```nix
"none"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.keys.windowNav`

`one of "alt", "ctrl-alt", "cmd-alt", "none"` · default `"alt"`

The modifier vocabulary for prowl's window chords — one setting rather
than a bind-per-action, because what people need to move is the
modifier, not the letters. It drives focus (`<mod>` + hjkl), layouts
(`<mod>` + `/` `,`), fullscreen, moving a workspace to the next
monitor (`<mod>⇧⇥`), and entering service mode
(`<mod>⇧;`). Anything that names a workspace — focusing one, or
throwing the focused window there — hangs off `leader` instead, not
this option.

"alt" (default) is ⌥. The alternatives are for **non-US keyboard
layouts**, where ⌥+letter types accented characters — a rice that owns
⌥+letter is unusable on those, which is the concrete reason this option
exists.

Whatever you pick, AeroSpace claims those chords **globally**, so they
stop reaching whatever owned them inside a terminal. The surface is
small now that the workspace throws moved to the leader: only hjkl,
`/` `,`, `f`, `⇧⇥` and `⇧;`, none of which a roster letter can land
on — and `<mod>⇥` is free again, since workspace back-and-forth
retired in favour of pounce's cross-workspace ⌘⇥ switcher. (Under
"ctrl-alt" that used to bite — the throws were `⌃⌥⇧` + an app's roster
letter, so an app on `a` silently ate hearth's zellij
`Ctrl Alt Shift a` in-place-agent bind. That collision is gone.)
Nothing on a stock macOS collides either: the only ⌃⌥ system hotkeys
are input-source switching (⌃⌥Space, off by default) and hyper-F13.

"none" drops the modifier chords entirely: no focus/layout chords, no
service mode. Combined with `leader = "none"` that's a rice where the
tiler tiles and the keyboard is left alone — mouse-first. The cheatsheet
follows, so it never advertises a key that does nothing.

Only meaningful with nebelhaus.prowl.enable.

Example:

```nix
"ctrl-alt"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

## nebelhaus.hotCorners

What each corner of the screen does when the pointer reaches it. Every corner is unset by default, so the rice never overwrites one you set yourself.

### `nebelhaus.hotCorners.bottomLeft`

`null or one of "disabled", "mission-control", "application-windows", "desktop", "launchpad", "notification-center", "quick-note", "screen-saver", "prevent-screen-saver", "sleep-display", "lock-screen"` · default `null`

What happens when the pointer reaches the bottom-left corner of the main
display.

```
              disabled  nothing happens — the corner is explicitly claimed and left inert
       mission-control  Mission Control: every window and Space, zoomed out
   application-windows  App Exposé: every window of the app you're in
               desktop  push all windows aside and show the desktop
             launchpad  the grid of installed apps (on macOS 26 this opens the Apps view)
   notification-center  slide out Notification Center and its widgets
            quick-note  start a Quick Note — Apple's own default for the bottom-right corner
          screen-saver  start the screen saver immediately
  prevent-screen-saver  hold the screen saver off while the pointer rests here
         sleep-display  put the display to sleep (the machine keeps running)
           lock-screen  lock the screen and return to the login window
```

null (the default) writes nothing at all, which is not the same as
"disabled": corners are a setting people have usually already made by
hand, and a rice that names one it doesn't care about would silently
erase it. Use `"disabled"` to explicitly claim a corner and make it inert.

Setting a corner also clears its MODIFIER key. macOS stores "hold ⌘ for
this corner" separately (`wvous-*-modifier`), and a leftover modifier from
an earlier setup makes a corner the rice just declared look broken —
nothing happens, because you weren't holding the key nobody told you
about. Corners the rice leaves at null keep whatever modifier they have.

Worth knowing if you also run tiling: `mission-control` and `desktop` are
macOS's own window and Space management, which prowl replaces. They still
work, they just show you a view of the windows prowl is arranging.

Example:

```nix
"mission-control"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.hotCorners.bottomRight`

`null or one of "disabled", "mission-control", "application-windows", "desktop", "launchpad", "notification-center", "quick-note", "screen-saver", "prevent-screen-saver", "sleep-display", "lock-screen"` · default `null`

What happens when the pointer reaches the bottom-right corner of the main
display.

```
              disabled  nothing happens — the corner is explicitly claimed and left inert
       mission-control  Mission Control: every window and Space, zoomed out
   application-windows  App Exposé: every window of the app you're in
               desktop  push all windows aside and show the desktop
             launchpad  the grid of installed apps (on macOS 26 this opens the Apps view)
   notification-center  slide out Notification Center and its widgets
            quick-note  start a Quick Note — Apple's own default for the bottom-right corner
          screen-saver  start the screen saver immediately
  prevent-screen-saver  hold the screen saver off while the pointer rests here
         sleep-display  put the display to sleep (the machine keeps running)
           lock-screen  lock the screen and return to the login window
```

null (the default) writes nothing at all, which is not the same as
"disabled": corners are a setting people have usually already made by
hand, and a rice that names one it doesn't care about would silently
erase it. Use `"disabled"` to explicitly claim a corner and make it inert.

Setting a corner also clears its MODIFIER key. macOS stores "hold ⌘ for
this corner" separately (`wvous-*-modifier`), and a leftover modifier from
an earlier setup makes a corner the rice just declared look broken —
nothing happens, because you weren't holding the key nobody told you
about. Corners the rice leaves at null keep whatever modifier they have.

Worth knowing if you also run tiling: `mission-control` and `desktop` are
macOS's own window and Space management, which prowl replaces. They still
work, they just show you a view of the windows prowl is arranging.

Example:

```nix
"mission-control"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.hotCorners.topLeft`

`null or one of "disabled", "mission-control", "application-windows", "desktop", "launchpad", "notification-center", "quick-note", "screen-saver", "prevent-screen-saver", "sleep-display", "lock-screen"` · default `null`

What happens when the pointer reaches the top-left corner of the main
display.

```
              disabled  nothing happens — the corner is explicitly claimed and left inert
       mission-control  Mission Control: every window and Space, zoomed out
   application-windows  App Exposé: every window of the app you're in
               desktop  push all windows aside and show the desktop
             launchpad  the grid of installed apps (on macOS 26 this opens the Apps view)
   notification-center  slide out Notification Center and its widgets
            quick-note  start a Quick Note — Apple's own default for the bottom-right corner
          screen-saver  start the screen saver immediately
  prevent-screen-saver  hold the screen saver off while the pointer rests here
         sleep-display  put the display to sleep (the machine keeps running)
           lock-screen  lock the screen and return to the login window
```

null (the default) writes nothing at all, which is not the same as
"disabled": corners are a setting people have usually already made by
hand, and a rice that names one it doesn't care about would silently
erase it. Use `"disabled"` to explicitly claim a corner and make it inert.

Setting a corner also clears its MODIFIER key. macOS stores "hold ⌘ for
this corner" separately (`wvous-*-modifier`), and a leftover modifier from
an earlier setup makes a corner the rice just declared look broken —
nothing happens, because you weren't holding the key nobody told you
about. Corners the rice leaves at null keep whatever modifier they have.

Worth knowing if you also run tiling: `mission-control` and `desktop` are
macOS's own window and Space management, which prowl replaces. They still
work, they just show you a view of the windows prowl is arranging.

Example:

```nix
"mission-control"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.hotCorners.topRight`

`null or one of "disabled", "mission-control", "application-windows", "desktop", "launchpad", "notification-center", "quick-note", "screen-saver", "prevent-screen-saver", "sleep-display", "lock-screen"` · default `null`

What happens when the pointer reaches the top-right corner of the main
display.

```
              disabled  nothing happens — the corner is explicitly claimed and left inert
       mission-control  Mission Control: every window and Space, zoomed out
   application-windows  App Exposé: every window of the app you're in
               desktop  push all windows aside and show the desktop
             launchpad  the grid of installed apps (on macOS 26 this opens the Apps view)
   notification-center  slide out Notification Center and its widgets
            quick-note  start a Quick Note — Apple's own default for the bottom-right corner
          screen-saver  start the screen saver immediately
  prevent-screen-saver  hold the screen saver off while the pointer rests here
         sleep-display  put the display to sleep (the machine keeps running)
           lock-screen  lock the screen and return to the login window
```

null (the default) writes nothing at all, which is not the same as
"disabled": corners are a setting people have usually already made by
hand, and a rice that names one it doesn't care about would silently
erase it. Use `"disabled"` to explicitly claim a corner and make it inert.

Setting a corner also clears its MODIFIER key. macOS stores "hold ⌘ for
this corner" separately (`wvous-*-modifier`), and a leftover modifier from
an earlier setup makes a corner the rice just declared look broken —
nothing happens, because you weren't holding the key nobody told you
about. Corners the rice leaves at null keep whatever modifier they have.

Worth knowing if you also run tiling: `mission-control` and `desktop` are
macOS's own window and Space management, which prowl replaces. They still
work, they just show you a view of the windows prowl is arranging.

Example:

```nix
"mission-control"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

## nebelhaus.screenshots

Where ⇧⌘4 puts its files, in what format, and whether it draws a window shadow or a preview thumbnail. Unset by default, so macOS's own choices stand.

### `nebelhaus.screenshots.format`

`null or one of "png", "jpg", "pdf", "tiff", "heic", "gif"` · default `null`

The image format new screenshots are saved in. null (the default)
leaves macOS's own choice alone, which is png.

png is lossless and the right default for UI and text — a jpg
screenshot of a terminal has visible ringing around every glyph. jpg
is worth choosing only when you screenshot photographs often enough
for the file sizes to matter.

Example:

```nix
"png"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.screenshots.includeDate`

`null or boolean` · default `null`

Whether filenames carry the date and time ("Screenshot 2026-08-03 at
13.37.20.png") or just a counter ("Screenshot 1.png"). null (the
default) leaves macOS's own choice alone, which is to include it.

Example:

```nix
true
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.screenshots.location`

`null or string` · default `null`

Where ⇧⌘3 / ⇧⌘4 / ⇧⌘5 write their files. null (the default) leaves
macOS's own choice alone, which is the Desktop.

Absolute, or starting with `~/` — the rice expands the `~` for you and
CREATES the directory during activation. Both halves matter: macOS
stores this string verbatim and expands nothing, and if the path does
not exist screencapture silently falls back to the Desktop, so a
typo'd or not-yet-created folder looks exactly like the setting having
been ignored.

Example:

```nix
"~/Pictures/Screenshots"
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.screenshots.shadow`

`null or boolean` · default `null`

Whether a window capture (⇧⌘4 then Space) keeps macOS's big soft drop
shadow. null (the default) leaves macOS's own choice alone, which is
to include it.

false is the setting to want if screenshots go into documentation: the
shadow is transparent padding, so it adds a wide invisible margin that
every layout then has to fight. Holding ⌥ while you click suppresses
it for one capture either way.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.screenshots.thumbnail`

`null or boolean` · default `null`

Whether the floating preview thumbnail appears in the bottom-right
corner after a capture. null (the default) leaves macOS's own choice
alone, which is to show it.

false writes the file immediately instead of after the ~5s the
thumbnail waits around — the setting to want if you screenshot in
quick succession, or if you script anything that reads the file. The
cost is losing the markup/drag affordance the thumbnail offers.

Example:

```nix
false
```

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

## nebelhaus.prowl

Tiling window management and the Caps-Lock leader launcher.

### `nebelhaus.prowl.enable`

`boolean` · default `true`

AeroSpace tiling window management + the leader-key launcher.

This is the room switch: off drops AeroSpace, its launch agent, the
wake-time window re-sort and the key remap entirely. To keep the tiler but
leave the keyboard alone, use nebelhaus.keys.leader = "none" and
nebelhaus.keys.windowNav = "none" instead of turning the room off.

<small>Declared in [`modules/prowl/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/prowl/options.nix).</small>

## nebelhaus.sill

The menu bar, and which pills it draws.

### `nebelhaus.sill.aiUsage.provider`

`one of "latest", "claude", "codex", "opencode"` · default `"latest"`

Which AI provider to display in the main pill: `latest` (default, automatically
shows whichever provider reported most recently), or one of
`claude`, `codex`, `opencode`.
Clicking the pill always displays the full dropdown with all reporting providers.

Note this is about *usage readouts*, not about which client `wt` can
spawn: a provider reports here whenever it has data for your account —
Codex notably does so from a ChatGPT login alone, with no CLI installed
— so it is deliberately not tied to `nebelhaus.agents.clients`.

Example:

```nix
"claude"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.battery.hideOver`

`null or signed integer` · default `null`

Hide the battery pill when charge percentage is above this threshold
(e.g., set to 80 to show the battery pill only when charge is at or below 80%).

Example:

```nix
80
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.clock.mode`

`one of "full", "compact"` · default `"full"`

The display mode for the clock pill: `full` (default, e.g. "Fri Jul 31  09:41 AM" with calendar icon)
or `compact` (e.g. "Fri 31/7 9:41" without icon and trimmed spacing).

Example:

```nix
"compact"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.elgato.host`

`string` · default `""`

Which Elgato Key Light the `elgato` pill toggles — a hostname or IP,
optionally with a `:port` (the light's HTTP API is on 9123).

Empty (the default) means discover it: the pill browses mDNS for
`_elg._tcp`, caches what it found in
`~/.local/state/nebelhaus/elgato-host`, and re-browses at most once a
minute whenever the light stops answering — so a light that took a new
DHCP address comes back on its own, without a rebuild. Pin this when
you have more than one light, when the light has a static lease, or
when mDNS is unreliable on your network.

Example:

```nix
"elgato-key-light-mini-57a3.local"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.enable`

`boolean` · default `true`

The SketchyBar menu bar. When off, the native macOS menu bar is kept
(nebelhaus stops hiding it) and no bar is drawn.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items`

`submodule` · default `{ }`

Which SketchyBar pills to draw, one bool each. The core pills —
`clock`, `weather`, `media`, `battery`, `wifi` — default true; the extras
— the readouts `cpu`, `memory`, `volume`, `calendar`, `caffeinate`
and the personal `agents`, `aiUsage`, `elgato`, `harvest` —
default false. Set
only what you want to change:

  nebelhaus.sill.items = {
    weather = false;   # drop a default-on core pill
    cpu = true;        # add an off-by-default readout
    caffeinate = true; # add the keep-awake controller
  };

A pill set false is never created (its update script doesn't run either).
The hush (Do-Not-Disturb) pill is separate — it rides
nebelhaus.hush.enable, not this set.

Example:

```nix
{
  cpu = true;
  weather = false;
}
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.agents`

`boolean` · default `false`

A paw pill tracking your agent-worktree panes — amber when one is blocked on you, click for the per-agent list, each row marked with the client sitting in it; left-click a row to jump to that pane, ⌥/right-click for a live `zellij subscribe` peek. Fed by each client's own lifecycle hooks, which all call `agent-state` (also installed as ~/.config/sketchybar/plugins/agents-hook.sh): Opencode's plugin and Codex's ~/.codex/hooks.json are written for you (Codex asks you to trust its hooks the first time it sees them), while Claude Code's four agent-state hooks stay yours to point at it in ~/.claude/settings.json — Claude owns that file and rewrites it, so the rice merges in only the keys it must and never touches those four. (The two worktree hooks ARE declared, in hearth: they point at a rice-controlled path and self-heal on rebuild.) A row whose zellij pane is gone drops off by itself, which is what stands in for the session-end event Codex doesn't have. Dormant until a client fires.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.aiUsage`

`boolean` · default `false`

A gauge pill showing AI usage (Claude Code/Codex subscription rate limits as %, or Opencode API token cost as daily $). Automatically shows whichever provider reported most recently. Click for expanded session/weekly limits and daily/monthly API costs with model breakdowns. Claude and Opencode are read off disk; Codex has no local usage data, so its row is polled from your ChatGPT account with the OAuth token in ~/.codex/auth.json (refreshed and rewritten in place) — no Codex login on the machine, no call is made. Claude's row is pushed by its statusline; the Codex and Opencode rows are pulled by the pill itself on a 3-minute TTL, so they stay current on a machine that never opens Claude at all. Claude and Opencode also get a `tokens` block in the dropdown — raw tokens moved today, this week, this month and all time (cache reads and all), two periods to a line so a full set reads as a 2×2, purely for the fun of watching the number climb. A period with nothing in it is left out rather than printed as a zero, so the block simply gets smaller, and a closing `∑ Everything` adds every provider up when more than one is reporting. It is a score, not a limit: nothing acts on it, and it never reaches the pill's own label. Claude's is summed from your transcripts on a 15-minute TTL behind an index, so only sessions that grew since the last pass are re-read; Codex has no row because it keeps no local history to count.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.battery`

`boolean` · default `true`

The battery pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.caffeinate`

`boolean` · default `false`

A coffee pill that prevents idle system sleep for 1/2/4/8 hours, a custom whole-hour duration, or indefinitely. The display may still turn off; closing a MacBook lid still sleeps it. Uses macOS's built-in `caffeinate`, so there is no extra package.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.calendar`

`boolean` · default `false`

Your next timed event, with a click-popup of the next five. Pulls in `ical-buddy` automatically and reads Calendar, so macOS prompts for Calendar access on first run.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.claudeUsage`

`boolean` · default `false`

Deprecated alias for `aiUsage`.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.clock`

`boolean` · default `true`

The clock pill, pinned to the far right.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.cpu`

`boolean` · default `false`

Total CPU load, as a percentage pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.elgato`

`boolean` · default `false`

Toggles an Elgato Key Light on the local network. The light is found over mDNS (or pinned with `nebelhaus.sill.elgato.host`), and the pill draws dim when it can't be reached at all — a light that dropped off the wifi is not the same thing as a light that's switched off.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.harvest`

`boolean` · default `false`

A Harvest time-tracking pill; needs a ~/.config/sketchybar/harvest_secrets.sh you provide.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.media`

`boolean` · default `true`

The now-playing track (scrolls; auto-hides when nothing plays).

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.memory`

`boolean` · default `false`

Memory-pressure percentage pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.volume`

`boolean` · default `false`

Output volume / mute state.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.weather`

`boolean` · default `true`

The weather pill and its click-to-open forecast popover.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.items.wifi`

`boolean` · default `true`

The Wi-Fi status pill.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.sill.position`

`one of "top", "bottom", "auto"` · default `"top"`

Where the bar sits. `top` and `bottom` pin it there. `auto` flips it
at runtime — `bottom` whenever an external display is attached (docked
with the lid open, or clamshell), `top` on the built-in display alone —
driven by a `display_change` hook, so the bar moves the moment you dock
or undock, without a rebuild.

The bar's height/pill offsets are tuned for the notch, which only
exists at the top of the built-in display; at `bottom` there's no notch
to tuck under, so `auto` conveniently keeps the notch case (`top`) on
the notched screen and the plain case (`bottom`) on the external.

Example:

```nix
"auto"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

## nebelhaus.pounce

The ⌘Space command palette.

### `nebelhaus.pounce.enable`

`boolean` · default `true`

The pounce command palette daemon (⌘Space) + its rice commands.

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.followSystemAppearance`

`boolean` · default `true`

Let the palette follow macOS Light/Dark Mode instead of pinning one
polarity: pounce gets the nebelung variant AND its latte counterpart at
your nebelhaus.theme.contrast, as its `theme`/`themeLight` pair, and
picks between them per open (no rebuild, no daemon restart).

Honest scope: this makes pounce the one themed tool that does NOT follow
nebelhaus.theme.flavor — a flavor pin is a *palette* choice, and asking
to follow the system says the polarity is macOS's call. The contrast
axis still applies to both halves. Everything else on the rice keeps
whatever flavor pins.

false pins pounce to the flavor like every other port, which is exactly
what it did before this option existed.

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.items`

`attribute set of (submodule)` · default `{ }`

Per-item palette settings, keyed by the item's own address. One entry is
one row of the palette: hide it, give it a search shorthand, give it a key.

  "cmd:<id>"                       a command, by script name without .sh
  "app:/Applications/Foo.app"      an application, by path
  "mode:<name>"                    a built-in window — launcher, clipboard,
                                   emoji, screenshots, camera, filesearch

Those keys are pounce's own address space (the same strings its frecency
store and `pounce run` use), so a key written here is also what you'd type
to invoke the thing from a script or another tool's binding.

Hotkeys can be a single chord ("opt+e") or a LEADER SEQUENCE — steps
separated by spaces, modifiers by "+", the notation Emacs and VS Code use:

  hotkey = "opt+space e";          # ⌥Space, then E
  hotkey = [ "cmd+k" "cmd+c" ];    # the same thing, step by step

Sequences are worth knowing about on a tiling rice: they open a namespace
that structurally can't collide with the ⌥/⌘ chords prowl already claims,
and they need no Accessibility grant (pounce grabs the second step as an
ordinary global hotkey for a couple of seconds rather than tapping events).

Two things this checks at build time, because both fail SILENTLY at
runtime: a key that names no real item shape (a "mode:" typo binds
nothing at all), and a chord already claimed by nebelhaus.keys.palette or
nebelhaus.keys.leader (whoever registers first wins, and it isn't always
the same one). What it can't check is whether `cmd:<id>` names a command
that exists — command scripts are discovered at runtime, so pounce warns
about that itself when the daemon starts, and `pounce doctor` lists any
binding that failed to arm.

Example:

```nix
{
  "app:/Applications/Ghostty.app" = {
    hotkey = "opt+t";
  };
  "cmd:brew-services" = {
    listed = false;
  };
  "cmd:emoji" = {
    alias = "emo";
    hotkey = "opt+e";
  };
  "mode:clipboard" = {
    hotkey = "cmd+shift+v";
  };
}
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.items.<name>.alias`

`null or string` · default `null`

A search shorthand, matched at a bonus over the item's real name —
so "emo" can find the Emoji Picker without renaming it.

Example:

```nix
"emo"
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.items.<name>.caption`

`null or string` · default `null`

How this item reads on the cheatsheet page that lists your item
hotkeys (⌘Space then ⇥, or the leader's `/`). Only used when the
item has a `hotkey` — a row without a key has nothing to teach.

Defaults to a name derived from the key, which is right often
enough to leave alone: `mode:clipboard` becomes "Clipboard
history", `app:/Applications/Ghostty.app` becomes "Ghostty", and
`cmd:brew-services` becomes "Brew services". Set this when the
derived name isn't what the palette actually calls the row — the
rice can't read a command's own `# pounce: name` header at
evaluation time, so that one is a guess.

Example:

```nix
"Clipboard history"
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.items.<name>.hotkey`

`null or string or list of string` · default `null`

A global chord, or a leader sequence, that invokes this item
directly without opening the palette first. Modifier names follow
pounce's spelling: cmd/command/super/meta · opt/option/alt ·
ctrl/control · shift.

Whether the KEY name is one pounce can bind is not checked here
(that vocabulary lives in the app); a chord it can't register is
reported by `pounce doctor` rather than silently dropped.

Example:

```nix
"opt+space e"
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.items.<name>.listed`

`boolean` · default `true`

Whether the item appears in the palette's list.

Named `listed` rather than `enable` because that is precisely what
it does: false removes the ROW, and a `hotkey` on the same item
keeps working. It's how you hide a command you only ever want to
reach by key — or clear the launcher of tools someone else on this
Mac has no use for, which is the closest thing to a "pack" the
surface has today. (It writes pounce's own `enabled` key.)

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.scale`

`integer or floating point number between 0.8 and 2.0 (both inclusive)` · default `nebelhaus.ui.scale, held inside pounce's 0.8-2.0`

How big the palette is drawn. Multiplies every size in pounce's UI — the
launcher's rows, header, icons and action bar, and the panels behind it:
the emoji grid, clipboard history, recent screenshots, camera peek, Find
Files, the cheatsheet and the window switcher.

Follows nebelhaus.ui.scale by default, so you rarely set this directly.
It exists as its own option for the case where the palette wants a
different size from the rest of the rice — the launcher is read at arm's
length for a second, not lived in like the terminal.

pounce's own range is narrower than ui.scale's, so a rice at
`ui.scale = 2.5` gets a palette at 2.0 rather than an evaluation error.

Two things adapt on their own, which is why one number is enough: the
launcher shows fewer rows when the scaled rows stop fitting on screen, and
every panel's width is held inside the visible frame. That matters most
alongside `nebelhaus.displays.<name>.uiScale` — a larger-text display mode
and a larger palette multiply, and the palette is the one that would
otherwise run off the edge.

Example:

```nix
1.4
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.signingIdentity`

`string` · default `""`

A code-signing identity in your login keychain — either its SHA-1 or
(preferred) its full common name. The pounce daemon is re-signed with
it so a macOS Accessibility (TCC) grant survives rebuilds. List yours:
  security find-identity -v -p codesigning

Prefer a "Developer ID Application" identity passed BY NAME (e.g.
"Developer ID Application: Jane Doe (TEAMID)"): its designated
requirement anchors on the stable team OU, so the grant survives even
a certificate renewal (the renewed cert keeps the same name/team but
gets a new SHA — a hardcoded SHA would silently fall back to unsigned).
This is also the identity the Homebrew build is signed with, so both
install paths share one identity. An "Apple Development" cert works too
but expires yearly and pins the specific cert, so it's less durable.

Changing this once invalidates the existing grant (the requirement
changes) — re-approve pounce in Accessibility a single time after.

Leave empty to run pounce unsigned (the palette works, but auto-paste
and other Accessibility-gated features stay off).

Example:

```nix
"Developer ID Application: Jane Doe (ABCDE12345)"
```

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.windowMode`

`one of "default", "compact"` · default `"compact"`

The palette's proportions. `compact` is narrower with tighter rows and
keeps its list hidden until you type — the rice's tuned look, and what it
shipped before this option existed. `default` is pounce's roomier layout,
which shows the top results the moment it opens.

This is shape, not size: how BIG the palette is drawn is
nebelhaus.pounce.scale. The two compose — a compact palette at scale 1.4
is still the compact layout, just readable from further away.

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

### `nebelhaus.pounce.windowSwitcher`

`boolean` · default `true`

Replace the stock ⌘Tab app switcher with pounce's MRU *window* switcher:
tap ⌘⇥ to toggle to the last window (across workspaces), hold ⌘ and keep
tapping ⇥ to walk older ones, type while holding to fuzzy-filter
(frecency-ranked). Rows carry the window's AeroSpace workspace, and
focusing goes through `aerospace focus --window-id` so a window parked
on another workspace surfaces correctly.

Needs the daemon to hold an Accessibility grant — in practice, set
nebelhaus.pounce.signingIdentity so the grant survives rebuilds. Without
the grant the event tap can't install and stock ⌘Tab keeps working, so
this default is safe on a fresh, not-yet-granted install. false leaves
⌘Tab native even when the grant is there.

<small>Declared in [`modules/pounce/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/pounce/options.nix).</small>

## nebelhaus.trill

The Messages client.

### `nebelhaus.trill.enable`

`boolean` · default `true`

The trill Messages client, installed via the trill flake (copied to /Applications).

<small>Declared in [`modules/trill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/trill/options.nix).</small>

### `nebelhaus.trill.followSystemAppearance`

`boolean` · default `true`

Let trill's palette follow macOS Light/Dark Mode instead of pinning one
polarity: trill gets the nebelung variant AND its latte counterpart at
your nebelhaus.theme.contrast, and picks between them itself — no
rebuild, no relaunch.

Same honest scope as the pounce option of the same name: with this on,
trill does NOT follow nebelhaus.theme.flavor, because asking to follow
the system says the polarity is macOS's call. The contrast axis still
applies to both halves. Set it false to pin trill to theme.flavor like
every other themed tool.

Either way this writes only the DEFAULT: a palette chosen in trill's own
Settings ▸ Theme wins over what the rice writes, and so does trill's
appearance preference (Follow macOS / Dark / Light), which lives in its
settings rather than here.

<small>Declared in [`modules/trill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/trill/options.nix).</small>

## nebelhaus.perch

The notch file shelf.

### `nebelhaus.perch.enable`

`boolean` · default `true`

The perch notch file shelf, installed via the perch flake (copied to /Applications).

<small>Declared in [`modules/perch/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/perch/options.nix).</small>

### `nebelhaus.perch.followSystemAppearance`

`boolean` · default `true`

Let the shelf's palette follow macOS Light/Dark Mode instead of pinning
one polarity: perch gets the nebelung variant AND its latte counterpart
at your nebelhaus.theme.contrast, and picks between them itself — no
rebuild, no relaunch.

Same honest scope as the trill and pounce options of the same name: with
this on, perch does NOT follow nebelhaus.theme.flavor, because asking to
follow the system says the polarity is macOS's call. The contrast axis
still applies to both halves. Set it false to pin the shelf to
theme.flavor like every other themed tool.

Perch has no theme picker of its own — the shelf is a five-second
surface with nowhere to put one — so unlike trill, this is the only word
on its colors.

<small>Declared in [`modules/perch/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/perch/options.nix).</small>

## nebelhaus.hush

One quiet switch: Do Not Disturb, optional Slack status, and your hooks.

### `nebelhaus.hush.enable`

`boolean` · default `true`

The hush room: one quiet switch — bar pill, palette command, and a
`hush` CLI — that turns macOS Do Not Disturb on/off (via the
declaratively-bound symbolic hotkey 175, pressed synthetically),
optionally sets your Slack status, and runs your hooks.

Honest scope: hush flips the built-in Do Not Disturb, not named Focus
modes, and it doesn't manage which apps break through — curate that
once in System Settings. The keypress needs an Accessibility grant on
whatever app invokes hush (palette runs inherit pounce's; grant
sketchybar once for the pill). `hush doctor` walks the one-time steps.

<small>Declared in [`modules/hush/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hush/options.nix).</small>

### `nebelhaus.hush.hooks`

`list of (absolute path or string)` · default `[ ]`

Extra scripts run on every hush/unhush, each called with a single
argument "on" or "off". Paths are copied into the store; strings are
run as-is (so $HOME paths work). Failures are logged, never fatal —
a broken hook can't wedge the toggle.

Example:

```nix
[ ./onair-light.sh "/Users/ada/bin/pause-music" ]
```

<small>Declared in [`modules/hush/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hush/options.nix).</small>

### `nebelhaus.hush.slack.enable`

`boolean` · default `false`

Also set a Slack status and snooze Slack notifications (all devices,
phone included) while hushed. Off by default: it needs a personal
Slack user token (scopes users.profile:write + dnd:write) provided
via tokenCommand. The previous status is saved and restored on
unhush.

<small>Declared in [`modules/hush/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hush/options.nix).</small>

### `nebelhaus.hush.slack.snooze`

`boolean` · default `true`

Also pause Slack's own notifications (dnd.setSnooze) while hushed —
this is what silences the phone. Ended on unhush; capped at 24h as
a failsafe if you forget.

<small>Declared in [`modules/hush/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hush/options.nix).</small>

### `nebelhaus.hush.slack.statusEmoji`

`string` · default `":no_bell:"`

Slack status emoji while hushed.

<small>Declared in [`modules/hush/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hush/options.nix).</small>

### `nebelhaus.hush.slack.statusText`

`string` · default `"heads down"`

Slack status text while hushed.

<small>Declared in [`modules/hush/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hush/options.nix).</small>

### `nebelhaus.hush.slack.tokenCommand`

`string` · default `""`

Shell command that prints the Slack user token (xoxp-…) to stdout.
Keychain-first so no secret ever lands in the store or a dotfile:
  security add-generic-password -s hush-slack -a $USER -w 'xoxp-…'

Example:

```nix
"security find-generic-password -s hush-slack -w"
```

<small>Declared in [`modules/hush/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/hush/options.nix).</small>

## nebelhaus.snippets

Text expansion via espanso.

### `nebelhaus.snippets.enable`

`boolean` · default `false`

Text expansion via espanso: type a short trigger (say "@@") and it's
replaced inline with a longer string (your email), in any app —
browsers, Messages, and the terminal. espanso injects keystrokes, so
it works where macOS's own text replacement doesn't (terminals,
many Electron apps).

Off by default: it installs the Espanso.app cask and needs a one-time
macOS Accessibility grant (System Settings → Privacy & Security →
Accessibility → enable Espanso) the first time it runs. The rice runs
the SIGNED app bundle rather than a nix-store binary on purpose, so
that grant is keyed to a stable identity and survives reboots and
nixpkgs bumps — you grant it once, not on every rebuild (and so the
espanso troubleshooting window stops popping up at login, since that
window only ever meant "the grant went missing").

<small>Declared in [`modules/snippets/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/snippets/options.nix).</small>

### `nebelhaus.snippets.matches`

`list of (submodule)` · default `[ ]`

The expansion table — one { trigger; replace; } per snippet, written
to ~/.config/espanso/match/default.yml. Only espanso's plain
trigger→replace form is exposed here; for dynamic matches (dates,
shell output, forms) drop a hand-written .yml alongside it in
~/.config/espanso/match/ — espanso loads every file in that dir.

Example:

```nix
[
  { trigger = "@@"; replace = "ada@example.com"; }
  { trigger = "##"; replace = "+1 555 0100"; }
]
```

<small>Declared in [`modules/snippets/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/snippets/options.nix).</small>

### `nebelhaus.snippets.matches.*.replace`

`string` · no default

What it expands to.

Example:

```nix
"ada@example.com"
```

<small>Declared in [`modules/snippets/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/snippets/options.nix).</small>

### `nebelhaus.snippets.matches.*.trigger`

`string` · no default

What you type.

Example:

```nix
"@@"
```

<small>Declared in [`modules/snippets/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/snippets/options.nix).</small>

## nebelhaus.tour

The first-run tutor.

### `nebelhaus.tour.enable`

`boolean` · default `true`

The haus tour — a first-run tutor that walks the four moves (launch /
navigate / resize / palette) as ONE quiet pill in the bar, advancing
live as each move is detected. It never opens a window or steals
focus: a fresh machine just shows a dormant "new here?" hint, clicking
it (or `haus tour`, or ⌘Space → tour) starts the lap, right-click
hides it forever. Detection reuses signals the rice already fires (the
leader-mode scripts) — no key logging, no Accessibility.

Needs prowl + sill (it silently stays out of the bar without them);
the ⌘Space step is dropped when pounce is off. Progress lives in
~/.local/state/nebelhaus — `haus tour reset` re-arms a finished tour.

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.tour.steps`

`null or (non-empty (list of (submodule)))` · default `null`

A community-authored tour, in order. null keeps the built-in four-move
nebelhaus tour unchanged; supplying a list replaces it, so a shared rice can
teach its own workflow without shipping scripts or reaching outside the
`nebelhaus.*` option surface.

Detection reuses signals the rice already emits. `launch`, `workspace`,
`navigate` and `resize` need prowl; `palette` needs Pounce and its palette
binding. The module warns when a chosen detector's room is disabled.

Example:

```nix
[
  {
    detect = "palette";
    hint = "Press ⌘Space, type tour, then hit ↵";
  }
]
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.tour.steps.*.detect`

`one of "launch", "workspace", "navigate", "resize", "palette"` · no default

The existing rice signal that completes this step: entering launch,
navigate or resize mode; changing workspace; or running the Haus Tour
command from Pounce (`palette`). The tour observes outcomes, never
keystrokes. Clicking the pill still skips a step that cannot be
detected in the current setup.

Example:

```nix
"palette"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

### `nebelhaus.tour.steps.*.hint`

`string` · no default

The instruction shown in the tour pill for this step.

Example:

```nix
"Press ⌘Space, type calendar, then hit ↵"
```

<small>Declared in [`modules/sill/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/sill/options.nix).</small>

## nebelhaus.developer

The developer pack: the CLI toolbelt, Git tooling, coding-agent tooling, and language runtimes. Off is a nebelhaus machine for someone who never opens a terminal by choice.

### `nebelhaus.developer.agents.enable`

`boolean` · default `config.nebelhaus.developer.enable`

Coding-agent *tooling*: `wt` (agent worktrees), `agent-state` (the
pane-status writer behind the `agents` bar pill and the zellij tab
badge), `zscratch`, the agent-worktree statusline, and the client
config hearth writes (Claude Code's settings.json keys, opencode's
agent-state plugin). Which clients get installed is `agents.clients`.

Off is right for any machine not running coding agents — it's a large
surface a non-developer never sees. It also empties `agents.clients`,
since a client with no `wt` to park it is not the deal on offer.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.developer.enable`

`boolean` · default `true`

The developer pack: the CLI toolbelt, Git tooling, coding-agent
tooling, and language runtimes. On (the default) is the rice as it
has always been.

`false` is what makes a non-developer nebelhaus possible — it strips
those tools rather than merely hiding them. What remains is the
product: `haus`, `awake`, the theme, the terminal, the bar, the tiler
and the palette.

The sub-options below each default to THIS value, so turning it off
turns everything off and you can then re-enable one piece:

  nebelhaus.developer.enable = false;
  nebelhaus.developer.git.enable = true;  # …but keep git

Example:

```nix
false
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.developer.git.enable`

`boolean` · default `config.nebelhaus.developer.enable`

Git and its surroundings: the shell alias vocabulary, the themed git
config, delta (diff pager), lazygit, `gh`, and gnupg for commit
signing. Off drops all of them, and `nebelhaus.git.*` then has
nothing to configure.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.developer.languages`

`list of value "node" (singular enum)` · default `[ "node" ] when developer.enable is true, else [ ]`

Language runtimes to install. Currently only "node" (bun + fnm, with
fnm's `--use-on-cd` shell hook).

Deliberately a list rather than one bool per language, so adding
"rust" or "python" later doesn't change this option's shape.

Example:

```nix
[ ]
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.developer.toolbelt.enable`

`boolean` · default `config.nebelhaus.developer.enable`

The terminal toolbelt: bat, fzf, fd, ripgrep, yazi, zoxide, lsd,
glow, jq, tree, chafa, ttyd and fastfetch — the themed replacements
for cat, find, grep, ls and friends that the rice's shell is built
around.

Off leaves a plain shell. The prompt (starship) and the colour scheme
stay: these are the *tools*, not the appearance.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

## nebelhaus.collar

Touch ID for sudo — including inside a terminal multiplexer — and the passwordless-rebuild rule.

### `nebelhaus.collar.enable`

`boolean` · default `true`

The collar room: Touch ID for `sudo`, with `reattach` — the PAM shim
that keeps the prompt working when sudo runs inside a terminal
multiplexer (tmux/zellij/screen), where it otherwise beachballs.

Off means macOS's stock password prompt everywhere, including for the
rebuild below. Nothing else in the rice depends on it.

<small>Declared in [`modules/collar/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/collar/options.nix).</small>

### `nebelhaus.collar.passwordlessRebuild`

`boolean` · default `true`

Exempt system activation from authenticating at all: a sudoers rule
granting NOPASSWD to `darwin-rebuild` and `haus-activate` at their
stable /run/current-system paths. This is what makes `haus rebuild`,
`haus rollback` and `bench try switch` a single uninterrupted command
rather than one that stops for a fingerprint you already gave.

Honest scope: this is a real root grant, and both commands take a path
or flake ref you choose — so it means "anything I can build, I can
activate as root, unprompted". That is the whole point (you already
authenticated to build it), but on a shared or managed machine it's the
knob to turn off. With it off, activation prompts via Touch ID (or a
password when `enable` is false) and nothing else changes.

<small>Declared in [`modules/collar/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/collar/options.nix).</small>

## nebelhaus.secrets

Where secret values come from on this machine.

### `nebelhaus.secrets.provider`

`null or string` · default `"keyring"`

The secretspec provider that supplies secret VALUES on this machine.
The secrets room writes it to ~/.config/secretspec/config.toml as the
default provider, so `secretspec run / check / set` work without
flags. Any provider string secretspec accepts, URIs included:
"keyring" (macOS login keychain — local, no accounts), "onepassword",
"bws" (Bitwarden Secrets Manager), "gcsm" (Google Cloud Secret
Manager), "awssm" (AWS Secrets Manager), "vault", "pass",
"protonpass", "lastpass", "dotenv", "env", or a scoped URI like
"onepassword://account@vault".

WHICH secrets exist is not declared here — that's each project's
committed secretspec.toml. Cloud providers authenticate with their own
credentials, configured outside Nix (e.g. `gcloud auth
application-default login` for gcsm); that login is the one manual
step on a new Mac. null skips writing the config file entirely — run
`secretspec config init` yourself.

Example:

```nix
"gcsm"
```

<small>Declared in [`modules/secrets/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/secrets/options.nix).</small>

## nebelhaus.homebrew

How rebuilds treat Homebrew packages you did not declare.

### `nebelhaus.homebrew.autoUpdate`

`boolean` · default `false`

Run `brew update` before activating the Homebrew step on every
rebuild. Off by default — reproducible rebuilds shouldn't silently
pull newer formulae. Turn on if you want brew to track upstream.

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.homebrew.cleanup`

`one of "none", "uninstall", "zap"` · default `"none"`

How `darwin-rebuild switch` treats Homebrew casks/brews that are
installed but NOT declared anywhere in your config.

- "none" (default, safe): leave undeclared formulae/casks alone. The
  rice never deletes apps you installed yourself.
- "uninstall": remove undeclared formulae/casks (keeps their data).
- "zap": remove undeclared formulae/casks AND their app data. Fully
  declarative, but a stray cask you forgot to list is deleted — with
  no backup — on the very next rebuild. Only choose this once every
  app you keep is declared (bootstrap can adopt your current casks).

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>

### `nebelhaus.homebrew.upgrade`

`boolean` · default `false`

Upgrade outdated Homebrew packages on every rebuild. Off by default
for the same reproducibility reason as autoUpdate.

<small>Declared in [`modules/den/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/den/options.nix).</small>
