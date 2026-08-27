# How the family's CLIs put a line on screen

The one presentation standard for every tool the workshop ships — `bench`,
`haus`, `holt`, `trill`, and every `pounce` command script. It lives here, beside
`agent-surface.md` and `drift.md`, because it binds every repo and belongs to
none of them.

It is the design half. The runtime that implements it is its own repo (see
**The runtime**, below); this file is what that repo is judged against, and what
a bash fallback has to match line for line.

> A cat's whiskers are how it knows whether it fits through the gap. Every
> defect below is a tool that never measured.

## Why this exists — the three defects, measured

Taken on 2026-08-27 against `bench` (3148 ln), `haus.sh` + `haus-show.sh`
(5034 ln) and `holt/internal/ui/ui.go`.

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
nebelung. Distance to the nearest nebelung token, CIE ΔE:

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
bench, which is the drift this table exists to stop. That one is settled: haus
moved to `245` when it grew the gate, so the family has one muted grey until
step 4 resolves all nine roles against nebelung.

The accent is the sharpest joke: every family CLI's primary hue resolves to
**blue**, and nebelung is *"Mocha with the blue stripped out"*. Ghostty,
starship, bat, lazygit, yazi and delta all wear nebelung on this machine. The
tools we wrote are the only things on screen that don't.

### 3. Width is counted in the wrong unit

`printf '%-9s'` pads by bytes under most locales, not by display cells. `say()`
opens with `🌫`, which is one grapheme, four bytes, and **two display columns**.
Every column after a glyph is sheared by a different amount depending on which
glyph it was.

`haus.sh` and `haus-show.sh` additionally had **no colour gate at all** — 35
raw `\033[38;5;N` escapes emitted unconditionally, into pipes, files and CI logs
alike. `bench`'s palette block gets this right and was the model; both now carry
a copy of it, and a bats case fails on any new escape written outside it.

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
| `say` | `🌫` | `~` | 2 |
| `ok` | `✓` | `+` | 1 |
| `warn` | `⚠` | `!` | 1 |
| `err` | `✗` | `x` | 1 |
| `info` | `ⓘ` | `i` | 1 |
| `skip` | `–` | `-` | 1 |
| `bullet` | `·` | `.` | 1 |
| `hint` | `↳` | `>` | 1 |
| `spin` | `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` | `|/-\` | 1 |

`🌫` is width 2 and every other glyph is width 1. The gutter is therefore
**3 cells wide, always** — glyph plus padding to 3 — so that lines with
different glyphs align and continuation lines have a fixed indent to hang from.

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
  left (`…/holt/internal/ui`), a duration never truncates.
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

Unchanged from holt's `internal/ui` (SPEC.md §2.3), promoted to a family rule:
**stdout carries data only.** Every diagnostic, prompt and progress line goes to
stderr, because callers do `cd "$(holt child …)"` and hooks read paths off
stdout.

## The runtime

Bash can't link a Go library, so the standard ships as two implementations of
one spec.

**A Go module + one binary**, in its own repo — modelled on `holt`: standalone,
repo-agnostic, its own flake input, shipped on `PATH` by the layer.

- Go callers (`holt`) import the package. No process, no protocol.
- Shell callers (`bench`, `haus`, pounce commands) drive the binary.

Measured before choosing: **lipgloss v2 (`charm.land/lipgloss/v2`) plus
`x/term` — 3.0 MB stripped, 4.4 ms cold start, 22 modules in the graph.**

- **Not bubbletea.** It wants to own the event loop and the screen. `bench` and
  `haus` need a filter *they* drive, not a runtime that drives them. A live
  region is ~80 lines of lipgloss plus a `SIGWINCH` handler.
- **Not fang/cobra.** Six verbs does not justify cobra's dependency graph.

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

## Order of work

1. This file. ✔
2. `bench` — fold to width, `\033[J`, `trap WINCH`. ✔ *(landed; eight tests in
   `test/bench.bats` hold the contract across sixteen widths from 2 to 120, plus
   a real pty for the measurement itself.)* `haus`'s phase painter — same
   treatment, still to do.
3. The shared bash fallback, sourced by `bench` and `haus.sh`; holt's
   `internal/ui` moved onto the same role names.
4. The Go module and binary. The bash fallback is demoted to the no-binary path.

Steps 2 and 3 are worth doing even if step 4 slips: they delete the 72
hardcoded widths and the four copies of the palette, which is where the drift
lives.
