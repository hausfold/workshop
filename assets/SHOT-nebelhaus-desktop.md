# The nebelhaus desktop still — shot sheet

One frame, for `hausfold.co/desktops/` and `/desktops/nebelhaus/`. It replaces
the placeholder in `hausfold/assets/hero.png`, which is dense, dated and shows a
GitHub profile as its second-largest object.

**The message:** *this is not a dotfiles collection; it is an entire Mac that
belongs together.* Everything below serves that one sentence. If an element in
the frame doesn't, it comes out.

---

## The production fact that decides everything

`hausfold.co` sets `--measure: 41rem`. The shot frame renders at roughly
**600 CSS px wide** on a desktop browser, and **~350 px** on a phone.

At 600 px the whole desktop is 600 px. The bar's pill labels are ~4 px tall.
Nobody reads a word of the terminal.

So the still is judged as a **composition, not as content**. What survives at
600 px, in order:

1. the bright pounce card in the middle of the frame
2. the two bar bands, top and bottom, framing everything
3. the 60 / 40 vertical split
4. the sage ember under the notch
5. a thin coloured seam of wallpaper between the tiles

Everything else is texture. That's not a compromise — it's the brief. The old
hero fails because it tried to be readable and became a wall.

---

## The scene

```
┌────────────────────────────────────────────────────────────────────┐
│ ▟▙ 1  ⌘ ghostty            ▁▁▁▁▁▁▁            ⏻ 21°  Thu  9:41 AM │  sill, menu bar
│                             ▝▘  ← perch: two sage pips             │  (notch centred)
├──────────────────────────────────┬─────────────────────────────────┤
│  agent session, mid-turn         │  haus status                    │
│                                  │    this machine: …              │
│  › add obsidian to the roster    │    current generation           │
│  ⏺ Read  hosts/mbp/default.nix   │    pinned nebelhaus rice        │
│  ✳ Thinking…                     │    ✓ up to date with upstream   │
│                                  ├─────────────────────────────────┤
│         ╔═══════════════════════════════════════════╗              │
│         ║  🔍  86 f in c                            ║              │  pounce,
│         ║  ┌─────────────────────────────────────┐  ║              │  across
│         ║  │  30 °C                              │  ║              │  the seam
│         ║  │  86 °F → Celsius              ⏎ copy│  ║              │
│         ║  └─────────────────────────────────────┘  ║              │
│         ╚═══════════════════════════════════════════╝              │
│                                  │   haus.roster = [               │
│  worktree-… · PR #— · claude     │  +   "obsidian"                 │
│                                  │  -  accent = "mauve";           │
│                                  │  +  accent = "pink";            │
├──────────────────────────────────┴─────────────────────────────────┤
│  ▶ …            🌙 Focus            🐾 1                           │  sill, second bar
└────────────────────────────────────────────────────────────────────┘
        ↑ Ghostty · zellij, 60%          ↑ Zen, 40%
```

**What each object is doing for the pitch:**

| in frame | proves |
|---|---|
| two bars, top and bottom | **sill** — and that a second bar is a supported thing, not a hack |
| the 60/40 split with even gaps | **prowl** — a terminal and a *native app* under one tiler |
| the pounce card straddling the seam | **pounce** — system-wide, not a terminal toy |
| the sage pips under the notch | **perch** — the shelf is holding something |
| `haus status` | **haus** + reproducibility, in four lines |
| the host-file diff | the whole thesis: *the machine is a file you edit* |
| the agent pane + the worktree HUD row | the agent workflow, and the one thing no other rice has |
| Zen's chrome, fog-grey with a pink accent | **nebelung** reaches past the terminal |
| the wallpaper band and seam | nebelung's atmosphere |

That is nine of the eleven rooms the `/desktops/nebelhaus/` page lists. The
missing two — collar (Touch ID) and secrets — are **invisible by nature**;
they belong in the prose beside the picture, and the page already carries them.

---

## Setup

### 1. Make the Mac bigger, not the crop smaller

```sh
haus set displays.internal.uiScale larger-text
haus rebuild
```

On the 14″ this resolves to **1147 × 745 points → a 2294 × 1490 capture**.
This is the lever that matters: it enlarges *Zen* too, which `haus.ui.scale`
cannot touch (no system-wide UI scale exists on macOS).

Look at it first. If the terminal is still small in the frame, add
`haus set ui.scale 1.2` — but know that the two **multiply**, so 1.35 on an
already-scaled display is a bigger jump than it looks. It also widens prowl's
gaps (10/20 pt × scale), which is the only lever you have on how much
wallpaper shows.

> **Perch does not follow either lever.** The shelf sizes itself from the
> screen, so a scaled display leaves it the same physical size while everything
> around it grows. The ember will look *relatively* smaller than it does today.
> That's correct behaviour, not a staging mistake.

### 2. Strip the bars back to something a stranger recognises

Your live host runs six personal pills. For the shot:

```sh
haus set sill.items.aiUsage false     # a dollar figure in a marketing shot
haus set sill.items.elgato false      # your key light
haus set sill.items.harvest false     # your timesheet
haus set sill.items.weather true      # back on — a default-install pill
haus set sill.items.wifi true         # same
haus set sill.battery.hideOver 80     # already yours: keep it, so no battery pill
haus rebuild
```

Keep on the **menu bar**: workspaces · front app · weather · wifi · clock.
Keep on the **second bar**: media (or nothing) · hush · agents.
`battery.hideOver = 80` means a plugged-in Mac draws no battery pill at all —
that is how you delete "battery anxiety" without deleting the option.

Restore afterwards with `haus reset sill.items.aiUsage` (and friends).

> **Check the second bar is actually on top.** SketchyBar draws *under* windows
> by default, which is invisible for a menu-bar-edge bar and very visible for a
> bottom one. prowl reserves the outer-bottom gap for it, so it should be clear
> — but confirm with your eyes before you shoot, not after.

### 3. Accent and wallpaper

**Keep `theme.accent = "pink"`.** `hausfold.co` sets
`--a-nebelhaus: var(--nebelung-pink)` — the page the shot lands on is already
pink, and so are the ears in the logo. (`assets/SHOTLIST.md` used to say
"default mauve"; that line is now wrong and has been corrected in the same
change as this file.)

**Switch the wallpaper to `flow` for the shot:**

```sh
haus set theme.wallpaper flow
haus rebuild
```

`orbits` — what you run — puts all of its content in the bottom-right corner,
which is precisely where the second bar and the right-hand tile bury it. `flow`
runs its lines edge to edge, so the outer gap band and the vertical seam each
catch two or three coloured segments. Honest expectation: with the second bar
on, the wallpaper is a **frame, not a field**. Widening it further means
raising `ui.scale`, and past ~1.3 the tiles start to look cramped.

### 4. Clock

Shoot at **9:41**, AM or PM, on a day in the current month. Both `clock.mode`
values print a date, so the shot dates itself no matter what — a same-month date
is invisible, a two-month-old one is what made the current hero look abandoned.

Nothing else needs faking. Don't touch the system clock.

---

## Dressing each pane

### Left tile — Ghostty, zellij, exactly three panes

Three. Not four. The current hero has five and reads as noise.

**Pane 1 · left, full height (~55 % of the tile) — the agent, mid-turn.**

A real Claude Code session in a real `worktree-*` checkout. What should be on
screen, top to bottom:

- one short user line: `› add obsidian to the roster`
- one tool-call line: `⏺ Read  hosts/mbp/default.nix`
- the working line: `✳ Thinking…` with its spinner

and at the bottom, the rice's own **statusline row with the agent-worktree
HUD** — the branch and the PR pill. That row is the single most
differentiating pixel in the frame; make sure it's in shot and not scrolled
off. (Claude Code's own footer is collapsed by the rice's binary patch, so
there's no dead row beneath it.)

Mid-turn is what you asked for and it's the livelier choice — but a spinner is
a *moving* glyph and the wrong frame reads as "caught mid-load". Take five
captures a second apart and pick the one where the spinner glyph is at its
fullest (`✳`/`✶`, not `·`). This is the one thing in the shot worth
re-rolling.

**Pane 2 · right, upper (~45 % × 50 %) — `haus status`.**

Run it, leave the output. It is naturally 8 lines and every one of them is on
message: the machine, the generation, the pinned rice, and a green
`✓ up to date with upstream`. Do not scroll it. Do not run anything after it.

**Pane 3 · right, lower — a host-file diff.**

`cd ~/.config/nix && git diff` with a small **real, uncommitted** hunk staged by
hand in `hosts/<host>/default.nix`:

```diff
   haus.roster = [
     "ghostty"
     "zen"
+    "obsidian"
   ];
-  haus.theme.accent = "mauve";
+  haus.theme.accent = "pink";
```

Six lines. Red and green blocks that read as *colour* at 600 px, and as the
entire thesis at full size — the machine is a file, and adding an app is one
line. Make the edit, shoot, `git checkout` it after.

> Don't substitute lazygit here. Lazygit's five panels are what made the old
> hero unreadable, and the commit column is a wall of your own prose.

### Right tile — Zen

One window, one tab, on **`nebelhaus.com/start/first-run/`**.

The point is the *chrome*, not the page: Zen wearing fog-grey with a pink
accent is what proves nebelung reaches past the terminal. Before shooting:
empty bookmarks bar (or hidden), no second tab, no profile avatar, no
extension icons, no notification dot.

> Caveat, small: §5 of the rename will 301 `nebelhaus.com` to `hausfold.co`
> path-for-path. When that lands the URL in the bar is a wrong-brand signal and
> the shot wants a retake. At 600 px it is four illegible pixels, so this is not
> a reason to delay.

### Perch

Drag **two** files onto the shelf before capturing so the ember lights two
pips. One pip is ambiguous; three starts to look busy. Any two files — the
shelf draws pips, not names.

### Pounce, across the seam

Press the palette key, type:

```
86 f in c
```

→ **`30 °C`**, detail line `86 °F → Celsius`.

Use this, not the `72 f in c` in the original notes: 72 °F is 22.2222 °C, and
six significant digits of decimal is visual noise at any size. 86 → 30 is exact,
two glyphs, and legible at 350 px on a phone.

Position the panel so it **straddles the Ghostty/Zen boundary**. That overlap is
the entire argument that pounce is a system thing. Pounce centres itself, so
this falls out of a 60/40 split — check it, don't assume it.

---

## Do not let any of these into the frame

Checked against what the current hero actually ships:

- `julienmartel@Mac`, or any prompt/fetch showing the username — **no
  fastfetch/nerdfetch pane at all**
- a battery percentage, an uptime, a "36 %"
- the aiUsage pill, any `$0.20`, any token count
- `Monogram`, the Elgato pill, the Harvest pill
- `github.com/nebelhaus` — the org is **`hausfold`** now, and that string in a
  marketing shot is a bug
- the word `wt` anywhere — **holt** is the live workflow
- any notification banner; put Focus on before you shoot (it's on the bottom bar
  anyway, so the pill doubles as proof)
- private repo names, client filenames, a branch called `fix-the-thing-for-X`
- a mouse cursor (`screencapture` omits it unless you pass `-C`)
- a date older than this month

---

## Capture

The pounce panel closes when it loses focus, so the capture has to fire *while
you're standing still*. Use the timer:

```sh
screencapture -x -t png -T 10 ~/Desktop/nebelhaus-master.png
```

…then ⌘Space, type `86 f in c`, and don't move. `-x` mutes the shutter, and no
cursor is drawn.

Take five. Pick the spinner frame.

The capture is **2294 × 1490** (the full panel including the pixels behind the
notch — they are in the file even though the hardware hides them, which is why
the perch ember lands in the shot).

## Export

> **The panel is 1.54 : 1, not 16 : 10.** Cropping to 16:10 costs 56 px of
> height, and both bars live at the extremes — you would shave off the two
> things the shot exists to show. So the still keeps the panel's own ratio and
> the CSS follows it. The "16:10" in the brief was a guess at the hardware; this
> is the hardware.

```sh
cd ~/Desktop

# the site asset — ~2.6x for a 600px slot, which is plenty
magick nebelhaus-master.png -resize 1600x1039 -quality 82 nebelhaus-desktop.webp

# sanity: under ~250 KB, and it must survive a 350px look
identify -format '%wx%h %b\n' nebelhaus-desktop.webp
```

Then **look at it at 350 px wide** before accepting it. If the pounce card
isn't the first thing you see, the frame is still too dense — the fix is
always to remove something, never to zoom.

### The @2x question

You don't need one. 1600 px into a 600 px slot is already 2.6×.

### The og:image question — 3 / 5, your call

`hausfold.co/AGENTS.md` says: *"No `og:image`, and that's a decision, not an
omission… Adding one needs a reason of its own."* The stated objection is to *a
1200×630 sheet with the wordmark centred on it* — which a real desktop capture
isn't. So the door is open, but walking through it means editing that bullet in
the same PR.

If you do it: **crop, don't shrink.** A whole desktop at 1200 × 630 is mud. Cut
a 1.91:1 band across the middle third — menu bar + the pounce card + the seam —
so the card is ~40 % of the width. That crop reads at thumbnail size; the full
desktop does not.

```sh
# adjust the +Y offset by eye; this is the band, not a formula
magick nebelhaus-master.png -crop 2294x1201+0+180 +repage \
  -resize 1200x630^ -gravity center -extent 1200x630 \
  -quality 84 nebelhaus-og.webp
```

I'd do it, on `/desktops/nebelhaus/` only — it's the most-shared page of the
three and a real capture is a stronger card than a title. Reversing costs one
commit deleting three meta tags.

---

## Wiring it into the site

The edits are prepared as an applicable patch. Nothing is committed to
`hausfold.co` until the file exists — a broken `<img>` is worse than the honest
grey box the page draws today.

```sh
cd "$(holt child ~/code/workshop/hausfold.co)"
mkdir -p public/media
cp ~/Desktop/nebelhaus-desktop.webp public/media/
git apply ../../workshop/assets/desktops-hero.patch
```

The patch:

- adds `.shot--filled` to `public/hausfold.css` — drops the dashed border and
  the forced aspect ratio so the picture sets its own height
- swaps the `<span>[ shot not taken yet ]</span>` for an `<img>` in **both**
  wide frames (`/desktops/` and `/desktops/nebelhaus/`)
- leaves the two narrow frames on `/desktops/nebelhaus/` as placeholders

**If your capture isn't 2294 × 1490, fix the `width`/`height` attributes.**
They're what stops the page reflowing as the image loads; wrong numbers are
worse than none.

Still to do by hand in that repo, because they are judgement calls:

1. the **`og:image`** block, if you took that call above
2. the **"Placeholder frames, never a stale screenshot"** bullet in
   `AGENTS.md` — it still points at `nebelhaus/assets/hero.png` (the directory
   is `hausfold/` since 2026-08-09) and still calls it a placeholder
3. `hausfold.co` has had **no binary asset at all** until now. Its build story
   is "there is no build" and that stays true — a static file in `public/` is
   still no build — but it's worth one line in `AGENTS.md` saying so, before
   someone reads the absence as a rule.

---

## The two narrow frames

`/desktops/nebelhaus/` also wants *pounce, mid-launch* and *the terminal — zsh,
helix, lazygit*. Both come out of the same staging session, shot separately at
window scope rather than cropped out of the master — a crop of a 600 px-wide
composition is 300 px of mush.

They are a second sitting. Don't let them hold up the one that matters.
