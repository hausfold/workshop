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
# Safe: per-key snapshot (this is NSGlobalDomain — never import the whole
# domain), restored via an EXIT/INT trap, plus a residue check at the end.
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
declare -A had val

snapshot() {
  for k in "${keys[@]}"; do
    if v=$(defaults read -g "$k" 2>/dev/null); then had[$k]=1; val[$k]="$v"
    else had[$k]=""; fi
  done
}
restore() {
  for k in "${keys[@]}"; do
    if [ -n "${had[$k]:-}" ]; then defaults write -g "$k" "${val[$k]}"
    else defaults delete -g "$k" >/dev/null 2>&1; fi
  done
}
cleanup() {
  printf '\n→ restoring…\n'
  restore
  local bad=0
  for k in "${keys[@]}"; do
    now=$(defaults read -g "$k" 2>/dev/null); now=${now:-<unset>}
    want=${had[$k]:+${val[$k]}}; want=${want:-<unset>}
    [ "$now" = "$want" ] || { printf '  ✗ %s is %s, was %s\n' "$k" "$now" "$want"; bad=1; }
  done
  [ $bad -eq 0 ] && printf '  ✓ every key back to its original state\n'
  printf '  alert volume now: %s\n' "$(alertvol)"
}

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }
alertvol() { osascript -e 'get volume settings' 2>/dev/null | sed 's/.*alert volume:\([0-9]*\).*/\1/'; }

snapshot
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
cat <<'EOF'

  The mapping is exponential: stored = e^(slider − 1), i.e. slider = 1 + ln(v).
  So 0.5 is 31%, not 50%, and everything at or below e^-1 ≈ 0.3679 is silence.
  nix-darwin's docstring lists 75/50/25% as magic constants without saying the
  shape, which is exactly how a rice ends up shipping "half volume" that isn't.
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
  say "  --audible: playing three beeps (Submarine, then a bogus path, then restored)"
  osascript -e 'beep' >/dev/null 2>&1; sleep 1
  defaults write -g com.apple.sound.beep.sound -string /nope/does-not-exist.aiff
  sleep 1; osascript -e 'beep' >/dev/null 2>&1; sleep 1
  printf '  did the second beep still sound, and was it the default? ^ that is the answer\n'
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
