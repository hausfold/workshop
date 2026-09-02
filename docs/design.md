# The visual system

**How hausfold and its products look off the terminal — the standard for
anyone, human or agent, making a thing that carries the brand: a logo, a
banner, an OG card, a README hero, a one-off page.** Binds every repo in the
family. The master SVG sources live in the *Logo system* design project;
exported PNGs land in each repo's own assets. Served publicly at
`https://hausfold.co/design.md` — the site's Worker proxies this file from
main, so it stays at `docs/design.md`; moving or renaming it breaks that
URL.

Three scopes this file deliberately does not own:

| That question is… | Owned by |
|---|---|
| how a **CLI** draws — colour roles, glyphs, columns | **snug**'s `README.md` and `AGENTS.md`, the terminal presentation standard (see the routing table's row) |
| how **hausfold.co** implements this — greyscale at rest, borrowed colour, the one sanctioned motion | that repo's `AGENTS.md` |
| the palette **tokens** themselves | **nebelung**. The values below are vendored from its `palette/nebelung.hex.json` (rendered for CSS as `dist/css/nebelung-mocha.css`) and nebelung stays the source of truth — `test/design-palette.bats` diffs every hex in this file back against it. A web page can load the served copy at `https://hausfold.co/hausfold.css` |

## Theme

- **Silver-mist.** Dark, low-contrast, everywhere — a silver-mist Catppuccin
  Mocha variant, named for the Nebelung cat: grey, in fog.
- **Dark only.** Never invert a product artifact to a light theme. The
  sanctioned light artifacts are the org's light square and nebelung's latte
  banner, drawn from the latte flavor of the same tokens.
- **Elevation is surface steps** — base → surface0 → surface1 — never shadows.
- **Accents are pastel and light**: text, icons and borders on dark surfaces,
  or fills with dark (crust) text on top.
- **Marks are quiet.** One idea, one extra shape; big shapes only. Detail —
  notches, cut-outs, swatch strips, outline strokes — is what gets a draft
  rejected.

## Colour

| Token | Hex | Brand use |
|---|---|---|
| `--nebelung-crust` | `#121212` | deepest ground: OG cards, the family showcase; ears/shapes on inverted banners |
| `--nebelung-mantle` | `#191919` | alias target of `--nebelung-bg-alt` |
| `--nebelung-base` | `#202020` | page background; tile fill when the tile sits on a surface0 banner |
| `--nebelung-surface0` | `#343434` | standard mark tile; standard banner ground; "gray" in inverted marks; ghost ears on OG cards @ 0.55 |
| `--nebelung-surface1` | `#494949` | the gray story shape in every mark (prompt bar, card, fog); `--nebelung-border` |
| `--nebelung-surface2` | `#5c5c5c` | secondary story shape (fog layer 2 @ 0.7, text lines); dashed placeholder border |
| `--nebelung-overlay0` | `#717171` | reserved |
| `--nebelung-overlay1` | `#858585` | section eyebrows; OG footer |
| `--nebelung-overlay2` | `#9a9a9a` | small labels ("ORG") |
| `--nebelung-subtext0` | `#aeaeae` | OG subtitle; product labels; `--nebelung-fg-muted` |
| `--nebelung-subtext1` | `#c3c3c3` | reserved |
| `--nebelung-text` | `#d7d7d7` | primary text; the `hausfold` wordmark |
| `--nebelung-rosewater` | `#f3e1dd` | reserved |
| `--nebelung-flamingo` | `#efcece` | reserved |
| `--nebelung-pink` | `#f2c4e5` | link hover; held by the `hacker` desktop and docs error callouts — not available as a product hue |
| `--nebelung-mauve` | `#c9a8f1` | **nebelung's product colour**; `--nebelung-accent`; link colour |
| `--nebelung-red` | `#ed8fa9` | `--nebelung-danger` only |
| `--nebelung-maroon` | `#e6a3ad` | hausfold.co's provisional pick for scruff (see product table) |
| `--nebelung-peach` | `#f5b58e` | **pounce's product colour** |
| `--nebelung-yellow` | `#f7e2b5` | **trill's product colour**; `--nebelung-warning` |
| `--nebelung-green` | `#abe1a6` | **perch's product colour**; `--nebelung-success` |
| `--nebelung-teal` | `#9be0d5` | `--nebelung-info` |
| `--nebelung-sky` | `#91dbe8` | retired, never reassigned — a trill asset holding sky is stale |
| `--nebelung-sapphire` | `#7dc6e7` | reserved |
| `--nebelung-blue` | `#8db4f3` | reserved — blue is the hue nebelung exists to strip out; never an accent |
| `--nebelung-lavender` | `#b5bff8` | link hover on working canvases |

Semantic aliases: `--nebelung-bg` → base · `--nebelung-bg-alt` → mantle ·
`--nebelung-bg-deep` → crust · `--nebelung-fg` → text · `--nebelung-fg-muted`
→ subtext0 · `--nebelung-border` → surface1 · `--nebelung-accent` → mauve ·
`--nebelung-success` → green · `--nebelung-warning` → yellow ·
`--nebelung-danger` → red · `--nebelung-info` → teal.

### Product colours

| Product | Token | Hex | Status |
|---|---|---|---|
| hausfold (org) | none | — | no single hue: the wordmark is `--nebelung-text` on crust, and the wedge-fan mark sweeps all six accents |
| haus | none yet | — | undecided |
| nebelung | `--nebelung-mauve` | `#c9a8f1` | decided (latte `#8545e3`) |
| pounce | `--nebelung-peach` | `#f5b58e` | decided |
| perch | `--nebelung-green` | `#abe1a6` | decided |
| trill | `--nebelung-yellow` | `#f7e2b5` | decided |
| scruff | `--nebelung-maroon` | `#e6a3ad` | provisional — hausfold.co's pick, not yet carried into the logo system. Deliberately maroon and **not pink** |
| snug | none yet | — | undecided |

Rules:

- Every colour is `var(--nebelung-*)` — a light artifact resolves the same
  tokens in the latte flavor. A hardcoded hex is a defect.
- Mauve is the accent. No hue competes with it as a CTA.
- **Each product owns one hue and no two share one.** A hue that falls out
  of use (sky) is retired, never reassigned.

## Typography

- Brand face: **Space Grotesk** (Google Fonts, weights 400;500;600;700) on
  every deliverable — banners, OG cards, the logo sheet.
- **Wordmarks are lowercase**, weight 600, +0.06em tracking — every one of
  them, `hausfold` through `snug`.
- UPPERCASE is reserved for eyebrows, taglines and footers, always
  wide-tracked (0.14–0.24em). Never for a wordmark.

Scale as built (px / weight / tracking):

| Use | Spec | Colour |
|---|---|---|
| OG title (product name) | 92 / 700 / +0.04em, lowercase | product colour |
| OG subtitle | 36 / 400, line-height 1.4 | `subtext0` |
| OG footer `HAUSFOLD / NAME` | 23 / 400 / +0.22em, UPPER | `overlay1` |
| Banner wordmark | 30 / 600 / +0.06em, lowercase | product colour (standard) · `surface0` or `crust` (inverted) |
| Banner tagline | 11 / 400 / +0.2em, UPPER | `crust` @ 0.72 |
| Showcase `hausfold` | 40 / 600 / +0.06em | `fg` |
| Section eyebrow | 12 / 600 / +0.18em, UPPER | `overlay1` |
| Labels under tiles | 12–14 / 400 | `subtext0` |

## The logo system

### The ears

One shared mark across the family: two curved ear paths in a 100×100 viewBox,
used verbatim in every product mark —

```svg
M 18 13 Q 34 18 47 24 Q 34 35 30.5 57 Q 20 34 18 13 Z   <!-- left -->
M 82 13 Q 66 18 53 24 Q 66 35 69.5 57 Q 80 34 82 13 Z   <!-- right -->
```

The ears are **never redrawn**. A product may change their position, scale
and colour — nothing else. Never outlined, never split into two colours,
never cut out of a filled shape, and never rotated, with one exception:
pounce's leap tilt (12°).

### The tile

- Square, 100×100 viewBox, corner radius **24** (24% of side).
- **Standard**: tile `surface0`, ears in the product colour, story shapes in
  `surface1`/`surface2`.
- **Inverted**: tile in the product colour; ears and shapes `surface0` (logo
  sheet) or `crust` (banners carrying a tagline). Small accents inside
  inverted shapes keep the product colour; parts that were gray dim to 0.45.
- A shape that bleeds off the tile is clipped by the tile's own rounded rect.

### The marks

Every mark is the untouched family ears in the product colour, plus gray
palette shapes that carry the story, at the same weight as its siblings.

**nebelung** — *Nebel, ears sinking into grey fog.* Ears mauve,
`translate(10 12) scale(0.8)`. Fog layer 1
`M -4 66 Q 18 56 38 64 Q 62 73 82 63 Q 94 58 106 64 L 106 104 L -4 104 Z`
in `surface1`; fog layer 2
`M -4 80 Q 22 71 46 78 Q 72 86 106 76 L 106 104 L -4 104 Z`
in `surface2` @ 0.7. Latte variant: tile latte base `#f1f1f1`, ears latte
mauve `#8545e3`, fog latte surface1 `#c0c0c0` / latte surface2 `#b0b0b0`
@ 0.7, banner ground latte crust `#e0e0e0` — fog surfaces step darker
instead of lighter.

**pounce** — *mid-pounce over the prompt bar.* Ears peach,
`translate(14 4) scale(0.72) rotate(12 50 35)`. Prompt bar
`rect 10,66 80×18 rx 9` in `surface1`; caret `rect 19,70.5 3.5×9 rx 1.75`
peach. Tagline: `SUMMON, AIM, POUNCE`.

**trill** — *the card wears the ears.* Ears yellow,
`translate(14 0) scale(0.72)`; notification card `rect 14,52 72×34 rx 10` in
`surface1`; dot `circle 26,63 r 4.5` yellow; text lines `rect 36,59 38×5` and
`rect 36,69 26×5` (rx 2.5) in `surface2`. Tagline: `NO NOISE, JUST A TRILL`.

**perch** — *two files, fanned out.* Ears green, `translate(4 19)
scale(0.72)`. Cards clipped to the tile: `rect 10,68 42×46 rx 6` in
`surface1` rotated −11°, `rect 46,64 42×48 rx 6` green rotated 7°.

**hausfold (org)** — *the wedge-fan disc*: a circle of thin wedges sweeping
all six accents, the one mark outside the ears system and the one that
holds colour at rest. Sources: this repo's `assets/hausfold-dark-square.svg`
and `assets/hausfold-light-square.svg`; hausfold.co's favicon carries the
same fan, generated from nebelung's port. The logo sheet holds a 150×150
dashed placeholder (`1px dashed` `surface2`, radius 24, on `base`) for an
ears-family org mark; until one is ratified, the wedge fan is the org's
mark.

**haus, scruff, snug** — no mark exists. Set the wordmark alone; never
invent a mark.

### Lockups

- **Banner** — 400×116, radius 24, padding `0 32`, gap 20; mark 62×62;
  wordmark 30/600/+0.06em lowercase. Standard: ground `surface0`, wordmark in
  the product colour. Inverted: ground in the product colour, wordmark
  `surface0` — or `crust` with the tagline under it.
- **Family showcase** — 760 wide, padding 48, ground `crust`, 1px
  `--nebelung-border`, radius 24. Org row (wordmark + `ORG` label) above a
  1px `surface0` rule, then the product tiles at 88×88, gap 36.
- **OG card** — 1280×640, padding 72, ground `crust`, radius 28, clipped.
  Product tile 220×220, 52 from the text column; title/subtitle stacked with
  gap 18; ghost ears 560×560 at top −150 / right −110 in `surface0` @ 0.55;
  footer `HAUSFOLD / NAME` bottom-left.

## Layout

Radii in use: **24** (tile, banner, showcase), **28** (page cards, OG),
**999** (pills), 6–13 (shapes inside marks). There is no general spacing
scale, grid or breakpoint system — until one exists, copy the geometry above
verbatim rather than approximating it.

## Motion

None in brand artifacts. (hausfold.co allows exactly one hover-only sheen on
its mark; the bar for a second one is owned in that repo's `AGENTS.md`.)

## Do's and don'ts

- **Do** keep the ears path identical across products; move, scale and
  recolour only.
- **Do** keep every mark to the ears plus one gray story idea, at the same
  visual weight as its siblings.
- **Do** stay dark, step surfaces for elevation, and spend accents as light
  strokes/fills on dark or with crust text on top.
- **Don't** hardcode hex; resolve every colour through `var(--nebelung-*)`.
- **Don't** add fine detail: notches, cut-outs, multi-swatch strips, outline
  strokes, two-tone ears.
- **Don't** rotate the ears (pounce's 12° tilt is the one exception), outline
  them, or carve them out of a filled shape.
- **Don't** share a hue between products, or let anything compete with mauve
  as the accent.
- **Don't** invent a mark for a product that has none — wordmark alone.

## Not yet defined

Current gaps, stated so nobody fills them by improvising:

- **Marks in the ears system** for the org, haus, scruff and snug — the org
  has the wedge fan meanwhile; the other three set the wordmark alone.
- **Light-theme artifacts** beyond the org's light square and nebelung's
  latte banner — the latte token sheet exists; artifacts drawn from it
  mostly don't.
- **Clearspace and minimum sizes** — smallest size rendered so far is 62px;
  nothing smaller is proven.
- **An icon set** beyond the logo marks.
- **Spacing scale, grid, motion** for anything bigger than the lockups above.

Where the design project holds a second candidate — trill's fused
single-silhouette icon master, perch's re-laid-out banner variant, the
`NOTIFICATIONS, FILTERED` tagline — the geometry written above is the
standard until this file changes.

## Agent quick reference

Ground `#121212` (crust) · card `#202020` (base) · tile `#343434` (surface0)
· gray shapes `#494949`/`#5c5c5c` · text `#d7d7d7` · muted `#aeaeae` ·
accents: mauve `#c9a8f1`, peach `#f5b58e`, yellow `#f7e2b5`, green `#abe1a6`
· face Space Grotesk · wordmarks lowercase 600/+0.06em · radii 24/28 · dark
only · no shadows · no motion.
