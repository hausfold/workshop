#!/usr/bin/env bash
# source-shapes — what a stranger's desktop costs to FETCH and to READ.
#
# Evidence for desktop acquisition, step B. Step A shipped a
# sandbox for reading a LOCAL file (restrict-eval, empty allowed-uris, IFD off,
# NIX_PATH cleared, two paths named). Step B fetches instead, and this measures
# what changes when the file it reads arrives in the store rather than in
# ~/Downloads. Five things the note had been asserting or had not asked:
#
#   1. FETCHING CANNOT HAPPEN INSIDE THE GUARD. `builtins.fetchTree` under
#      `allowed-uris = ""` is refused by URI, so `show` is two acts: fetch
#      unguarded (no publisher code runs), then read the store path guarded
#      (no network). Neither act can do the other's job.
#   2. THE GUARD'S GRANULARITY CHANGES IN THE STORE. Naming one file allows
#      exactly it outside the store, and its whole store ROOT inside — so a
#      fetched repo's desktop can read every other file in that repo. It still
#      cannot read another store path, or anything outside the store.
#   3. THE LOCK RECORDS A COMMIT DATE, NOT A FETCH DATE. `lastModified` is the
#      source's own timestamp. Nothing in the lock says when you pinned it.
#   4. THE RAW-URL SHAPE PINS ONLY narHash — its whole lock node is
#      narHash/type/url, so no rev and no lastModified — and `nix flake update`
#      on it prints an arrow with the SAME URL on both ends, no rev and no date,
#      while the content changes underneath. Nothing moving prints no line at
#      all, so the two are not confusable by silence — only by a line that says
#      the same thing twice. (This section reported "no left-hand side" until
#      2026-08-20; it was grepping the arrow line out of a three-line block.
#      haus's docs/model.md carries the shape it settled on.)
#   5. "FETCHING RUNS NO PUBLISHER CODE" IS A PROPERTY OF `flake = false`, not
#      of fetching. A desktop locks inert; a ROOM is an ordinary flake input and
#      locking one EVALUATES its flake.nix to find its own inputs. So pinning a
#      room is already running its code, and step F's prompt is owed before the
#      lock rather than before the rebuild.
#
#   ./script/probes/source-shapes.sh              # local fixtures only, no network
#   PROBE_REMOTE=git+https://github.com/hausfold/workshop \
#     ./script/probes/source-shapes.sh            # + one real remote node
#
# No macOS, no darwin system, no build — it builds throwaway git repos in a temp
# dir and runs real `nix eval` / `nix flake lock` against them, so it runs in
# seconds anywhere, including a cloud container. Everything it makes is under one
# mktemp dir and removed on exit.
#
# ⚠️ It measures NIX, not haus. haus's own `share/haus/desktop-check` is not
# reachable from the workshop, so the rows below are about the mechanism `haus
# show` sits on rather than about the command. Rerun on a Nix bump: sections 1,
# 2 and 6 are evaluator behaviour and are exactly the kind of thing a release
# moves.

set -uo pipefail   # deliberately NOT -e: half these commands are run to fail

for dep in nix git jq; do
  command -v "$dep" >/dev/null || { echo "source-shapes: needs $dep on PATH" >&2; exit 2; }
done
# Self-dating: sections 1, 2 and 6 are evaluator behaviour, so a result is only
# readable next to the Nix that produced it.
printf 'nix: %s\n' "$(nix --version)"

lab=$(mktemp -d)
# …resolved to its PHYSICAL path, or section 2 measures macOS instead of Nix:
# `mktemp -d` there hands back /var/folders/…, /var is a symlink to /private/var,
# and a `-I` entry spelled through it is reported "does not exist, ignoring" —
# so every guarded read fails as *blocked* and the one row that expects an
# allowed read is the only one that shows it. No-op on Linux.
lab=$(cd "$lab" && pwd -P)
trap 'rm -rf "$lab"' EXIT
cd "$lab" || exit 1

pass=0; fail=0
say() { printf '\n\033[1m%s\033[0m\n' "$*"; }
row() { # row <label> <expected> <actual>
  if [ "$2" = "$3" ]; then pass=$((pass + 1)); printf '  ✅ %-46s %s\n' "$1" "$3"
  else fail=$((fail + 1)); printf '  ❌ %-46s got %s, expected %s\n' "$1" "$3" "$2"; fi
}

# The guard step A built, as close as it can be reproduced from outside haus.
# --impure is not a weakening we chose: --restrict-eval only ever SUBTRACTS, and
# pure mode forbids every absolute path outright, so the guarded form of "read
# this file" is necessarily impure + restricted.
guard() { # guard <allowed-path> <nix-eval-args...>
  local allow=$1; shift
  nix eval --impure --restrict-eval \
    --option allowed-uris "" \
    --option allow-import-from-derivation false \
    --option nix-path "" \
    -I "$allow" "$@" 2>&1
}

blocked() { case "$1" in *"is forbidden in restricted mode"*) echo yes ;; *) echo no ;; esac; }

# ── the fixture: a stranger's desktop repo with a secret beside the desktop ──
mkdir -p writer-desktop
cat > writer-desktop/writer.nix <<'EOF'
{ haus = { apps.packs.writing.enable = true; theme.accent = "mauve"; }; }
EOF
echo "ada-private-notes" > writer-desktop/NOTES.txt
cat > writer-desktop/peek.nix <<'EOF'
{ haus = { theme.accent = builtins.readFile ./NOTES.txt; }; }
EOF
git init -q -b main writer-desktop
git -C writer-desktop add -A
git -C writer-desktop -c user.email=probe@local -c user.name=probe commit -qm fixture

mkdir -p outside && cp writer-desktop/peek.nix writer-desktop/NOTES.txt outside/

say "1. Fetch and read are two acts — the guard forbids fetching"
out=$(nix eval --impure --restrict-eval --option allowed-uris "" --option nix-path "" \
  --raw --expr "builtins.fetchTree { type = \"git\"; url = \"file://$lab/writer-desktop\"; ref = \"main\"; }" 2>&1)
row "fetchTree inside the guard" yes "$(blocked "$out")"
out=$(nix eval --raw --expr "builtins.fetchTree { type = \"git\"; url = \"file://$lab/writer-desktop\"; ref = \"main\"; }" 2>&1)
case "$out" in *"pure evaluation mode"*) v=refused ;; /nix/store/*) v=fetched ;; *) v=other ;; esac
row "fetchTree pure, no narHash" refused "$v"
src=$(nix eval --impure --raw --expr \
  "builtins.fetchTree { type = \"git\"; url = \"file://$lab/writer-desktop\"; ref = \"main\"; }" 2>/dev/null)
row "fetchTree impure, no consumer flake" fetched "$([ -d "$src" ] && echo fetched || echo failed)"

say "2. The guard's granularity: per file outside the store, per store path inside"
out=$(guard "$lab/outside/peek.nix" --json --expr "import $lab/outside/peek.nix")
row "outside: one file named, sibling read" yes "$(blocked "$out")"
out=$(guard "$lab/outside" --json --expr "import $lab/outside/peek.nix")
row "outside: parent named, sibling read" no "$(blocked "$out")"
out=$(guard "$src/peek.nix" --json --expr "import $src/peek.nix")
row "in store: one file named, sibling read" no "$(blocked "$out")"
other=$(nix eval --impure --raw --expr \
  "builtins.fetchTree { type = \"file\"; url = \"file://$lab/writer-desktop/writer.nix\"; }" 2>/dev/null)
out=$(guard "$src/writer.nix" --raw --expr "builtins.readFile $other")
row "in store: a DIFFERENT store path" yes "$(blocked "$out")"
out=$(guard "$src/writer.nix" --raw --expr "builtins.readFile /etc/hostname")
row "in store: a path outside the store" yes "$(blocked "$out")"

say "3. What each source shape pins"
git_attrs=$(nix eval --impure --json --expr \
  "builtins.attrNames (builtins.fetchTree { type = \"git\"; url = \"file://$lab/writer-desktop\"; ref = \"main\"; })" 2>/dev/null)
file_attrs=$(nix eval --impure --json --expr \
  "builtins.attrNames (builtins.fetchTree { type = \"file\"; url = \"file://$lab/writer-desktop/writer.nix\"; })" 2>/dev/null)
row "git shape has rev" yes "$(echo "$git_attrs" | grep -q '"rev"' && echo yes || echo no)"
row "git shape has lastModified" yes "$(echo "$git_attrs" | grep -q '"lastModified"' && echo yes || echo no)"
row "file shape has rev" no "$(echo "$file_attrs" | grep -q '"rev"' && echo yes || echo no)"
row "file shape has lastModified" no "$(echo "$file_attrs" | grep -q '"lastModified"' && echo yes || echo no)"
printf '     git:  %s\n     file: %s\n' "$git_attrs" "$file_attrs"

say "4. The lock's lastModified is the SOURCE's date, not the fetch's"
mkdir -p consumer
# Built outside the heredoc on purpose: a `}` inside a `${VAR:+…}` replacement
# closes the expansion, so inlining this emits `};;}` and a syntax error that
# `nix flake lock` reports two rows later, about a different line.
remote_input=""
[ -n "${PROBE_REMOTE:-}" ] && remote_input="
    repoRemote = { url = \"$PROBE_REMOTE\"; flake = false; };"
cat > consumer/flake.nix <<EOF
{
  inputs = {
    repoLocal = { url = "git+file://$lab/writer-desktop?ref=main"; flake = false; };
    rawFile   = { url = "file://$lab/writer-desktop/writer.nix"; flake = false; };$remote_input
  };
  outputs = { ... }: { };
}
EOF
git init -q -b main consumer && git -C consumer add flake.nix
(cd consumer && nix flake lock >/dev/null 2>&1)
commit_date=$(git -C writer-desktop log -1 --format=%ct)
locked_date=$(jq -r '.nodes.repoLocal.locked.lastModified' consumer/flake.lock 2>/dev/null)
# The equality IS the claim: lastModified is the source's own commit timestamp,
# so it is not and cannot be a record of when the fetch happened. (An earlier
# draft also asserted `locked_date != now`, which is racy against the probe's
# own clock and proves nothing the row below doesn't — the honest measurement of
# "the source is older than the fetch" is the remote row further down, over a
# repo whose HEAD really is minutes or days old.)
row "lastModified == the commit's date" "$commit_date" "$locked_date"
row "the node is typed \`flake: false\`" false "$(jq -r '.nodes.repoLocal.flake' consumer/flake.lock 2>/dev/null)"
row "git node's fields" "lastModified,narHash,ref,rev,revCount,type,url" \
  "$(jq -r '.nodes.repoLocal.locked|keys|join(",")' consumer/flake.lock 2>/dev/null)"
row "raw-URL node's fields" "narHash,type,url" \
  "$(jq -r '.nodes.rawFile.locked|keys|join(",")' consumer/flake.lock 2>/dev/null)"
if [ -n "${PROBE_REMOTE:-}" ]; then
  row "remote node resolved a rev" yes \
    "$(jq -e -r '.nodes.repoRemote.locked.rev' consumer/flake.lock >/dev/null 2>&1 && echo yes || echo no)"
  remote_date=$(jq -r '.nodes.repoRemote.locked.lastModified' consumer/flake.lock 2>/dev/null)
  row "remote lastModified predates this fetch" yes \
    "$([ -n "$remote_date" ] && [ "$remote_date" -lt "$(date +%s)" ] && echo yes || echo no)"
  printf '     remote locked: %s\n     that is %ss before this fetch\n' \
    "$(jq -c '.nodes.repoRemote.locked' consumer/flake.lock 2>/dev/null)" \
    "$(( $(date +%s) - remote_date ))"
fi

say "5. Updating a raw-URL source: an arrow with the same URL on both ends"
# Read the WHOLE block, never one line of it. Nix prints three lines — the
# input's name, the old side indented under it, the new side behind the arrow.
# Until 2026-08-20 this section grepped `^\s*(→|->)`, saw only the second half,
# and reported "no left-hand side"; the note then wrote that down and cited it
# twice before anyone looked again. A probe that greps one line out of a
# multi-line block measures the grep.
# awk, not `sed -n /a/,/b/p`: POSIX BREs have no alternation, so the `\(→\|->\)`
# end address is a GNU extension that BSD sed reads as a literal `|` — the range
# then never ends and the "block" runs to EOF. Widening the capture is the same
# defect as narrowing it.
update_block() { # update_block <nix output> <input name> — name line .. arrow line
  printf '%s\n' "$1" | awk -v want="Updated input '$2'" '
    index($0, want) { inblock = 1 }
    inblock         { print }
    inblock && !index($0, want) && (/→/ || /->/) { exit }'
}
quoted() { # quoted <lines> — the first single-quoted string in the first line that has one
  printf '%s\n' "$1" | sed -n "s/^[^']*'\\([^']*\\)'.*\$/\\1/p" | head -1
}
sides() { # sides <block> — prints the old side and the new side, one per line
  quoted "$(printf '%s\n' "$1" | grep -v 'Updated input' | grep -vE '(→|->)')"
  quoted "$(printf '%s\n' "$1" | grep -E '(→|->)')"
}
# A `git` node's date is printed OUTSIDE the quotes — `'…?rev=…' (2026-08-20)` —
# so it has to be read off the block's own lines. Asking `sides()` about it would
# be this probe's original sin twice: a test that can only ever see what its own
# extraction kept.
carries() { # carries <block> <lhs> <rhs> — "yes" if either end shows a rev or a date
  case "$2$3" in *rev=*) echo yes; return ;; esac
  printf '%s\n' "$1" | grep -qE '\([0-9]{4}-[0-9]{2}-[0-9]{2}\)' && echo yes || echo no
}

before=$(jq -r '.nodes.rawFile.locked.narHash' consumer/flake.lock 2>/dev/null)
sed -i.bak 's/"mauve"/"teal"/' writer-desktop/writer.nix 2>/dev/null || \
  sed -i '' 's/"mauve"/"teal"/' writer-desktop/writer.nix
# --refresh: without it the fetcher cache can serve the pre-edit copy under
# tarball-ttl, and the rows below fail for a reason unrelated to the claim.
file_out=$(cd consumer && nix flake update rawFile --refresh 2>&1)
after=$(jq -r '.nodes.rawFile.locked.narHash' consumer/flake.lock 2>/dev/null)
file_blk=$(update_block "$file_out" rawFile)
file_lhs=$(sides "$file_blk" | sed -n 1p); file_rhs=$(sides "$file_blk" | sed -n 2p)
row "content moved (narHash changed)" changed \
  "$([ "$before" != "$after" ] && echo changed || echo same)"
row "the line HAS a left-hand side" yes "$([ -n "$file_lhs" ] && echo yes || echo no)"
row "both ends are the same URL, byte for byte" same \
  "$([ -n "$file_lhs" ] && [ "$file_lhs" = "$file_rhs" ] && echo same || echo differ)"
row "either end carries a rev or a date" no \
  "$(carries "$file_blk" "$file_lhs" "$file_rhs")"
# The real no-op, for contrast: run it again with nothing moved underneath.
quiet_out=$(cd consumer && nix flake update rawFile --refresh 2>&1)
row "nothing moved: no update line at all" none \
  "$(printf '%s\n' "$quiet_out" | grep -qE "Updated input|(→|->) '" && echo printed || echo none)"
# And what a two-sided line looks like when it means something: commit the SAME
# edit into the repo shape and move that node instead.
git -C writer-desktop -c user.email=probe@local -c user.name=probe commit -aqm teal
git_blk=$(update_block "$(cd consumer && nix flake update repoLocal --refresh 2>&1)" repoLocal)
git_lhs=$(sides "$git_blk" | sed -n 1p); git_rhs=$(sides "$git_blk" | sed -n 2p)
# Expecting `yes` from the same `carries` the file row expects `no` from is the
# point: one detector, both answers measured, so neither row can pass vacuously.
row "a git node's ends differ, and carry rev + date" differ \
  "$([ -n "$git_lhs" ] && [ "$git_lhs" != "$git_rhs" ] &&
     [ "$(carries "$git_blk" "$git_lhs" "$git_rhs")" = yes ] && echo differ || echo same)"
printf '     the file node:\n%s\n     the git node:\n%s\n' \
  "$(printf '%s\n' "${file_blk:-<nothing printed>}" | sed 's/^/       /')" \
  "$(printf '%s\n' "${git_blk:-<nothing printed>}" | sed 's/^/       /')"

say "6. 'Fetching runs no publisher code' is a property of flake=false, not of fetching"
# The desktop shapes above are all `flake = false`, where a lock is a pure fetch.
# A ROOM (step F) is an ordinary flake input, and locking one EVALUATES its
# flake.nix to discover its own inputs — so the code prompt a room earns is owed
# before the lock, not merely before the rebuild.
mkdir -p room
cat > room/flake.nix <<'EOF'
{
  inputs = { nixpkgs.url = builtins.throw "PUBLISHER-CODE-RAN-AT-LOCK-TIME"; };
  outputs = { ... }: { };
}
EOF
git init -q -b main room
git -C room add -A
git -C room -c user.email=probe@local -c user.name=probe commit -qm room
for kind in flake nonflake; do
  d="consumer-$kind"; mkdir -p "$d"
  if [ "$kind" = flake ]; then spec="{ url = \"git+file://$lab/room?ref=main\"; }"
  else spec="{ url = \"git+file://$lab/room?ref=main\"; flake = false; }"; fi
  printf '{\n  inputs.theRoom = %s;\n  outputs = { ... }: { };\n}\n' "$spec" > "$d/flake.nix"
  git init -q -b main "$d"; git -C "$d" add flake.nix
  out=$(cd "$d" && nix flake lock 2>&1)
  case "$out" in *PUBLISHER-CODE-RAN-AT-LOCK-TIME*) v=evaluated ;; *) v=inert ;; esac
  if [ "$kind" = flake ]; then row "a room (flake input): locking it" evaluated "$v"
  else row "a desktop (flake = false): locking it" inert "$v"; fi
done

say "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
