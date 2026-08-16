# Copilot instructions

**Read [`AGENTS.md`](../AGENTS.md) at the repo root first — it is the full,
authoritative instruction set for every agent working here, and this file is
only a pointer to it.** (Copilot doesn't follow file imports, hence the
duplication below; if the two ever disagree, `AGENTS.md` wins.)

The short version:

- This repo is the **workshop**: a parent directory holding every repo in the
  [hausfold](https://github.com/hausfold) family, plus `bench`, the script that
  moves changes between them. The sibling repos are
  independent git repos that are *not* checked out in a linked worktree or a
  cloud container — don't hunt for them, and don't report them as gitignored.
- **Every task belongs to exactly one repo.** `AGENTS.md` opens with the routing
  table; if the change belongs to a child repo, it doesn't belong in a workshop
  commit.
- The repos are a chain of pinned flake inputs
  (`nebelung → pounce → haus → ~/.config/nix`), so a merged commit is
  invisible downstream until `bench ship` bumps each `flake.lock`. Never
  hand-walk that ripple.
- **Land through a PR** — never a direct push or a local `git merge` into `main`.
- Nix work needs Nix: in a container, run `./.agents/setup.sh` first.

For review comments, the same bar applies as anywhere else here: correctness and
boundaries (did this change edit the right repo?) over style.
