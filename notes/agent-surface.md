# The agent surface

Working standard, 2026-08-16. What every hausfold tool owes a coding agent, and
how that reaches a user — whether they run haus or downloaded one app.

Current code is the source of truth for what exists; §8 is the measured gap
between that and this standard, and §9 is the order it closes in.

## 0. The claim

The family is already half AI-native and nobody wrote it down. Nearly every
tool is configured by a file rather than a settings window (§8 names the one
that isn't); pounce, perch, trill and holt each expose a CLI; holt already emits
`--json`. What's missing is mostly not capability — it's **discoverability and
uniformity**. An agent sitting in front
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
<tool> skill                 print the tool's own SKILL.md to stdout
<tool> skill <name>          print one of its other skills (§A4)
<tool> skill install         write ALL of them into every agent client found
<tool> skill install --client claude|codex|opencode
<tool> skill install --dir PATH
```

**`install` means all of them.** A tool that ships a second skill and installs
only its first has shipped a skill that exists in the repo, in the binary and in
the derivation, and reaches no standalone user — the "installed, listed, never
loaded" failure this whole note is built around, one step earlier. Bare
`<tool> skill` stays singular because it is the "show me the thing" form and a
tool with one skill is still the common case.

**Embedded, not a file on disk.** A Homebrew cask ships an `.app`; a Nix build
ships a store path; `go install` ships one binary. Only embedding is uniform
across all three, and it makes the docs impossible to desync from the binary
that implements them — the version that answers `--help` is the version that
answers `skill`.

`install` writes `<skills-dir>/<name>/SKILL.md` — one directory per skill,
named for the skill rather than the tool, so a tool shipping several lands
several — and refuses rather than clobbers: if the target exists and differs, it says so and prints the diff
path. **On a haus machine it refuses outright** — those directories are
read-only Nix symlinks, and haus has already installed the skill (§4). Say
that in the refusal; don't make the user work it out from an EPERM.

The verb is `skill`, not `agent`: all three clients call these things skills,
and in this family `agent` already means a launchd agent.

### A4 — One shape, ≤150 lines each

Committed at `ai/SKILL.md` in the tool's own repo — the source, embedded at
build time. **One skill is the shape.** A tool ships a *second* only when it
owns a job that has no verb, and then it is a sibling directory,
`ai/<name>/SKILL.md`, under the rules at the end of this section. holt is the
first: `handoff`, which is how to write the brief `holt spawn --prompt-file`
opens a lane on. The shape below is the same for every one of them:

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
  `perch`, `trill`, `holt`, `nebelung`, and holt's `handoff`. They land in one
  shared `~/.claude/skills/`, next to whatever else the user installed. A name
  that is not a tool name is the one to think hard about: check it against that
  list **and against the host's own hand-wired skills**, because a machine that
  already declares `~/.claude/skills/<name>` gets an activation conflict, not a
  winner. (`handoff` did exactly that, and the host file had to give it up in
  the same rebuild.)
- **A second skill has to be ABOUT the tool.** If it would read the same with
  the tool's name swapped out, it is a personal workflow file and belongs in the
  user's own config, not in a repo strangers install from. The test that passed
  for `handoff`: the brief is the argument to a holt flag, and a flag whose
  argument nobody knows how to write is a flag nobody uses well.
- **The description is ONE physical line, and at least 80 characters.** A YAML
  folded scalar (`>-` and an indented body) is valid YAML and every build guard
  here rejects it, on purpose: the guards are `grep`, and a description that
  needs a parser is a description that can silently stop being checked. The
  floor is in the standard rather than in each repo's guard so that the number
  cannot drift between repos — under it there are not enough of the user's own
  phrases in there to route on.
- **The skill's `name:` key must match the directory it installs into.** Two
  identifiers for one thing — the path a client scans, and the string it routes
  on — and a mismatch installs a skill under a name nothing ever asks for.
- **Name the failure, not the feature, when the tool can't do the thing.** A
  skill whose `description` advertises only what the tool does never loads on
  the sentence it most needs to refuse. perch's is the case: it has no read
  verb, so *"what's on my shelf?"* must be in the description or the paragraph
  that says "don't invent `perch list`" never fires.
- **No option or flag inventories in the hand-written half.** Anything that
  drifts gets *generated* (haus's `references/options.md` is the pattern:
  rendered from the module system, so it can't be wrong about the revision on
  this machine). Prose in the SKILL.md is only for what doesn't drift.
- **Every claim in it is runnable.** A command in a SKILL.md that has never
  been run is a confidently-wrong instruction with a nice format.

### A5 — Config is a file, and the file has a schema

Settings live in a file the agent can read, diff and edit — never only in a UI.
Going further, each tool grows a `<tool> config print --json` showing the
**effective** values including defaults, so an agent can tell *unset* from *set
to the default*. pounce already has `config print`; that's the shape.

This is *nearly* true across the family and it is worth being precise about
where it isn't, because "settings live in a file" is the sentence this whole
standard rests on. pounce (`config.json`), trill
(`~/.config/trill/rules.json`) and holt (`~/.config/holt/config.toml`) check
out. **perch does not:** its user-facing settings — `showOnAllDisplays`,
`retentionDays`, `mobileEnabled`, `launchAtLogin` — live in `UserDefaults`
(`Perch/App/AppSettings.swift`), which is exactly the click-only case this
requirement forbids. Its `~/.config/perch/config.json` holds machine-written
*theme* defaults only, and that file's own comment says so.

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
`modules/options-groups.nix`, which already carries a blurb per room.

⚠️ **That file has two records and both have a `focus`.** `groups` is
per-**namespace** (`{ order; blurb; }`) and is what the host template and
hausfold.co's option reference read. `rooms` is per-**room**
(`{ title; order; blurb; }`) and is the one this wants — land the new fields on
`groups` and you get a namespace list wearing a room's name.

```nix
# in `rooms`, not `groups`
focus = {
  title = "Focus";
  order = 90;
  blurb = "One quiet switch: …";                                        # exists
  agent.cli  = "pounce focus on|off|status";                            # NEW — the runtime verb, or null
  agent.asks = [ "make my mac quiet" "turn on do not disturb" "hush" ]; # NEW
};
```

One more field, one more renderer, no new source of truth — and `room-registry`
(haus's `flake.nix`) already fails the build on "a room with no title or no
blurb", so a new room cannot silently ship without its routing row once `agent`
joins that check.

## 4. Distribution

**haus machines.** `haus.ai.skill` grows from "install the haus skill" to
"install the haus skill **and every skill each hausfold tool on this machine
ships**" — per skill, not per tool, since a tool may ship more than one (§A4).
haus
already takes nebelung, pounce, perch and holt as flake inputs, so each flake
exposes its SKILL.md as a package output (`pkgs.<tool>-skill`) and haus copies
the ones whose room is actually enabled — the shelf room off means no perch
skill, because a skill for an app you don't have is worse than none: the agent
will confidently offer it.

⚠️ **This used to say trill is not one of those inputs. As of 2026-08-25 it
is** — route B landed: haus takes trill as a flake input and `haus.trill.enable`
is a real room, so `pkgs.trill-skill` is reachable and gates on that switch like
every other. What stayed true is the narrower claim underneath: trill is still
not in `bench`'s `FAMILY` (bench's 🚨 by `FAMILY` explains why a lock edge and
family membership are different questions). `trill skill install` remains the
answer for a standalone user with no haus.

Same install path as today: into each client's own skills dir
(`~/.claude/skills`, `~/.codex/skills`, `~/.config/opencode/skills`), one entry
per skill, named by the TOOL rather than by haus. haus's own skill stays
file-by-file because `this-machine.md` is rendered per host and has to sit
beside the store-built parts; a tool's skill has no per-host half, so it is one
directory symlink. ⚠️ A host that hand-wires `~/.claude/skills/<name>` for a
skill of the same name must drop it in the **same rebuild** — see §9 step 3.

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
  ai/<name>/SKILL.md       any further skill, same shape (§A4) — usually none
  script/check-skills.sh   the guards, as a script BOTH CI and Nix run
  <build>                  embeds ai/**/SKILL.md into the binary
  flake.nix                exposes packages.<system>.<tool>-skill
                           whose output is $out/<name>/SKILL.md per skill
<tool> --help              verbs, flags, exit codes
<tool> <verb> --json       stable schema, stdout only
<tool> skill               prints the embedded SKILL.md
<tool> skill install       writes every skill into every client found
```

Five files' worth of work per tool, and the one that takes thought is the
`description`.

**The derivation's output is `$out/<tool>/SKILL.md`, not `$out/SKILL.md`** —
one nesting level, named for the skill. It means a consumer links a directory
whose name is already right, and it means the *tool* decides its skill's folder
name rather than whoever installs it. That is a real choice and this is where it
is made; it is not implied by anything else here.

**A tool shipping more than one skill lays them out as siblings** —
`ai/<name>/SKILL.md` → `$out/<name>/SKILL.md`, beside the tool's own. holt is
the first (`handoff`); the rules that keep that from becoming a dumping ground
are in §A4, because they bind the skill rather than the packaging. **Every
guard runs per skill**, not once on the first one.

haus is the one variant, in two ways, both legacy rather than exemption: its
skill source is `modules/ai/agents/SKILL.md` (a room's file, not a repo
root's) and its derivation is flat, `$out/SKILL.md`, because it predates this
paragraph. Its *generated* half — a reference rendered from the module system
rather than hand-written — is the part the other five copy.

**Each repo's build files follow that repo's own convention**, so the
derivation lives at `nix/skill.nix` in perch, trill, holt and nebelung, and at
`pkgs/pounce-skill/default.nix` in pounce, which keeps its packages under
`pkgs/<name>/`. Only the package *name* and the output *layout* are fixed.

**The guards go in a script the repo's own CI runs, not in the `runCommand`
body.** Every guard exists because the failure it catches is invisible at
runtime — a skill with broken frontmatter is installed, listed and never
loaded — so a guard that only runs on a developer's machine catches nothing.
That was the original rule here ("a repo whose CI builds anything must build its
skill package"), and it turned out not to reach: most of these repos build Go or
Swift in CI and **no Nix at all**, so guards living in the derivation ran
nowhere that mattered. A plain script satisfies both callers. holt's is
`script/check-skills.sh`, run by `nix/skill.nix` and by `check.yml`, and it
**discovers** `ai/*/SKILL.md` rather than taking a list — three hardcoded lists
(script, derivation, workflow) is three places to forget a new skill, and
forgetting it in the CI copy reinstates the whole gap.

⚠️ **`holt` has a naming conflict to resolve before step 4.** Its `SPEC.md`
§14.5 already reserves this capability as `holt docs agent [--format=md|json]`,
with a `{version, body}` envelope, which is a different verb and a different
output shape from `<tool> skill`. One of the two names has to go, and holt's
came first. Decide it when step 4 starts, not by whichever gets implemented.

## 7. How we know it works

Not "the file exists". The acceptance test is behavioural, per tool, run in a
pane with no context:

> Open a fresh agent session on a machine with the tool installed and no
> checkout of its repo. Say the sentence a user would say. It works on the
> first try, with no follow-up question about flags.

The sentences are the fixtures, **one per skill** rather than one per tool — a
second skill with no sentence of its own is a second skill nothing tests:

| skill | the sentence |
|---|---|
| perch | "put this file in my shelf" / "what's on my shelf?" |
| pounce | "what did I copy three things ago?" |
| trill | "tell me when this build finishes" |
| holt | "what agent worktrees do I have open?" |
| holt · handoff | "hand this off to a fresh session" / "spawn an agent to do this" |
| haus | "make my terminal font bigger" |
| nebelung | "what's the hex for the background colour?" |

A tool that needs a second turn to get the flags right has not met the
standard, however complete its SKILL.md is.

## 8. Where the family stands

A1/A5 measured 2026-08-16; **A2/A3/A4 re-measured 2026-08-22**, because step 2
landed everywhere in between and the old table had stopped being true about four
repos at once.

| tool | A1 · CLI covers UI | A2 · JSON + exits | A3 · `skill` verb | A4 · SKILL.md | A5 · config file |
|---|---|---|---|---|---|
| **holt** | ✅ full lifecycle | ✅ `list --json`, `watch --json` NDJSON, exits 0–5 | ❌ | ✅ **two** — `holt` + `handoff` | ✅ `config.toml` |
| **haus** | ✅ `set/get/options/status/plan/diff/doctor` | ⚠️ `show --json` only | ❌ (skill exists, no verb) | ✅ generated | ✅ host file |
| **pounce** | ⚠️ rich (`run`, `drafts`, `focus`, `doctor`, `config print`), but `drafts list` is TSV-only | ❌ no `--json` anywhere | ❌ | ✅ (`pkgs/pounce-skill`) | ✅ `config.json` |
| **trill** | ⚠️ `send`/`ping`/`doctor`; no read of what fired | ⚠️ `--json` **output** on `doctor` only (`send --json` is an *input* format) | ❌ | ✅ | ✅ `rules.json` |
| **perch** | ❌ **`add` only** — cannot list or remove | ⚠️ `--json` on `add` | ❌ | ✅ | ❌ **`UserDefaults`** |
| **nebelung** | ❌ no CLI at all | ✅ palette is JSON | ❌ | ✅ | n/a |

**A4 is done — all six, step 2 is closed.** What is left of the cheap half is
A3: the `skill` verb exists nowhere, so a standalone user still gets nothing.
haus's A2 has moved off "no `--json` on any verb" (`haus show --json`); the rest
of that column is unre-measured beyond the spot checks above, and A1/A5 are the
2026-08-16 reading.

Reading the table: **A3 is uniformly absent and uniformly cheap** — it is one
verb over docs that already exist, and it is what a standalone user feels.
**A1 is the expensive column and only perch and nebelung genuinely fail it**; perch's gap is
the one that breaks a real sentence today ("what's on my shelf?"), and perch is
also the one A5 failure.

⚠️ **`perch add` has never shipped.** It landed in perch#63, after the
`v2026.08.14-1` tag, so the released app — the one installed on this machine —
has no `perch-cli` in its bundle at all, and `nix/package.nix` guards against
exactly that by skipping `bin/perch` when the binary is missing. Perch's skill
is therefore correct and inert until `bench release perch` runs. Nothing else in
the table has this problem.

## 9. Order

1. **This note**, and the `AGENTS.md` routing row that points here.
2. ~~**`ai/SKILL.md` in five repos**~~ — **done** (perch, trill, pounce, holt,
   nebelung all ship one, each with a `nix/skill.nix` exposing
   `pkgs.<tool>-skill`; pounce's lives at `pkgs/pounce-skill/` per its own
   convention). haus was never in this step: its skill source already lives at
   `modules/ai/agents/SKILL.md`, and is the pattern the other five copied.
3. **haus installs them** — `haus.ai.skill` extended to every tool's skill, plus
   `references/rooms.md` from `options-groups.nix`'s `rooms` record. After this,
   a haus user has the whole thing (minus trill — see §4). ⚠️ **A skill whose
   name a host file already hand-wires collides**: two definitions of one
   `home.file` path is a home-manager *eval* conflict, not a last-wins, so the
   host-side removal and the install must land in the same rebuild.
4. **`<tool> skill` verb** in pounce, perch, trill, holt. Public CLI surface on
   released tools, so it rides a normal release, not a hotfix.
5. **perch's read verbs** — `perch list`, `perch rm`, `--json` on both, and its
   settings out of `UserDefaults` into a file. The one repo failing two
   requirements, and the only one where a released sentence is still broken.
   **`bench release perch` is a prerequisite for any of perch's agent surface to
   exist on a real machine** (see §8).
6. **`--json` sweep** — pounce's read verbs, trill `list`, `haus get --json`.

Steps 2 and 3 deliver the user-visible result; 4–6 are the long tail and can be
picked up per repo in any order. With 2 done, **3 is the whole remaining
user-visible win** — six skills exist and, until it lands, a haus machine
installs one of them.
