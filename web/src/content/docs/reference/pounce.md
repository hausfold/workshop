---
title: Pounce config & CLI
description: Every config key, CLI flag, and file path for the Pounce command palette.
---

Reference for configuring and driving [Pounce](/guides/pounce/). For writing
your own commands, see [Writing pounce commands](/guides/pounce-commands/).

## Config file

Pounce reads `~/.config/pounce/config.json`. Every key is optional; the file is
re-read each time the palette opens (no daemon restart needed).

```jsonc
{
  "theme": "nebelung",       // "nebelung" (default) or "mocha" (stock Catppuccin)
  "windowMode": "default",   // "default" (720px) or "compact" (600px, tighter)
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
  "fileSearch": {
    "enabled": true,         // the Find Files mode
    "homeOnly": true,        // scope to ~ instead of the whole index
    "maxResults": 60         // rows kept per query
  }
}
```

| Key | Values | Default |
|---|---|---|
| `theme` | `"nebelung"` \| `"mocha"` | `"nebelung"` |
| `windowMode` | `"default"` \| `"compact"` | `"default"` |
| `hotkey.enabled` | `true` \| `false` | `true` |
| `hotkey.key` | key name | `"space"` |
| `hotkey.modifiers` | array of `cmd`/`shift`/`opt`/`ctrl` | `["cmd"]` |
| `clipboard.enabled` | `true` \| `false` | `true` |
| `clipboard.maxEntries` | number | `200` |
| `clipboard.blacklistBundleIds` | array of bundle ids | `["com.apple.Passwords"]` |
| `clipboard.autoPaste` | `true` \| `false` | `false` |
| `fileSearch.enabled` | `true` \| `false` | `true` |
| `fileSearch.homeOnly` | `true` \| `false` | `true` |
| `fileSearch.maxResults` | number | `60` |

Setting `hotkey.enabled` to `false` frees the hotkey so an external launcher
(skhd, AeroSpace) can bind a key to `pounce-palette` instead.

## CLI

```sh
pounce --launcher                 # apps + commands palette (the default mode)
pounce --max-empty 7              # rows to show before you type
pounce -p "Pick:"                 # generic picker; reads lines from stdin
pounce -i "sf.symbol.name"        # icon for the picker

# built-in modes
pounce --clipboard                # clipboard history
pounce --emoji                    # emoji picker
pounce --screenshots              # screenshot browser
pounce --camera                   # live camera preview
pounce --cheatsheet [path]        # cheatsheet overlay

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
| `--launcher` | Apps + commands mode |
| `--max-empty N` | Rows shown before any query is typed |
| `--clipboard` / `--emoji` / `--screenshots` / `--camera` | Built-in modes |
| `--find-files` | Live file/folder search over the Spotlight index |
| `--cheatsheet [path]` | Overlay a cheatsheet (JSON) |
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
