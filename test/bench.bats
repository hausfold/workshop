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
  # Source the library form; override ROOT so repo_dir() resolves into fixtures.
  HAUS_LIB=1 source "$HAUS"
  ROOT="$TMP/root"
  mkdir -p "$ROOT"
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

# (hook_field + the worktree lifecycle moved to the standalone `wt` tool in
# the rice (nebelhaus/modules/den) — bench no longer parses hook payloads.)

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
  [[ "$output" == *"--override-input nebelhaus path:$ROOT/nebelhaus"* ]]
  [[ "$output" == *"--override-input nebelhaus/nebelung path:$ROOT/nebelung"* ]]
  [[ "$output" == *"--override-input nebelhaus/pounce path:/tmp/wt/pounce"* ]]
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
  [[ "$output" == *"--override-input nebelhaus/pounce path:/tmp/batch/pounce"* ]]
  [[ "$output" == *"--override-input nebelhaus/nebelung path:$ROOT/nebelung"* ]]
  [[ "$output" == *"--override-input nebelhaus path:$ROOT/nebelhaus"* ]]
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

@test "read_version reads and trims nebelhaus's VERSION file" {
  mkdir -p "$ROOT/nebelhaus"
  printf '  0.3.0\n' >"$ROOT/nebelhaus/VERSION"
  run read_version nebelhaus
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

@test "write_version round-trips a same-day -N version through nebelhaus's VERSION" {
  mkdir -p "$ROOT/nebelhaus"
  printf '0.5.8\n' >"$ROOT/nebelhaus/VERSION"
  write_version nebelhaus 2026.07.18-1
  run read_version nebelhaus
  [ "$output" = "2026.07.18-1" ]
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
    {"name":"bump nebelhaus/homebrew-tap","status":"completed","conclusion":"success",
     "startedAt":"2026-08-02T10:02:41Z","completedAt":"2026-08-02T10:02:50Z"}]}'
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "ok	build + publish release	2m 41s" ]
  [ "${lines[1]}" = "ok	bump nebelhaus/homebrew-tap	9s" ]
  [ "${lines[2]}" = "RUN	completed	success" ]
}

@test "a job that hasn't started reads as queued, not as a 2000-year runtime" {
  # GitHub hands back a year-1 timestamp for a job that never began; without the
  # guard that subtraction renders as an absurd duration.
  run render_run '{"status":"in_progress","conclusion":null,"jobs":[
    {"name":"bump nebelhaus/homebrew-tap","status":"queued","conclusion":null,
     "startedAt":"0001-01-01T00:00:00Z","completedAt":"0001-01-01T00:00:00Z"}]}'
  [ "${lines[0]}" = "wait	bump nebelhaus/homebrew-tap	queued" ]
  [ "${lines[1]}" = "RUN	in_progress	" ]
}

@test "a failed job renders as fail and a skipped one says so" {
  run render_run '{"status":"completed","conclusion":"failure","jobs":[
    {"name":"build + publish release","status":"completed","conclusion":"failure",
     "startedAt":"2026-08-02T10:00:00Z","completedAt":"2026-08-02T10:01:35Z"},
    {"name":"bump nebelhaus/homebrew-tap","status":"completed","conclusion":"skipped",
     "startedAt":"0001-01-01T00:00:00Z","completedAt":"0001-01-01T00:00:00Z"}]}'
  [ "${lines[0]}" = "fail	build + publish release	1m 35s" ]
  [ "${lines[1]}" = "skip	bump nebelhaus/homebrew-tap	skipped" ]
  [ "${lines[2]}" = "RUN	completed	failure" ]
}

@test "a long job name is clamped so a live row can never soft-wrap" {
  # The repaint moves the cursor up by LINE COUNT; a wrapped row desyncs the frame.
  run render_run '{"status":"completed","conclusion":"success","jobs":[
    {"name":"an absurdly long job name that would certainly wrap a narrow terminal",
     "status":"completed","conclusion":"success",
     "startedAt":"2026-08-02T10:00:00Z","completedAt":"2026-08-02T10:00:05Z"}]}'
  [ "${lines[0]}" = "ok	an absurdly long job name that wou	5s" ]
}

@test "row_glyph walks the spinner and never leaves colour on" {
  run row_glyph run 0
  [ "$output" = "⠋" ]          # NO_COLOR is unset in bats, and stdout isn't a TTY
  run row_glyph run 11
  [ "$output" = "⠙" ]          # frame 11 wraps back round the 10-frame cycle
  run row_glyph ok 0
  [ "$output" = "✓" ]
  run row_glyph fail 0
  [ "$output" = "✗" ]
  run row_glyph queued 0
  [ "$output" = "·" ]
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
  make_repo nebelhaus
  git -C "$ROOT/nebelhaus" tag v0.2.0
  git -C "$ROOT/nebelhaus" -c user.name=t -c user.email=t@t commit -q --allow-empty -m two
  git -C "$ROOT/nebelhaus" -c user.name=t -c user.email=t@t commit -q --allow-empty -m three
  run commits_since nebelhaus v0.2.0
  [ "$output" = "2" ]
}

@test "commits_since is 0 when the tag is at HEAD" {
  make_repo nebelhaus
  git -C "$ROOT/nebelhaus" tag v0.2.0
  run commits_since nebelhaus v0.2.0
  [ "$output" = "0" ]
}

@test "commits_since degrades to ? on a bogus ref" {
  make_repo nebelhaus
  run commits_since nebelhaus v9.9.9
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
  run docs_watermark trill
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
  git -C "$ROOT/nebelhaus" worktree add -q -b worktree-blue "$TMP/wt-blue"
  WT_REPO="nebelhaus" WT_PATH="$TMP/wt-blue"
  record_activation mbp
  run cat "$ACTIVE_FILE"
  [[ "$output" == *"nebelhaus"* ]]
  [[ "$output" == *"worktree-blue"* ]]
  [[ "$output" == *"$TMP/wt-blue"* ]]
  # the untouched repos stay out of it — the receipt lists only what drifted
  [[ "$output" != *"pounce"* ]]
}

@test "record_activation flags a dirty source tree" {
  setup_receipt
  git -C "$ROOT/nebelhaus" worktree add -q -b worktree-blue "$TMP/wt-blue"
  echo scratch >"$TMP/wt-blue/uncommitted"
  WT_REPO="nebelhaus" WT_PATH="$TMP/wt-blue"
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
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t/nix/store/aaa-system\nnebelhaus\t/wt/blue\tworktree-blue\tclean\n' >"$ACTIVE_FILE"
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
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t/nix/store/aaa-system\nnebelhaus\t/wt/blue\tworktree-blue\tclean\n' >"$ACTIVE_FILE"
  run read_activation
  [ "$status" -ne 0 ]
  run cat "$ACTIVE_FILE"
  [ "$status" -ne 0 ]                       # the stale file is gone
}

@test "read_activation trusts a receipt written before system-pinning existed" {
  setup_receipt
  mkdir -p "$STATE_DIR"
  current_system() { echo /nix/store/bbb-system; }
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t\nnebelhaus\t/wt/blue\tworktree-blue\tclean\n' >"$ACTIVE_FILE"
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
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t/nix/store/aaa-system\nnebelhaus\t%s/gone-wt\tworktree-blue\tclean\n' "$TMP" >"$ACTIVE_FILE"
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
  printf 'when\t2026-08-03 10:00\nhost\tmbp\nsystem\t/nix/store/aaa-system\nnebelhaus\t%s\tworktree-blue\tclean\n' "$ROOT/nebelhaus" >"$ACTIVE_FILE"
  run status_running
  [[ "$output" == *"2026-08-03 10:00"* ]]
  [[ "$output" != *"unknown time"* ]]
}

@test "status_running clamps a long branch name so the columns can't shear" {
  setup_receipt
  mkdir -p "$STATE_DIR"
  current_system() { echo /nix/store/aaa-system; }
  printf 'when\tnow\nhost\tmbp\nsystem\t/nix/store/aaa-system\nnebelhaus\t%s\tworktree-an-absurdly-long-agent-branch-name\tclean\n' \
    "$ROOT/nebelhaus" >"$ACTIVE_FILE"
  run status_running
  [[ "$output" == *"…"* ]]
  [[ "$output" != *"worktree-an-absurdly-long-agent-branch-name"* ]]
}
