#!/usr/bin/env bash
# Power — the last of §5.6's three unspiked groups.
#
# The roadmap said "nix-darwin has no typed surface for this at all". That is
# wrong twice over: `power.sleep.{computer,display,harddisk,allowSleepByPowerButton}`
# and `power.restartAfter{PowerFailure,Freeze}` are all typed. What they are NOT
# is plist writes — like `networking.applicationFirewall`, this group is
# nix-darwin shelling out in its own activation script, here to `systemsetup`.
# So none of the restart-map machinery applies, and neither does any of this
# shelf's usual `defaults`-based evidence.
#
# Two things follow, and they are the whole reason this probe exists:
#
#   1. `systemsetup` has NO power-source selector. Every verb in its man page
#      is source-blind, while macOS stores battery and AC settings separately
#      (and this machine's differ). "Sleep at 5 min on battery, never on AC" —
#      the only opinion a laptop rice actually has — is not expressible.
#   2. nix-darwin sends every systemsetup call to `&> /dev/null`. A refusal,
#      a typo'd value, an unsupported verb: all identical to success.
#
# Sections A, B and D are read-only and run anywhere. Section C is the write
# test: it needs root (a Touch ID prompt on this machine) and is opt-in behind
# POWER_SWEEP_WRITE=1, so a warm sudo timestamp can never make it run by
# accident. It says so and skips rather than pretending.

set -uo pipefail

say()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
plist=/Library/Preferences/com.apple.PowerManagement.plist

# ---- A. what nix-darwin actually emits --------------------------------------
say "A. The typed surface, and how it is implemented"
cat <<'EOF'
  <nix-darwin>/modules/power/sleep.nix + default.nix (nix-darwin's own tree, NOT
  the rice's modules/), in system.activationScripts.power:

    systemsetup -setComputerSleep '<minutes|Never>'          &> /dev/null
    systemsetup -setDisplaySleep '<minutes|Never>'           &> /dev/null
    systemsetup -setHardDiskSleep '<minutes|Never>'          &> /dev/null
    systemsetup -setAllowPowerButtonToSleepComputer 'on|off' &> /dev/null
    systemsetup -setRestartPowerFailure 'on|off'             &> /dev/null
    systemsetup -setRestartFreeze 'on|off'                   &> /dev/null

  Six typed options, no plist, no restart map — and no stderr, ever.
EOF

# ---- B. read-only census ----------------------------------------------------
say "B. What this machine holds (read-only — no sudo needed)"
printf '  pmset -g custom:\n'
pmset -g custom 2>/dev/null | sed 's/^/    /'
printf '\n  %s (world-readable, so this census needs no privileges):\n' "$plist"
plutil -p "$plist" 2>/dev/null | sed 's/^/    /'

printf '\n  keys that differ between the two power sources on this machine:\n'
/usr/bin/python3 - "$plist" <<'PY' | sed 's/^/    /'
import plistlib, sys
p = plistlib.load(open(sys.argv[1], "rb"))
ac, bat = p.get("AC Power", {}), p.get("Battery Power", {})
diff = sorted(set(ac) | set(bat))
rows = [(k, ac.get(k, "—"), bat.get(k, "—")) for k in diff if ac.get(k) != bat.get(k)]
if not rows:
    print("(none — this machine happens to hold identical settings on both)")
for k, a, b in rows:
    print(f"{k:<28} AC={a!s:<8} battery={b!s}")
PY
cat <<'EOF'

  Whatever the rows say, the SHAPE is the finding: macOS models power settings
  per source, and the typed nix-darwin surface has no way to name a source.
EOF

# ---- C. the write test ------------------------------------------------------
# Read one timer out of the root-owned plist. Prints an empty string, not a
# sentinel, when the key is absent — the restore path has to be able to tell
# "was 10" from "wasn't there", and a "?" that silently means "skip the
# restore" is how a probe leaves a machine changed.
timer() {  # $1 = "AC Power" | "Battery Power", $2 = timer key
  /usr/bin/python3 -c "import plistlib,sys
p=plistlib.load(open(sys.argv[1],'rb')).get(sys.argv[2],{})
print(p.get(sys.argv[3],''))" "$plist" "$1" "$2"
}

write_test() {
if [ "${POWER_SWEEP_WRITE:-}" != 1 ]; then
  cat <<EOF
  ⏭  SKIPPED — this section writes a real power setting as root, so it is opt-in
     rather than gated on whether sudo happens to be cached (an agent inheriting
     a warm sudo timestamp must not silently run it):

       POWER_SWEEP_WRITE=1 $0

     Run it from a terminal, at a keyboard — root here means a Touch ID prompt.
     It will: read the current computer- and display-sleep timers, set computer
     sleep to 17 via systemsetup (capturing the stderr nix-darwin discards),
     re-read $plist to see whether ONE
     source moved or both, and put both timers back on both sources.
EOF
  return 0
fi
sudo -n true 2>/dev/null || printf '  (needs root — you will be asked to authenticate)\n'

before_ac=$(timer "AC Power" "System Sleep Timer")
before_bat=$(timer "Battery Power" "System Sleep Timer")
# systemsetup clamps display sleep to <= computer sleep, so a machine whose
# display sleep is above 17 gets a SECOND setting moved by this one write.
disp_ac=$(timer "AC Power" "Display Sleep Timer")
disp_bat=$(timer "Battery Power" "Display Sleep Timer")
printf '  before: computer sleep AC=%s battery=%s · display sleep AC=%s battery=%s\n' \
  "${before_ac:-<unset>}" "${before_bat:-<unset>}" "${disp_ac:-<unset>}" "${disp_bat:-<unset>}"

put_back() {  # $1 = -c|-b, $2 = sleep|displaysleep, $3 = value, $4 = label
  if [ -z "$3" ]; then
    printf '  ⚠️  %s had no stored value — NOT restored. Check `pmset -g custom`\n' "$4"
    printf '      and set it by hand; this probe will not guess.\n'
    return
  fi
  sudo pmset "$1" "$2" "$3" 2>/dev/null \
    || printf '  ⚠️  could not restore %s to %s — do it by hand\n' "$4" "$3"
}
restore_power() {
  printf '\n→ restoring…\n'
  put_back -c sleep "$before_ac" "AC computer sleep"
  put_back -b sleep "$before_bat" "battery computer sleep"
  put_back -c displaysleep "$disp_ac" "AC display sleep"
  put_back -b displaysleep "$disp_bat" "battery display sleep"
  sleep 1
  printf '  now: computer sleep AC=%s battery=%s · display sleep AC=%s battery=%s\n' \
    "$(timer 'AC Power' 'System Sleep Timer')" "$(timer 'Battery Power' 'System Sleep Timer')" \
    "$(timer 'AC Power' 'Display Sleep Timer')" "$(timer 'Battery Power' 'Display Sleep Timer')"
}
trap restore_power EXIT INT TERM

printf '  running: sudo systemsetup -setcomputersleep 17   (stderr NOT discarded)\n'
out=$(sudo systemsetup -setcomputersleep 17 2>&1); rc=$?
printf '    exit=%s output: %s\n' "$rc" "${out:-<silent>}"
sleep 1
after_ac=$(timer "AC Power" "System Sleep Timer")
after_bat=$(timer "Battery Power" "System Sleep Timer")
printf '    after:  AC=%s battery=%s · display sleep AC=%s battery=%s\n' \
  "$after_ac" "$after_bat" \
  "$(timer 'AC Power' 'Display Sleep Timer')" "$(timer 'Battery Power' 'Display Sleep Timer')"
if [ "$after_ac" = "$after_bat" ]; then
  printf '    → source-blind: one option, both sources. Confirms the limit above.\n'
else
  printf '    → only one source moved. Worse: the option silently means "the\n'
  printf '      source you were plugged into when the rebuild ran".\n'
fi
}

say "C. Does the systemsetup path work on macOS 26 — and which source moves?"
write_test

# ---- D. what is not reachable at all ----------------------------------------
say "D. Not typed by nix-darwin, and not reachable through system.defaults"
cat <<'EOF'
  Low Power Mode      sudo pmset -a lowpowermode 1     (also -b / -c)
  battery vs AC       sudo pmset -b sleep 5 -c sleep 0
  lid / clamshell     sudo pmset -a lidwake 1 / disablesleep 1
  hibernate mode      sudo pmset -a hibernatemode 3
  wake for network    sudo pmset -a womp 1

  All of these are root-only CLI writes into a root-owned plist. A curated
  `nebelhaus.power.*` would therefore be a `pmset` activation step of the rice's
  own — not a `system.defaults` group — which puts it in the same family as
  `security.firewall` (socketfilterfw) rather than the same family as
  hotCorners/screenshots/menuBar.
EOF

say "Done. Record results in macos-settings-matrix.md."
