# How the family's CLIs put a line on screen

The one presentation standard for every tool the workshop ships **that draws on
a terminal** — `bench`, `haus`, `scruff` and `factory`. It lives here, beside
`agent-surface.md` and `drift.md`, because it binds every repo and belongs to
none of them.

It is the design half. The runtime that implements it is
[hausfold/snug](https://github.com/hausfold/snug): this file is what that repo
is judged against, and what its bash fallback has to match line for line.

Where the standard *stops* is the last section, and is as load-bearing as what
it covers — a scope that is merely unstated reads as a sweep nobody finished.

> A cat's whiskers are how it knows whether it fits through the gap. Every defect
> below is a tool that never measured.

## Why this exists — the three defects, measured

Measured 2026-08-27 against `bench` (3148 ln), `haus.sh` + `haus-show.sh` (5034
ln) and `scruff/internal/ui/ui.go`. No family CLI holds a hand-picked index any
more, and the fixed widths that survive are the no-snug fallback plus the two
named exceptions the caller table records. The defects stay written down because
each names the mistake the rules below prevent, and because other repos cite
them by number. **Line numbers are deliberately absent from this file: it
outlives them.**

**1. Fixed-width rows in a resizable window** — the founding defect. 72
hardcoded `%-NNs` widths across the three CLIs. `printf` pads, so a row occupies
its full declared width whatever the content, and the wrap threshold is a
property of the *format string* and nothing else. `bench release`'s job row was
48 cells always while its repaint moved the cursor up by rows *printed* rather
than screen lines *occupied*, so below 49 columns every frame scrolled instead
of repainting. `haus rebuild` had the same defect with a second head: `phase_ok`
repaints with `\r`, which returns to column 0 of the current **physical** row,
so a wrapped stub left `· activate` stranded above `✓ activate` for the rest of
the run. Both heads are measured in a real pty by
`haus/test/phase-painter.bats`. Clamping the *content* instead — which is what
`bench` did, in a comment that named the bug — only guesses at a width, and
guesses the same one for every terminal alive.

**2. The palette is not the palette.** Seven 256-colour indices, copy-pasted
into four files, none from nebelung. Distance to the nearest token, CIE ΔE:

| index | hex | role | nearest nebelung | hex | ΔE |
| --- | --- | --- | --- | --- | --- |
| 103 | `#8787af` | primary accent ("the fog itself") | `blue` | `#8db4f3` | 21.8 |
| 108 | `#87af87` | ok / healthy | `green` | `#abe1a6` | 19.7 |
| 110 | `#87afd7` | repo names | `sapphire` | `#7dc6e7` | 12.4 |
| 167 | `#d75f5f` | error | `red` | `#ed8fa9` | 27.4 |
| 179 | `#d7af5f` | warn / stale | `peach` | `#f5b58e` | 22.3 |
| 243 | `#767676` | muted (haus) | `overlay0` | `#717171` | 2.0 |
| 245 | `#8a8a8a` | muted (bench) | `overlay1` | `#858585` | 1.9 |

ΔE above ~10 is "plainly a different colour". Only the greys land close, and
they were *two different greys for one role* — the drift this table exists to
stop. Every family CLI's primary hue resolved to **blue**, and nebelung is
*"Mocha with the blue stripped out"*. **An index is not a token; hand-picking
one is the defect, not sourcing.**

**3. Width is counted in the wrong unit.** `printf '%-9s'` pads by bytes under
most locales, and bytes always OVER-count: a `%-9s` field holding a 3-byte mark
comes out seven cells wide. Every column after a glyph shears by a different
amount depending on which glyph it was, and three CJK runes fill the same field
to six cells with no padding at all. The other half is the ungated escape:
`haus.sh` + `haus-show.sh` measured 35 raw `\033[38;5;N` emitted
unconditionally, into pipes, files and CI logs alike.

## The standard

### Colour roles

Nine roles. A tool names a role, never a colour. Roles resolve against the
nebelung variant in play, so `nebelung-latte` gets the light answer for free.

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
the user's own background. `accent` is `mauve`, the nearest nebelung hue to the
`#8787af` everything used to reach for.

A role belongs to a **column**, said once. The exception is the column whose
meaning changes row by row — `bench status`'s dirty count is amber only when it
is not zero — so a single cell may carry its own role (`snug.Cell(snug.Warn,
…)`, `ui_cell`). It is a role and never an escape: a caller that builds the row
with the colour already in it has put something in the cell that the padding
then counts, which is the shearing a budget exists to stop.

**Degradation** is by terminal capability, decided once at startup:

| capability | how colour resolves |
| --- | --- |
| truecolor (`COLORTERM=truecolor\|24bit`) | nebelung hex, exact |
| 256 | nearest cube/grey index to the nebelung hex |
| 8/16 | nearest ANSI base, roles collapse: `subject`→`accent`, `path`→`muted` |
| none | no escapes; the glyph carries the meaning |

### Glyphs

**The glyph is load-bearing and the colour is not** — a role must be readable
with colour off. One glyph per role, ASCII fallback when the locale isn't UTF-8:

| role | glyph | ascii | width |
| --- | --- | --- | --- |
| `say` | `≋` | `~` | 1 |
| `ok` | `✓` | `+` | 1 |
| `warn` | `⚠` | `!` | 1 |
| `err` | `✗` | `x` | 1 |
| `info` | `ⓘ` | `i` | 1 |
| `skip` | `–` | `-` | 1 |
| `bullet` | `·` | `.` | 1 |
| `hint` | `↳` | `>` | 1 |
| `spin` | `⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏` | `\|/-\` | 1 |

Every glyph is **one cell**, and the gutter is therefore **3 cells wide,
always** — glyph plus padding to 3 — so lines with different glyphs align and
continuation lines have a fixed indent to hang from.

**No mark defaults to emoji presentation** — none has `Emoji_Presentation =
Yes`, which is the property a disputed width comes from. That is narrower than
"no emoji", and the difference matters: `⚠` (U+26A0) is `Emoji = Yes` and is in
the table anyway. It is the constraint on adding a mark, and snug's `glyph.go`
carries it as the implementation.

**Widths are declared and verified against real terminals, never taken from a
width library.** The hazard is not emoji-ness but `East_Asian_Width`, in two
shapes: `ⓘ` (U+24D8), `–` (U+2013), `·` (U+00B7) and the truncation `…`
(U+2026), which is not a mark but ends every folded line, are **Ambiguous** —
one cell in a Western locale, two under an East-Asian one, and `x/ansi` and
`runewidth` each expose a mode for each answer, so neither has a single one to
give. And `⚠` (U+26A0) is one cell bare but two as the emoji-presentation
sequence `U+26A0 U+FE0F` — the tables hold **bare codepoints**, so a caller
appending a variation selector has silently doubled it.

Hold a mark against a ruler and read the DIGITS. Another mark is no reference: a
locale that doubles one Ambiguous glyph doubles them all and leaves any two of
them aligned. For a number rather than an eyeball, ask the terminal where its
cursor ended up:

```sh
stty -echo; printf '\r\u24D8\033[6n'; IFS=';' read -rd R _ col; stty echo
echo "$col"   # 2 → one cell, 3 → two
```

Measurement libraries are used only on **content**, which is ordinary text and
where they agree.

### Layout

Everything is measured in display cells, resolved with grapheme-cluster width,
never bytes and never runes.

- **Prose is capped at `min(terminal width, 100)` cells.** **Tables and live
  regions are exempt** — they are bounded by their own content, and a job list
  that stopped at 100 in a 200-column window would be hiding the room it had.
- **Every line fits, or is folded — never soft-wrapped.** A tool that lets the
  terminal wrap has given up its own indentation. Fold at a word boundary and
  hang continuations at the gutter.
- **Columns are budgeted, not declared.** A table gets the available width and
  each column a *weight* and a *minimum*. Columns take their natural width if
  the sum fits; otherwise every column drops to its minimum and the remainder is
  shared **by weight** — repeatedly, because a column that reaches its natural
  width releases its share back. Weight is what decides, not width; "the widest
  gives up first" is the usual outcome, not the rule.
- **Truncation is by priority, with `…` inside the field.** Each column says
  what it gives up first — a repo name from the right, a path from the left
  (`…/scruff/internal/ui`), a duration never.
- **A column that never truncates is MEASURED, never assumed.** Seven cells for
  a duration because `12m 34s` is "the longest one" puts `100m 05s` into the
  next column and back into the bug the budget prevents.
- **The tier is chosen from the WINDOW, then the column is clamped to the
  content — never the other way round.** Clamping first asks *"is the longest
  name short?"* when it means *"is there room?"*, and drops a duration column on
  a 200-column terminal because the jobs were called `build` / `test` / `lint`.
- **Below the sum of minimums, the table drops a tier** rather than emitting a
  row it knows will wrap:

  | tier | keeps | example at that width | | --- | --- | --- | | `table` |
  padded name column, aligned detail | ` ✓ bump-tap 12s` | | `list` | name only
  — the detail goes, and so does the padding | ` ✓ bump-tap` | | `bare` | the
  3-cell indent collapses to one space | `✓ bump…` |

- **The floor is 2 cells** — one glyph and nothing else.

### Measuring the window

**`tput cols` is wrong and will pass review anyway.** terminfo carries a
*static* size — 80 for every `xterm-*` entry — and ncurses only overrides it
from the real window when `LINES`/`COLUMNS` are exported. In a 40-column pty it
answers **80**.

Use `stty size` (TIOCGWINSZ), the only source that tracks a resize. Read it from
`/dev/tty`, not `<&1`: inside `$( )` — which is where a shell measures — fd 1 is
the substitution's pipe and never the terminal.

**A stream with no window is not given one.** Assuming 80 for a pipe is the same
mistake with the number hardcoded a layer up, and costs prose folded at a column
nobody chose and a table cut to 79 cells with an ellipsis where the path tail
was — in the stream someone is about to grep. A redirected stream is neither
folded nor fitted; it is written whole.

Measure once at start, then only when `SIGWINCH` says the window changed. `stty`
forks; a 10 fps painter must not.

### Live regions

A live region is a block of lines rewritten in place: `bench release`'s job
list, `haus rebuild`'s phase lines, `bench rebuild`'s store counter. The
contract:

1. **Only on a TTY.** Piped, in CI or under `bats`, it degrades to one plain
   line per *state change*. No cursor escape ever reaches a file.
2. **Motion is not gated on `NO_COLOR`.** A spinner on a colourless terminal is
   still the thing you want to see.
3. **Repaint counts screen lines, not logical rows.** Folding to fit makes those
   equal by construction, which is the whole point of folding.
4. **`SIGWINCH` re-measures and repaints from scratch**, clearing to end of
   screen (`\033[J`) rather than trusting the old height.
5. **The cursor is restored on every exit path**, `SIGINT` and a `set -e` abort
   included.
6. **Frame rate and poll rate stay unrelated** — a background fetch, a 10 fps
   painter, durations clocked locally. Never fetch-paint-sleep.
7. **Scrollback is append-only.** A finished region leaves its final frame there
   and moves on.

**A resize mid-region is not an edge case.** Nothing that repaints ten times a
second may skip the trap. A painter slow enough to re-measure per row — haus
draws four rows a second — needs none: the row after the resize picks it up.

### Streams

From scruff's `internal/ui` (SPEC.md §2.3), promoted to a family rule: **stdout
carries data only.** Every diagnostic, prompt and progress line goes to stderr,
because callers do `cd "$(scruff child …)"` and hooks read paths off stdout.

**A report is data.** `bench status`'s tables and the `scruff` listing are the
thing the user ran the command *for*, so they draw on fd 1 — which is what lets
`bench status | less` carry them whole — while the narration stays on fd 2.

**A report is measured, gated and painted for the stream it lands on, never the
other one.** Budget a report from stderr and a TTY stdout beside a redirected
stderr draws plain; a piped stdout beside a live stderr draws escapes into a
pipe. Go callers get one question and one answer from `Printer.PrintData`, which
measures `Out`; `Print` is the other half, for a table that is part of what the
tool is *saying*. The bash half is the same two verbs — `ui_table_data` for fd
1, `ui_table` for fd 2 — the first made possible by a second measurement and a
second palette (`UI_OUT_TTY`, `UI_OUT_PROFILE`, `UI_OUT_AVAIL`,
`UI_OUT_<role>`). One window, measured once; each stream then answered about its
own far end.

## The runtime

Bash can't link a Go library, so the standard ships as two implementations of
one spec, both in [hausfold/snug](https://github.com/hausfold/snug) —
standalone, repo-agnostic, its own flake input, shipped on `PATH` by the layer.

- Go callers (`scruff`) import `github.com/hausfold/snug`. No process, no
  protocol.
- Shell callers (`bench`, `haus`) drive the binary, which the layer puts on
  `PATH` beside `trill` and `haus-notify`. **Not pounce's command scripts** —
  they have no terminal on the far end and must never grow one.
- A shell caller that draws no live region needs only the fallback, and
  `factory` is the one that says so: the binary's single advantage is a region
  repainted from a coprocess, and every factory verb prints its report and
  stops. **Driving the binary is not the marker of compliance — resolving the
  palette from snug is.**

**One process per command invocation, not per line.** A fork costs 4.4 ms; a
per-line fork would put 320 ms of pure overhead into a 60-line `haus rebuild`.
So the shell opens one coprocess at the top of a command, writes
newline-delimited records to its stdin for the whole run, and closes it at the
end. That also buys what bash cannot do at all: log lines scrolling *above* a
region still spinning.

**Two dependencies: `x/ansi` plus `x/term`** — 9 modules against lipgloss v2's
22, 2.1 MB against 3.0. The parts of lipgloss we would use are the parts
`x/ansi` already *is*: the family's look is quiet — aligned text and a fog
palette, no borders and no boxes — so a styling engine buys nothing and costs 13
modules. Not bubbletea, which wants to own the event loop and the screen when
`bench` and `haus` need a filter *they* drive; a live region is ~80 lines plus a
`SIGWINCH` handler. Not fang/cobra — six verbs does not justify the graph. Not
`tput cols`: `x/term` asks the kernel (`TIOCGWINSZ`), the only thing that tracks
a resize, and that is the bug the whole library exists for.

### Why the fallback lives in snug

`ui.sh` is not kept in step with `palette.go` — the two are *generated from the
same list*. snug's `script/gen-palette.sh` writes `palette.go` and ui.sh's
`UI__HEX` / `UI__X256` blocks in one run, from one nebelung checkout and one
`TOKENS` list, and snug's suite re-derives every index and diffs the hex on
every push. A fallback that drew a *different* colour would be worse than no
fallback: it makes "which machine is this?" a question you ask about your own
output. Both halves live in one repo so that test always runs — split across two
it is a diff that skips, green and checking nothing, on any machine without the
second checkout.

A palette can be generated from one list for both halves. **A layout cannot, so
it is diffed**: snug's `TestBashTableMatchesGo` renders the same columns and
rows through both painters at every width from too narrow to draw at all up to
wider than any content, and reds on the first line they disagree about. It runs
with colour ON as well as off — a role with the colour off leaves no trace, so
layout is all a plain diff can compare.

ui.sh ships **inside snug's derivation, beside `bin/snug`**, so the binary and
the stand-in for the binary arrive together or not at all. The caller that most
needs it could not reach it anywhere else: `haus.sh` is `builtins.readFile`'d
into a store binary, and a haus user has no workshop checkout. **Never vendor a
copy into a consumer**: that reintroduces exactly the drift the fallback exists
to delete, and haus already takes `inputs.snug`, so its derivation reads
`${snug}/share/ui.sh` off the store path with nothing to drift. The fallback is
held to the whole spec, not a subset — `bench` finds it in the snug **checkout**
while the binary comes from **PATH**, so a workshop clone whose layer was never
activated has the fallback and no binary, and that is the ordinary case.

## Who draws through it

Every surface a *user* drives resolves its colour from snug's generated palette;
no hand-picked 256-colour index survives in one. The installers and the
maintenance scripts still hold theirs, deliberately — see **Where the standard
stops**.

**Reaching ui.sh is three different questions and each caller answers its own.**
`bench` finds it in the snug **checkout** (`repo_dir snug`), because the
workshop has one by construction. haus and factory read a **store path** off
their own snug input, injected as `HAUS_UI_SH` and `FACTORY_UI_SH` — their users
have no checkout. scruff has neither question: it imports the Go package. A haus
binary with no wrapper above it to inherit the variable from answers the same
question its own way rather than adding a fourth: `focus` and `haus-secret` take
the store path as a build-time substitution, `github-signal` and `awake` take it
prepended by their derivations, and the three scripts that are neither resolve
it off `command -v snug`. The choice is local — a script that is ALREADY a
`@placeholder@` template takes another hole; one that is read whole takes the
line of shell.

What all of them share is the DEGRADATION: the variable naming nothing, or the
checkout being absent, must leave the tool printing plain marked text rather
than dying. factory is the sharpest case — it installs with a `git clone` and a
symlink on a machine with no Nix at all — and a change that makes any verb
*need* snug has broken that install.

| caller | how it reaches the runtime |
| --- | --- |
| `scruff`'s `internal/ui` | imports `github.com/hausfold/snug`. No process, no protocol |
| `bench` | sources `$(repo_dir snug)/share/ui.sh`, plus one `snug run` coprocess for a command with a live region. Tables are `ui_col` + `ui_trow` + `ui_table_data`; a clone with no snug checkout — which its own CI is — falls back to a renderer in `bench` that lays the same columns out at natural widths |
| haus's `haus.sh` and `haus-show.sh` | ui.sh at `HAUS_UI_SH`, injected by `modules/core`; the `haus rebuild` phase painter is a coprocess. Two named format-string exceptions survive: `haus-show`'s `field` (a one-row label, not a table) and `haus set`'s picker, whose padding is the parse contract that recovers the chosen path out of `gum filter`'s answer |
| haus's `focus` and `github-signal` | ui.sh in their own shell: `focus` by build-time substitution, `github-signal` prepended by its derivation. `focus` sources it LAZILY, inside the two verbs that draw a table, because the bar drives it on a timer. Both check `BASH_VERSINFO` first |
| haus's `haus-secret` | ui.sh substituted at build time — a launchd agent, `haus doctor` and a person at a prompt all exec it directly. Sourced LAZILY and only from the paths that draw; the hot path `exec`s secretspec without touching the painter. The one caller that draws **no table**: `--list` is blocks, because a column holding `why` or `obtain` cuts the only part worth reading. It declines the fold for an `obtain` with no whitespace — `ui_fold` hard-breaks a word wider than the line, fatal for a URL somebody is about to copy |
| haus's `awake` | ui.sh prepended by its derivation. Also a DATA SOURCE: `status --raw` answers the bar's coffee pill with `mode<TAB>remaining<TAB>until`, so `raw_status` and the launchd controller never reach `ui_load`. What draws is one sentence per prose verb — and it is the one binary whose confirmations stay on **fd 1**, having no narration to separate a report from |
| haus's `statusline.sh` and `image-preview.sh` | ui.sh roles only — neither draws a live region |
| haus's `lane-open.sh` | resolves `HAUS_UI_SH` and injects it into the snippet the lane's own shell runs; nothing in the script sources ui.sh itself |
| `factory` | ui.sh at `FACTORY_UI_SH`, set by its own flake's `makeWrapper`. **No coprocess and no binary on PATH.** Its `lib/ui.sh` is the adapter, separate from `lib/common.sh` because `factory --help` has to draw without `jq` |

haus's suite enforces this with **two bans of different strengths, and the
difference is the point.** Over `haus.sh` and `haus-show.sh` it fails on *any*
literal escape outside a comment: those two draw nothing but text and roles, so
there is no legal place for one. Over the three painters it bans the SGR colour
forms only (`\033[38;`, `\033[48;`, the ANSI-basic sets), because those three
legitimately emit escapes that are not colour — OSC 8 hyperlinks, OSC 2 window
titles, and the DECTCEM cursor `image-preview.sh` needs. A blanket ban there
would be suppressed per line until it meant nothing.

**One exception is named in the ban rather than pattern-matched away**: the
statusline's `TINT_FABLE` row tint is a *background* and the nine roles are all
foreground, so it stays a raw escape gated on the profile being truecolor — also
correct on its own terms, since `#382713` has no cube equivalent and ungated it
paints a warm band behind text `NO_COLOR` has already returned to default.

Three collisions come out of eleven statusline slots landing on nine roles. Two
lose nothing: `PURGE` and `WARN` both become `warn`, but every `PURGE` use
carries its own glyph (`⏏`, `◇`, `N^`) and `WARN`'s two carry none, so the
distinction survives in the channel that holds it; `ADD`/`PR_OPEN` and
`DEL`/`PR_CLOSED` were already `ok` and `err` by index. The third is a real
change, written down so nobody rediscovers it from the screen: `DOT` and `DIM`
both become `muted`, so the clean `●` renders in the same grey as the cost
beside it, and keeps its meaning positionally.

## Rules a caller has to meet

**The record protocol.** Tab-separated, one per line, verb first —
`say<TAB>text`, `row<TAB>state<TAB>name<TAB>detail`, `paint`, `end`. A space
after the verb does not parse: `snug run` splits on tabs and answers `unknown
record`. A row never carries an empty field between two non-empty ones, because
`read` collapses consecutive delimiters — a running job's detail carries its
stale duration, and only the trailing `since` may be empty. Multi-line text is
one record per line; the emitter folds the newlines.

**One coprocess per command, opened by the live region and closed with it.** The
fork happens when a command opens a region — a command that draws none forks
nothing — and the dispatch belongs to the *caller*, because a library sourced
per script cannot see the command boundary that decision needs. It opens only
under a terminal on fd 2 and only when ui.sh loaded, so a machine with the
binary but no snug checkout gets the ui.sh path even interactively. A snug that
dies once stays dead for the command (`SNUG_TRIED` is not reset on close): a
failed record write must never re-fork per frame. The close is guarded on
`UI_READY`.

**Outside a live region the coprocess is the wrong writer — and a message verb
must never open one.** A record crosses a pipe and is drawn by another process
on ITS stderr; a table the command `printf`s itself goes straight to the
terminal. The two are on different schedules, so mixing them prints rows above
the section title that introduces them and wedges a row into the middle of a
folded sentence. Inside a region there is no race, because a caller writes
nothing directly while one is up. A run of regions may share one coprocess —
`haus rebuild` keeps one across every phase — but the close cannot wait for the
command: `bench release --ship` ends inside `bench ship`, whose tables would
interleave with its own titles, and a failed `haus rebuild` phase dumps 25 lines
of build log straight to the terminal.

**Anything drawing from a background job needs its own duplicate of the write
end.** Bash closes a coprocess's descriptors in every child it forks, so a
background painter writing to `${SNUG[1]}` silently does nothing — the row
freezes at `0.0s` while every assertion stays green. `exec {FD}>&"${SNUG[1]}"`
is the fix; bash's own copy is then closed, or nothing reaches EOF. **Its
converse: anything backgrounded that draws NOTHING must drop that fd**, because
`snug_close` waits for EOF and an inherited copy keeps it from arriving — and
where that job's exit condition is "the parent is gone", the two wait for each
other with no clock on it. **Write a test that counts frames**: a spinner that
never turns looks exactly like a phase that is taking a while. The loop's leash
is `kill -0 $$`, without which a finished caller leaves snug spinning as an
orphan.

**Nothing may repaint while `sudo` might be asking for a password.** The prompt
goes to `/dev/tty` — the terminal the region repaints, and one its line count
knows nothing about — so ten frames a second rewind over what is being typed.
`haus` draws `activate` as a still row unless `sudo -n true` proves the
timestamp is valid: a one-way probe that under-detects on purpose, because the
safe direction is the still row.

**Which stream a command draws on is a property of the COMMAND, not the verb.**
`haus` sets `REPORT=1` in its dispatch for `status doctor plan diff permissions
btm generations get capture`; those draw entirely on fd 1, everything else
entirely on fd 2. `die` and progress are the exceptions inside a report and are
always fd 2. A per-verb split cannot be right: half the verbs are called from
helpers both kinds of command use, so `settings_diff` inside `haus plan` and
inside `haus set` want opposite answers — and a split header/body makes `haus
doctor | pbcopy` an unlabelled list of ticks, which `docs/bug-reports.md` makes
the entire feedback channel for a product with no telemetry. The cost is that a
report's *prose* gets no folding, because `snug run` draws on ITS stderr, which
is the terminal rather than the calling command's stdout. Its **tables** need no
coprocess — they are budgeted against `UI_OUT_AVAIL` in the caller's own shell —
so that half of the cost is payable rather than structural.

**One colour precedence, asked rather than re-derived.** ui.sh measures BOTH
streams at load and resolves a palette for each. Narration reads `UI_*`; a
report reads `UI_OUT_*`. Never swap `UI_TTY` and ask again, and never spell the
rule a second time by hand — that is how one binary comes to answer `NO_COLOR` +
`CLICOLOR_FORCE` two ways. Neither answer is wrong in the abstract; two answers
in one binary is. ⚠️ `haus.sh` still does the swap — the route that exists where
a caller predates the second palette. It is a conversion still owed, not a
defect to file, and it is the one place the rule above is knowingly unmet.

**Force the gate where colour is correct without a tty.** haus's statusline
renders with both descriptors captured — Claude Code reads the line and puts it
in a terminal — so a measured `[ -t 2 ]` answers "no colour" for output that
lands in colour anyway. It sets `UI_TTY=1` and forces *only* that, leaving
`NO_COLOR` and `TERM=dumb` still able to win.

**Never call your path-to-ui.sh variable `UI_SH`.** That is ui.sh's own
source-twice sentinel (`[ -n "${UI_SH:-}" ] && return 0`), so a caller holding
the path in it makes the file return before defining anything: no error, no
colour, and a suite that stays green because every role is legitimately empty
when the painter is absent. haus's is `HAUS_UI_SH`.

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
`tput` exits 2 with `TERM` unset — the shape of any session with no pty (`ssh
mac haus rebuild`, a launchd job, CI). The caller exits 2 with nothing on either
stream, after a successful evaluation and before anything activated, and the
sanitising `case` that exists to cope with a bad answer never runs. `|| true`
inside that final substitution is the fix. A width probe that can kill its
caller is the worst possible failure mode for a courtesy — which is the argument
for one runtime rather than four copies. ui.sh deliberately does not inherit the
line.

**The binary owns a signal policy; the library does not.** `snug run` installs a
SIGINT handler and exits 128+signum, because Go's default disposition terminates
without running a `defer`, so the region's `Close()` never fires and a ⌃C leaves
the terminal with no cursor. The caller cannot fix that — the coprocess is dead
before bash's INT trap runs. A Go program importing the package owns its own
policy, so the library installs nothing.

## Where the standard stops

Eight surfaces are **deliberately** outside it: six out entirely, one out of the
*runtime* but not the *palette*, one out of everything. Each is a decision, not
a backlog — re-open one by editing this section, not by quietly converting a
file.

**The reasons do not collapse into one.** Three are out because nothing on the
far end is a terminal, and it is tempting to write that as the section's rule.
It is not: the installers and the maintenance scripts are read by PEOPLE at real
terminals and are exempt for reasons of their own — one about *when* they run,
one about *who* reads them. A single "nobody reads these as a report" test would
be false about a third of the list and would let the next borderline file in
under a claim nobody checked.

- **trill's `trill` CLI — plain, and staying plain.** Swift, so it cannot import
  snug's package; the only way in is driving `snug run` over the record protocol
  as a coprocess. That is what the protocol is for, but it is a *feature*
  somebody would have to want, not a sweep somebody forgot. Do not file it as
  debt.

  **haus's ten one-file Swift helpers are out on the same import**, and mostly
  on a second reason too. `hausax`, `hausdisp`, `hausocr`, `hausrect`,
  `haustabs`, `floatpin`, `floatring`, `barpop`, `barvitals` and
  `haus-github-receiver` are compiled with `xcrun swiftc` against AppKit. Six
  would have nothing to say if they could — three draw on the SCREEN, three emit
  machine input. `hausdisp list` is a real listing a real person reads, once, to
  find a monitor's UUID before writing the `haus.displays` option; it stays
  plain for trill's reason exactly. `hausax` straddles and lands the same place:
  bare it prints JSON, but `hausax input-sources --all` is a plain list a person
  reads.
- **pounce's command scripts — permanently out.** A command's stdout is the
  *launcher's* input, parsed by the app; an escape there is a bug, not a style.
  The `# pounce:` header comments are its whole presentation contract. Stated
  here as well as in the stdout bullet on purpose: a palette command is written
  by somebody reading *that* file's header, not this section.
- **The installers — exempt from the RUNTIME, not from the palette.** haus's
  `bootstrap.sh` (the standalone `curl | bash`, on a Mac with no nix) and
  `haus-activate.sh` (handed a reset environment by `sudo`, as root, to activate
  the very generation that would install `share/ui.sh`) cannot reach a painter:
  an installer that needs the thing it installs is not an installer. That is a
  fact about WHEN they run, and it is permanent.

  The exemption covers the runtime and stops there — "cannot source it" is not
  "colour is somebody else's problem", and the screen a new user sees first is
  the last place the founding defect may live. They may not *source* snug; they
  must still **carry its numbers**:

  - every constant is **copied out of snug's generated `share/ui.sh`**, for the
    `nebelung` variant, which is what `ui__detect_variant` answers on a machine
    with nothing in `~/.config/snug/variant` — exactly the machine an installer
    runs on. Copy the hex *and* the 256 index *and* the 16-colour name.
  - the gate is **ported, not re-derived** — `NO_COLOR` beats everything except
    `CLICOLOR_FORCE`, a non-TTY is colourless unless forced, `dumb` means it
    even when forced.
  - a copy drifts, so **a test diffs it back**: haus's
    `test/installer-palette.bats` reads the roles and the precedence out of the
    real `share/ui.sh` at the pinned rev and reds when either moves. An inlined
    palette with no drift test is the hand-maintained copy this exercise
    deleted; the test is the price of the exemption, not an extra.

  `bootstrap.sh` is also the one family CLI that gates **two streams
  separately**. The rule elsewhere keys on the *command*, but bootstrap's whole
  preflight is plain stdout prose, so its narration is gated with it on fd 1 and
  only `die` draws on fd 2. One gate asked about both streams is how
  `bootstrap.sh | tee log` comes out either escape-littered or monochrome.
- **A row nothing draws on a terminal — out, and not for any reason above.**
  haus's `modules/terminal/scripts/find.sh` pads for `fzf`, which owns the
  window and does its own cutting, and `haus set`'s picker pads for `gum filter`
  — where the padding is load-bearing twice over, because the chosen LINE comes
  back and the path is recovered by splitting on the first space. A bar plugin's
  `printf` has no terminal on the far end at all. A budget applied to any of
  them takes a window away from whatever actually owns it.
- **stdout that is another program's input — out, by construction.** The
  generalisation of pounce's rule, and the biggest group here. Every one writes
  fd 1 for a parser, so an escape is a corrupted field rather than a style
  question:

  | surface | what is on fd 1 | who reads it | | --- | --- | --- | | `awake
  status --raw` | `mode<TAB>remaining<TAB>until` | the bar's coffee pill, with
  `IFS=$'\t' read` and `cut -f1` | | `scruff-cache` | `scruff --json`, or a
  cache path, or an age in seconds | the bar's agents pill, the Lanes palette,
  `lane-cwd.sh` | | `agent-state` | the agent-state TSV | the bar's agents pill
  | | `hausrect` | `id x y width height` per window | `tiling-mode.sh`, sizing a
  grid | | `barvitals` | a few TSV lines, one sample | the cpu and memory pills
  AND their dropdowns, from one run | | `hausocr` | the recognized text, nothing
  else | `pbcopy`, via the `copy-text` palette command | | `hausax` | a JSON
  state document | the theme room's activation, which `jq`s `.appearance` out of
  it | | `haustabs` | 4-byte-length-prefixed JSON | Firefox's native-messaging
  protocol — an escape here is a framing error, not a smudge | |
  `agent-desktop-guard` | the PreToolUse hook's JSON verdict | Claude Code,
  which re-opens a permission prompt on it |

  `awake` is in this table AND in the caller table above, which is the point of
  keeping both: the rule is per-STREAM inside a binary, not per-binary.

  **`haus-fix` and `haus-fix-github` belong here because their fd 1 is a
  SUBPROCESS's.** `haus-fix` runs the agent under `tee` when it has a terminal,
  so fd 1 is the transcript, and the prompt reaches fd 1 only under `--dry-run`,
  where the point is a clean document. `haus-fix-github` writes no report on fd
  1 at all: its prompt is a command substitution piped into `scruff spawn
  --prompt-file -`. Neither is silent toward a person — both talk through
  `haus-notify`, because both are usually spawned from a trill pill with no
  terminal near them.

- **Surfaces with no terminal on either end — out, and nothing to convert.**
  Listed rather than left implicit, because "it must have been missed" is the
  only other reading:

  - **They draw on the screen.** `floatpin`, `floatring` and `barpop` are AppKit
    processes that place an outline, pin a window or watch for a click.
  - **They hand a line to something that draws it.** `haus-notify` puts a line
    on SCREEN through trill or Apple's banner; `modules/core/trill.sh` resolves
    the bundle and `exec`s. `haus-notify`'s only terminal writes are refusals on
    fd 2 — and a flag it does not know is warned about and DROPPED rather than
    refused, because a haus bug must not cost the user the message haus was
    sending.
  - **They write a log or a file, detached.** `lidawake` (and
    `haus-agent-awake`, the same script under a second name) is a root daemon
    writing to `/var/log`; `haus-github-receiver` sits behind a cloudflared
    tunnel; `statusline-refresh` is run DETACHED and writes a TSV that
    `statusline.sh` renders — the render is the surface, and it is in the caller
    table. `portless` is a third-party npm daemon and not ours to convert.

- **`portless-lane` — the one genuinely borderline file, and it stays out.**
  Bash, on `PATH`, run by hand, printing three lines for a person on fd 2. By
  every test above it is eligible, and saying otherwise would be the exemption
  list turning into a place to hide things. Two reasons it is out anyway, and
  they only work together: its three lines are a **preamble to somebody else's
  output**, since it hands the terminal to `portless run <cmd>` whose dev server
  owns both streams for the rest of the session; and the file **has a deletion
  date in its own header** — vercel-labs/portless#398 adds `--prefix`, this
  shim's whole job done one level down, after which the file goes and
  `lane-open.sh` exports `PORTLESS_PREFIX` instead. If that PR stalls and the
  shim outlives it, this bullet is the thing to re-open.

- **The maintenance and probe scripts — out, permanently, by decision.** haus's
  `script/build-golden-vm.sh`, trill's `scripts/dev-install.sh`, and this repo's
  `script/issue-labels.sh` and `script/probes/*.sh`. These do *not* meet the
  installer test — `build-golden-vm.sh` wants `tart` on PATH and runs on a fully
  provisioned Mac, so it could source a painter perfectly well — and the honest
  reason is different: their whole audience is the few people with a workshop
  checkout, and a colour they get wrong costs a maintainer one squint. Say that
  rather than stretching the installer argument over them, which is how an
  exemption list turns into a place to hide things. A **settled scope**, not a
  queue: "convert the last few scripts" is not a piece of work that exists.
  Converting one anyway is not forbidden — it is just nobody's task, and it does
  not belong in a sweep, a checklist or a PR body as though it were owed.
