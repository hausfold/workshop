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
| `haus edit` | Open your host file (`~/.config/nix/hosts/<hostname>/default.nix`) in `$EDITOR`. |
| `haus doctor` | Health check: Determinate Nix, Xcode CLT, the GUI login agents, Homebrew cask drift (casks installed that no rebuild will manage), and whether an [agent](/guides/ai-agent/) can change this machine. |
| `haus btm` | On macOS 26 Tahoe+, check whether Background Task Management is blocking the nix login agents, and print the one-time fix. A no-op on earlier macOS. See [Troubleshooting](/reference/troubleshooting/#after-a-macos-upgrade-all-my-agents-are-dead-macos-26-tahoe). |

### One thing `haus rebuild` refuses

If your host file sets `system.defaults.universalaccess.*`, `haus rebuild`
refuses to run from an AI agent session that lacks Full Disk Access — that write
would abort activation partway and skip every background service the rice
installs. Run the same command yourself instead. See [Changing your Mac with an
agent](/guides/ai-agent/#the-one-rebuild-it-will-refuse).

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

## The other CLIs

`haus` is the only command an end user needs. The rice and workshop ship three
more, each for a different job — see [the CLIs at a glance](/start/the-family/#the-clis-at-a-glance)
for the full map:

- **[`wt`](/guides/claude-agents/)** — agent worktrees (Claude Code, Codex, OpenCode) for any repo.
  Also on your `PATH` (it ships in the rice), and useful to anyone who runs Claude
  Code, contributor or not.
- **[`bench`](/internals/contributing/)** — the contributor CLI in the workshop
  checkout: `try`, `ship`, `release` for moving changes between the family's repos.
- **`zscratch`** — feel-test a zellij edit without a rebuild (for rice
  contributors); ships in the rice.
