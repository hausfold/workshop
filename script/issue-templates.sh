#!/usr/bin/env bash
# issue-templates.sh — render every family repo's .github/ISSUE_TEMPLATE/ from
# the one table below.
#
#   ./script/issue-templates.sh            write them
#   ./script/issue-templates.sh --check    fail if any repo has drifted
#   ./script/issue-templates.sh haus …     just the named repos
#
# WHY a generator for files that change once a year: there are nine of them and
# the shape is the product. Four forms hand-maintained across nine repos is
# `_bench`'s hazard with a wider blast radius (AGENTS.md: "a hand copy and can
# rot") — the day pounce's bug form asks for something haus's doesn't, a
# reporter's answer depends on which repo they happened to land in, and nothing
# anywhere fails. `--check` is the thing that fails.
#
# The design this renders is docs/bug-reports.md. Read that before editing a
# heredoc here: the field COUNT is load-bearing — four, because longer forms
# come back empty — so adding one is a decision, not a tweak.
set -euo pipefail

# The workshop dir. Overridable because CI checks out ONE repo at a time: the
# drift job clones the workshop and the repo under test side by side into a
# scratch dir and points this at it, rather than needing all eight present.
ROOT="${ISSUE_TEMPLATES_ROOT:-$(cd "$(dirname "$0")/.." && pwd)}"

# Where a repo's checkout is. Every family repo is a subdirectory of the
# workshop EXCEPT the workshop, which is the root itself — so the obvious
# "$ROOT/$repo" silently skipped the one repo this script lives in, reporting
# it as not-cloned.
repo_dir() {
  case "$1" in
    workshop) printf '%s' "$ROOT" ;;
    org)      printf '%s/org-profile' "$ROOT" ;;
    *)        printf '%s/%s' "$ROOT" "$1" ;;
  esac
}

# Every repo that takes reports from a human, plus `org` — the checkout of
# hausfold/.github, whose templates GitHub serves to any repo with none of its
# own (homebrew-tap, holt-swift, producer-desktop, and whatever gets created
# next). That fallback is the difference between "every repo" being a list we
# maintain and being true. `ops` is private and takes no reports, so it's out.
REPOS=(haus pounce perch trill holt nebelung hausfold.co workshop org)

# ---- the table ---------------------------------------------------------------
# TOOL      what the reporter calls it
# BLURB     one line, shown under "Bug report" in the chooser
# DOCS      where the docs for this thing live
# DIAG      the label of the diagnostics field; empty = this repo has no
#           diagnostic command and the field is omitted rather than faked
# DIAG_HINT the sentence under it, naming the exact command
# AREAS     the "where" dropdown. Last option is always "somewhere else / not sure".
#           No colons — these are YAML plain scalars.
# SECURITY  the repo whose Security tab takes a private report. Its own, except
#           for the org-wide default, which has no repo of its own to point at.
meta() {
  DIAG=""; DIAG_HINT=""; SECURITY="$1"
  case "$1" in
    haus)
      TOOL="haus"
      BLURB="Something about the desktop doesn't work"
      DOCS="https://hausfold.co/docs/haus"
      DIAG="haus doctor"
      DIAG_HINT="Paste the output of \`haus doctor\`. It only reads — it changes nothing, prompts for nothing, and sends nothing anywhere."
      AREAS=(
        "installing — the one-liner, bootstrap, first rebuild"
        "rebuild, update or rollback"
        "windows — tiling, workspaces, the keybinds"
        "bar — the menu bar"
        "terminal — Ghostty, the shell, sessions"
        "launcher — Pounce wiring"
        "shelf — Perch wiring"
        "focus, notifications or Do Not Disturb"
        "security, secrets or Touch ID"
        "apps, Homebrew or the App Store"
        "appearance, theme or wallpaper"
        "desktops — choosing, customizing, sharing one"
        "the haus CLI itself"
        "the docs"
        "somewhere else, or not sure"
      )
      ;;
    pounce)
      TOOL="Pounce"
      BLURB="Something about the palette doesn't work"
      DOCS="https://hausfold.co/docs/pounce"
      DIAG="pounce doctor"
      DIAG_HINT="Paste the output of \`pounce doctor\`. It only reads — it changes nothing and sends nothing anywhere."
      AREAS=(
        "the hotkey — pressing it opens nothing"
        "results, ranking or search"
        "a built-in command"
        "writing my own command"
        "settings or config.json"
        "the daemon — launchd, starting, restarting"
        "installing or updating"
        "the docs"
        "somewhere else, or not sure"
      )
      ;;
    perch)
      TOOL="Perch"
      BLURB="Something about the shelf doesn't work"
      DOCS="https://hausfold.co/docs/perch"
      DIAG="Version and macOS"
      DIAG_HINT="Perch's version (menu bar → About, or \`perch --version\`), your macOS version, and your Mac model. Perch has no doctor command yet, so this is the substitute."
      AREAS=(
        "dragging files in"
        "dragging files out"
        "the notch — it doesn't appear, or appears wrong"
        "staging, clearing or losing an item"
        "Finder integration"
        "iPhone or iPad"
        "updating"
        "installing — the zip, the cask, Gatekeeper"
        "the docs"
        "somewhere else, or not sure"
      )
      ;;
    trill)
      TOOL="trill"
      BLURB="Something about notifications doesn't work"
      DOCS="https://hausfold.co/docs/trill"
      DIAG="trill doctor"
      DIAG_HINT="Paste the output of \`trill doctor\`. It only reads — it changes nothing and sends nothing anywhere. If it says it needs Full Disk Access, paste that too; it's an answer."
      AREAS=(
        "a banner — wrong, missing, or won't go away"
        "rules.json — something isn't matching"
        "the trill CLI"
        "an action button"
        "digest or catch-up"
        "the GitHub provider"
        "installing or updating"
        "the docs"
        "somewhere else, or not sure"
      )
      ;;
    holt)
      TOOL="holt"
      BLURB="Something about worktrees or lanes doesn't work"
      DOCS="https://github.com/hausfold/holt#readme"
      DIAG="Version and platform"
      DIAG_HINT="\`holt --version\`, your OS, and which client you spawned the lane with (Claude Code, Codex, OpenCode…)."
      AREAS=(
        "creating a lane"
        "resuming a parked lane"
        "park or unpark"
        "reap — something was removed, or won't be"
        "hooks"
        "the registry — a lane is missing or wrong"
        "an SDK — Go, Swift, TypeScript, Python, Rust"
        "installing"
        "the docs"
        "somewhere else, or not sure"
      )
      ;;
    nebelung)
      TOOL="Nebelung"
      BLURB="A port is wrong, broken, or missing"
      DOCS="https://github.com/hausfold/nebelung#readme"
      AREAS=(
        "a port renders wrong"
        "a port won't install"
        "a port Catppuccin has and we don't"
        "the palette itself — a colour looks wrong"
        "building it — build.sh, the templates"
        "the docs"
        "somewhere else, or not sure"
      )
      ;;
    hausfold.co)
      TOOL="the site"
      BLURB="A page is wrong, broken, or missing"
      DOCS="https://hausfold.co/docs"
      AREAS=(
        "a docs page is wrong or out of date"
        "a docs page is missing"
        "the install one-liner"
        "a download or release link"
        "the site itself — layout, search, links"
        "somewhere else, or not sure"
      )
      ;;
    workshop)
      TOOL="the workshop"
      BLURB="Something about bench or the cross-repo flow doesn't work"
      DOCS="https://github.com/hausfold/workshop#readme"
      DIAG="bench status"
      DIAG_HINT="Paste the output of \`bench status\`. It only reads."
      AREAS=(
        "bench status"
        "bench try or try-batch"
        "bench ship — a lock edge won't move"
        "bench release"
        "bench overlap"
        "bench docs-since"
        "the completion — _bench"
        "the README or AGENTS.md"
        "somewhere else, or not sure"
      )
      ;;
    # The org-wide default: what a reporter gets in any hausfold repo that
    # doesn't ship its own forms. It can't ask for `haus doctor` — it doesn't
    # know what they're running — and its "where" dropdown is the tool list
    # rather than one tool's insides, which makes it the ROUTING form. Routing
    # is exactly what a reporter who landed in the tap or a mirror needs.
    org)
      TOOL="hausfold"
      BLURB="Something in a hausfold repo doesn't work"
      DOCS="https://hausfold.co/docs"
      # Advisories are per-repo and there is no org-wide form, so the family's
      # front door takes them; same maintainer either way.
      SECURITY="haus"
      AREAS=(
        "haus — the desktop"
        "Pounce — the command palette"
        "Perch — the notch shelf"
        "trill — notifications"
        "holt — agent worktrees"
        "Nebelung — the theme"
        "the Homebrew tap"
        "hausfold.co — the site or docs"
        "somewhere else, or not sure"
      )
      ;;
    *) return 1 ;;
  esac
}

# ---- rendering ---------------------------------------------------------------
# @TOOL@ / @BLURB@ / @DOCS@ / @SECURITY@ substituted in; heredocs are quoted so
# the backticks inside the prose stay prose.
expand() { sed -e "s|@TOOL@|$TOOL|g" -e "s|@BLURB@|$BLURB|g" -e "s|@DOCS@|$DOCS|g" -e "s|@SECURITY@|$SECURITY|g"; }

render_config() {
  cat <<'EOF' | expand
# Generated by workshop/script/issue-templates.sh — edit the generator, not this.
#
# Blank issues are off deliberately, and it costs us nothing: templates only
# apply in the web UI, so `gh issue create` still opens anything we want from a
# terminal. What it buys is that a report from a stranger arrives in a shape.
blank_issues_enabled: false
#
# The security link needs private vulnerability reporting ON for that repo, or
# it 404s for exactly the person it's for. script/issue-labels.sh turns it on.
contact_links:
  - name: A security or privacy problem
    url: https://github.com/hausfold/@SECURITY@/security/advisories/new
    about: Report it privately, never in a public issue. We answer these first.
  - name: The docs
    url: @DOCS@
    about: Worth a look first — but a bug report that turns out to be documented is still a docs bug, so file it anyway.
  # ⚠️ This is a DIRECTORY, not a door. github.com/hausfold has no "new issue"
  # button, so anything here that reads as "file it at this link" sends someone
  # to a page that can't take their report. The earlier wording did exactly
  # that. The permission to file in the wrong place lives ON the bug form,
  # which is a place you can actually file.
  - name: Made by us, but a different tool?
    url: https://github.com/hausfold
    about: This page lists all of them — open its repo and use its Issues tab. Or just file here; moving an issue between our repos is one click for us.
EOF
}

render_bug() {
  cat <<'EOF' | expand
# Generated by workshop/script/issue-templates.sh — edit the generator, not this.
name: Bug report
description: @BLURB@
labels: ["bug", "triage"]
body:
  - type: markdown
    attributes:
      value: |
        **Wrong repo? File it anyway.** hausfold is one product split across
        eight repositories, and working out which one owns your bug is our job,
        not yours — we move issues between them in one click.

        There's no telemetry in any of this, ever. This form is the only way we
        find out.
  - type: textarea
    id: what
    attributes:
      label: What happened?
      description: |
        What you did, what you expected, and what you got instead. Verbatim
        beats tidy — "it said something about a lock file" is worth more
        polished than nothing.
      placeholder: |
        I …
        I expected …
        Instead …
    validations:
      required: true
  - type: dropdown
    id: area
    attributes:
      label: Where in @TOOL@?
      description: A guess is fine. It only routes the first look.
      options:
EOF
  printf '        - %s\n' "${AREAS[@]}"
  cat <<'EOF' | expand
    validations:
      required: true
EOF
  if [ -n "$DIAG" ]; then
    # Block scalars, not quoted ones. Every hint here grows an apostrophe
    # sooner or later — "Perch's version", "it's an answer" — and a YAML
    # single-quoted scalar ENDS at the first one, so perch's and trill's forms
    # rendered as invalid YAML on the first pass. A block scalar has no escape
    # to get wrong, and the text is written by us, one line, from the table
    # above.
    cat <<'EOF'
  - type: textarea
    id: diagnostics
    attributes:
      label: |-
EOF
    printf '        %s\n' "$DIAG"
    cat <<'EOF'
      description: |-
EOF
    printf '        %s\n' "$DIAG_HINT"
    cat <<'EOF'
      render: text
    validations:
      required: false
EOF
  fi
  cat <<'EOF' | expand
  - type: textarea
    id: anything
    attributes:
      label: Anything else
      description: A screenshot, a log line, a hunch about what caused it. Optional — send the form without it rather than not sending it.
    validations:
      required: false
EOF
}

render_idea() {
  cat <<'EOF' | expand
# Generated by workshop/script/issue-templates.sh — edit the generator, not this.
name: Idea
description: Something @TOOL@ should do, or should do differently
labels: ["idea", "triage"]
body:
  - type: markdown
    attributes:
      value: |
        Two questions. The second one is the one that decides it — an idea we
        can picture someone's actual Tuesday around beats a good idea in the
        abstract every time.
  - type: textarea
    id: what
    attributes:
      label: What would you want to do?
      description: Describe it as the thing you'd do, not as the feature that would let you do it.
      placeholder: |
        I want to …
    validations:
      required: true
  - type: textarea
    id: today
    attributes:
      label: What do you do today instead?
      description: The workaround, the other app, the thing you gave up on. If the answer is "nothing, I just don't", that's an answer.
    validations:
      required: true
EOF
}

render_task() {
  cat <<'EOF' | expand
# Generated by workshop/script/issue-templates.sh — edit the generator, not this.
#
# The four blocks below are the PR body's four blocks, on purpose: an issue
# filled in this way IS the PR body, written before the work instead of after.
# Whoever does the work opens a PR whose body is this one with Verify ticked.
#
# ⚠️ This form is MAINTAINER-FACING on a chooser that strangers read, so its
# title and description have one job before anything else: let a reporter rule
# it out in one glance. Words that only mean something inside the workshop —
# "lane", "spec", "ripple" — cost a reporter a re-read here and buy nothing,
# since the people who fill this in already know the flow.
name: Task (for maintainers)
description: Work we've already decided to do, written up so someone can pick it up
labels: ["task"]
body:
  - type: markdown
    attributes:
      value: |
        **This one's for us.** It's not a place to report a problem or ask for
        something — it's how we write down work that's already been decided.

        Reporting a problem? Use **Bug report**. Suggesting something? Use
        **Idea**. We turn those into one of these ourselves once we've decided
        to do them.
  - type: textarea
    id: what
    attributes:
      label: What
      description: The change, in the imperative. One sentence if it can be.
    validations:
      required: true
  - type: textarea
    id: why
    attributes:
      label: Why
      description: What's wrong today. Link the bug or idea this came from.
    validations:
      required: true
  - type: textarea
    id: verify
    attributes:
      label: Verify
      description: The exact commands or clicks that prove it works, in order. Whoever feel-tests this later has only this list.
      placeholder: |
        - [ ] `bench try switch`, then …
    validations:
      required: true
  - type: textarea
    id: watchout
    attributes:
      label: Watch out
      description: Blast radius. Other repos, other people's branches, anything that has to land before or after this.
    validations:
      required: false
EOF
}

# ---- drive -------------------------------------------------------------------
write_repo() { # write_repo <repo> <dest-dir>
  local repo="$1" dir="$2"
  meta "$repo" || { echo "no table row for '$repo'" >&2; return 1; }
  mkdir -p "$dir"
  render_config > "$dir/config.yml"
  render_bug    > "$dir/bug.yml"
  render_idea   > "$dir/idea.yml"
  render_task   > "$dir/task.yml"
}

check=0
case "${1:-}" in --check) check=1; shift ;; -h|--help) sed -n '2,10p' "$0"; exit 0 ;; esac
targets=("$@"); [ ${#targets[@]} -eq 0 ] && targets=("${REPOS[@]}")

rc=0
for repo in "${targets[@]}"; do
  dest="$(repo_dir "$repo")/.github/ISSUE_TEMPLATE"
  if [ ! -e "$(repo_dir "$repo")/.git" ]; then
    printf '  ⚠ %s — not checked out here, skipped (bench clone)\n' "$repo"
    continue
  fi
  if [ "$check" -eq 1 ]; then
    tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
    write_repo "$repo" "$tmp"
    if diff -ru "$dest" "$tmp" >/dev/null 2>&1; then
      printf '  ✓ %s\n' "$repo"
    else
      printf '  ✗ %s — drifted from the generator:\n' "$repo"
      diff -ru "$dest" "$tmp" || true
      rc=1
    fi
    rm -rf "$tmp"; trap - EXIT
  else
    write_repo "$repo" "$dest"
    printf '  ✓ %s\n' "$repo"
  fi
done
exit $rc
