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

## nebelhaus.apps

The shared app roster: one entry per app, driving the launcher key, its workspace, the bar pill, the cheatsheet, and optionally its Homebrew cask.

### `nebelhaus.apps`

`attribute set of (submodule)` · default `{ }`

The shared app roster, keyed by a stable app id. This is the canonical,
composable source for AeroSpace launcher keys and workspaces,
SketchyBar pills, the pounce cheatsheet, and optional Homebrew casks.

Attribute-set entries merge across Nix modules, so a host, an imported
file, and pounce's "Install App" command can each contribute one app
without parsing or replacing a monolithic list. Set an entry's enable
field to false to remove it, or override individual fields by app id.

Example:

```nix
{
  slack = {
    key = "s";
    name = "Slack";
    workspace = "S";
    appId = "com.tinyspeck.slackmacgap";
    barIcon = ":slack:";
    cask = "slack";
  };
}
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.apps.<name>.appId`

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

### `nebelhaus.apps.<name>.barIcon`

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

### `nebelhaus.apps.<name>.cask`

`null or string` · default `null`

Homebrew cask that installs this app. When set, it's appended to
homebrew.casks so declaring the app also installs it. null means
"already present / installed some other way" (e.g. Safari, Music).

Example:

```nix
"slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.apps.<name>.enable`

`boolean` · default `true`

Whether this app participates in the shared launcher roster.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.apps.<name>.key`

`string` · no default

The leader letter for this app: tap Caps Lock then this key to
launch/focus it. Must be unique across the roster.

Example:

```nix
"s"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.apps.<name>.label`

`null or string` · default `null`

Cheatsheet caption for the leader key. null uses name.

Example:

```nix
"Slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.apps.<name>.name`

`string` · no default

macOS application name, as passed to `open -a`.

Example:

```nix
"Slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.apps.<name>.order`

`signed integer` · default `1000`

Roster order; lower values appear first. Ties are sorted by app id.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus.apps.<name>.workspace`

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

Theme the apps in your roster (`nebelhaus.apps`) that Nebelung ships a
port for, without wiring each one by hand.

The rice already themes every tool it installs itself — the shell, the
terminal, the git stack, Zen, Obsidian. This covers the other direction:
an app YOU added to the roster that Nebelung happens to have a theme for.
Add `zed`, `warp` or `xcode` to `nebelhaus.apps` and its Nebelung theme
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

## nebelhaus.claude

Claude Code integration.

### `nebelhaus.claude.globalMd`

`strings concatenated with "\n"` · default `""`

Contents of Claude Code's global memory file, written to
~/.claude/CLAUDE.md (hearth wires it into home-manager). This is your
personal, cross-project operating context. When set, the rice prepends
one short section of its own — the `wt child` worktree rule, since the
rice ships `wt` and that rule is what keeps it working — then your text.
Leave it empty to manage ~/.claude/CLAUDE.md fully by hand (nothing is
written, so the rice never clobbers a by-hand file).

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
file is) and a starter CLAUDE.md for your config repo.

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
and the personal `agents`, `elgato`, `harvest` — default false. Set
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

A paw pill tracking your `claude --worktree` agent panes — amber when one is blocked on you, click for the per-agent list; left-click a row to jump to that pane, ⌥/right-click for a live `zellij subscribe` peek. Fed by Claude Code hooks (point them at ~/.config/sketchybar/plugins/agents-hook.sh); dormant until they fire.

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

Toggles an Elgato Key Light on the local network.

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

## nebelhaus.developer
### `nebelhaus.developer.agents.enable`

`boolean` · default `config.nebelhaus.developer.enable`

Coding-agent tooling: `wt` (Claude Code agent worktrees), `zscratch`,
the agent-worktree statusline, opencode, and the Claude Code settings
and hooks hearth writes.

Off is right for any machine not running coding agents — it's a large
surface a non-developer never sees.

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

The terminal toolbelt: bat, fzf, fd, yazi, zoxide, lsd, glow, jq,
tree, chafa, ttyd and fastfetch — the themed replacements for cat,
find, ls and friends that the rice's shell is built around.

Off leaves a plain shell. The prompt (starship) and the colour scheme
stay: these are the *tools*, not the appearance.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

## nebelhaus.keys
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
(`<mod>` + `/` `,`), fullscreen, workspace back-and-forth, moving a
workspace to the next monitor (`<mod>⇧⇥`), and entering service mode
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
`/` `,`, `f`, `⇥`, `⇧⇥` and `⇧;`, none of which a roster letter can
land on. (Under "ctrl-alt" that used to bite — the throws were `⌃⌥⇧` +
an app's roster letter, so an app on `c` silently ate hearth's zellij
`Ctrl Alt Shift c` in-place-agent bind. That collision is gone.)
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

## nebelhaus.perch
### `nebelhaus.perch.enable`

`boolean` · default `true`

The perch notch file shelf, installed via the perch flake (copied to /Applications).

<small>Declared in [`modules/perch/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/perch/options.nix).</small>

## nebelhaus.ui
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
  - the Dock icon size (system.defaults.dock.tilesize)
  - prowl's window gaps

What it deliberately does NOT move:

  - Sill's menu bar. Its height is tuned to sit inside the macOS
    menu-bar band so the hover-reveal covers it exactly; scaling that
    linearly breaks the alignment rather than making it bigger. The bar
    needs its own sizing pass, not a multiplier.
  - anything outside nebelhaus. macOS has no system-wide UI scale, so
    third-party apps follow only a display-resolution change.

Example:

```nix
1.35
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>
