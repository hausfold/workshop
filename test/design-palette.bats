#!/usr/bin/env bats
# docs/design.md vendors nebelung hexes, and AGENTS.md's rule is that a
# palette is never inlined without a drift test — this is that test. Every
# hex in the doc is diffed back against nebelung's palette/*.hex.json: the
# checkout beside the workshop's main checkout when there is one, else
# GitHub raw (the repo is public), so it runs on a dev machine and in CI
# alike. When it reddens, nebelung moved: re-vendor the doc's values, never
# the other way around.

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
