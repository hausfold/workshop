---
title: The haus CLI
description: The end-user haus command — configure, rebuild, compare, undo, and diagnose your machine.
---

`haus` is the command that drives your machine after install. It wraps the Nix
and `darwin-rebuild` invocations you'd otherwise type by hand, with safe
defaults (it always builds before switching). It lands on your `PATH` after the
first `switch`.

For the day-to-day workflow, see [Keeping in sync](/guides/staying-in-sync/).

## Commands

| Command | What it does |
|---|---|
| `haus rebuild` | Build, then `darwin-rebuild switch`. Your everyday apply. A failed build never touches the running system. |
| `haus update` | Update the `nebelhaus` pin in `~/.config/nix/flake.lock`, then rebuild — pulls new rice versions. |
| `haus rollback [N]` | Atomically return to the previous generation — or to generation `N`. |
| `haus generations` | List the generations you can roll back to. |
| `haus status` | Show the current generation and how stale the pinned rice is. |
| `haus edit` | Open your host file (`~/.config/nix/hosts/<hostname>/default.nix`) in `$EDITOR`. |
| `haus options` | Refresh the annotated catalogue of every `nebelhaus.*` option on this machine's pinned rice. |
| `haus set <path> <value>` | Write and stage one machine override as ordinary Nix, type-check it, then rebuild. `theme.accent` and `nebelhaus.theme.accent` are equivalent. |
| `haus get [path]` | Print one declared value; with no path, list the machine-writable overrides. |
| `haus unset <path>` | Explicitly set a nullable option to `null`, then rebuild. |
| `haus reset <path>` | Remove one machine override, inherit the host/preset/rice value again, then rebuild. |
| `haus plan` | Build a read-only preview of package, macOS-setting, and cask changes. |
| `haus diff` | Compare the active generation's declared macOS settings with the machine's effective state. |
| `haus capture [category…]` | Render this Mac's current settings as config lines and save a restorable snapshot. |
| `haus revert-settings [snapshot\|list]` | Restore a `haus capture` snapshot — the undo for macOS preferences Nix generations do not rewind. |
| `haus doctor` | Health check: Determinate Nix, Xcode CLT, the GUI login agents, Homebrew cask drift (casks installed that no rebuild will manage), and whether an [agent](/guides/ai-agent/) can change this machine. |
| `haus btm` | On macOS 26 Tahoe+, check whether Background Task Management is blocking the nix login agents, and print the one-time fix. A no-op on earlier macOS. See [Troubleshooting](/reference/troubleshooting/#after-a-macos-upgrade-all-my-agents-are-dead-macos-26-tahoe). |
| `haus tour [reset]` | Start the guided haus tour in the bar, or re-arm its first-run hint. |

## The writable settings overlay

For one option, you do not need to open an editor:

```sh
haus set theme.accent teal
haus get theme.accent       # teal
haus reset theme.accent     # inherit the preset/rice value again
```

`haus set` writes and stages a small module at
`~/.config/nix/hosts/<hostname>/settings/theme.accent.nix`. `mkNebelhaus`
auto-imports every `.nix` file in that directory, just as it already imports
Pounce's generated `packages/*.nix` app declarations. The file is the setting:
there is no JSON database beside it, and it is safe to inspect, edit, or commit.
Staging is required because a git-backed flake ignores untracked files; `haus
reset` stages the deletion for the same reason. Neither command commits or
pushes your config repo.

The overlay uses `lib.mkForce` because a machine choice must be able to override
a preset deliberately. That makes `unset` and `reset` distinct:

- `haus unset lock.requirePassword` writes `null`; it succeeds only when that
  option's type admits `null`.
- `haus reset lock.requirePassword` deletes the generated module, so whatever
  the host file, preset, or rice says underneath becomes effective again.

Only `nebelhaus.*` paths are accepted. The prefix is optional for convenience;
passing `system.defaults.*`, `homebrew.*`, or an unknown option fails before a
file is written. Values use the obvious shell form for strings (`teal`) and JSON
syntax for booleans, numbers, lists, and attribute sets. A type-invalid value is
written and staged only long enough to evaluate the real module; on rejection,
the previous file is restored and that path is staged before any rebuild or
activation.

Pounce's **Haus Settings** command is the same mechanism with three intent-sized
buttons: **Make text bigger**, **Switch to light mode**, and **High contrast on**.
It delegates to `haus set`; the palette does not keep settings of its own.

### One thing `haus rebuild` refuses

If your host file sets `system.defaults.universalaccess.*`, `haus rebuild`
refuses to run from an AI agent session that lacks Full Disk Access — that write
would abort activation partway and skip every background service the rice
installs. Run the same command yourself instead. See [Changing your Mac with an
agent](/guides/ai-agent/#the-one-rebuild-it-will-refuse).

## Typical sessions

**Change a setting and apply it:**

```sh
haus set theme.accent teal  # writes config, checks it, and rebuilds
# for structural/multi-option edits instead:
haus edit
haus rebuild
```

**Pull the latest rice:**

```sh
haus update      # bumps the pin and rebuilds
```

**Recover from a bad change:**

```sh
haus rollback    # back to the previous generation
haus diff        # macOS settings do not roll back with a Nix generation
haus doctor      # if something still looks off
```

## The other CLIs

`haus` is the only command an end user needs. The rice and workshop ship three
more, each for a different job — see [the CLIs at a glance](/start/the-family/#the-clis-at-a-glance)
for the full map:

- **[`holt`](/guides/claude-agents/)** — agent worktrees (Claude Code, Codex, OpenCode) for any repo.
  Also on your `PATH` (it ships in the rice), and useful to anyone who runs Claude
  Code, contributor or not.
- **[`bench`](/internals/contributing/)** — the contributor CLI in the workshop
  checkout: `try`, `ship`, `release` for moving changes between the family's repos.
- **`zscratch`** — feel-test a zellij edit without a rebuild (for rice
  contributors); ships in the rice.
