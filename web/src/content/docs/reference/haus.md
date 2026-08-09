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
| `haus options` | Refresh the annotated catalogue of every `haus.*` option on this machine's pinned rice. |
| `haus set <path> <value> [<path> <value>…]` | Write and stage machine overrides as ordinary Nix, type-check them, then rebuild once. `theme.accent` and `haus.theme.accent` are equivalent. Several pairs are applied all-or-nothing. |
| `haus get [path]` | Print one declared value; with no path, list the machine-writable overrides. |
| `haus unset <path> [<path>…]` | Explicitly set nullable options to `null`, then rebuild once. Takes a list, all-or-nothing. |
| `haus reset <path> [<path>…]` | Remove machine overrides, inherit the host/preset/rice value again, then rebuild once. Takes a list, all-or-nothing. A path that has no override is reported and skipped; if none of them had one, nothing is rebuilt. |
| `haus plan` | Preview what the next `haus rebuild` would change — settings, packages, casks — read-only, nothing built into place. |
| `haus diff` | The config declared for this machine vs what macOS actually has right now — effective state, not just the plist. |
| `haus capture [cat…]` | Turn this Mac's current settings into config lines *and* a snapshot. Defaults to `dock keyboard finder`; name a literal plist domain (e.g. `com.apple.Terminal`) for anything else. |
| `haus revert-settings [snapshot\|list]` | Put back a `haus capture` snapshot — the macOS defaults a generation rollback leaves untouched. `list` shows what you've captured. |
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

`set` takes as many `<path> <value>` pairs as you like, and applies them in a
single rebuild:

```sh
haus set theme.flavor latte theme.systemAppearance flavor
```

That matters for intents that span two options — light mode is the rice's
palette *and* macOS's own appearance — because `haus set` rebuilds per call, so
two calls would be two rebuilds with the machine sitting half-switched in
between. Several pairs are **all-or-nothing**: every file is written before
anything is type-checked, and one rejected value rolls all of them back.

`unset` and `reset` take a list of paths for the same reason, with the same
all-or-nothing single rebuild — so the way back out of a two-option intent is
also one command:

```sh
haus reset theme.flavor theme.systemAppearance
```

The two differ in one place. A path **`reset`** is given that has no override is
reported and skipped rather than fatal — you asked for it to inherit, and it
already does, so the rest are still withdrawn (and if none of them had an
override, nothing is rebuilt at all). `unset` has no such skip: it writes `null`
for every path unconditionally, so one option whose type does not admit `null`
takes the whole call down with it.

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

:::note[The namespace used to be `nebelhaus.*`]
Every option on this site is spelled `haus.*`. Older configurations write
`nebelhaus.*`, and **they still work** — the rice carries each old path as an
alias that sets the new one and prints an obsolete-option warning on rebuild.
Nothing breaks if you leave your host file alone; renaming the prefix is how you
silence the warnings. The aliases go away once the last configuration has moved,
so treat them as a grace period rather than a second spelling.
:::

Only `haus.*` paths are accepted. The prefix is optional for convenience;
passing `system.defaults.*`, `homebrew.*`, or an unknown option fails before a
file is written. Values use the obvious shell form for strings (`teal`) and JSON
syntax for booleans, numbers, lists, and attribute sets. A type-invalid value is
written and staged only long enough to evaluate the real module; on rejection,
the previous file is restored and that path is staged before any rebuild or
activation.

Pounce's **Haus Settings** command is the same mechanism with three intent-sized
buttons: **Make text bigger**, **Switch to light mode**, and **High contrast on**.
It delegates to `haus set`; the palette does not keep settings of its own.
**Switch to light mode** is the multi-pair case — it sets `theme.flavor` and
`theme.systemAppearance` together, so macOS's appearance comes over with the
rice's rather than being left behind.

### One thing `haus rebuild` refuses

If your host file sets `system.defaults.universalaccess.*`, `haus rebuild`
refuses to run from an AI agent session that lacks Full Disk Access — that write
would abort activation partway and skip every background service the rice
installs. Run the same command yourself instead. See [Changing your Mac with an
agent](/guides/ai-agent/#the-one-rebuild-it-will-refuse).

## The one thing `haus rollback` can't undo

A generation rollback rewinds everything Nix owns — packages, services, login
agents — atomically. It does **not** touch macOS's own preferences. Those get
written imperatively during activation (into `com.apple.dock`, Finder,
`NSGlobalDomain`…), and stepping back a generation never unsets them. Nix rolls
back what Nix wrote; the Dock's autohide is macOS's to remember.

Four read-only-plus-one commands close that gap:

```sh
haus plan        # what the next rebuild would change, before it changes it
haus diff        # what's declared vs what macOS actually has now
haus capture     # snapshot the settings you're about to let a rebuild move
haus revert-settings   # put that snapshot back if you don't like where it went
```

`plan` and `diff` read the built activation script itself rather than a
hand-kept list, so they can't drift out from under an upstream nix-darwin
change — and both consult a live NSWorkspace probe for the accessibility keys
macOS accepts silently and then ignores, instead of trusting the plist. `capture`
before a risky change and `revert-settings` after is the macOS-defaults
equivalent of `haus rollback`.

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

**Preview a change, and keep a way back for the settings rollback misses:**

```sh
haus capture     # snapshot dock/keyboard/finder as they are now
haus plan        # see what the next rebuild would move
haus rebuild
# … don't like it? packages come back with rollback, macOS defaults with:
haus revert-settings
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
