<div align="center">

# 🧰 the hausfold workshop

**where the family is built**

the bench — every repo in one place, and the tool that moves changes between them.

![part of hausfold](https://img.shields.io/badge/part_of-hausfold-f2c4e5?labelColor=202020)
![themed by nebelung](https://img.shields.io/badge/themed_by-nebelung-c9a8f1?labelColor=202020)
![license](https://img.shields.io/badge/license-MIT-d7d7d7?labelColor=202020)

</div>

---

This directory is the working checkout of the whole
[hausfold](https://github.com/hausfold) org. Each subdirectory is its own repo;
this folder itself is a small repo holding this README, an `AGENTS.md`, the
`bench` script and `web/` (nebelhaus.com), plus `assets/` and `test/`.

If you remember one thing: **work anywhere, then `./bench status` tells you
what's out of sync and `./bench ship` makes it right.**

## the family

- 🏠 [**nebelhaus**](https://github.com/hausfold/hausfold) — the house. the whole rice, one Nix flake. start here. *(the repo is `hausfold/hausfold` and the checkout `./hausfold`; the rice itself keeps the name)*
- 🐾 [**pounce**](https://github.com/hausfold/pounce) — the palette. keyboard-first launcher; every command a file.
- 🪺 [**perch**](https://github.com/hausfold/perch) — the shelf. files, caught in the notch.
- 🌫️ [**nebelung**](https://github.com/hausfold/nebelung) — the theme. the silver-mist palette.
- 🪵 [**holt**](https://github.com/hausfold/holt) — the worktrees. parallel coding agents, safely, in any repo.
- 🧰 [**workshop**](https://github.com/hausfold/workshop) — the bench. where the family is built. *(you are here)*

Each one stands alone. Together they're a house.

Four more ride along: 🐙 [**org-profile**](https://github.com/hausfold/.github)
(the org's GitHub front page), 🍺
[**homebrew-tap**](https://github.com/hausfold/homebrew-tap) (CI bumps it on
every release — you almost never touch it), 🔔
[**trill**](https://github.com/hausfold/trill) (the notification compositor —
ejected from the incubator 2026-08-09; deliberately *not* a family repo — no
lock edge, so `bench try`/`ship`/`status` never walk it, though `bench
clone`/`pull` plant it and the docs sweep reads it), and ⌂
[**hausfold.co**](https://github.com/hausfold/hausfold.co) — the site for
**haus**, the nix-darwin layer all of this is becoming, sold and shipped under
the name hausfold (decided 2026-08-08, named 2026-08-10; see
[`notes/hausfold-rename.md`](notes/hausfold-rename.md)). Its checkout is
`hausfold.co/`, **with the `.co`** — plain `hausfold/` is the rice, so site work
sent to the short name edits the desktop and nothing errors. hausfold.co used to
be the only private checkout here; it's public as of 2026-08-08. Your
`~/.config/nix` lives outside this dir entirely.

## the one gotcha

The repos form a chain of pinned flake inputs:

```
nebelung ──► pounce ──► nebelhaus ──► ~/.config/nix ──► your Mac
```

(Those are flake **input** names, not directories — the rice's input is still
spelled `nebelhaus` while its checkout is `./hausfold`.)

A flake input is **not** "whatever is on GitHub right now" — it's an exact commit
hash, frozen in `flake.lock`. That's what makes a rebuild reproducible. The flip
side: **committing, even pushing, changes nothing downstream** until each
downstream lock is updated. One hex value costs three repos of ceremony.

Never hand-walk that ripple. `./bench ship` performs it in order, and
`./bench status` shows every pin that's fallen behind.

![one colour change rippling down the chain: nebelung → pounce → nebelhaus → ~/.config/nix → your Mac, each lock pinning the exact commit of the one before](./assets/ripple.webp)

## the taste

```sh
./bench status         # what's dirty, unpushed, stale, or waiting in a worktree
./bench try            # build your real machine against the LOCAL checkouts
./bench try switch     # …and run it on this Mac (nothing pushed)
./bench ship           # push upstream→downstream, updating each lock along the way
```

`bench try` is the important one: it builds your actual machine config against
your local, uncommitted checkouts. You never push to find out whether something
works.

## the bench commands

| command | what it does |
|---------|--------------|
| `./bench status` | what this Mac is actually running (the pinned build, or a local branch a `try switch` put on it), git state of every repo, every lock edge (who's pinning an old rev of whom — or an **off-main** one, a pin that dies when its PR branch is deleted), and every release edge (is the tag users install from behind main?) |
| `./bench try [switch]` | build (and optionally activate) your machine against the local checkouts — from inside an agent worktree too, which is how you feel ONE unmerged branch |
| `./bench try-batch [switch]` | merge every **open PR** onto a throwaway tree per repo and build the whole queue in ONE rebuild, `main` untouched |
| `./bench ship` | push everything in dependency order, rippling `flake.lock` updates downstream |
| `./bench rebuild` | plain pinned rebuild of `~/.config/nix` |
| `./bench pull` | fast-forward every repo |
| `./bench clone` | fetch any repo missing from this directory — the family, plus `trill` and `hausfold.co`, which carry docs but no lock edge |
| `./bench release <repo> [version] [--ship]` | stamp the version + tag it, then **watch the CI run to the end** — release + brew tap bump. CalVer for pounce/perch/hausfold (`v<YYYY.MM.DD>`, `-N` on a same-day repeat, and a version argument is refused); **holt takes a semver argument and requires one** — five SDK registries share that number. `--ship` ripples the new lock edge after |
| `./bench docs-since [--mark]` | every commit since the docs were last reconciled, per repo — the input to the daily `/docs-sync` sweep |

The rice ships a `bench` shell alias, so these work from anywhere.

## the whole life of a change

```
hack ──► test ──► PR ──► batch-test ──► merge ──► ship ──► release
```

Agents draft on `worktree-*` branches in parallel · `bench try` proves it builds
· a PR lands it (never a direct push to `main`) · `bench try-batch` feels the
whole queue in one rebuild before anything merges · `bench ship` ripples the
locks · `bench release` tags it and CI does the rest.

Each step, and why it's shaped that way, is in
[`docs/workflows.md`](./docs/workflows.md).

## setting up on a fresh machine

```sh
git clone https://github.com/hausfold/workshop.git
cd workshop
./bench clone
```

(Your private `~/.config/nix` is restored separately — see its own README.)

## where a change goes

Every repo's agent instructions open with the same routing table, so a session
started anywhere knows whether it's in the right place. The short version:
**colors → nebelung · the palette app → pounce · system behavior → `./hausfold`
(the rice) · personal anything → `~/.config/nix`**. When in doubt, start here and read
[`AGENTS.md`](./AGENTS.md).

Those instructions are harness-neutral on purpose: `AGENTS.md` is the one body,
and Claude Code, Codex, OpenCode, Copilot & co. each reach it through a
one-line pointer, with the shared flows (`/ship`, `/docs-sync`) and the session
bootstrap in [`.agents/`](./.agents/README.md).

## more

- [Workflows](./docs/workflows.md) — daily driving, parallel agents, batch-testing, releasing
- [The four CLIs](./docs/workflows.md#the-four-clis) — `haus` vs `bench` vs `holt` vs `zscratch`
- [nebelhaus.com](https://nebelhaus.com) — the user-facing docs this repo publishes

## roadmap

- **nebelhaus tui options program** — a custom install script people can `curl`
  and pipe into bash, spawning a TUI that asks for preferences (favorite IDE,
  accent color, …) and templates `haus.*` options into the generated host
  file.
- **the one hero shot** — media is marketing-only here (docs stay text; shots rot
  as the rice moves — see [`assets/SHOTLIST.md`](./assets/SHOTLIST.md)), and the
  rice's `assets/hero.png` is the single placeholder still worth capturing: for a
  rice, that one clean-desktop shot *is* the pitch.

## license

MIT © hausfold
