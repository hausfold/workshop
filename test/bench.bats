#!/usr/bin/env bats
# Unit tests for the `bench` CLI. We source bench with HAUS_LIB=1 (which skips the
# command dispatch) and call its functions directly, pointing ROOT/CONSUMER at
# throwaway fixtures. These cover the parsing + path logic that the whole
# status/ship/release flow rests on — not the nix/darwin-rebuild side effects.

setup() {
  HAUS="$BATS_TEST_DIRNAME/../bench"
  TMP="$BATS_TEST_TMPDIR"
  # Hermetic git: ignore the machine's global/system config so fixtures behave
  # the same everywhere. (Without this, a global tag.gpgsign=true turns the
  # lightweight `git tag` calls below into "fatal: no tag message?" failures.)
  export GIT_CONFIG_GLOBAL=/dev/null GIT_CONFIG_SYSTEM=/dev/null
  # HAUS_HOST is host_name()'s escape hatch and short-circuits it before any
  # nix lookup, so a developer who exports it would see the host_name test
  # below fail for a reason that has nothing to do with the code.
  unset HAUS_HOST
  # Source the library form; override ROOT so repo_dir() resolves into fixtures.
  HAUS_LIB=1 source "$HAUS"
  ROOT="$TMP/root"
  mkdir -p "$ROOT"
  BATS_SAVED_PATH="$PATH"
  # Same reason: the overlap tests `cd` into a per-test fixture, and on bats
  # 1.10 that cd outlives the test body — leaving bats' own cleanup standing in
  # a directory it is about to delete.
  BATS_SAVED_PWD="$PWD"
  # And HOME, for the same reason: the notify tests below repoint it — at a
  # non-existent dir to hide the ~/Applications candidate, or at a fixture that
  # PROVIDES one — and on bats-core 1.10 (Ubuntu CI) that mutation outlives the
  # test body, into a cleanup that is entitled to a real HOME.
  BATS_SAVED_HOME="$HOME"
  # A consumer fixture, so nothing here reads the machine's real ~/.config/nix —
  # layer_input() would, and on a dev Mac it would even answer correctly, which
  # is the kind of green that stops meaning anything on CI.
  mkconsumer mydesktop
}

teardown() {
  # The ensure_nix_path tests below deliberately strip PATH down to a fixture
  # dir, to hide `nix` from `command -v`. That mutation escapes the test body,
  # and bats' own per-test cleanup shells out to `rm` — so on bats-core 1.10
  # (Ubuntu CI) every test still printed `ok` while the RUN exited 1 with
  # `bats-exec-test: line 205: rm: command not found`. Newer bats (nixpkgs, on
  # macOS) papers over it, which is exactly why this was green locally and red
  # on CI. Put PATH back before bats needs it.
  PATH="$BATS_SAVED_PATH"
  HOME="$BATS_SAVED_HOME"
  cd "$BATS_SAVED_PWD" || true
}

mkconsumer() { # mkconsumer <input-name> — a machine flake whose haus input is called <name>
  CONSUMER="$TMP/consumer"
  mkdir -p "$CONSUMER"
  python3 - "$CONSUMER/flake.lock" "$1" <<'JSON'
import json, sys
name = sys.argv[2]
json.dump({
    "root": "root",
    "nodes": {
        "root": {"inputs": {name: name, "nixpkgs": "nixpkgs"}},
        name: {
            "inputs": {"pounce": "pounce", "nebelung": "nebelung", "nixpkgs": "nixpkgs"},
            "original": {"type": "github", "owner": "hausfold", "repo": "haus"},
            "locked": {"type": "github", "owner": "hausfold", "repo": "haus", "rev": "deadbee"},
        },
        "pounce": {"original": {"type": "github", "owner": "hausfold", "repo": "pounce"}},
        "nebelung": {"original": {"type": "github", "owner": "hausfold", "repo": "nebelung"}},
        "nixpkgs": {"original": {"type": "github", "owner": "NixOS", "repo": "nixpkgs"}},
    },
}, open(sys.argv[1], "w"))
JSON
  LAYER_INPUT=""   # drop any memo from a previous mkconsumer in the same test
}

# ── locked_rev: parse a rev out of flake.lock, degrade to "?" on anything odd ──

@test "locked_rev reads the locked rev of an input" {
  mkdir -p "$ROOT/pounce"
  cat >"$ROOT/pounce/flake.lock" <<'JSON'
{ "nodes": { "nebelung": { "locked": { "rev": "abc123" } } } }
JSON
  run locked_rev pounce nebelung
  [ "$status" -eq 0 ]
  [ "$output" = "abc123" ]
}

@test "locked_rev yields ? when the input node is missing" {
  mkdir -p "$ROOT/pounce"
  echo '{ "nodes": {} }' >"$ROOT/pounce/flake.lock"
  run locked_rev pounce nebelung
  [ "$output" = "?" ]
}

@test "locked_rev yields ? on a missing lock file" {
  mkdir -p "$ROOT/pounce"
  run locked_rev pounce nebelung
  [ "$output" = "?" ]
}

@test "locked_rev yields ? on malformed JSON (never crashes the caller)" {
  mkdir -p "$ROOT/pounce"
  echo 'not json {{{' >"$ROOT/pounce/flake.lock"
  run locked_rev pounce nebelung
  [ "$output" = "?" ]
}

# ── rev_on_main: is a locked rev actually on the upstream's main? ──────────────
#
# Three-valued on purpose. `no` is the hazard (a lock pinned at an unmerged PR
# branch, which stops resolving when GitHub deletes that branch on merge);
# `unknown` is "this clone can't answer", which must stay silent rather than
# warn on every machine that hasn't fetched.

mkmain() { # mkmain <name> — fixture repo on a real `main` with one commit
  mkdir -p "$ROOT/$1"
  git -C "$ROOT/$1" init -q -b main
  git -C "$ROOT/$1" -c user.name=t -c user.email=t@t commit -q --allow-empty -m one
}

@test "rev_on_main says yes for a commit on main" {
  mkmain nebelung
  run rev_on_main nebelung "$(git -C "$ROOT/nebelung" rev-parse main)"
  [ "$output" = "yes" ]
}

@test "rev_on_main says yes for an ancestor of main, not just its tip" {
  mkmain nebelung
  local first; first="$(git -C "$ROOT/nebelung" rev-parse main)"
  git -C "$ROOT/nebelung" -c user.name=t -c user.email=t@t commit -q --allow-empty -m two
  run rev_on_main nebelung "$first"
  [ "$output" = "yes" ]
}

@test "rev_on_main says no for a rev that lives only on an unmerged branch" {
  # The real incident (workshop#251): a lock pinned at a PR-branch head.
  mkmain nebelung
  git -C "$ROOT/nebelung" checkout -q -b worktree-feature
  git -C "$ROOT/nebelung" -c user.name=t -c user.email=t@t commit -q --allow-empty -m pr
  local pr_rev; pr_rev="$(git -C "$ROOT/nebelung" rev-parse HEAD)"
  git -C "$ROOT/nebelung" checkout -q main
  run rev_on_main nebelung "$pr_rev"
  [ "$output" = "no" ]
}

@test "rev_on_main ignores HEAD when main exists — a checkout parked on a branch still reports off-main" {
  # Every extra ref only WIDENS the yes-set, so consulting HEAD unconditionally
  # would let the in-place agent mode (main checkout sitting on a branch)
  # silence the warning exactly where it's most likely to be earned.
  mkmain nebelung
  git -C "$ROOT/nebelung" checkout -q -b worktree-feature
  git -C "$ROOT/nebelung" -c user.name=t -c user.email=t@t commit -q --allow-empty -m pr
  run rev_on_main nebelung "$(git -C "$ROOT/nebelung" rev-parse HEAD)"   # still ON that branch
  [ "$output" = "no" ]
}

@test "rev_on_main falls back to HEAD when the repo has no main branch" {
  mkdir -p "$ROOT/nebelung"
  git -C "$ROOT/nebelung" init -q -b trunk
  git -C "$ROOT/nebelung" -c user.name=t -c user.email=t@t commit -q --allow-empty -m one
  run rev_on_main nebelung "$(git -C "$ROOT/nebelung" rev-parse HEAD)"
  [ "$output" = "yes" ]
}

@test "rev_on_main yields unknown for a rev this clone doesn't have" {
  mkmain nebelung
  run rev_on_main nebelung deadbeefdeadbeefdeadbeefdeadbeefdeadbeef
  [ "$output" = "unknown" ]
}

@test "rev_on_main yields unknown for locked_rev's ? and for an empty rev" {
  mkmain nebelung
  run rev_on_main nebelung '?'
  [ "$output" = "unknown" ]
  run rev_on_main nebelung ''
  [ "$output" = "unknown" ]
}

@test "rev_on_main yields unknown when the repo isn't cloned here" {
  run rev_on_main nosuchrepo abc123
  [ "$output" = "unknown" ]
}

# (hook_field + the worktree lifecycle moved to the standalone `wt` tool in
# the rice (haus/modules/core) — bench no longer parses hook payloads.)

# ── gh_repo: a checkout's directory name is not always its owner/repo ─────────
#
# The local side is `repo_dir` ($ROOT/<name>); this is the remote side. They
# agree for most of the family and deliberately don't for org-profile. The
# layer's checkout has been renamed twice — these tests are what stops an old
# spelling coming back, in either direction.

@test "gh_repo resolves a family checkout to owner/repo" {
  run gh_repo nebelung
  [ "$output" = "$GH_ORG/nebelung" ]
  run gh_repo haus
  [ "$output" = "$GH_ORG/haus" ]
}

@test "gh_repo maps org-profile to the repo GitHub insists is named .github" {
  # The checkout can't be `.github`: a dotdir there is invisible to the family
  # loops and collides with the workshop's own ./.github (its CI).
  run gh_repo org-profile
  [ "$output" = "$GH_ORG/.github" ]
}

@test "gh_repo never emits the layer's pre-migration repo name" {
  # `hausfold/hausfold` RESOLVES — GitHub redirects a pre-rename name — so
  # nothing would fail until someone creates a real repo under the freed slug.
  # Leaning on a redirect is the bug; nothing being queued to claim it is a
  # prediction, not a guarantee.
  for name in "${FAMILY[@]}" org-profile homebrew-tap; do
    run gh_repo "$name"
    [ "$output" != "$GH_ORG/hausfold" ]
  done
}

@test "repo_dir resolves the layer to its checkout" {
  mkdir -p "$ROOT/haus/.git"
  run repo_dir haus
  [ "$output" = "$ROOT/haus" ]
}

@test "repo_dir resolves scruff to \$ROOT/scruff, checkout or not" {
  # The 2026-08-27 `hausfold/holt` → `hausfold/scruff` rename moved the
  # directory too, so there is no arm here any more and the answer does not
  # depend on what is on disk. `bench clone` builds its destination from this,
  # so a fresh machine must never be handed the old directory name.
  run repo_dir scruff
  [ "$output" = "$ROOT/scruff" ]

  mkdir -p "$ROOT/scruff/.git"
  run repo_dir scruff
  [ "$output" = "$ROOT/scruff" ]
}

@test "gh_repo resolves scruff to the repo, never the checkout" {
  run gh_repo scruff
  [ "$output" = "$GH_ORG/scruff" ]
  # And the freed slug stays freed — decision 5 in the rename plan: recreating
  # `hausfold/holt` would kill every redirect permanently.
  [ "$output" != "$GH_ORG/holt" ]
}

# ── local_src / overrides: worktree-aware checkout substitution ────────────────

@test "local_src points at the main checkout when not in a worktree" {
  WT_REPO="" WT_PATH=""
  run local_src nebelung
  [ "$output" = "$ROOT/nebelung" ]
}

@test "local_src substitutes the worktree path for the active worktree repo" {
  WT_REPO="nebelung" WT_PATH="/tmp/wt/nebelung"
  run local_src nebelung
  [ "$output" = "/tmp/wt/nebelung" ]
  # …but other repos still resolve to their main checkout.
  run local_src pounce
  [ "$output" = "$ROOT/pounce" ]
}

@test "overrides redirects every family input, honouring the active worktree" {
  WT_REPO="pounce" WT_PATH="/tmp/wt/pounce"
  run overrides
  [[ "$output" == *"--override-input mydesktop path:$ROOT/haus"* ]]
  [[ "$output" == *"--override-input mydesktop/nebelung path:$ROOT/nebelung"* ]]
  [[ "$output" == *"--override-input mydesktop/pounce path:/tmp/wt/pounce"* ]]
}

@test "overrides emits a row for every OVERRIDABLE repo — a missing one fails silently" {
  # The seam this covers is the quiet one. `--override-input` for an input nix
  # has never heard of is NOT an error, so a repo added to OVERRIDABLE and
  # forgotten here makes `bench try` announce your branch while building the
  # pinned one. Same failure mode, mirrored, as naming an input that doesn't
  # exist — which is what the 🚨 in overrides() is about.
  #
  # By path rather than by input name on purpose: the input NAME is the
  # consumer's to choose (`consumer @layer haus` is the standing proof they
  # diverge), so the checkout each row points AT is the only half this repo owns.
  #
  # And the path comes from `repo_dir`, never `$ROOT/$name`: since scruff those
  # two answer differently for one repo, and hardcoding the shape here would
  # make this test the thing that fails when the checkout finally moves.
  WT_REPO="" WT_PATH=""
  run overrides
  local name dir
  for name in "${OVERRIDABLE[@]}"; do
    [ "$name" = haus ] && continue    # the layer is the override's own root, not a sub-input
    dir="$(repo_dir "$name")"
    [[ "$output" == *"path:$dir"* ]] \
      || { echo "OVERRIDABLE repo '$name' has no --override-input row"; echo "$output"; return 1; }
  done
}

# ── layer_input: the CONSUMER's name for the haus input, not ours ─────────────
#
# `--override-input <a-name-this-flake-doesn't-have>` is not an error in Nix, it
# is a no-op — so getting this name wrong makes `bench try` announce your branch
# and build the pinned layer. The name belongs to the CONSUMER's flake, so the
# fixture deliberately uses one bench would never guess. These are what stop a
# literal being baked back in.

@test "lock_layer_input reads the consumer's own name for the layer" {
  run lock_layer_input
  [ "$output" = "mydesktop" ]
  mkconsumer haus
  run lock_layer_input
  [ "$output" = "haus" ]
}

@test "lock_layer_input identifies the layer by its inputs, not by its slug" {
  # This machine's lock still records the slug §10 freed (hausfold/hausfold), so
  # a slug match would fail on the only consumer that exists. The signature is
  # the node's OWN inputs.
  python3 - "$CONSUMER/flake.lock" <<'JSON'
import json, sys
lock = json.load(open(sys.argv[1]))
lock["nodes"]["mydesktop"]["original"] = {"type": "github", "owner": "hausfold", "repo": "hausfold"}
json.dump(lock, open(sys.argv[1], "w"))
JSON
  run lock_layer_input
  [ "$output" = "mydesktop" ]
}

@test "lock_layer_input is empty for a flake that doesn't take the layer" {
  echo '{ "root": "root", "nodes": { "root": { "inputs": { "nixpkgs": "nixpkgs" } }, "nixpkgs": {} } }' \
    >"$CONSUMER/flake.lock"
  run lock_layer_input
  [ -z "$output" ]
}

@test "overrides uses the name the consumer gave the input" {
  mkconsumer haus
  run overrides
  [[ "$output" == *"--override-input haus path:$ROOT/haus"* ]]
  [[ "$output" == *"--override-input haus/pounce path:$ROOT/pounce"* ]]
  [[ "$output" != *"mydesktop"* ]]
}

@test "resolve_layer_input assumes, out loud, when there is no lock to read" {
  rm -f "$CONSUMER/flake.lock"
  run resolve_layer_input
  [ "$status" -eq 0 ]
  [[ "$output" == *"assuming"* ]]
  [[ "$output" == *"haus"* ]]
}

@test "layer_input stays silent — every caller interpolates it inside \$( )" {
  # `warn` prints on STDOUT here (only `die` redirects), so a chatty layer_input
  # splices its own warning into the value: cmd_ship's `nix flake update
  # "$input"` would be handed a name with a ⚠ in it. Loud belongs in
  # resolve_layer_input, which runs in the command's own shell.
  rm -f "$CONSUMER/flake.lock"
  run layer_input
  [ "$status" -eq 0 ]
  [ "$output" = "haus" ]
  echo '{ "root": "root", "nodes": { "root": { "inputs": {} } } }' >"$CONSUMER/flake.lock"
  LAYER_INPUT=""
  run layer_input
  [ "$status" -eq 0 ]
  [ "$output" = "haus" ]
}

@test "every \$(overrides) caller resolves the input name in its own shell first" {
  # A die inside `$(overrides)` kills only that subshell and hands nix an empty
  # `--override-input`, which is a no-op — the exact failure this seam ends. So
  # the guard is structural: each caller of $(overrides) calls
  # resolve_layer_input before it. This counts them rather than trusting memory.
  local callers guards
  callers="$(grep -v '^\s*#' "$HAUS" | grep -c '\$(overrides)')"
  guards="$(grep -c '^\s*resolve_layer_input  ' "$HAUS")"   # the call sites, not the definition
  # Four override sites now, behind three functions: cmd_try uses it TWICE —
  # once for the build, once for the trill card's `--dry-run`, which has to see
  # the same overridden inputs or it would measure the pinned build instead —
  # plus cmd_try_batch and activate_built. Four guards, because cmd_try's one
  # `resolve_layer_input` covers both of its sites and cmd_ship's is for `nix
  # flake update "$input"`, which takes the name too. The count is the
  # tripwire: a FIFTH override site trips this test, and whoever adds it has to
  # come and read this comment.
  [ "$callers" -eq 4 ]
  [ "$guards" -ge "$callers" ]
}

@test "resolve_layer_input dies on a readable lock with no layer in it" {
  echo '{ "root": "root", "nodes": { "root": { "inputs": {} } } }' >"$CONSUMER/flake.lock"
  run resolve_layer_input
  [ "$status" -ne 0 ]
  [[ "$output" == *"no input carrying the haus layer"* ]]
}

@test "the consumer edge carries the sentinel, never a baked-in input name" {
  local found=""
  for edge in "${EDGES[@]}"; do
    read -r holder input _ <<<"$edge"
    [ "$holder" = "consumer" ] || continue
    found=1
    [ "$input" = "@layer" ]
  done
  [ -n "$found" ]
}

# ── the four repo lists answer four different questions ──────────────────────
# FAMILY / OVERRIDABLE / EDGES / LOCK_ONLY were one list for long enough to read
# as one, and trill then snug pulled them apart. The 🚨 by FAMILY is the prose;
# these are the part that fails when someone folds them back together.

@test "every EDGES source is a repo some list can resolve to a checkout" {
  local edge holder input source name found
  for edge in "${EDGES[@]}"; do
    read -r holder input source <<<"$edge"
    found=""
    for name in "${FAMILY[@]}" "${LOCK_ONLY[@]}" consumer; do
      [ "$name" = "$source" ] && { found=1; break; }
    done
    [ -n "$found" ] || { echo "EDGES source '$source' is in no list"; return 1; }
  done
}

@test "LOCK_ONLY is derived from EDGES, and holds exactly the non-FAMILY sources" {
  local name fam
  # Nothing in FAMILY may appear here: LOCK_ONLY is the repos bench does NOT
  # walk, and a FAMILY repo leaking in would have cmd_ship fast-forward it twice.
  for name in "${LOCK_ONLY[@]}"; do
    for fam in "${FAMILY[@]}" consumer; do
      [ "$name" != "$fam" ] || { echo "$name is in both FAMILY and LOCK_ONLY"; return 1; }
    done
  done
  # And the other direction: an EDGES source outside FAMILY must have landed here
  # rather than being typed in, which is the whole reason it is a derived array.
  local edge holder input source found
  for edge in "${EDGES[@]}"; do
    read -r holder input source <<<"$edge"
    found=""
    for fam in "${FAMILY[@]}" consumer; do
      [ "$source" = "$fam" ] && { found=skip; break; }
    done
    [ "$found" = skip ] && continue
    found=""
    for name in "${LOCK_ONLY[@]}"; do
      [ "$name" = "$source" ] && { found=1; break; }
    done
    [ -n "$found" ] || { echo "EDGES source '$source' never reached LOCK_ONLY"; return 1; }
  done
}

@test "a lock source that bench does not walk is overridable, or bench try lies about it" {
  # `bench try` from a worktree of an EDGES source has to be able to redirect
  # that input, or it silently builds the PINNED repo while announcing your
  # branch — detect_worktree walks OVERRIDABLE, not FAMILY, for exactly this.
  local name found fam
  for name in "${LOCK_ONLY[@]}"; do
    found=""
    for fam in "${OVERRIDABLE[@]}"; do
      [ "$fam" = "$name" ] && { found=1; break; }
    done
    [ -n "$found" ] || { echo "$name is a lock source but not OVERRIDABLE"; return 1; }
  done
}

# ── ship_scope: the downstream closure a `bench ship <repo>` walks ────────────

@test "ship_scope of pounce is pounce plus everything that consumes it, in walk order" {
  run ship_scope pounce
  [ "$status" -eq 0 ]
  [ "$output" = $'pounce\nhaus\nconsumer' ]
}

@test "ship_scope of nebelung reaches the whole spine through both of its edges" {
  run ship_scope nebelung
  [ "$output" = $'nebelung\npounce\nhaus\nconsumer' ]
}

@test "ship_scope of a lock-only source ripples haus + consumer without adding the rest of FAMILY" {
  # trill isn't walked by cmd_ship (not FAMILY) — its presence in the output is
  # for the fast-forward loop, which reads its HEAD before bumping haus's lock.
  run ship_scope trill
  [ "$output" = $'haus\ntrill\nconsumer' ]
}

@test "ship_scope of the consumer is just the consumer — nothing is downstream of it" {
  run ship_scope consumer
  [ "$output" = "consumer" ]
}

@test "ship_scope never emits a repo twice, however many named seeds converge on it" {
  # scruff and snug both ripple through haus; haus and consumer must appear once.
  run ship_scope scruff snug
  [ "$output" = $'scruff\nhaus\nsnug\nconsumer' ]
}

@test "ship_in_scope lets everything through when no repos were named" {
  local -a SHIP_SCOPE=()
  ship_in_scope nebelung
  ship_in_scope consumer
  ship_in_scope anything-at-all
}

@test "ship_in_scope answers membership when a scope was named" {
  local -a SHIP_SCOPE=(pounce haus consumer)
  ship_in_scope haus
  ! ship_in_scope nebelung
}

# ── locked_slug: a lock records a SOURCE as well as a rev ─────────────────────

@test "locked_slug reports the owner/repo an input is fetched from" {
  mkdir -p "$ROOT/haus"
  cat >"$ROOT/haus/flake.lock" <<'JSON'
{ "nodes": { "pounce": { "original": { "type": "github", "owner": "hausfold", "repo": "pounce" } } } }
JSON
  run locked_slug haus pounce
  [ "$output" = "hausfold/pounce" ]
}

@test "locked_slug catches an input still fetched under a freed slug" {
  run locked_slug consumer mydesktop
  [ "$output" = "hausfold/haus" ]
  python3 - "$CONSUMER/flake.lock" <<'JSON'
import json, sys
lock = json.load(open(sys.argv[1]))
lock["nodes"]["mydesktop"]["original"]["repo"] = "hausfold"   # the slug §10 freed
json.dump(lock, open(sys.argv[1], "w"))
JSON
  run locked_slug consumer mydesktop
  [ "$output" = "hausfold/hausfold" ]
  [ "$output" != "$(gh_repo haus)" ]   # …which is what bench status reports on
}

@test "locked_slug stays silent for inputs with no slug to be wrong about" {
  mkdir -p "$ROOT/haus"
  cat >"$ROOT/haus/flake.lock" <<'JSON'
{ "nodes": { "local": { "original": { "type": "path", "path": "/tmp/x" } },
             "elsewhere": { "original": { "type": "gitlab", "owner": "hausfold", "repo": "pounce" } },
             "bare":  { "original": { "type": "github", "owner": "hausfold" } } } }
JSON
  run locked_slug haus local
  [ -z "$output" ]
  # owner/repo on a NON-github forge is not a GitHub slug, and comparing it to
  # one would cry wolf on every edge that legitimately lives somewhere else.
  run locked_slug haus elsewhere
  [ -z "$output" ]
  run locked_slug haus bare
  [ -z "$output" ]
  run locked_slug haus nosuchinput
  [ -z "$output" ]
}

# ── try-batch: a per-repo integration checkout wins over worktree + main ───────

@test "local_src prefers a batch integration checkout over the active worktree" {
  BATCH_SRC[nebelung]="/tmp/batch/nebelung"
  # even when this same repo is also the active worktree, the batch tree wins…
  WT_REPO="nebelung" WT_PATH="/tmp/wt/nebelung"
  run local_src nebelung
  [ "$output" = "/tmp/batch/nebelung" ]
  # …and a repo with no batch entry still resolves to its main checkout.
  run local_src pounce
  [ "$output" = "$ROOT/pounce" ]
}

@test "overrides points a batched repo at its integration tree, the rest at main" {
  BATCH_SRC[pounce]="/tmp/batch/pounce"
  run overrides
  [[ "$output" == *"--override-input mydesktop/pounce path:/tmp/batch/pounce"* ]]
  [[ "$output" == *"--override-input mydesktop/nebelung path:$ROOT/nebelung"* ]]
  [[ "$output" == *"--override-input mydesktop path:$ROOT/haus"* ]]
}

# ── bench try lane: build a pane's worktree + every scruff-child alongside it ────
#
# scruff's registry only ever records a ONE-HOP parent pointer per row (the
# spawning pane's own checkout path) — never a children list, deliberately.
# lane_paths/detect_lane do the walk bench-side: start at a checkout, pull in
# any row whose `parent` matches something already found, transitively.

@test "local_src prefers a lane child checkout over its main checkout" {
  LANE_SRC[scruff]="/tmp/lane/scruff"
  WT_REPO="pounce" WT_PATH="/tmp/wt/pounce"
  run local_src scruff
  [ "$output" = "/tmp/lane/scruff" ]
  # the active worktree's own repo is untouched by LANE_SRC…
  run local_src pounce
  [ "$output" = "/tmp/wt/pounce" ]
  # …and an uninvolved repo still falls back to its main checkout.
  run local_src perch
  [ "$output" = "$ROOT/perch" ]
}

@test "local_src prefers a batch integration checkout over a lane child" {
  BATCH_SRC[scruff]="/tmp/batch/scruff"
  LANE_SRC[scruff]="/tmp/lane/scruff"
  run local_src scruff
  [ "$output" = "/tmp/batch/scruff" ]
}

@test "overrides points a lane child at its checkout, honouring the active worktree too" {
  WT_REPO="pounce" WT_PATH="/tmp/wt/pounce"
  LANE_SRC[haus]="/tmp/lane/haus"
  run overrides
  [[ "$output" == *"--override-input mydesktop path:/tmp/lane/haus"* ]]
  [[ "$output" == *"--override-input mydesktop/pounce path:/tmp/wt/pounce"* ]]
  [[ "$output" == *"--override-input mydesktop/nebelung path:$ROOT/nebelung"* ]]
}

mkregistry() { # mkregistry <file> <row>... — one "name main branch path parent agent" per row
  local file="$1"; shift
  : >"$file"
  local row
  for row in "$@"; do printf '%s\n' "$row" | tr ' ' '\t' >>"$file"; done
}

@test "lane_paths returns just self when there's no registry" {
  WT_REGISTRY="$TMP/no-such-registry.tsv"
  run lane_paths /tmp/wt/pounce
  [ "$output" = "/tmp/wt/pounce" ]
}

@test "lane_paths walks scruff-child rows transitively, ignoring unrelated ones" {
  WT_REGISTRY="$TMP/registry.tsv"
  mkregistry "$WT_REGISTRY" \
    "child1 $ROOT/haus worktree-child1 /tmp/wt/haus /tmp/wt/pounce claude" \
    "grandchild $ROOT/nebelung worktree-grandchild /tmp/wt/nebelung /tmp/wt/haus claude" \
    "other $ROOT/perch worktree-other /tmp/wt/perch /tmp/some-other-pane claude"
  run lane_paths /tmp/wt/pounce
  [[ "$output" == *"/tmp/wt/pounce"* ]]
  [[ "$output" == *"/tmp/wt/haus"* ]]
  [[ "$output" == *"/tmp/wt/nebelung"* ]]
  [[ "$output" != *"/tmp/wt/perch"* ]]
}

@test "wt_branch names a branch, a detached tree, and a checkout that's gone" {
  # The regression: `set -euo pipefail` + a bare assignment from a git that
  # exits 128 (a worktree dir deleted without a prune — a pane killed without
  # the remove hook) aborted the WHOLE status run, silently, before the lock
  # and release sections. And a detached tree exits 0 printing nothing, so an
  # `|| echo` fallback can't cover it — the column came out blank.
  mkmain haus
  git -C "$ROOT/haus" worktree add -q -b worktree-blue "$TMP/wt-blue"
  run wt_branch "$TMP/wt-blue"
  [ "$status" -eq 0 ]
  [ "$output" = "worktree-blue" ]

  git -C "$ROOT/haus" worktree add -q --detach "$TMP/wt-det"
  run wt_branch "$TMP/wt-det"
  [ "$status" -eq 0 ]
  [ "$output" = "(detached)" ]

  rm -rf "$TMP/wt-gone"
  run wt_branch "$TMP/wt-gone"
  [ "$status" -eq 0 ]
  [ "$output" = "?" ]
}

@test "lane_table renders a live lane, a parked one, and a stale branch" {
  # The render loop itself: two defects (a tilde-mangled path fed back to git,
  # so every lane read clean; an unclamped parked branch shearing the table)
  # both survived a green suite of helper-only tests.
  mkmain haus
  WT_REGISTRY="$TMP/registry.tsv"
  git -C "$ROOT/haus" worktree add -q -b worktree-live "$TMP/live"
  echo scratch >"$TMP/live/uncommitted"
  # a branch with an unmerged commit, no checkout and no registry row: a corpse
  git -C "$ROOT/haus" worktree add -q -b worktree-dead "$TMP/dead"
  git -C "$TMP/dead" -c user.name=t -c user.email=t@t commit -q --allow-empty -m two
  git -C "$ROOT/haus" worktree remove --force "$TMP/dead"
  mkregistry "$WT_REGISTRY" \
    "live $ROOT/haus worktree-live $TMP/live $ROOT/haus claude" \
    "gone $ROOT/haus worktree-gone $TMP/no-such-checkout $ROOT/haus claude" \
    "alien /Users/someone/other worktree-alien /wt/alien /Users/someone/other claude"

  run lane_table
  [ "$status" -eq 0 ]
  [[ "$output" == *"worktree-live"* ]]
  [[ "$output" == *"dirty"* ]]                       # the checkout really is dirty
  [[ "$output" == *"(parked — 'scruff gone' to resume"* ]]
  [[ "$output" == *"worktree-dead"* && "$output" == *"stale branch"* ]]
  [[ "$output" == *"scruff reap"* ]]                   # a live lane exists to reap
  [[ "$output" != *"alien"* ]]                       # somebody else's repo
}

@test "lane_table prints nothing at all when there are no lanes and no corpses" {
  mkmain haus
  WT_REGISTRY="$TMP/no-such-registry.tsv"
  run lane_table
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "lane_table clamps a long branch on a parked row too" {
  WT_REGISTRY="$TMP/registry.tsv"
  mkregistry "$WT_REGISTRY" \
    "gone $ROOT/haus worktree-gone-with-a-very-long-lane-name-indeed $TMP/nope $ROOT/haus claude"
  run lane_table
  [[ "$output" == *"worktree-gone-with-a-very-long-…"* ]]
}

@test "lane_rows keeps hausfold + host-config lanes and drops everyone else's" {
  # bench lists scruff's registry, not `git worktree list` — git's answer includes
  # hand-made trees scruff never made and `scruff reap` will never sweep, which is
  # what made the two tools look permanently out of sync. The registry is
  # machine-wide, so a lane in an unrelated repo is filtered out here.
  WT_REGISTRY="$TMP/registry.tsv"
  CONSUMER="$TMP/hostcfg"
  mkregistry "$WT_REGISTRY" \
    "lane1 $ROOT/haus worktree-lane1 /wt/haus $ROOT/haus claude" \
    "site $ROOT/hausfold.co worktree-site /wt/site $ROOT/hausfold.co codex" \
    "shop $ROOT worktree-shop /wt/shop $ROOT claude" \
    "host $TMP/hostcfg worktree-host /wt/host $TMP/hostcfg claude" \
    "alien /Users/someone/work/other worktree-alien /wt/alien /Users/someone/work/other claude"
  run lane_rows
  [ "$status" -eq 0 ]
  [[ "$output" == *"worktree-lane1"* ]]   # a family repo
  [[ "$output" == *"worktree-site"* ]]    # hausfold, not family, still ours
  [[ "$output" == *"worktree-shop"* ]]    # the workshop itself
  [[ "$output" == *"worktree-host"* ]]    # ~/.config/nix
  [[ "$output" != *"worktree-alien"* ]]   # somebody else's repo
  [ "$(printf '%s\n' "$output" | wc -l | tr -d ' ')" = 4 ]
}

@test "lane_rows emits repo, branch, checkout and lane name, tab separated" {
  WT_REGISTRY="$TMP/registry.tsv"
  mkregistry "$WT_REGISTRY" "lane1 $ROOT/haus worktree-lane1 /wt/haus $ROOT/haus claude"
  run lane_rows
  [ "$output" = "$(printf '%s\t%s\t%s\t%s' "$ROOT/haus" worktree-lane1 /wt/haus lane1)" ]
}

@test "lane_rows says nothing when scruff has never written a registry" {
  WT_REGISTRY="$TMP/no-such-registry.tsv"
  run lane_rows
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "lane_label names the workshop and the host config, not their basenames" {
  CONSUMER="$TMP/hostcfg"
  run lane_label "$ROOT"; [ "$output" = workshop ]
  run lane_label "$TMP/hostcfg"; [ "$output" = consumer ]
  run lane_label "$ROOT/hausfold.co"; [ "$output" = hausfold.co ]
}

@test "dirty_cell is six COLUMNS wide either way" {
  # `·` is two BYTES and one column, so printf '%-6s' pads it to six bytes —
  # five columns — and shears every column to its right.
  run dirty_cell dirty
  [ "$output" = "dirty " ]
  run dirty_cell '·'
  [ "$output" = "·     " ]
}

@test "detect_lane populates LANE_SRC for every scruff child, mapped to its family repo" {
  mkmain pounce
  # detect_lane's self-lookup is `git rev-parse --show-toplevel` (no -C), which
  # resolves symlinks (/tmp → /private/tmp on macOS) — match that here, exactly
  # like BATCH_SCRATCH's `pwd -P` does elsewhere in bench, or self never matches
  # the registry row bats' own $TMP wrote with the unresolved path.
  local self; self="$(cd "$ROOT/pounce" && git rev-parse --show-toplevel)"
  WT_REGISTRY="$TMP/registry.tsv"
  mkregistry "$WT_REGISTRY" \
    "child1 $ROOT/haus worktree-child1 $ROOT/haus-child $self claude" \
    "grandchild $ROOT/nebelung worktree-grandchild $ROOT/nebelung-child $ROOT/haus-child claude" \
    "other $ROOT/perch worktree-other $ROOT/perch-other /some/other/pane claude"
  cd "$ROOT/pounce" && detect_lane
  [ "${LANE_SRC[haus]}" = "$ROOT/haus-child" ]
  [ "${LANE_SRC[nebelung]}" = "$ROOT/nebelung-child" ]
  [ -z "${LANE_SRC[perch]:-}" ]
}

# ── ensure_nix_path: nix on PATH for a caller with no login shell ─────────────
# Regression: the layer binds ⌘B straight to `bench try lane switch` via a
# zellij `Run`, which execs bench from the zellij server's environment. That
# PATH carries /run/current-system/sw/bin (so bash 5 resolves) but NOT
# /nix/var/nix/profiles/default/bin, where nix actually lives — so bench got
# as far as announcing a build and died on `nix: command not found`.

@test "ensure_nix_path appends a nix bindir the caller's PATH is missing" {
  mkdir -p "$TMP/nixbin"
  : >"$TMP/nixbin/nix"; chmod +x "$TMP/nixbin/nix"
  NIX_BINDIRS=("$TMP/nixbin")
  PATH="$TMP/empty"          # no nix reachable
  ensure_nix_path
  [[ ":$PATH:" == *":$TMP/nixbin:"* ]]
  command -v nix >/dev/null
}

@test "ensure_nix_path leaves PATH alone when nix already resolves" {
  mkdir -p "$TMP/mine" "$TMP/nixbin"
  : >"$TMP/mine/nix"; chmod +x "$TMP/mine/nix"
  NIX_BINDIRS=("$TMP/nixbin")
  PATH="$TMP/mine"
  ensure_nix_path
  [ "$PATH" = "$TMP/mine" ]   # a caller's own nix is never shadowed or duplicated
}

@test "ensure_nix_path never appends a bindir PATH already carries" {
  mkdir -p "$TMP/nixbin" "$TMP/other"
  NIX_BINDIRS=("$TMP/nixbin")
  PATH="$TMP/other:$TMP/nixbin"   # already there, but nix isn't in it yet
  ensure_nix_path
  [ "$PATH" = "$TMP/other:$TMP/nixbin" ]
}

@test "ensure_nix_path can't put the current directory on PATH via an empty one" {
  mkdir -p "$TMP/nixbin"
  NIX_BINDIRS=("$TMP/nixbin")
  PATH=""                        # a leading colon would mean "." to the shell
  ensure_nix_path
  [ "$PATH" = "$TMP/nixbin" ]
}

@test "ensure_nix_path skips bindirs that don't exist on this machine" {
  NIX_BINDIRS=("$TMP/not-a-dir")
  PATH="$TMP/empty"
  ensure_nix_path
  [[ ":$PATH:" != *":$TMP/not-a-dir:"* ]]
}

@test "host_name dies on missing nix instead of guessing a host that can't build" {
  NIX_BINDIRS=("$TMP/not-a-dir")
  PATH="$TMP/empty"
  run host_name
  [ "$status" -ne 0 ]
  # The old code fell through to `hostname -s` here, so bench announced it was
  # building a darwinConfiguration the consumer flake has never heard of
  # ("Mac") and only then died on the next line. Fail on the real cause.
  [[ "$output" == *"nix isn't on PATH"* ]]
}

# ── version_file / read_version: the release tag source (regression: $verfile) ─

@test "version_file locates pounce's version source" {
  run version_file pounce
  [ "$output" = "$ROOT/pounce/pkgs/pounce/default.nix" ]
}

@test "version_file rejects a non-releasable repo" {
  run version_file nebelung
  [ "$status" -ne 0 ]
}

@test "read_version extracts the version from pounce's default.nix" {
  mkdir -p "$ROOT/pounce/pkgs/pounce"
  cat >"$ROOT/pounce/pkgs/pounce/default.nix" <<'NIX'
{ lib }:
stdenv.mkDerivation {
  pname = "pounce";
  version = "1.4.2";
}
NIX
  run read_version pounce
  [ "$output" = "1.4.2" ]
}

@test "read_version reads and trims haus's VERSION file" {
  mkdir -p "$ROOT/haus"
  printf '  0.3.0\n' >"$ROOT/haus/VERSION"
  run read_version haus
  [ "$output" = "0.3.0" ]
}

# ── write_version: stamp a (date) version back into the source, round-tripping ─

@test "write_version stamps pounce's default.nix, leaving POUNCE_VERSION alone" {
  mkdir -p "$ROOT/pounce/pkgs/pounce"
  cat >"$ROOT/pounce/pkgs/pounce/default.nix" <<'NIX'
{ lib }:
stdenv.mkDerivation {
  pname = "pounce";
  version = "0.5.8";
  buildPhase = ''
    POUNCE_VERSION="$version" bash ./build.sh
  '';
}
NIX
  write_version pounce 2026.07.18
  run read_version pounce
  [ "$output" = "2026.07.18" ]
  # the shell-var line that also says "version" must survive untouched
  grep -q 'POUNCE_VERSION="\$version"' "$ROOT/pounce/pkgs/pounce/default.nix"
}

@test "write_version round-trips a same-day -N version through haus's VERSION" {
  mkdir -p "$ROOT/haus"
  printf '0.5.8\n' >"$ROOT/haus/VERSION"
  write_version haus 2026.07.18-1
  run read_version haus
  [ "$output" = "2026.07.18-1" ]
}

# ── version_scheme: scruff is the one repo whose number is a judgement ────────

@test "version_scheme is calver for the tag-and-forget repos" {
  for repo in pounce perch haus; do
    run version_scheme "$repo"
    [ "$output" = calver ]
  done
}

@test "version_scheme is semver for scruff" {
  run version_scheme scruff
  [ "$output" = semver ]
}

@test "version_file locates scruff's VERSION" {
  run version_file scruff
  [ "$output" = "$ROOT/scruff/VERSION" ]
}

@test "read_version reads and trims scruff's VERSION file" {
  mkdir -p "$ROOT/scruff"
  printf '0.1.0\n' >"$ROOT/scruff/VERSION"
  run read_version scruff
  [ "$output" = "0.1.0" ]
}

# scruff's version lives in four files, so write_version delegates to the repo's
# own script rather than learning three manifest shapes. What's asserted here is
# the HANDOFF — that bench calls it with the version — not the script's own
# behaviour, which scruff tests where it lives.
@test "write_version delegates scruff to the repo's stamp script" {
  mkdir -p "$ROOT/scruff/script"
  cat >"$ROOT/scruff/script/stamp-version.sh" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$1" > "$(dirname "$0")/../VERSION"
echo "stamped $1"
SH
  chmod +x "$ROOT/scruff/script/stamp-version.sh"
  write_version scruff 0.2.0
  run read_version scruff
  [ "$output" = "0.2.0" ]
}

# A checkout that predates the release flow has no stamp script, and the failure
# has to name the fix rather than surfacing as a bare "no such file".
@test "write_version refuses scruff when the stamp script is missing" {
  mkdir -p "$ROOT/scruff"
  run write_version scruff 0.2.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"stamp-version.sh"* ]]
  [[ "$output" == *"bench pull scruff"* ]]
}

# ── next_version: today's date, with -N on a same-day repeat ───────────────────

@test "next_version is the bare date when nothing is tagged today" {
  make_repo pounce
  run next_version pounce
  [ "$output" = "$(date +%Y.%m.%d)" ]
}

@test "next_version appends -1 when today's bare date is already tagged" {
  make_repo pounce
  git -C "$ROOT/pounce" tag "v$(date +%Y.%m.%d)"
  run next_version pounce
  [ "$output" = "$(date +%Y.%m.%d)-1" ]
}

@test "next_version keeps counting -N past existing same-day releases" {
  make_repo pounce
  today="$(date +%Y.%m.%d)"
  git -C "$ROOT/pounce" tag "v$today"
  git -C "$ROOT/pounce" tag "v$today-1"
  git -C "$ROOT/pounce" tag "v$today-2"
  run next_version pounce
  [ "$output" = "$today-3" ]
}

# ── the release watch: rendering a `gh run view` blob into job rows ────────────
# Only the pure part is tested — turning CI's JSON into state/name/detail rows.
# The paint loop needs a TTY and a live run, so it isn't reachable from here.

render_run() { printf '%s' "$1" | python3 -c "$WATCH_RENDER_PY"; }

@test "the watch renders a finished run as ✓ rows plus a RUN verdict" {
  run render_run '{"status":"completed","conclusion":"success","jobs":[
    {"name":"build + publish release","status":"completed","conclusion":"success",
     "startedAt":"2026-08-02T10:00:00Z","completedAt":"2026-08-02T10:02:41Z"},
    {"name":"bump hausfold/homebrew-tap","status":"completed","conclusion":"success",
     "startedAt":"2026-08-02T10:02:41Z","completedAt":"2026-08-02T10:02:50Z"}]}'
  [ "$status" -eq 0 ]
  # Trailing empty field: a FINISHED job's duration is final, so it carries no
  # start epoch for the paint loop to keep counting from.
  [ "${lines[0]}" = "ok	build + publish release	2m 41s	" ]
  [ "${lines[1]}" = "ok	bump hausfold/homebrew-tap	9s	" ]
  [ "${lines[2]}" = "RUN	completed	success" ]
}

@test "a RUNNING job carries its start epoch so the paint loop can clock it live" {
  # This is what decouples the display from the poll: the seconds tick locally
  # once a second even though `gh run view` is only called every few.
  run render_run '{"status":"in_progress","conclusion":null,"jobs":[
    {"name":"build + publish release","status":"in_progress","conclusion":null,
     "startedAt":"2026-08-02T10:00:00Z","completedAt":"0001-01-01T00:00:00Z"}]}'
  [ "$status" -eq 0 ]
  # 2026-08-02T10:00:00Z as a unix epoch.
  [ "$(printf '%s' "${lines[0]}" | cut -f4)" = "1785664800" ]
  [ "$(printf '%s' "${lines[0]}" | cut -f1)" = "run" ]
}

@test "a job that hasn't started reads as queued, not as a 2000-year runtime" {
  # GitHub hands back a year-1 timestamp for a job that never began; without the
  # guard that subtraction renders as an absurd duration.
  run render_run '{"status":"in_progress","conclusion":null,"jobs":[
    {"name":"bump hausfold/homebrew-tap","status":"queued","conclusion":null,
     "startedAt":"0001-01-01T00:00:00Z","completedAt":"0001-01-01T00:00:00Z"}]}'
  [ "${lines[0]}" = "wait	bump hausfold/homebrew-tap	queued	" ]
  [ "${lines[1]}" = "RUN	in_progress	" ]
}

@test "a failed job renders as fail and a skipped one says so" {
  run render_run '{"status":"completed","conclusion":"failure","jobs":[
    {"name":"build + publish release","status":"completed","conclusion":"failure",
     "startedAt":"2026-08-02T10:00:00Z","completedAt":"2026-08-02T10:01:35Z"},
    {"name":"bump hausfold/homebrew-tap","status":"completed","conclusion":"skipped",
     "startedAt":"0001-01-01T00:00:00Z","completedAt":"0001-01-01T00:00:00Z"}]}'
  [ "${lines[0]}" = "fail	build + publish release	1m 35s	" ]
  [ "${lines[1]}" = "skip	bump hausfold/homebrew-tap	skipped	" ]
  [ "${lines[2]}" = "RUN	completed	failure" ]
}

@test "the renderer hands the painter the WHOLE job name" {
  # It used to clamp to 34 chars to protect the repaint from a soft-wrap. The
  # painter measures the window now, so a clamp here would only ever be a guess
  # at a width — and it guessed 34 for every terminal alive.
  run render_run '{"status":"completed","conclusion":"success","jobs":[
    {"name":"an absurdly long job name that would certainly wrap a narrow terminal",
     "status":"completed","conclusion":"success",
     "startedAt":"2026-08-02T10:00:00Z","completedAt":"2026-08-02T10:00:05Z"}]}'
  [ "${lines[0]}" = "ok	an absurdly long job name that would certainly wrap a narrow terminal	5s	" ]
}

@test "watch_paint hands snug one row record per job plus a paint, with the clock re-derived" {
  # The coprocess contract: records exactly in `snug run`'s grammar. fd 9 is a
  # stand-in for the coprocess — watch_paint only ever WRITES records there and
  # never reads back, so a plain file proves the framing.
  local now since r1
  now="$(date +%s)"; since=$(( now - 65 ))   # 1m 05s ago
  # A real renderer row for a running job: detail is its (stale) duration, and
  # only the LAST field may be empty — `read` collapses consecutive tabs, so a
  # row can never carry an empty field between two non-empty ones.
  printf -v r1 'run\tbuild + publish release\t0s\t%s' "$since"
  WATCH_ROWS=( "$r1" $'ok\tbump-tap\t12s\t' )
  : >"$TMP/records"
  exec 9>"$TMP/records"
  SNUG_FD=9; SNUG_PID=""; SNUG_TRIED=1   # fd 9 stands in; no coprocess fork
  watch_paint >/dev/null 2>&1
  snug_close >/dev/null 2>&1
  exec 9>&-
  SNUG_FD=""
  run grep -c '^row' "$TMP/records"
  [ "$output" = "2" ]
  grep -q '^paint$' "$TMP/records"
  # A running job's clock is re-derived from its start epoch, not trusted from
  # the (already stale) snapshot — 65s ago renders 1m 05s. (Regex, not a
  # literal: the test's `now` and the resolver's can straddle a second.)
  grep -q $'run\tbuild + publish release\t[0-9]*m [0-9][0-9]s' "$TMP/records"
  grep -q $'ok\tbump-tap\t12s' "$TMP/records"
  grep -q '^end$' "$TMP/records"
}

@test "watch_paint prints one plain line per state CHANGE, not per frame, with no snug at all" {
  # No coprocess, no ui.sh: the glyph carries the meaning and a line is only
  # drawn when a row's state changes — the piped/CI shape. `run` is a subshell,
  # so the dedupe map wouldn't survive between calls: paint twice in one body.
  UI_READY=""; SNUG_FD=""
  WATCH_SEEN=()
  WATCH_ROWS=( $'run\tbump-tap\t\t' $'ok\tlint\t5s\t' )
  watch_two() { watch_paint; WATCH_ROWS=( $'ok\tbump-tap\t12s\t' $'ok\tlint\t5s\t' ); watch_paint; WATCH_ROWS=( $'ok\tbump-tap\t12s\t' $'ok\tlint\t5s\t' ); watch_paint; }
  run watch_two
  [ "$status" -eq 0 ]
  # run->·, lint->✓, then one change (run->ok), then nothing.
  [ "${#lines[@]}" -eq 3 ]
  [[ "$output" == *$'\u2713  bump-tap (12s)'* ]]
  [[ "$output" == *$'\u00b7  bump-tap ()'* ]]
}

@test "watch_paint routes through ui.sh's live region when snug the binary is absent" {
  # The fallback painter: same records, lower fidelity. Stubbed, because what
  # this test owns is the DISPATCH — bench fed the rows to ui_row and painted
  # one frame per call — not ui.sh's rendering, which snug's own suite sweeps
  # at widths 2–200. Stubs (not the real functions) also make this pass on CI,
  # where ui.sh never loads.
  SNUG_FD=""
  UI_READY=1
  WATCH_ROWS=( $'run\tbump-tap\t\t' $'ok\tlint\t5s\t' )
  ui_log="$TMP/ui.log"; : >"$ui_log"
  ui_clear() { echo -n 'clear;' >>"$ui_log_file"; }
  ui_row()   { printf 'row:%s:%s:%s;' "$1" "$2" "$3" >>"$ui_log_file"; }
  ui_paint() { echo -n 'paint;' >>"$ui_log_file"; }
  ui_log_file="$ui_log"
  watch_two() { watch_paint; WATCH_ROWS=( $'ok\tbump-tap\t12s\t' $'ok\tlint\t5s\t' ); watch_paint; }
  run watch_two
  [ "$status" -eq 0 ]
  [[ "$(cat "$ui_log")" == "clear;row:run:bump-tap:;row:ok:lint:5s;paint;clear;row:ok:bump-tap:12s;row:ok:lint:5s;paint;" ]]
}


@test "bench's records parse as snug records: the binary itself renders them" {
  # The record grammar is the contract between two repos; a mismatch would pass
  # every grep above and fail on the first real `bench release`. So feed the
  # exact bytes watch_paint emits to a real `snug run` and make it render. Skips
  # where snug isn't installed (CI) — the pty it can't be tested without, but
  # every haus machine has the binary.
  command -v snug >/dev/null 2>&1 || skip "snug not on PATH"
  SNUG_FD=""; SNUG_PID=""; SNUG_TRIED=""
  WATCH_ROWS=( $'ok\tbump-tap\t12s\t' )
  : >"$TMP/records"
  exec 9>"$TMP/records"
  SNUG_FD=9; SNUG_TRIED=1
  say "hello records" >/dev/null 2>&1
  watch_paint >/dev/null 2>&1
  snug_close >/dev/null 2>&1
  exec 9>&-
  SNUG_FD=""
  run snug run <"$TMP/records"
  [ "$status" -eq 0 ]
  [[ "$output" != *"unknown record"* ]]
  [[ "$output" == *"hello records"* ]]
  [[ "$output" == *"bump-tap"* ]]
  # Every message verb rides the same grammar — feed one record each. (There
  # is no `fail` wrapper: bench's verb is `die`, which exits. `snug_emit fail`
  # is the exact path the wrapper takes.)
  : >"$TMP/records"
  exec 9>"$TMP/records"
  SNUG_FD=9; SNUG_TRIED=1
  warn "a warn" >/dev/null 2>&1
  hint "a hint" >/dev/null 2>&1
  snug_emit fail "a fail" >/dev/null 2>&1
  snug_close >/dev/null 2>&1
  exec 9>&-
  SNUG_FD=""
  run snug run <"$TMP/records"
  [ "$status" -eq 0 ]
  [[ "$output" != *"unknown record"* ]]
  [[ "$output" == *"a warn"* ]]
  [[ "$output" == *"a hint"* ]]
  [[ "$output" == *"a fail"* ]]
}

# ── latest_tag / commits_since: the release-edge staleness check ───────────────

make_repo() { # make_repo <name> — a fixture git repo with one commit
  mkdir -p "$ROOT/$1"
  git -C "$ROOT/$1" init -q
  git -C "$ROOT/$1" -c user.name=t -c user.email=t@t commit -q --allow-empty -m one
}

@test "latest_tag picks the newest v* tag by version order, not lexically" {
  make_repo pounce
  git -C "$ROOT/pounce" tag v0.9.0
  git -C "$ROOT/pounce" tag v0.10.0
  run latest_tag pounce
  [ "$output" = "v0.10.0" ]
}

@test "latest_tag is empty when a repo has no tags" {
  make_repo pounce
  run latest_tag pounce
  [ "$output" = "" ]
}

@test "latest_tag ignores tags that don't look like releases" {
  make_repo pounce
  git -C "$ROOT/pounce" tag v0.1.0
  git -C "$ROOT/pounce" tag experiment
  run latest_tag pounce
  [ "$output" = "v0.1.0" ]
}

@test "commits_since counts commits on HEAD past the tag" {
  make_repo haus
  git -C "$ROOT/haus" tag v0.2.0
  git -C "$ROOT/haus" -c user.name=t -c user.email=t@t commit -q --allow-empty -m two
  git -C "$ROOT/haus" -c user.name=t -c user.email=t@t commit -q --allow-empty -m three
  run commits_since haus v0.2.0
  [ "$output" = "2" ]
}

@test "commits_since is 0 when the tag is at HEAD" {
  make_repo haus
  git -C "$ROOT/haus" tag v0.2.0
  run commits_since haus v0.2.0
  [ "$output" = "0" ]
}

@test "commits_since degrades to ? on a bogus ref" {
  make_repo haus
  run commits_since haus v9.9.9
  [ "$output" = "?" ]
}

@test "docs_watermark is empty when no sweep has ever run" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  run docs_watermark pounce
  [ "$output" = "" ]
}

@test "docs_watermark reads the rev a previous sweep recorded" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  cat > "$DOCS_STATE" <<'JSON'
{"repos": {"pounce": {"rev": "deadbeef"}}, "last_run": "2026-07-20T05:00:00-05:00"}
JSON
  run docs_watermark pounce
  [ "$output" = "deadbeef" ]
}

@test "docs_watermark is empty for a repo the state file doesn't know" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  echo '{"repos": {"pounce": {"rev": "deadbeef"}}}' > "$DOCS_STATE"
  run docs_watermark perch
  [ "$output" = "" ]
}

@test "docs_watermark degrades to empty on malformed state (never crashes the sweep)" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  echo 'not json at all' > "$DOCS_STATE"
  run docs_watermark pounce
  [ "$output" = "" ]
}

# ── docs-since --mark: the watermark must track main, never the current HEAD ──
# A sweep ends sitting on its own docs-sync-* PR branch. Marking HEAD there parks
# the watermark on a commit main doesn't contain, and every later run re-reads
# from a bogus base.

@test "docs-since --mark records main's tip, not the branch the sweep is sitting on" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  local main_rev; main_rev="$(git -C "$ROOT/pounce" rev-parse main)"
  # Simulate the end of a sweep: on a docs branch, one commit ahead of main.
  git -C "$ROOT/pounce" checkout -q -b docs-sync-2026-07-20
  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "docs: sync"
  [ "$(git -C "$ROOT/pounce" rev-parse HEAD)" != "$main_rev" ]   # HEAD really has diverged

  cmd_docs_since --mark >/dev/null 2>&1
  run docs_watermark pounce
  [ "$output" = "$main_rev" ]
}

@test "docs-since --mark falls back to HEAD in a repo with no main branch" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M trunk
  local head_rev; head_rev="$(git -C "$ROOT/pounce" rev-parse HEAD)"

  cmd_docs_since --mark >/dev/null 2>&1
  run docs_watermark pounce
  [ "$output" = "$head_rev" ]
}

# ── docs-since skips the sweep's own commits ──────────────────────────────────
# Doc PRs land on main like anything else. Without the Docs-Sync trailer filter
# the routine reads yesterday's output as today's input, every day, forever.

@test "docs-since skips commits carrying the Docs-Sync trailer" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  cmd_docs_since --mark >/dev/null 2>&1          # watermark at the first commit

  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty \
    -m "docs: sync 2026-07-20

Docs-Sync: 2026-07-20"
  run cmd_docs_since
  [[ "$output" == *"nothing new since the last docs sweep"* ]]
}

@test "docs-since still reports real work landed alongside a swept commit" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  cmd_docs_since --mark >/dev/null 2>&1

  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty \
    -m "docs: sync 2026-07-20

Docs-Sync: 2026-07-20"
  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty \
    -m "feat: a real behavior change"
  run cmd_docs_since
  [[ "$output" == *"a real behavior change"* ]]
  [[ "$output" != *"docs: sync 2026-07-20"* ]]
  [[ "$output" == *"(1 commits)"* ]]            # count matches what's shown
}

# ── the usage header and the sed that prints it must not drift apart ─────────
# `bench <garbage>` prints the header with a hardcoded line range. Grow the
# header and the range silently truncates it — which is how the paragraph about
# scruff needing an explicit semver argument went missing.

@test "bench <garbage> prints the usage header all the way to its last line" {
  local last; last="$(awk '/^# Rule of thumb/ {print NR - 2; exit}' "$HAUS")"
  local want; want="$(sed -n "${last}p" "$HAUS" | sed 's/^# \{0,1\}//')"
  run bash "$HAUS" definitely-not-a-subcommand
  [ "$status" -ne 0 ]
  [[ "$output" == *"$want"* ]]
}

# ── the read/landed split: an unmerged doc PR must not read as a clean repo ───
# One watermark meant "read" and "documented" were the same number. They part
# company the moment a sweep opens a PR nobody merges: those commits are marked
# read forever and no later run ever looks at them again — the docs stay wrong
# and the sweep reports itself clean. `landed` is what makes that gap sayable.

@test "docs_landed reads the pre-split single rev, so a legacy state shows no false gap" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  echo '{"repos": {"pounce": {"rev": "deadbeef"}}}' > "$DOCS_STATE"
  run docs_landed pounce
  [ "$output" = "deadbeef" ]
  run docs_watermark pounce
  [ "$output" = "deadbeef" ]                    # and `read` still answers too
}

@test "docs-since --mark with nothing pending moves read and landed together" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main

  cmd_docs_since --mark >/dev/null 2>&1
  [ "$(docs_watermark pounce)" = "$(docs_landed pounce)" ]
  run cmd_docs_since
  [[ "$output" != *"READ but not landed"* ]]    # no PR outstanding, so no gap
}

@test "docs-since --mark --pending advances read alone, leaving landed behind" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  cmd_docs_since --mark >/dev/null 2>&1         # a baseline both watermarks share
  local was; was="$(docs_landed pounce)"

  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: two"
  cmd_docs_since --mark --pending pounce >/dev/null 2>&1

  [ "$(docs_landed pounce)" = "$was" ]                        # landed did not move
  [ "$(docs_watermark pounce)" != "$was" ]                    # read did
}

@test "docs-since warns about commits read but not landed, and counts them" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  cmd_docs_since --mark >/dev/null 2>&1

  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: two"
  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: three"
  cmd_docs_since --mark --pending pounce >/dev/null 2>&1

  run cmd_docs_since
  [[ "$output" == *"2 commits READ but not landed"* ]]
}

@test "the gap ignores the sweep's own commits, like the range does" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  cmd_docs_since --mark >/dev/null 2>&1

  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: real"
  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty \
    -m "docs: sync 2026-07-20

Docs-Sync: 2026-07-20"
  cmd_docs_since --mark --pending pounce >/dev/null 2>&1

  run cmd_docs_since
  [[ "$output" == *"1 commits READ but not landed"* ]]
}

@test "docs-since --landed closes the gap it was warning about" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  cmd_docs_since --mark >/dev/null 2>&1
  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: two"
  cmd_docs_since --mark --pending pounce >/dev/null 2>&1
  run cmd_docs_since
  [[ "$output" == *"READ but not landed"* ]]

  cmd_docs_since --landed pounce >/dev/null 2>&1
  [ "$(docs_landed pounce)" = "$(docs_watermark pounce)" ]
  run cmd_docs_since
  [[ "$output" != *"READ but not landed"* ]]
}

@test "docs-since --landed refuses to default to every repo" {
  # --landed is the ONLY thing that closes a gap. Defaulting to all of them
  # would put the family's whole outstanding state one keystroke from erased.
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce perch)
  run cmd_docs_since --landed
  [ "$status" -ne 0 ]
  [[ "$output" == *"name the repos whose doc PR merged"* ]]
}

@test "docs-since --landed takes several repos in one pass" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce perch)
  make_repo pounce; git -C "$ROOT/pounce" branch -M main
  make_repo perch;  git -C "$ROOT/perch"  branch -M main
  cmd_docs_since --mark >/dev/null 2>&1
  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: two"
  git -C "$ROOT/perch"  -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: two"
  cmd_docs_since --mark --pending pounce perch >/dev/null 2>&1

  cmd_docs_since --landed pounce perch >/dev/null 2>&1
  [ "$(docs_landed pounce)" = "$(docs_watermark pounce)" ]
  [ "$(docs_landed perch)"  = "$(docs_watermark perch)" ]
}

# ── the gap must outlive a --mark that forgot about it ────────────────────────
# The ordinary shape of the bug: a repo whose doc PR is open but which produced
# no commits this run, so the sweep has no reason to name it --pending. If
# --mark closed its gap the whole split would be decorative.

@test "a repo's gap survives a --mark that doesn't name it pending" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce perch)
  make_repo pounce; git -C "$ROOT/pounce" branch -M main
  make_repo perch;  git -C "$ROOT/perch"  branch -M main
  cmd_docs_since --mark >/dev/null 2>&1

  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: two"
  cmd_docs_since --mark --pending pounce >/dev/null 2>&1
  local held; held="$(docs_landed pounce)"

  # Next run: pounce is quiet and its PR is still open, so only perch is named.
  git -C "$ROOT/perch" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: two"
  cmd_docs_since --mark --pending perch >/dev/null 2>&1

  [ "$(docs_landed pounce)" = "$held" ]
  run cmd_docs_since
  [[ "$output" == *"pounce: 1 commits READ but not landed"* ]]
}

@test "a bare --mark leaves every outstanding gap standing" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  cmd_docs_since --mark >/dev/null 2>&1
  git -C "$ROOT/pounce" -c user.name=t -c user.email=t@t commit -q --allow-empty -m "feat: two"
  cmd_docs_since --mark --pending pounce >/dev/null 2>&1

  cmd_docs_since --mark >/dev/null 2>&1          # the old single-flag form
  run cmd_docs_since
  [[ "$output" == *"READ but not landed"* ]]
}

@test "a repo joining the sweep mid-life gets a gap it can name, not a false count" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(perch)
  make_repo perch
  git -C "$ROOT/perch" branch -M main
  cmd_docs_since --mark --pending perch >/dev/null 2>&1   # first sweep, PR opened

  run cmd_docs_since
  [[ "$output" == *"nothing has ever landed"* ]]
  cmd_docs_since --landed perch >/dev/null 2>&1
  run cmd_docs_since
  [[ "$output" != *"landed"* ]]
}

@test "a landed watermark that was rebased away says so instead of claiming nothing landed" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  cmd_docs_since --mark >/dev/null 2>&1
  python3 - "$DOCS_STATE" <<'JSON'
import json, sys
s = json.load(open(sys.argv[1]))
s["repos"]["pounce"]["landed"] = "0" * 40      # a rev this repo has never held
json.dump(s, open(sys.argv[1], "w"), indent=2)
JSON
  run cmd_docs_since
  [[ "$output" == *"is gone (rebased away?)"* ]]
  [[ "$output" != *"nothing has ever landed"* ]]
}

@test "docs-since refuses --pending without --mark rather than recording nothing" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  run cmd_docs_since --pending pounce
  [ "$status" -ne 0 ]
  [[ "$output" == *"qualifies --mark"* ]]
}

@test "docs-since --landed says nothing moved when nothing had been read" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  run cmd_docs_since --landed pounce
  [[ "$output" == *"nothing read yet"* ]]
  [[ "$output" != *"watermarks caught up"* ]]   # no cheerful green over a no-op
}

@test "docs-since refuses a repo it doesn't sweep rather than silently doing nothing" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  run cmd_docs_since --landed notarepo
  [ "$status" -ne 0 ]
  [[ "$output" == *"not a docs repo"* ]]
}

@test "docs-since refuses an unknown flag rather than reading it as a repo" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  run cmd_docs_since --marc
  [ "$status" -ne 0 ]
  [[ "$output" == *"unknown flag"* ]]
}

@test "docs-since still takes a bare --mark, the way the dispatch used to pass it" {
  DOCS_STATE="$ROOT/.docs-sync.json"
  DOCS_REPOS=(pounce)
  make_repo pounce
  git -C "$ROOT/pounce" branch -M main
  local main_rev; main_rev="$(git -C "$ROOT/pounce" rev-parse main)"
  cmd_docs_since --mark "" >/dev/null 2>&1      # the empty second arg of the old form
  run docs_watermark pounce
  [ "$output" = "$main_rev" ]
}

# ── who is driving: the switch gate is on WHO, not WHERE ──────────────────────
# `bench try switch` is allowed from an agent worktree (that's the only way to
# feel-test ONE unmerged branch). What's gated is an AI agent doing it unasked,
# because activation is machine-wide and serial.

@test "agent_driving is false for a plain human shell" {
  ( unset AI_AGENT CLAUDECODE CLAUDE_CODE_ENTRYPOINT CODEX_SANDBOX OPENCODE OPENCODE_BIN_PATH
    run agent_driving
    [ "$status" -ne 0 ] )
}

@test "agent_driving spots each supported agent's marker" {
  local var
  for var in AI_AGENT CLAUDECODE CLAUDE_CODE_ENTRYPOINT CODEX_SANDBOX OPENCODE OPENCODE_BIN_PATH; do
    ( unset AI_AGENT CLAUDECODE CLAUDE_CODE_ENTRYPOINT CODEX_SANDBOX OPENCODE OPENCODE_BIN_PATH
      export "$var=1"
      run agent_driving
      [ "$status" -eq 0 ] ) || { echo "missed marker: $var"; return 1; }
  done
}

# ── the activation receipt: what is this machine actually running? ────────────

setup_receipt() { # a state file under the test tmpdir, plus fixture checkouts
  STATE_DIR="$TMP/state"; ACTIVE_FILE="$STATE_DIR/activated"
  local name
  for name in "${OVERRIDABLE[@]}"; do
    make_repo "$name"
    git -C "$ROOT/$name" branch -M main
  done
}

@test "record_activation writes nothing when every source is a clean main checkout" {
  setup_receipt
  WT_REPO="" WT_PATH=""
  record_activation mbp
  [ ! -f "$ACTIVE_FILE" ]
}

@test "record_activation names the worktree branch it just activated" {
  setup_receipt
  git -C "$ROOT/haus" worktree add -q -b worktree-blue "$TMP/wt-blue"
  WT_REPO="haus" WT_PATH="$TMP/wt-blue"
  record_activation mbp
  run cat "$ACTIVE_FILE"
  [[ "$output" == *"haus"* ]]
  [[ "$output" == *"worktree-blue"* ]]
  [[ "$output" == *"$TMP/wt-blue"* ]]
  # the untouched repos stay out of it — the receipt lists only what drifted
  [[ "$output" != *"pounce"* ]]
}

@test "record_activation flags a dirty source tree" {
  setup_receipt
  git -C "$ROOT/haus" worktree add -q -b worktree-blue "$TMP/wt-blue"
  echo scratch >"$TMP/wt-blue/uncommitted"
  WT_REPO="haus" WT_PATH="$TMP/wt-blue"
  record_activation mbp
  run cat "$ACTIVE_FILE"
  [[ "$output" == *"dirty"* ]]
}

@test "record_activation records a batch tree as the queue it stood for" {
  setup_receipt
  BATCH_SRC[pounce]="$TMP/batch-pounce"
  mkdir -p "$TMP/batch-pounce"
  record_activation mbp
  run cat "$ACTIVE_FILE"
  [[ "$output" == *"batch: main + open PRs"* ]]
}

@test "read_activation returns the body while the recorded system is live" {
  setup_receipt
  mkdir -p "$STATE_DIR"
  current_system() { echo /nix/store/aaa-system; }
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t/nix/store/aaa-system\nhaus\t/wt/blue\tworktree-blue\tclean\n' >"$ACTIVE_FILE"
  run read_activation
  [ "$status" -eq 0 ]
  [[ "$output" == *"worktree-blue"* ]]
  [ -f "$ACTIVE_FILE" ]
}

@test "read_activation reaps the receipt once the system moved under it" {
  # a haus rollback, a bench rebuild, or anyone else's switch — the receipt
  # must not keep claiming a build that isn't mounted any more.
  setup_receipt
  mkdir -p "$STATE_DIR"
  current_system() { echo /nix/store/bbb-system; }
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t/nix/store/aaa-system\nhaus\t/wt/blue\tworktree-blue\tclean\n' >"$ACTIVE_FILE"
  run read_activation
  [ "$status" -ne 0 ]
  run cat "$ACTIVE_FILE"
  [ "$status" -ne 0 ]                       # the stale file is gone
}

@test "read_activation trusts a receipt written before system-pinning existed" {
  setup_receipt
  mkdir -p "$STATE_DIR"
  current_system() { echo /nix/store/bbb-system; }
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t\nhaus\t/wt/blue\tworktree-blue\tclean\n' >"$ACTIVE_FILE"
  run read_activation
  [ "$status" -eq 0 ]
  [[ "$output" == *"worktree-blue"* ]]
}

@test "status_running says pinned when no receipt is live" {
  setup_receipt
  mkdir -p "$STATE_DIR"
  run status_running
  [[ "$output" == *"running the pinned build"* ]]
}

@test "status_running leads with the local build, and flags a reaped source" {
  setup_receipt
  mkdir -p "$STATE_DIR"
  current_system() { echo /nix/store/aaa-system; }
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t/nix/store/aaa-system\nhaus\t%s/gone-wt\tworktree-blue\tclean\n' "$TMP" >"$ACTIVE_FILE"
  run status_running
  [[ "$output" == *"running LOCAL code"* ]]
  [[ "$output" == *"worktree-blue"* ]]
  [[ "$output" == *"(gone)"* ]]
  [[ "$output" == *"bench rebuild"* ]]
}

@test "status_running reports WHEN the local build was activated" {
  # regression: read_activation is consumed through $(…), so the timestamp has
  # to travel as a line of its output — a global set in that subshell is lost.
  setup_receipt
  mkdir -p "$STATE_DIR"
  current_system() { echo /nix/store/aaa-system; }
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t/nix/store/aaa-system\nhaus\t%s\tworktree-blue\tclean\n' "$ROOT/haus" >"$ACTIVE_FILE"
  run status_running
  [[ "$output" == *"2026-08-03 10:00"* ]]
  [[ "$output" != *"unknown time"* ]]
}

@test "status_running clamps a long branch name so the columns can't shear" {
  setup_receipt
  mkdir -p "$STATE_DIR"
  current_system() { echo /nix/store/aaa-system; }
  printf 'when\tnow\nhost\tmbp\nsystem\t/nix/store/aaa-system\nhaus\t%s\tworktree-an-absurdly-long-agent-branch-name\tclean\n' \
    "$ROOT/haus" >"$ACTIVE_FILE"
  run status_running
  [[ "$output" == *"…"* ]]
  [[ "$output" != *"worktree-an-absurdly-long-agent-branch-name"* ]]
}

# ── bench overlap (earshot) ──────────────────────────────────────────────────
# The design claim these protect: nothing is declared anywhere. Every fact comes
# out of the shared object store, so the tests are all "put real trees on disk
# and ask", never "write a fixture ledger and trust it".

setline() { # setline <file> <n> <text> — portable in-place line edit (no sed -i:
            # BSD wants an argument, GNU refuses one, and CI is the other OS).
  awk -v n="$2" -v t="$3" 'NR == n { print t; next } { print }' "$1" > "$1.tmp"
  mv "$1.tmp" "$1"
}

mkoverlap() { # a repo with lanes: snug (uncommitted, line 12), far (line 50),
              # rival (committed, line 10), and a base editing line 10.
  # pwd -P, not $TMP: on macOS /tmp is a symlink into /private/tmp, and git
  # answers --show-toplevel with the physical path — so a fixture built under
  # the symlinked one would never match its own registry rows.
  mkdir -p "$TMP/ov"
  OV="$(cd "$TMP/ov" && pwd -P)"
  git init -q -b main "$OV/repo"
  git -C "$OV/repo" config user.email t@example.com
  git -C "$OV/repo" config user.name tester
  seq 1 60 > "$OV/repo/doc.md"
  echo untouched > "$OV/repo/other.md"
  git -C "$OV/repo" add -A
  git -C "$OV/repo" commit -qm base
  local l
  for l in snug far rival; do
    git -C "$OV/repo" worktree add -q -b "worktree-$l" "$OV/lanes/$l" main
  done
  # snug: UNCOMMITTED — the half merge-tree structurally cannot see
  setline "$OV/lanes/snug/doc.md" 12 12-snug
  # far: committed, same file, 38 lines away
  setline "$OV/lanes/far/doc.md" 50 50-far
  git -C "$OV/lanes/far" commit -qam "far: the bottom of doc"
  # rival: committed, two lines from snug
  setline "$OV/lanes/rival/doc.md" 10 10-rival
  git -C "$OV/lanes/rival" commit -qam "rival: the top of doc"
  WT_REGISTRY="$TMP/ov-registry.tsv"
  mkregistry "$WT_REGISTRY" \
    "snug $OV/repo worktree-snug $OV/lanes/snug $OV/repo claude" \
    "far $OV/repo worktree-far $OV/lanes/far $OV/repo claude" \
    "rival $OV/repo worktree-rival $OV/lanes/rival $OV/repo claude"
}

@test "hunk_ranges reports the BASE side, so both lanes speak one coordinate system" {
  # -a,b is the ancestor's numbering; +c,d is the lane's own, and two lanes'
  # own numbers drift apart with every insertion above the hunk.
  run bash -c 'printf "%s\n" "diff --git a/f b/f" "--- a/f" "+++ b/f" "@@ -10,4 +14,9 @@" | { '"$(declare -f hunk_ranges)"'; EARSHOT_HUGE=9; hunk_ranges; }'
  [ "$output" = "$(printf 'f\t10\t13')" ]
}

@test "hunk_ranges treats a countless hunk header as exactly one line" {
  run bash -c 'printf "%s\n" "diff --git a/f b/f" "--- a/f" "+++ b/f" "@@ -10 +10 @@" | { '"$(declare -f hunk_ranges)"'; EARSHOT_HUGE=9; hunk_ranges; }'
  [ "$output" = "$(printf 'f\t10\t10')" ]
}

@test "hunk_ranges gives a pure insertion the seam it was inserted into" {
  # "-7,0" touches nothing of the base, but two lanes inserting there still
  # collide — so it claims the join between 7 and 8 rather than nothing at all.
  run bash -c 'printf "%s\n" "diff --git a/f b/f" "--- a/f" "+++ b/f" "@@ -7,0 +8,3 @@" | { '"$(declare -f hunk_ranges)"'; EARSHOT_HUGE=9; hunk_ranges; }'
  [ "$output" = "$(printf 'f\t7\t8')" ]
}

@test "hunk_ranges lets an added file claim everything — add/add always conflicts" {
  run bash -c 'printf "%s\n" "diff --git a/f b/f" "--- /dev/null" "+++ b/f" "@@ -0,0 +1,3 @@" | { '"$(declare -f hunk_ranges)"'; EARSHOT_HUGE=2147483647; hunk_ranges; }'
  [ "$output" = "$(printf 'f\t0\t2147483647')" ]
}

@test "hunk_ranges lets a deleted file claim everything — delete/edit always conflicts" {
  run bash -c 'printf "%s\n" "diff --git a/f b/f" "--- a/f" "+++ /dev/null" "@@ -1,3 +0,0 @@" | { '"$(declare -f hunk_ranges)"'; EARSHOT_HUGE=2147483647; hunk_ranges; }'
  [ "$output" = "$(printf 'f\t0\t2147483647')" ]
}

@test "hunk_ranges keeps a path that has a space in it" {
  # The path is read with substr, not $2 — awk's fields would shear it in half
  # and the file would silently never match anyone else's.
  run bash -c 'printf "%s\n" "diff --git a/my file.md b/my file.md" "--- a/my file.md" "+++ b/my file.md" "@@ -4,2 +4,2 @@" | { '"$(declare -f hunk_ranges)"'; EARSHOT_HUGE=9; hunk_ranges; }'
  [ "$output" = "$(printf 'my file.md\t4\t5')" ]
}

@test "range_compare calls two edits within the fuzz the same region" {
  run bash -c "printf '%s\n' \$'A\tdoc.md\t10\t10' \$'B\tdoc.md\t12\t12' | { $(declare -f range_compare); EARSHOT_FUZZ=3; EARSHOT_HUGE=2147483647; range_compare; }"
  [ "$output" = "$(printf 'hunk\tdoc.md\tL10-12')" ]
}

@test "range_compare calls two edits beyond the fuzz the same file only" {
  # The whole point: co-editing a long shared file is normal here and must not
  # cry wolf. A warning you learn to ignore is worse than no warning.
  run bash -c "printf '%s\n' \$'A\tdoc.md\t10\t10' \$'B\tdoc.md\t50\t50' | { $(declare -f range_compare); EARSHOT_FUZZ=3; EARSHOT_HUGE=2147483647; range_compare; }"
  [ "$output" = "$(printf 'file\tdoc.md\t-')" ]
}

@test "range_compare says nothing when the two sides share no file at all" {
  run bash -c "printf '%s\n' \$'A\ta.md\t1\t1' \$'B\tb.md\t1\t1' | { $(declare -f range_compare); EARSHOT_FUZZ=3; EARSHOT_HUGE=2147483647; range_compare; }"
  [ -z "$output" ]
}

@test "range_compare doesn't misread side B when side A is empty" {
  # awk's usual two-file NR==FNR idiom reads the second file's FIRST record as
  # the first file's whenever the first file is empty — and "this lane has
  # changed nothing yet" is an ordinary state here, not an edge case. Hence the
  # side tag. Without it this test reports doc.md overlapping itself.
  run bash -c "printf '%s\n' \$'B\tdoc.md\t10\t10' | { $(declare -f range_compare); EARSHOT_FUZZ=3; EARSHOT_HUGE=2147483647; range_compare; }"
  [ -z "$output" ]
}

@test "earshot_side reads a live lane's checkout and a parked lane's branch" {
  mkdir -p "$TMP/live/.git"
  run earshot_side "$TMP/live" worktree-x "$TMP/main"
  [ "$output" = "$(printf '%s\t' "$TMP/live")" ]
  run earshot_side "$TMP/gone" worktree-x "$TMP/main"
  [ "$output" = "$(printf '%s\tworktree-x' "$TMP/main")" ]
}

@test "earshot_lanes takes only the lanes of the repo asked about" {
  WT_REGISTRY="$TMP/registry.tsv"
  mkregistry "$WT_REGISTRY" \
    "mine $ROOT/haus worktree-mine /wt/mine $ROOT/haus claude" \
    "other $ROOT/pounce worktree-other /wt/other $ROOT/pounce claude"
  run earshot_lanes "$ROOT/haus"
  [ "$output" = "$(printf 'mine\tworktree-mine\t/wt/mine')" ]
}

@test "earshot_order sends the pushed branch first" {
  mkoverlap
  git -C "$OV/repo" update-ref refs/remotes/origin/worktree-rival worktree-rival
  run earshot_order "$OV/repo" worktree-snug 1 worktree-rival 1 rival snug
  [[ "$output" == "rival lands first (already pushed)"* ]]
}

@test "earshot_order rebases the smaller branch when neither is pushed" {
  mkoverlap
  run earshot_order "$OV/repo" worktree-snug 1 worktree-rival 9 rival snug
  [[ "$output" == "rival lands first (bigger: 9 files vs 1)"* ]]
}

@test "earshot_order breaks a tie the same way from both sides" {
  # Both agents must reach the same answer without talking to each other, so
  # the tiebreak has to be a fact of the repo, not a view from one lane.
  mkoverlap
  run earshot_order "$OV/repo" worktree-snug 1 worktree-rival 1 rival snug
  local from_snug="$output"
  run earshot_order "$OV/repo" worktree-rival 1 worktree-snug 1 snug rival
  [[ "$from_snug" == rival* ]]     # "rival" sorts before "snug"
  [[ "$output" == rival* ]]
}

@test "cmd_overlap sees a sibling's UNCOMMITTED edit, which merge-tree cannot" {
  # This is the whole reason the hunk index exists beside merge-tree: a lane
  # spends most of its life with its work still in the working tree.
  mkoverlap
  cd "$OV/lanes/rival"
  run cmd_overlap
  [ "$status" -eq 4 ]
  [[ "$output" == *"snug"* ]]
  [[ "$output" == *"doc.md"* ]]
  [[ "$output" == *"L10-12"* ]]
}

@test "cmd_overlap is quiet about a lane at the other end of the same file" {
  mkoverlap
  cd "$OV/lanes/far"
  run cmd_overlap
  [ "$status" -eq 3 ]                       # same file, different regions
  [[ "$output" == *"elsewhere in the file"* ]]
  [[ "$output" != *"⚠"* ]]
}

@test "cmd_overlap reports a lane with no commits as uncommitted, not as the base" {
  # `git log -1 <branch>` on a commitless lane answers with the shared ancestor,
  # which would quote the repo's own history back as the neighbour's plan.
  mkoverlap
  cd "$OV/lanes/rival"
  run cmd_overlap
  [[ "$output" == *"uncommitted work only"* ]]
  [[ "$output" != *"“base”"* ]]
}

@test "cmd_overlap treats two lanes creating the same new file as a collision" {
  mkoverlap
  echo hello > "$OV/lanes/snug/brand-new.md"
  echo goodbye > "$OV/lanes/far/brand-new.md"
  cd "$OV/lanes/far"
  run cmd_overlap
  [ "$status" -eq 4 ]
  [[ "$output" == *"brand-new.md"* ]]
  [[ "$output" == *"the whole file"* ]]
}

@test "cmd_overlap --path answers with silence when that file is clear" {
  # The hook-shaped form. Anything that prints on a clear file gets muted.
  mkoverlap
  cd "$OV/lanes/rival"
  run cmd_overlap --path other.md
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "cmd_overlap --path takes an absolute path as readily as a relative one" {
  mkoverlap
  cd "$OV/lanes/rival"
  run cmd_overlap --path "$OV/lanes/rival/doc.md"
  [ "$status" -eq 4 ]
  [[ "$output" == *"snug"* ]]
}

@test "cmd_overlap says so plainly when this repo has no other lanes" {
  mkoverlap
  WT_REGISTRY="$TMP/empty.tsv"
  : > "$WT_REGISTRY"
  cd "$OV/lanes/rival"
  run cmd_overlap
  [ "$status" -eq 0 ]
  [[ "$output" == *"no other lanes"* ]]
}

@test "cmd_overlap ignores a registry row whose branch is gone — a corpse, not a lane" {
  mkoverlap
  git -C "$OV/repo" worktree remove --force "$OV/lanes/snug"
  git -C "$OV/repo" branch -qD worktree-snug
  cd "$OV/lanes/rival"
  run cmd_overlap
  [ "$status" -eq 3 ]                       # far is still there, quietly
  [[ "$output" != *"snug"* ]]
  [[ "$output" == *"1 other lane"* ]]
}

@test "cmd_overlap from the MAIN checkout reports lane against lane instead" {
  mkoverlap
  cd "$OV/repo"
  run cmd_overlap
  [ "$status" -eq 4 ]
  [[ "$output" == *"↔"* ]]
  [[ "$output" == *"snug"* ]]
  [[ "$output" == *"rival"* ]]
}

@test "cmd_overlap stays quiet about a lane whose work was SQUASH-merged into main" {
  # A squash merge lands the lane's work as a brand-new commit and leaves the
  # lane's OWN commits unreachable from main — so `merge-base` keeps answering
  # with the pre-merge commit for as long as the branch exists, and the reader,
  # whose history contains the squash, measures that landed commit as its own
  # work. Both sides then hold the same diff and "collide" over it. Before the
  # M-block the merged lane claimed every line it had landed, forever, with an
  # intent line quoting its merged commit and a landing order for a branch with
  # nothing left to land — and it never aged out.
  mkoverlap
  # rival's line-10 edit lands on main as a squash: same content, new commit,
  # rival's own commit not an ancestor of it.
  setline "$OV/repo/doc.md" 10 10-rival
  git -C "$OV/repo" commit -qam "squash: rival's line 10, as a new commit"
  # The reader is cut from main AFTER the merge — the ordinary case, and the
  # one that makes both sides carry the landed diff.
  git -C "$OV/repo" worktree add -q -b worktree-after "$OV/lanes/after" main
  setline "$OV/lanes/after/other.md" 1 mine
  mkregistry "$WT_REGISTRY" \
    "rival $OV/repo worktree-rival $OV/lanes/rival $OV/repo claude" \
    "after $OV/repo worktree-after $OV/lanes/after $OV/repo claude"
  cd "$OV/lanes/after"
  run cmd_overlap
  [ "$status" -eq 0 ]
  [[ "$output" != *"doc.md"* ]]
  [[ "$output" != *"lands first"* ]]
}

@test "cmd_overlap still sees a merged lane's UNMERGED commits" {
  # The other half of the same seam: subtracting what main landed must not
  # subtract what the lane kept doing afterwards — exactly the state `scruff
  # reship` exists for, commits made after the PR merged.
  mkoverlap
  setline "$OV/repo/doc.md" 10 10-rival
  git -C "$OV/repo" commit -qam "squash: rival's line 10, as a new commit"
  # Line 13, not 11: three lines clear of the squashed hunk so it forms its own,
  # and still inside the fuzz around snug's line 12. Adjacent to the landed hunk
  # it would COALESCE into one range, and the test would then be passing on the
  # coincidence that the merged range no longer matched, rather than on the
  # lane's later work being kept.
  setline "$OV/lanes/rival/doc.md" 13 13-rival-after
  git -C "$OV/lanes/rival" commit -qam "rival: kept going after the merge"
  cd "$OV/lanes/snug"
  run cmd_overlap
  [ "$status" -eq 4 ]
  [[ "$output" == *"rival"* ]]
}

@test "cmd_overlap does not subtract a lane's own edit that main happens to match" {
  # Per-side, never global: an unrebased lane did not inherit main's commit, so
  # none of main's work is in its diff to take out — and a global subtraction
  # would delete this edit, because an independent change to the same line
  # produces the very same base-side range.
  mkoverlap
  setline "$OV/repo/doc.md" 10 10-from-main
  git -C "$OV/repo" commit -qam "main: line 10, independently"
  cd "$OV/lanes/snug"                       # snug edits line 12, rival line 10
  run cmd_overlap
  [ "$status" -eq 4 ]
  [[ "$output" == *"rival"* ]]
}

@test "cmd_overlap still calls two lanes creating one new file a collision" {
  # A whole-file add claims 0..HUGE on every side by construction, so a global
  # subtraction would cancel this out exactly — and add/add is the case
  # side_ranges calls the one this tool would otherwise be blindest to.
  mkoverlap
  echo from-main > "$OV/repo/new.md"
  git -C "$OV/repo" add new.md
  git -C "$OV/repo" commit -qm "main: adds new.md"
  echo from-rival > "$OV/lanes/rival/new.md"
  git -C "$OV/lanes/rival" add new.md
  git -C "$OV/lanes/rival" commit -qm "rival: adds it too"
  echo from-snug > "$OV/lanes/snug/new.md"
  cd "$OV/lanes/snug"
  run cmd_overlap
  [ "$status" -eq 4 ]
  # The FINDING row, not a bare filename: the intent line quotes the lane's
  # commit subject, so `*"new.md"*` alone is satisfied by the subject even when
  # the row it is supposed to assert has been subtracted away. (Which is why
  # the subject above no longer names the file either.)
  [[ "$output" == *"new.md  the whole file"* ]]
}

@test "cmd_overlap reaches the merge-tree verdict even when the index is quiet" {
  # The two signals are reported apart precisely so they can disagree, and the
  # verdict used to sit past the empty-index `continue` — harmless only while
  # they could not disagree in THIS direction. Subtracting landed ranges is
  # what makes the index empty while merge-tree still conflicts: the reader
  # carries main's change to a line an unrebased lane also edited, so the
  # reader authored nothing, and the lane will still conflict with main. The
  # failure mode was not a missed row but a printed "merge-tree: clean".
  mkoverlap
  setline "$OV/repo/doc.md" 10 10-from-main    # main lands line 10; rival has its own
  git -C "$OV/repo" commit -qam "main: line 10, landed"
  git -C "$OV/repo" worktree add -q -b worktree-after "$OV/lanes/after" main
  mkregistry "$WT_REGISTRY" \
    "rival $OV/repo worktree-rival $OV/lanes/rival $OV/repo claude" \
    "after $OV/repo worktree-after $OV/lanes/after $OV/repo claude"
  cd "$OV/lanes/after"                          # cut from main, nothing of its own
  run cmd_overlap
  [[ "$output" == *"none in your files"* ]]     # index quiet, correctly
  [[ "$output" == *"merge-tree already conflicts"* ]]
  [[ "$output" != *"merge-tree: clean"* ]]
  [ "$status" -eq 4 ]
}

@test "cmd_overlap is unchanged when the merge base IS main's tip" {
  # The no-op property the M-block leans on: cut from the current main, nothing
  # sits between base and tip, the landed set is empty, and every finding is
  # the one this tool reported before the block existed.
  mkoverlap
  cd "$OV/lanes/snug"
  run cmd_overlap
  [ "$status" -eq 4 ]
  [[ "$output" == *"rival"* ]]
  [[ "$output" == *"doc.md"* ]]
}

@test "cmd_overlap refuses an argument it doesn't know rather than guessing" {
  run cmd_overlap --wat
  [ "$status" -eq 1 ]
  [[ "$output" == *"unknown argument"* ]]
}

@test "hunk_ranges doesn't read an added '++ ' line as a file header" {
  # A line whose own text starts with "++ " arrives in the diff as "+++ ", and
  # reading it as a header files every LATER hunk under a garbage path — the
  # file drops out of the comparison silently, which is the worst way to fail.
  run bash -c 'printf "%s\n" "diff --git a/f b/f" "--- a/f" "+++ b/f" "@@ -2,2 +2,2 @@" "+++ still content" "@@ -10,1 +10,1 @@" | { '"$(declare -f hunk_ranges)"'; EARSHOT_HUGE=9; hunk_ranges; }'
  [ "$output" = "$(printf 'f\t2\t3\nf\t10\t10')" ]
}

@test "hunk_ranges doesn't read a removed '-- ' line as a file header either" {
  run bash -c 'printf "%s\n" "diff --git a/f b/f" "--- a/f" "+++ b/f" "@@ -2,2 +2,2 @@" "--- /dev/null" "@@ -10,1 +10,1 @@" | { '"$(declare -f hunk_ranges)"'; EARSHOT_HUGE=9; hunk_ranges; }'
  [ "$output" = "$(printf 'f\t2\t3\nf\t10\t10')" ]
}

@test "cmd_overlap measures against origin/main, not the local main behind it" {
  # A sibling landing its PR moves the REMOTE ref; the local main doesn't hear
  # about it until someone pulls. Reading local main would blind the check to
  # the one event it exists to catch.
  mkoverlap
  git -C "$OV/repo" worktree add -q -b tmp-origin "$OV/lanes/tmporigin" main
  setline "$OV/lanes/tmporigin/doc.md" 10 10-landed-elsewhere
  git -C "$OV/lanes/tmporigin" commit -qam "a sibling PR that already merged"
  git -C "$OV/repo" update-ref refs/remotes/origin/main tmp-origin
  git -C "$OV/repo" worktree remove --force "$OV/lanes/tmporigin"
  git -C "$OV/repo" branch -qD tmp-origin
  cd "$OV/lanes/rival"                       # rival edits line 10 too
  run cmd_overlap
  [ "$status" -eq 4 ]
  [[ "$output" == *"origin/main"* ]]
  [[ "$output" == *"merge-tree already conflicts"* ]]
}

@test "cmd_overlap --path is silent from the main checkout too" {
  # --path is the hook-shaped form wherever it runs from; a summary line on a
  # clear file is exactly what makes a hook get muted.
  mkoverlap
  cd "$OV/repo"
  run cmd_overlap --path other.md
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "cmd_overlap --path from the main checkout still names a real collision" {
  mkoverlap
  cd "$OV/repo"
  run cmd_overlap --path doc.md
  [ "$status" -eq 4 ]
  [[ "$output" == *"↔"* ]]
  [[ "$output" != *"🌫"* ]]                  # findings only, no header
}

# ── notify: the banner `release` and `try-batch` leave on screen ─────────────
#
# Every path through it swallows its own output by design — a courtesy must not
# be why a release fails — so a regression here is invisible by construction.
# That is exactly the shape this suite exists for.
#
# The fixtures replace both renderers: a fake Trill.app whose binary records its
# argv, and an `osascript` on PATH that records that it ran at all.

mktrill_at() { # mktrill_at <app-bundle> <exit-code> — a Trill.app whose CLI logs its argv
  local app="$1/Contents/MacOS"
  mkdir -p "$app"
  cat >"$app/Trill" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"$TMP/trill.log"
exit ${2:-0}
EOF
  chmod +x "$app/Trill"
}

mktrill() { # mktrill <exit-code> — the fixture app, pointed at by TRILL_APP
  mktrill_at "$TMP/Trill.app" "${1:-0}"
  export TRILL_APP="$TMP/Trill.app"
}

mkhometrill() { # the same app, at a FAKE $HOME/Applications — for the TRILL_APP-unset path
  # With TRILL_APP unset the candidates are ("$HOME/Applications/Trill.app"
  # "/Applications/Trill.app"), and the second is a real, executable app on
  # every machine this ships to. So such a test cannot just point HOME at an
  # empty dir: it falls through to the developer's OWN trill and fires a genuine
  # banner (source bench.run, since no call site's BENCH_NOTIFY_SOURCE is in
  # play) while still asserting `status -eq 0` and staying green. Planting the
  # fixture at the FIRST candidate exercises the unset path and is hermetic.
  HOME="$TMP/fakehome"
  mktrill_at "$HOME/Applications/Trill.app" 0
}

mkosascript() {
  mkdir -p "$TMP/fakebin"
  cat >"$TMP/fakebin/osascript" <<EOF
#!/bin/sh
printf '%s\n' "\$*" >>"$TMP/osascript.log"
EOF
  chmod +x "$TMP/fakebin/osascript"
  PATH="$TMP/fakebin:$PATH"
}

@test "notify sends through trill when Trill.app is there" {
  mktrill 0
  mkosascript
  BENCH_NOTIFY_SOURCE=release notify "done" "pounce 2026.08.25 is live" "Published by CI."
  run cat "$TMP/trill.log"
  [[ "$output" == *"--source bench.release"* ]]
  [[ "$output" == *"--kind done"* ]]
  [[ "$output" == *"pounce 2026.08.25 is live"* ]]
  # and NOT twice — a delivered banner must not also fire Apple's
  [ ! -f "$TMP/osascript.log" ]
}

@test "notify falls back to Apple's banner when trill can't draw it" {
  mktrill 2      # 2 = daemon unreachable
  mkosascript
  notify "fault" "release failed" "The CI run went red."
  run cat "$TMP/osascript.log"
  [[ "$output" == *"release failed"* ]]
}

@test "notify falls back when there is no Trill.app at all" {
  # TRILL_APP *overrides* the candidate list rather than heading it, so this IS
  # the whole set — there is no ~/Applications left to neutralise with HOME.
  export TRILL_APP="$TMP/nowhere.app"
  mkosascript
  notify "note" "a title" "a body"
  run cat "$TMP/osascript.log"
  [[ "$output" == *"a title"* ]]
}

@test "notify with TRILL_APP unset does not die under set -u" {
  unset TRILL_APP
  mkhometrill      # found before /Applications, so the machine's real trill never fires
  mkosascript
  run notify "note" "t" "b"
  [ "$status" -eq 0 ]
  run cat "$TMP/trill.log"
  [[ "$output" == *"--source bench.run"* ]]     # the default source, no call site setting it
  [ ! -f "$TMP/osascript.log" ]                 # ~/Applications is a real candidate, not a miss
}

@test "BENCH_NOTIFY=off draws nothing through either renderer" {
  mktrill 0
  mkosascript
  BENCH_NOTIFY=off notify "done" "silent" "nothing should appear"
  [ ! -f "$TMP/trill.log" ]
  [ ! -f "$TMP/osascript.log" ]
}

@test "BENCH_NOTIFY=trill never falls back to Apple's banner" {
  mktrill 2
  mkosascript
  BENCH_NOTIFY=trill notify "fault" "t" "b"
  [ ! -f "$TMP/osascript.log" ]
}

@test "notify never fails its caller, whatever the renderer does" {
  # The whole reason it exists as a helper: `set -e` is on in every caller, and
  # a release must not die because a banner did.
  mktrill 3
  mkosascript
  run notify "note" "t" "b"
  [ "$status" -eq 0 ]
}

@test "notify passes a body containing a double quote through intact" {
  # The bug the argv form fixes: interpolated, this ends the AppleScript string
  # early. Checked on the trill side, where the argv is recoverable.
  mktrill 0
  mkosascript   # unreachable while trill exits 0 — and the fixture is what keeps
                # a regression in that path off the machine's real osascript
  BENCH_NOTIFY_SOURCE=release notify "done" 'a "quoted" tag' 'body with " in it'
  run cat "$TMP/trill.log"
  [[ "$output" == *'a "quoted" tag'* ]]
}

# ── snug's bash painter ──────────────────────────────────────────────────────

@test "bench sources snug's share/ui.sh out of the snug checkout" {
  # The wiring step 7 of docs/cli-presentation.md builds on, and the reason the
  # file moved out of this repo: `repo_dir snug` is the whole lookup, so a
  # renamed path or a `repo_dir` arm that stopped answering fails HERE rather
  # than the first time bench tries to draw a row.
  mkdir -p "$ROOT/snug/share"
  cat > "$ROOT/snug/share/ui.sh" <<'UI'
ui_say() { printf 'FIXTURE %s\n' "$*"; }
UI
  ui_load
  [ "$(type -t ui_say)" = function ]
  run ui_say hello
  [ "$output" = "FIXTURE hello" ]
}

@test "bench runs on a machine with no snug checkout at all" {
  # `bench clone` planted no snug before 2026-08-27, so a checkout that predates
  # it has none — and the fallback painter being missing must cost the caller
  # nothing. A bare `source` of a nonexistent path exits 1 under `set -e`, which
  # would kill bench at load time, before any verb ran and with nothing on
  # either stream: the same failure shape ui_measure's width guard exists for.
  [ ! -e "$ROOT/snug" ]
  run ui_load
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}
