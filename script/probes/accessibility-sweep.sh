#!/usr/bin/env bash
# Sweep every accessibility key the roadmap wants, now that FDA is known to be
# the gate. RUN FROM A TERMINAL THAT HOLDS FULL DISK ACCESS.
#
# universalaccess-fda-test.sh already proved the mechanism on ONE key
# (reduceMotion writes and takes effect with FDA). This fills in the rest,
# because "same domain, so it must work" is precisely the reasoning that got
# haus's docs/macos-settings.md wrong twice.
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
# READ ONLY, deliberately. An earlier version of this script wrote
# `global = LARGE` and reported "✓ accepted" — which was worthless evidence:
# `defaults -dict-add` stores ANY string, so a made-up token looks exactly like
# a real one. `LARGE` was a guess, never read off Apple. Writing a bogus value
# here risks the same illusion com.apple.Accessibility already produced: a plist
# that looks applied and changes nothing.
#
# The vocabulary is small (the shipped value is `global = DEFAULT`) and the way
# to learn it is to let macOS write it, then read it back.
say "C. FontSizeCategory — macOS 26 per-app text size (read-only)"
printf '  current value:\n'
defaults read "$dom" FontSizeCategory 2>/dev/null | sed 's/^/    /'
cat <<'EOF'

  Vocabulary (resolved 2026-07-25 by setting Text size in System Settings and
  reading back): `DEFAULT`, then Apple's Dynamic Type steps `AX1`… — NOT size
  words. An earlier version of this script wrote `LARGE`; that would have been
  stored and silently ignored.

  Scope (also resolved): this only affects apps that adopted Dynamic Type — the
  per-bundle-ID list above is the whole participant set, and it is all Apple.
  With `global = AX1` live, a non-participant still reports default 13pt body
  text. So this is a nicety for Mail/Messages/Notes/Calendar, NOT a system-wide
  "make everything bigger".

  RESOLVED — and the answer is do not write this key. Tested: the write lands
  in the plist correctly, but posts no change notification. Running apps never
  re-read it (Notes stayed at default size), and System Settings renders a
  desynced view of its own per-app rows — several show "Default", one blank —
  which LOOKS like corruption but isn't; the plist is intact and reopening
  Settings shows the true values. Only dragging the slider by hand works.

  Heuristic from this domain: the SCALAR keys (section A) write, notify, and
  take effect. The one STRUCTURED key lands and lies. Treat dict-valued
  accessibility keys as GUI-only.
EOF

say "Done — the domain is restored on exit. Record results in macos-settings-matrix.md."
