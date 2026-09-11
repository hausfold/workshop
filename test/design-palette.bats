#!/usr/bin/env bats
# docs/design.md, assets/README.md (the media kit) and the mark SVGs — the ones
# here, and pounce's, perch's and trill's in their own repos — vendor nebelung
# hexes; the doc also vendors hausfold.co's page numbers, and
# AGENTS.md's rule is that nothing is inlined without a drift test — this is
# that test. Every hex in the doc is diffed back against nebelung's
# palette/*.hex.json, and every literal the page register quotes (measure,
# gutter, rhythm, faces, radii, accent steps) back against hausfold.co's
# public/hausfold.css and src/app/global.css: the checkout beside the
# workshop's main checkout when there is one, else GitHub raw (both repos
# are public), so it runs on a dev machine and in CI alike. When it reddens,
# the upstream moved: re-vendor the doc's values, never the other way around.

palette_dir=""
marks_dir=""

# The tests that fetch nothing — three that read only this repo's own files,
# and one that reads the sibling checkouts if they are there. setup() returns
# before it can skip any of them on a palette, a stylesheet or a mark it could
# not reach — the shape docs/drift.md parks under "a per-item skip in setup()
# blanks every test in the file, and reads green".
NO_FETCH_TESTS=(
  "design.md's clearspace ratios are what its own lockups measure"
  "design.md's minimum sizes are the arithmetic its own geometry gives"
  "the media kit's short version matches design.md"
  "PRODUCT_MARKS names every mark SVG in the sibling repos"
)

# The product marks that live in their own repos. nebelung's tiles are in this
# repo's assets/ and need no fetching.
PRODUCT_MARKS=(
  pounce/pounce-square
  pounce/pounce-square-inverted
  pounce/pounce-square-latte
  perch/perch-square
  perch/perch-square-inverted
  perch/perch-square-latte
  perch/perch-icon-ios
  trill/trill-icon-master
  trill/trill-square-inverted
  trill/trill-square-latte
)

setup() {
  WORKSHOP="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  DOC="$WORKSHOP/docs/design.md"
  KIT="$WORKSHOP/assets/README.md"
  local no_fetch
  for no_fetch in "${NO_FETCH_TESTS[@]}"; do
    if [ "$BATS_TEST_DESCRIPTION" = "$no_fetch" ]; then return 0; fi
  done
  palette_dir="$BATS_TMPDIR/design-palette"
  mkdir -p "$palette_dir"
  local common neb_dir f
  common="$(git -C "$WORKSHOP" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)"
  neb_dir=""
  [ -n "$common" ] && neb_dir="$(dirname "$common")/nebelung/palette"
  for f in nebelung.hex.json nebelung-latte.hex.json; do
    [ -s "$palette_dir/$f" ] && continue
    if [ -n "$neb_dir" ] && [ -f "$neb_dir/$f" ]; then
      cp "$neb_dir/$f" "$palette_dir/$f"
    else
      curl -fsSL "https://raw.githubusercontent.com/hausfold/nebelung/main/palette/$f" \
        -o "$palette_dir/$f" 2>/dev/null || true
    fi
    [ -s "$palette_dir/$f" ] || skip "no nebelung checkout and no network for $f"
  done
  local site_dir out
  site_dir=""
  [ -n "$common" ] && site_dir="$(dirname "$common")/hausfold.co"
  for f in public/hausfold.css src/app/global.css; do
    out="$palette_dir/$(basename "$f")"
    [ -s "$out" ] && continue
    if [ -n "$site_dir" ] && [ -f "$site_dir/$f" ]; then
      cp "$site_dir/$f" "$out"
    else
      curl -fsSL "https://raw.githubusercontent.com/hausfold/hausfold.co/main/$f" \
        -o "$out" 2>/dev/null || true
    fi
    [ -s "$out" ] || skip "no hausfold.co checkout and no network for $f"
  done
  marks_dir="$palette_dir/marks"
  mkdir -p "$marks_dir"
  # Set for the five tests that read marks; the other six that get this far do
  # not, and a mark they never open must not decide their outcome.
  MARKS_MISSING=""
  local mark repo repo_dir resolved=0
  for mark in "${PRODUCT_MARKS[@]}"; do
    repo="${mark%%/*}"
    f="${mark##*/}.svg"
    repo_dir=""
    [ -n "$common" ] && repo_dir="$(dirname "$common")/$repo/assets"
    # A checkout is re-read every time: BATS_TMPDIR outlives the run, and a
    # cached copy would keep this green through the very edit it exists to
    # catch. Only the download is cached, and only against the eleven fetching
    # setups one `bats` invocation of this file runs. A checkout that is here answers
    # for itself, so a file it does not have clears the cached copy too.
    if [ -n "$repo_dir" ] && [ -d "$repo_dir" ]; then
      if [ -f "$repo_dir/$f" ]; then cp "$repo_dir/$f" "$marks_dir/$f"; else rm -f "$marks_dir/$f"; fi
    elif [ ! -s "$marks_dir/$f" ]; then
      curl -fsSL "https://raw.githubusercontent.com/hausfold/$repo/main/assets/$f" \
        -o "$marks_dir/$f" 2>/dev/null || true
    fi
    if [ -s "$marks_dir/$f" ]; then resolved=$((resolved + 1)); else MARKS_MISSING="$MARKS_MISSING $repo/$f"; fi
  done
  # ONE mark going missing while the rest resolve means PRODUCT_MARKS names a
  # file that is on no upstream `main` yet — the five mark tests fail for it,
  # loudly, and the other six still run. Skipping instead would blank all eleven,
  # this diff's own claims included; that is the shape docs/drift.md parks under
  # "Seen once", and a note is not a gate. The only skip left is the machine
  # that can reach NOTHING: no sibling checkouts and no network.
  [ "$resolved" -gt 0 ] || skip "no mark SVG is reachable: no sibling checkouts and no network"
}

# The five tests below open the marks; they refuse to pass on a partial set.
assert_every_mark_present() {
  [ -z "$MARKS_MISSING" ] || {
    echo "PRODUCT_MARKS names a mark that is in no sibling checkout and on no"
    echo "upstream main:$MARKS_MISSING"
    echo "Land the mark's own repo first, then bench pull, then this."
    false
  }
}

@test "PRODUCT_MARKS names every mark SVG in the sibling repos" {
  # The five mark tests open what this array names and nothing else, so a mark
  # added upstream and forgotten here is a file with no drift test at all —
  # green, and unguarded: docs/drift.md row 33, a check whose census is a
  # hand-maintained list. This walks the other way: every *.svg in a sibling
  # repo's assets/ has to be in the array. It reads checkouts only. There is
  # nothing to enumerate over the network, because the array is itself what
  # says which repos to look in, so a machine without them skips rather than
  # grading a list against itself.
  local root repo repo_dir f name missing="" found=0
  root="$(dirname "$(git -C "$WORKSHOP" rev-parse --path-format=absolute --git-common-dir)")"
  for repo in $(printf '%s\n' "${PRODUCT_MARKS[@]}" | cut -d/ -f1 | sort -u); do
    repo_dir="$root/$repo/assets"
    [ -d "$repo_dir" ] || continue
    found=1
    for f in "$repo_dir"/*.svg; do
      [ -e "$f" ] || continue
      name="$repo/$(basename "$f" .svg)"
      printf '%s\n' "${PRODUCT_MARKS[@]}" | grep -qxF "$name" || missing="$missing $name"
    done
  done
  [ "$found" = 1 ] || skip "no sibling checkout to enumerate marks from"
  [ -z "$missing" ] || {
    echo "a mark SVG in a sibling repo that PRODUCT_MARKS does not name:$missing"
    echo "Add it to the array, so the five tests below open it too."
    false
  }
}

@test "every hex in design.md is a nebelung token value (mocha or latte)" {
  run python3 - "$DOC" "$palette_dir" <<'PY'
import json, re, sys
doc, pdir = sys.argv[1], sys.argv[2]
values = set()
for f in ("nebelung.hex.json", "nebelung-latte.hex.json"):
    values |= {v.lower() for v in json.load(open(f"{pdir}/{f}")).values()}
text = open(doc).read()
bad = sorted({h.lower() for h in re.findall(r"#([0-9a-fA-F]{6})\b", text)} - values)
if bad:
    print("hexes in design.md that are no nebelung token value:", ", ".join("#" + b for b in bad))
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "every hex in the media kit's README is a nebelung token value" {
  run python3 - "$KIT" "$palette_dir" <<'PY'
import json, re, sys
doc, pdir = sys.argv[1], sys.argv[2]
values = set()
for f in ("nebelung.hex.json", "nebelung-latte.hex.json"):
    values |= {v.lower() for v in json.load(open(f"{pdir}/{f}")).values()}
text = open(doc).read()
bad = sorted({h.lower() for h in re.findall(r"#([0-9a-fA-F]{6})\b", text)} - values)
if bad:
    print("hexes in assets/README.md that are no nebelung token value:", ", ".join("#" + b for b in bad))
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "a mark SVG spends only nebelung tokens, and only its own accent" {
  assert_every_mark_present
  run python3 - "$palette_dir" "$WORKSHOP/assets" "$marks_dir" <<'PY'
import glob, json, os, re, sys
pdir, adirs = sys.argv[1], sys.argv[2:]
values = set()
for f in ("nebelung.hex.json", "nebelung-latte.hex.json"):
    values |= {v.lower() for v in json.load(open(f"{pdir}/{f}")).values()}
# The house's two squares are exempt: their ring is ninety wedges of colour
# interpolated between two accents, so those fills are deliberately not tokens.
files = [f for d in adirs for f in sorted(glob.glob(f"{d}/*.svg"))
         if not os.path.basename(f).startswith("hausfold-")]
if not files:
    print(f"no mark SVGs found in {adirs}; this test has lost its subject")
    sys.exit(1)
# "One hue per product" is measurable: every accent a mark spends has to be its
# own. The neutrals are the ramp; everything else in the palette is an accent.
NEUTRAL = {"text", "subtext1", "subtext0", "overlay2", "overlay1", "overlay0",
           "surface2", "surface1", "surface0", "base", "mantle", "crust"}
# Both sets, because a light tile is latte: a latte accent in the wrong mark is
# the same defect as a mocha one. No mocha accent is a latte neutral or the
# reverse, so the union stays a clean partition. What it cannot tell is WHICH
# set a file is drawn in — a mark spending its own hue out of both ramps at
# once passes here; that is "a mark SVG is drawn in one nebelung set" below,
# and which ROLE each hex is in is the fill test below that.
ramps = [{k: v.lower() for k, v in json.load(open(f"{pdir}/{f}")).items()}
         for f in ("nebelung.hex.json", "nebelung-latte.hex.json")]
accents = {v for r in ramps for k, v in r.items() if k not in NEUTRAL}
own = {p: {r[t] for r in ramps} for p, t in
       (("nebelung", "mauve"), ("pounce", "peach"), ("perch", "green"),
        ("trill", "yellow"), ("scruff", "maroon"))}
bad = []
for f in files:
    base = os.path.basename(f)
    mine = own.get(base.split("-")[0])
    for h in sorted({h.lower() for h in re.findall(r"#([0-9a-fA-F]{6})\b", open(f).read())}):
        if h not in values:
            bad.append(f"{base}: #{h} is no nebelung token value")
        elif mine and h in accents and h not in mine:
            bad.append(f"{base}: #{h} is another product's accent, not one of its "
                       f"own ({', '.join('#' + x for x in sorted(mine))})")
if bad:
    print("colour in a mark SVG that the standard does not allow it:")
    for b in bad:
        print("  " + b)
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "every shape a mark SVG draws is written out in design.md" {
  assert_every_mark_present
  run python3 - "$DOC" "$WORKSHOP/assets" "$marks_dir" <<'PY'
import glob, os, re, sys
doc, adirs = sys.argv[1], sys.argv[2:]
# design.md is the public standard and prints each mark's geometry as text; the
# SVG beside the PNG is the source of record. This is the seam between them:
# every path, transform, tile radius and alpha step in the SVG has to be written
# out in the doc. It runs one way only, and it reads no fills; colour is the
# test above. The house's two squares are exempt: their ring is ninety wedges of
# interpolated colour that design.md states as a rule rather than as ninety
# paths. Its glyph path IS written out, but spaced differently there, so the
# exemption is the whole file rather than the ring alone.
text = re.sub(r"\s+", " ", open(doc).read())
files = [f for d in adirs for f in sorted(glob.glob(f"{d}/*.svg"))
         if not os.path.basename(f).startswith("hausfold-")]
if not files:
    print(f"no mark SVGs found in {adirs}; this test has lost its subject")
    sys.exit(1)
bad = []
for f in files:
    svg = open(f).read()
    for attr in ("d", "transform"):
        for v in re.findall(rf'\b{attr}="([^"]+)"', svg):
            if re.sub(r"\s+", " ", v).strip() not in text:
                bad.append(f"{os.path.basename(f)}: {attr}=\"{v}\"")
    # the tile's corner radius, which design.md fixes at 24
    for v in re.findall(r'<clipPath[^>]*>\s*<rect[^>]*\brx="([^"]+)"', svg):
        if v != "24":
            bad.append(f"{os.path.basename(f)}: tile radius {v}, and design.md says 24")
    # every alpha step, which the doc writes as "@ 0.7", "@ 0.45"
    for v in re.findall(r'\bopacity="([^"]+)"', svg):
        if f"@ {v}" not in text:
            bad.append(f"{os.path.basename(f)}: opacity {v} is in no stanza as @ {v}")
if bad:
    print("geometry in a mark SVG that design.md does not write out:")
    for b in bad:
        print("  " + b)
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "every rect and circle a mark SVG draws is the one design.md writes out" {
  assert_every_mark_present
  run python3 - "$DOC" "$WORKSHOP/assets" "$marks_dir" <<'PY'
import glob, os, re, sys
doc, adirs = sys.argv[1], sys.argv[2:]
# The test above matches whole attribute strings, which is why it reads `d` and
# `transform` and stops: a rect is five attributes in the SVG and one phrase in
# the doc, and neither is a substring of the other, so a shape resized in place
# passed it and the colour test both. This is that seam, for the two primitives
# that are numbers rather than a path. *The marks* spells each one out — `rect
# x,y w×h rx r`, `circle x,y r n` — which makes both directions checkable: no
# mark draws a shape its own stanza doesn't write, and no stanza writes one no
# mark draws. The house's two squares are exempt as above.
text = open(doc).read()
section = re.search(r"^### The marks\n(.*?)(?=^### )", text, re.S | re.M)
if not section:
    print("design.md lost '### The marks', which is where every shape's numbers "
          "are written out: re-derive this test from wherever they went")
    sys.exit(1)
# the stanzas rewrap, and a phrase can wrap with them
section = re.sub(r"\s+", " ", section.group(1))

def num(v):
    return f"{float(v):g}"

def phrase(s):
    if s[0] == "rect":
        return f"rect {s[1]},{s[2]} {s[3]}×{s[4]} rx {s[5]}"
    return f"circle {s[1]},{s[2]} r {s[3]}"

# a shape phrase, or the trailing "(rx 2.5)" that sets the radius for a run of
# rects — which is how the doc writes trill's two text lines
# A shape bleeds off the tile — nebelung's fog runs -4 to 106 — so every
# coordinate here is signed, on both sides.
TOKEN = re.compile(r"rect (-?[\d.]+),(-?[\d.]+) (-?[\d.]+)×(-?[\d.]+)(?: rx (-?[\d.]+))?"
                   r"|circle (-?[\d.]+),(-?[\d.]+) r (-?[\d.]+)"
                   r"|\(rx (-?[\d.]+)\)")

def written(body):
    """Every shape a stanza writes out, as (kind, numbers…)."""
    out, pending = [], []
    for m in TOKEN.finditer(body):
        if m.group(9):
            for r in pending:
                r[5] = num(m.group(9))
            pending = []
        elif m.group(6):
            out.append(["circle"] + [num(g) for g in m.group(6, 7, 8)])
        else:
            r = ["rect"] + [num(g) for g in m.group(1, 2, 3, 4)] + [num(m.group(5) or 0)]
            out.append(r)
            if m.group(5) is None:
                pending.append(r)  # an rx the doc states once, after the run
    return {tuple(r) for r in out}

def drawn(svg):
    """The same, out of a mark. Every other element is a path or a group."""
    # the tile's clip is the test above's, and the tile ground is a rule in
    # *The tile* rather than a rect any stanza writes out — but only while it
    # is square-cornered: a rounded ground is what that bullet forbids an iOS
    # icon, so it comes back through here as a shape no stanza writes
    body = re.sub(r"<clipPath.*?</clipPath>", "", svg, flags=re.S)
    out = set()
    for kind, keys in (("rect", ("x", "y", "width", "height", "rx")),
                       ("circle", ("cx", "cy", "r"))):
        for tag in re.findall(rf"<{kind}\b[^>]*>", body):
            a = dict(re.findall(r'\b([a-z-]+)="([^"]+)"', tag))
            vals = tuple(num(a.get(k, "0")) for k in keys)
            if kind == "rect" and vals == ("0", "0", "100", "100", "0"):
                continue
            out.add((kind,) + vals)
    return out

# Each stanza leads with the product in bold, and each mark's filename leads
# with the same word: that is the whole mapping between the two.
parts = re.split(r"\*\*([^*]+)\*\*:", section)
says = {}
for lead, body in zip(parts[1::2], parts[2::2]):
    says.setdefault(re.split(r"[^a-z]", lead.lower())[0], set()).update(written(body))
count = sum(len(v) for v in says.values())
if count < 8:
    print(f"only {count} shapes parsed out of '### The marks', and it writes 8: "
          f"the spelling changed; fix this regex with it")
    sys.exit(1)

files = [f for d in adirs for f in sorted(glob.glob(f"{d}/*.svg"))
         if not os.path.basename(f).startswith("hausfold-")]
if not files:
    print(f"no mark SVGs found in {adirs}; this test has lost its subject")
    sys.exit(1)
# Every variant of a mark is the same drawing — inverted and latte recolour
# it, the iOS icon insets it — so each file answers for the whole stanza, and
# a shape dropped from one variant alone is as red as one dropped from all.
bad, named = [], set()
for f in files:
    base = os.path.basename(f)
    product = base.split("-")[0]
    named.add(product)
    said, mine = says.get(product, set()), drawn(open(f).read())
    bad += [f"{base} draws {phrase(s)}, which {product}'s stanza does not write out"
            for s in sorted(mine - said)]
    bad += [f"{base} does not draw {phrase(s)}, which {product}'s stanza writes out"
            for s in sorted(said - mine)]
for product, said in sorted(says.items()):
    if said and product not in named:
        bad.append(f"design.md's {product} stanza writes shapes and no mark SVG "
                   f"here is named for it: the house's two squares are exempt by "
                   f"name, so anything else is the lead or the filenames moving")
if bad:
    print("a shape that design.md and the mark SVGs spell differently:")
    for b in bad:
        print("  " + b)
    if any(s[0] == "rect" and s[5] == "0" for v in says.values() for s in v):
        print("A rect the doc leaves at rx 0 takes its radius from the next "
              "trailing `(rx …)`, so check where that parenthetical sits.")
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "every fill in a mark SVG is the role design.md gives that shape" {
  assert_every_mark_present
  run python3 - "$DOC" "$palette_dir" "$WORKSHOP/assets" "$marks_dir" <<'PY'
import glob, json, math, os, re, sys, xml.etree.ElementTree as ET
doc, pdir, adirs = sys.argv[1], sys.argv[2], sys.argv[3:]
# The two tests above read the marks' geometry and stop, which is why a mark
# could be redrawn in the wrong greys and pass every check in this file: the
# colour test asks only whether a hex is SOME nebelung token and not another
# product's accent, never whether it is the token *The marks* names for that
# shape. This is that seam. Each stanza writes the role beside the shape — `in
# `surface1``, `peach`, `yellow` — and *The tile* says where a role lands on
# each of the three variants, so the expected fill is one lookup per shape.
#
# The variants are not a rename. A light tile keeps each shape's POSITION in
# the ramp: its ground is latte `base`, not latte `surface0`, because latte
# runs the other way. An inverted tile recolours by rule rather than by token:
# the ground takes the hue, the ears and the story shapes go `surface0` (or
# `crust` under a tagline), and the doc's two exceptions both turn on one
# question — what a shape sits ON. A small accent on a gray shape keeps the
# product colour; a whole story shape drawn in the hue does not. A gray over
# another inverted shape steps darker to `mantle` and dims, because `surface0`
# at 0.45 over `surface0` is `surface0`. Both read here as containment in an
# EARLIER shape whose standard role is a neutral, which is what "on a gray
# shape" and "over another inverted shape" describe; a shape only half over
# another is neither, and the doc does not rule on it.
#
# Bounding boxes are the geometry, and every one of them is a hull rather than
# the shape: axis-aligned around a rotated rect's corners (perch's two cards
# are both rotated), and around a path's control points, which is wider than
# the curve. That is why containment and not overlap decides — nebelung's fog
# and its ears overlap as hulls and touch nowhere as drawings. Whether a gray sitting on the
# ground dims at all stays the drawing's call (perch's back card does, pounce's
# prompt bar does not); only what it dims TO is a rule. The house's two squares
# are exempt, as above.
SVGNS = "{http://www.w3.org/2000/svg}"
text = open(doc).read()

def section(head):
    m = re.search(rf"^### {re.escape(head)}\n(.*?)(?=^#{{2,3}} )", text, re.S | re.M)
    return m.group(1) if m else ""

def num(v):
    return f"{float(v):g}"

ramps = {n: {k: v.lower() for k, v in json.load(open(f"{pdir}/{f}")).items()}
         for n, f in (("mocha", "nebelung.hex.json"), ("latte", "nebelung-latte.hex.json"))}
NEUTRAL = {"text", "subtext1", "subtext0", "overlay2", "overlay1", "overlay0",
           "surface2", "surface1", "surface0", "base", "mantle", "crust"}
ACCENT = sorted(set(ramps["mocha"]) - NEUTRAL)
# Three things the doc has to keep saying for a role to resolve at all: which
# hue each product owns, which paths are the family ears, and how far a gray
# dims when it steps darker.
own = dict(re.findall(r"^\| ([a-z][a-z0-9.]*) \| product \| `--nebelung-([a-z0-9]+)` \|",
                      text, re.M))
ears_paths = {re.sub(r"\s+", " ", d).strip()
              for d in re.findall(r"^(M [\d .QLZ]*?Z)", section("The ears"), re.M)}
dims = re.search(r"gray dims to ([\d.]+)", section("The tile"))
if len(own) < 5 or len(ears_paths) != 2 or not dims:
    print("design.md's *Product colours* table, *The ears* paths or *The tile*'s dim "
          "step stopped parsing: every role here resolves through those three, so "
          "re-derive this test from wherever they went")
    sys.exit(1)
DIM = num(dims.group(1))

# ---- the role each stanza gives each shape -----------------------------
TOKEN = re.compile(
    r"\b(?P<ears>[Ee]ars)\b"
    r"|`(?P<path>M [^`]*?Z)`"
    r"|rect (?P<rx>-?[\d.]+),(?P<ry>-?[\d.]+) (?P<rw>-?[\d.]+)×(?P<rh>-?[\d.]+)"
    r"(?: rx (?P<rr>-?[\d.]+))?"
    r"|circle (?P<cx>-?[\d.]+),(?P<cy>-?[\d.]+) r (?P<cr>-?[\d.]+)"
    r"|\(rx (?P<setrx>-?[\d.]+)\)"
    r"|`(?P<neutral>" + "|".join(sorted(NEUTRAL)) + r")`"
    r"|\b(?P<accent>" + "|".join(ACCENT) + r")\b"
    r"|@ (?P<alpha>\d+(?:\.\d+)?)")

def roles(body):
    """Every shape a stanza names, as key -> (role, alpha it is drawn at).

    A role falls on every shape still waiting for one, so `rect … and rect …
    (rx 2.5) in `surface2`` colours both lines; an `@ 0.45` falls on the run
    the role just closed. A stanza writes its standard drawing first and its
    inverted and latte exceptions after, in prose that names shapes rather
    than spelling them out, so the FIRST role a shape is given is the one
    kept and the exception sentences colour nothing.
    """
    entries, pending, rx_pending, last = [], [], [], []
    for m in TOKEN.finditer(body):
        if m.group("setrx") is not None:
            for e in rx_pending:
                e[0][5] = num(m.group("setrx"))
            rx_pending = []
        elif m.group("neutral") or m.group("accent"):
            for e in pending:
                e[1] = m.group("neutral") or m.group("accent")
            last, pending = pending, []
        elif m.group("alpha") is not None:
            for e in last:
                if e[2] is None:
                    e[2] = num(m.group("alpha"))
        else:
            if m.group("ears"):
                key = ["ears"]
            elif m.group("path"):
                key = ["path", re.sub(r"\s+", " ", m.group("path")).strip()]
            elif m.group("rx") is not None:
                key = ["rect"] + [num(m.group(g)) for g in ("rx", "ry", "rw", "rh")]
                key.append(num(m.group("rr") or 0))
            else:
                key = ["circle"] + [num(m.group(g)) for g in ("cx", "cy", "cr")]
            entries.append([key, None, None])
            pending.append(entries[-1])
            if m.group("rx") is not None and m.group("rr") is None:
                rx_pending.append(entries[-1])
    out = {}
    for key, role, alpha in entries:
        if role:
            out.setdefault(tuple(key), (role, alpha))
    return out

parts = re.split(r"\*\*([^*]+)\*\*:", re.sub(r"\s+", " ", section("The marks")))
says = {}
for lead, body in zip(parts[1::2], parts[2::2]):
    product = re.split(r"[^a-z]", lead.lower())[0]
    for k, v in roles(body).items():
        says.setdefault(product, {}).setdefault(k, v)
count = sum(len(v) for v in says.values())
if count < 14:
    print(f"only {count} shape→role pairs parsed out of '### The marks', and it "
          f"writes 14: the spelling changed; fix this regex with it")
    sys.exit(1)

# ---- what a mark actually paints, in paint order -----------------------
def mul(m, n):
    a, b, c, d, e, f = m
    A, B, C, D, E, F = n
    return (a*A + c*B, b*A + d*B, a*C + c*D, b*C + d*D, a*E + c*F + e, b*E + d*F + f)

def ctm_of(s):
    m = (1, 0, 0, 1, 0, 0)
    for name, args in re.findall(r"(translate|scale|rotate|matrix)\(([^)]*)\)", s or ""):
        v = [float(x) for x in re.split(r"[ ,]+", args.strip()) if x]
        if name == "translate":
            m = mul(m, (1, 0, 0, 1, v[0], v[1] if len(v) > 1 else 0))
        elif name == "scale":
            m = mul(m, (v[0], 0, 0, v[1] if len(v) > 1 else v[0], 0, 0))
        elif name == "rotate":
            r = math.radians(v[0])
            rot = (math.cos(r), math.sin(r), -math.sin(r), math.cos(r), 0, 0)
            m = mul(mul(mul(m, (1, 0, 0, 1, v[1], v[2])), rot), (1, 0, 0, 1, -v[1], -v[2])) \
                if len(v) == 3 else mul(m, rot)
        else:
            m = mul(m, tuple(v))
    return m

def box(m, pts):
    xs, ys = zip(*[(m[0]*x + m[2]*y + m[4], m[1]*x + m[3]*y + m[5]) for x, y in pts])
    return (min(xs), min(ys), max(xs), max(ys))

# A mark is drawn out of three primitives and nothing else. The list is a
# census, so it is written as one: anything that is not a container and not on
# it raises rather than being walked past, because an element this test never
# opens is a fill that NOTHING in this file checks — test 4 sees a legal token,
# test 5 reads only `d`, `transform` and `opacity`, and test 6 reads only rects
# and circles. An `<ellipse>` would ship a whole undocumented shape into a mark
# with every test green, which is docs/drift.md row 33 in the test that claims
# to read every fill. Widening the vocabulary is a decision for *What makes a
# mark quiet* first and this census second.
SHAPES = ("rect", "circle", "path")
CONTAINERS = ("svg", "g", "defs", "title", "desc", "metadata")

def painted(path):
    """Every filled element of a mark, in paint order, with its fill and its
    opacity resolved down the groups and its box in the tile's own 100-unit
    coordinates."""
    out = []

    def walk(el, ctm, fill, alpha):
        tag = el.tag.replace(SVGNS, "")
        if tag == "clipPath":  # the clip is the geometry test's, and paints nothing
            return
        ctm = mul(ctm, ctm_of(el.get("transform")))
        fill = (el.get("fill") or fill or "").lower()
        # a group's opacity dims everything under it, so a stanza's alpha is the
        # product down the tree: `<g opacity="0.7">` around the ears is the same
        # edit as putting it on each ear path, and has to read the same here
        alpha = alpha * float(el.get("opacity", 1))
        a = el.attrib
        if tag == "rect":
            key = ("rect",) + tuple(num(a.get(k, "0"))
                                    for k in ("x", "y", "width", "height", "rx"))
            x, y, w, h = (float(a.get(k, 0)) for k in ("x", "y", "width", "height"))
            pts, d = [(x, y), (x + w, y), (x + w, y + h), (x, y + h)], None
        elif tag == "circle":
            key = ("circle",) + tuple(num(a.get(k, "0")) for k in ("cx", "cy", "r"))
            cx, cy, r = (float(a.get(k, 0)) for k in ("cx", "cy", "r"))
            pts = [(cx - r, cy - r), (cx + r, cy - r), (cx + r, cy + r), (cx - r, cy + r)]
            d = None
        elif tag == "path":
            d = re.sub(r"\s+", " ", a["d"]).strip()
            key = ("ears",) if d in ears_paths else ("path", d)
            pts = [(float(x), float(y))
                   for x, y in re.findall(r"(-?[\d.]+)[ ,](-?[\d.]+)", d)]
        else:
            if tag not in CONTAINERS:
                raise ValueError(
                    f"<{tag}> is a shape no test in this file reads, so every fill it "
                    f"carries is unchecked: a mark is drawn in {', '.join(SHAPES)}, and "
                    f"widening that is *What makes a mark quiet*'s call before it is "
                    f"this census's")
            for kid in el:
                walk(kid, ctm, fill, alpha)
            return
        if not pts:
            raise ValueError(f"no coordinates in {tag} {key}")
        out.append({"key": key, "d": d, "fill": fill,
                    "alpha": num(alpha), "box": box(ctm, pts)})

    walk(ET.parse(path).getroot(), (1, 0, 0, 1, 0, 0), None, 1.0)
    return out

GROUND = ("rect", "0", "0", "100", "100", "0")

def name(k):
    if k == ("ears",):
        return "the ears"
    if k[0] == "path":
        return f"path `{k[1][:40]}…`"
    return f"{k[0]} {' '.join(k[1:])}"

def inside(inner, outer):
    return (outer[0] <= inner[0] and outer[1] <= inner[1]
            and inner[2] <= outer[2] and inner[3] <= outer[3])

files = [f for d in adirs for f in sorted(glob.glob(f"{d}/*.svg"))
         if not os.path.basename(f).startswith("hausfold-")]
if not files:
    print(f"no mark SVGs found in {adirs}; this test has lost its subject")
    sys.exit(1)

bad = []
for f in files:
    base = os.path.basename(f)
    product = base.split("-")[0]
    said = says.get(product, {})
    variant = ("inverted" if "-inverted" in base else
               "latte" if "-latte" in base else "standard")
    ramp = ramps["latte" if variant == "latte" else "mocha"]
    if product not in own:
        bad.append(f"{base} is a mark for {product}, which *Product colours* gives no "
                   f"hue of its own: a mark and a row land together")
        continue
    hue = ramp[own[product]]
    try:
        els = painted(f)
    except ValueError as e:
        bad.append(f"{base}: {e}")
        continue

    def sits_on_gray(el, drawn_before):
        for other in drawn_before:
            if other["key"] != GROUND and said.get(other["key"], ("",))[0] in NEUTRAL \
                    and inside(el["box"], other["box"]):
                return True
        return False

    drew = set()
    for i, el in enumerate(els):
        got, alpha, what = el["fill"], el["alpha"], name(el["key"])
        # no `fill` of its own and none down the groups: SVG paints that black
        got = got or "unfilled, which SVG paints black"
        if el["key"] == GROUND:
            want = {"standard": ramp["surface0"], "latte": ramp["base"],
                    "inverted": hue}[variant]
            if got != f"#{want}":
                bad.append(f"{base}: the tile ground is {got}, and *The tile* grounds "
                           f"{'an' if variant == 'inverted' else 'a'} {variant} tile "
                           f"in #{want}")
            continue
        drew.add(el["key"])
        if el["key"] not in said:
            bad.append(f"{base}: {what} is painted {got}, and {product}'s stanza gives "
                       f"it no colour role")
            continue
        role, said_alpha = said[el["key"]]
        if variant != "inverted":
            if role in NEUTRAL and role not in ("surface1", "surface2"):
                bad.append(f"{base}: {what} is drawn in `{role}`, and *The tile* only "
                           f"places surface1 and surface2 on a {variant} tile: say "
                           f"where this one lands before a mark spends it")
                continue
            if got != f"#{ramp[role]}":
                bad.append(f"{base}: {what} is {got}, and {product}'s stanza draws it in "
                           f"{role} — #{ramp[role]} in the "
                           f"{'latte' if variant == 'latte' else 'mocha'} set")
            if alpha != (said_alpha or "1"):
                bad.append(f"{base}: {what} is at opacity {alpha}, and its stanza draws "
                           f"it at {said_alpha or 'no alpha'}")
            continue
        # Whether a gray on an inverted tile dims is the drawing's call, but the
        # bullet gives one step to dim BY, so a shape at any other alpha is a
        # number nothing in the doc supports.
        if alpha not in ("1", DIM):
            bad.append(f"{base}: {what} is at opacity {alpha}, and the one step an "
                       f"inverted tile dims by is {DIM}")
        on_gray = sits_on_gray(el, els[:i])
        if role in NEUTRAL and on_gray:
            ok = {f"#{ramp['mantle']}"}
            why = "`mantle`, because a gray over another inverted shape steps darker"
            if alpha != DIM:
                bad.append(f"{base}: {what} is at opacity {alpha}, and a gray over "
                           f"another inverted shape dims to {DIM}")
        elif role in NEUTRAL or not on_gray:
            # `crust` is the other half of that bullet and belongs to a banner
            # carrying a tagline (*Lockups*); every file this test opens is a
            # tile, where crust is two rungs too dark rather than a second
            # reading. A banner SVG landing in PRODUCT_MARKS reddens here, which
            # is the right place to decide it.
            ok = {f"#{ramp['surface0']}"}
            why = ("`surface0` — the `crust` half of that bullet is a banner "
                   "carrying a tagline, and this is a tile")
        else:
            ok = {f"#{hue}"}
            why = f"{role}, because a small accent on a gray shape keeps the product colour"
        if got not in ok:
            bad.append(f"{base}: {what} is {got}, and an inverted tile makes it {why}")
    if GROUND not in {e["key"] for e in els}:
        bad.append(f"{base}: paints no 100×100 tile ground, so there is nothing for "
                   f"*The tile*'s ground rule to be true of")
    for k in sorted(said.keys() - drew):
        bad.append(f"{base}: does not paint {name(k)}, which {product}'s stanza colours")
    # Both ears carry one role and so collapse to one key above; *The ears* says
    # the two paths are used verbatim in every product mark, which is a count.
    if ("ears",) in said:
        for d in sorted(ears_paths - {e["d"] for e in els}):
            bad.append(f"{base}: draws no ear path `{d[:40]}…`, and *The ears* uses "
                       f"both verbatim in every product mark")

if bad:
    print("a fill a mark SVG and design.md disagree about:")
    for b in dict.fromkeys(bad):
        print("  " + b)
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "a mark SVG is drawn in one nebelung set, the one its name claims" {
  assert_every_mark_present
  run python3 - "$palette_dir" "$WORKSHOP/assets" "$marks_dir" <<'PY'
import glob, json, os, re, sys
pdir, adirs = sys.argv[1], sys.argv[2:]
# *The tile*'s light bullet ends "One drawing holds one set: never latte with
# paper, and never latte with mocha". This is the latte-with-mocha half, which
# the colour test above cannot reach: it unions both ramps and asks only
# whether a hex is in the union, so a mocha grey under a latte accent satisfies
# it twice over. The latte-with-paper half needs no test — paper is in neither
# ramp, so the colour test already refuses it. The set a file is drawn in is
# not in the file, so the filename is what claims it: a `-latte` mark is the
# light tile, everything else is mocha.
ramps = {n: {v.lower() for v in json.load(open(f"{pdir}/{f}")).values()}
         for n, f in (("mocha", "nebelung.hex.json"), ("latte", "nebelung-latte.hex.json"))}
# The two ramps share one value (mocha overlay0 is latte subtext0), so a fill
# can be evidence for neither side. No mark can be drawn only in that one value
# while every mark carries an accent, and no accent is shared — so the second
# arm below is a floor under a drawing that could claim a set by its name
# alone, not coverage of anything a mark does today.
files = [f for d in adirs for f in sorted(glob.glob(f"{d}/*.svg"))
         # The house's light square is drawn in hausfold.co's paper and light
         # accents rather than in latte — *The house* says so — and both its
         # squares spend ninety interpolated wedges that are in no ramp.
         if not os.path.basename(f).startswith("hausfold-")]
if not files:
    print(f"no mark SVGs found in {adirs}; this test has lost its subject")
    sys.exit(1)
bad = []
for f in files:
    base = os.path.basename(f)
    claimed = "latte" if "-latte" in base else "mocha"
    other = "mocha" if claimed == "latte" else "latte"
    fills = {h.lower() for h in re.findall(r'fill="#([0-9a-fA-F]{6})"', open(f).read())}
    foreign = sorted(h for h in fills if h in ramps[other] and h not in ramps[claimed])
    if foreign:
        bad.append(f"{base} is the {claimed} drawing and spends "
                   f"{', '.join('#' + h for h in foreign)} out of the {other} set")
    elif not any(h in ramps[claimed] and h not in ramps[other] for h in fills):
        bad.append(f"{base} is the {claimed} drawing and spends no colour that only "
                   f"the {claimed} set has, so nothing here says which set it is in")
if bad:
    print("a mark SVG that does not hold one nebelung set:")
    for b in bad:
        print("  " + b)
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "the media kit's colour table matches nebelung's mocha palette" {
  run python3 - "$KIT" "$palette_dir" <<'PY'
import json, re, sys
doc, pdir = sys.argv[1], sys.argv[2]
mocha = {k: v.lower() for k, v in json.load(open(f"{pdir}/nebelung.hex.json")).items()}
text = open(doc).read()
pairs = re.findall(r"`([a-z0-9]+)`\s*\|\s*`#([0-9a-fA-F]{6})`", text)
if len(pairs) < 12:
    print(f"only {len(pairs)} token|hex pairs parsed — the kit's colour table changed shape; fix this regex with it")
    sys.exit(1)
bad = [(n, h) for n, h in pairs if mocha.get(n) != h.lower()]
if bad:
    for n, h in bad:
        print(f"{n}: assets/README.md says #{h}, nebelung says #{mocha.get(n, '<no such token>')}")
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "design.md's named token hexes match nebelung's mocha palette" {
  run python3 - "$DOC" "$palette_dir" <<'PY'
import json, re, sys
doc, pdir = sys.argv[1], sys.argv[2]
mocha = {k: v.lower() for k, v in json.load(open(f"{pdir}/nebelung.hex.json")).items()}
text = open(doc).read()
pairs = re.findall(r"`--nebelung-([a-z0-9]+)`\s*\|\s*`#([0-9a-fA-F]{6})`", text)
if len(pairs) < 26:
    print(f"only {len(pairs)} token|hex pairs parsed — the colour table's shape changed; fix this regex with it")
    sys.exit(1)
bad = [(n, h) for n, h in pairs if mocha.get(n) != h.lower()]
if bad:
    for n, h in bad:
        print(f"--nebelung-{n}: design.md says #{h}, nebelung says #{mocha.get(n, '<no such token>')}")
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "the latte citations in design.md and the media kit match nebelung's latte palette" {
  run python3 - "$palette_dir" "$DOC" "$KIT" <<'PYEOF'
import json, os, re, sys
pdir, files = sys.argv[1], sys.argv[2:]
latte = {k: v.lower() for k, v in json.load(open(f"{pdir}/nebelung-latte.hex.json")).items()}
bad = []
# Both write the light tile's colours out as "latte <token> `#hex`", and both
# have to say what nebelung says. The floor is the count each one carries: a
# citation that stops parsing is the spelling drifting, not a hex going right.
for f, floor in zip(files, (9, 9)):
    name = os.path.basename(f)
    pairs = re.findall(r"latte\s+([a-z0-9]+)\s+`#([0-9a-fA-F]{6})`", open(f).read())
    if len(pairs) < floor:
        bad.append(f"only {len(pairs)} latte citations parsed out of {name}, and it "
                   f"carries {floor}: the latte spelling changed; fix this regex with it")
        continue
    bad += [f"latte {n}: {name} says #{h}, nebelung says #{latte.get(n, '<no such token>')}"
            for n, h in pairs if latte.get(n) != h.lower()]
if bad:
    print("\n".join(bad))
    sys.exit(1)
PYEOF
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "design.md's page register matches hausfold.co's stylesheets" {
  run python3 - "$DOC" "$palette_dir" <<'PY'
import sys
doc, pdir = sys.argv[1], sys.argv[2]
text = open(doc).read()
site = open(f"{pdir}/hausfold.css").read()
docs = open(f"{pdir}/global.css").read()
# (what the doc says, the literal the stylesheet must still carry, which sheet)
claims = [
    ("41rem", "--measure: 41rem;", site),
    ("78rem", "--page-max: 78rem;", site),
    ("clamp(1.4rem, 5vw, 2rem)", "--gutter: clamp(1.4rem, 5vw, 2rem);", site),
    ("clamp(3.5rem, 9vw, 7.5rem)", "clamp(3.5rem, 9vw, 7.5rem)", site),
    ("clamp(2.5rem, 6vw, 4rem)", "clamp(2.5rem, 6vw, 4rem)", site),
    ("clamp(3rem, 7vw, 4.75rem)", "gap: clamp(3rem, 7vw, 4.75rem);", site),
    ("clamp(0.94rem, 0.9rem + 0.2vw, 1.02rem)", "--step: clamp(0.94rem, 0.9rem + 0.2vw, 1.02rem);", site),
    ("/ 1.62", "line-height: 1.62;", site),
    ("clamp(1.28rem, 4vw, 1.72rem)", "font-size: clamp(1.28rem, 4vw, 1.72rem);", site),
    ("/ 1.32", "line-height: 1.32;", site),
    ("−0.014em", "letter-spacing: -0.014em;", site),
    ("22ch", "max-width: 22ch;", site),
    ("clamp(1.5rem, 5vw, 1.95rem)", "font-size: clamp(1.5rem, 5vw, 1.95rem);", site),
    ("+0.02em", "letter-spacing: 0.02em;", site),
    ("clamp(3.4rem, 11vw, 5rem)", "font-size: clamp(3.4rem, 11vw, 5rem);", site),
    ("/ 0.9", "line-height: 0.9;", site),
    ("SF Mono 300", "font-weight: 300;", site),
    ("0.72rem / +0.16em", "letter-spacing: 0.16em;", site),
    ("0.82rem / 1.6", "font-size: 0.82rem;", site),
    ("radius 3", "border-radius: 3px;", site),
    ("radius 2", "border-radius: 2px;", site),
    ("0.7s", "transition: opacity 0.7s ease;", site),
    ("prose 62ch", "max-width: 62ch;", site),
    ("58ch", "max-width: 58ch;", site),
    ("0.72rem", "gap: 0.72rem;", site),
    ("1.05rem", "gap: 1.05rem;", site),
    ("1.6rem", "gap: 1.6rem;", site),
    ("30rem", "@media (max-width: 30rem)", site),
    ("0.7rem, +0.1em", "letter-spacing: 0.1em;", site),
    ("0.85rem 1rem", "padding: 0.85rem 1rem;", site),
    ("0.25em", "text-underline-offset: 0.25em;", site),
    ("2px | a page's copy button", "--radius-sm: 2px;", docs),
    ("4 to 6px", "--radius-2xl: 6px;", docs),
    ("wash at 7%", "var(--accent) 7%", docs),
    ("line at 55%", "var(--accent) 55%", docs),
    ("quiet at 50%", "var(--accent) 50%", docs),
    ("clamp(0.98rem, 0.94rem + 0.22vw, 1.06rem)", "clamp(0.98rem, 0.94rem + 0.22vw, 1.06rem)", docs),
    ("/ 1.7", "line-height: 1.7;", docs),
    ("2.25rem", "2.25rem", docs),
    ("hacker pink for error", "--color-fd-error: var(--a-hacker);", docs),
    ("perch green for success", "--color-fd-success: var(--a-perch);", docs),
    ("trill yellow for warning", "--color-fd-warning: var(--a-trill);", docs),
]
bad = []
for said, literal, sheet in claims:
    if said not in text:
        bad.append(f"design.md no longer says {said!r}: update this test's table with the doc")
    elif literal not in sheet:
        bad.append(f"design.md says {said!r} but hausfold.co's stylesheet has no {literal!r}: re-vendor the doc")
if bad:
    print("\n".join(bad))
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "design.md's clearspace ratios are what its own lockups measure" {
  run python3 - "$DOC" <<'PY'
import re, sys
text = open(sys.argv[1]).read()

def section(head):
    m = re.search(rf"^### {re.escape(head)}\n(.*?)(?=^### )", text, re.S | re.M)
    return m.group(1) if m else ""

locks = section("Lockups")
stanza = section("Clearspace and minimum sizes")
flat = re.sub(r"\s+", " ", stanza)  # the stanza rewraps; the sentence is one line
if not locks or not stanza:
    print("design.md lost '### Lockups' or '### Clearspace and minimum sizes': "
          "the clearspace rule is derived from the first, so re-derive it")
    sys.exit(1)

def bullet(name):
    m = re.search(rf"^- \*\*{re.escape(name)}\*\*(.*?)(?=^- \*\*|\Z)", locks, re.S | re.M)
    return m.group(1) if m else ""

def edges(name, b, mark):
    """Every other clearance the bullet states, as (what it is, px)."""
    out, pad = [], re.search(r"padding `?(?:(\d+) )?(\d+)`?", b)
    if pad:
        out.append(("its padding", int(pad.group(2))))
    if name == "Banner":
        h = re.search(r"^: \d+×(\d+)", b)
        if h:  # the mark is centred in the height, not held off it by padding
            out.append(("the air above and below it", (int(h.group(1)) - mark) / 2))
    return out

# (the lockup, how it names its mark, how it names its tightest neighbour,
#  the noun the stanza uses for that mark)
LOCKUPS = [
    ("Banner",       r"mark (\d+)×", r"gap (\d+)",                        "mark"),
    ("Family strip", r"at (\d+)×",   r"gap (\d+)",                        "tiles"),
    ("OG card",      r"tile (\d+)×", r"×\d+, (\d+) from the text column", "tile"),
]

bad = []
for name, mark_re, near_re, noun in LOCKUPS:
    b = bullet(name)
    m, n = re.search(mark_re, b), re.search(near_re, b)
    if not (m and n):
        bad.append(f"can't read {name}'s mark size or its tightest neighbour out of "
                   f"design.md any more: the bullet moved, so re-derive its ratio")
        continue
    mark, near = int(m.group(1)), int(n.group(1))
    floor = 0.2 * mark
    ratio = near / mark
    if ratio < 0.2:
        bad.append(f"{name} clears only {ratio:.3f}× its {mark}px mark, under the 0.2× "
                   f"floor the stanza sets: the lockup or the floor has to move")
    said = f"{ratio:.3f}× its {mark}px {noun}"
    if said not in flat:
        bad.append(f"{name} now measures {said!r}, which the clearspace stanza "
                   f"doesn't say: re-vendor the sentence from the lockup")
    for what, px in edges(name, b, mark):
        if px < floor:
            bad.append(f"{name} leaves {px:g}px for {what}, under the {floor:g}px floor "
                       f"its {mark}px mark asks for: the lockup or the floor has to move")
if bad:
    print("\n".join(bad))
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "design.md's minimum sizes are the arithmetic its own geometry gives" {
  run python3 - "$DOC" <<'PY'
import re, sys
text = open(sys.argv[1]).read()

def section(head):
    m = re.search(rf"^### {re.escape(head)}\n(.*?)(?=^### )", text, re.S | re.M)
    return m.group(1) if m else ""

def wall(half):
    """A house's wall thickness: how far its inner path sits inside its outer."""
    out = re.search(r"`(M50 [^`]+Z)`\s*\n?\s*outside", half)
    inn = re.search(r"`(M50 [^`]+Z)`\s*\n?\s*inside", half)
    if not (out and inn):
        return None
    left = lambda p: min(float(x) for x in re.findall(r"L([\d.]+) ", p))
    return round(left(inn.group(1)) - left(out.group(1)), 2)

house = section("The house")
favicon_half, _, padded_half = house.partition("The padded square")
marks = section("The marks")
stanza = section("Clearspace and minimum sizes")
rows = {int(m.group(1)): m.group(0)
        for m in re.finditer(r"^\| \*\*(\d+)px\*\* \|.*$", stanza, re.M)}
caret = re.search(r"caret `rect [\d.,]+ ([\d.]+)×", marks)
line1 = re.search(r"text lines `rect 36,(\d+) 38×(\d+)`", marks)
line2 = re.search(r"`rect 36,(\d+) 26×\d+`", marks)

# (what the raster has to hold, its width in the 100-unit box, the row it sets)
INK = [
    ("the favicon's walls", wall(favicon_half), 16),
    ("walls",               wall(padded_half),  24),
    ("pounce's caret",      float(caret.group(1)) if caret else None, 32),
]
if not (rows and line1 and line2) or any(u is None for _, u, _ in INK):
    print("design.md's house paths, pounce's caret, trill's text lines or the "
          "minimum-size table moved: re-derive the table from the new geometry")
    sys.exit(1)

bad = []
for name, units, size in INK:
    said = f"{units:g} units → {units * size / 100:.2f}px"
    row = rows.get(size, "")
    if name not in row or said not in row:
        bad.append(f"the {size}px row should name {name} and read {said!r}: that "
                   f"is what the geometry above it now gives")
gap = int(line2.group(1)) - (int(line1.group(1)) + int(line1.group(2)))
if f"{gap}-unit gap" not in rows.get(32, ""):
    bad.append(f"trill's text lines are now {gap} units apart, which the 32px row "
               f"doesn't say")
if bad:
    print("\n".join(bad))
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}

@test "the media kit's short version matches design.md" {
  run python3 - "$DOC" "$KIT" <<'PY'
import re, sys
doc, kit = open(sys.argv[1]).read(), open(sys.argv[2]).read()
stanza = re.search(r"^### Clearspace and minimum sizes\n(.*?)(?=^### )", doc, re.S | re.M)
clear = re.search(r"^- \*\*Clearspace:.*?(?=^- \*\*)", kit, re.S | re.M)
floors = re.search(r"^- \*\*Minimum size:.*?(?=^\n)", kit, re.S | re.M)
if not (stanza and clear and floors):
    print("design.md's clearspace stanza or the media kit's short version of it "
          "moved: the kit vendors those numbers, so re-vendor them")
    sys.exit(1)
stanza = re.sub(r"\s+", " ", stanza.group(1))
rasters = set(re.findall(r"\| \*\*(\d+)px\*\* \|", doc))

# The kit states the rule in fewer words. Every ratio it quotes has to be one
# the stanza measures, and every floor one the stanza's table defines.
bad = []
for ratio in sorted(set(re.findall(r"\d[\d.]*×", clear.group(0)))):
    if ratio not in stanza:
        bad.append(f"the media kit says {ratio!r}, which design.md's clearspace "
                   f"stanza doesn't: the doc is the standard, so re-vendor the kit")
for floor in sorted(set(re.findall(r"(\d+)px", floors.group(0)))):
    if floor not in rasters:
        bad.append(f"the media kit sets a {floor}px floor, which design.md's "
                   f"minimum-size table has no row for: re-vendor the kit")
if bad:
    print("\n".join(bad))
    sys.exit(1)
PY
  [ "$status" -eq 0 ] || { echo "$output"; false; }
}
