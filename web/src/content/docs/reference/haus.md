---
title: The haus CLI
description: The end-user haus command — rebuild, update, rollback, and diagnose your machine.
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
| `haus plan` | Preview what the next `haus rebuild` would change — settings, packages, casks — read-only, nothing built into place. |
| `haus diff` | The config declared for this machine vs what macOS actually has right now — effective state, not just the plist. |
| `haus capture [cat…]` | Turn this Mac's current settings into config lines *and* a snapshot. Defaults to `dock keyboard finder`; name a literal plist domain (e.g. `com.apple.Terminal`) for anything else. |
| `haus revert-settings [snapshot\|list]` | Put back a `haus capture` snapshot — the macOS defaults a generation rollback leaves untouched. `list` shows what you've captured. |
| `haus edit` | Open your host file (`~/.config/nix/hosts/<hostname>/default.nix`) in `$EDITOR`. |
| `haus doctor` | Health check: Determinate Nix, Xcode CLT, the GUI login agents, Homebrew cask drift (casks installed that no rebuild will manage), and whether an [agent](/guides/ai-agent/) can change this machine. |
| `haus btm` | On macOS 26 Tahoe+, check whether Background Task Management is blocking the nix login agents, and print the one-time fix. A no-op on earlier macOS. See [Troubleshooting](/reference/troubleshooting/#after-a-macos-upgrade-all-my-agents-are-dead-macos-26-tahoe). |

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
haus edit        # tweak your host file
haus rebuild
```

**Pull the latest rice:**

```sh
haus update      # bumps the pin and rebuilds
```

**Recover from a bad change:**

```sh
haus rollback    # back to the previous generation
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
