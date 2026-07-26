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
here, it gets a SketchyBar pill, and ⌥⇧<key> throws a window to
it. null makes the app "launcher-only": the leader still opens
it in the current workspace, but it claims no workspace, pill,
or auto-assign rule (e.g. Passwords).

Example:

```nix
"S"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

## nebelhaus.theme

Colour and wallpaper.

### `nebelhaus.theme.accent`

`one of "rosewater", "flamingo", "pink", "mauve", "red", "maroon", "peach", "yellow", "green", "teal", "sky", "sapphire", "blue", "lavender"` · default `"mauve"`

The accent colour, a Catppuccin Mocha name (the Nebelung palette is a
grey-tinted Mocha). It recolours the tools nebelhaus injects colours
into — lazygit, fzf, yazi, and the Zen browser — via the matching
Nebelung per-accent ports.

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

`positive integer, meaning >0` · default `19`

Terminal font size in points. The single most useful knob for a
larger-text machine, since it moves everything the rice actually
lives in.

19 is the default for a reason worth knowing: the Ghostty window is
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
locked; the bar's bottom-right quick-hint block only shows in Locked
mode. Set false to start in Normal mode (zellij's own default).

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

AeroSpace tiling window management + the Caps-Lock leader launcher.

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

## nebelhaus._apps
### `nebelhaus._apps.*.appId`

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

### `nebelhaus._apps.*.barIcon`

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

### `nebelhaus._apps.*.cask`

`null or string` · default `null`

Homebrew cask that installs this app. When set, it's appended to
homebrew.casks so declaring the app also installs it. null means
"already present / installed some other way" (e.g. Safari, Music).

Example:

```nix
"slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus._apps.*.enable`

`boolean` · default `true`

Whether this app participates in the shared launcher roster.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus._apps.*.key`

`string` · no default

The leader letter for this app: tap Caps Lock then this key to
launch/focus it. Must be unique across the roster.

Example:

```nix
"s"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus._apps.*.label`

`null or string` · default `null`

Cheatsheet caption for the leader key. null uses name.

Example:

```nix
"Slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus._apps.*.name`

`string` · no default

macOS application name, as passed to `open -a`.

Example:

```nix
"Slack"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus._apps.*.order`

`signed integer` · default `1000`

Roster order; lower values appear first. Ties are sorted by app id.

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>

### `nebelhaus._apps.*.workspace`

`null or string` · default `null`

The AeroSpace workspace this app owns — its window auto-moves
here, it gets a SketchyBar pill, and ⌥⇧<key> throws a window to
it. null makes the app "launcher-only": the leader still opens
it in the current workspace, but it claims no workspace, pill,
or auto-assign rule (e.g. Passwords).

Example:

```nix
"S"
```

<small>Declared in [`modules/options.nix`](https://github.com/nebelhaus/nebelhaus/blob/main/modules/options.nix).</small>
