# The agent surface

Working standard, 2026-08-16. What every hausfold tool owes a coding agent, and
how that reaches a user — whether they run haus or downloaded one app.

Current code is the source of truth for what exists; §8 is the measured gap
between that and this standard, and §9 is the order it closes in.

## 0. The claim

The family is already half AI-native and nobody wrote it down. Every tool is
configured by a file rather than a settings window; pounce, perch, trill and
holt each expose a CLI; holt already emits `--json`. What's missing is not
capability — it's **discoverability and uniformity**. An agent sitting in front
of this machine cannot answer "put this in my shelf" unless somebody told it
that `perch` exists, what its verbs are, and when *not* to reach for it.

So the goal is not "add AI features to the apps". It is:

> **Every tool describes itself to an agent, in one shape, and the description
> ships with the tool.**

A user should be able to say *"put this in my shelf"*, *"tell me when the build
finishes"*, *"what's on my clipboard"*, *"make my Mac quiet"* — and the agent
already in their terminal does it on the first try, with no setup and no
guessing at flags.

Two audiences, and the standard must serve both:

| | who | how they get the docs |
|---|---|---|
| **haus user** | runs `haus`, has the apps because a room installed them | haus installs every tool's skill automatically — they do nothing |
| **standalone user** | `brew install perch`, nothing else from us | one command: `perch skill install` |

Neither is the fallback for the other. A tool that only teaches agents when
haus is present is not a product; a tool that needs a setup step on a haus
machine has a bug.

## 1. The five requirements

A tool is **agent-ready** when it meets all five. They are ordered: each one is
worthless without the one above it.

### A1 — Everything the UI does, the CLI does

No capability reachable only by clicking. Every user-facing action has a
non-interactive invocation that works from a script with no TTY, no window
focus, and no human.

This is the requirement with teeth, and the one the family fails hardest
(§8): perch can be *written to* from the CLI and not read from, so an agent can
put a file on the shelf and then cannot tell the user what's on it.

The test: **can an agent undo what it just did?** Add implies list and remove.
Send implies read. Set implies get.

### A2 — Structured output, stable and documented

- `--json` on every read verb. One documented schema per verb; adding a key is
  fine, renaming or removing one is a breaking change.
- Write verbs emit a JSON **receipt** under `--json`: what changed, and the
  identifier needed to address it later.
- Data on stdout, diagnostics on stderr, always. An agent piping `--json`
  through `jq` must never get a progress line in the middle of it.
- **Exit codes are documented and meaningful.** perch's `0 added · 1 usage ·
  2 refused · 3 no Perch · 4 copy failed` is the house standard — distinguish
  *the user asked for something impossible* from *the daemon isn't running*
  from *it failed*, because an agent's recovery differs for each.
- Never require a TTY to succeed. Never prompt when stdin isn't a terminal —
  fail with a usage error naming the flag that would have answered.

### A3 — `<tool> skill`, and it's embedded

Every tool ships its own agent documentation **inside its binary**, and can
print or install it:

```
<tool> skill                 print the SKILL.md to stdout
<tool> skill install         write it into every agent client found on this Mac
<tool> skill install --client claude|codex|opencode
<tool> skill install --dir PATH
```

**Embedded, not a file on disk.** A Homebrew cask ships an `.app`; a Nix build
ships a store path; `go install` ships one binary. Only embedding is uniform
across all three, and it makes the docs impossible to desync from the binary
that implements them — the version that answers `--help` is the version that
answers `skill`.

`install` writes `<skills-dir>/<tool>/SKILL.md` and refuses rather than
clobbers: if the target exists and differs, it says so and prints the diff
path. **On a haus machine it refuses outright** — those directories are
read-only Nix symlinks, and haus has already installed the skill (§4). Say
that in the refusal; don't make the user work it out from an EPERM.

The verb is `skill`, not `agent`: all three clients call these things skills,
and in this family `agent` already means a launchd agent.

### A4 — One SKILL.md, one shape, ≤150 lines

Committed at `ai/SKILL.md` in the tool's own repo — the single source, embedded
at build time. The shape:

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

Then, and only then, `--help` for the exhaustive flag list. The SKILL.md is a
routing document, not a man page. If it grows past 150 lines it has stopped
being one.

**The `description` field is the most important line in the file** and the one
most likely to be written wrong. It is not a summary — it is what every client
matches against the user's words to decide whether to load the skill at all. So
it names **the phrases a user actually says**, not the features the tool has:

> ✅ `Put files on the Mac's notch shelf, list what's on it, take things off it.
> Use when the user says "put this in my shelf", "add this to perch", "what's on
> my shelf", "clear my shelf", or drags a file at you and asks you to hold it.`
>
> ❌ `Perch is a native macOS notch file shelf with staging, drag/drop and an
> encrypted iOS companion wire.`

The second one is true, well written, and will never load.

Rules that follow from the shape:

- **Skill names are globally unique across the family** — `haus`, `pounce`,
  `perch`, `trill`, `holt`, `nebelung`. They land in one shared
  `~/.claude/skills/`, next to whatever else the user installed.
- **No option or flag inventories in the hand-written half.** Anything that
  drifts gets *generated* (haus's `references/options.md` is the pattern:
  rendered from the module system, so it can't be wrong about the revision on
  this machine). Prose in the SKILL.md is only for what doesn't drift.
- **Every claim in it is runnable.** A command in a SKILL.md that has never
  been run is a confidently-wrong instruction with a nice format.

### A5 — Config is a file, and the file has a schema

Already true across the family and worth stating so it stays true: settings
live in a file the agent can read, diff and edit — never only in a UI. Going
further, each tool's config file gets a `$schema`-able description or a
`<tool> config print --json` that shows the effective values including
defaults, so an agent can tell *unset* from *set to the default*.

## 2. What we are deliberately NOT doing

**No MCP servers, for now.** For a coding agent in a terminal — which is every
agent that will ever touch these tools — a documented CLI plus a skill is
strictly better than an MCP server: nothing to launch, nothing to authorize,
works identically in Claude Code, Codex, OpenCode and a bare shell script, and
it is the same surface a human uses, so it can't rot in a corner nobody runs.
An MCP server is a second implementation of the same verbs with its own
lifecycle and its own bugs.

The case for MCP arrives when a **non-terminal** agent needs these tools —
claude.ai, a desktop client with no shell. Revisit then; the CLI is the layer
an MCP server would wrap anyway, so nothing here is wasted.

**No agent-facing network surface.** No tool grows a socket for a remote model
to talk to. Perch's paired-phone wire is a product feature and stays as
tightly scoped as it is.

**No "AI features" inside the apps.** No model calls from pounce, no
summarization in trill. The tools stay small and scriptable; the intelligence
is the agent driving them. This is the whole thesis and it is worth defending
against the obvious pressure to add a sparkle button.

## 3. The rooms

Rooms are configuration, not runtime, so they are already served by
`references/options.md` in the haus skill — generated from the module system,
so it describes exactly the revision this machine is pinned to.

Two gaps remain, and both are about **routing** rather than reference:

1. **A room has no one-line "what am I" for an agent.** `options.md` is a flat
   list of leaves. An agent asked "make my Mac quiet" must reconstruct that
   this is the focus room from option names alone.
2. **A room's runtime CLI is invisible.** The focus room's *behaviour* is
   reached through `pounce focus`, the shelf room's through `perch`, the bar
   through `sketchybar`. Nothing connects the room to the command.

Close both with `references/rooms.md`, generated into the haus skill from
`modules/options-groups.nix` — which already carries a per-room `blurb` read by
the host template and hausfold.co. Add two fields to each record:

```nix
focus = {
  order = …;
  blurb = "…";                              # exists
  agent.cli  = "pounce focus on|off|status"; # NEW — the runtime verb, or null
  agent.asks = [ "make my mac quiet" "turn on do not disturb" "hush" ];  # NEW
};
```

One more field, one more renderer, no new source of truth — and `room-registry`
already fails the build when a room is missing from that file, so a new room
cannot silently ship without its routing row.

## 4. Distribution

**haus machines.** `haus.ai.skill` grows from "install the haus skill" to
"install the haus skill **and one per hausfold tool this machine has**". haus
already takes nebelung, pounce, perch, holt and trill as flake inputs, so each
flake exposes its SKILL.md as a package output and haus copies the ones whose
room is actually enabled. A machine with the shelf room off gets no perch
skill — a skill for an app you don't have is worse than none, because the agent
will confidently offer it.

Same install path as today: file-by-file into each client's own skills dir
(`~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`), so a host
can still symlink an individual skill out of the store for live editing.

**Standalone.** `<tool> skill install`. The tool's README says so in its install
section, one line, right after `brew install`. Homebrew casks get a `caveats`
line — it's the only place a cask can talk to the user, and this is exactly
what it's for.

## 5. The skill is not the only way in

A skill only loads for a client that has a skills directory. Two cheaper
fallbacks, and they cost nothing:

- **`--help` is agent-readable prose.** Verbs first, flags second, exit codes
  listed. Every tool here already does this well; the standard is to keep it.
- **The repo's own `AGENTS.md`** covers agents working *on* the tool. It is not
  a substitute for the skill, which covers agents *using* it, on a machine that
  has no checkout.

## 6. The shape of a compliant tool, in full

```
<repo>/
  ai/SKILL.md              the source, ≤150 lines, committed
  <build>                  embeds ai/SKILL.md into the binary
  flake.nix                exposes packages.<system>.<tool>-skill
<tool> --help              verbs, flags, exit codes
<tool> <verb> --json       stable schema, stdout only
<tool> skill               prints the embedded SKILL.md
<tool> skill install       writes it into every client found
```

Four files' worth of work per tool, and the one that takes thought is the
`description`.

## 7. How we know it works

Not "the file exists". The acceptance test is behavioural, per tool, run in a
pane with no context:

> Open a fresh agent session on a machine with the tool installed and no
> checkout of its repo. Say the sentence a user would say. It works on the
> first try, with no follow-up question about flags.

The sentences, one per tool, are the fixtures:

| tool | the sentence |
|---|---|
| perch | "put this file in my shelf" / "what's on my shelf?" |
| pounce | "what did I copy three things ago?" |
| trill | "tell me when this build finishes" |
| holt | "what agent worktrees do I have open?" |
| haus | "make my terminal font bigger" |
| nebelung | "what's the hex for the background colour?" |

A tool that needs a second turn to get the flags right has not met the
standard, however complete its SKILL.md is.

## 8. Where the family stands, measured 2026-08-16

| tool | A1 · CLI covers UI | A2 · JSON + exits | A3 · `skill` verb | A4 · SKILL.md | A5 · config file |
|---|---|---|---|---|---|
| **holt** | ✅ full lifecycle | ✅ `--json`, exit codes | ❌ | ❌ | ✅ |
| **haus** | ✅ `set/get/options/status/plan/diff/doctor` | ⚠️ no `--json` | ❌ (skill exists, no verb) | ✅ generated | ✅ |
| **pounce** | ⚠️ rich, but read verbs are TSV-only | ❌ no `--json` anywhere | ❌ | ❌ | ✅ `config.json` |
| **trill** | ⚠️ `send`/`ping`/`doctor`; no read of what fired | ⚠️ `--json` on doctor only | ❌ | ❌ | ✅ `rules.json` |
| **perch** | ❌ **`add` only** — cannot list or remove | ⚠️ `--json` on `add` | ❌ | ❌ | ✅ |
| **nebelung** | ❌ no CLI at all | ✅ palette is JSON | ❌ | ❌ | n/a |

Reading the table: **A3/A4 is uniformly absent and uniformly cheap** — it is
docs plus one verb, in six repos, and it is what the user actually feels. **A1
is the expensive column and only perch and nebelung genuinely fail it**; perch's
gap is the one that breaks a real sentence today ("what's on my shelf?").

## 9. Order

1. **This note**, and the `AGENTS.md` routing row that points here.
2. **`ai/SKILL.md` in all six repos.** Docs only, no code, no release. Lands the
   whole standalone *content* and is what haus needs in order to install
   anything.
3. **haus installs them** — `haus.ai.skill` extended, plus `references/rooms.md`
   from `options-groups.nix`. After this, a haus user has the whole thing.
4. **`<tool> skill` verb** in pounce, perch, trill, holt. Public CLI surface on
   released tools, so it rides a normal release, not a hotfix.
5. **perch's read verbs** — `perch list`, `perch rm`, `--json` on both. The one
   A1 gap worth a feature PR of its own.
6. **`--json` sweep** — pounce's read verbs, trill `list`, `haus get --json`.

Steps 2 and 3 deliver the user-visible result; 4–6 are the long tail and can be
picked up per repo in any order.
