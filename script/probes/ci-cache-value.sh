#!/usr/bin/env bash
# ci-cache-value.sh — what a CI job actually costs, and what the Nix store
# cache is actually holding.
#
# The store cache (docs/ci.md, "The Nix store cache") is on haus and nebelung
# and deliberately not on the repos whose expensive derivation is the Swift
# that just changed. It answers two questions nobody can read off a repo:
#
#   1. Does a `nix` job earn a cache? Only if the job is on the run's critical
#      path AND the seconds a restore could remove are the seconds it actually
#      spends. A restore hands back two of the three phases below — the
#      substitute row always, and the build row for every derivation the
#      change did NOT invalidate — and never the evaluation. So a step total
#      answers nothing: `nix build` is all three, and reading it as "the
#      fetch" is how snug's old verdict came to rest on 12s of `go build` and
#      `go test`. haus's cache pays on the build row (29 checks, most PRs
#      touching none of their inputs); snug's would pay on neither, because
#      the source change invalidates both its derivations every run. scruff
#      and snug both answer no; re-run before adding one anywhere new.
#   2. Is the store creeping toward GitHub's 10 GB per-repo ceiling? Not the
#      store on disk — the ceiling counts the COMPRESSED entry, and `du -sh
#      /nix/store` reads about six times high against it. Section 2 lifts the
#      two numbers the saving run logs and section 3 reads the live entries.
#
#   script/probes/ci-cache-value.sh                 # the four repos with Linux
#                                                   # nix jobs on their gate
#   script/probes/ci-cache-value.sh haus nebelung   # named repos
#   RUNS=20 script/probes/ci-cache-value.sh snug    # a wider sample
#   BRANCH=worktree-x script/probes/ci-cache-value.sh haus   # a lane, not main
#   ORG=someone-else script/probes/ci-cache-value.sh their-repo
#
# Honest about oracles. Section 1 is wall clock as GitHub recorded it, so a
# queued runner and a slow mirror are both in it — read the min, not the avg,
# for what the work costs. Section 2 is one run, the newest, because step
# names move, and its phase rows are that one run too. Section 3 is the only
# section that measures the ceiling; until a push to main has actually saved
# an entry it correctly prints nothing, and a cold run's job time is not the
# counterfactual for a warm one.
#
# Needs `gh` authenticated against the org. Read-only: no writes, no cache
# deletion, nothing that touches a run.
set -euo pipefail

ORG=${ORG:-hausfold}
RUNS=${RUNS:-10}
BRANCH=${BRANCH:-main}
repos=("$@")
[ ${#repos[@]} -gt 0 ] || repos=(haus nebelung scruff snug)

for repo in "${repos[@]}"; do
  printf '\n══ %s ══ last %s runs on %s\n' "$repo" "$RUNS" "$BRANCH"

  ids=$(gh run list --repo "$ORG/$repo" --branch "$BRANCH" --limit "$RUNS" \
        --json databaseId --jq '.[].databaseId')
  if [ -z "$ids" ]; then
    printf '  no runs\n'
    continue
  fi

  # 1. Wall clock per job. The longest average is the critical path: shaving a
  #    job that is not it buys the gate nothing.
  printf '\n  job wall clock\n'
  for id in $ids; do
    gh api "repos/$ORG/$repo/actions/runs/$id/jobs?per_page=100" --jq '
      .jobs[] | select(.completed_at != null)
      | [.name, ((.completed_at|fromdateiso8601) - (.started_at|fromdateiso8601))] | @tsv'
  done | awk -F'\t' '
    { n[$1]++; t[$1]+=$2; if ($2>hi[$1]) hi[$1]=$2; if (lo[$1]=="" || $2<lo[$1]) lo[$1]=$2 }
    END { for (k in n) printf "    %-38s n=%-3d avg=%4ds  min=%4ds  max=%4ds\n", k, n[k], t[k]/n[k], lo[k], hi[k] }
  ' | sort -t= -k3 -rn

  # 2. Where those seconds go in the job that runs nix — the only job a store
  #    cache can touch. Detected by step, not by job name: haus's is called
  #    "eval the example host".
  newest=$(printf '%s\n' "$ids" | head -1)
  jobs_json=$(gh api "repos/$ORG/$repo/actions/runs/$newest/jobs?per_page=100")
  # A step GitHub named itself reads "Run <command or action>", so `Run nix
  # eval`, `Run nixbuild/nix-quick-install-action@v35` and `Run
  # DeterminateSystems/nix-installer-action@v23` all match and a hand-named
  # step like haus's "nix-gc pins what macOS won't release" does not. Most
  # matches wins, so a job that merely mentions nix once cannot outrank the
  # one that runs it.
  nix_job=$(printf '%s' "$jobs_json" | jq -r '
    [ .jobs[]
      | { id, name, hits: ([.steps[].name | select(test("^Run \\S*nix"; "i"))] | length) }
      | select(.hits > 0) ]
    | sort_by(-.hits) | .[0] // empty | "\(.id)\t\(.name)"')
  if [ -n "$nix_job" ]; then
    printf '\n  nix job steps, run %s (%s)\n' "$newest" "${nix_job#*$'\t'}"
    printf '%s' "$jobs_json" | jq -r --arg id "${nix_job%%$'\t'*}" '
      .jobs[] | select(.id == ($id|tonumber)) | .steps[]
      | select(.completed_at != null)
      | "    \(((.completed_at|fromdateiso8601) - (.started_at|fromdateiso8601))|tostring|(" " * (5 - length)) + .)s  \(.name)"'

    # One fetch of the job's log serves the phase split and the save figures.
    log=$(gh run view --repo "$ORG/$repo" --job "${nix_job%%$'\t'*}" --log 2>/dev/null || true)
    [ -n "$log" ] || printf '\n  could not read the job log — no phases, no save figures\n'

    # A step is NOT a phase. `nix build` is at least three — evaluate,
    # substitute, build — and a restore replaces the second outright and as
    # much of the third as the change left alone. Read the step total as "the
    # fetch" and you get snug's old verdict, which rested on 12s that were
    # `go build` and `go test`. Split it at the markers nix prints into the
    # same log. One run, the newest, like the step list above it.
    phases=$(printf '%s' "$log" | awk -F'\t' '
      function tsec(l,   s, p) {
        if (!match(l, /[0-9][0-9]:[0-9][0-9]:[0-9][0-9]\.[0-9]+Z/)) return -1
        s = substr(l, RSTART, RLENGTH - 1); split(s, p, ":")
        return p[1] * 3600 + p[2] * 60 + p[3] }
      function d(a, b) { if (a < 0 || b < 0) return -1
        b -= a
        if (b < -43200) b += 86400      # a real midnight wrap
        else if (b < 0) return -1       # markers out of order: say nothing
        return b }
      function row(sec, name, note,   v) {
        v = sec < 0 ? "    -" : sprintf("%5.1f", sec)
        printf "    %ss  %-11s%s\n", v, name, note }
      function flush(e,   pe, se, why) {
        if (!open) return
        open = 0
        # A step that neither planned a fetch nor built anything is one phase
        # already — a warm store, or an eval that realised nothing.
        if (plan < 0 && build < 0) {
          if (marks > 0) why = "markers seen, but no timestamp on them to place"
          else           why = "nothing to split: no fetch planned, nothing built"
          printf "    %s\n           %s\n", cmd, why
          return }
        pe = (plan >= 0 ? plan : build)      # evaluate ends where the plan lands
        se = (build >= 0 ? build : e)        # substitute ends where building starts
        printf "    %s\n", cmd
        row(d(start, pe), "evaluate", "to the build plan")
        if (plan >= 0)
          row(d(plan, se), "substitute", mib " MiB")
        else
          row(0, "substitute", "nothing fetched — the store already had it")
        if (build >= 0)
          row(d(build, e), "build", drvs " derivation" (drvs == 1 ? "" : "s"))
        else
          row(0, "build", "nothing built") }
      { t = tsec($0) }
      # A step ends where the next one starts. `gh` names the step in field 2
      # on some logs and writes UNKNOWN STEP on others, so take the name when
      # it is there and fall back to the group line the runner writes.
      $2 != "" && $2 != "UNKNOWN STEP" && $2 != stepname { flush(prev); stepname = $2 }
      /##\[group\](Post )?Run |##\[group\]Post |Post job cleanup\./ {
        flush(prev)
        if ($0 ~ /##\[group\]Run ([^ ]* )*nix([ "]|$)/) {
          open = 1; start = t; plan = -1; build = -1; mib = "?"; drvs = 0; marks = 0
          sub(/^.*##\[group\]Run /, ""); sub(/\r$/, ""); cmd = $0 }
        prev = t; next }
      { if (t >= 0) prev = t }
      open && /will be fetched \(|building .\/nix\/store\// { marks++ }
      open && t >= 0 && /will be fetched \(/ {
        if (plan < 0) { plan = t
          if (build >= 0 && build < plan) build = -1   # an earlier invocation built that
          if (match($0, /\([0-9.]+ MiB/)) mib = substr($0, RSTART + 1, RLENGTH - 5) } }
      open && t >= 0 && /building .\/nix\/store\// { if (build < 0) build = t; drvs++ }
      END { flush(prev) }')
    if [ -n "$phases" ]; then
      printf '\n  phases inside those steps — a step is not a phase\n'
      printf '  a restore replaces substitute outright, build only where the change\n'
      printf '  left the inputs alone, and evaluate never (bar the input fetch in it)\n'
      printf '%s\n' "$phases"
    fi

    # What the run logged as it saved, if it saved: the store as nar bytes,
    # and the compressed entry that number turned into. Only the second is
    # comparable with the 10 GB ceiling. A run that only restored logs
    # neither, and these two lines simply do not appear.
    nar=$(printf '%s' "$log" | grep -oE 'Current store size in bytes: [0-9]+' | tail -1 | grep -oE '[0-9]+$' || true)
    sent=$(printf '%s' "$log" | grep -oE 'Sent [0-9]+ of [0-9]+ \(100\.0%\)' | tail -1 | awk '{print $4}' || true)
    [ -n "$nar" ]  && printf '    store as nar bytes: %s MiB\n' "$((nar / 1048576))"
    [ -n "$sent" ] && printf '    saved as an entry of: %s MiB (this is the one the ceiling counts)\n' "$((sent / 1048576))"
  else
    printf '\n  no job in run %s runs nix\n' "$newest"
  fi

  # 3. What the repo is actually holding. GitHub's ceiling is 10 GB per repo
  #    across ALL entries, evicting the least recently used, and dropping any
  #    entry untouched for 7 days.
  printf '\n  cache entries now (10 GB ceiling, compressed, all keys)\n'
  # shellcheck disable=SC2016  # $t is jq's, not the shell's
  gh cache list --repo "$ORG/$repo" --limit 100 \
     --json key,sizeInBytes,ref,lastAccessedAt --jq '
    (map(.sizeInBytes) | add // 0) as $t
    | (.[] | "    \(((.sizeInBytes/1048576)|floor|tostring) + " MiB" | (" " * (10 - length)) + .)  \(.lastAccessedAt[0:10])  \(.ref)  \(.key[0:44])"),
      "    ────── \(($t/1073741824)*100|round/100) GB of 10 GB, \(length) entr\(if length == 1 then "y" else "ies" end)"'
done
