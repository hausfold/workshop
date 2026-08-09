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
# test and needs root, which on this machine means a Touch ID prompt — so an
# agent cannot run it and the script says so rather than pretending.

set -uo pipefail

say()  { printf '\n\033[1m%s\033[0m\n' "$*"; }
plist=/Library/Preferences/com.apple.PowerManagement.plist

# ---- A. what nix-darwin actually emits --------------------------------------
say "A. The typed surface, and how it is implemented"
cat <<'EOF'
  modules/power/sleep.nix + modules/power/default.nix, in
  system.activationScripts.power:

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
write_test() {
if ! sudo -n true 2>/dev/null; then
  if [ ! -t 0 ]; then
    cat <<EOF
  ⏭  SKIPPED — this needs root, and root here means an interactive Touch ID
     prompt. That makes it the one section an agent cannot run, so it is left
     for a person at the keyboard rather than guessed at:

       $0

     It will: read the current computer-sleep timer, set it to 17 via
     systemsetup (capturing the stderr nix-darwin discards), re-read
     $plist to see whether ONE source moved
     or both, and put the original value back.
EOF
    return 0
  fi
  printf '  (needs root — you will be asked to authenticate)\n'
fi

before_ac=$(/usr/bin/python3 -c "import plistlib,sys;print(plistlib.load(open('$plist','rb')).get('AC Power',{}).get('System Sleep Timer','?'))")
before_bat=$(/usr/bin/python3 -c "import plistlib,sys;print(plistlib.load(open('$plist','rb')).get('Battery Power',{}).get('System Sleep Timer','?'))")
printf '  before: AC=%s battery=%s\n' "$before_ac" "$before_bat"

restore_power() {
  printf '\n→ restoring computer sleep to AC=%s battery=%s…\n' "$before_ac" "$before_bat"
  [ "$before_ac" != "?" ] && sudo pmset -c sleep "$before_ac" 2>/dev/null
  [ "$before_bat" != "?" ] && sudo pmset -b sleep "$before_bat" 2>/dev/null
  sleep 1
  printf '  now: %s\n' "$(pmset -g custom | tr '\n' ' ' | tr -s ' ')"
}
trap restore_power EXIT INT TERM

printf '  running: sudo systemsetup -setcomputersleep 17   (stderr NOT discarded)\n'
out=$(sudo systemsetup -setcomputersleep 17 2>&1); rc=$?
printf '    exit=%s output: %s\n' "$rc" "${out:-<silent>}"
sleep 1
after_ac=$(/usr/bin/python3 -c "import plistlib,sys;print(plistlib.load(open('$plist','rb')).get('AC Power',{}).get('System Sleep Timer','?'))")
after_bat=$(/usr/bin/python3 -c "import plistlib,sys;print(plistlib.load(open('$plist','rb')).get('Battery Power',{}).get('System Sleep Timer','?'))")
printf '    after:  AC=%s battery=%s\n' "$after_ac" "$after_bat"
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
