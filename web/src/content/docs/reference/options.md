---
title: nebelhaus.* options
description: Every option you can set in your host file — types, defaults, and what each one changes.
tableOfContents:
  maxHeadingLevel: 2
---

These are the `nebelhaus.*` options you set in your host file at
`~/.config/nix/hosts/<hostname>/default.nix`. They're defined in the rice's
`modules/options.nix`. Everything here is optional unless noted; the defaults
are a complete, working system.

Apply changes with `haus rebuild`. Each option below lists its **type** and
**default** on the line under its name.

## nebelhaus.git

Your commit identity — set your own. It stays in [your host file](/internals/flakes/#your-config-is-a-thin-consumer).

### `nebelhaus.git.name`
`str` · default `""`

Git `user.name` for commits.

### `nebelhaus.git.email`
`str` · default `""`

Git `user.email` for commits.

### `nebelhaus.git.signingKey`
`str` · default `""`

GPG key id for signing commits/tags. Empty disables signing. Key material lives outside Nix (`gpg-agent` + `pinentry-mac`).

```nix
nebelhaus.git.name = "Ada Lovelace";
nebelhaus.git.email = "ada@example.com";
nebelhaus.git.signingKey = "6F7BD6F43A7C1420";
```

## nebelhaus.theme

### `nebelhaus.theme.accent`
enum · default `"mauve"`

Accent hue. One of `rosewater`, `flamingo`, `pink`, `mauve`, `red`, `maroon`, `peach`, `yellow`, `green`, `teal`, `sky`, `sapphire`, `blue`, `lavender`. Re-tints lazygit, fzf, yazi, and the Zen browser; the neutral greys stay fixed.

See [Theming & accents](/guides/theming/) and the [palette](/reference/palette/).

### `nebelhaus.theme.wallpaper`
enum · default `"none"`

The desktop wallpaper, applied at each rebuild. One of `none`, `orbits`, `constellation`, `flow`, `bold`. The first three are hand-made with the palette baked in; `bold` is generated from your `theme.accent`, so it follows the accent. `none` leaves your current wallpaper alone — changing the desktop is personal, so nothing moves unless you ask (the install interview offers the choice).

## nebelhaus.hearth

The shell and terminal layer. See [The shell](/guides/the-shell/).

### `nebelhaus.hearth.editor`
`str` · default `"hx"`

The one editor the rice uses everywhere: `$EDITOR` / `$VISUAL` **and** what every "open in an editor" action launches (the "Nix Config" palette command, the bar's nix-open item, the file-association hijack) — opened in a new zellij tab. A terminal editor is recommended; a GUI editor's CLI works too (e.g. `"code"` or `"code -w"` to block).

### `nebelhaus.hearth.hijackFileAssociations`
`bool` · default `false`

When `true`, makes `hearth.editor` the default opener for `.json`/`.md`/`.ts`/`.nix`/… via `duti`. Opt-in; changes double-click behaviour.

### `nebelhaus.hearth.obsidianVaults`
`listOf str` · default `[]`

Home-relative paths to existing Obsidian vaults that should use the full
Nebelung theme. On each rebuild, Hearth copies the generated theme into every
listed vault, selects its dark appearance, and removes the obsolete `nebelung`
CSS snippet from the enabled list. Other `appearance.json` settings are
preserved.

Paths must be relative, may not contain `..`, and must already contain an
`.obsidian` directory. Missing vaults are skipped with a warning.

```nix
nebelhaus.hearth.editor = "nvim";
nebelhaus.hearth.obsidianVaults = [
  "Library/Mobile Documents/iCloud~md~obsidian/Documents/notes"
];
```

## nebelhaus.prowl

Tiling and the Caps-Lock launcher. See [Window management](/guides/window-management/).

### `nebelhaus.prowl.enable`
`bool` · default `true`

Toggle AeroSpace tiling, the Caps-Lock launcher, and window-management keybinds.

### `nebelhaus.prowl.apps`
`listOf submodule` · default terminal + browser

The single source of truth for the launcher letters, workspace assignment, and bar pills.

Each entry in `nebelhaus.prowl.apps` is a submodule with these fields:

- **`key`** — `str` — Leader letter (unique across the roster).
- **`name`** — `str` — macOS app name (used by `open -a`).
- **`workspace`** — `str` / `null` — AeroSpace workspace letter; `null` = launcher-only.
- **`appId`** — `str` / `null` — Bundle id for auto-assigning windows. `null` skips it. Find with `osascript -e 'id of app "…"'`.
- **`barIcon`** — `str` / `null` — SketchyBar app-font ligature (e.g. `:slack:`); `null` uses the workspace letter.
- **`label`** — `str` / `null` — Cheatsheet caption; `null` uses `name`.
- **`cask`** — `str` / `null` — Homebrew cask to install; `null` if already installed.

```nix
nebelhaus.prowl.apps = [
  { key = "s"; name = "Slack"; workspace = "S";
    appId = "com.tinyspeck.slackmacgap"; barIcon = ":slack:";
    label = "Slack"; cask = "slack"; }
];
```

## nebelhaus.sill

The status bar. See [The bar](/guides/the-bar/).

### `nebelhaus.sill.enable`
`bool` · default `true`

Toggle SketchyBar. When on, the native macOS menu bar is hidden.

### `nebelhaus.sill.items`
`submodule` (one `bool` per pill) · default `{}`

Which bar pills to draw, one bool each. Set only what you want to change. The **core** pills — `clock`, `weather`, `media`, `battery`, `wifi` — default `true`; the **extras** default `false`: readouts `cpu` (load %), `memory` (pressure %), `volume` (output level / mute), `calendar` (next event + a popup of the next five; pulls in `ical-buddy` and reads Calendar), and `caffeinate` (launchd-owned keep-awake presets for 1/2/4/8 hours, custom hours, or indefinitely, backed by the built-in `awake` CLI), plus the personal `agents` (a pill tracking your Claude agent panes), `elgato` (toggle an Elgato Key Light), and `harvest` (a Harvest time tracker — reads `~/.config/sketchybar/harvest_secrets.sh`, which you provide). A pill set `false` is never created and its update script doesn't run.

```nix
nebelhaus.sill.items = {
  weather = false;
  cpu = true;
  caffeinate = true;
};
```

See [The bar](/guides/the-bar/#toggling-bar-items).

## nebelhaus.pounce

The command palette. See [Pounce](/guides/pounce/) and its [config reference](/reference/pounce/).

### `nebelhaus.pounce.enable`
`bool` · default `true`

Toggle the Pounce daemon, the ⌘Space palette, and its Accessibility features.

### `nebelhaus.pounce.signingIdentity`
`str` · default `""`

A code-signing identity — the daemon is re-signed with it so the Accessibility grant survives rebuilds. Takes either the identity's full common name or its SHA-1; prefer the name:

```nix
nebelhaus.pounce.signingIdentity = "Developer ID Application: Jane Doe (ABCDE12345)";
```

A **Developer ID Application** identity named this way is the durable choice — it matches on the team OU, so the grant survives certificate renewal. An Apple Development SHA-1 works but pins one certificate, and those expire yearly. List yours with `security find-identity -v -p codesigning`.

Changing this value changes pounce's code identity, which invalidates the existing TCC grant — macOS asks you to approve Accessibility once more after the next rebuild. Empty runs unsigned (palette works; auto-paste off).

### `nebelhaus.pounce.windowSwitcher`
`bool` · default `true`

Replace the stock ⌘Tab app switcher with pounce's MRU *window* switcher — ⌘⇥ toggles to the last window (across workspaces), hold ⌘ and tap ⇥ to walk older ones, type to fuzzy-filter (frecency-ranked). Focus routes through AeroSpace so a window parked on another workspace surfaces. Needs the daemon's Accessibility grant (set `signingIdentity` so it survives rebuilds); without it, stock ⌘Tab keeps working.

## nebelhaus.hush

The quiet switch. See [Focus & DND](/guides/hush/).

### `nebelhaus.hush.enable`
`bool` · default `true`

Toggle the hush room: the bell pill, the "Toggle Hush" palette command, and the `hush` CLI. The room binds the Do Not Disturb symbolic hotkey (175) declaratively on every rebuild.

### `nebelhaus.hush.slack.enable`
`bool` · default `false`

Also set a Slack status and snooze Slack notifications (phone included) while hushed. Needs `tokenCommand`. The previous status is saved and restored on unhush.

### `nebelhaus.hush.slack.tokenCommand`
`str` · default `""`

Shell command that prints your Slack user token (`xoxp-…`, scopes `users.profile:write` + `dnd:write`). Keychain-first: `security find-generic-password -s hush-slack -w`.

### `nebelhaus.hush.slack.statusText` / `statusEmoji`
`str` · defaults `"heads down"` / `":no_bell:"`

The status shown while hushed.

### `nebelhaus.hush.slack.snooze`
`bool` · default `true`

Pause Slack's own notifications (all devices) while hushed; ended on unhush, capped at 24h as a failsafe.

### `nebelhaus.hush.hooks`
`listOf (path or str)` · default `[]`

Extra scripts run on every hush/unhush, each called with `on` or `off`. Paths are copied into the store; strings run as-is. Failures log, never block the toggle.

## nebelhaus.trill

The [Trill](https://github.com/nebelhaus/trill) Messages client — a native
iMessage/SMS/RCS client that reads `chat.db` read-only. Installed as a Homebrew
cask from the nebelhaus tap. See the [Trill guide](/guides/trill/).

### `nebelhaus.trill.enable`
`bool` · default `true`

Install the Trill Messages client. First launch needs **Full Disk Access**
(granted to the app bundle, not Terminal) to read `~/Library/Messages/chat.db`;
sending prompts for **Automation** on first use. Set `false` to leave it out.

## nebelhaus.tour

### `nebelhaus.tour.enable`
`bool` · default `true`

The first-run **haus tour** — one quiet bar pill that walks the four moves
(launch / navigate / resize / palette), advancing as each is detected. Needs
prowl + sill (it silently stays out of the bar without them); the palette step
drops when pounce is off. A fresh machine shows a dormant "new here?" hint;
`haus tour` or ⌘Space → tour starts the lap, right-click hides it forever.

## nebelhaus.homebrew

Homebrew *policy* — not the casks/brews themselves (those go in `homebrew.casks`
/ `homebrew.brews`).

### `nebelhaus.homebrew.cleanup`
enum · default `"none"`

How `switch` treats undeclared Homebrew packages: `"none"` (leave alone — the rice never deletes your apps), `"uninstall"` (remove, keep data), `"zap"` (remove + data).

### `nebelhaus.homebrew.autoUpdate`
`bool` · default `false`

Run `brew update` before every activation. Off for reproducibility.

### `nebelhaus.homebrew.upgrade`
`bool` · default `false`

Upgrade outdated packages on every rebuild. Off for reproducibility — so a
cask stays on the version brew first installed until you bump it. Turn both
this and `autoUpdate` on (ideally per-host) to keep casks like trill tracking
upstream latest; see [Keeping casks current](/guides/making-it-yours/#homebrew-behaviour).

### `nebelhaus.homebrew.installsFile`
`path | null` · default `null`

Optional machine-editable JSON used by Pounce's **Install App** command:

```json
{ "casks": ["obsidian"], "brews": ["wget"], "nixpkgs": ["ripgrep"] }
```

Homebrew casks and formulae merge into their corresponding nix-darwin lists;
Nixpkgs attribute paths merge into `environment.systemPackages`. The file must
be tracked by the consumer flake's Git repository so Nix can read it. See
[Adding apps & tools](/guides/adding-apps/).

## nebelhaus.claude

### `nebelhaus.claude.globalMd`
`lines` · default `""`

Contents of `~/.claude/CLAUDE.md` (cross-project context for Claude Code). The rice ships no opinion; leave empty to manage by hand.

## A complete example host file

```nix
{ pkgs, ... }:
{
  # Identity
  nebelhaus.git.name = "Ada Lovelace";
  nebelhaus.git.email = "ada@example.com";
  nebelhaus.git.signingKey = "";
  nebelhaus.pounce.signingIdentity = "";

  # Preferences
  nebelhaus.theme.accent = "sapphire";
  nebelhaus.hearth.editor = "nvim";

  # Your app roster (merged with the rice defaults)
  nebelhaus.prowl.apps = [
    { key = "s"; name = "Slack"; workspace = "S";
      appId = "com.tinyspeck.slackmacgap"; barIcon = ":slack:"; cask = "slack"; }
  ];

  # Extra apps with no launcher key
  homebrew.casks = [ "discord" ];

  # Your own packages
  home-manager.users.ada.home.packages = with pkgs; [ ripgrep ];
}
```

For how these fit into the flake, see [How the flakes fit together](/internals/flakes/).
