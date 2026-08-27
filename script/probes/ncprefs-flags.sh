#!/usr/bin/env bash
# ncprefs-flags.sh — read-only probe for macOS per-app notification settings.
#
# WHERE THE SETTINGS ACTUALLY LIVE (macOS 26.6, verified 2026-08-01)
#
#   ~/Library/Group Containers/group.com.apple.usernoted/Library/Preferences/
#       group.com.apple.usernoted.plist
#
# NOT `com.apple.ncprefs`. That domain still exists and still carries an `apps`
# array with plausible-looking `flags`, but on 26.6 it is a STALE MIRROR: this
# machine's copy sat unchanged for two weeks while the real settings moved
# underneath it. Anything reading ncprefs reports confidently wrong state. It
# was the documented location on older releases, which is exactly why it's a
# trap — every reversal you'll find online points at it.
#
# Verified empirically by holding one app's switches in a known state and
# diffing, rather than by trusting the flag tables in circulation:
#
#   bit 25 (0x2000000)  Allow notifications — the master switch. READ IT FIRST:
#                       macOS freezes the bits below at their last values when
#                       it goes off, so an audit that skips it reports every
#                       app you silenced years ago as noisy.
#   bit 2 (0x4)  Play sound for notification
#   bit 3 (0x8)  Desktop, Temporary style — an on-screen banner
#   bit 4 (0x10) Desktop, Persistent style — an on-screen alert
#
# Bits 3 and 4 are ONE control in two styles, not a control and a detail:
# no app on a 108-app store has both, and unticking Desktop for an app set to
# Persistent clears bit 4 (watched live, 2026-08-04 — Reminders went
# 9437708310 → 9437708358). An earlier version of this header called bit 3
# "THE bit", which reports every Persistent app as quiet while macOS is still
# drawing alerts for it. Desktop is on when EITHER bit is set.
#
# Bits 3, 4 and 2 all cleared = that app is silent and drawing nothing, while
# notifications still flow to Notification Center for trill to mirror.
#
# TCC: the group container is protected, so reading this needs Full Disk
# Access. A terminal that already holds FDA will read it without complaint and
# tell you nothing about whether an un-granted process could — check with
# `--tcc` before concluding anything about permissions.
#
# NEVER writes. Modes:
#
#   ./ncprefs-flags.sh              # every app, decoded, noisy ones flagged
#   ./ncprefs-flags.sh <match>      # just the apps matching a bundle-id substring
#   ./ncprefs-flags.sh --tcc        # does THIS process actually have FDA?
#   ./ncprefs-flags.sh --legacy     # ncprefs vs usernoted, to show the drift
set -euo pipefail

USERNOTED="$HOME/Library/Group Containers/group.com.apple.usernoted/Library/Preferences/group.com.apple.usernoted.plist"
USERNOTED_DB="$HOME/Library/Group Containers/group.com.apple.usernoted/db2/db"

# ------------------------------------------------------------------ --tcc

if [[ "${1:-}" == "--tcc" ]]; then
	echo "Full Disk Access check for this process:"
	if head -c 16 "$USERNOTED_DB" >/dev/null 2>&1; then
		echo "  GRANTED — usernoted db2/db is readable."
		echo "  Careful: this says the *terminal* is granted, not trill."
	else
		echo "  DENIED — usernoted db2/db is unreadable."
		echo "  A doctor check running like this must report \"unknown\","
		echo "  never \"quiet\"."
	fi
	exit 0
fi

if [[ ! -r "$USERNOTED" ]]; then
	echo "cannot read $USERNOTED" >&2
	echo "almost certainly Full Disk Access — run: $0 --tcc" >&2
	exit 1
fi

# --------------------------------------------------------------- --legacy

if [[ "${1:-}" == "--legacy" ]]; then
	python3 - "$USERNOTED" <<-'PY'
		import plistlib, subprocess, sys

		live = {a.get("bundle-id"): a.get("flags")
		        for a in plistlib.load(open(sys.argv[1], "rb")).get("apps", [])}
		old = {}
		try:
		    x = subprocess.run(["defaults", "export", "com.apple.ncprefs", "-"],
		                       capture_output=True).stdout
		    old = {a.get("bundle-id"): a.get("flags")
		           for a in plistlib.loads(x).get("apps", [])}
		except Exception as e:
		    print("could not read com.apple.ncprefs:", e)

		drift = [(b, old[b], live[b]) for b in sorted(set(old) & set(live))
		         if old[b] != live[b]]
		print(f"ncprefs: {len(old)} apps · usernoted: {len(live)} apps · "
		      f"{len(drift)} disagree\n")
		for b, o, n in drift:
		    print(f"  {b}\n    ncprefs   {o}\n    usernoted {n}")
		if not drift:
		    print("  (no drift right now — that does NOT make ncprefs safe;")
		    print("   it drifts silently the moment a switch is touched)")
	PY
	exit 0
fi

# ----------------------------------------------------------------- report

python3 - "$USERNOTED" "${1:-}" <<-'PY'
	import plistlib, sys

	SOUND, DESKTOP, ALLOW = 1 << 2, (1 << 3) | (1 << 4), 1 << 25
	path, match = sys.argv[1], (sys.argv[2] if len(sys.argv) > 2 else "")

	apps = [a for a in plistlib.load(open(path, "rb")).get("apps", [])
	        if a.get("flags") is not None and a.get("bundle-id")]
	if match:
	    apps = [a for a in apps if match.lower() in a["bundle-id"].lower()]

	rows, noisy = [], 0
	for a in sorted(apps, key=lambda a: a["bundle-id"]):
	    f = a["flags"]
	    # "Allow notifications" first, always. macOS freezes the style and
	    # sound bits at their last values when that master switch goes off, so
	    # reading them without it reports every app the user silenced years
	    # ago — the exact bug trill shipped once, and this probe is what an
	    # agent uses to corroborate trill, so the two have to agree.
	    allowed = bool(f & ALLOW)
	    d, s = allowed and bool(f & DESKTOP), allowed and bool(f & SOUND)
	    if d or s:
	        noisy += 1
	    rows.append((a["bundle-id"], f, "on" if d else "off",
	                 "on" if s else "off",
	                 "NOISY" if d else ("sound" if s else ("quiet" if allowed else "off"))))

	print(f"{len(rows)} apps · {noisy} still drawing a banner and/or sounding\n")
	print(f"{'BUNDLE ID':<46}{'FLAGS':>12}  {'DESKTOP':<8}{'SOUND':<7}VERDICT")
	for bid, f, d, s, v in rows:
	    print(f"{bid:<46}{f:>12}  {d:<8}{s:<7}{v}")
	print("\nallow = bit 25 (0x2000000, read FIRST) · Desktop = bit 3 (0x8, "
	      "temporary) OR bit 4 (0x10, persistent) · sound = bit 2 (0x4)")
	print("quiet = allowed, both drawing bits clear: silent and drawing "
	      "nothing, still reaching Notification Center")
	print("off   = allow bit clear: macOS isn't notifying for it at all")
PY
