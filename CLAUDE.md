# CLAUDE.md

@AGENTS.md

<!--
Everything above this line is imported from AGENTS.md — the one set of project
instructions, shared by every harness. Put project rules THERE, not here, or
Codex/OpenCode/Copilot silently run without them.

Only Claude-specific wiring belongs below.
-->

## Claude-specific wiring (nothing project-level here)

| Thing | Where | Notes |
|---|---|---|
| Project instructions | `AGENTS.md`, imported above | Claude Code reads only `CLAUDE.md`, so this file exists purely to import it. |
| Skills (`/ship`, `/docs-sync`, `/release`, `/earshot`) | `.claude/skills/<name>/SKILL.md` | Symlinks into `.agents/skills/` — the shared bodies every client uses. Edit the target, never the link. |
| Session bootstrap | `.claude/settings.json` → `SessionStart` → `.agents/setup.sh` | Same script Codex and OpenCode call. Installs Nix in cloud containers, no-ops locally. |
| Worktree hooks | `~/.claude/settings.json` (yours, not the repo's) → `holt hook create` / `holt hook remove` | **haus declares these** and re-asserts them every rebuild, so they self-heal when Claude rewrites the file. Not hand-edited — change them in `haus`'s `modules/terminal`. The four agent-state hooks in the same file stay yours. |

The full cross-harness map is [`.agents/README.md`](./.agents/README.md).
