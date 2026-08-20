#!/usr/bin/env bash
# source-shapes — what a stranger's desktop costs to FETCH and to READ.
#
# Evidence for ../rooms-desktops.md's Acquisition plan, step B. Step A shipped a
# sandbox for reading a LOCAL file (restrict-eval, empty allowed-uris, IFD off,
# NIX_PATH cleared, two paths named). Step B fetches instead, and this measures
# what changes when the file it reads arrives in the store rather than in
# ~/Downloads. Four things the note had been asserting or had not asked:
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
#   4. THE RAW-URL SHAPE PINS NARHASH AND NOTHING ELSE — no rev, no
#      lastModified — and `nix flake update` on it prints the same URL on both
#      sides of the arrow while the content changes underneath.
#
#   ./notes/probes/source-shapes.sh              # local fixtures only, no network
#   PROBE_REMOTE=git+https://github.com/hausfold/workshop \
#     ./notes/probes/source-shapes.sh            # + one real remote node
#
# No macOS, no darwin system, no build — it builds throwaway git repos in a temp
# dir and runs real `nix eval` / `nix flake lock` against them, so it runs in
# seconds anywhere, including a cloud container. Everything it makes is under one
# mktemp dir and removed on exit.
#
# ⚠️ It measures NIX, not haus. haus's own `share/haus/desktop-check` is not
# reachable from the workshop, so the rows below are about the mechanism `haus
# show` sits on rather than about the command. Rerun on a Nix bump: rows 1 and 2
# are evaluator behaviour and are exactly the kind of thing a release moves.

set -uo pipefail   # deliberately NOT -e: half these commands are run to fail

lab=$(mktemp -d)
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
now=$(date +%s)
(cd consumer && nix flake lock >/dev/null 2>&1)
commit_date=$(git -C writer-desktop log -1 --format=%ct)
locked_date=$(jq -r '.nodes.repoLocal.locked.lastModified' consumer/flake.lock 2>/dev/null)
row "lastModified == the commit's date" "$commit_date" "$locked_date"
row "lastModified != the fetch time" different \
  "$([ "$locked_date" != "$now" ] && echo different || echo same)"
row "the node is typed \`flake: false\`" false "$(jq -r '.nodes.repoLocal.flake' consumer/flake.lock 2>/dev/null)"
row "raw-URL node's fields" "narHash,type,url" \
  "$(jq -r '.nodes.rawFile.locked|keys|join(",")' consumer/flake.lock 2>/dev/null)"
if [ -n "${PROBE_REMOTE:-}" ]; then
  row "remote node resolved a rev" yes \
    "$(jq -e -r '.nodes.repoRemote.locked.rev' consumer/flake.lock >/dev/null 2>&1 && echo yes || echo no)"
  printf '     remote locked: %s\n' "$(jq -c '.nodes.repoRemote.locked' consumer/flake.lock 2>/dev/null)"
fi

say "5. Updating a raw-URL source shows the same URL on both sides"
before=$(jq -r '.nodes.rawFile.locked.narHash' consumer/flake.lock 2>/dev/null)
sed -i.bak 's/"mauve"/"teal"/' writer-desktop/writer.nix 2>/dev/null || \
  sed -i '' 's/"mauve"/"teal"/' writer-desktop/writer.nix
update_line=$(cd consumer && nix flake update rawFile 2>&1 | grep -E '^\s*(→|->)' | head -1)
after=$(jq -r '.nodes.rawFile.locked.narHash' consumer/flake.lock 2>/dev/null)
row "content moved (narHash changed)" changed \
  "$([ "$before" != "$after" ] && echo changed || echo same)"
row "update line distinguishes old from new" no \
  "$(echo "$update_line" | grep -qE '(→|->).*(→|->)' && echo yes || echo no)"
printf '     nix said: %s\n' "${update_line:-<nothing>}"

say "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
