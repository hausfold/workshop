# The hacker desktop still — shot sheet

One frame, replacing the placeholder in `haus/assets/hero.png`, which is dense,
dated and shows a GitHub profile as its second-largest object.

> ⚠️ **Read this for the scene and the crop, not for where the frame goes.**
> It was written for `hausfold.co/desktops/` and `/desktops/hacker/`, and
> **both are deleted** — the desktop pages moved into
> `content/docs/haus/desktops/` on 2026-08-14, and the docs carry no frames on
> purpose. The site patch in `desktops-hero.patch` targets a file that no
> longer exists, in a format the Next port replaced; don't try to apply it.
> The one surface still open to this shot is the haus README, and `SHOTLIST.md`
> is where its slot is tracked.

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
4. the ember under the notch — two accent-pink pips
5. a thin coloured seam of wallpaper between the tiles

Everything else is texture. That's not a compromise — it's the brief. The old
hero fails because it tried to be readable and became a wall.

---

## The scene

```
┌────────────────────────────────────────────────────────────────┐
│ ▟▙ 1  ⌘ ghostty            ▁▁▁▁▁▁▁            ⏻ 21°  Thu  9:41 AM │  bar, menu bar
│                             ▝▘  ← perch: two pink pips             │  (notch centred)
├──────────────────────────────────┬───────────────────────────────┤
│  agent session, mid-turn         │  haus status                    │
│                                  │    this machine: …              │
│  › add obsidian to the roster    │    current generation           │
│  ⏺ Read  hosts/mbp/default.nix   │    pinned hacker desktop        │
│  ✳ Thinking…                     │    ✓ up to date with upstream   │
│                                  ├───────────────────────────────┤
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
├──────────────────────────────────┴───────────────────────────────┤
│  ▶ …            🌙 Focus            🐾 1                           │  bar, second bar
└─────────────────────────────────────────────────────────────────┘
        ↑ Ghostty · zellij, 60%          ↑ Zen, 40%
```

**What each object is doing for the pitch:**

| in frame | proves |
|---|---|
| two bars, top and bottom | **bar** — and that a second bar is a supported thing, not a hack |
| the 60/40 split with even gaps | **windows** — a terminal and a *native app* under one tiler |
| the pounce card straddling the seam | **pounce** — system-wide, not a terminal toy |
| the two pips under the notch | **perch** — the shelf is holding something |
| `haus status` | **haus** + reproducibility, in four lines |
| the host-file diff | the whole thesis: *the machine is a file you edit* |
| the agent pane + the worktree HUD row | the agent workflow, and the one thing no other rice has |
| Zen's chrome, fog-grey with a pink accent | **nebelung** reaches past the terminal |
| the wallpaper band and seam | nebelung's atmosphere |

That is nine of the eleven rooms the `/desktops/hacker/` page lists. The
missing two — security (Touch ID) and secrets — are **invisible by nature**;
they belong in the prose beside the picture, and the page already carries them.

---

## Setup

### 1. One command, one rebuild

```sh
haus set \
  displays          '{"internal":{"uiScale":"larger-text"}}' \
  theme.wallpaper   flow \
  bar.items        '{"agents":true}' \
  bar.bottom.items '{"media":true,"focus":true,"agents":true}'
```

Undo the whole thing afterwards with:

```sh
haus reset displays theme.wallpaper bar.items bar.bottom.items
```

> **`haus set` cannot address a sub-path of a submodule.** `haus set
> bar.items.aiUsage false` and `haus set displays.internal.uiScale larger-text`
> both die with *"is not a settable option on this machine's pinned rice"* —
> the module system doesn't expose `options.haus.bar.items.aiUsage`, so
> `settings_option_exists` rejects them. Hence the whole-attrset JSON above.
> It's also why this is one call: `haus set` rebuilds once at the end, so four
> calls would be four rebuilds.

What each pair is doing:

**`displays`** — on the 14″, `larger-text` resolves to **1147 × 745 points → a
2294 × 1490 capture**. This is the lever that matters: it enlarges *Zen* too,
which `haus.ui.scale` cannot touch (macOS has no system-wide UI scale).

Look at it before adding anything else. If the terminal is still small in the
frame, add `ui.scale '1.2'` as a fifth pair — but know that the two
**multiply**, so 1.2 on an already-scaled display is a bigger jump than it
looks. It also widens the tiler's gaps (10/20 pt × scale), which is the only lever
you have on how much wallpaper shows.

> **Perch follows neither lever.** The shelf sizes itself from the screen, so a
> scaled display leaves it the same physical size while everything around it
> grows. The ember will look *relatively* smaller than it does today. Correct
> behaviour, not a staging mistake.

**`theme.wallpaper flow`** — `orbits`, what you run, puts all of its content in
the bottom-right corner, which is precisely where the second bar and the
right-hand tile bury it. `flow` runs its lines edge to edge, so the **left and
right** outer bands each catch two or three coloured segments. Honest
expectation on both counts: flow's lines only occupy the lower half, so the top
band catches nothing; and with the second bar on, the wallpaper is a **frame,
not a field**. Widening it means raising `ui.scale`, and past ~1.3 the tiles
start to look cramped.

**`bar.items '{"agents":true}'`** — an `mkForce` of the whole set, so every key
you don't name falls back to its own default. That is exactly the bar a
stranger gets on a fresh install: clock, weather, media, battery, wifi, plus
the agents paw. It drops your aiUsage gauge, the Elgato pill and caffeinate in
one stroke — no per-pill commands, nothing to remember to restore.

**`bar.bottom.items`** — **this one is load-bearing, not tidiness.** A pill
named in `bottom.items` is drawn on the bottom bar *whatever `bar.items` says
about it* (`bar/default.nix` filters `bottomItems` from `cfg.bottom.items`
alone). Your host names `aiUsage`, `elgato` and `caffeinate` down there, so
without this pair the dollar figure you just removed from the menu bar is still
sitting on the bottom one.

The result: **menu bar** — workspaces · front app · weather · wifi · clock.
**Second bar** — media · focus · agents. `bar.battery.hideOver = 80` stays as
your host sets it, so a plugged-in Mac draws no battery pill at all. That is
how you delete "battery anxiety" without deleting the option.

> **Check the second bar is actually on top.** SketchyBar draws *under* windows
> by default, which is invisible for a menu-bar-edge bar and very visible for a
> bottom one. windows reserves the outer-bottom gap for it, so it should be clear
> — but confirm with your eyes before you shoot, not after.

### 2. Accent — leave it alone

**Keep `theme.accent = "pink"`.** `hausfold.co` sets
`--a-haus: var(--nebelung-pink)` — the page the shot lands on is already
pink, and so are the ears in the logo. (`assets/SHOTLIST.md` used to say
"default mauve"; that line was wrong and is corrected in the same change as
this file.)

Knock-on worth knowing: **perch's ember wears the accent**
(`ShelfEmber.swift` paints its pips with `rice.accent`, fed from
`haus.theme.accent`). The pips are pink here, not perch's own mark green — the
"sage ember" in the original brief describes perch at *its* default, standing
alone, not perch inside this rice.

### 3. Clock

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

> That green tick only prints when the pin equals `origin` **and** the machine
> is online. A behind pin prints an amber *"a newer rice is available upstream
> — haus update"* instead, which is a fine line in real life and the wrong note
> in a hero. `haus update` first, then run `haus status` in the pane.

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

> This survives §1's staging because `haus set` writes its overrides to
> **separate files** under `hosts/<host>/settings/` and `git add`s them. They're
> staged; your demo hunk isn't. So plain `git diff` shows the six lines and
> nothing else — no need to juggle commits.

> Don't substitute lazygit here. Lazygit's five panels are what made the old
> hero unreadable, and the commit column is a wall of your own prose.

### Right tile — Zen

One window, one tab, on **`hausfold.co/start/first-run/`**.

The point is the *chrome*, not the page: Zen wearing fog-grey with a pink
accent is what proves nebelung reaches past the terminal. Before shooting:
empty bookmarks bar (or hidden), no second tab, no profile avatar, no
extension icons, no notification dot.

> Caveat, small: §5 of the rename will 301 `hausfold.co` to `hausfold.co`
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
- `github.com/hausfold` — the org is **`hausfold`** now, and that string in a
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
screencapture -x -t png -T 10 ~/Desktop/hacker-master.png
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
magick hacker-master.png -resize 1600x1039 -quality 82 hacker-desktop.webp

# sanity: under ~250 KB, and it must survive a 350px look
identify -format '%wx%h %b\n' hacker-desktop.webp
```

Then **look at it at 350 px wide** before accepting it. If the pounce card
isn't the first thing you see, the frame is still too dense — the fix is
always to remove something, never to zoom.

### The @2x question

You don't need one. 1600 px into a 600 px slot is already 2.6×.

### og:image — decided 2026-08-09: **hausfold.co stays imageless**

Asked and answered. Having a real desktop capture does **not** reopen it: the
site's link cards keep degrading to the title and one line, which is the tone
the pages are for.

So the existing rule in `hausfold.co/AGENTS.md` stands unedited —

> *"No `og:image`, and that's a decision, not an omission… Adding one needs a
> reason of its own."*

— and so does the one that would have made it expensive anyway: *"Every page
carries the same head… A change to one is a change to all of them."* Carding
one page and not the other seven breaks that as written; carding all eight to
avoid it is a lot of surface for a picture nobody asked for.

**Don't cut an og crop.** There is one export from this shoot
(`hacker-desktop.webp`) and it is the in-page hero. If this comes up again,
the answer is no unless the *tone* argument has changed, not the asset one.

---

## Wiring it into the site

The edits are prepared as an applicable patch. Nothing is committed to
`hausfold.co` until the file exists — a broken `<img>` is worse than the honest
grey box the page draws today.

```sh
cd "$(holt child ~/code/workshop/hausfold.co)"
mkdir -p public/media
cp ~/Desktop/hacker-desktop.webp public/media/
git apply ~/code/workshop/assets/desktops-hero.patch
```

The patch path has to be absolute: a `holt child` lands under
`~/.cache/claude-worktrees/hausfold.co/<name>`, nowhere near the workshop.

> **The patch will rot, silently.** It carries blob hashes for
> `desktops/index.html`, `desktops/hacker/index.html` and `hausfold.css`,
> and nothing in this repo checks it. It applied cleanly when written
> (`git apply --check`, all three files). If any of those three has moved
> since, `git apply` refuses — read it and make the three edits by hand; it's
> 70 lines and the shape is obvious.

The patch:

- adds `.shot--filled` to `public/hausfold.css` — keeps a 1 px border but makes
  it solid, drops the padding, and releases the forced aspect ratio so the
  picture sets its own height
- swaps the `<span>[ shot not taken yet ]</span>` for an `<img>` in **both**
  wide frames (`/desktops/` and `/desktops/hacker/`)
- leaves the two narrow frames on `/desktops/hacker/` as placeholders

**If your capture isn't 2294 × 1490, fix the `width`/`height` attributes.**
They're what stops the page reflowing as the image loads; wrong numbers are
worse than none.

Still to do by hand in that repo, because they are judgement calls:

1. the **"Placeholder frames, never a stale screenshot"** bullet in
   `AGENTS.md` — it still points at `haus/assets/hero.png` (the directory
   is `haus/` since 2026-08-11) and still calls it a placeholder. Amend it
   to say the wide frames hold a real capture and the two narrow ones don't
   yet; the rule itself is unchanged and still correct.
2. `hausfold.co` has had **no binary asset at all** until now. Its build story
   is "there is no build" and that stays true — a static file in `public/` is
   still no build — but it's worth one line in `AGENTS.md` saying so, before
   someone reads the absence as a rule.

No og:image edit. That decision was re-confirmed on 2026-08-09 and the bullet
in `AGENTS.md` stands as written.

---

## The two narrow frames

`/desktops/hacker/` also wants *pounce, mid-launch* and *the terminal — zsh,
helix, lazygit*. Both come out of the same staging session, shot separately at
window scope rather than cropped out of the master — a crop of a 600 px-wide
composition is 300 px of mush.

They are a second sitting. Don't let them hold up the one that matters.
