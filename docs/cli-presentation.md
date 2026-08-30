# How the family's CLIs put a line on screen

The one presentation standard for every tool the workshop ships **that draws on a
terminal** — `bench`, `haus` and `scruff`. It lives here, beside `agent-surface.md`
and `drift.md`, because it binds every repo and belongs to none of them.

Where it *stops* — trill's CLI, pounce's command scripts, the maintenance
scripts, and the installers, which are out of the *runtime* but not the
*palette* — is **Where the standard stops**, the last section in this file, and
is as load-bearing as what it covers: a scope that is merely unstated reads as a
sweep nobody finished.

It is the design half. The runtime that implements it is its own repo (see
**The runtime**, below); this file is what that repo is judged against, and what
a bash fallback has to match line for line.

> A cat's whiskers are how it knows whether it fits through the gap. Every
> defect below is a tool that never measured.

## Why this exists — the three defects, measured

Measured 2026-08-27 against `bench` (3148 ln), `haus.sh` + `haus-show.sh`
(5034 ln) and `scruff/internal/ui/ui.go`.

### 1. Fixed-width rows in a resizable window

72 hardcoded `%-NNs` column widths across the three CLIs — `%-34s`, `%-38s`,
`%-44s`, `%-46s`. Because `printf` pads, a row occupies its full declared width
whatever the content, so the wrap threshold is a property of the *format string*
and nothing else.

`bench release`'s job row was the worst case, because it is repainted in
place:

```
printf '\033[2K   %s  %s%-34s%s %s%s%s\n'   # 3 + glyph + 2 + 34 + 1 + detail
```

That is **48 columns, always**. The repaint moves the cursor up by the number of
rows it *printed*, not the number of screen lines those rows *occupied*:

```
[ "$WATCH_PAINTED" -gt 0 ] && printf '\033[%dA' "$WATCH_PAINTED"
```

Measured in a sized pty, three job rows, three frames:

| terminal width | row width | soft-wraps | cursor-up | result |
| --- | --- | --- | --- | --- |
| 100 | 48 | no | 3 | in place |
| 49 | 48 | no | 3 | in place |
| 48 | 48 | **yes** | 3 | **scroll spam** |
| 40 | 48 | **yes** | 3 | **scroll spam** |

At exactly 48 it still breaks: a line whose width *equals* the terminal's puts
the cursor at column 49, and the terminal wraps. So the real threshold is
`COLUMNS ≥ 49` — "unless it's at the perfect window width".

`bench` already knows. `WATCH_RENDER_PY` clamps job names to 34 characters with
the comment *"the live repaint counts LINES to move the cursor back up, so a row
that soft-wraps in a narrow terminal would desync the whole frame"* — a comment
that named the bug and then narrowed the content instead of measuring the
window. Line numbers are deliberately absent from this file: it outlives them.

`haus rebuild`'s phase lines were the same defect with a second head, and both
heads are measured in a real pty (`haus/test/phase-painter.bats`):

| what wrapped | its width | wraps at | what the screen kept |
| --- | --- | --- | --- |
| the finished `activate` row | 52 cells | ≤ 52 columns | the row across two screen lines |
| the stub `phase_start` leaves | 14 cells | ≤ 13 columns | `· activate` orphaned above `✓ activate` |

The second is the one worth naming: `phase_ok` repaints with `\r`, which returns
to column 0 of the current **physical** row. While the stub fits one row that is
the same thing as the start of the line; the moment it wraps, `\r` rewinds only
its last row and the first is stranded there for the rest of the rebuild. A
painter cannot know which row it is on without measuring the window.

**Nothing anywhere handles `SIGWINCH`.** A resize mid-`bench release` corrupts
the frame for the rest of the run. `haus`'s painter draws four rows rather than
ten a second, so it re-measures per row instead and needs no trap — a resize
mid-phase is picked up by the row that lands after it, and a window that
narrowed past the stub gets a fresh line rather than a `\r` into the middle of
one.

### 2. The palette is not the palette

Seven 256-colour indices, copy-pasted into four files, none of them from
nebelung. This is the measurement the standard was written against; no family
CLI holds one today. Distance to the nearest nebelung token, CIE ΔE:

| index | hex | role | nearest nebelung | hex | ΔE |
| --- | --- | --- | --- | --- | --- |
| 103 | `#8787af` | primary accent ("the fog itself") | `blue` | `#8db4f3` | 21.8 |
| 108 | `#87af87` | ok / healthy | `green` | `#abe1a6` | 19.7 |
| 110 | `#87afd7` | repo names | `sapphire` | `#7dc6e7` | 12.4 |
| 167 | `#d75f5f` | error | `red` | `#ed8fa9` | 27.4 |
| 179 | `#d7af5f` | warn / stale | `peach` | `#f5b58e` | 22.3 |
| 243 | `#767676` | muted (haus) | `overlay0` | `#717171` | 2.0 |
| 245 | `#8a8a8a` | muted (bench) | `overlay1` | `#858585` | 1.9 |

ΔE above ~10 is "plainly a different colour". Only the two greys land close —
and they were *two different greys for one role*, `243` in haus and `245` in
bench, which is the drift this table exists to stop. All nine roles now resolve
against nebelung, so there is one grey and nobody picks it.

The accent is the sharpest joke: every family CLI's primary hue resolves to
**blue**, and nebelung is *"Mocha with the blue stripped out"*. Ghostty,
starship, bat, lazygit, yazi and delta all wear nebelung on this machine. The
tools we wrote are the only things on screen that don't.

### 3. Width is counted in the wrong unit

`printf '%-9s'` pads by bytes under most locales, not by display cells. `say()`
opens with `🌫`, which is one grapheme, four bytes, and **two display columns**.
Every column after a glyph is sheared by a different amount depending on which
glyph it was.

An ungated script is the other half of this, and `haus.sh` + `haus-show.sh`
measured 35 raw `\033[38;5;N` escapes emitted unconditionally, into pipes, files
and CI logs alike. Neither script holds an escape, nor does `bench`: every
colour in all three is an alias onto snug's generated roles, and haus's suite
fails on ANY literal escape in those two files outside a comment. There is no
legal place for one.

## The standard

### Colour roles

Nine roles. A tool names a role, never a colour. Roles resolve against the
nebelung variant in play, so a machine on `nebelung-latte` gets the light
answer for free.

| role | means | nebelung token |
| --- | --- | --- |
| `accent` | the tool speaking — `say`, section heads | `mauve` |
| `ok` | current, healthy, passed | `green` |
| `warn` | stale, wants attention, degraded | `peach` |
| `err` | failed, refused, missing | `red` |
| `muted` | secondary detail, durations, counts | `overlay1` |
| `subject` | the thing under discussion — repo, host, lane | `sapphire` |
| `path` | a filesystem path or a store path | `teal` |
| `field` | a key in a key/value grid | `subtext0` |
| `body` | ordinary text | *terminal default* |

`body` is deliberately unset rather than `text`: painting ordinary prose fights
the user's own background and is the single fastest way to look cheap.

`accent` moves off blue to `mauve` — the nearest nebelung hue to the `#8787af`
everything already uses, and the one that honours the flavour's premise.

**Degradation** is by terminal capability, decided once at startup:

| capability | how colour resolves |
| --- | --- |
| truecolor (`COLORTERM=truecolor\|24bit`) | nebelung hex, exact |
| 256 | nearest cube/grey index to the nebelung hex |
| 8/16 | nearest ANSI base, roles collapse: `subject`→`accent`, `path`→`muted` |
| none | no escapes; the glyph carries the meaning |

### Glyphs

The glyph is load-bearing and the colour is not — a role must be readable with
colour off. One glyph per role, ASCII fallback when the locale isn't UTF-8:

| role | glyph | ascii | width |
| --- | --- | --- | --- |
| `say` | `🌫` | `~` | 1 |
| `ok` | `✓` | `+` | 1 |
| `warn` | `⚠` | `!` | 1 |
| `err` | `✗` | `x` | 1 |
| `info` | `ⓘ` | `i` | 1 |
| `skip` | `–` | `-` | 1 |
| `bullet` | `·` | `.` | 1 |
| `hint` | `↳` | `>` | 1 |
| `spin` | `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` | `|/-\` | 1 |

Every glyph is **one cell**, and the gutter is therefore **3 cells wide,
always** — glyph plus padding to 3 — so that lines with different glyphs align
and continuation lines have a fixed indent to hang from.

⚠️ Widths here are **declared and measured against real terminals**, never taken
from a width library, and `🌫` (U+1F32B) is why. It has `Emoji_Presentation =
No`, so it is exactly the codepoint where sources disagree: `x/ansi` and
`runewidth` both answer 1, they disagree with *each other* on the
variation-selector form, and the reflex "emoji are two cells" — which this table
recorded until it was checked — is wrong. Measured in Ghostty, the family's own
terminal, against a column ruler: **one cell**. To check any other terminal and
get a number rather than an eyeball, ask it where its cursor ended up:

```sh
stty -echo; printf '\r\U0001F32B\033[6n'; IFS=';' read -rd R _ col; stty echo
echo "$col"   # 2 → one cell, 3 → two
```

Measurement libraries are used only on **content**, which is ordinary text and
where they agree.

### Layout

Everything is measured in display cells, resolved with grapheme-cluster width,
never bytes and never runes.

- **Prose is capped at `min(terminal width, 100)` cells.** Past 100 a line of
  text is unreadable, and a maximised terminal is not an invitation to fill it.
  **Tables and live regions are exempt** — they are already bounded by their own
  content, and a job list that stopped at 100 while the window was 200 would be
  hiding the room it had.
- **Every line fits, or is folded — never soft-wrapped.** A tool that lets the
  terminal wrap has given up its own indentation. Fold at a word boundary and
  hang continuations at the gutter.
- **Columns are budgeted, not declared.** A table gets the available width and
  each column a *weight* and a *minimum*. Columns take their natural width if
  the sum fits; otherwise the widest over its minimum gives up cells first.
- **Truncation is by priority, with `…` inside the field.** Each column says
  what it gives up first — a repo name truncates from the right, a path from the
  left (`…/scruff/internal/ui`), a duration never truncates.
- **A column that never truncates is MEASURED, never assumed.** Budget it from
  the widest value actually in the frame. `bench` budgeted seven cells for a
  duration on the reasoning that `12m 34s` is the longest one — and a job past
  a hundred minutes renders `100m 05s`, eight cells, straight into the last
  column and back into the bug the budget existed to prevent.
- **The tier is chosen from the WINDOW, then the column is clamped to the
  content — never the other way round.** Clamping first and testing the clamped
  value asks *"is the longest name short?"* when it means *"is there room?"*.
  `bench` shipped that inversion for an afternoon: a CI run of `build` / `test`
  / `lint` dropped its duration column on a 200-column terminal.
- **Below the sum of minimums, the table drops a tier** rather than emitting a
  row it knows will wrap. Three tiers, each giving up the least useful thing
  left:

  | tier | keeps | example at that width |
  | --- | --- | --- |
  | `table` | padded name column, aligned detail | `   ✓  bump-tap        12s` |
  | `list` | name only — the detail goes, and so does the padding | `   ✓  bump-tap` |
  | `bare` | the 3-cell indent collapses to one space | `✓ bump…` |

- **The floor is 2 cells** — one glyph and nothing else. At 1 cell there is
  nothing honest left to draw.

### Measuring the window

**`tput cols` is wrong and will pass review anyway.** terminfo carries a
*static* size — 80 for every `xterm-*` entry — and ncurses only overrides it
from the real window when `LINES`/`COLUMNS` are exported. Measured in a
40-column pty, `tput cols` answers **80**. A painter built on it folds to a
width the window hasn't had since 1978, and looks exactly like a painter that
works right up until someone narrows their terminal.

Use `stty size` (TIOCGWINSZ), which is the only source that tracks a resize. Read
it from `/dev/tty`, not `<&1`: inside `$( )` — which is where a shell measures —
fd 1 is the substitution's pipe and never the terminal.

**A stream with no window is not given one.** Assuming 80 for a pipe is the
`tput cols` mistake with the number hardcoded a layer up, and it costs the same
thing twice: prose folded at a column nobody chose, and a table cut to 79 cells
with an ellipsis where the path tail was — in the stream someone is about to
grep, or the file they redirected the report into. A redirected stream is
neither folded nor fitted; it is written whole.

Measure once at start, then only when `SIGWINCH` says the window actually
changed. `stty` forks; a 10 fps painter must not.

### Live regions

A live region is a block of lines rewritten in place: `bench release`'s job
list, `haus rebuild`'s phase lines, `bench rebuild`'s store counter.

The contract:

1. **Only on a TTY.** Piped, in CI or under `bats`, a live region degrades to
   one plain line per *state change*. No cursor escape ever reaches a file.
2. **Motion is not gated on `NO_COLOR`.** A spinner on a colourless terminal is
   still the thing you want to see. (`bench`'s watch loop already said this before any of
   this work; keep it.)
3. **Repaint counts screen lines, not logical rows.** Since every line is folded
   to fit, those are equal by construction — which is the whole point of folding
   rather than wrapping.
4. **`SIGWINCH` re-measures and repaints from scratch**, clearing to end of
   screen (`\033[J`) rather than trusting the old height.
5. **The cursor is restored on every exit path**, including `SIGINT` and a
   `set -e` abort. A terminal left with no cursor is the worst thing a spinner
   can do to you.
6. **Frame rate and poll rate stay unrelated.** `bench` already gets this right
   — a background fetch, a 10 fps painter, running durations clocked locally —
   and the runtime must keep it, not regress to fetch-paint-sleep.
7. **Scrollback is append-only.** Lines that have scrolled off the region are
   never rewritten; a finished region leaves its final frame in scrollback and
   moves on.

### Streams

Unchanged from scruff's `internal/ui` (SPEC.md §2.3), promoted to a family rule:
**stdout carries data only.** Every diagnostic, prompt and progress line goes to
stderr, because callers do `cd "$(scruff child …)"` and hooks read paths off
stdout.

**A report is data.** `bench status`'s tables and the `scruff` listing are the
thing the user ran the command *for*, not the tool talking about it, so they
draw on fd 1 — which is what lets `bench status | less` carry them whole — while
the narration around them stays on fd 2.

**A report is measured, gated and painted for the stream it lands on, never the
other one.** The two questions come apart the moment the streams do, and they
come apart in both directions: budget a report from stderr and a TTY stdout
beside a redirected stderr draws plain, while a piped stdout beside a live
stderr draws escapes into a pipe. Go callers get one question and one answer
from `Printer.PrintData`, which measures `Out`; `Print` is the other half, for a
table that is part of what the tool is *saying*. There is no bash equivalent, so
`bench` carries two gates asking about two streams and loses the first of those
two edges — written down in the code beside them rather than left to be
rediscovered from the screen.

## The runtime

Bash can't link a Go library, so the standard ships as two implementations of
one spec.

**A Go module + one binary**, in its own repo — modelled on `scruff`: standalone,
repo-agnostic, its own flake input, shipped on `PATH` by the layer. It exists:
[hausfold/snug](https://github.com/hausfold/snug).

- Go callers (`scruff`) import `github.com/hausfold/snug`. No process, no protocol.
- Shell callers (`bench`, `haus`) drive the binary, which the layer puts on
  `PATH` unconditionally beside `trill` and `haus-notify`. **Not pounce's
  command scripts** — see **Where the standard stops**; they have no terminal on
  the far end and must never grow one.

Two dependencies, and the second choice went the other way from what this file
first recorded. **`x/ansi` (charm's ANSI-aware string layer) plus `x/term` — 9
modules in the graph against lipgloss v2's 22, 2.1 MB against 3.0.** The parts
of lipgloss we would actually use are the parts `x/ansi` already *is*: the
family's look is quiet — aligned text and a fog palette, no borders and no
boxes — so a styling engine buys nothing and costs 13 modules.

- **Not lipgloss.** See above. It is the right answer for a bordered, boxed UI
  and this is not one.
- **Not bubbletea.** It wants to own the event loop and the screen. `bench` and
  `haus` need a filter *they* drive, not a runtime that drives them. A live
  region is ~80 lines plus a `SIGWINCH` handler.
- **Not fang/cobra.** Six verbs does not justify cobra's dependency graph.
- **Not `tput cols`.** terminfo carries a *static* size and answers 80 in a
  40-column window. `x/term` asks the kernel (`TIOCGWINSZ`), which is the only
  thing that tracks a resize — and that is the bug the whole library exists for.

**One process per command invocation, not per line.** A fork costs 4.4 ms; a
per-line fork would put 320 ms of pure overhead into a 60-line `haus rebuild`.
So the shell opens one coprocess at the top of a command, writes newline-
delimited records to its stdin for the whole run, and closes it at the end. That
also buys something bash cannot do at all today: log lines scrolling *above* a
live region that is still spinning.

**A bash fallback ships beside it** and implements the same spec at lower
fidelity — role names, the 3-cell gutter, folding, the colour gate, a correct
live region — for machines without the binary on `PATH`. It is the reason the
standard is written here in prose rather than only as Go.

## Who draws through it

Every surface a *user* drives resolves its colour from snug's generated
palette; no hand-picked 256-colour index survives in one. The installers and
the maintenance scripts still hold theirs, deliberately — see **Where the
standard stops**.

| caller | how it reaches the runtime |
| --- | --- |
| `scruff`'s `internal/ui` | imports `github.com/hausfold/snug`. No process, no protocol |
| `bench` | sources `$(repo_dir snug)/share/ui.sh`, and opens one `snug run` coprocess for a command that draws a live region |
| haus's `haus.sh` and `haus-show.sh` | ui.sh at `HAUS_UI_SH`, injected by `modules/core`; the `haus rebuild` phase painter is a coprocess |
| haus's `statusline.sh` and `image-preview.sh` | ui.sh roles only — neither draws a live region |
| haus's `lane-open.sh` | resolves `HAUS_UI_SH` and injects it into the snippet the lane's own shell runs; nothing in the script sources ui.sh itself |

haus's suite enforces this, with **two bans of different strengths, and the
difference is the point.** Over `haus.sh` and `haus-show.sh` it fails on *any*
literal escape outside a comment: those two draw nothing but text and roles, so
there is no legal place for one. Over the three painters it bans the SGR colour
forms only (`\033[38;`, `\033[48;`, the ANSI-basic sets), because those three
legitimately emit escapes that are not colour — OSC 8 hyperlinks, OSC 2 window
titles, and the DECTCEM cursor hide/show `image-preview.sh` needs. A blanket ban
there would have to be suppressed per line until it meant nothing.

**One exception is named in the ban rather than pattern-matched away**: the
statusline's `TINT_FABLE` row tint is a *background*, and the nine roles are all
foreground. It stays a raw escape, gated on the profile being truecolor — which
is also correct on its own terms, since `#382713` has no cube equivalent, and
ungated it paints a warm band behind text that `NO_COLOR` has already returned
to terminal default.

Three collisions come out of eleven statusline slots landing on nine roles.
Two lose nothing. `PURGE` and `WARN` both become `warn`, but every `PURGE` use
carries its own glyph (`⏏`, `◇`, `N^`) and `WARN`'s two carry none — **the glyph
is load-bearing and the colour is not** is this file's own rule, so the
distinction survives in the channel that holds it. `ADD`/`PR_OPEN` both become
`ok` and `DEL`/`PR_CLOSED` both `err`, which they already were by index. The
third is a real change and is written down so nobody rediscovers it from the
screen: `DOT` and `DIM` both become `muted`, so the clean `●` renders in the
same grey as the cost beside it. They were two hand-picked greys reaching for
the one role nebelung has for them, and the `●` keeps its meaning positionally.

## Rules a caller has to meet

**The record protocol.** Tab-separated, one per line, verb first — `say<TAB>text`,
`row<TAB>state<TAB>name<TAB>detail`, `paint`, `end`. A space after the verb does
not parse; `snug run` splits on tabs and answers `unknown record`. A row never
carries an empty field between two non-empty ones, because `read` collapses
consecutive delimiters — a running job's detail carries its stale duration, and
only the trailing `since` may be empty. Multi-line text is one record per line;
the emitter folds the newlines.

**One coprocess per command, opened by the live region and closed with it.** A
fork costs 4.4 ms, so the fork happens when a command opens a region — a command
that draws no region forks nothing — and the dispatch belongs to the *caller*,
not to the library: one fork per command is the whole economy, and a library
sourced per script cannot see the command boundary that decision needs. It opens only
under a terminal on fd 2 and only when ui.sh loaded, so a machine with the
binary on `PATH` but no snug checkout gets the ui.sh path even interactively —
one detection, one answer. A snug that dies once stays dead for the command
(`SNUG_TRIED` is not reset on close): a failed record write must never re-fork
per frame, which is the regression the coprocess exists to prevent. Degradation
falls back to ui.sh, and the close is guarded on `UI_READY` because the live
region exists only when ui.sh loaded.

**Outside a live region, the coprocess is the wrong writer — and a message verb
must never open one.** A record crosses a pipe and is drawn by another process on
ITS stderr; a table the command `printf`s itself goes straight to the terminal.
The two are on different schedules, so a command that mixes them prints its rows
above the section title that introduces them and wedges a row into the middle of
a folded sentence. Inside a region there is no race, because a caller writes
nothing directly while one is up — which is what makes "the region opens it" the
whole rule, in both directions. The live painter is the only caller that opens
one; and it closes with the last region rather than at the end of the command,
so that the moment the caller starts printing for itself again it is the only
writer. A run of regions may share one coprocess — `haus rebuild` opens a region
per phase and keeps it across all of them — but the close cannot wait for the
command: `bench release --ship` ends inside `bench ship`, whose tables would
interleave with its own section titles, and `haus rebuild`'s failed phase dumps
25 lines of build log straight to the terminal.

**Anything drawing from a background job needs its own duplicate of the write
end.** Bash closes a coprocess's descriptors in every child it forks, so a
background painter writing to `${SNUG[1]}` silently does nothing — the row
freezes at `0.0s` while every other assertion stays green. `exec {FD}>&"${SNUG[1]}"`
is the whole fix, because a plain duplicate is inherited like any other fd; bash's
own copy is then closed, or nothing ever reaches EOF. **And its converse: anything
backgrounded that draws NOTHING must drop that fd.** The close half of `snug_close`
waits for `snug run` to see EOF, and an inherited copy in an unrelated background
job keeps it from ever arriving — measured, the wait lasted exactly as long as
that job. Where the job's own exit condition is "the parent is gone", which is
what a progress ticker watches, the two wait for each other with no clock on it. **Write a test that counts
frames** — a spinner that never turns looks exactly like a phase that is taking
a while. The loop's leash is `kill -0 $$`: it holds a copy of the write end, so
without that check a finished caller leaves snug spinning as an orphan.

**Nothing may repaint while `sudo` might be asking for a password.** The prompt
goes to `/dev/tty` — the same terminal the region repaints, and one the region's
line count knows nothing about — so ten frames a second rewind over the prompt
and over what is being typed into it. `haus` draws `activate` as a still row
unless `sudo -n true` proves the timestamp is already valid: a one-way probe
that under-detects on purpose, because the safe direction is the still row.

**Which stream a command draws on is a property of the COMMAND, not the verb.**
`haus` sets `REPORT=1` in its dispatch for `status doctor plan diff permissions
btm generations get capture`; those draw entirely on fd 1, everything else
entirely on fd 2. `die` and progress are the exceptions inside a report and are
always fd 2 — an error is not part of a report, and neither is a "fetching …"
line. A per-verb split cannot be right: half the verbs are called from helpers
that both kinds of command use, so `settings_diff` inside `haus plan` and inside
`haus set` want opposite answers — and a split header/body makes `haus doctor |
pbcopy` an unlabelled list of ticks, which `docs/bug-reports.md` makes the entire
feedback channel for a product with no telemetry. The cost is that a report gets
no folding, because it cannot use the coprocess: `snug run` draws on ITS stderr,
which is the terminal, not the calling command's stdout. `bench`'s status tables
pay the same price.

**One colour precedence, asked rather than re-derived.** ui.sh measures fd 2 at
load. A report draws on fd 1, so ask ui.sh again — `ui__detect_profile` /
`ui__resolve_palette` with `UI_TTY` set from fd 1 — and read `C_*` off that
answer. Spelling the rule a second time by hand is how one binary comes to answer
`NO_COLOR` + `CLICOLOR_FORCE` two ways. Neither answer is wrong in the abstract;
two answers in one binary is.

**Force the gate where colour is correct without a tty.** haus's statusline
renders with both descriptors captured — Claude Code reads the line and puts it
in a terminal — so a measured `[ -t 2 ]` answers "no colour" for output that
lands in colour anyway. It sets `UI_TTY=1` rather than measuring, and forces
*only* that, leaving `NO_COLOR` and `TERM=dumb` still able to win.

**Never call your path-to-ui.sh variable `UI_SH`.** That is ui.sh's own
source-twice sentinel (`[ -n "${UI_SH:-}" ] && return 0`), so a caller holding
the path in it makes the file return before defining anything: no error, no
colour, and a suite that stays green because every role is legitimately empty
when the painter is absent. haus's is `HAUS_UI_SH`, and the module injects it
rather than letting the script re-resolve a constant path three times per prompt.

**ui.sh is bash 4+, and macOS's `/bin/bash` is 3.2** — where it does not degrade
but half-loads with `bad substitution`. Use `#!/usr/bin/env bash` and a
`BASH_VERSINFO` guard, and put the guard in the text that actually *sources* it:
for a script that hands a snippet to another shell, the snippet is the caller,
and a `grep` against the outer file is satisfied by a guard protecting nothing.
A script that never sources ui.sh in its own shell keeps `/bin/bash` — an
absolute interpreter beats an inherited `PATH` under launchd.

**A width probe must not be able to kill its caller.** This shape:

```sh
sz="$(stty size 2>/dev/null </dev/tty)" && COLS="${sz#* }" || COLS="$(tput cols 2>/dev/null)"
```

`set -e` exempts every command in a `&&`/`||` list **except the last**, and
`tput` exits 2 with `TERM` unset — the shape of any session with no pty
(`ssh mac haus rebuild`, a launchd job, CI). The caller exits 2 with nothing on
either stream, after a successful evaluation and before anything activated, and
the sanitising `case` that exists precisely to cope with a bad answer never runs.
`|| true` inside that final substitution is the fix. **A width probe that can
kill its caller is the worst possible failure mode for a courtesy** — which is
the argument for one runtime rather than four copies. ui.sh deliberately does
not inherit the line.

**The binary owns a signal policy; the library does not.** `snug run` installs a
SIGINT handler and exits 128+signum, because Go's default disposition terminates
without running a `defer`, so the region's `Close()` never fires and a ⌃C leaves
the terminal with no cursor. The caller cannot fix that — the coprocess is dead
before bash's INT trap runs. A Go program importing the package owns its own
policy, so the library installs nothing.

## Why the fallback lives in snug

`ui.sh` is not kept in step with `palette.go` — the two are *generated from the
same list*. snug's `script/gen-palette.sh` writes `palette.go` and ui.sh's
`UI__HEX` / `UI__X256` blocks in one run, from one nebelung checkout and one
`TOKENS` list, and snug's suite re-derives every 256-colour index and diffs the
hex against `palette.go` on every push. A fallback that drew a *different*
colour from the binary would be worse than no fallback, because it makes "which
machine is this?" a question you have to ask about your own output. Both halves
live in one repo so that test always runs: split across two, it is a diff that
skips — green, checking nothing — on any machine without the second checkout.

It ships **inside snug's derivation, beside `bin/snug`**, so the binary and the
stand-in for the binary arrive together or not at all. The caller that most
needs it could not reach it anywhere else: `haus.sh` is `builtins.readFile`'d
into a store binary, and a haus user has no workshop checkout. Vendoring a copy
into haus would reintroduce exactly the drift the fallback exists to delete;
haus already takes `inputs.snug`, so its derivation reads `${snug}/share/ui.sh`
straight off the store path, with no copy and nothing to drift.

## Where the standard stops

Four surfaces are **deliberately** outside it, and not all in the same way: two
are out entirely, one is out of the *runtime* but not the *palette*, and one is
out of everything. Each is a decision, not a backlog — re-open one by editing
this section, not by quietly converting a file.

- **trill's `trill` CLI — plain, and staying plain.** It draws no colour at all,
  and that is settled rather than pending. It is Swift, so it cannot import
  snug's package; the only way in is to drive `snug run` over the record
  protocol as a coprocess. That is possible — it is what the protocol is for —
  but it is a *feature* somebody would have to want, not a sweep somebody
  forgot, and nobody wants it. Do not file it as debt.
- **pounce's command scripts — permanently out.** A command's stdout is the
  *launcher's* input, parsed by the app; there is no terminal on the other end of
  it and an escape there is a bug, not a style. The `# pounce:` header comments
  are its whole presentation contract. This is why they are clean today and why
  nothing should ever make them otherwise.
- **The installers — exempt from the RUNTIME, not from the palette.** `haus`'s
  `bootstrap.sh` (the standalone `curl | bash`, on a Mac with no nix at all) and
  `haus-activate.sh` (handed a reset environment by `sudo`, as root, to activate
  the very generation that would install `share/ui.sh`) genuinely cannot reach a
  painter: an installer that needs the thing it installs is not an installer.
  That is a fact about WHEN they run, and it is permanent.

  It bought them more than it should have. "Cannot source it" was read as
  "colour is somebody else's problem", and the result was the standard's own
  founding defect surviving on the one screen a new user sees before anything
  else: `bootstrap.sh` had no gate at all and four escapes picked by eye,
  `say` among them on index 103 — a **blue**, the one hue nebelung exists to
  strip out. So the exemption is narrowed to what it actually covers. These two
  may not *source* snug; they must still **carry its numbers**:

  - every constant is **copied out of snug's generated `share/ui.sh`**, for the
    `nebelung` variant, which is what `ui__detect_variant` answers on a machine
    with nothing in `~/.config/snug/variant` — which is exactly the machine an
    installer runs on. Copy the hex *and* the 256 index *and* the 16-colour
    name; never hand-pick one, and never derive the index by eye. Hand-picking
    is the defect, not sourcing.
  - the gate is **ported, not re-derived** — `NO_COLOR` beats everything except
    `CLICOLOR_FORCE`, a non-TTY is colourless unless forced, `dumb` means it
    even when forced.
  - a copy drifts, so **a test diffs it back**: `haus`'s
    `test/installer-palette.bats` reads the roles and the precedence out of the
    real `share/ui.sh` at the pinned rev and reds when either moves. An inlined
    palette with no drift test is the hand-maintained copy this whole exercise
    deleted; the test is the price of the exemption, not an extra.

  `bootstrap.sh` is also the one family CLI that gates **two streams
  separately**. The two-streams rule elsewhere keys on the *command* — a report
  draws on fd 1, a narrator on fd 2 — but bootstrap's whole preflight (the
  audit, the settings table, the undo note) is plain stdout prose, so its
  narration is gated with it on fd 1 and only `die` draws on fd 2. One gate
  asked about both streams is how `bootstrap.sh | tee log` comes out either
  escape-littered or silently monochrome.
- **The maintenance and probe scripts — out, permanently, by decision.**
  `haus`'s `script/build-golden-vm.sh`, trill's `scripts/dev-install.sh`, and
  this repo's `script/issue-labels.sh` and `script/probes/*.sh`. These do *not*
  meet the installer test — `build-golden-vm.sh` wants `tart` on PATH and runs
  on a fully provisioned Mac, so it could source a painter perfectly well — and
  the honest reason is different: their whole audience is the four people with a
  workshop checkout, and a colour they get wrong costs a maintainer one squint.
  Say that rather than stretching the installer argument over them, which is how
  an exemption list turns into a place to hide things. This is a **settled
  scope**, not a queue: they are not waiting for anybody, and "convert the last
  few scripts" is not a piece of work that exists. Converting one anyway is not
  forbidden — it is just nobody's task, and it does not belong in a sweep, a
  checklist or a PR body as though it were owed.
