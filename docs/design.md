---
version: alpha
name: hausfold
description: >-
  How hausfold and its products look off the terminal. Silver-mist dark, one
  hue per product and none for the house, the shared ears mark, the house
  glyph for the org. Space Grotesk on an artifact, the Mac's own faces on a
  page.
colors:
  crust: "#121212"
  mantle: "#191919"
  base: "#202020"
  surface0: "#343434"
  surface1: "#494949"
  surface2: "#5c5c5c"
  overlay0: "#717171"
  overlay1: "#858585"
  overlay2: "#9a9a9a"
  subtext0: "#aeaeae"
  subtext1: "#c3c3c3"
  text: "#d7d7d7"
  mauve: "#c9a8f1"
  maroon: "#e6a3ad"
  green: "#abe1a6"
  yellow: "#f7e2b5"
  peach: "#f5b58e"
  pink: "#f2c4e5"
  red: "#ed8fa9"
  teal: "#9be0d5"
  lavender: "#b5bff8"
  primary: "{colors.mauve}"
  bg: "{colors.base}"
  bg-alt: "{colors.mantle}"
  bg-deep: "{colors.crust}"
  fg: "{colors.text}"
  fg-muted: "{colors.subtext0}"
  border: "{colors.surface1}"
  accent: "{colors.mauve}"
  success: "{colors.green}"
  warning: "{colors.yellow}"
  danger: "{colors.red}"
  info: "{colors.teal}"
  product-nebelung: "{colors.mauve}"
  product-pounce: "{colors.peach}"
  product-perch: "{colors.green}"
  product-trill: "{colors.yellow}"
  product-scruff: "{colors.maroon}"
  desktop-hacker: "{colors.pink}"
typography:
  artifact-wordmark:
    fontFamily: Space Grotesk
    fontSize: 30px
    fontWeight: 600
    letterSpacing: 0.06em
  artifact-tagline:
    fontFamily: Space Grotesk
    fontSize: 11px
    fontWeight: 400
    letterSpacing: 0.2em
  artifact-og-title:
    fontFamily: Space Grotesk
    fontSize: 92px
    fontWeight: 700
    letterSpacing: 0.04em
  artifact-og-subtitle:
    fontFamily: Space Grotesk
    fontSize: 36px
    fontWeight: 400
    lineHeight: 1.4
  artifact-og-footer:
    fontFamily: Space Grotesk
    fontSize: 23px
    fontWeight: 400
    letterSpacing: 0.22em
  artifact-eyebrow:
    fontFamily: Space Grotesk
    fontSize: 12px
    fontWeight: 600
    letterSpacing: 0.18em
  page-body:
    fontFamily: ui-serif, New York, Georgia, Iowan Old Style, serif
    fontSize: 1.02rem
    fontWeight: 400
    lineHeight: 1.62
  page-standfirst:
    fontFamily: ui-serif, New York, Georgia, Iowan Old Style, serif
    fontSize: 1.72rem
    fontWeight: 400
    lineHeight: 1.32
    letterSpacing: -0.014em
  page-wordmark:
    fontFamily: ui-monospace, SF Mono, Menlo, monospace
    fontSize: 1.95rem
    fontWeight: 400
    letterSpacing: 0.02em
  page-mark:
    fontFamily: ui-monospace, SF Mono, Menlo, monospace
    fontSize: 5rem
    fontWeight: 300
    lineHeight: 0.9
  page-eyebrow:
    fontFamily: ui-monospace, SF Mono, Menlo, monospace
    fontSize: 0.72rem
    fontWeight: 400
    letterSpacing: 0.16em
  page-code:
    fontFamily: ui-monospace, SF Mono, Menlo, monospace
    fontSize: 0.82rem
    fontWeight: 400
    lineHeight: 1.6
  docs-heading:
    fontFamily: ui-serif, New York, Georgia, Iowan Old Style, serif
    fontSize: 2.25rem
    fontWeight: 600
  docs-body:
    fontFamily: -apple-system, SF Pro Text, system-ui, sans-serif
    fontSize: 1.06rem
    fontWeight: 400
    lineHeight: 1.7
rounded:
  page-sm: 2px
  page: 3px
  docs-lg: 6px
  mark-shape: 9px
  tile: 24px
  card: 28px
  pill: 999px
spacing:
  artifact-gap: 20px
  artifact-pad: 32px
  artifact-pad-lg: 48px
  artifact-pad-xl: 72px
  page-list: 0.72rem
  page-block: 1.05rem
  page-masthead: 1.6rem
  page-gutter: 2rem
  page-section: 4.75rem
  page-measure: 41rem
  page-max: 78rem
components:
  tile:
    backgroundColor: "{colors.surface0}"
    rounded: "{rounded.tile}"
    size: 100px
  banner:
    backgroundColor: "{colors.surface0}"
    typography: "{typography.artifact-wordmark}"
    rounded: "{rounded.tile}"
    width: 400px
    height: 116px
    padding: 0 32px
  family-strip:
    backgroundColor: "{colors.crust}"
    rounded: "{rounded.tile}"
    width: 760px
    padding: 48px
  og-card:
    backgroundColor: "{colors.crust}"
    typography: "{typography.artifact-og-title}"
    rounded: "{rounded.card}"
    width: 1280px
    height: 640px
    padding: 72px
  page-command:
    typography: "{typography.page-code}"
    rounded: "{rounded.page}"
    padding: 0.85rem 1rem
---

# The visual system

**How hausfold and its products look off the terminal: the standard for
anyone, human or agent, making a thing that carries the brand.** A logo, a
banner, an OG card, a README hero, a one-off web page. It binds every repo in
the family. A mark's SVG is its source of record and the PNGs beside it render
from it: this repo's `assets/` for the house and nebelung, each product's own
`assets/` for the rest, all of it indexed in
[`assets/README.md`](../assets/README.md), the media kit that
`https://hausfold.co/brand` 301s onto. The *Logo system* design project is
where a mark is drawn and redrawn; it is not where the current one lives. This
file is served publicly at `https://hausfold.co/design.md`. The site's Worker
proxies this file from main, so it stays at `docs/design.md`; moving or
renaming it breaks that URL.

The front matter above is the token half, in the DESIGN.md format Google
Stitch published (`npx @google/design.md lint docs/design.md` reads it). The
prose below is the decisions. Where the two disagree, the prose is wrong and
gets fixed; where prose and the design project disagree, the prose is the
standard until this file changes; and where a mark's SVG and the geometry
printed below disagree, the SVG is the mark and the printed geometry is what
gets corrected. The rules here still say what a mark may *be* — a radius, a
token, a minimum width — and an SVG that breaks one of those is wrong however
current it is.

The geometry under *Components* is a second telling of what the mark SVGs
already hold, kept because this file is the public standard and a mark has to
be readable as text. It is not a licence to let the two drift: a change to a
mark changes the SVG and this file in the same commit.

`test/design-palette.bats` holds part of that seam, and only part. For every
product mark — nebelung's tiles here, pounce's, perch's and trill's read
out of their own repos — it checks that every path, transform, tile radius and
alpha step in the SVG is written out in the stanza here, and that the file
spends nebelung tokens and no other product's accent. It also closes this file
on itself: the clearspace ratios and the minimum-size table are re-derived from
the *Lockups* bullets and from the house paths, caret and text lines written
above, and the media kit's short version is diffed back against both. It runs
one way, it does not check that a token is in the *role* the stanza gives it,
and it reaches the house's two squares only through the four paths quoted
here, never their ring of ninety interpolated wedges. Everything outside that
is on the reader.

Three scopes this file deliberately does not own:

| That question is… | Owned by |
|---|---|
| how a **CLI** draws: colour roles, glyphs, columns | **snug**'s `README.md` and `AGENTS.md`, the terminal presentation standard (see the routing table's row) |
| how **hausfold.co** implements this: greyscale at rest, borrowed colour, one hue per docs tree, the one sanctioned motion | that repo's `AGENTS.md` and `docs/design.md`. The page register below is vendored from its `public/hausfold.css`; the stylesheet is the site's own, not an API, so copy its numbers and never its class names |
| the palette **tokens** themselves | **nebelung**. The values in this file are vendored from its `palette/nebelung.hex.json` (rendered for CSS as `dist/css/nebelung-mocha.css`) and nebelung stays the source of truth: `test/design-palette.bats` diffs every hex in this file back against it, and every number the page register quotes back against hausfold.co's stylesheets. A web page can load the served copy at `https://hausfold.co/hausfold.css` |

## Overview

- **Silver-mist.** Dark, low-contrast, everywhere: a silver-mist Catppuccin
  Mocha variant, named for the Nebelung cat. Grey, in fog.
- **Elevation is surface steps**, base to surface0 to surface1, never
  shadows.
- **Accents are pastel and light**: text, icons and borders on dark surfaces,
  or fills with dark (crust) text on top.
- **Marks are quiet**: one idea, one extra shape, nothing thin. The measurable
  form of that rule is under *Shapes*.
- **Precise, calm, restrained.** A page states what a thing is and how to
  install it, and stops. Nothing is sold with a gradient.

Two registers, and every artifact belongs to exactly one:

| Register | Who | Colour | Mark |
|---|---|---|---|
| **The house** | hausfold the org, haus the layer, snug the runtime, every desktop (`hacker`, `everyday`, `minimal`, `blank`), hausfold.co | grey at rest; colour is borrowed from a product, never owned. The hacker desktop holds pink as an *accent* (the site's `--a-hacker`, the docs' error callouts, the hero's themed browser) and nothing else | the house `⌂`, the org's mark. **A desktop never has a mark**, and neither does haus or snug |
| **The products** | nebelung, pounce, perch, trill, scruff | one hue each, no two the same | the family ears on a tile, where a mark exists (nebelung, pounce, trill, perch). scruff sets the wordmark alone |

Two surfaces, and every deliverable is one or the other:

| Surface | Examples | Face | Theme | Radius |
|---|---|---|---|---|
| **Artifact** | a tile, a banner, the family strip, an OG card, a README hero, a social card | Space Grotesk | dark; a light one is latte, and the org's light square alone is paper | 24 and 28 |
| **Page** | a one-off page, a landing, the docs, anything in a browser | the Mac's own: New York, SF, SF Mono | both, always | 2 to 6px |

## Colors

| Token | Hex | Brand use |
|---|---|---|
| `--nebelung-crust` | `#121212` | deepest ground: OG cards, the family strip, the house's tile; ears and shapes on inverted banners; a page's dark ground |
| `--nebelung-mantle` | `#191919` | alias target of `--nebelung-bg-alt` |
| `--nebelung-base` | `#202020` | artifact page background; tile fill when the tile sits on a surface0 banner |
| `--nebelung-surface0` | `#343434` | standard mark tile; standard banner ground; "gray" in inverted marks; ghost ears on OG cards @ 0.55 |
| `--nebelung-surface1` | `#494949` | the gray story shape in every mark (prompt bar, card, fog); `--nebelung-border`; a page's 1px rule in dark |
| `--nebelung-surface2` | `#5c5c5c` | secondary story shape (fog layer 2 @ 0.7, text lines); dashed placeholder border |
| `--nebelung-overlay0` | `#717171` | reserved |
| `--nebelung-overlay1` | `#858585` | section eyebrows; OG footer |
| `--nebelung-overlay2` | `#9a9a9a` | small labels ("ORG"); a page's tertiary ink in dark |
| `--nebelung-subtext0` | `#aeaeae` | OG subtitle; product labels; `--nebelung-fg-muted` |
| `--nebelung-subtext1` | `#c3c3c3` | a page's secondary ink in dark |
| `--nebelung-text` | `#d7d7d7` | primary text; the `hausfold` wordmark on an artifact |
| `--nebelung-rosewater` | `#f3e1dd` | reserved |
| `--nebelung-flamingo` | `#efcece` | reserved |
| `--nebelung-pink` | `#f2c4e5` | **the hacker desktop's accent**, and the docs' error callouts. An accent, not a product colour, and never a mark |
| `--nebelung-mauve` | `#c9a8f1` | **nebelung's product colour**; `--nebelung-accent`; link colour; what `/docs/haus` wears, borrowed |
| `--nebelung-red` | `#ed8fa9` | `--nebelung-danger` only |
| `--nebelung-maroon` | `#e6a3ad` | hausfold.co's provisional pick for scruff (see the product table) |
| `--nebelung-peach` | `#f5b58e` | **pounce's product colour** |
| `--nebelung-yellow` | `#f7e2b5` | **trill's product colour**; `--nebelung-warning` |
| `--nebelung-green` | `#abe1a6` | **perch's product colour**; `--nebelung-success` |
| `--nebelung-teal` | `#9be0d5` | `--nebelung-info` |
| `--nebelung-sky` | `#91dbe8` | retired, never reassigned: a trill asset holding sky is stale |
| `--nebelung-sapphire` | `#7dc6e7` | reserved |
| `--nebelung-blue` | `#8db4f3` | reserved. Blue is the hue nebelung exists to strip out; never an accent |
| `--nebelung-lavender` | `#b5bff8` | link hover on working canvases |

Semantic aliases: `--nebelung-bg` → base · `--nebelung-bg-alt` → mantle ·
`--nebelung-bg-deep` → crust · `--nebelung-fg` → text · `--nebelung-fg-muted`
→ subtext0 · `--nebelung-border` → surface1 · `--nebelung-accent` → mauve ·
`--nebelung-success` → green · `--nebelung-warning` → yellow ·
`--nebelung-danger` → red · `--nebelung-info` → teal.

### Product colours

| Name | Register | Token | Hex | Status |
|---|---|---|---|---|
| hausfold (org) | house | none | | no hue of its own. The wordmark is `--nebelung-text` on crust; the house glyph is grey at rest and sweeps all six accents when it shows colour |
| haus | house | none | | no hue of its own. Its docs tree wears mauve because the layer ships nebelung: borrowed, and it stays nebelung's |
| snug | house | none | | no hue and no mark, by decision. The family pins it by rev and `bench release snug` refuses: it is the runtime under our CLIs, not something anyone installs, so it sets the wordmark alone like haus |
| hacker (desktop) | house | `--nebelung-pink` | `#f2c4e5` | an accent only. The other desktops hold none |
| nebelung | product | `--nebelung-mauve` | `#c9a8f1` | decided (latte mauve `#8545e3`) |
| pounce | product | `--nebelung-peach` | `#f5b58e` | decided (latte peach `#f66d2d`) |
| perch | product | `--nebelung-green` | `#abe1a6` | decided (latte green `#4a9e3a`) |
| trill | product | `--nebelung-yellow` | `#f7e2b5` | decided (latte yellow `#d99137`) |
| scruff | product | `--nebelung-maroon` | `#e6a3ad` | provisional: hausfold.co's pick, not yet carried into the logo system. Deliberately maroon and **not pink** (latte maroon `#de5059`) |

**The ring** is those six accents in one fixed order, read clockwise from
twelve: mauve, maroon, green, yellow, peach, pink (nebelung, scruff, perch,
trill, pounce, hacker). It is the only place the accents appear together:
the house glyph's sweep and the favicon. Nothing else lines them up.

Rules:

- Every colour is `var(--nebelung-*)`. A hardcoded hex is a defect.
- Mauve is the accent. No hue competes with it as a CTA.
- **Each product owns one hue and no two share one.** A hue that falls out
  of use (sky) is retired, never reassigned. There is no seventh accent, and
  the six are spoken for. snug is house register precisely so that it never
  needs one.
- **The house borrows.** A house surface shows a product's hue only while
  pointing at that product; at rest it is grey.

### Colour on a page

- **Both themes, always.** A page defines its colours as tokens on `:root`,
  redefines them under `prefers-color-scheme: dark` and again under
  `[data-theme]`, and paints its own ground. Both themes is a page rule; an
  artifact is dark, or latte where it is light.
- **Dark is nebelung, pushed one step out** for contrast: ground crust, the
  secondary ink subtext1, the tertiary ink overlay2, the rule surface1. Two
  values are deliberately not tokens and stay literal in `hausfold.css`: the
  primary ink, one rung above `text`, and the well fill, which is not mantle.
- **Light is paper, not latte.** nebelung's pastels are built for a dark
  ground and wash out on white, so the light page palette (ground, three
  inks, rule, well, and a darker copy of each of the six accents) is
  hand-picked in `hausfold.css` and is the only light set a page may use.
  Reference it by name; it has no `--nebelung-*` spelling.
- **A landing page is greyscale at rest.** A product's name takes that
  product's accent on hover; the house glyph sweeps the ring on hover; the
  favicon holds the ring with no hover to gate it. That is the whole colour
  budget of a landing page.
- **A docs page wears one hue at rest**, its tree's, so a reader can tell
  the trees apart with the page upside down: haus mauve (borrowed), pounce
  peach, perch green, trill yellow, scruff maroon. Four named steps and
  nothing mixes its own: the accent; a wash at 7% for fills; a line at 55%
  into the rule colour; a quiet at 50% into the tertiary ink for a resting
  glyph. Callouts spend perch green for success, trill yellow for warning,
  hacker pink for error, and the tree's own accent for info.
- **Colour orients; it never decorates.** Every place it lands answers
  *where am I* or *what is this*. If a use answers neither, it stays grey.

## Typography

Two faces for two surfaces, and one rule across both: **wordmarks are
lowercase**, `hausfold` through `snug`.

| | Artifact | Page |
|---|---|---|
| Face | **Space Grotesk** (Google Fonts, 400 to 700) on every artifact: banners, OG cards, the logo sheet | **the Mac's own faces**, never a webfont. New York (`ui-serif`) for landing body and every docs heading; SF (`-apple-system`) for docs body; SF Mono for chrome: the mark, the wordmark, breadcrumbs, eyebrows, code, the colophon |
| Wordmark | 600, +0.06em, lowercase | SF Mono 400, +0.02em, lowercase |
| Capitals | eyebrows, taglines and footers only, wide-tracked 0.14 to 0.24em | eyebrows, the copy button and the colophon's stage label only, 0.10 to 0.16em |
| Never | a system face | Space Grotesk, or any font loaded over the network |

Artifact scale as built (px / weight / tracking):

| Use | Spec | Colour |
|---|---|---|
| OG title (product name) | 92 / 700 / +0.04em, lowercase | product colour |
| OG subtitle | 36 / 400, line-height 1.4 | `subtext0` |
| OG footer `HAUSFOLD / NAME` | 23 / 400 / +0.22em, UPPER | `overlay1` |
| Banner wordmark | 30 / 600 / +0.06em, lowercase | product colour (standard) · `surface0` or `crust` (inverted) |
| Banner tagline | 11 / 400 / +0.2em, UPPER | `crust` @ 0.72 |
| Family strip `hausfold` | 40 / 600 / +0.06em | `fg` |
| Section eyebrow | 12 / 600 / +0.18em, UPPER | `overlay1` |
| Labels under tiles | 12 to 14 / 400 | `subtext0` |

Page scale as built. Sizes clamp between a phone and a desktop; the token
carries the desktop end.

| Use | Spec | Colour |
|---|---|---|
| Landing body | New York, `clamp(0.94rem, 0.9rem + 0.2vw, 1.02rem)` / 1.62 | primary ink |
| Standfirst | New York, `clamp(1.28rem, 4vw, 1.72rem)` / 1.32 / −0.014em, at most 22ch, balanced | primary ink |
| The house glyph | SF Mono 300, `clamp(3.4rem, 11vw, 5rem)` / 0.9 | tertiary ink at rest |
| Wordmark | SF Mono 400, `clamp(1.5rem, 5vw, 1.95rem)` / +0.02em | primary ink |
| Section eyebrow | SF Mono 400, 0.72rem / +0.16em, UPPER, 1px rule beneath | tertiary ink |
| Command, code block | SF Mono, 0.82rem / 1.6 | primary ink |
| Inline code | SF Mono, 0.86em | secondary ink |
| Fact term | SF Mono, 0.82rem / 1.75 | primary ink |
| Colophon | SF Mono, 0.8rem; stage label 0.66rem / +0.16em, UPPER | tertiary ink |
| Docs heading | New York; `h1` `clamp(1.85rem, …, 2.25rem)` | primary ink |
| Docs body | SF, `clamp(0.98rem, 0.94rem + 0.22vw, 1.06rem)` / 1.7 | primary ink |

## Layout

**Artifacts** are built to the fixed geometry under *Components*: padding
32 on a banner, 48 on the family strip, 72 on an OG card; gaps 20 (banner mark to
wordmark), 36 (family strip tiles), 52 (OG tile to text column), 18 (OG title to
subtitle). Copy those numbers verbatim rather than approximating them; there
is no grid behind them.

**A page is one column, and it leans left.**

- The reading column is **41rem** wide, hung off an implied **78rem** page:
  its left margin is `max(0, (100cqw − 78rem) / 2)` and its right margin is
  `auto`. Every line of type starts on the page's own left axis and the
  empty field is on the right. Never centre it.
- Gutter `clamp(1.4rem, 5vw, 2rem)` each side. Top padding
  `clamp(3.5rem, 9vw, 7.5rem)`, bottom `clamp(2.5rem, 6vw, 4rem)`.
- Vertical rhythm, outside in: sections sit `clamp(3rem, 7vw, 4.75rem)`
  apart; inside a section, blocks are 1.05rem apart; a list's items 0.55 to
  0.72rem; the masthead's parts 1.6rem.
- Measures inside the column: prose 62ch, lists and fact grids 58ch, the
  standfirst 22ch.
- One breakpoint, **30rem**, where the two-column fact grid and the colophon
  stack. Everything else is a clamp. A page never scrolls horizontally.
- The docs keep Fumadocs' own two-pane shell, re-pointed at these tokens.
  Nothing new is laid out there.

## Elevation & Depth

- **Surface steps, never shadows.** An artifact rises base → surface0 →
  surface1. A page has a 1px rule in the rule colour and a well fill for a
  box, and nothing else.
- **No blur, no glass, no glow, no drop shadow**, on either surface.
- The one depth device in an artifact is the OG card's ghost ears, 560×560
  in `surface0` @ 0.55, bleeding off the top right.

## Shapes

Radii in use:

| Radius | Where |
|---|---|
| 2px | a page's copy button |
| 3px | a page's command box and tooltips; the docs' default |
| 4 to 6px | the docs' larger controls |
| 6 to 10 | story shapes inside marks, in the 100-unit box; a small accent (caret, text line) keeps half its height |
| **24** | the tile, the banner, the family strip (24% of the tile's side) |
| **28** | OG cards and the logo sheet's cards |
| 999 | pills |

A 24 belongs on a tile and never on a page; a 3 belongs on a page and never
on a tile.

### The ears

One shared mark across the products: two curved ear paths in a 100×100
viewBox, used verbatim in every product mark.

```svg
M 18 13 Q 34 18 47 24 Q 34 35 30.5 57 Q 20 34 18 13 Z   <!-- left -->
M 82 13 Q 66 18 53 24 Q 66 35 69.5 57 Q 80 34 82 13 Z   <!-- right -->
```

The ears are **never redrawn**. A product may change their position, scale
and colour, nothing else. Never outlined, never split into two colours,
never cut out of a filled shape, and never rotated, with one exception:
pounce's leap tilt (12°). The ears belong to the products: the house does
not wear them, and a desktop does not either.

### The house

The org's mark is a house: a pentagon outline with a peaked roof, the `⌂`
glyph made geometry. It exists in two renderings and both are the standard.

- **As geometry**, on a tile: ninety wedges of 4° (half-angle 2° plus 1.5°
  of overlap), radius 80, turning around (50, 51.56) in the 100-unit box,
  painted clockwise from twelve o'clock through the ring, with the colour
  between two accents interpolated in RGB. Over the wedges sits a cover in
  the ground colour with the house cut out of it (`fill-rule="evenodd"`: the
  tile, then the outer pentagon, then the inner). The favicon's house fills
  the tile, stroke 10.8:
  `M50 13.51 L78.22 47.97 L78.22 86.48 L21.78 86.48 L21.78 47.97 Z` outside,
  `M50 30.57 L67.42 51.83 L67.42 75.68 L32.58 75.68 L32.58 51.83 Z` inside.
  The padded square for avatars and social profiles uses the same ring under
  a smaller house:
  `M50 24.57 L65.80 43.86 L65.80 65.43 L34.20 65.43 L34.20 43.86 Z` outside,
  `M50 34.12 L59.75 46.02 L59.75 59.38 L40.25 59.38 L40.25 46.02 Z` inside.
  Sources: this repo's `assets/hausfold-dark-square.svg` (ground crust, the
  six dark accents) and `assets/hausfold-light-square.svg` (the site's paper
  ground and its six light accents); hausfold.co's `public/favicon.svg`,
  generated by its `scripts/sync-nebelung.mjs` from the same ring. The
  monochrome fallback (`favicon.ico`) is the primary ink on crust with no
  sweep. The light square is the one artifact drawn in the page register's
  paper and light accents rather than in latte, because it exists to sit on
  hausfold.co's own ground; every other light artifact is latte.
- **As a glyph**, in running text and on the site's masthead: `⌂` (U+2302)
  in SF Mono at weight 300, grey (the tertiary ink) at rest. On the site it
  sweeps the ring only under the pointer. In a README it is the one
  character allowed before a house wordmark: `⌂ haus`, `⌂ hausfold`.

The house is the only mark that holds colour at rest (the favicon) and the
only one that ever shows more than one accent.

### What makes a mark quiet

The rule is measurable. In the 100-unit box:

- **Nothing narrower than 3.5 units.** The pounce caret (3.5 wide) is the
  floor; trill's text lines are 5.
- **No strokes.** Every shape is a fill, and no fill is outlined.
- **At most four fills**: the tile, the product colour, `surface1`,
  `surface2`. A product-colour accent inside a gray shape (pounce's caret,
  trill's dot) counts as the product colour.
- **One story shape**, or one shape in two layers (nebelung's fog, perch's
  two cards). A third idea is a second draft.
- Detail is what gets a draft rejected: notches, cut-outs, swatch strips,
  outline strokes, two-tone ears.

## Components

### The tile

- Square, 100×100 viewBox, corner radius **24**.
- **Standard**: tile `surface0`, ears in the product colour, story shapes in
  `surface1`/`surface2`.
- **Inverted**: tile in the product colour; ears and shapes `surface0` (logo
  sheet) or `crust` (banners carrying a tagline). Small accents inside
  inverted shapes keep the product colour. A gray dims to 0.45, and what it
  dims *to* depends on what it sits on: over the tile ground it stays
  `surface0` (perch's back card), and over another inverted shape it steps
  darker to `mantle`, because `surface0` at 0.45 over `surface0` is
  `surface0` and the shape disappears (nebelung's second fog, trill's text
  lines).
- **Light**: the same drawing in nebelung's latte set — tile latte base
  `#f1f1f1`, ears the product's latte accent (*Product colours*), story
  shapes latte surface1 `#c0c0c0` and latte surface2 `#b0b0b0`, on a latte
  crust `#e0e0e0` ground where the artifact carries one. A light tile keeps
  each shape's *position* in the ramp, not its token name: the latte ramp
  runs the other way, so the tile is `base`, its lightest neutral, and still
  sits a step above the ground the way `surface0` does on crust, while the
  story shapes turn round and step darker than the tile instead of lighter.
  `surface2` is still the further of the two. Latte accents are saturated
  rather than pastel, which is what makes them read here, and why a light
  artifact is latte while a light page is paper (*Colour on a page*). One
  drawing holds one set: never latte with paper, and never latte with mocha.
- **No light inverted tile.** An inverted tile is already the product colour
  carrying dark shapes, so it holds on a light ground as it does on crust.
- A shape that bleeds off the tile is clipped by the tile's own rounded rect.
- **An iOS app icon keeps the tile's clip and loses its ground's radius**:
  the ground bleeds square to all four edges and carries no alpha channel,
  because iOS masks its own squircle over a square it requires to be opaque,
  and our radius 24 would show through that mask as four transparent
  notches. The shapes are still cut by the tile's rounded rect, as the
  bullet above says. A mark whose shapes bleed is inset far enough that the
  system's mask cannot clip them at 60 pt; how far is the mark's own number,
  below.

### The marks

Every product mark is the untouched family ears in the product colour, plus
gray palette shapes that carry the story, at the same weight as its siblings.

**nebelung**: *Nebel, ears sinking into grey fog.* Ears mauve,
`translate(10 12) scale(0.8)`. Fog layer 1
`M -4 66 Q 18 56 38 64 Q 62 73 82 63 Q 94 58 106 64 L 106 104 L -4 104 Z`
in `surface1`; fog layer 2
`M -4 80 Q 22 71 46 78 Q 72 86 106 76 L 106 104 L -4 104 Z`
in `surface2` @ 0.7. Latte variant: the light tile above, ears
latte mauve, fog @ 0.7. In the inverted tile the fog
steps darker too: fog 1 is `surface0` and fog 2 is `mantle` @ 0.45 over it.

**pounce**: *mid-pounce over the prompt bar.* Ears peach,
`translate(14 4) scale(0.72) rotate(12 50 35)`. Prompt bar
`rect 10,66 80×18 rx 9` in `surface1`; caret `rect 19,70.5 3.5×9 rx 1.75`
peach. Tagline: `SUMMON, AIM, POUNCE`.

**trill**: *the card wears the ears.* Ears yellow,
`translate(14 0) scale(0.72)`; notification card `rect 14,52 72×34 rx 10` in
`surface1`; dot `circle 26,63 r 4.5` yellow; text lines `rect 36,59 38×5` and
`rect 36,69 26×5` (rx 2.5) in `surface2`. Inverted: ears and card
`surface0`, the dot still yellow, the two text lines `mantle` @ 0.45 over the
card. Tagline: `NO NOISE, JUST A TRILL`.

**perch**: *two files, fanned out.* Ears green, `translate(4 19)
scale(0.72)`. Cards clipped to the tile: `rect 10,68 42×46 rx 6` in
`surface1` under `rotate(-11 31 91)`, `rect 46,64 42×48 rx 6` green under
`rotate(7 67 88)`. The iOS icon is that whole tile inset by
`translate(9 9) scale(0.82)` on a full-bleed `surface0` ground, which is what
keeps the lower card off the system's mask.

**hausfold (org)**: the house, under *Shapes*. On a tile its ground is
crust, never `surface0`.

**No mark, by decision**: haus, snug, and every desktop. They set the
wordmark alone, with the house glyph in front of it where a README wants a
glyph. **No mark yet**: scruff sets the wordmark alone until one is ratified.
An emoji is not a stand-in for a mark on any of them.

### Lockups

- **Banner**: 400×116, radius 24, padding `0 32`, gap 20; mark 62×62;
  wordmark 30/600/+0.06em lowercase. Standard: ground `surface0`, wordmark in
  the product colour. Inverted: ground in the product colour, wordmark
  `surface0`, or `crust` with the tagline under it.
- **Family strip** (the design project's *showcase*): 760 wide, padding 48, ground `crust`, 1px
  `--nebelung-border`, radius 24. Org row (wordmark + `ORG` label) above a
  1px `surface0` rule, then the product tiles at 88×88, gap 36.
- **OG card**: 1280×640, padding 72, ground `crust`, radius 28, clipped.
  Product tile 220×220, 52 from the text column; title/subtitle stacked with
  gap 18; ghost ears 560×560 at top −150 / right −110 in `surface0` @ 0.55;
  footer `HAUSFOLD / NAME` bottom-left.

### Clearspace and minimum sizes

**Clearspace: 0.2× the mark's own width, on every side.** No other ink inside
that band — another mark, a wordmark, running text, a rule, or the edge of the
artwork. The mark's own silhouette used as ground texture is not ink, which is
what lets the OG card's ghost ears (`surface0` @ 0.55 on crust) sit anywhere.
The figure is read off the three lockups above, which already clear it as
drawn: the banner's 20px gap is 0.323× its 62px mark, the family strip's 36px
gap 0.409× its 88px tiles, and the OG card's 52px to the text column 0.236× its
220px tile — the tightest clearance the family draws, and still clear.
`test/design-palette.bats` re-derives every clearance those three bullets
state, the padding around each mark included, so one that tightens reddens the
test instead of quietly breaking the rule.

**Minimum sizes are device pixels**, not points: a 16pt icon on a 2× display is
a 32px raster and safe, and the same icon on a 1× display is the case that
breaks. Unlike the clearspace figure these are not read off a shipped file —
nothing in the family draws a mark below the banner's 62px — they are what the
geometry above does to a raster, rendered at each size and read back.

| raster | what reads |
|---|---|
| **16px** | the ears, the hue and the tile; the house only where it fills its tile (the favicon's walls, 10.8 units → 1.73px) |
| **24px** | the story shape as a silhouette, and the padded square's house (walls 6.05 units → 1.45px) |
| **32px** | the finest thing inside a story shape: pounce's caret in peach (3.5 units → 1.12px), and trill's two text lines, whose 5-unit gap only returns to the card colour here |

**Under 16px there is no mark** — the wordmark alone, with the `⌂` glyph in
front of it only where a house wordmark already takes one.

One rule underneath that table: **a shape needs about a device pixel of ink to
be itself** (units × size ÷ 100). Below that it survives only as a tint of what
sits behind it, which is why 3.5 units is the floor under *What makes a mark
quiet* and why nothing finer is drawn. Two shapes want more again: trill's
lines sit 5 units apart, and at 24px that gap is a dip in the grey rather than
the card showing through.

### Page pieces

The parts a hausfold page is made of, as decisions. `hausfold.css` is the
site's stylesheet, not a published API: take the numbers, write your own
classes.

- **Masthead**: the house glyph, then the wordmark, then the standfirst,
  stacked 1.6rem apart, left-aligned.
- **Command box**: 1px rule, well fill, radius 3, padding `0.85rem 1rem`;
  the command in SF Mono 0.82rem, scrolling sideways inside the box; a
  `COPY` button in SF Mono 0.7rem, +0.1em, uppercase, radius 2, 1px rule,
  transparent ground.
- **Section**: an eyebrow in SF Mono 0.72rem uppercase over a 1px rule,
  then prose at 62ch. Headings inside are 600 at body size.
- **Index**: a list of products, each a SF Mono name at 0.92rem and a prose
  line; the name takes its product's accent on hover only.
- **Fact list**: a two-column grid, SF Mono term and prose definition, gap
  `0.5rem 1.1rem`, one column under 30rem.
- **Colophon**: a top rule, SF Mono 0.8rem, the stage label pushed right.
- **Links**: inherit colour, 1px underline in the tertiary ink offset
  0.25em, underline goes to the text colour on hover; focus is a 2px outline
  offset 3px.
- **Media**: none. A page shows a product in code, drawn in HTML inside an
  SVG laptop frame, or shows nothing. Screenshots are governed by
  `assets/SHOTLIST.md` and no page carries one.

## Do's and Don'ts

- **Do** keep the ears path identical across products; move, scale and
  recolour only.
- **Do** keep every mark to the ears plus one gray story idea, within the
  four-fill and 3.5-unit limits above.
- **Do** stay dark on an artifact, or latte where a light one is wanted,
  ship both themes on a page, step surfaces
  for elevation, and spend accents as light strokes and fills on dark or
  with crust text on top.
- **Do** set Space Grotesk on an artifact and the Mac's own faces on a
  page, and lowercase every wordmark on both.
- **Do** lean a page's column left and hold it at 41rem.
- **Don't** hardcode hex; resolve every colour through `var(--nebelung-*)`,
  or on a page through the named tokens in `hausfold.css`.
- **Don't** add fine detail: notches, cut-outs, multi-swatch strips, outline
  strokes, two-tone ears.
- **Don't** rotate the ears (pounce's 12° tilt is the one exception), outline
  them, or carve them out of a filled shape.
- **Don't** share a hue between products, or let anything compete with mauve
  as the accent.
- **Don't** give the house a hue, a desktop a mark, or a product without a
  mark an improvised one.

### Reflexes to refuse

Generated design has habits. Each of these has been drafted at least once
and is refused on sight:

- a gradient anywhere but the house's ring
- glass, blur, glow, or a drop shadow
- a grid of cards, each with an icon, a title and a blurb
- an eyebrow over every heading, a badge row, a row of pills
- blue, or a seventh hue, or a hue the house keeps at rest
- a hardcoded hex where a token exists
- a light artifact in anything but latte, the org's paper square aside, or
  a single theme on a page
- an inverted tile redrawn in latte, or latte and paper mixed in one drawing
- a webfont on a page, or a system face on an artifact
- a centred column, a hero band, a full-bleed page background
- a wordmark in capitals, or an emoji standing in for a mark
- radius 24 on a page, or radius 3 on a tile
- a screenshot in a docs page, or a stock icon anywhere
- motion on load, a spinner, a scroll-driven effect, a scroll-snap point
- an outline stroke, a notch, a cut-out, two-tone ears
- a mark for haus, a desktop, scruff or snug
- a mark under 16px, or one crowded tighter than 0.2× its own width

### Motion

None in an artifact. On a page, nothing moves while you read. The one
sanctioned motion in the family is the site's: the house glyph's ring turns
under the pointer, fading in over 0.7s, never on load, and
`prefers-reduced-motion` keeps the colour and drops the turn. A second one
has to clear the bar hausfold.co's `AGENTS.md` sets, in that repo.

## Not yet defined

Current gaps, stated so nobody fills them by improvising. A gap here is a
decision someone owes, not a file to go and draw: *Reflexes to refuse* turns
the first away on sight, so closing it takes an edit there as well as here.

- **A mark for scruff.** Maroon is its hue; the story shape is undecided. snug
  is not on this list — it is house register, and never gets one.
- **An icon set** beyond the logo marks.
- **A grid** for anything wider than one column, and **breakpoints** beyond
  the one at 30rem.

Where the design project holds a second candidate (trill's fused
single-silhouette icon master, perch's re-laid-out banner variant, the
`NOTIFICATIONS, FILTERED` tagline) the geometry written above is the
standard until this file changes.

## Agent quick reference

Ground `#121212` (crust) · card `#202020` (base) · tile `#343434` (surface0)
· gray shapes `#494949`/`#5c5c5c` · text `#d7d7d7` · muted `#aeaeae` ·
accents: mauve `#c9a8f1`, peach `#f5b58e`, yellow `#f7e2b5`, green `#abe1a6`,
maroon `#e6a3ad`; pink `#f2c4e5` is the hacker desktop's accent only · the
ring: mauve, maroon, green, yellow, peach, pink · the house is the org mark,
the ears are the products' · **artifact**: Space Grotesk, dark, and latte
for a light one · wordmarks lowercase 600/+0.06em, radii 24/28 · marks:
0.2× clearspace, floors 16/24/32 device px · **page**: New York + SF +
SF Mono, both themes, greyscale at rest, one 41rem column leaning left,
radius 3 · no shadows · no motion.
