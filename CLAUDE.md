# CLAUDE.md

@AGENTS.md

Claude-only wiring, nothing project-level: `/ship`, `/docs-sync`, `/release` and `/earshot` are `.claude/skills/<name>/SKILL.md` symlinks into `.agents/skills/` (edit the target, never the link; `/factory` comes from factory via haus). `.claude/settings.json`'s `SessionStart` runs `.agents/setup.sh`, the same bootstrap every client calls. The `WorktreeCreate`/`WorktreeRemove` hooks in `~/.claude/settings.json` (→ `scruff hook create` / `scruff hook remove`) are declared by haus's `modules/terminal` and re-asserted every rebuild — not hand-edited. Full map: [`.agents/README.md`](./.agents/README.md).
