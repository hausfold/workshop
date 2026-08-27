#!/usr/bin/env bash
# issue-labels.sh — the GitHub-side half of the bug report flow: the labels the
# forms apply, and the private security destination their first contact link
# points at.
#
#   ./script/issue-labels.sh            show what would change (default)
#   ./script/issue-labels.sh --apply    make it so
#   ./script/issue-labels.sh --apply haus pounce   just the named repos
#
# WHY this is a script and not a one-time click: `.github/ISSUE_TEMPLATE/bug.yml`
# declares `labels: ["bug", "triage"]`, and GitHub silently DROPS a label that
# doesn't exist in that repo — the issue opens, the label isn't on it, and
# nothing anywhere says so. So the forms and the label set are one artifact
# split across two places, and this is the half that lives on GitHub.
#
# Same for the security link: `config.yml`'s first contact link is
# /security/advisories/new, which 404s unless private vulnerability reporting is
# ON for that repo. It was off on all nine when the forms were written.
#
# Read-only by default because everything here writes to a PUBLIC org.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ORG="hausfold"

# The repos that ship forms — issue-templates.sh's REPOS, resolved to their real
# GitHub names (its `org` is the checkout dir `org-profile`, i.e. hausfold/.github).
# Read from the generator rather than copied, so a repo added there cannot be
# silently missing its labels here — two hand-kept copies of one list, where
# nothing fails when they disagree, is `_bench`'s standing hazard (AGENTS.md)
# and there is no reason to grow a second instance of it.
mapfile -t REPOS < <(
  sed -n 's/^REPOS=(\(.*\))$/\1/p' "$ROOT/script/issue-templates.sh" \
    | tr ' ' '\n' | sed -e 's/^org$/.github/' -e 's/^workshop$/workshop/'
)
[ ${#REPOS[@]} -gt 0 ] || { echo "couldn't read REPOS from script/issue-templates.sh" >&2; exit 1; }

# ---- the label set -----------------------------------------------------------
# name|colour|description. Colours are Nebelung's (palette/nebelung.hex.json) so
# the issue list looks like everything else we make.
#
# Only THREE are ours. `bug` ships with every GitHub repo and already means the
# right thing, so it is deliberately absent — restyling a default label is churn
# on nine repos that buys nothing.
LABELS=(
  "triage|f5b58e|Not looked at yet. Every bug and idea starts here; a maintainer takes it off."
  "idea|c9a8f1|Something we could do. Not a commitment."
  "task|7dc6e7|Decided work, specified enough for a lane to pick up."
)

apply=0
case "${1:-}" in
  --apply) apply=1; shift ;;
  -h|--help) sed -n '2,10p' "$0"; exit 0 ;;
esac
targets=("$@"); [ ${#targets[@]} -eq 0 ] && targets=("${REPOS[@]}")

command -v gh >/dev/null 2>&1 || { echo "needs gh (github.com/cli/cli)" >&2; exit 1; }

[ "$apply" -eq 1 ] || printf '  (dry run — nothing is written. Re-run with --apply.)\n\n'

changes=0
for repo in "${targets[@]}"; do
  printf '\033[38;5;103m%s\033[0m\n' "$ORG/$repo"

  # Labels. `gh label create --force` is create-or-update in one call, but it
  # rewrites colour and description every time, so the dry run has to do the
  # comparison itself to say anything useful.
  existing="$(gh label list --repo "$ORG/$repo" --limit 100 --json name,color,description 2>/dev/null || echo '[]')"
  for spec in "${LABELS[@]}"; do
    IFS='|' read -r name colour desc <<<"$spec"
    have="$(printf '%s' "$existing" | jq -r --arg n "$name" '.[] | select(.name == $n) | "\(.color)|\(.description)"')"
    if [ "$have" = "$colour|$desc" ]; then
      printf '  ✓ label %s\n' "$name"
      continue
    fi
    changes=$((changes + 1))
    if [ -z "$have" ]; then printf '  + label %s (#%s)\n' "$name" "$colour"
    else                    printf '  ~ label %s — colour/description differ\n' "$name"; fi
    [ "$apply" -eq 1 ] || continue
    gh label create "$name" --repo "$ORG/$repo" --color "$colour" --description "$desc" --force >/dev/null
  done

  # Private vulnerability reporting — what config.yml's first contact link needs.
  # The GET is a 204/404 pair rather than a body, so `-i` and the status line is
  # the answer.
  if gh api "repos/$ORG/$repo/private-vulnerability-reporting" --jq '.enabled' 2>/dev/null | grep -qx true; then
    printf '  ✓ private vulnerability reporting\n'
  else
    changes=$((changes + 1))
    printf '  + private vulnerability reporting (its /security/advisories/new 404s until this is on)\n'
    if [ "$apply" -eq 1 ]; then
      gh api -X PUT "repos/$ORG/$repo/private-vulnerability-reporting" >/dev/null \
        || printf '    ⚠ could not enable it — needs admin on this repo\n'
    fi
  fi
done

echo
if [ "$changes" -eq 0 ]; then
  printf '\033[38;5;108m✓\033[0m everything already matches\n'
elif [ "$apply" -eq 1 ]; then
  printf '\033[38;5;108m✓\033[0m %d change(s) applied\n' "$changes"
else
  printf '\033[38;5;179m⚠\033[0m %d change(s) pending — re-run with --apply\n' "$changes"
fi
