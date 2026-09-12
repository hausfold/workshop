#!/usr/bin/env bash
# ci-cache-value.sh — what a CI job actually costs, and what the Nix store
# cache is actually holding.
#
# The store cache (docs/ci.md, "The Nix store cache") is on haus and nebelung
# and deliberately not on the repos whose expensive derivation is the Swift
# that just changed. Two questions were left open for measurement, and both
# need numbers nobody can read off the repo:
#
#   1. Do scruff's and snug's `nix` jobs earn a cache? Only if the job is on
#      the run's critical path AND the seconds a restore could remove are the
#      seconds it actually spends. A job that fetches from cache.nixos.org and
#      then builds the thing that just changed has almost nothing to restore.
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
# names move. Section 3 is the only section that measures the ceiling; until a
# push to main has actually saved an entry it correctly prints nothing, and a
# cold run's job time is not the counterfactual for a warm one.
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

    # What the run logged as it saved, if it saved: the store as nar bytes,
    # and the compressed entry that number turned into. Only the second is
    # comparable with the 10 GB ceiling. A run that only restored logs
    # neither, and says so.
    log=$(gh run view --repo "$ORG/$repo" --job "${nix_job%%$'\t'*}" --log 2>/dev/null || true)
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
