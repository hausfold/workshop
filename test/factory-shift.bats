#!/usr/bin/env bats
# Unit tests for `script/factory-shift` — specifically, for the passes that
# CANNOT see, which are the ones a night shift has to get right.
#
# The shift's whole product is a log somebody reads in the morning instead of
# having watched. So the failure that matters here is not "it crashed": it is
# a pass that sensed nothing, said nothing about that, and ended on a line
# that reads exactly like a quiet night. Both blind paths below produced that
# until 2026-08-29, when a run of `connection reset by peer` against
# api.github.com made the difference observable.
#
# `gh` is a stub on PATH. `trill` deliberately is not, so `notify` short-
# circuits on `command -v` and nothing is drawn during a test run.

setup() {
  SHIFT="$BATS_TEST_DIRNAME/../script/factory-shift"
  TMP="$BATS_TEST_TMPDIR"
  export FACTORY_STATE_DIR="$TMP/state"
  # No usage feed: the budget line degrades to a stated unknown, which keeps
  # these tests independent of whatever the real machine's quota is doing.
  export FACTORY_USAGE_TSV="$TMP/no-such-usage.tsv"
  mkdir -p "$TMP/bin"
  PATH="$TMP/bin:$PATH"
  export PATH
}

# Write a `gh` stub whose behaviour per subcommand is chosen by the caller.
# $1 = what `gh repo list` does: ok | fail | empty
# $2 = what `gh run list` does:  green | red | fail
stub_gh() {
  cat >"$TMP/bin/gh" <<EOF
#!/usr/bin/env bash
case "\$1 \$2" in
"repo list")
  case "$1" in
  fail)  echo "connection reset by peer" >&2; exit 1 ;;
  empty) exit 0 ;;
  *)     echo "perch" ;;
  esac
  ;;
"pr list") ;;                       # no open PRs: the merge half is not under test
"run list")
  case "$2" in
  fail)  echo "http2: client conn could not be established" >&2; exit 1 ;;
  red)   printf 'failure\thttps://example.invalid/run/1\n' ;;
  *)     printf 'success\thttps://example.invalid/run/1\n' ;;
  esac
  ;;
esac
EOF
  chmod +x "$TMP/bin/gh"
}

@test "a readable, green main says nothing about CI and ends on a clean pass" {
  stub_gh ok green
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"pass done: 0 merged"* ]]
  [[ "$output" != *"CI-RED"* ]]
  [[ "$output" != *"ci-unknown"* ]]
}

@test "a red main is still reported" {
  stub_gh ok red
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"CI-RED: perch"* ]]
}

@test "a main whose latest run cannot be READ is ci-unknown, never silence" {
  stub_gh ok fail
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"ci-unknown: perch"* ]]
  # The distinction that matters: not-red and could-not-look must not print
  # the same thing, or a red main inside a flaky window is reported by omission.
  [[ "$output" != *"CI-RED"* ]]
}

@test "a failed org listing aborts the pass instead of reporting a quiet night" {
  stub_gh fail green
  run "$SHIFT" --dry-run
  [ "$status" -ne 0 ]
  [[ "$output" == *"pass ABORTED"* ]]
  [[ "$output" != *"pass done: 0 merged"* ]]
}

@test "an empty org listing aborts too — nothing sensed is not nothing to report" {
  stub_gh empty green
  run "$SHIFT" --dry-run
  [ "$status" -ne 0 ]
  [[ "$output" == *"pass ABORTED"* ]]
  [[ "$output" != *"pass done: 0 merged"* ]]
}

@test "every line the pass printed is also in the day's log, which IS the handover" {
  stub_gh ok fail
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  log="$FACTORY_STATE_DIR/shift-$(date +%Y%m%d).log"
  [ -f "$log" ]
  grep -q "ci-unknown: perch" "$log"
}
