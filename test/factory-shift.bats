#!/usr/bin/env bats
# Unit tests for `script/factory-shift` — and specifically for the passes that
# CANNOT see, which are the ones a night shift has to get right.
#
# The shift's product is a log somebody reads in the morning instead of having
# watched. So the failure that matters is not a crash: it is a pass that sensed
# nothing, said nothing about that, and ended on output identical to a quiet
# night. There are four ways to be blind — the repo list, one repo's PR list,
# one PR's tier verdict, one repo's main CI — and each has a case below.
#
# `gh`, `trill` and `factory-tier` are all stubbed. Stubbing `trill` is not
# tidiness: `setup()` PREPENDS to PATH, so a real `trill` on a developer's
# machine is still found by `notify`'s `command -v`, and several cases here
# reach a `notify fault`. The screen belongs to whoever is sitting at it, and
# running a test suite is never a reason to take it. The stub also records its
# calls, which makes the notify POLICY testable — see the pair of cases on it.

setup() {
  TMP="$BATS_TEST_TMPDIR"
  # A throwaway ROOT. `factory-shift` resolves its siblings by path
  # (`$ROOT/script/factory-tier`), not through PATH, so a stub for one of
  # those has to sit where the script looks rather than in front of it.
  mkdir -p "$TMP/root/script" "$TMP/bin"
  cp "$BATS_TEST_DIRNAME/../script/factory-shift" "$TMP/root/script/"
  cp "$BATS_TEST_DIRNAME/../script/factory-lease" "$TMP/root/script/"
  SHIFT="$TMP/root/script/factory-shift"

  export FACTORY_STATE_DIR="$TMP/state"
  # No usage feed and no lease file: the budget line degrades to a stated
  # unknown and the lease reads "none", so nothing here depends on what the
  # real machine's quota or lease happen to be. "No lease" also means the
  # merge path stops at `would-merge`, which is what keeps these tests from
  # ever needing a `gh pr merge` stub that could be wrong in a costly way.
  export FACTORY_USAGE_TSV="$TMP/no-such-usage.tsv"

  PATH="$TMP/bin:$PATH"
  export PATH
  export TRILL_CALLS="$TMP/trill-calls"
  cat >"$TMP/bin/trill" <<'EOF'
#!/usr/bin/env bash
printf '%s\n' "$*" >>"$TRILL_CALLS"
EOF
  chmod +x "$TMP/bin/trill"

  stub_gh ok green none
  stub_tier 3
}

# $1 gh repo list: ok | fail | empty
# $2 gh run list:  green | red | fail
# $3 gh pr list:   none | one | fail
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
"pr list")
  case "$3" in
  fail) echo "http2: client conn could not be established" >&2; exit 1 ;;
  one)  printf '7\tsomething\n' ;;
  esac
  ;;
"run list")
  case "$2" in
  fail) echo "http2: client conn could not be established" >&2; exit 1 ;;
  red)  printf 'failure\thttps://example.invalid/run/1\n' ;;
  *)    printf 'success\thttps://example.invalid/run/1\n' ;;
  esac
  ;;
esac
EOF
  chmod +x "$TMP/bin/gh"
}

# $1 = the exit code factory-tier returns: 0 judged tier-1 · 3 judged refusal ·
# anything else is `set -e` aborting inside it, i.e. no verdict at all.
stub_tier() {
  case "$1" in
  0) body='echo "tier: 1 (hausfold/perch#7 · 1 files, 2 lines) head=deadbeef"; exit 0' ;;
  3) body='echo "tier: not-1 — touches AGENTS.md  (hausfold/perch#7)"; exit 3' ;;
  *) body='echo "gh: connection reset by peer" >&2; exit 1' ;;
  esac
  printf '#!/usr/bin/env bash\n%s\n' "$body" >"$TMP/root/script/factory-tier"
  chmod +x "$TMP/root/script/factory-tier"
}

# ── the two controls: what a seeing pass says must not move ───────────────────

@test "a readable, green main says nothing about CI and ends on a clean pass" {
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"pass done: 0 merged"* ]]
  [[ "$output" != *"CI-RED"* ]]
  # Named one by one rather than a bare *unknown*: the budget line legitimately
  # says "budget: unknown" here, having no usage feed, and a blanket match on
  # the word would pass for the wrong reason on a machine that has one.
  [[ "$output" != *"ci-unknown"* ]]
  [[ "$output" != *"prs-unknown"* ]]
  [[ "$output" != *"tier-unknown"* ]]
  [[ "$output" != *"ABORTED"* ]]
}

@test "a red main is still reported" {
  stub_gh ok red none
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"CI-RED: perch"* ]]
}

@test "a PR that WAS judged and refused is still queued, with its reason" {
  stub_gh ok green one
  stub_tier 3
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"queued: perch#7"* ]]
  [[ "$output" == *"touches AGENTS.md"* ]]
  [[ "$output" != *"tier-unknown"* ]]
}

# Writes the aiusage feed the budget block reads: 5-hour %, weekly %, and how
# far off the weekly reset is. The third argument is seconds of week REMAINING,
# because that is what the human's reserve drains against — a test that pinned
# an absolute stamp would start passing for the wrong reason, then stop.
stub_usage() { # <5h %> <week %> <seconds of week left>
  export FACTORY_USAGE_TSV="$TMP/usage.tsv"
  printf '%s\t%s\t0\t%s\tstub\n' "$1" "$2" "$(($(date +%s) + $3))" >"$FACTORY_USAGE_TSV"
}

# ── the budget verdict, which is the fixer gate ───────────────────────────────
# A gate that refuses everything is invisible: its "no" is the same word as a
# correct "no", and the path behind it simply never runs. So the case that
# matters most here is the plain affirmative, and it is written first — the
# refusals below it are only worth pinning once something can get through.

@test "the two dials and the ceiling are still the ones the docs state" {
  # docs/factory.md's budget governor quotes these three numbers, and the
  # verdict is unreadable without them. A tuned dial is a fine change; a tuned
  # dial the doc still states the old value for is the drift this pins.
  grep -q '^CEILING=95 ' "$SHIFT"
  grep -q '^RESERVE=70 ' "$SHIFT"
  grep -q '^FIXER=5 ' "$SHIFT"
}

@test "an early-week burst with the week mostly unspent can still afford a fixer" {
  # A sixth of the week's budget gone with 84% of its clock left. Bursty is how
  # this account is actually spent, so if this shape cannot get through, the
  # CI-RED path has no reachable caller at all.
  stub_usage 13 16 $((604800 * 84 / 100))
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"fixer: yes"* ]]
}

@test "a saturated 5-hour window refuses however much of the week is left" {
  # Not the same question as the week, and it outranks it: a factory that
  # saturates the rolling window at 4am rate-limits whoever sits down at 9.
  stub_usage 84 16 $((604800 * 84 / 100))
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"fixer: no (5h window at 84%)"* ]]
}

@test "a burst big enough to eat the human's rest of the week refuses" {
  # Half the window gone with 90% of it still to come — burst-tolerant is not
  # the same as unbounded, and the reserve is what draws that line.
  stub_usage 10 50 $((604800 * 90 / 100))
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"fixer: no (headroom"* ]]
}

@test "a spent week late in the window refuses, where the same spend early does not" {
  stub_usage 10 90 $((604800 * 10 / 100))
  run "$SHIFT" --dry-run
  [[ "$output" == *"fixer: no (headroom"* ]]
  # The reserve drains with the clock, so the LAST of the week is the factory's
  # to spend if the human left it — otherwise the gate is just a later pace line.
  stub_usage 10 60 $((604800 * 10 / 100))
  run "$SHIFT" --dry-run
  [[ "$output" == *"fixer: yes"* ]]
}

@test "a budget that cannot be read is a refusal, never permission" {
  # Three ways to not know, one answer. An unknown that fell through to `yes`
  # would spawn lanes on a machine whose quota nobody can see — the same
  # mistake `ci-unknown` and `tier-unknown` exist to refuse to make.
  run "$SHIFT" --dry-run   # setup() points FACTORY_USAGE_TSV at a missing file
  [[ "$output" == *"budget: unknown"*"fixer: no (budget unknown)"* ]]

  printf 'claude\tclaude\t0\t0\tstub\n' >"$TMP/usage.tsv"
  export FACTORY_USAGE_TSV="$TMP/usage.tsv"
  run "$SHIFT" --dry-run
  [[ "$output" == *"unreadable feed"*"fixer: no (budget unknown)"* ]]

  printf '10\t50\t0\t0\tstub\n' >"$TMP/usage.tsv"
  run "$SHIFT" --dry-run
  [[ "$output" == *"no weekly reset stamp"*"fixer: no (budget unknown)"* ]]
}

# ── the four blind spots ─────────────────────────────────────────────────────

@test "a main whose latest run cannot be READ is ci-unknown, never silence" {
  stub_gh ok fail none
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"ci-unknown: perch"* ]]
  # not-red and could-not-look must not print the same thing, or a red main
  # inside a flaky window is reported by omission.
  [[ "$output" != *"CI-RED"* ]]
  # And it carries WHY: telling a blip from a rate limit is the foreman's
  # judgement, and this line is all it has to make it on.
  [[ "$output" == *"http2: client conn could not be established"* ]]
}

@test "a repo whose open PRs cannot be listed says so, and still checks its CI" {
  stub_gh ok red fail
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"prs-unknown: perch"* ]]
  # An unlistable PR set must not take the CI half down with it: they are
  # independent questions about the same repo.
  [[ "$output" == *"CI-RED: perch"* ]]
}

@test "a PR that could not be judged is tier-unknown, not queued" {
  stub_gh ok green one
  stub_tier 1
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [[ "$output" == *"tier-unknown: perch#7"* ]]
  # The expensive collapse: the nightshift skill tells the foreman that queued
  # rows need nothing, so an unjudged PR filed as queued is one nobody revisits.
  [[ "$output" != *"queued: perch#7"* ]]
}

@test "a failed org listing aborts the pass instead of reporting a quiet night" {
  stub_gh fail green none
  run "$SHIFT" --dry-run
  [ "$status" -ne 0 ]
  [[ "$output" == *"pass ABORTED"* ]]
  [[ "$output" != *"pass done: 0 merged"* ]]
}

@test "an empty org listing aborts too — nothing sensed is not nothing to report" {
  stub_gh empty green none
  run "$SHIFT" --dry-run
  [ "$status" -ne 0 ]
  [[ "$output" == *"pass ABORTED"* ]]
  [[ "$output" != *"pass done: 0 merged"* ]]
}

# ── the notify policy, which is a judgement and therefore worth pinning ───────

@test "one unseeable repo does not card — that judgement is the foreman's" {
  stub_gh ok fail none
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  [ ! -f "$TRILL_CALLS" ]
}

@test "a pass that could not run at all DOES card — the blast radius differs" {
  stub_gh fail green none
  run "$SHIFT" --dry-run
  [ "$status" -ne 0 ]
  grep -q "pass aborted" "$TRILL_CALLS"
}

# ── the log is the handover, so it has to hold what the terminal showed ───────

@test "every line the pass printed is also in the day's log" {
  stub_gh ok fail none
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  log="$FACTORY_STATE_DIR/shift-$(date +%Y%m%d).log"
  [ -f "$log" ]
  grep -q "ci-unknown: perch" "$log"
}

@test "a multi-line stderr becomes one log line, because one event is one line" {
  cat >"$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
case "$1 $2" in
"repo list") echo "perch" ;;
"pr list") ;;
"run list") printf 'error: one\nerror: two\nerror: three\n' >&2; exit 1 ;;
esac
EOF
  chmod +x "$TMP/bin/gh"
  run "$SHIFT" --dry-run
  [ "$status" -eq 0 ]
  log="$FACTORY_STATE_DIR/shift-$(date +%Y%m%d).log"
  [ "$(grep -c 'ci-unknown' "$log")" -eq 1 ]
  grep -q 'ci-unknown: perch .*error: one error: two error: three' "$log"
}
