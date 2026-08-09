---
title: The family
description: The repos that make up nebelhaus, what each one owns, and how they feed each other.
---

nebelhaus is not one repo — it's a small family, each piece owning one job and
usable on its own. The rice ([nebelhaus](https://github.com/hausfold/hausfold))
ties them together, but pounce, perch, and nebelung stand alone too.

## The repos

| Repo | Owns | You touch it when… |
|---|---|---|
| 🏠 [**nebelhaus**](https://github.com/hausfold/hausfold) | the rice — nix-darwin modules for tiling, bar, shell, security, palette wiring | anything about *how the system behaves* |
| 🐾 [**pounce**](https://github.com/hausfold/pounce) | the launcher — a native Swift command palette + its generic command scripts | the palette app or a built-in command changes |
| 🐈 [**perch**](https://github.com/hausfold/perch) | the shelf — a native notch file tray that stages dropped files and drags them out as one group | you want to change the file shelf |
| 🌫 [**nebelung**](https://github.com/hausfold/nebelung) | the colours — a silver-mist Catppuccin variant + per-tool theme templates | you want a different shade of fog |
| 🪵 [**holt**](https://github.com/hausfold/holt) | the worktree substrate — agent worktrees for any repo and any client, which the rice takes as a flake input | you want to change how agent worktrees are made, parked or reaped |
| 🍺 [**homebrew-tap**](https://github.com/hausfold/homebrew-tap) | the Homebrew tap (`brew tap hausfold/tap`) | almost never — CI bumps it on every release |
| 🧰 [**workshop**](https://github.com/hausfold/workshop) | every repo checked out side-by-side + the `bench` dev CLI | you're hacking on the family itself |

Your private machine config — identity, secrets, your app roster — lives at
`~/.config/nix` and is **yours**, never part of the rice.

## The CLIs at a glance

There are four command-line tools in nebelhaus, and knowing which is which saves
a lot of confusion. **Two jobs, four commands** — and if you only *use*
nebelhaus, you only ever need the first one:

| Command | You reach for it to… | Works on | Ships in |
|---|---|---|---|
| **`haus`** | drive your own machine — [rebuild, update, roll back, diagnose](/reference/haus/) | your Mac (`~/.config/nix`) | the rice — every install has it |
| **`holt`** | manage [agent worktrees](/guides/claude-agents/) — safe parallel agents, resumable panes | any git repo | the rice — every install has it |
| **`bench`** | [move a change across the family repos](/internals/contributing/) — try, ship, release | the workshop checkouts | the workshop — contributors only |
| **`zscratch`** | [feel-test a zellij edit](/internals/contributing/#feel-testing-a-zellij-edit-zscratch) with no rebuild | the rice's zellij config | the rice — for rice contributors |

`haus` and `bench` never overlap — they're named differently on purpose so they
can't shadow each other. `haus` knows only *your machine*; `bench` knows only
*the family repos*. `holt` and `zscratch` are dev tools the rice puts on your
`PATH` whether or not you ever contribute — `holt` especially is worth knowing
for **anyone** who runs Claude Code, nebelhaus contributor or not. It's the one
that isn't really nebelhaus's at all: [its own
repo](https://github.com/hausfold/holt), which the rice merely takes as a flake
input. Its bash predecessor `wt.sh` has been retired entirely.

## The rooms, standalone

- **[pounce](/guides/pounce/)** installs from Homebrew (`brew install pounce`)
  with zero Nix. It's a general command palette; the rice just wires it up.
- **[perch](https://github.com/hausfold/perch)** is a plain menu-bar app — the
  notch file shelf — that needs none of the rest of the family to run.
- **[nebelung](/reference/palette/)** is a plain colour system. Any tool —
  Ghostty, bat, lazygit, Slack, Zen — can consume its rendered themes without
  touching the rest.
- **[nebelhaus](/start/what-is-nebelhaus/)** is the whole system, but its
  modules (`den`, `hearth`, `prowl`, `sill`, `collar`, `pounce`, `hush`,
  `secrets`) are exported individually so you can cherry-pick.

## How they feed each other

The repos form a chain of pinned flake inputs. Each link is a *flake input* —
a reference to an exact commit, recorded in the downstream repo's `flake.lock`:

![one colour change rippling down the chain: nebelung → pounce → nebelhaus → ~/.config/nix → your Mac, each lock pinning the exact commit of the one before](/media/ripple.webp?v=2)

The catch that surprises everyone: a flake input is **not** "whatever is on
GitHub right now" — it's a frozen commit hash. So pushing a change to `nebelung`
changes **nothing** downstream until each downstream `flake.lock` is bumped to
the new commit. That's what makes rebuilds reproducible, and it's why updating
is a deliberate `nix flake update`, not automatic.

As an end user you rarely feel this — `haus update` handles it. It matters if
you [contribute to the family](/internals/contributing/) or want to understand
[how the flakes fit together](/internals/flakes/).

## Built on

nebelhaus stands on the shoulders of excellent open-source projects:

- [Nix](https://nixos.org) & [nix-darwin](https://github.com/nix-darwin/nix-darwin) — reproducible system config
- [AeroSpace](https://github.com/nikitabobko/AeroSpace) — the tiling window manager
- [SketchyBar](https://github.com/FelixKratz/SketchyBar) — the status bar
- [Catppuccin](https://github.com/catppuccin) — the colour framework nebelung is derived from
- [Ghostty](https://ghostty.org), [zellij](https://zellij.dev), [yazi](https://yazi-rs.github.io), [helix](https://helix-editor.com), [starship](https://starship.rs) — the terminal stack

nebelhaus is MIT-licensed, with one exception: **perch** is *fair source* —
[FSL-1.1-ALv2](https://fsl.software), the Functional Source License with an
Apache-2.0 future licence, so every release becomes Apache-2.0 two years after
it ships. You can read it, build it, and change it for yourself; you can't sell
it as a competing product.
