#!/usr/bin/env bash
# Sound — the third §5.6 group with no spike behind it, until now.
#
# The roadmap said "no typed nix-darwin domain covers it". That is wrong: TWO
# keys are typed (`com.apple.sound.beep.volume`, `com.apple.sound.beep.feedback`),
# and the interesting half is not whether they write — they do, instantly, with
# no FDA gate and no restart — but what the number MEANS. The volume leaf looks
# like a fraction and is not one.
#
# Oracle: `osascript -e 'get volume settings'` reads CoreAudio's live alert
# volume (0–100), which is a genuine effective-state probe in the same sense as
# NSWorkspace for accessibility — it is not a re-read of the plist we just wrote.
# The keys with no such oracle say so and stop at persistence.
#
# Safe: the whole global domain is exported for reading, but only OUR keys are
# written back (never `defaults import` NSGlobalDomain), restored via an
# EXIT/INT trap and then compared fragment-by-fragment against the snapshot, so
# a retyped or missing key is reported rather than assumed.
# No sudo, no rebuild. Nothing is played unless you pass --audible.

set -uo pipefail

audible=""
[ "${1:-}" = "--audible" ] && audible=1

keys=(
  com.apple.sound.beep.volume
  com.apple.sound.beep.feedback
  com.apple.sound.beep.sound
  com.apple.sound.uiaudio.enabled
)
tmp="$(mktemp -d)"
snap="$tmp/global.plist"

# Snapshot and restore through PlistBuddy XML fragments, not `defaults read` +
# a bare `defaults write`. The bare form writes every value back as a STRING —
# beep.volume is a float and the two switches are bools — and a text comparison
# of `defaults read` output cannot see the difference, so the naive version of
# this script printed a green restore while retyping three keys.
frag() { /usr/libexec/PlistBuddy -x -c "Print :$1" "${2:-$snap}" 2>/dev/null || printf '<absent>'; }
restore_key() {
  local x
  if x=$(/usr/libexec/PlistBuddy -x -c "Print :$1" "$snap" 2>/dev/null); then
    defaults write -g "$1" "$x"
  else
    defaults delete -g "$1" >/dev/null 2>&1
  fi
}
cleanup() {
  printf '\n→ restoring…\n'
  for k in "${keys[@]}"; do restore_key "$k"; done
  local bad=0 after="$tmp/after.plist"
  defaults export -g "$after"
  for k in "${keys[@]}"; do
    if [ "$(frag "$k" "$snap")" != "$(frag "$k" "$after")" ]; then
      printf '  ✗ %s did not come back — snapshot kept at %s\n' "$k" "$snap"
      bad=1
    fi
  done
  if [ $bad -eq 0 ]; then
    printf '  ✓ every key back to its original state, VALUE AND TYPE\n'
    rm -rf "$tmp"
  fi
  printf '  alert volume now: %s\n' "$(alertvol)"
}

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }
alertvol() { osascript -e 'get volume settings' 2>/dev/null | sed 's/.*alert volume:\([0-9]*\).*/\1/'; }

defaults export -g "$snap" || { printf 'could not snapshot NSGlobalDomain\n'; exit 1; }
trap cleanup EXIT INT TERM

printf 'baseline alert volume: %s\n' "$(alertvol)"

# ---- A. beep.volume — typed, live, and NOT a percentage ---------------------
say "A. com.apple.sound.beep.volume (nix-darwin: typed float) — oracle: alert volume"
printf '  %-12s %-14s %s\n' "written" "alert volume" "linear reading would be"
for v in 1.0 0.7788008 0.6065307 0.4723665 0.5 0.3678794 0.0; do
  defaults write -g com.apple.sound.beep.volume -float "$v"
  sleep 0.5
  printf '  %-12s %-14s %s\n' "$v" "$(alertvol)" "$(awk -v x="$v" 'BEGIN{printf "%d", x*100}')"
done
defaults delete -g com.apple.sound.beep.volume >/dev/null 2>&1
sleep 0.5
printf '  %-12s %-14s %s\n' "<deleted>" "$(alertvol)" "— null = write nothing"
cat <<'EOF'

  The mapping is exponential: stored = e^(slider − 1), i.e. slider = 1 + ln(v).
  So 0.5 is 31%, not 50%, and everything at or below e^-1 ≈ 0.3679 is silence.
  nix-darwin's docstring lists 75/50/25% as magic constants without saying the
  shape, which is exactly how a rice ends up shipping "half volume" that isn't.

  The <deleted> row is the group's default policy, measured rather than assumed:
  removing the key returns the alert volume to the OS default (100), NOT to the
  last written value and not to 0. Null really is "write nothing".
EOF

# ---- B. the same key is written from the other side -------------------------
say "B. Two writers — the volume UI writes the identical key"
defaults write -g com.apple.sound.beep.volume -float 1.0   # known start for the demo
sleep 0.5
before=$(defaults read -g com.apple.sound.beep.volume 2>/dev/null)
osascript -e 'set volume alert volume 60' >/dev/null 2>&1
sleep 1
printf '  set alert volume 60 (the AppleScript/UI path) → plist key is now %s\n' \
  "$(defaults read -g com.apple.sound.beep.volume 2>/dev/null)"
printf '  (was %s — e^(0.6-1) = %s, so the UI stores the same exponential value)\n' \
  "$before" "$(awk 'BEGIN{printf "%.5f", exp(-0.4)}')"
cat <<'EOF'
  → a declared value silently reverts a hand-set alert volume on every rebuild,
    and a later drag of the slider silently diverges from the declaration. Same
    two-writers question as §5.7, one settings group down.
EOF

# ---- C. keys with no oracle -------------------------------------------------
say "C. Keys with no programmatic oracle (persistence only)"
persist() {
  local k="$1" a="$2" note="$3"
  if ! out=$(defaults write -g "$k" $a 2>&1); then
    printf '  ✗ %s — write refused: %s\n' "$k" "$out"; return
  fi
  printf '  ✓ %-32s persists as %-42s %s\n' "$k" "$(defaults read -g "$k")" "$note"
}
persist com.apple.sound.beep.feedback "-int 0" "(typed) volume-key feedback; no reader"
persist com.apple.sound.uiaudio.enabled "-int 0" "(untyped) UI sound effects"
persist com.apple.sound.beep.sound "-string /System/Library/Sounds/Submarine.aiff" \
  "(untyped) FULL PATH, unvalidated"
cat <<'EOF'

  beep.sound takes an absolute path, and nothing validates it: a typo persists
  exactly like a real path. Candidate alert sounds live in /System/Library/Sounds
  (14 on 26.6) and ~/Library/Sounds. Whether a bad path degrades to the default
  beep or to silence is the one open row in this group — it needs an ear.
EOF

if [ -n "$audible" ]; then
  say "  --audible: a control beep first, then Submarine, then a bogus path"
  # Section C leaves uiaudio.enabled=0 and beep.feedback=0 set. Beeping under
  # our own mute is how the first run of this produced four silent "beeps" and
  # no information at all — so put every key back and prove the channel works
  # BEFORE testing anything.
  for k in "${keys[@]}"; do restore_key "$k"; done
  sleep 1
  printf '  0/3 control — pristine settings, alert volume %s. You should hear a beep.\n' "$(alertvol)"
  osascript -e 'beep' >/dev/null 2>&1; sleep 2
  cat <<'EOF'
      Heard nothing? Then rows 1–3 below prove nothing either. Check: output
      device and its volume, a Focus/Do-Not-Disturb that suppresses alerts, and
      System Settings ▸ Sound ▸ Alert sound not set to "None". Fix that, re-run.
EOF
  printf '\n  1/3 beep.sound = Submarine.aiff (a sound that exists)\n'
  defaults write -g com.apple.sound.beep.sound -string /System/Library/Sounds/Submarine.aiff
  sleep 1; osascript -e 'beep' >/dev/null 2>&1; sleep 2
  printf '  2/3 beep.sound = /nope/does-not-exist.aiff\n'
  defaults write -g com.apple.sound.beep.sound -string /nope/does-not-exist.aiff
  sleep 1; osascript -e 'beep' >/dev/null 2>&1; sleep 2
  printf '  3/3 key deleted again — same reference as 0/3\n'
  restore_key com.apple.sound.beep.sound
  sleep 1; osascript -e 'beep' >/dev/null 2>&1; sleep 1
  cat <<'EOF'

  Did 1 differ from 0? Then the key works at all. Did 2 sound, and did it match
  3 or 1? Bogus path → default beep is a degrade a rice can live with; bogus
  path → silence is a broken option that reads as applied.
EOF
fi

# ---- D. the startup chime ---------------------------------------------------
say "D. Startup chime — nvram StartupMute (read-only here)"
if out=$(nvram StartupMute 2>&1); then
  printf '  %s\n' "$out"
else
  printf '  unset — the variable only exists once something has muted the chime\n'
fi
cat <<'EOF'
  Writing it is `sudo nvram StartupMute=%01`: firmware state, not a plist, so it
  is outside `system.defaults` entirely and outside this script's no-sudo rule.
  A curated `sound.startupChime` would need its own activation step, and would
  be the first setting in the group that survives an OS reinstall.
EOF

say "Done — everything restored on exit. Record results in macos-settings-matrix.md."
