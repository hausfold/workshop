#!/usr/bin/env bats
# Unit tests for `script/factory-tier` — the filter that decides, with no
# person in the loop, which PRs the night shift may merge.
#
# This is the one script in the set whose output causes something with no
# undo-by-default. docs/factory.md says the merge decision is "made by a path
# filter a person reviewed, not by a model's read of the diff", and "the filter
# IS the definition" — claims about a jq expression, which only something that
# runs it can hold up. `test/factory-shift.bats` cannot: it stubs
# `factory-tier` with a hardcoded exit code, so the shift's suite proves what
# the shift does with a verdict and nothing about how a verdict is reached.
#
# The failure that matters here is not a crash either. It is a deny clause that
# stops matching — a nested `| not)` moved one paren, a lost `"i"` flag — and
# whose only symptom is a PR merging at 3 a.m. that a person meant to see. So
# every clause of the filter gets a case that would fail if that clause were
# deleted, and the affirmative is written first: a filter that refuses
# everything is a filter with no observable behaviour at all.
#
# `gh` is stubbed; `jq` is real, because the filter IS a jq program and a stub
# of it would be the thing under test.

setup() {
  TMP="$BATS_TEST_TMPDIR"
  mkdir -p "$TMP/bin"
  # Run the real script in place. Unlike `factory-shift` it resolves no
  # siblings by path, so there is nothing to shim next to it.
  TIER="$BATS_TEST_DIRNAME/../script/factory-tier"

  PATH="$TMP/bin:$PATH"
  export PATH
  export TIER_PR_JSON="$TMP/pr.json"
  export TIER_FILES_JSON="$TMP/files.json"
  export TIER_LOGIN=julienmartel

  # The catch-all arm is load-bearing. A `gh` subcommand this stub does not
  # know must be loud: answering an unrecognised call with silence and exit 0
  # is how a check quietly stops being made, which is the whole shape this
  # suite exists to prevent.
  cat >"$TMP/bin/gh" <<'EOF'
#!/usr/bin/env bash
case "$1 $2" in
"pr view")        cat "$TIER_PR_JSON" ;;
"api user")       printf '%s\n' "$TIER_LOGIN" ;;
"api --paginate") cat "$TIER_FILES_JSON" ;;
*) echo "gh stub: unexpected call: $*" >&2; exit 9 ;;
esac
EOF
  chmod +x "$TMP/bin/gh"

  files "docs/factory.md"
  pr
}

# Writes the paginated files payload. Each argument is a path, or
# `<path>:<status>` where the status is the REST endpoint's own word
# (`modified`, `added`, `renamed`). Also records the count, so `pr` below
# agrees with it by construction and a disagreement is something a test had
# to ask for.
files() {
  local json='[]' arg path status
  for arg in "$@"; do
    path="${arg%%:*}"
    status=modified
    case "$arg" in *:*) status="${arg##*:}" ;; esac
    json=$(jq --arg p "$path" --arg s "$status" '. + [{path: $p, status: $s}]' <<<"$json")
  done
  printf '%s\n' "$json" >"$TMP/files.json"
  NFILES=$#
}

# Writes the `gh pr view` payload. The base is a PR that IS tier 1 in every
# respect, and a case states only its own deviation as a jq assignment — so
# `pr '.isDraft = true'` is unambiguously about drafts, and a test that stops
# being about what it says is a test that had to be edited to get there.
pr() {
  jq -n --argjson n "${NFILES:-1}" '{
    state: "OPEN", isDraft: false, author: {login: "julienmartel"},
    baseRefName: "main", headRefName: "worktree-x",
    headRefOid: "1a2b3c4d5e", mergeable: "MERGEABLE",
    statusCheckRollup: [], changedFiles: $n, additions: 10, deletions: 2
  }' | jq "${1:-.}" >"$TMP/pr.json"
}

# ── the affirmative, and the contract factory-shift reads off it ──────────────

@test "a docs-only PR from a worktree branch is tier 1" {
  run "$TIER" perch 7
  [ "$status" -eq 0 ]
  [[ "$output" == "tier: 1 "* ]]
}

@test "the tier-1 line ENDS in the head SHA, because factory-shift slices it" {
  # `factory-shift` merges with `--match-head-commit "${verdict##*head=}"`,
  # which takes everything after the last `head=` on the line. Anything
  # appended after the SHA therefore becomes part of the SHA, the merge fails
  # closed forever, and the shift silently stops merging — a two-file contract
  # with nothing else checking it, so both sides are read here.
  run "$TIER" perch 7
  [ "$status" -eq 0 ]
  [[ "$output" == *"head=1a2b3c4d5e" ]]
  grep -q 'verdict##\*head=' "$BATS_TEST_DIRNAME/../script/factory-shift"
}

@test "a docs/ path that is not markdown is still tier 1" {
  # `^docs/` is a separate arm from `\.md$` and easy to lose in a rewrite that
  # "simplifies" the filter to markdown. haus's docs/site-data/ is generated
  # JSON that hausfold.co consumes, and it is docs.
  files "docs/site-data/options.json"
  pr
  run "$TIER" perch 7
  [ "$status" -eq 0 ]
}

@test "--paths-only answers the file filter alone, before the PR's state" {
  # The two halves are separable on purpose, and a draft is the cheapest proof
  # that the second half is genuinely not consulted.
  pr '.isDraft = true'
  run "$TIER" --paths-only perch 7
  [ "$status" -eq 0 ]
  [[ "$output" == "tier: paths ok"* ]]
}

# ── the deny list: one case per clause ────────────────────────────────────────

@test "every exclusion docs/factory.md names is one the filter actually makes" {
  # A prose exclusion that nothing executes is worse than no exclusion,
  # because it reads as a check: the doc naming a path the filter has never
  # heard of costs nothing until the night it merges one.
  #
  # Both sides are read for the same reason the budget dials are: a pin that
  # only greps the script is re-blessed by the same edit that breaks the doc —
  # docs/drift.md's row 20.
  #
  # ⚠️ The table below is hand-maintained, so it covers the exclusions it
  # LISTS and not "every exclusion the doc names". A new one needs a row here
  # or this case stays green while the pin stops reaching it.
  doc="$BATS_TEST_DIRNAME/../docs/factory.md"
  while IFS='|' read -r claim path; do
    grep -qF "$claim" "$doc" || { echo "doc no longer names: $claim"; false; }
    files "$path"
    pr
    run "$TIER" perch 7 </dev/null
    [ "$status" -eq 3 ] || { echo "not refused: $path"; false; }
    [[ "$output" == *"touches $path"* ]] || { echo "wrong reason for $path: $output"; false; }
  done <<'EOF'
AGENTS.md|AGENTS.md
CLAUDE.md|docs/CLAUDE.md
SKILL.md|.agents/skills/ship/SKILL.md
.github/|.github/ISSUE_TEMPLATE/bug.md
.claude/|.claude/notes.md
.agents/|.agents/README.md
content/|content/docs/index.md
EOF
}

@test "the agent-steering denies are case-insensitive, because APFS is" {
  # A merged docs/claude.md IS what a tool opening docs/CLAUDE.md reads on this
  # machine, so a lowercase spelling is the same policy change wearing a name
  # a case-sensitive filter does not recognise.
  files "docs/agents.md"
  pr
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"touches docs/agents.md"* ]]
}

@test "a path that is neither docs/ nor markdown is refused" {
  files "script/factory-tier"
  pr
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
}

@test "one bad path among good ones refuses the whole PR" {
  # The filter is over every file, not the first or the majority: a PR is tier
  # 1 only if there is nothing in it a person needed to see.
  files "docs/factory.md" "README.md" "AGENTS.md"
  pr
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"touches AGENTS.md"* ]]
}

# ── the structural checks, which are about the file LIST rather than its paths ─

@test "a rename is refused even when the new path is docs-shaped" {
  # A rename is a delete wearing a docs name: `git mv .github/workflows/x.yml
  # docs/x.md` passes every path test and removes a workflow. The REST
  # endpoint is what carries the status at all — GraphQL's file list does not.
  files "docs/moved.md:renamed"
  pr
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"renames docs/moved.md"* ]]
}

@test "a file list shorter than changedFiles is refused as truncated" {
  # The guard against paging silently stopping: files 101+ never meeting the
  # filter is indistinguishable from their not existing, and this is the only
  # thing that tells them apart.
  files "docs/a.md" "docs/b.md"
  pr '.changedFiles = 5'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"truncated (2 of 5)"* ]]
}

@test "a PR with no files is refused" {
  files
  pr
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"no files"* ]]
}

@test "churn over the cap is refused, and the cap is the documented 2000" {
  doc="$BATS_TEST_DIRNAME/../docs/factory.md"
  grep -qF '2000 changed lines' "$doc"
  pr '.additions = 1999 | .deletions = 2'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"2001 changed lines (cap 2000)"* ]]
}

@test "FACTORY_TIER_MAX_LINES tightens the cap" {
  # Only the environment moves it. A narrower cap is always safe; the point of
  # the knob is a night the user wants kept small, not a wider filter.
  pr '.additions = 50 | .deletions = 0'
  FACTORY_TIER_MAX_LINES=10 run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"(cap 10)"* ]]
}

# ── the PR's own state ────────────────────────────────────────────────────────

@test "a PR that is not open is refused" {
  pr '.state = "CLOSED"'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"not open"* ]]
}

@test "a draft is refused" {
  pr '.isDraft = true'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"draft"* ]]
}

@test "a base other than main is refused" {
  pr '.baseRefName = "release"'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"base is not main"* ]]
}

@test "a head that is not a worktree-* branch is refused" {
  # The lane convention is the proxy for "an agent of this user wrote it under
  # the rules in AGENTS.md". A branch named anything else did not come from
  # that path, whatever it contains.
  pr '.headRefName = "patch-1"'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"head is not a worktree-* branch"* ]]
}

@test "a PR by anyone but the authenticated user is refused" {
  # The check is against `gh api user`, not a name written down here, so it
  # keeps meaning "you" on any machine that runs it. A drive-by docs PR from a
  # stranger is the case this exists for.
  pr '.author.login = "someone-else"'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"author is not you"* ]]
}

@test "a conflicting PR is refused, and the reason names the state" {
  pr '.mergeable = "CONFLICTING"'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"mergeable=CONFLICTING"* ]]
}

@test "UNKNOWN mergeability is refused too — GitHub is still computing it" {
  # Not conflict-free, merely not yet known to be. Mergeability is computed
  # asynchronously after a push, so this is the ordinary state of a PR opened
  # seconds ago, and the next pass will have an answer.
  pr '.mergeable = "UNKNOWN"'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"mergeable=UNKNOWN"* ]]
}

# ── checks ────────────────────────────────────────────────────────────────────

@test "an empty check rollup is fine — most docs repos run no CI on PRs" {
  pr '.statusCheckRollup = []'
  run "$TIER" perch 7
  [ "$status" -eq 0 ]
}

@test "a check still running is 'not yet', not 'no'" {
  pr '.statusCheckRollup = [{status: "IN_PROGRESS", conclusion: null}]'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"checks still running"* ]]
}

@test "a red check is refused, and the reason names the conclusion" {
  pr '.statusCheckRollup = [{status: "COMPLETED", conclusion: "FAILURE"}]'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"check concluded FAILURE"* ]]
}

@test "NEUTRAL and SKIPPED conclusions are not red" {
  pr '.statusCheckRollup = [{status: "COMPLETED", conclusion: "SUCCESS"},
                            {status: "COMPLETED", conclusion: "NEUTRAL"},
                            {status: "COMPLETED", conclusion: "SKIPPED"}]'
  run "$TIER" perch 7
  [ "$status" -eq 0 ]
}

@test "a legacy commit status is read from .state when there is no conclusion" {
  # statusCheckRollup mixes two node types: CheckRun carries `conclusion`,
  # StatusContext carries `state`. Reading only the first would score every
  # commit-status check as the default SUCCESS.
  pr '.statusCheckRollup = [{state: "FAILURE"}]'
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"check concluded FAILURE"* ]]
}

# ── the CLI contract factory-shift depends on ─────────────────────────────────

@test "a missing argument is exit 2 — usage, not a verdict" {
  # 0, 3 and 2 are three different answers, and factory-shift's `tier-unknown`
  # arm exists because anything outside them means the script died mid-judgement.
  run "$TIER" perch
  [ "$status" -eq 2 ]
  [[ "$output" == *"usage:"* ]]
}

@test "a bare repo name is qualified to hausfold/, in the verdict line too" {
  files "AGENTS.md"
  pr
  run "$TIER" perch 7
  [ "$status" -eq 3 ]
  [[ "$output" == *"(hausfold/perch#7)"* ]]
}
