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
# the rice (haus/modules/den) — bench no longer parses hook payloads.)

# ── gh_repo: a checkout's directory name is not always its owner/repo ─────────
#
# The local side is `repo_dir` ($ROOT/<name>); this is the remote side. They
# agree for most of the family and deliberately don't for org-profile. The
# `nebelhaus` arm that used to sit here retired with §3.3's step 4, and §10
# renamed the layer's checkout again (./hausfold → ./haus) — these tests are
# what stops either spelling coming back, in either direction.

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

@test "gh_repo never emits the rice's pre-migration repo name" {
  # `hausfold/nebelhaus` RESOLVES — GitHub redirects the pre-rename name — so
  # nothing would fail until someone creates a real repo under it, which §6
  # says will happen: the rice keeps the name. Leaning on that redirect is the
  # bug this asserts against.
  for name in "${FAMILY[@]}" org-profile homebrew-tap; do
    run gh_repo "$name"
    [ "$output" != "$GH_ORG/nebelhaus" ]
  done
}

@test "repo_dir resolves the layer to its checkout" {
  mkdir -p "$ROOT/haus/.git"
  run repo_dir haus
  [ "$output" = "$ROOT/haus" ]
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
  [[ "$output" == *"--override-input nebelhaus path:$ROOT/haus"* ]]
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
  [[ "$output" == *"--override-input nebelhaus path:$ROOT/haus"* ]]
}

# ── bench try lane: build a pane's worktree + every holt-child alongside it ────
#
# holt's registry only ever records a ONE-HOP parent pointer per row (the
# spawning pane's own checkout path) — never a children list, deliberately.
# lane_paths/detect_lane do the walk bench-side: start at a checkout, pull in
# any row whose `parent` matches something already found, transitively.

@test "local_src prefers a lane child checkout over its main checkout" {
  LANE_SRC[holt]="/tmp/lane/holt"
  WT_REPO="pounce" WT_PATH="/tmp/wt/pounce"
  run local_src holt
  [ "$output" = "/tmp/lane/holt" ]
  # the active worktree's own repo is untouched by LANE_SRC…
  run local_src pounce
  [ "$output" = "/tmp/wt/pounce" ]
  # …and an uninvolved repo still falls back to its main checkout.
  run local_src perch
  [ "$output" = "$ROOT/perch" ]
}

@test "local_src prefers a batch integration checkout over a lane child" {
  BATCH_SRC[holt]="/tmp/batch/holt"
  LANE_SRC[holt]="/tmp/lane/holt"
  run local_src holt
  [ "$output" = "/tmp/batch/holt" ]
}

@test "overrides points a lane child at its checkout, honouring the active worktree too" {
  WT_REPO="pounce" WT_PATH="/tmp/wt/pounce"
  LANE_SRC[haus]="/tmp/lane/haus"
  run overrides
  [[ "$output" == *"--override-input nebelhaus path:/tmp/lane/haus"* ]]
  [[ "$output" == *"--override-input nebelhaus/pounce path:/tmp/wt/pounce"* ]]
  [[ "$output" == *"--override-input nebelhaus/nebelung path:$ROOT/nebelung"* ]]
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

@test "lane_paths walks holt-child rows transitively, ignoring unrelated ones" {
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

@test "detect_lane populates LANE_SRC for every holt child, mapped to its family repo" {
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

# ── version_scheme: holt is the one repo whose number is a judgement ───────────

@test "version_scheme is calver for the tag-and-forget repos" {
  for repo in pounce perch haus; do
    run version_scheme "$repo"
    [ "$output" = calver ]
  done
}

@test "version_scheme is semver for holt" {
  run version_scheme holt
  [ "$output" = semver ]
}

@test "version_file locates holt's VERSION" {
  run version_file holt
  [ "$output" = "$ROOT/holt/VERSION" ]
}

@test "read_version reads and trims holt's VERSION file" {
  mkdir -p "$ROOT/holt"
  printf '0.1.0\n' >"$ROOT/holt/VERSION"
  run read_version holt
  [ "$output" = "0.1.0" ]
}

# holt's version lives in four files, so write_version delegates to the repo's
# own script rather than learning three manifest shapes. What's asserted here is
# the HANDOFF — that bench calls it with the version — not the script's own
# behaviour, which holt tests where it lives.
@test "write_version delegates holt to the repo's stamp script" {
  mkdir -p "$ROOT/holt/script"
  cat >"$ROOT/holt/script/stamp-version.sh" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$1" > "$(dirname "$0")/../VERSION"
echo "stamped $1"
SH
  chmod +x "$ROOT/holt/script/stamp-version.sh"
  write_version holt 0.2.0
  run read_version holt
  [ "$output" = "0.2.0" ]
}

# A checkout that predates the release flow has no stamp script, and the failure
# has to name the fix rather than surfacing as a bare "no such file".
@test "write_version refuses holt when the stamp script is missing" {
  mkdir -p "$ROOT/holt"
  run write_version holt 0.2.0
  [ "$status" -ne 0 ]
  [[ "$output" == *"stamp-version.sh"* ]]
  [[ "$output" == *"bench pull holt"* ]]
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
  # Trailing empty field: a FINISHED job's duration is final, so it carries no
  # start epoch for the paint loop to keep counting from.
  [ "${lines[0]}" = "ok	build + publish release	2m 41s	" ]
  [ "${lines[1]}" = "ok	bump nebelhaus/homebrew-tap	9s	" ]
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
    {"name":"bump nebelhaus/homebrew-tap","status":"queued","conclusion":null,
     "startedAt":"0001-01-01T00:00:00Z","completedAt":"0001-01-01T00:00:00Z"}]}'
  [ "${lines[0]}" = "wait	bump nebelhaus/homebrew-tap	queued	" ]
  [ "${lines[1]}" = "RUN	in_progress	" ]
}

@test "a failed job renders as fail and a skipped one says so" {
  run render_run '{"status":"completed","conclusion":"failure","jobs":[
    {"name":"build + publish release","status":"completed","conclusion":"failure",
     "startedAt":"2026-08-02T10:00:00Z","completedAt":"2026-08-02T10:01:35Z"},
    {"name":"bump nebelhaus/homebrew-tap","status":"completed","conclusion":"skipped",
     "startedAt":"0001-01-01T00:00:00Z","completedAt":"0001-01-01T00:00:00Z"}]}'
  [ "${lines[0]}" = "fail	build + publish release	1m 35s	" ]
  [ "${lines[1]}" = "skip	bump nebelhaus/homebrew-tap	skipped	" ]
  [ "${lines[2]}" = "RUN	completed	failure" ]
}

@test "a long job name is clamped so a live row can never soft-wrap" {
  # The repaint moves the cursor up by LINE COUNT; a wrapped row desyncs the frame.
  run render_run '{"status":"completed","conclusion":"success","jobs":[
    {"name":"an absurdly long job name that would certainly wrap a narrow terminal",
     "status":"completed","conclusion":"success",
     "startedAt":"2026-08-02T10:00:00Z","completedAt":"2026-08-02T10:00:05Z"}]}'
  [ "${lines[0]}" = "ok	an absurdly long job name that wou	5s	" ]
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
