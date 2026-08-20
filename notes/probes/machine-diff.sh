#!/usr/bin/env bash
# machine-diff — what a consumer's own option tree can and cannot be asked.
#
# Evidence for ../rooms-desktops.md's Acquisition plan, step C: "what your
# machine becomes" if you selected a stranger's desktop. Steps A and B read the
# stranger's FILE; C is the first one that has to look at the reader's MACHINE,
# and the question it turns on is whether the module system will answer a
# leaf-by-leaf question about a machine cheaply, honestly and without writing
# anything. Eight rows, six of which the note had been reasoning about:
#
#   1. `highestPrio` IS THE ARBITRATION, and it is exposed on every option.
#      100 a plain definition · 900 the desktop seam · 1000 a room's mkDefault ·
#      1500 the declared default. So "will this desktop's value actually land?"
#      is one number per leaf, read off the module system rather than modelled.
#   2. A LIST AT A HIGHER PRIORITY IS REPLACED, NOT CONCATENATED. Lists merge
#      only among definitions at the SAME priority, so a host naming a list the
#      desktop also names drops the desktop's entries entirely, silently.
#   3. LOSING DEFINITIONS ARE INVISIBLE. `definitionsWithLocations` and `files`
#      carry only the winners, so what a leaf would REVERT to when the desktop
#      stops setting it cannot be read out of the current tree at all.
#   4. `files` AT PRIORITY 1500 NAMES THE DECLARATION, not a definition. Read as
#      "who set this", it accuses a module of setting an option nobody set.
#   5. A DYNAMIC `attrsOf` SUB-PATH HAS NO OPTION NODE. `haus.roster.slack.key`
#      is not reachable under `options`, so every leaf under a recursive
#      container can be compared by VALUE and not by priority.
#   6. `nix eval` ON A CONSUMER FLAKE WRITES ITS LOCK when the lock needs
#      changes. A command that promises to write nothing has to say so:
#      `--no-write-lock-file` computes one in memory, `--no-update-lock-file`
#      refuses instead.
#   7. A `--apply` EXPRESSION MAY NOT `import` AN ABSOLUTE PATH in pure mode, so
#      the query is inlined — which makes every path string taken from a
#      stranger's desktop an injection surface in the reader's own evaluation.
#   8. UNDER LAZY TREES A STORE PATH OUT OF AN EVALUATION IS A NAME, NOT A
#      LOCATION. Three evaluations of one pinned input give three different
#      `-source` paths and NONE of the three is on disk, while
#      `builtins.readFile` on one works INSIDE the evaluation that produced it.
#      So a diagnostic that prints one is telling a person to look somewhere
#      they cannot go, under a different name each time.
#
#   ./notes/probes/machine-diff.sh                    # rows 1-7, on synthetic modules
#   PROBE_CONSUMER=~/.config/nix PROBE_HOST=mbp \
#     ./notes/probes/machine-diff.sh                  # + rows 5 and 8 on a real machine
#
# Rows 1–4, 5 and 7 are the MODULE SYSTEM and need only nixpkgs' `lib`; 6 needs a
# flake and builds two throwaway ones in a temp dir. All of that runs anywhere
# nix does with flakes enabled, cloud container included. Row 5 is measured BOTH
# ways — on a synthetic container by default, and against a real machine's own
# `haus.roster.<app>.key` when a consumer is given — and row 8 needs the real
# consumer, so it is opt-in and skipped loudly without one.
#
# `lib` comes from $PROBE_LIB, or from the copy every haus machine already has
# in its system profile (modules/desktop-check.nix stages one for `haus show`).
# In a container with neither:
#   git clone --depth 1 --filter=blob:none --sparse https://github.com/NixOS/nixpkgs
#   cd nixpkgs && git sparse-checkout set lib     # 15 MB, seconds
#   PROBE_LIB=$PWD/lib ./notes/probes/machine-diff.sh
#
# ⚠️ Rows 1–8 are EVALUATOR and module-system behaviour, not haus's. Rerun on a
# Nix bump or a nixpkgs bump; row 8 in particular is a property of lazy trees,
# which is on by default in Determinate Nix and not in every Nix.

set -uo pipefail   # deliberately NOT -e: several commands here are run to fail

for dep in nix jq git; do
  command -v "$dep" >/dev/null || { echo "machine-diff: needs $dep on PATH" >&2; exit 2; }
done
printf 'nix: %s\n' "$(nix --version)"

lab="$(cd "$(mktemp -d)" && pwd -P)"   # physical, or restrict-eval and the
                                       # store comparisons below measure macOS
# `-e` is deliberately off up there, so an empty `lab` would turn every
# `"$lab/x"` below into an absolute path and write the lab into `/`.
[ -n "$lab" ] || { echo "machine-diff: could not make a temp dir" >&2; exit 2; }
trap 'rm -rf "$lab"' EXIT

# Rows 6 and 7 are `nix eval` over a flake. Without the experimental features
# they fail into a 2>/dev/null and print a plausible-looking wrong answer, which
# is the exact shape of failure the rest of this file is about.
flakes=1
nix flake metadata --help >/dev/null 2>&1 || flakes=""

hdr() { printf '\n\033[1m── %s\033[0m\n' "$*"; }
row() { printf '  %-34s %s\n' "$1" "$2"; }
# `%-34s` pads by BYTES, so a label with a multi-byte character in it lands
# short. The continuation rows are indented ASCII for exactly that reason —
# a `…` prefix cost two columns and made the table look ragged.
skip() { printf '  \033[38;5;179m⚠ skipped\033[0m — %s\n' "$*"; }

LIB="${PROBE_LIB:-}"
if [ -z "$LIB" ] && [ -d /run/current-system/sw/share/haus/desktop-check/lib ]; then
  # A haus machine ships nixpkgs' lib beside the desktop checker. Resolved
  # physically for the same reason `haus show` resolves it: /run is a symlink.
  LIB="$(cd /run/current-system/sw/share/haus/desktop-check/lib && pwd -P)"
fi

# ---- 1–4: the ladder, lists, and what the option tree will not tell you -------
hdr "1–4 · what one option node can be asked"
if [ -z "$LIB" ] || [ ! -d "$LIB" ]; then
  skip "no nixpkgs lib — set PROBE_LIB (see the header)"
else
  cat >"$lab/ladder.nix" <<'NIX'
# Takes the lib directory as a STRING rather than a path literal, so a
# $PROBE_LIB with a space in it is an argument rather than a parse error.
libPath:
let
  lib = import libPath;
  decl = { lib, ... }: {
    _file = "DECLARED-IN";
    options.demo.flag = lib.mkOption { type = lib.types.bool; default = false; };
    options.demo.list = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "DECLARED" ]; };
    options.demo.bag = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule { options.key = lib.mkOption { type = lib.types.nullOr lib.types.str; default = null; }; });
      default = { };
    };
  };
  # The three rungs haus documents, spelled the way each one arrives.
  room = { lib, ... }: { _file = "ROOM"; demo.flag = lib.mkDefault true; demo.list = lib.mkDefault [ "room" ]; };
  desktop = { lib, ... }: { _file = "DESKTOP"; demo.flag = lib.mkOverride 900 false; demo.list = lib.mkOverride 900 [ "desktop" ]; demo.bag.slack.key = lib.mkOverride 900 "s"; };
  host = { _file = "HOST"; demo.list = [ "host" ]; demo.bag.slack.key = "h"; };
  host2 = { _file = "HOST2"; demo.list = [ "host2" ]; };

  at = mods: p:
    let
      e = lib.evalModules { modules = [ decl ] ++ mods; };
      o = lib.getAttrFromPath (lib.splitString "." p) e.options;   # these all exist
    in
    {
      prio = o.highestPrio;
      value = o.value;
      files = o.files;
      # The list `files` is derived from, read directly so the claim about
      # losing definitions is about the thing it names.
      defs = map (d: d.file) o.definitionsWithLocations;
    };
  # The sub-path a recursive container's leaf actually is. Walked by hand and
  # NOT with `getAttrFromPath`, which `abort`s on a missing key — and `abort` is
  # not something `tryEval` catches, so the probe would die where the whole
  # point is that the attribute is absent.
  descend = node: ps:
    if ps == [ ] then node
    else if !(builtins.isAttrs node) then null
    else if !(node ? ${builtins.head ps}) then null
    else descend node.${builtins.head ps} (builtins.tail ps);
  sub = mods:
    let
      e = lib.evalModules { modules = [ decl ] ++ mods; };
      node = descend e.options [ "demo" "bag" "slack" "key" ];
    in
    {
      optionNode = node != null;
      configValue = e.config.demo.bag.slack.key;
    };
in
{
  declaredOnly = at [ ] "demo.flag";
  roomOnly = at [ room ] "demo.flag";
  roomThenDesktop = at [ room desktop ] "demo.flag";
  hostWins = at [ room desktop host ] "demo.list";
  desktopList = at [ room desktop ] "demo.list";
  twoPlainLists = at [ host host2 ] "demo.list";
  dynamicKey = sub [ room desktop host ];
}
NIX
  out="$(nix eval --impure --json --expr "import \"$lab/ladder.nix\" \"$LIB\"" 2>&1)"
  if ! printf '%s' "$out" | jq -e . >/dev/null 2>&1; then
    printf '%s\n' "$out" | tail -5
  else
    j() { printf '%s' "$out" | jq -r "$1"; }
    row "declared, nobody defines it" "highestPrio $(j .declaredOnly.prio) · files $(j '.declaredOnly.files | join(",")')"
    row "a room's mkDefault" "highestPrio $(j .roomOnly.prio) · value $(j .roomOnly.value)"
    row "the desktop seam over it" "highestPrio $(j .roomThenDesktop.prio) · value $(j .roomThenDesktop.value)"
    row "a plain host line over both" "highestPrio $(j .hostWins.prio) · value $(j '.hostWins.value | join(",")')"
    row "  its list entries" "$(j '.desktopList.value | join(",")') → $(j '.hostWins.value | join(",")')  (REPLACED, not merged)"
    row "two definitions, same priority" "$(j '.twoPlainLists.value | join(",")')  (that is when a list concatenates)"
    row "definitionsWithLocations" "$(j '.hostWins.defs | join(",")')  ← losers are gone, not merely unranked"
    row "1500 rung's 'files'" "$(j '.declaredOnly.files | join(",")')  ← the DECLARATION, not a definition"
    row "options.<bag>.slack.key node?" "$(j .dynamicKey.optionNode)  · config says $(j .dynamicKey.configValue)"
  fi
fi

# ---- 6: does asking a consumer cost it its lock? ------------------------------
hdr "6 · what a read-only query writes"
if [ -z "$flakes" ]; then
  skip "this nix has no flake support — rows 6 and 7 measure a flake"
else
mkdir -p "$lab/dep" "$lab/consumer"
cat >"$lab/dep/flake.nix" <<'NIX'
{
  outputs = { self }: { lib.answer = 42; };
}
NIX
git -C "$lab/dep" init -q . && git -C "$lab/dep" add -A && \
  git -C "$lab/dep" -c user.email=p@x -c user.name=p commit -qm one
cat >"$lab/consumer/flake.nix" <<NIX
{
  inputs.dep.url = "git+file://$lab/dep";
  outputs = { self, dep }: { value = dep.lib.answer; };
}
NIX
git -C "$lab/consumer" init -q . && git -C "$lab/consumer" add -A && \
  git -C "$lab/consumer" -c user.email=p@x -c user.name=p commit -qm one

( cd "$lab/consumer" && nix eval --json .#value >/dev/null 2>&1 )
row "plain eval, no lock present" "$([ -f "$lab/consumer/flake.lock" ] && echo 'WROTE flake.lock' || echo 'wrote nothing')"

rm -f "$lab/consumer/flake.lock"
( cd "$lab/consumer" && nix eval --no-write-lock-file --json .#value >/dev/null 2>&1 )
row "--no-write-lock-file" "answered $([ -f "$lab/consumer/flake.lock" ] && echo 'and WROTE' || echo 'and wrote nothing')"

rm -f "$lab/consumer/flake.lock"
noupd="$( cd "$lab/consumer" && nix eval --no-update-lock-file --json .#value 2>&1 )"
case "$noupd" in
  *"not allowed"*) row "--no-update-lock-file" "refused: '…requires lock file changes but they're not allowed'" ;;
  *)               row "--no-update-lock-file" "answered: $noupd" ;;
esac
fi

# ---- 7: what an --apply expression may reach ---------------------------------
hdr "7 · the query has to be inlined"
if [ -z "$flakes" ]; then
  skip "this nix has no flake support — rows 6 and 7 measure a flake"
else
printf '_: 1\n' >"$lab/apply.nix"
pure="$( cd "$lab/consumer" && nix eval --json .#value --apply "import $lab/apply.nix" 2>&1 )"
case "$pure" in
  *"forbidden in pure evaluation mode"*) row "--apply 'import /abs/file'" "refused in pure mode" ;;
  *)                                      row "--apply 'import /abs/file'" "$(printf '%s' "$pure" | tail -1)" ;;
esac
# …and the consequence, measured rather than asserted: with the query inlined,
# a path carrying a quote is not a string in it — it is Nix.
hostile='haus.roster."; x = builtins.getEnv "HOME"; y = ".key'
raw="$( cd "$lab/consumer" && nix eval --json .#value --apply "cfg: \"$hostile\"" 2>&1 )"
case "$raw" in
  *error*) row "  an unescaped path in one" "changes the expression: $(printf '%s' "$raw" | grep -m1 error: | cut -c1-46)" ;;
  *)       row "  an unescaped path in one" "evaluated to $raw — the path became syntax" ;;
esac
fi

# ---- 5, 8: a real machine ----------------------------------------------------
hdr "5, 8 · a real consumer"
C="${PROBE_CONSUMER:-}"
H="${PROBE_HOST:-}"
if [ -z "$C" ] || [ ! -f "$C/flake.nix" ]; then
  skip "set PROBE_CONSUMER=~/.config/nix (and PROBE_HOST=<hostname>) to measure a machine"
else
  [ -n "$H" ] || H="$(basename "$(ls -d "$C"/hosts/*/ 2>/dev/null | head -1)" 2>/dev/null)"
  [ -n "$H" ] || H="$(hostname -s)"
  cfg=".#darwinConfigurations.$H"

  # 8a. the same pinned input, three times. Every row here is guarded on the
  # eval having ANSWERED: a swallowed failure leaves `seen` empty, and then
  # `sort -u | wc -l` says 1 and `[ -e "" ]` says "DOES NOT EXIST" — three
  # confident rows that measured nothing, reading as support for the claim.
  # Which is the failure this whole file is about, produced by the file itself.
  seen=""
  got=0
  for _ in 1 2 3; do
    p="$( cd "$C" && nix eval --no-update-lock-file --raw "$cfg.config.haus._desktop.sources" \
            --apply 'x: if x == [ ] then "none" else builtins.head x' 2>/dev/null )"
    [ -n "$p" ] || continue
    got=$((got + 1))
    seen="$seen $p"
  done
  if [ "$got" -lt 3 ]; then
    skip "$cfg did not evaluate ($got/3 answered) — is $H the right host name?"
  else
    n="$(printf '%s\n' $seen | sort -u | wc -l | tr -d ' ')"
    row "3 evals of one pinned desktop" "$n distinct store path(s)"
    onthem=0
    for p in $seen; do [ -e "$p" ] && onthem=$((onthem + 1)); done
    row "  and how many are on disk?" "$onthem of 3"

    inside="$( cd "$C" && nix eval --no-update-lock-file --raw "$cfg.config.haus._desktop.sources" \
        --apply 'x: if x == [ ] then "none" else builtins.substring 0 8 (builtins.readFile (builtins.head x))' 2>/dev/null )"
    row "  readFile INSIDE that eval" "$([ -n "$inside" ] && echo 'works' || echo 'fails')"
  fi

  # 5. a flat leaf against a dynamic one, in one query.
  apply='cfg:
    let
      split = p: builtins.filter (x: builtins.isString x && x != "") (builtins.split "\\." p);
      descend = node: ps:
        if ps == [ ] then node
        else if !(builtins.isAttrs node) then null
        else if !(node ? ${builtins.head ps}) then null
        else descend node.${builtins.head ps} (builtins.tail ps);
      isOption = x: builtins.isAttrs x && (x._type or null) == "option";
      look = p: let o = descend cfg.options (split p); in
        if o == null || !(isOption o) then { path = p; node = false; }
        else { path = p; node = true; prio = o.highestPrio; };
    in map look [ "haus.theme.accent" "haus.roster.slack.key" ]'
  q="$( cd "$C" && nix eval --no-update-lock-file --json "$cfg" --apply "$apply" 2>/dev/null )"
  if [ -n "$q" ]; then
    printf '%s' "$q" | jq -r '.[] | "  \(.path)"+(" "*(34-(.path|length)))+(if .node then "option node · highestPrio \(.prio)" else "NO OPTION NODE — compare by value only" end)'
  else
    skip "the query did not evaluate — is $H the right host name?"
  fi
fi

printf '\n'
