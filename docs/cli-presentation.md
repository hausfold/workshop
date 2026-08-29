# How the family's CLIs put a line on screen

The one presentation standard for every tool the workshop ships **that draws on a
terminal** — `bench`, `haus` and `scruff`. It lives here, beside `agent-surface.md`
and `drift.md`, because it binds every repo and belongs to none of them.

Where it *stops* — trill's CLI, pounce's command scripts, the installers, the
maintenance scripts — is **Where the standard stops**, the last section in this
file, and is as load-bearing as what it covers: a scope that is merely unstated
reads as a sweep nobody finished.

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

## Order of work

The list is the durable record of what is left; keep it true or it stops being
one. State as of 2026-08-29:

| | | |
|---|---|---|
| 1 | **This file** — the standard itself | ✔ done |
| 2 | **`bench`'s live painter** — folded to width, `\033[J`, `trap WINCH` | ✔ done (#469; eight tests in `test/bench.bats` across widths 2–120, plus a real pty for the measurement) |
| 3 | **`haus`'s phase painter**, and the colour gate `haus.sh` / `haus-show.sh` never had | ✔ done ([haus#547](https://github.com/hausfold/haus/pull/547); 16 bats cases). Two heads, and §1 has the distinction: the finished row merely *wraps*, the 14-cell `phase_start` stub is what strands a line above its own successor |
| 4 | **[hausfold/snug](https://github.com/hausfold/snug)** — the Go package and the binary | ✔ done, public, CI green |
| 5 | **scruff's `internal/ui`** onto snug's roles | ✔ done ([scruff#70](https://github.com/hausfold/scruff/pull/70), re-pinned in [scruff#71](https://github.com/hausfold/scruff/pull/71)) |
| 6 | **snug reachable** — flake input, `bench`'s `EDGES`, on `PATH` | ✔ done ([snug#2](https://github.com/hausfold/snug/pull/2) → [haus#545](https://github.com/hausfold/haus/pull/545) → [workshop#473](https://github.com/hausfold/workshop/pull/473)) |
| 7 | **`bench` onto `snug run`** as a coprocess | ✔ done ([workshop#482](https://github.com/hausfold/workshop/pull/482); eight bats cases around the record contract, including one that feeds bench's exact bytes to a real `snug run`; see **What 7 shipped**, below) |
| 8 | **The bash fallback** — [`snug/share/ui.sh`](https://github.com/hausfold/snug/blob/main/share/ui.sh), the same spec in bash | ✔ done (17 bats cases; the width sweeps run 2–200 at four colour depths). Written here as `lib/ui.sh` in [workshop#476](https://github.com/hausfold/workshop/pull/476), moved into snug the same week — see **Why 8 lives in snug** below |
| 9 | **`haus` onto `snug run`** — the end-user CLI's own step 7 | ✔ done ([haus#562](https://github.com/hausfold/haus/pull/562); 30 bats cases, two of them real ptys). Both end-user scripts, not one: `haus.sh` and `haus-show.sh` — see **What 9 shipped**, below |
| 10 | **haus's three remaining painters** — `modules/ai/statusline.sh`, `modules/terminal/scripts/image-preview.sh`, `modules/terminal/lanes/lane-open.sh` | ⏳ open. The last hardcoded indices in anything a *user* drives; the maintenance scripts under **Where the standard stops** still hold theirs. See **What 10 has to answer**, below |

**What 10 has to answer.** Two things 7 and 9 never met, both in
`statusline.sh`, and both worth knowing before the diff:

- **It renders with stdout piped, not to a terminal.** Claude Code captures the
  line. `ui__detect_profile` gates on a tty, so sourcing `ui.sh` naively turns
  the HUD monochrome — the gate has to be forced (`UI_TTY=1`) rather than
  measured. This is the first caller in the family whose colour is *correct*
  without a tty, and the fallback's own detection is wrong for it by design.
- **Eleven slots against nine roles, and the collision is fine.** `PURGE` (256
  index 173, orange) and `WARN` (179, yellow) both land on `warn`. That reads as
  a lost distinction and is not one: every `PURGE` use carries its own glyph
  (`⏏`, `◇`, `N^`) while `WARN`'s two carry none, and **the glyph is
  load-bearing and the colour is not** is this file's own rule. The distinction
  survives the collapse in the channel the standard says holds it.

  A third slot, `NAME`, was `\033[1m` — bold, an ATTRIBUTE rather than a colour,
  and the nine roles carry no weight. It becomes `subject`, which is what a
  worktree name is; the bold is simply gone, and nothing needed it.

  The row tint is the one genuine gap — `TINT_FABLE`'s `\033[48;2;…` is a
  *background*, and the nine roles are all foreground. Either it stays a raw
  escape with a comment saying so, or snug grows a background role. It is one
  line either way; do not let it hold up the other ten.

**What 7 shipped.** `bench` sources `$(repo_dir snug)/share/ui.sh` and calls
`ui_say` / `ui_row` / `ui_paint`; where `snug` is on `PATH` and fd 2 is a
terminal it opens ONE coprocess for the whole command — lazily, on the first
line the command draws, so a verb that prints nothing forks nothing — and
writes the same records to it. The dispatch belongs to `bench`, not to the
library — one fork per *command* is the whole economy, and a library sourced
per script cannot see the command boundary that decision needs.

Three contract points worth having in one place:

- **Records are tab-separated, one per line, verb first** — `say<TAB>text`,
  `row<TAB>state<TAB>name<TAB>detail`, `paint`, `end`. A space after the verb
  does not parse: `snug run` splits on tabs and answers `unknown record`.
- **A row never carries an empty field between two non-empty ones.** `read`
  collapses consecutive delimiters, so a renderer row's detail is never empty
  for a running job (it carries the stale duration) — only the trailing
  `since` field may be empty.
- **Multi-line text is one record per line.** Newlines would break record
  framing; the emitter folds them.
- **A snug that died once stays dead for the command.** `SNUG_TRIED` is not
  reset by `snug_close`, so a failed record write never re-forks per frame —
  the fork-a-frame loop is the regression the coprocess exists to prevent.
  A dying coprocess degrades to ui.sh: `watch_paint || true` keeps the watch
  alive, the verbs fall back, and `ui_live_close` is guarded on `UI_READY`
  because it exists only when ui.sh loaded.
- **The coprocess opens only under a terminal on fd 2**, and only when ui.sh
  loaded (`UI_TTY` is ui.sh's). A machine with the binary on PATH but no
  snug checkout gets the ui.sh path even interactively — one detection, one
  answer.

The watch's duration clock stays in `bench` (a running job's seconds re-derive
every frame from its start epoch); folding, the budget, the tiers, the resize
and the cursor are snug's. The message verbs (`say`/`warn`/`hint`/`die`) moved
to fd 2 with the move — stdout carries data only — and `bench`'s hand-picked
256-colour palette block is gone, replaced by aliases onto the generated roles.
The status tables stay on fd 1 for now, so `bench status | less` carries them
whole; their alias gate keys on fd 1 while the verbs' gate keys on fd 2 — one
palette, two gates, to be unified when the tables move to ui.sh.

The step also deleted `paint_live`, `watch_measure`, `row_glyph` and the
`WATCH_RENDER_PY` clamp from `bench` — the last four copies of machinery
`ui.sh` and `palette.go` already own.

⚠️ **`ui.sh` deliberately does not inherit this line**, which `bench` and
`haus` both carried:

```sh
sz="$(stty size 2>/dev/null </dev/tty)" && COLS="${sz#* }" || COLS="$(tput cols 2>/dev/null)"
```

`set -e` exempts every command in a `&&`/`||` list **except the last**, and
`tput` exits 2 with `TERM` unset — the shape of any session with no pty
(`ssh mac haus rebuild`, a launchd job, CI). Measured: the caller exits 2 with
nothing on either stream, after a successful evaluation and before anything
activated, and the sanitising `case` that exists precisely to cope with a bad
answer never runs. `|| true` inside that final substitution is the fix. **A
width probe that can kill its caller is the worst possible failure mode for a
courtesy** — which is the whole argument for one runtime rather than four
copies.

**What 9 shipped.** `haus.sh` and `haus-show.sh` draw through snug the way
`bench` does, and there is now **no hardcoded escape left in either** — the
suite fails on any `\033[` outside a comment, because with every colour an alias
onto the generated roles there is no legal place for one. Both scripts already
*sourced* `ui.sh` (step 6 wired `HAUS_UI_SH` through the wrapper); 9 is the part
that was deliberately left open, and the comment in `haus.sh` that named this PR
as its precondition is gone with it.

The `haus rebuild` phase painter is the piece with teeth. It was a live region
of exactly one line, hand-drawn: `phase_start` left a 14-cell stub, `\r\033[2K`
repainted over it, and `phase_row` chose between five width tiers it measured
itself. All of that is deleted — `PHASE_COLS`, `PHASE_UNBOUNDED`, `PHASE_STUB`,
`phase_measure`, `phase_row`, and the `stty size … || tput cols` probe this file
already warns about. What replaces it is `row`/`paint`/`end` records and a
background frame loop, so a rebuild's `resolve` and `activate` phases now carry a
**turning spinner and a live clock**, which bash could not do at all before: the
phase is a foreground command (`sudo haus-activate` has to keep the terminal for
its password prompt), so the frames come from a loop beside it rather than from
polling around a backgrounded phase. The loop's leash is `kill -0 $$` — it holds
a copy of the coprocess's write end, so without that check a finished `haus`
would leave snug spinning as an orphan.

Three contract points 7 did not have to answer, and 9 did:

- **A coprocess's own descriptors are NOT available in a subshell.** Bash closes
  them in every child it forks, so a background painter writing to `${SNUG[1]}`
  silently does nothing — measured, one frame in a 0.6 s phase, the row frozen
  at `0.0s`, and every other assertion in the suite green throughout. The fix is
  one line, `exec {FD}>&"${SNUG[1]}"`, because a plain duplicate is inherited
  like any other fd; bash's copy is then closed, or nothing ever reaches EOF.
  7 never met this because bench's watch loop paints from the main shell.
  **Anything that draws from a background job needs the duplicate, and a test
  that counts frames** — a spinner that never turns looks exactly like a phase
  that is simply taking a while.
- **Nothing may repaint while `sudo` might be asking for a password.** The
  prompt goes to `/dev/tty` — the same terminal the region repaints, and one the
  region's line count knows nothing about — so ten frames a second rewind over
  the prompt and over what is being typed into it. `haus` runs `activate` as a
  still row unless `sudo -n true` proves the timestamp is already valid: a
  one-way probe that under-detects on purpose, because the safe direction is the
  row it drew before there was a spinner at all.
- **Two streams, and which one is a property of the COMMAND, not the verb.**
  This is where 9 diverges from 7, and the divergence was earned the hard way.
  `haus` sets `REPORT=1` in its dispatch for `status doctor plan diff
  permissions btm generations get capture`; those draw entirely on fd 1, and
  everything else draws entirely on fd 2. `die` is the one exception and is
  always fd 2, because an error is not part of a report.

  A per-verb split — bench's, and the first cut of 9 — cannot be right here:
  half the verbs are called from helpers both kinds of command use, so
  `settings_diff` inside `haus plan` and inside `haus set` want opposite
  answers. The measured consequence was that `haus doctor`'s section headers
  went to fd 2 while its findings stayed on fd 1, making `haus doctor | pbcopy`
  an unlabelled list of ticks — and `docs/bug-reports.md` makes that paste the
  entire feedback channel for a product with no telemetry.

  The cost is that a report gets no folding, because it cannot use the
  coprocess: `snug run` draws on ITS stderr, which is the terminal, not the
  calling command's stdout. That is the same price bench's tables pay.
  (`haus show` is a report; its `die`, its usage and its one "fetching …"
  progress line are on fd 2, as errors and progress are everywhere.)
- **One colour precedence, asked rather than re-derived.** `ui.sh` measures fd 2
  at load; the reports are on fd 1, so both scripts call its own
  `ui__detect_profile`/`ui__resolve_palette` a second time with `UI_TTY` set from
  fd 1, and read `C_*` off *that* answer. Spelling the rule a second time is what
  made one binary answer `NO_COLOR` + `CLICOLOR_FORCE` two ways during this
  work — haus's old block had NO_COLOR winning, ui.sh has the force winning.
  Neither is wrong in the abstract; two answers in one binary is.

⚠️ **9 found a bug in 4, and it is the contract's own item 5.** `snug run`
never restored the cursor when it was interrupted: Go's default SIGINT
disposition terminates without running a `defer`, so `region.Close()` never
fired. Measured against the shipped binary — `hid=True, restored=False`. The
caller cannot fix it, because the coprocess is dead before bash's INT trap runs,
and a ⌃C through `bench release`'s watch has been leaving terminals with no
cursor for as long as 7 has been shipped. Fixed in
[snug#9](https://github.com/hausfold/snug/pull/9): the BINARY installs the
handler and exits 128+signum; the library deliberately does not, because a Go
program importing snug owns its own signal policy.

**How 8 stays in step with 4.** It is not kept in step — it is *generated from
the same list*. `snug`'s `script/gen-palette.sh` writes `palette.go` and
`ui.sh`'s `UI__HEX`/`UI__X256` blocks in one run, from one nebelung checkout and
one `TOKENS` list, and snug's bats suite re-derives every 256-colour index and
diffs the hex against `palette.go` on every push. A fallback that drew a
*different* colour from the binary would be worse than no fallback, since it
makes "which machine is this?" a question you have to ask about your own output.

While the two halves were in two repos this was a *diff*, and it needed a snug
checkout beside the workshop — CI cloned one, and on any laptop without one the
test skipped: green, checking nothing. Both halves are in snug now, so the drift
test always runs and the clone step is gone.

Two bugs were found by writing it against snug rather than from memory, and both
were in snug: its `bare` tier carried the full 3-cell gutter whenever colour was
on (`TrimRight(mark, " ")` does nothing once the mark ends in a reset escape),
and `Say` at a window narrower than four columns emitted the gutter plus a
clamped character. Both overflowed the last column; neither was visible to a
colourless test sweep. Fixed in
[snug#3](https://github.com/hausfold/snug/pull/3). A third was found by moving
it: the bats test that re-derives the 256-colour table computed *unweighted*
Euclidean distance while `theme.go`'s `dist` weights the channels 3/6/1. It
agreed on all thirty-two entries by luck, so it passed green while checking a
different algorithm from the one the binary runs.

**Why 8 lives in snug, not here.** It was written here and moved within the
week, because the caller that most needs it could never have reached it from
here: `haus.sh` is `builtins.readFile`'d into a store binary, and a haus user
has no workshop checkout. A fallback the fallback's biggest consumer cannot
source is not a fallback. The alternatives were both worse — vendoring a copy
into haus reintroduces exactly the drift 8 exists to delete, and haus already
takes `inputs.snug`, so its derivation reads `${snug}/share/ui.sh` straight off
the store path with no copy and no drift check at all. It ships *inside* snug's
derivation, beside `bin/snug`, so the binary and the stand-in for the binary
arrive together or not at all.

Nothing sourced `ui.sh` when it moved, which is the only reason the move was
free. Do this kind of correction before 7 adopts it, not after.

## Where the standard stops

Four surfaces are **deliberately** outside it. Each is a decision, not a
backlog — re-open one by editing this section, not by quietly converting a file.

- **trill's `trill` CLI — plain, for now.** It draws no colour at all today, and
  that stays. Two reasons, and the second is the one that decides it: it is
  Swift, so it cannot import snug's package and would have to drive `snug run`
  over the record protocol as a coprocess (possible — that is what the protocol
  is for — but a feature, not a sweep); and trill's tab on hausfold.co is still
  positioning-undecided, which is why **hausfold.co's own `AGENTS.md`** says
  "don't grow the tree past that page" — a rule about the SITE tree, not about
  `trill/docs/`, which is trill's manual and grows freely. Presentation on a
  surface whose shape is unsettled is work you do twice. Revisit when the tab
  ships.
- **pounce's command scripts — permanently out.** A command's stdout is the
  *launcher's* input, parsed by the app; there is no terminal on the other end of
  it and an escape there is a bug, not a style. The `# pounce:` header comments
  are its whole presentation contract. This is why they are clean today and why
  nothing should ever make them otherwise.
- **The installers — exempt because they run before the machine has snug.**
  `haus`'s `bootstrap.sh` (the standalone `curl | bash`) and `haus-activate.sh`
  (runs under `sudo` before anything is on PATH). An installer that needs the
  thing it installs is not an installer, and that is the whole test — it is
  about WHEN a script runs, not about whether someone got round to it.
- **The maintenance and probe scripts — out because nobody ships them.**
  `haus`'s `script/build-golden-vm.sh`, trill's `scripts/dev-install.sh`, and
  this repo's `script/issue-labels.sh` and `script/probes/*.sh`. These do *not*
  meet the installer test — `build-golden-vm.sh` wants `tart` on PATH and runs
  on a fully provisioned Mac, so it could source a painter perfectly well — and
  the honest reason is different: their whole audience is the four people with a
  workshop checkout, and a colour they get wrong costs a maintainer one squint.
  Say that rather than stretching the installer argument over them, which is how
  an exemption list turns into a place to hide things. They may be converted
  whenever someone wants to; nothing here is waiting on them.
