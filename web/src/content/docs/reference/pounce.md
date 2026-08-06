---
title: Pounce config & CLI
description: Every config key, CLI flag, and file path for the Pounce command palette.
---

Reference for configuring and driving [Pounce](/guides/pounce/). For writing
your own commands, see [Writing pounce commands](/guides/pounce-commands/).

## Config file

Pounce reads `~/.config/pounce/config.json`. Every key is optional; the file is
re-read each time the palette opens (no daemon restart needed).

### Start from a config that documents itself

```sh
pounce config init      # writes ~/.config/pounce/config.json
pounce config print     # …or just look at it, touching nothing
```

That writes **every** setting at its default, with a sentence above it, all
commented out — so the file changes nothing until you uncomment a line, and you
make it minimal by deleting the lines you never touched. Nothing below needs to
be memorised or copied out of this page.

It never overwrites a config you already have: it writes `config.json.new` beside
it instead, and `--force` replaces. **Inside the rice it refuses**, because your
config.json is generated from [`nebelhaus.pounce.*`](/reference/options/#nebelhauspounce)
and the next `haus rebuild` would put the generated one straight back — change it
in your host file instead.

**Comments and trailing commas are fine.** Pounce strips both before parsing, which
is what lets you uncomment any subset of lines without fixing up commas by hand.
`//` and `/* */` inside a string value are left alone, so a URL in a setting is
safe. Unknown keys are ignored, so an older pounce never chokes on a config written
by a newer one.

```jsonc
{
  "theme": "nebelung",       // "nebelung" (default), "mocha", or a themes/ file
  "themeLight": "nebelung-latte",  // used when macOS is in Light Mode
  "themeDark": "nebelung",         // used when macOS is in Dark Mode
  "windowMode": "default",   // "default" (720px) or "compact" (600px, tighter)
  "scale": 1.0,              // 0.8-2.0 — how big the whole UI is drawn
  "hotkey": {
    "enabled": true,         // register the global hotkey in-process
    "key": "space",          // "space", "return", "tab", "escape", "a"–"z", "0"–"9"
    "modifiers": ["cmd"]     // any of "cmd", "shift", "opt", "ctrl"
  },
  "clipboard": {
    "enabled": true,         // watch the pasteboard
    "maxEntries": 200,       // history size
    "blacklistBundleIds": ["com.apple.Passwords"],  // never record from these
    "autoPaste": false       // synthesize ⌘V into the prior app (needs Accessibility)
  },
  "quickAnswers": {
    "currency": true         // fetch ECB rates so "100 usd in eur" answers inline
  },
  "updates": {
    "check": true            // nudge (never install) when a new release is out
  },
  "fileSearch": {
    "enabled": true,         // the Find Files mode
    "homeOnly": true,        // scope to ~ instead of the whole index
    "maxResults": 60         // rows kept per query
  },
  "apps": {
    "demoteBundleIds": [],   // sink these apps below everything else
    "hideBundleIds": []      // drop these apps from the list entirely
  },
  "windows": {
    "enabled": false,        // the MRU window switcher (needs Accessibility)
    "key": "tab",            // hold the modifiers, tap this to walk windows
    "modifiers": ["cmd"]
  },
  "items": {                 // per-item enable / alias / hotkey — see below
    "cmd:emoji": { "alias": "emo", "hotkey": "opt+space e" }
  }
}
```

| Key | Values | Default |
|---|---|---|
| `theme` | `"nebelung"` \| `"mocha"` \| a `themes/` file name | `"nebelung"` |
| `themeLight` | same values; applies in macOS Light Mode | `"nebelung-latte"` |
| `themeDark` | same values; applies in macOS Dark Mode | `"nebelung"` |
| `windowMode` | `"default"` \| `"compact"` | `"default"` |
| `scale` | `0.8`–`2.0` (clamped, not rejected) | `1.0` |
| `hotkey.enabled` | `true` \| `false` | `true` |
| `hotkey.key` | key name | `"space"` |
| `hotkey.modifiers` | array of `cmd`/`shift`/`opt`/`ctrl` | `["cmd"]` |
| `clipboard.enabled` | `true` \| `false` | `true` |
| `clipboard.maxEntries` | number | `200` |
| `clipboard.blacklistBundleIds` | array of bundle ids | `["com.apple.Passwords"]` |
| `clipboard.autoPaste` | `true` \| `false` | `false` |
| `quickAnswers.currency` | `true` \| `false` | `true` |
| `updates.check` | `true` \| `false` | `true` |
| `fileSearch.enabled` | `true` \| `false` | `true` |
| `fileSearch.homeOnly` | `true` \| `false` | `true` |
| `fileSearch.maxResults` | number | `60` |
| `apps.demoteBundleIds` | array of bundle ids | a built-in list of background/helper apps |
| `apps.hideBundleIds` | array of bundle ids | `[]` |
| `windows.enabled` | `true` \| `false` | `false` |
| `windows.key` | key name | `"tab"` |
| `windows.modifiers` | array of `cmd`/`shift`/`opt`/`ctrl` | `["cmd"]` |
| `items` | map of item key → `{ enabled, alias, hotkey }` | `{}` |

`themeLight` / `themeDark` are resolved per open (like everything else here), so
flipping macOS appearance shows on the next summon. Either one falls back to
`theme`, and `theme` alone pins one palette for both modes.

Setting `windows.enabled` turns on the MRU
[window switcher](/guides/pounce/#a-window-switcher-not-an-app-switcher-opt-in); it needs the
Accessibility grant to install its event tap, and without the grant stock ⌘Tab
keeps working.

`quickAnswers.currency` and `updates.check` are the only two things in Pounce
that touch the network. The first fetches the ECB daily reference rates from
`api.frankfurter.app` (at most every 12 hours, cached to
`~/.local/share/pounce/currency-rates.json`). The second asks GitHub once an
hour whether there is a newer release. Set both to `false` and Pounce makes no
network requests at all.

`updates.check` only ever *tells* you — it never installs anything. While a
release is pending, the **Update Pounce** row is renamed with the new version
and pinned to the palette's first row, and a notification repeats at most once
a day. Press `⌘⏎` on that row to skip the version: the pin and the notification
stop until the next release, though searching for the row still shows what's
waiting. The wording follows how you installed Pounce, because not every
install can update itself in place:

| Install | What the nudge says |
|---|---|
| Homebrew | Return runs `brew upgrade pounce` and restarts the service |
| Dragged to `/Applications` | Return downloads the new release and swaps the app in place |
| The nebelhaus rice | Run [`haus update`](/reference/haus/) — Pounce comes down with the rest of the rice |
| Your own flake | Update your `pounce` input |

The last two update through the Nix store rather than in place, so Pounce
deliberately won't try to overwrite itself there — the next rebuild would
revert it anyway.

Setting `hotkey.enabled` to `false` frees the hotkey so an external launcher
(skhd, AeroSpace) can bind a key to `pounce-palette` instead.

Any `theme` value that isn't a built-in resolves to
`~/.config/pounce/themes/<name>.json` — a flat catppuccin-style
`name → "#hex"` map ([nebelung's](https://github.com/nebelhaus/nebelung)
`palette/*.hex.json` files verbatim), re-read on each open like the config
itself. That's how the rice's `theme.flavor` / `theme.contrast` reach Pounce
without a rebuild, and it works the same on a Homebrew install:

```sh
mkdir -p ~/.config/pounce/themes
curl -fsSLo ~/.config/pounce/themes/nebelung-latte.json \
  https://raw.githubusercontent.com/nebelhaus/nebelung/main/palette/nebelung-latte.hex.json
# config.json:  "theme": "nebelung-latte"
```

An unknown name or malformed file falls back to the built-in nebelung palette.

### Sizing: `windowMode` and `scale`

Two independent knobs. `windowMode` picks the launcher's *proportions* —
`"compact"` is a narrower window with tighter rows that hides its list until you
type. `scale` picks how *big* the whole thing is drawn: every size in the UI —
text, rows, icons, the emoji grid, clipboard history, Find Files, the cheatsheet,
the window switcher — is multiplied by it. They compose, so a compact launcher at
`1.4` is still the compact layout, just readable from further away.

Sizes are resolved before layout rather than by scaling the rendered window, so
text stays crisp at any value. Out-of-range values are clamped to 0.8–2.0 rather
than rejected: a config asking for `3.0` wants the biggest palette Pounce can
draw, and handing back the smallest would be the opposite of the ask.

Two things adapt on their own so a large scale can't push the window off screen:
the launcher shows fewer rows once the scaled rows stop fitting, and every panel's
width is held inside the visible screen. That matters most on a Mac that has
*also* been set to a lower-resolution "larger text" display mode — both make
things bigger, and they multiply.

On the rice this is written for you from
[`nebelhaus.ui.scale`](/reference/options/#nebelhausuiscale), so the palette grows
with the rest of the desktop.

## Per-item settings (`items`)

One map covers what you'd otherwise want three keys for — hide a row, give it a
search shorthand, give it a global key. Each entry is keyed by an **item key**:

| Item key | Addresses |
|---|---|
| `cmd:<id>` | a command script, by filename without `.sh` |
| `app:/Applications/Foo.app` | an application, by path |
| `mode:<name>` | a built-in window — `launcher`, `clipboard`, `emoji`, `screenshots`, `camera`, `filesearch` |

```jsonc
{
  "items": {
    "cmd:emoji":                     { "alias": "emo", "hotkey": "opt+e" },
    "cmd:brew-services":             { "enabled": false },
    "app:/Applications/Ghostty.app": { "alias": "term", "hotkey": "opt+t" },
    "mode:clipboard":                { "hotkey": "cmd+shift+v" }
  }
}
```

- **`enabled: false`** drops the row from the launcher. It does *not* disarm a
  hotkey you bound to it — keeping an item off the list but on a key is a
  legitimate setup.
- **`alias`** is a search shorthand, matched at a bonus over the item's real name
  so it wins over whatever app fuzzy-matches the same letters.
- **`hotkey`** runs the item directly, skipping the palette. The last segment is
  the key, the rest modifiers (`cmd`/`shift`/`opt`/`ctrl`); the
  `{"key": …, "modifiers": …}` object form works here too.

  The laptop **Fn/Globe key** is the special one-step form: for example,
  `"mode:emoji": { "hotkey": "fn" }`. Since Fn is modifier-only, this opt-in
  binding uses a keyboard event tap and needs Pounce's Accessibility grant. It
  fires only on a lone tap, so Fn combinations keep working, and it replaces
  macOS's stock Globe action only while armed. `"globe"` and `"function"` are
  accepted aliases. nebelhaus ships this emoji binding by default; set
  `nebelhaus.pounce.items."mode:emoji".hotkey = null` to leave Globe native.

### Leader sequences

Add a **space** for a two-step key: whitespace separates steps, `+` separates
modifiers, so `"opt+space e"` is ⌥Space then E — the notation Emacs and VS Code
use. Sequences sharing a leader share it (⌥Space registers once and owns a map of
next keys), and a sequence can run longer than two: `"opt+space g s"`.

The point on a tiling setup: a leader opens a namespace that can't collide with
the ⌥/⌘ chords AeroSpace already owns, and it needs **no Accessibility grant** —
pressing the leader grabs its next-step keys as ordinary global hotkeys for ~2s
and releases them the instant one fires, so there's no event tap and no TCC
prompt. Escape cancels; hesitate ~0.45s and a which-key overlay lists the next
keys. `pounce doctor` reports every binding it actually armed, so a typo or a key
some other app holds is visible at startup, not on the day you press it.

### Driving pounce from another binder

If a tool already owns your keystrokes — AeroSpace binding modes, skhd,
Shortcuts — let it do the chord and have pounce do the action:

```sh
pounce run cmd:emoji
pounce run mode:clipboard
```

Same target grammar as `items`, dispatched through the identical path a native
binding takes. It exits non-zero with a reason on a malformed target, so a typo
fails loudly instead of arming a key that does nothing.

## CLI

```sh
pounce --launcher                 # apps + commands palette (the default mode)
pounce --max-empty 7              # rows to show before you type
pounce -p "Pick:"                 # generic picker; reads lines from stdin
pounce -i "sf.symbol.name"        # icon for the picker
pounce -p "Search:" --chain       # picker whose free-text Enter feeds another pounce step
pounce run cmd:emoji              # run one item by its key (for external binders)

# built-in windows — items, not flags (`pounce run <item-key>`)
pounce run mode:clipboard         # clipboard history
pounce run mode:emoji             # emoji picker
pounce run mode:screenshots       # screenshot browser
pounce run mode:camera            # live camera preview
pounce run mode:filesearch        # file/folder search (Spotlight index)
pounce run cmd:hush               # any command, by script name without .sh
pounce run app:/Applications/Ghostty.app
pounce --cheatsheet [path]        # cheatsheet overlay
pounce --transform 'tr a-z A-Z'   # rewrite the selected text through a shell filter

# settings
pounce config                     # print the config path
pounce config print               # an annotated config on stdout, touching nothing
pounce config init                # write it (--force replaces an existing one)

# housekeeping
pounce doctor                     # diagnose a dead/slow hotkey (see Troubleshooting)
pounce --help                     # every flag, from the binary itself
pounce --version
pounce --daemon                   # run the resident daemon (launchd uses this)
pounce --copy-file <path>         # copy a file (contents) to the clipboard
pounce --request-accessibility    # prompt for the Accessibility grant
pounce --check-accessibility      # exit 0 / prints true when granted
pounce --request-bluetooth        # prompt for the Bluetooth grant (v0.4.4+)
pounce --check-bluetooth          # exit 0 / prints true when granted
```

| Flag | Purpose |
|---|---|
| `-p`, `--placeholder` | Prompt text for the search field |
| `-i`, `--icon` | SF Symbol icon for the picker |
| `--chain [keys]` | Mark a free-text commit as feeding another `pounce` step — holds the window with the loading skeleton instead of fading. Optional comma-separated action list (`--chain enter,opt`) chains on some Returns and not others; bare `--chain` means `enter`. See [two-step commands](/guides/pounce-commands/#two-step-commands-submenus) and [a step that takes a paragraph](/guides/pounce-commands/#a-step-that-takes-a-paragraph) |
| `--actions <spec>` | Label the action bar on a step that shows no rows: `"Go\|shift:New line\|cmd:Screenshot\|opt:Drafts"`. See [a step that takes a paragraph](/guides/pounce-commands/#a-step-that-takes-a-paragraph) |
| `--draft <key>` | Keep the typed text on any dismissal that isn't a commit, filed under `<key>`; read it back with `drafts` |
| `--query <text>` | Open with the box already holding `<text>`, caret at the end — a draft handed back to edit, not a filter to replace |
| `drafts <key> <op>` | Read back what `--draft` kept: `save` (from stdin), `list` (one line each), `get <i>`, `rm <i>`, `clear`. Live in `~/.local/state/pounce/drafts/<key>.tsv`, newest first, capped at 20 |
| `run <item-key>` | Run one item by the key `items` uses (`cmd:emoji`, `mode:clipboard`, `app:/…`), for binders that own the keystroke |
| `--launcher` | Apps + commands mode |
| `--max-empty N` | Rows shown before any query is typed |
| `--cheatsheet [path]` | Overlay a cheatsheet (JSON) |
| `--transform <filter>` | Pipe the current selection through a shell filter and paste the result back (needs Accessibility) — how **Capitalize** / **Lowercase** work |
| `run <item-key>` | Run one item: `mode:clipboard` \| `mode:emoji` \| `mode:screenshots` \| `mode:camera` \| `mode:filesearch` \| `mode:launcher`, `cmd:<id>`, `app:<path>`. The built-in windows had a flag each until 2026-07-30 (`--clipboard` and friends); they're items now, so one name works as a palette row, a hotkey target and a CLI argument. Needs the daemon |
| `config [print\|init]` | The config path, an annotated config on stdout, or write one — every setting at its default, documented, commented out. `init --force` replaces an existing config; without it you get `config.json.new` beside yours |
| `--version` | Print the version |
| `--request-accessibility` / `--check-accessibility` | Manage the Accessibility (TCC) grant |
| `--request-bluetooth` / `--check-bluetooth` | Manage the Bluetooth (TCC) grant — the bluetooth plugin calls this for you |

## File paths

| Path | What |
|---|---|
| `~/.config/pounce/config.json` | Configuration |
| `~/.config/pounce/commands/` | Your commands (highest precedence) |
| `~/.config/pounce/cheatsheet.json` | Optional cheatsheet content |
| `~/.local/share/pounce/frecency.json` | Usage history for ranking |
| `~/.local/share/pounce/pounce.sock` | Daemon control socket |

## Environment variables

Set by packagers (the rice), rarely by hand:

| Variable | Meaning |
|---|---|
| `POUNCE_BUILTIN_DIR` | Directory of built-in commands |
| `POUNCE_EXTRA_COMMAND_DIRS` | Colon-separated extra command dirs (Nix layers) |
| `POUNCE_COMMAND_PATH` | Colon-separated ad-hoc command dirs |

## Homebrew binaries

Installing via `brew install pounce` puts these on your `PATH`:

| Binary | What |
|---|---|
| `pounce` | The app / daemon |
| `pounce-palette` | The launcher wrapper (bind a hotkey to this) |
| `pounce-<command>` | A wrapper per built-in command (e.g. `pounce-clipboard`) |

Inside nebelhaus, set the palette up via [`nebelhaus.pounce`](/reference/options/#nebelhauspounce)
instead — the module handles the daemon, hotkey, and permission survival for you.
