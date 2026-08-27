#!/usr/bin/env bash
# Settle the universalaccess question — run this FROM A TERMINAL THAT HOLDS
# FULL DISK ACCESS (that's the whole point of the test).
#
# Background: haus's docs/macos-settings.md. `com.apple.universalaccess`
# refused every write during the original spike, but that spike ran under an app
# without FDA, so it could never have answered the positive case.
#
# There are TWO questions, and they are NOT the same — `com.apple.Accessibility`
# already showed that a write can succeed and still change nothing:
#
#   1. Does the write SUCCEED with FDA?
#   2. Does the value TAKE EFFECT (does macOS actually honour it)?
#
# Only "yes" to both means nix-darwin's system.defaults.universalaccess.*
# options are real on macOS 26.
#
# Safe by construction: snapshots the domain first, restores it at exit via a
# trap (even on Ctrl-C), and verifies the restore. Touches nothing else. No
# rebuild, no activation, no sudo.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
probe_src="$here/accessibility-effective.swift"
tmp="$(mktemp -d)"
snapshot="$tmp/universalaccess.plist"
restore_needed=""

cleanup() {
  if [ -n "$restore_needed" ]; then
    printf '\n→ restoring com.apple.universalaccess from snapshot…\n'
    defaults import com.apple.universalaccess "$snapshot" 2>/dev/null \
      && printf '  restored.\n' \
      || printf '  RESTORE FAILED — snapshot kept at %s\n' "$snapshot"
    # Belt and braces: the key should be gone regardless of import semantics.
    defaults delete com.apple.universalaccess hausFdaProbe >/dev/null 2>&1
    if defaults read com.apple.universalaccess reduceMotion >/dev/null 2>&1; then
      printf '  reduceMotion now: %s\n' "$(defaults read com.apple.universalaccess reduceMotion)"
    fi
  fi
  [ -n "$restore_needed" ] || rm -rf "$tmp"
}
trap cleanup EXIT INT TERM

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }

# ---- 0. does THIS process have Full Disk Access? --------------------------
# Strict read only. Do NOT fall back to `ls` — it succeeds on a mere stat, which
# makes an unreadable-but-existing file look readable (this exact bug produced a
# false "FDA present" reading during the original spike).
say "0. Does this terminal hold Full Disk Access?"
fda=yes
for p in "/Library/Application Support/com.apple.TCC/TCC.db" \
         "$HOME/Library/Safari/Bookmarks.plist"; do
  if head -c 16 "$p" >/dev/null 2>&1; then
    printf '   readable: %s\n' "$p"
  else
    printf '   DENIED:   %s\n' "$p"
    fda=no
  fi
done
if [ "$fda" = no ]; then
  cat <<'EOF'

   ✗ This terminal does NOT have Full Disk Access, so the test cannot answer
     anything new — it would just reproduce the original refusal.

     Grant it: System Settings ▸ Privacy & Security ▸ Full Disk Access ▸ (+),
     add your terminal, then FULLY QUIT and reopen it (a stale grant on macOS 26
     often needs removing and re-adding with the (+) button). Then re-run this.
EOF
  exit 2
fi
printf '   ✓ FDA present — the test is meaningful.\n'

# ---- 1. snapshot ----------------------------------------------------------
say "1. Snapshotting com.apple.universalaccess"
defaults export com.apple.universalaccess "$snapshot" \
  && printf '   snapshot: %s\n' "$snapshot" \
  || { printf '   could not export the domain; aborting.\n'; exit 1; }
restore_needed=1

# ---- 2. does a write succeed? --------------------------------------------
say "2. Q1 — does a write SUCCEED?"
if out=$(defaults write com.apple.universalaccess hausFdaProbe -int 42 2>&1); then
  if [ "$(defaults read com.apple.universalaccess hausFdaProbe 2>/dev/null)" = 42 ]; then
    printf '   ✓ WRITE SUCCEEDED and read back.\n'
    defaults delete com.apple.universalaccess hausFdaProbe >/dev/null 2>&1
  else
    printf '   ✗ write reported success but did not read back.\n'; exit 1
  fi
else
  printf '   ✗ WRITE STILL REFUSED even with FDA:\n     %s\n' "$out"
  printf '\n   VERDICT: FDA is not sufficient. The matrix stands as written.\n'
  exit 1
fi

# ---- 3. does it take effect? ---------------------------------------------
say "3. Q2 — does the value TAKE EFFECT?"
command -v swift >/dev/null 2>&1 || { printf '   swift not found; cannot sample effective state.\n'; exit 1; }
printf '   before: %s\n' "$(swift "$probe_src" 2>/dev/null)"
defaults write com.apple.universalaccess reduceMotion -bool true
printf '   plist:  reduceMotion=%s\n' "$(defaults read com.apple.universalaccess reduceMotion)"
after="$(swift "$probe_src" 2>/dev/null)"   # the probe settles ~2s internally
printf '   after:  %s\n' "$after"

say "VERDICT"
if printf '%s' "$after" | grep -q 'motion_reduced=true'; then
  cat <<'EOF'
  ✓✓ WRITES AND TAKES EFFECT with FDA.
     → nix-darwin's system.defaults.universalaccess.* options are REAL on 26,
       conditional on the rebuild being invoked from an FDA-holding app.
     → Update haus's docs/macos-settings.md; the five options move from
       "needs FDA / unproven" to "works, with an FDA caveat".
     → Keep the haus warning (haus#89): the caveat is exactly what it
       documents, and the activation-abort blast radius is unchanged.
EOF
else
  cat <<'EOF'
  ⚠️  WRITES BUT DOES NOT TAKE EFFECT — same shape as com.apple.Accessibility.
     → The plist accepts the value and macOS ignores it, which is the worst
       failure mode for a shared rice: it looks applied and isn't.
     → The five options stay unusable in practice. Consider whether a logout is
       required before calling this final (re-run after logging out).
EOF
fi
