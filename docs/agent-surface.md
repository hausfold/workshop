# The agent surface

**What every hausfold tool owes a coding agent, and how that reaches a user.**
Binds every repo in the family. Current code is the source of truth for what
exists; this is the standard it converges on.

Two audiences, and both are first-class:

| | who | how they get the docs |
|---|---|---|
| **haus user** | runs `haus`, has the apps because a room installed them | haus installs every tool's skill automatically — they do nothing |
| **standalone user** | `brew install perch`, nothing else from us | one command: `perch skill install` |

A tool that only teaches agents when haus is present is not a product; a tool
that needs a setup step on a haus machine has a bug.

## The five requirements

A tool is **agent-ready** when it meets all five. They are ordered — each one is
worthless without the one above it.

### A1 — Everything the UI does, the CLI does

No capability reachable only by clicking. Every user-facing action has a
non-interactive invocation that works from a script with no TTY, no window
focus, and no human.

The test: **can an agent undo what it just did?** Add implies list and remove.
Send implies read. Set implies get.

### A2 — Structured output, stable and documented

- `--json` on every read verb. One documented schema per verb; adding a key is
  fine, renaming or removing one is a breaking change.
- Write verbs emit a JSON **receipt** under `--json`: what changed, and the
  identifier needed to address it later.
- Data on stdout, diagnostics on stderr, always.
- **Exit codes are documented and meaningful.** perch's `0 added · 1 usage ·
  2 refused · 3 no Perch · 4 copy failed` is the house standard — distinguish
  *impossible request* from *daemon isn't running* from *it failed*, because an
  agent's recovery differs for each.
- Never require a TTY. Never prompt when stdin isn't a terminal — fail with a
  usage error naming the flag that would have answered.

### A3 — `<tool> skill`, and it's embedded

```
<tool> skill                 print the tool's own SKILL.md to stdout
<tool> skill <name>          print one of its other skills
<tool> skill install         write ALL of them into every agent client found
<tool> skill install --client claude|codex|opencode|pi
<tool> skill install --dir PATH
```

**`install` means all of them.** A tool that ships a second skill and installs
only its first reaches no standalone user with it.

**Embedded in the binary, not a file on disk.** A cask ships an `.app`, a Nix
build ships a store path, `go install` ships one binary — only embedding is
uniform across all three, and the version that answers `--help` is then the
version that answers `skill`.

`install` writes `<skills-dir>/<name>/SKILL.md` — one directory per skill, named
for the skill rather than the tool — and refuses rather than clobbers: if the
target exists and differs, it says so and prints the diff path. **On a haus
machine it refuses outright**, because those directories are read-only Nix
symlinks and haus has already installed the skill. Say that in the refusal;
don't make the user work it out from an `EPERM`.

The verb is `skill`, not `agent`: every client calls these things skills, and in
this family `agent` already means a launchd agent.

### A4 — One shape, ≤150 lines each

Committed at `ai/SKILL.md` in the tool's own repo — the source, embedded at
build time. **One skill is the shape.** A tool ships a second only when it owns
a job that has no verb, and then it is a sibling directory, `ai/<name>/SKILL.md`.

```markdown
---
name: <tool>
description: <the routing rule — see below>
---

# <Tool> — <one line: what it is>

<2–4 sentences: what it does, what it does NOT do, whether a daemon
must be running and how to tell.>

## Verbs

| do this | run this |
|---|---|
| put files on the shelf | `perch add <path>...` |
| …one row per verb, the common form only, no flag dumps… |

## When to reach for this

- <a thing a user says> → <the verb>

## When NOT to

- <the neighbouring tool, and why it's the right one instead>

## Traps

- <the failure that looks like something else>
```

Then, and only then, `--help` for the exhaustive flag list. A SKILL.md is a
routing document, not a man page. Past 150 lines it has stopped being one.

**The `description` field is the most important line in the file.** It is not a
summary — it is what every client matches against the user's words to decide
whether to load the skill at all. So it names **the phrases a user actually
says**, not the features the tool has:

> ✅ `Put files on the Mac's notch shelf, list what's on it, take things off it.
> Use when the user says "put this in my shelf", "add this to perch", "what's on
> my shelf", "clear my shelf", or drags a file at you and asks you to hold it.`
>
> ❌ `Perch is a native macOS notch file shelf with staging, drag/drop and an
> encrypted iOS companion wire.`

The second one is true, well written, and will never load.

Rules that follow from the shape:

- **Skill names are globally unique across the family** — they land in one
  shared `~/.claude/skills/`, next to whatever else the user installed. Check a
  new name against the tool names *and* against the host's own hand-wired
  skills: a machine that already declares `~/.claude/skills/<name>` gets an
  activation conflict, not a winner.
- **A second skill has to be ABOUT the tool.** If it would read the same with
  the tool's name swapped out, it is a personal workflow file and belongs in the
  user's own config.
- **The description is ONE physical line, and at least 80 characters.** A YAML
  folded scalar (`>-` plus an indented body) is valid YAML and every build guard
  here rejects it on purpose: the guards are `grep`, and a description that
  needs a parser is one that can silently stop being checked.
- **The skill's `name:` key must match the directory it installs into.** A
  mismatch installs a skill under a name nothing ever asks for.
- **Name the failure, not just the feature.** A skill whose `description`
  advertises only what the tool does never loads on the sentence it most needs
  to refuse — perch has no read verb, so *"what's on my shelf?"* must be in the
  description or the paragraph saying "don't invent `perch list`" never fires.
- **No option or flag inventories in the hand-written half.** Anything that
  drifts gets *generated* (haus's `references/options.md` is the pattern,
  rendered from the module system). Prose is only for what doesn't drift.
- **Every claim in it is runnable.** A command in a SKILL.md that has never been
  run is a confidently-wrong instruction with a nice format.

### A5 — Config is a file, and the file has a schema

Settings live in a file the agent can read, diff and edit — never only in a UI.
Each tool grows a `<tool> config print --json` showing the **effective** values
including defaults, so an agent can tell *unset* from *set to the default*.
pounce's `config print` is the shape.

`UserDefaults` is exactly the click-only case this forbids.

## What we deliberately do NOT do

**No MCP servers, for now.** For a coding agent in a terminal — which is every
agent that will touch these tools — a documented CLI plus a skill is strictly
better: nothing to launch, nothing to authorize, identical in Claude Code,
Codex, OpenCode, pi and a bare shell script, and it is the same surface a human
uses, so it can't rot in a corner nobody runs. The case for MCP arrives when a
**non-terminal** agent needs these tools; the CLI is the layer it would wrap
anyway.

**No agent-facing network surface.** No tool grows a socket for a remote model.

**No "AI features" inside the apps.** No model calls from pounce, no
summarization in trill. The tools stay small and scriptable; the intelligence is
the agent driving them.

## Rooms

Rooms are configuration, not runtime, so they are served by generated
`references/options.md` in the haus skill. Two routing gaps remain: a room has
no one-line "what am I", and a room's runtime CLI (`pounce focus`, `perch`,
`sketchybar`) is invisible from its options. Both close with a generated
`references/rooms.md` fed from `modules/options-groups.nix`:

```nix
# in `rooms`, not `groups` — that file has both, and both have a `focus`
focus = {
  title = "Focus";
  order = 90;
  blurb = "One quiet switch: …";                                        # exists
  agent.cli  = "pounce focus on|off|status";                            # NEW — the runtime verb, or null
  agent.asks = [ "make my mac quiet" "turn on do not disturb" "hush" ]; # NEW
};
```

`groups` is per-**namespace** and feeds the host template and hausfold.co's
option reference; `rooms` is per-**room** and is the one this wants.

## Distribution

**haus machines.** `haus.ai.skill` installs the haus skill and every skill each
hausfold tool on this machine ships — per skill, not per tool. Each flake
exposes its SKILL.md as `pkgs.<tool>-skill`, and haus copies the ones whose room
is actually enabled: a skill for an app you don't have is worse than none,
because the agent will confidently offer it.

Install path is each client's own skills dir (`~/.claude/skills`,
`~/.codex/skills`, `~/.config/opencode/skills`, `~/.pi/agent/skills`), one entry per skill, named by
the tool. haus's own skill stays file-by-file because `this-machine.md` is
rendered per host; a tool's skill has no per-host half, so it is one directory
symlink.

⚠️ A host that hand-wires `~/.claude/skills/<name>` for a skill of the same name
must drop it in the **same rebuild** — two definitions of one `home.file` path
is a home-manager *eval* conflict, not a last-wins.

**Standalone.** `<tool> skill install`, named in the README's install section
one line after `brew install`. Homebrew casks get a `caveats` line — it's the
only place a cask can talk to the user.

## The skill is not the only way in

- **`--help` is agent-readable prose.** Verbs first, flags second, exit codes
  listed.
- **The repo's own `AGENTS.md`** covers agents working *on* the tool. Not a
  substitute for the skill, which covers agents *using* it on a machine with no
  checkout.

## The shape of a compliant tool

```
<repo>/
  ai/SKILL.md              the source, ≤150 lines, committed
  ai/<name>/SKILL.md       any further skill, same shape — usually none
  script/check-skills.sh   the guards, as a script BOTH CI and Nix run
  <build>                  embeds ai/**/SKILL.md into the binary
  flake.nix                exposes packages.<system>.<tool>-skill
                           whose output is $out/<name>/SKILL.md per skill
<tool> --help              verbs, flags, exit codes
<tool> <verb> --json       stable schema, stdout only
<tool> skill               prints the embedded SKILL.md
<tool> skill install       writes every skill into every client found
```

**The derivation's output is `$out/<tool>/SKILL.md`, not `$out/SKILL.md`** — one
nesting level, named for the skill, so a consumer links a directory whose name
is already right and the *tool* decides that name. A tool shipping more than one
lays them out as siblings, and **every guard runs per skill**.

**The guards go in a script the repo's own CI runs, not in the `runCommand`
body.** Every guard exists because the failure it catches is invisible at
runtime — a skill with broken frontmatter is installed, listed and never
loaded — and most of these repos build Go or Swift in CI with no Nix at all, so
a guard living only in the derivation runs nowhere that matters. The script
**discovers** `ai/*/SKILL.md` rather than taking a list; scruff's
`script/check-skills.sh` is the pattern.

Each repo's build files follow that repo's own convention — `nix/skill.nix` in
perch, trill, scruff and nebelung, `pkgs/pounce-skill/default.nix` in pounce. Only
the package *name* and the output *layout* are fixed. haus is the one variant:
its skill source is `modules/ai/agents/SKILL.md` and its derivation is flat.

## How we know it works

Not "the file exists". The acceptance test is behavioural, per skill, run in a
pane with no context:

> Open a fresh agent session on a machine with the tool installed and no
> checkout of its repo. Say the sentence a user would say. It works on the
> first try, with no follow-up question about flags.

| skill | the sentence |
|---|---|
| perch | "put this file in my shelf" / "what's on my shelf?" |
| pounce | "what did I copy three things ago?" |
| trill | "tell me when this build finishes" |
| scruff | "what agent worktrees do I have open?" |
| scruff · handoff | "hand this off to a fresh session" / "spawn an agent to do this" |
| haus | "make my terminal font bigger" |
| nebelung | "what's the hex for the background colour?" |

A tool that needs a second turn to get the flags right has not met the standard,
however complete its SKILL.md is.

---

Where each tool currently stands against A1–A5, and the order the gaps close in,
is `todo/agent-surface.md` in [hausfold/ops](https://github.com/hausfold/ops).
