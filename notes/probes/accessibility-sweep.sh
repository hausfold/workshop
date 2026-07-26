#!/usr/bin/env bash
# Sweep every accessibility key the roadmap wants, now that FDA is known to be
# the gate. RUN FROM A TERMINAL THAT HOLDS FULL DISK ACCESS.
#
# universalaccess-fda-test.sh already proved the mechanism on ONE key
# (reduceMotion writes and takes effect with FDA). This fills in the rest,
# because "same domain, so it must work" is precisely the reasoning that got
# notes/macos-settings-matrix.md wrong twice.
#
# Two keys here are the point of the whole exercise and are NOT typed by
# nix-darwin — if they hold up they're reachable via CustomUserPreferences, and
# the large-print/high-contrast rice gains a system-level half it currently
# assumes it cannot have:
#
#   increaseContrast   — the high-contrast lever
#   FontSizeCategory   — macOS 26's per-app text size ("larger text")
#
# Honest about oracles. Some keys can be verified for EFFECT via NSWorkspace;
# the rest can only be shown to persist, and need a human eyeball. Each row says
# which it got, because "the write succeeded" was never sufficient evidence here
# (com.apple.Accessibility writes succeed and change nothing).
#
# Safe: snapshots the domain, restores via an EXIT/INT trap, verifies restore.
# No rebuild, no sudo.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
probe="$here/accessibility-effective.swift"
dom=com.apple.universalaccess
tmp="$(mktemp -d)"
snap="$tmp/universalaccess.plist"
restore_needed=""

cleanup() {
  if [ -n "$restore_needed" ]; then
    printf '\n→ restoring %s…\n' "$dom"
    if defaults import "$dom" "$snap" 2>/dev/null; then
      printf '  restored (snapshot: %s)\n' "$snap"
    else
      printf '  RESTORE FAILED — snapshot kept at %s\n' "$snap"
      return
    fi
  fi
  rm -rf "$tmp" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

say()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
oracle() { swift "$probe" 2>/dev/null; }   # settles ~2s internally

# ---- FDA gate -------------------------------------------------------------
# Strict read only — no `ls` fallback, which succeeds on a mere stat and once
# produced a false "FDA present" reading.
head -c 16 "/Library/Application Support/com.apple.TCC/TCC.db" >/dev/null 2>&1 || {
  cat <<'EOF'
✗ This terminal lacks Full Disk Access, so every write below would fail for a
  reason we already understand. Grant it (System Settings ▸ Privacy & Security ▸
  Full Disk Access ▸ (+)), fully quit and reopen the terminal, then re-run.
EOF
  exit 2
}
printf '✓ FDA present.\n'

defaults export "$dom" "$snap" || { printf 'could not snapshot %s\n' "$dom"; exit 1; }
restore_needed=1
printf '  snapshot: %s\n' "$snap"

# ---- keys with an NSWorkspace oracle (definitive) -------------------------
# key|write-args|token in the probe output that should flip to true
observable=(
  "reduceTransparency|-bool true|transparency_reduced=true"
  "increaseContrast|-bool true|contrast=true"
  "differentiateWithoutColor|-bool true|diffWithoutColor=true"
)

say "A. Keys with an effective-state oracle (definitive)"
for row in "${observable[@]}"; do
  IFS='|' read -r key args token <<<"$row"
  printf '\n  %s\n' "$key"
  if ! out=$(defaults write "$dom" "$key" $args 2>&1); then
    printf '    ✗ write refused: %s\n' "$out"; continue
  fi
  printf '    write ok; plist=%s\n' "$(defaults read "$dom" "$key" 2>/dev/null)"
  if oracle | grep -q "$token"; then
    printf '    ✓✓ TAKES EFFECT\n'
  else
    printf '    ⚠️  writes but NO EFFECT (may need logout — recheck after)\n'
    printf '       effective now: %s\n' "$(oracle)"
  fi
  defaults delete "$dom" "$key" >/dev/null 2>&1
done

# ---- keys with no oracle (persistence only) -------------------------------
say "B. Keys with no programmatic oracle (write/persist only — eyeball these)"
writeonly=(
  "mouseDriverCursorSize|-float 3.0|cursor should be visibly larger"
  "closeViewScrollWheelToggle|-bool true|^ + scroll should zoom"
  "closeViewZoomFollowsFocus|-bool true|zoom should follow keyboard focus"
)
for row in "${writeonly[@]}"; do
  IFS='|' read -r key args hint <<<"$row"
  printf '\n  %s\n' "$key"
  if ! out=$(defaults write "$dom" "$key" $args 2>&1); then
    printf '    ✗ write refused: %s\n' "$out"; continue
  fi
  printf '    ✓ writes and persists (plist=%s)\n' "$(defaults read "$dom" "$key" 2>/dev/null)"
  printf '    → check by eye: %s\n' "$hint"
done
printf '\n  (left set for ~10s so you can look, then restored at exit)\n'
swift -e 'import Foundation; Thread.sleep(forTimeInterval: 10)' 2>/dev/null
for row in "${writeonly[@]}"; do
  IFS='|' read -r key _ _ <<<"$row"
  defaults delete "$dom" "$key" >/dev/null 2>&1
done

# ---- FontSizeCategory: the large-print lever ------------------------------
say "C. FontSizeCategory — macOS 26 per-app text size (the 'larger text' lever)"
printf '  current: %s\n' "$(defaults read "$dom" FontSizeCategory 2>/dev/null | tr -d '\n' | cut -c1-160)"
if out=$(defaults write "$dom" FontSizeCategory -dict-add global -string LARGE 2>&1); then
  now="$(defaults read "$dom" FontSizeCategory 2>/dev/null | grep -c 'global = LARGE')"
  if [ "$now" = 1 ]; then
    printf '  ✓ accepted global = LARGE\n'
    printf '  → check by eye: open Notes or Messages — is body text larger?\n'
    printf '    (if yes, this is the system-level half of the large-print rice)\n'
    swift -e 'import Foundation; Thread.sleep(forTimeInterval: 10)' 2>/dev/null
  else
    printf '  ⚠️  write reported ok but the key did not change\n'
  fi
else
  printf '  ✗ refused: %s\n' "$out"
fi

say "Done — the domain is restored on exit. Record results in macos-settings-matrix.md."
