<div align="center">

# 🧰 the nebelhaus workshop

**where the family is built**

the bench — every repo in one place, and the tool that moves changes between them.

![part of nebelhaus](https://img.shields.io/badge/part_of-nebelhaus-f2c4e5?labelColor=202020)
![themed by nebelung](https://img.shields.io/badge/themed_by-nebelung-c9a8f1?labelColor=202020)
![license](https://img.shields.io/badge/license-MIT-d7d7d7?labelColor=202020)

</div>

---

This directory is the working checkout of the whole
[nebelhaus](https://github.com/nebelhaus) org. Each subdirectory is its own repo;
this folder itself is a small repo holding this README, a `CLAUDE.md`, the
`bench` script, and `web/` (nebelhaus.com), plus `assets/` and `test/`.

If you remember one thing: **work anywhere, then `./bench status` tells you
what's out of sync and `./bench ship` makes it right.**

## the family

- 🏠 [**nebelhaus**](https://github.com/nebelhaus/nebelhaus) — the house. the whole rice, one Nix flake. start here.
- 🐾 [**pounce**](https://github.com/nebelhaus/pounce) — the palette. keyboard-first launcher; every command a file.
- 🐦 [**trill**](https://github.com/nebelhaus/trill) — the messages. native iMessage/SMS/RCS, read from `chat.db`.
- 🪺 [**perch**](https://github.com/nebelhaus/perch) — the shelf. files, caught in the notch.
- 🌫️ [**nebelung**](https://github.com/nebelhaus/nebelung) — the theme. the silver-mist palette.
- 🧰 [**workshop**](https://github.com/nebelhaus/workshop) — the bench. where the family is built. *(you are here)*

Each one stands alone. Together they're a house.

Two more ride along: 🐙 [**org-profile**](https://github.com/nebelhaus/.github)
(the org's GitHub front page) and 🍺
[**homebrew-tap**](https://github.com/nebelhaus/homebrew-tap) (CI bumps it on
every release — you almost never touch it). Your private `~/.config/nix` lives
outside this dir entirely.

## the one gotcha

The repos form a chain of pinned flake inputs:

```
nebelung ──► pounce ──► nebelhaus ──► ~/.config/nix ──► your Mac
```

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
| `./bench status` | git state of every repo, every lock edge (who's pinning an old rev of whom), and every release edge (is the tag users install from behind main?) |
| `./bench try [switch]` | build (and optionally activate) your machine against the local checkouts |
| `./bench try-batch [switch]` | merge every **open PR** onto a throwaway tree per repo and build the whole queue in ONE rebuild, `main` untouched |
| `./bench ship` | push everything in dependency order, rippling `flake.lock` updates downstream |
| `./bench rebuild` | plain pinned rebuild of `~/.config/nix` |
| `./bench pull` | fast-forward every repo |
| `./bench clone` | fetch any family repo missing from this directory |
| `./bench release <repo>` | date-stamp the version (`v<YYYY.MM.DD>`, `-N` on a same-day repeat) + tag it — CI publishes the release + bumps the brew tap |
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
git clone https://github.com/nebelhaus/workshop.git
cd workshop
./bench clone
```

(Your private `~/.config/nix` is restored separately — see its own README.)

## where a change goes

Every repo's `CLAUDE.md` opens with the same routing table, so a session started
anywhere knows whether it's in the right place. The short version: **colors →
nebelung · the palette app → pounce · system behavior → nebelhaus · personal
anything → `~/.config/nix`**. When in doubt, start here and read
[`CLAUDE.md`](./CLAUDE.md).

## more

- [Workflows](./docs/workflows.md) — daily driving, parallel agents, batch-testing, releasing
- [The four CLIs](./docs/workflows.md#the-four-clis) — `haus` vs `bench` vs `wt` vs `zscratch`
- [nebelhaus.com](https://nebelhaus.com) — the user-facing docs this repo publishes

## roadmap

- **nebelhaus tui options program** — a custom install script people can `curl`
  and pipe into bash, spawning a TUI that asks for preferences (favorite IDE,
  accent color, …) and templates `nebelhaus.*` options into the generated host
  file.
- **the one hero shot** — media is marketing-only here (docs stay text; shots rot
  as the rice moves — see [`assets/SHOTLIST.md`](./assets/SHOTLIST.md)), and the
  rice's `assets/hero.png` is the single placeholder still worth capturing: for a
  rice, that one clean-desktop shot *is* the pitch.

## license

MIT © nebelhaus
