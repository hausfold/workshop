#!/usr/bin/env bash
# Locale / input sources — the §5.6 group that blocks every non-English rice,
# spiked the way §4 spiked universalaccess.
#
# Four questions, in the order they bite:
#
#   A. do the region keys take effect?          (yes — for FRESH processes)
#   B. does the dict-valued key take effect?    (no — lands and lies, like
#                                                FontSizeCategory before it)
#   C. does an ALREADY-RUNNING app notice?      (no — unless a distributed
#                                                notification is posted, which
#                                                `defaults write` does not do)
#   D. can input sources be set from a plist?   (yes — but the key that
#                                                resolves the layout is not the
#                                                one that looks authoritative)
#
# Oracle: locale-effective.swift — Foundation + Carbon TIS in a fresh process,
# never a re-read of the plist we just wrote.
#
# Safe: per-key snapshot for NSGlobalDomain (XML fragments via PlistBuddy, so
# arrays and dicts round-trip exactly), full-domain export/import for
# com.apple.HIToolbox, restored via an EXIT/INT trap and verified after.
# No sudo, no rebuild. It never changes the SELECTED input source, only which
# layouts are enabled, so the worst intermediate state is an extra layout in
# the input menu.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
oracle_swift="$here/locale-effective.swift"
tis="$here/tis-toggle.swift"
tmp="$(mktemp -d)"
snap="$tmp/global.plist"
hisnap="$tmp/hitoolbox.plist"

keys=(
  AppleLocale AppleLanguages AppleICUForce24HourTime
  AppleMetricUnits AppleMeasurementUnits AppleTemperatureUnit AppleFirstWeekday
)

restore_key() {
  local k="$1" x
  if x=$(/usr/libexec/PlistBuddy -x -c "Print :$k" "$snap" 2>/dev/null); then
    defaults write -g "$k" "$x"
  else
    defaults delete -g "$k" >/dev/null 2>&1
  fi
}
frag() { /usr/libexec/PlistBuddy -x -c "Print :$1" "$2" 2>/dev/null || printf '<absent>'; }
cleanup() {
  printf '\n→ restoring…\n'
  for k in "${keys[@]}"; do restore_key "$k"; done
  if [ -s "$hisnap" ]; then defaults import com.apple.HIToolbox "$hisnap"; fi
  sleep 1
  # Verify, don't assume: compare every touched key's XML fragment (value AND
  # type) against the snapshot, rather than eyeballing the census line.
  local bad=0 after="$tmp/after.plist" hiafter="$tmp/hitoolbox-after.plist"
  defaults export -g "$after"
  defaults export com.apple.HIToolbox "$hiafter"
  for k in "${keys[@]}"; do
    if [ "$(frag "$k" "$snap")" != "$(frag "$k" "$after")" ]; then
      printf '  ✗ %s did not come back\n' "$k"; bad=1
    fi
  done
  if [ "$(frag AppleEnabledInputSources "$hisnap")" \
     != "$(frag AppleEnabledInputSources "$hiafter")" ]; then
    printf '  ✗ com.apple.HIToolbox AppleEnabledInputSources did not come back\n'; bad=1
  fi
  printf '  %s\n' "$(swift "$oracle_swift")"
  if [ $bad -eq 0 ]; then
    printf '  ✓ every touched key back to its original state, value and type\n'
    rm -rf "$tmp"
  else
    printf '  snapshots kept at %s — restore by hand from there\n' "$tmp"
  fi
}

say() { printf '\n\033[1m%s\033[0m\n' "$*"; }
o() { swift "$oracle_swift" | sed 's/^effective: //'; }

defaults export -g "$snap" || { printf 'could not snapshot NSGlobalDomain\n'; exit 1; }
defaults export com.apple.HIToolbox "$hisnap" || {
  printf 'could not snapshot com.apple.HIToolbox\n'; exit 1; }
trap cleanup EXIT INT TERM
printf 'snapshots: %s\n' "$tmp"
printf 'baseline → %s\n' "$(o)"

# ---- A. scalar region keys --------------------------------------------------
say "A. Region keys — write, then read a FRESH process's resolved locale"
t() {  # key, write args (unquoted on purpose), label
  local k="$1"; shift
  local label="${!#}"
  local args=("${@:1:$#-1}")
  defaults write -g "$k" "${args[@]}" || { printf '  ✗ %s refused\n' "$k"; return; }
  printf '  %-46s → %s\n' "$label" "$(o | sed 's/ inputCurrent.*//')"
  restore_key "$k"
}
t AppleICUForce24HourTime -bool true "AppleICUForce24HourTime=true (typed)"
t AppleMetricUnits -bool false "AppleMetricUnits=false (typed)"
t AppleMeasurementUnits -string Inches "AppleMeasurementUnits=Inches (typed)"
t AppleTemperatureUnit -string Fahrenheit "AppleTemperatureUnit=Fahrenheit (typed)"
t AppleLocale -string de_DE "AppleLocale=de_DE (UNtyped)"
defaults write -g AppleLocale -string de_DE
t AppleLanguages -array de-DE en-CA "AppleLanguages=[de-DE,en-CA] + de_DE locale"
restore_key AppleLocale
cat <<'EOF'

  Read the columns, not the verdicts. Three of the four typed keys move
  something on their own — force24 the hour format, AppleMetricUnits the
  measurement system, AppleTemperatureUnit the temperature unit. The fourth,
  `AppleMeasurementUnits`, moves NOTHING any oracle here can see, and it is the
  one with the friendly Inches/Centimeters enum — the key a rice reaches for
  first. macOS writes all three together when you change the region, so setting
  the obvious-looking one alone leaves a plist that reads right and a machine
  that ignores it. That is this section's "second key makes the first a lie".

  `AppleLocale` is the lever with real reach: it moves the hour format, the
  measurement system AND the first weekday together, and it is NOT typed by
  nix-darwin (→ CustomUserPreferences).
EOF

# ---- B. the dict-valued key -------------------------------------------------
say "B. AppleFirstWeekday — a dict-valued key (the FontSizeCategory shape)"
defaults write -g AppleFirstWeekday -dict gregorian 2
printf '  plist now: %s\n' "$(defaults read -g AppleFirstWeekday | tr -d '\n' | tr -s ' ')"
printf '  %-46s → %s\n' "AppleFirstWeekday={gregorian=2}" "$(o | sed 's/.*\(firstWeekday=[0-9]*\).*/\1/')"
restore_key AppleFirstWeekday
cat <<'EOF'
  Stored, no error, no effect — Calendar keeps the locale's own first weekday.
  Set AppleLocale instead (section A shows de_DE moving it to 2 on its own).
  Second dict-valued key in this shelf to behave this way, after
  FontSizeCategory: treat structured keys in Apple's global domain as GUI-only
  until one proves otherwise.
EOF

# ---- C. does a running app notice? -----------------------------------------
say "C. The load-bearing finding — a running process needs a NOTIFICATION"
# Four arms, because "post a notification" is not the finding — "post THIS
# notification" is. Without the bogus arm the result is indistinguishable from
# any distributed post nudging CFPreferences, and the whole `notify` verb this
# probe recommends would rest on an untested assumption.
notifications=(
  ""                                                     # no post at all
  "AppleDatePreferencesChangedNotification"
  "AppleMeasurementSystemPreferencesChangedNotification"
  "haus.totally.bogus.notification"                 # control
)
for name in "${notifications[@]}"; do
  printf '\n  write at t=4s, then post: %s\n' "${name:-<nothing>}"
  swift "$oracle_swift" --watch 12 > "$tmp/watch.out" 2>&1 &
  w=$!
  sleep 4
  defaults write -g AppleICUForce24HourTime -bool true
  if [ -n "$name" ]; then
    swift -e "import Foundation
      DistributedNotificationCenter.default().postNotificationName(
        Notification.Name(\"$name\"),
        object: nil, userInfo: nil, deliverImmediately: true)" >/dev/null 2>&1
  fi
  wait $w
  sed 's/^/    /' "$tmp/watch.out"
  restore_key AppleICUForce24HourTime
done
cat <<'EOF'

  No post: the value never arrives — not in 8 seconds, not in
  `autoupdatingCurrent`, which is the flavour documented to track changes.
  Either Apple name: both flavours flip within one sample.
  The bogus name: nothing — so this is name-specific, not a generic
  distributed-notification poke of CFPreferences.

  So the group's missing piece is not a key and not a `killall`: it is a
  distributed notification, which restart-map.nix has no vocabulary for.

  Caveat this does NOT cover: `AppleLanguages` changes which .lproj a bundle
  loads at launch. No notification can retrofit that into a running app, so the
  UI-language half of this group is honestly "takes effect on app relaunch".
EOF

# ---- D. input sources -------------------------------------------------------
say "D. Input sources — com.apple.HIToolbox"
printf '  the documented API path (TISEnableInputSource):\n'
swift "$tis" enable com.apple.keylayout.French >/dev/null 2>&1
sleep 1
printf '    enabled → %s\n' "$(o | sed 's/.*inputEnabled=//')"
printf '    macOS itself then wrote: %s\n' \
  "$(defaults read com.apple.HIToolbox AppleEnabledInputSources | tr -d '\n' | tr -s ' ' | grep -o '{ InputSourceKind = "Keyboard Layout"; "KeyboardLayout ID" = [0-9]*; "KeyboardLayout Name" = [^;]*;' | tail -1)"
swift "$tis" disable com.apple.keylayout.French >/dev/null 2>&1
sleep 1

printf '\n  the plist path — which key actually resolves the layout?\n'
plistwrite() {  # $1 = python dict literal appended to AppleEnabledInputSources
  rm -f "$tmp/new.plist"   # never let a previous row's file stand in for this one
  if ! /usr/bin/python3 - "$hisnap" "$tmp/new.plist" "$1" <<'PY'
import ast, plistlib, sys
snap, out, entry = sys.argv[1], sys.argv[2], ast.literal_eval(sys.argv[3])
p = plistlib.loads(open(snap, "rb").read())
p["AppleEnabledInputSources"] = list(p["AppleEnabledInputSources"]) + [entry]
open(out, "wb").write(plistlib.dumps(p))
PY
  then
    printf '    ✗ could not build the candidate plist — row skipped\n'
    return 1
  fi
  defaults import com.apple.HIToolbox "$tmp/new.plist"
  sleep 2
}
try() {
  plistwrite "$1" || return
  printf '    %-34s → %s\n' "$2" "$(o | sed 's/.*inputEnabled=//')"
  defaults import com.apple.HIToolbox "$hisnap"; sleep 1
}
try "{'InputSourceKind':'Keyboard Layout','KeyboardLayout Name':'German'}" \
    "name only, no ID"
try "{'InputSourceKind':'Keyboard Layout','KeyboardLayout ID':3,'KeyboardLayout Name':'German'}" \
    "name German + ID 3 (German's)"
try "{'InputSourceKind':'Keyboard Layout','KeyboardLayout ID':99999,'KeyboardLayout Name':'French'}" \
    "name French + ID 99999 (bogus)"
try "{'InputSourceKind':'Keyboard Layout','KeyboardLayout ID':1,'KeyboardLayout Name':'Nonexistent'}" \
    "bogus name + real ID"
cat <<'EOF'

  Inverted from hot corners. There the integer macOS stores was the truth and
  the name was ours to invent; here `KeyboardLayout ID` must merely be PRESENT
  and is never validated (99999 works), while `KeyboardLayout Name` is what
  resolves the layout — and a name macOS doesn't know is stored in silence.

  And the name is not derivable from the input-source ID:
  com.apple.keylayout.SwissFrench is "Swiss French", com.apple.keylayout.ABC-QWERTZ
  is "ABC-QWERTZ". You learn each one by letting macOS write it — which is what
  `swift tis-toggle.swift enable <id>` above is for, and why a curated option
  should take the stable `com.apple.keylayout.*` ID and resolve it through TIS
  at activation rather than shipping a hand-typed name/ID table in Nix.
EOF

say "Done — everything restored on exit. Record results in haus's docs/macos-settings.md."
