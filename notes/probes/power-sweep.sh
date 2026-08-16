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
# TWO oracles, because the first version of this section used only the second
# and drew a conclusion from it. `pmset -g custom` is powerd's LIVE state;
# /Library/Preferences/com.apple.PowerManagement.plist is a file powerd writes
# on its own cadence. They can disagree, and a probe that reads only the file
# will report a landed write as a failure — which is exactly what happened
# here: the sleep rows were judged from the file and "failed", while the Low
# Power Mode row was judged from pmset and passed, in the same run. Different
# oracles, opposite verdicts, one confound.
#
# `timer` is the live reading and decides every verdict; `timer_file` is the
# cross-check, and a disagreement between them is itself a finding.
timer() {  # $1 = "AC Power" | "Battery Power", $2 = pmset key (sleep|displaysleep)
  pmset -g custom | awk -v want="$1" -v key="$2" '
    /^[A-Za-z].*Power:/ { section = substr($0, 1, index($0, ":") - 1) }
    $1 == key && section == want { print $2; exit }'
}
timer_file() {  # $1 = "AC Power" | "Battery Power", $2 = plist timer key
  /usr/bin/python3 -c "import plistlib,sys
p=plistlib.load(open(sys.argv[1],'rb')).get(sys.argv[2],{})
print(p.get(sys.argv[3],''))" "$plist" "$1" "$2"
}
both() {  # $1 source, $2 pmset key, $3 plist key — "live/file", flagged if split
  local live file
  live=$(timer "$1" "$2"); file=$(timer_file "$1" "$3")
  if [ "$live" = "$file" ]; then printf '%s' "$live"
  else printf '%s(file:%s)' "$live" "${file:-<absent>}"; fi
}

write_test() {
if [ "${POWER_SWEEP_WRITE:-}" != 1 ]; then
  cat <<EOF
  ⏭  SKIPPED — this section writes a real power setting as root, so it is opt-in
     rather than gated on whether sudo happens to be cached (an agent inheriting
     a warm sudo timestamp must not silently run it):

       POWER_SWEEP_WRITE=1 $0

     Run it from a terminal, at a keyboard — root here means a Touch ID prompt.
     It crosses two variables — which SETTING (computer sleep, display sleep,
     Low Power Mode) against which CALLER (nix-darwin's systemsetup vs pmset) —
     capturing the stderr nix-darwin discards and re-reading
     $plist after each, then puts
     every timer back on both sources. One run separates "systemsetup is
     broken" from "the setting is immutable on this hardware".
EOF
  return 0
fi
sudo -n true 2>/dev/null || printf '  (needs root — you will be asked to authenticate)\n'

lowpower() { pmset -g custom | awk '/lowpowermode/{print $2; exit}'; }
before_ac=$(timer 'AC Power' sleep)
before_bat=$(timer 'Battery Power' sleep)
lpm_before=$(lowpower)
# systemsetup clamps display sleep to <= computer sleep, so a machine whose
# display sleep is above 17 gets a SECOND setting moved by this one write.
disp_ac=$(timer 'AC Power' displaysleep)
disp_bat=$(timer 'Battery Power' displaysleep)
printf '  before: computer AC=%s bat=%s · display AC=%s bat=%s · lowpowermode %s\n' \
  "${before_ac:-<unset>}" "${before_bat:-<unset>}" "${disp_ac:-<unset>}" \
  "${disp_bat:-<unset>}" "${lpm_before:-<unset>}"

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
  [ -n "$lpm_before" ] && sudo pmset -a lowpowermode "$lpm_before" 2>/dev/null
  sleep 1
  state
}
trap restore_power EXIT INT TERM

# Two variables, crossed: WHICH SETTING (computer sleep vs display sleep vs Low
# Power Mode) and WHICH CALLER (nix-darwin's systemsetup vs pmset). One run of
# the cross tells you what a single row cannot:
#
#   computer sleep dead both ways        → the SETTING is immutable here
#                                          (Apple silicon pins it), and the
#                                          systemsetup row says nothing about
#                                          systemsetup
#   display sleep moves under pmset only → systemsetup IS broken, and
#                                          nix-darwin's six options are a no-op
#                                          for every macOS 26 user → upstream
#   both move                            → systemsetup is fine; only the
#                                          source-blindness limits it
#
# The first draft of this probe ran only the first row and drew a conclusion
# about `systemsetup` from it, which was one crossed variable short of evidence.
row() {  # $1 label, $2… command
  local label="$1"; shift
  local out rc
  out=$("$@" 2>&1); rc=$?
  printf '  %-46s exit=%s %s\n' "$label" "$rc" \
    "$([ -n "$out" ] && printf 'output: %s' "$(printf '%s' "$out" | tail -1)")"
  sleep 1
}
state() {
  printf '    now: computer AC=%s bat=%s · display AC=%s bat=%s · lowpowermode %s\n' \
    "$(both 'AC Power' sleep 'System Sleep Timer')" "$(both 'Battery Power' sleep 'System Sleep Timer')" \
    "$(both 'AC Power' displaysleep 'Display Sleep Timer')" "$(both 'Battery Power' displaysleep 'Display Sleep Timer')" \
    "$(lowpower)"
}

# WHICH SOURCES did a write reach? The interesting answer is neither "both"
# nor "none" but "one" — a source-blind CLI that quietly writes a single
# profile makes the setting depend on how the laptop was plugged in when the
# rebuild ran, which is a determinism bug a rice cannot see.
where_landed() {  # $1 asked-for value, $2 AC now, $3 battery now
  if [ "$2" = "$1" ] && [ "$3" = "$1" ]; then printf '✓ landed on BOTH sources'
  elif [ "$2" = "$1" ]; then printf '⚠️  landed on AC ONLY — battery untouched'
  elif [ "$3" = "$1" ]; then printf '⚠️  landed on BATTERY ONLY — AC untouched'
  else printf '✗ did not land'
  fi
}

printf '\n  running on: %s\n' "$(pmset -g batt | head -1 | sed "s/Now drawing from //")"
printf '\n  1/4 nix-darwin path, computer sleep: systemsetup -setcomputersleep 17\n'
printf '      (stderr NOT discarded — nix-darwin sends all of this to /dev/null)\n'
row "sudo systemsetup -setcomputersleep 17" sudo systemsetup -setcomputersleep 17
ss_ac=$(timer 'AC Power' sleep); ss_bat=$(timer 'Battery Power' sleep)
printf '      computer sleep → AC=%s battery=%s %s\n' "$ss_ac" "$ss_bat" \
  "$(where_landed 17 "$ss_ac" "$ss_bat")"

printf '\n  2/4 control, same setting via pmset (per source)\n'
row "sudo pmset -c sleep 18 -b sleep 19" sudo pmset -c sleep 18 -b sleep 19
pm_ac=$(timer 'AC Power' sleep); pm_bat=$(timer 'Battery Power' sleep)
printf '      computer sleep → AC=%s battery=%s %s\n' "$pm_ac" "$pm_bat" \
  "$([ "$pm_ac" = 18 ] && [ "$pm_bat" = 19 ] && printf '✓ landed, per source' || printf '✗ did not land')"

printf '\n  3/4 a DIFFERENT setting, both callers: display sleep\n'
row "sudo systemsetup -setdisplaysleep 21" sudo systemsetup -setdisplaysleep 21
ds_ss=$(timer 'AC Power' displaysleep); ds_ss_bat=$(timer 'Battery Power' displaysleep)
printf '      display sleep → AC=%s battery=%s %s\n' "$ds_ss" "$ds_ss_bat" \
  "$(where_landed 21 "$ds_ss" "$ds_ss_bat")"
row "sudo pmset -c displaysleep 22 -b displaysleep 23" sudo pmset -c displaysleep 22 -b displaysleep 23
ds_ac=$(timer 'AC Power' displaysleep); ds_bat=$(timer 'Battery Power' displaysleep)
printf '      display sleep → AC=%s battery=%s %s\n' "$ds_ac" "$ds_bat" \
  "$([ "$ds_ac" = 22 ] && [ "$ds_bat" = 23 ] && printf '✓ pmset landed, per source' || printf '✗ pmset did not land')"

printf '\n  4/4 the flagship power opinion nothing types: Low Power Mode\n'
row "sudo pmset -a lowpowermode 1" sudo pmset -a lowpowermode 1
lpm=$(pmset -g custom | awk '/lowpowermode/{print $2; exit}')
printf '      lowpowermode → %s %s\n' "$lpm" \
  "$([ "$lpm" = 1 ] && printf '✓ landed' || printf '✗ did not land')"

printf '\n  Verdict:\n'
pmset_ok=no
[ "$pm_ac" = 18 ] && [ "$pm_bat" = 19 ] && [ "$ds_ac" = 22 ] && [ "$ds_bat" = 23 ] && pmset_ok=yes
ss_sources=both
[ "$ss_ac" = 17 ] && [ "$ss_bat" != 17 ] && ss_sources=ac-only
[ "$ss_ac" != 17 ] && [ "$ss_bat" = 17 ] && ss_sources=battery-only
[ "$ss_ac" != 17 ] && [ "$ss_bat" != 17 ] && ss_sources=none

case "$pmset_ok:$ss_sources" in
  yes:ac-only|yes:battery-only)
    printf '    systemsetup WORKS but writes ONE power profile, while pmset writes the\n'
    printf '    one you name. So nix-darwin`s power.sleep.* silently means "whichever\n'
    printf '    source systemsetup felt like" — a setting whose result depends on\n'
    printf '    something the config cannot see. Build on pmset; this is worth filing.\n' ;;
  yes:both)
    printf '    systemsetup works and is simply source-blind: one call, both profiles.\n'
    printf '    Usable, but it cannot express battery-vs-AC, which is the only opinion\n'
    printf '    a laptop rice has. Build on pmset for that; the typed options are fine\n'
    printf '    for a symmetric value.\n' ;;
  yes:none)
    printf '    pmset lands and systemsetup does not: systemsetup is BROKEN on 26 and\n'
    printf '    nix-darwin ships six typed options that silently do nothing.\n'
    printf '    → worth filing upstream against LnL7/nix-darwin.\n' ;;
  *)
    printf '    pmset itself did not land as asked, so nothing above is evidence about\n'
    printf '    systemsetup. Check for a configuration profile pinning power settings,\n'
    printf '    and re-run before concluding anything.\n' ;;
esac
state
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
  `haus.power.*` would therefore be a `pmset` activation step of the rice's
  own — not a `system.defaults` group — which puts it in the same family as
  `security.firewall` (socketfilterfw) rather than the same family as
  hotCorners/screenshots/menuBar.
EOF

say "Done. Record results in macos-settings-matrix.md."
