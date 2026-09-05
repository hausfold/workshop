#!/usr/bin/env bats
# docs/design.md vendors nebelung hexes and hausfold.co's page numbers, and
# AGENTS.md's rule is that nothing is inlined without a drift test — this is
# that test. Every hex in the doc is diffed back against nebelung's
# palette/*.hex.json, and every literal the page register quotes (measure,
# gutter, rhythm, faces, radii, accent steps) back against hausfold.co's
# public/hausfold.css and src/app/global.css: the checkout beside the
# workshop's main checkout when there is one, else GitHub raw (both repos
# are public), so it runs on a dev machine and in CI alike. When it reddens,
# the upstream moved: re-vendor the doc's values, never the other way around.

palette_dir=""

setup() {
  WORKSHOP="$(cd "$(dirname "$BATS_TEST_FILENAME")/.." && pwd)"
  DOC="$WORKSHOP/docs/design.md"
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
