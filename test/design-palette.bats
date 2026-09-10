#!/usr/bin/env bats
# docs/design.md, assets/README.md (the media kit) and the mark SVGs — the two
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

# The product marks that live in their own repos. The two nebelung tiles are in
# this repo's assets/ and need no fetching.
PRODUCT_MARKS=(
  pounce/pounce-square
  pounce/pounce-square-inverted
  perch/perch-square
  perch/perch-square-inverted
  perch/perch-icon-ios
  trill/trill-icon-master
  trill/trill-square-inverted
)

setup() {
  WORKSHOP="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  DOC="$WORKSHOP/docs/design.md"
  KIT="$WORKSHOP/assets/README.md"
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
  # Set for the two tests that read marks; the other six do not, and a mark
  # they never open must not decide their outcome.
  MARKS_MISSING=""
  local mark repo repo_dir resolved=0
  for mark in "${PRODUCT_MARKS[@]}"; do
    repo="${mark%%/*}"
    f="${mark##*/}.svg"
    repo_dir=""
    [ -n "$common" ] && repo_dir="$(dirname "$common")/$repo/assets"
    # A checkout is re-read every time: BATS_TMPDIR outlives the run, and a
    # cached copy would keep this green through the very edit it exists to
    # catch. Only the download is cached, and only against the eight setups
    # one `bats` invocation of this file runs. A checkout that is here answers
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
  # file that is on no upstream `main` yet — the two mark tests fail for it,
  # loudly, and the other six still run. Skipping instead would blank all eight,
  # this diff's own claims included; that is the shape docs/drift.md parks under
  # "Seen once", and a note is not a gate. The only skip left is the machine
  # that can reach NOTHING: no sibling checkouts and no network.
  [ "$resolved" -gt 0 ] || skip "no mark SVG is reachable: no sibling checkouts and no network"
}

# The two tests below open the marks; they refuse to pass on a partial set.
assert_every_mark_present() {
  [ -z "$MARKS_MISSING" ] || {
    echo "PRODUCT_MARKS names a mark that is in no sibling checkout and on no"
    echo "upstream main:$MARKS_MISSING"
    echo "Land the mark's own repo first, then bench pull, then this."
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
mocha = {k: v.lower() for k, v in json.load(open(f"{pdir}/nebelung.hex.json")).items()}
accents = {v for k, v in mocha.items() if k not in NEUTRAL}
own = {p: mocha[t] for p, t in
       (("nebelung", "mauve"), ("pounce", "peach"), ("perch", "green"),
        ("trill", "yellow"), ("scruff", "maroon"))}
bad = []
for f in files:
    base = os.path.basename(f)
    mine = own.get(base.split("-")[0])
    for h in sorted({h.lower() for h in re.findall(r"#([0-9a-fA-F]{6})\b", open(f).read())}):
        if h not in values:
            bad.append(f"{base}: #{h} is no nebelung token value")
        elif mine and h in accents and h != mine:
            bad.append(f"{base}: #{h} is another product's accent, not its own #{mine}")
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

@test "design.md's latte citations match nebelung's latte palette" {
  run python3 - "$DOC" "$palette_dir" <<'PY'
import json, re, sys
doc, pdir = sys.argv[1], sys.argv[2]
latte = {k: v.lower() for k, v in json.load(open(f"{pdir}/nebelung-latte.hex.json")).items()}
text = open(doc).read()
pairs = re.findall(r"latte\s+([a-z0-9]+)\s+`#([0-9a-fA-F]{6})`", text)
if len(pairs) < 5:
    print(f"only {len(pairs)} latte citations parsed — the latte spelling changed; fix this regex with it")
    sys.exit(1)
bad = [(n, h) for n, h in pairs if latte.get(n) != h.lower()]
if bad:
    for n, h in bad:
        print(f"latte {n}: design.md says #{h}, nebelung says #{latte.get(n, '<no such token>')}")
    sys.exit(1)
PY
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
