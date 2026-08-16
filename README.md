# 🧰 workshop

**Where the [hausfold](https://github.com/hausfold) family gets built.**
*Every repo in one directory, and `bench` — the CLI that moves a change across them.*

<sub>**pre-release** · every path that could lose your work is either reversible by design or stops to ask you first. that's the intent, not a warranty — run it on a machine you can afford to rebuild, and tell us what breaks.</sub>

Five of them are Nix flakes, each pinning the ones upstream of it. Split a desktop
across five repos and you buy yourself a daily annoyance: nothing you write is
visible to its own neighbour until a lock file says so. `bench` is what makes
that chain feel like one codebase — build your real Mac against your
uncommitted edits, then push a change the whole way down.

## the one gotcha

```
nebelung ──► pounce ──► haus ──► ~/.config/nix ──► your Mac
theme        palette    layer    host file         darwin-rebuild
```

That's the spine, not the whole graph: `perch` and `holt` are inputs of `haus`
too, and `nebelung` is one a second time, directly rather than through pounce.
Six edges in all — `bench`'s `EDGES` has the list.

A flake input is not "whatever's on GitHub right now" — it's one exact commit,
frozen in `flake.lock`. That's what makes a rebuild reproducible, and it's the
catch: **committing changes nothing downstream. Pushing changes nothing
downstream.** A one-hex-digit colour tweak in nebelung reaches your Mac only
after three lock files move behind it.

Never walk that by hand. `./bench ship` does it in order; `./bench status`
names every pin that's fallen behind. (Those are repo names. Your flake's INPUT
name for the layer is your own — `inputs.haus` is what `bootstrap.sh` scaffolds,
and older configs say `inputs.nebelhaus`. `bench` doesn't care which: it reads
the name out of your `flake.lock`. That matters because Nix does **not** fail an
override naming an input that isn't there, so a hardcoded guess would build the
pinned layer while reporting your branch.)

## start

```sh
git clone https://github.com/hausfold/workshop && cd workshop
./bench clone          # plant every other repo beside this one

./bench status         # what this Mac is RUNNING · dirty trees · stale pins · agent lanes
./bench try            # build your real machine against the LOCAL checkouts
./bench try switch     # …and run it, for real (still nothing pushed)
./bench ship           # push upstream→downstream, updating each lock on the way
```

`try` is the one that earns the repo. It builds your actual machine config out
of your local, uncommitted checkouts — so you never push to find out whether
something works, and `main` never holds code nobody has felt.

| `./bench …` | |
|---|---|
| `status` | what's activated right now (the pinned build, or the branch a `try switch` put on it), every git and lock edge, every release edge |
| `try [switch]` | build (and activate) against the local checkouts — worktree-aware, so it can build ONE unmerged branch |
| `try lane [switch]` | same, plus every repo a `holt child` spawned from this pane — a cross-repo lane in one rebuild |
| `try-batch [switch]` | every **open PR** merged onto a throwaway tree per repo and built together in ONE rebuild, `main` untouched |
| `ship` | push in dependency order, rippling each `flake.lock` |
| `rebuild` | the plain pinned rebuild — the normal day |
| `pull` · `clone` | fast-forward every repo · fetch the ones you're missing |
| `release <repo> [version]` | stamp the version, tag it, then **watch CI to the end** — release + tap bump. The date *is* the version, except for holt, which takes semver because five SDK registries share the number |
| `docs-since [--mark]` | every commit since the docs were last reconciled — the input to the daily docs sweep |

## the family

Five repos share the lock chain above:

- 🏠 [**haus**](https://github.com/hausfold/haus) — the whole desktop, one Nix flake: the nix-darwin layer, plus **hacker**, the desktop built on it. **start here.**
- 🐾 [**pounce**](https://github.com/hausfold/pounce) — a keyboard-first command palette. every command is a file.
- 🪺 [**perch**](https://github.com/hausfold/perch) — a file shelf that grows out of the notch.
- 🌫️ [**nebelung**](https://github.com/hausfold/nebelung) — the silver-mist palette underneath all of it.
- 🦦 [**holt**](https://github.com/hausfold/holt) — worktree lanes, so parallel coding agents never fight over a checkout.

Four more ride along with no lock edge, so the ripple never walks them:
🔔 [trill](https://github.com/hausfold/trill) (a quiet notification compositor),
🍺 [homebrew-tap](https://github.com/hausfold/homebrew-tap) (CI-owned — you
almost never touch it), ⌂ [hausfold.co](https://github.com/hausfold/hausfold.co)
and 🐙 [org-profile](https://github.com/hausfold/.github). `bench clone` plants
them anyway; they carry docs. Your own `~/.config/nix` — the host file naming
your apps, your identity, your secrets — stays private, outside this directory,
and is restored from its own repo.

This repo itself holds `bench` (and `_bench`, its zsh completion — symlink it
into `~/.zsh-completions/` to get it on fpath), one set of agent instructions,
and `web/` — the
Cloudflare Worker behind [nebelhaus.com](https://nebelhaus.com), which is a 301
map to [hausfold.co](https://hausfold.co) now that the docs, the product pages
and the `curl | bash` one-liner all live there.

## the life of a change

```
hack ──► test ──► assure ──► PR ──► batch-test ──► merge ──► ship ──► release
```

Coding agents draft on `worktree-*` branches in parallel, `bench try` proves a
branch builds, a clean-context reviewer reads the diff cold, and `bench
try-batch` feels the whole review queue in a single rebuild — before any of it
lands on `main`.

## more

- [workflows](./docs/workflows.md) — daily driving, parallel agents, batch-testing, releasing
- [the four CLIs](./docs/workflows.md#the-four-clis) — `haus` vs `bench` vs `holt` vs `zscratch`
- [AGENTS.md](./AGENTS.md) — where a change goes, and the one instruction file every agent reads

---

<p align="center"><a href="https://hausfold.co">⌂ hausfold</a></p>
