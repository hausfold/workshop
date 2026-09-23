#!/usr/bin/env bash
# The two "writes and lies" rows of haus's docs/macos-settings.md that had no
# probe of their own: `com.apple.Accessibility` and
# `NSGlobalDomain AppleInterfaceStyle`. Both write cleanly and both move nothing,
# so the only evidence is an effective-state oracle read in a FRESH process.
#
#   A. com.apple.Accessibility    write the modern-looking keys, read NSWorkspace
#   B. AppleInterfaceStyle        write Dark (+ activateSettings -u), read AppKit's
#                                 effective appearance and listen for
#                                 AppleInterfaceThemeChangedNotification
#   C. the control for B          flip dark mode through System Events, which
#                                 SHOULD move both. Without it, a "nothing moved"
#                                 in B could be a broken oracle.
#
# RUN IT IN A VM. Section C repaints the whole desktop, and if macOS ever makes
# B live it repaints there too; that is the question being asked. `haus skill
# vm` has the loop. C also needs an Automation grant for System Events; a
# cirruslabs guest over ssh has one.
#
# Safe: A deletes exactly the keys it wrote. B and C put the appearance back to
# what the oracle read before they started, through System Events, and restore
# AppleInterfaceStyle's plist value. No sudo, no rebuild.
#
# Run history (dates belong here, not in the doc):
#   2026-09-23  26.6.2 (25G83) tart control and 27.0 (26A428) tart guest,
#               identical: A inert, B inert with no notification, C flips
#               appearance and posts the notification.

set -uo pipefail

here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
tmp="$(mktemp -d)"
say() { printf '\n\033[1m%s\033[0m\n' "$*"; }

cat >"$tmp/appearance.swift" <<'EOF'
import AppKit
let app = NSApplication.shared
Thread.sleep(forTimeInterval: 0.5)
let dark = app.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
print("appearance=\(dark ? "dark" : "light") key=\(UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "<absent>")")
EOF
cat >"$tmp/notewatch.swift" <<'EOF'
import Foundation
let c = DistributedNotificationCenter.default()
var seen = false
c.addObserver(forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"), object: nil, queue: nil) { _ in
  seen = true; print("    POSTED AppleInterfaceThemeChangedNotification")
}
RunLoop.main.run(until: Date().addingTimeInterval(Double(CommandLine.arguments[1]) ?? 6))
if !seen { print("    no AppleInterfaceThemeChangedNotification") }
EOF

a11y() { swift "$here/accessibility-effective.swift" 2>/dev/null; }
look() { swift "$tmp/appearance.swift" 2>/dev/null; }
se_dark() { osascript -e "tell application \"System Events\" to tell appearance preferences to set dark mode to $1" 2>&1; }

ax_keys=(ReduceMotionEnabled ReduceTransparencyEnabled DifferentiateWithoutColor EnhancedBackgroundContrastEnabled)
# Per-key XML fragments, so a restore keeps the type (bash 3.2: no assoc arrays).
for k in "${ax_keys[@]}"; do
  /usr/libexec/PlistBuddy -x -c "Print :$k" ~/Library/Preferences/com.apple.Accessibility.plist >"$tmp/ax.$k" 2>/dev/null || rm -f "$tmp/ax.$k"
done
style_before="$(defaults read -g AppleInterfaceStyle 2>/dev/null || true)"
start="$(look)"
start_dark=false; case "$start" in appearance=dark*) start_dark=true ;; esac

cleanup() {
  printf '\n→ restoring…\n'
  for k in "${ax_keys[@]}"; do
    if [ -s "$tmp/ax.$k" ]; then defaults write com.apple.Accessibility "$k" "$(cat "$tmp/ax.$k")"
    else defaults delete com.apple.Accessibility "$k" >/dev/null 2>&1; fi
  done
  se_dark "$start_dark" >/dev/null
  if [ -n "$style_before" ]; then defaults write -g AppleInterfaceStyle "$style_before"
  else defaults delete -g AppleInterfaceStyle >/dev/null 2>&1; fi
  printf '  now: %s (started %s)\n' "$(look)" "$start"
  rm -rf "$tmp"
}
trap cleanup EXIT INT TERM

say "A. com.apple.Accessibility — expect: plist moves, NSWorkspace does not"
printf '  before: %s\n' "$(a11y)"
for k in "${ax_keys[@]}"; do defaults write com.apple.Accessibility "$k" -bool true; done
notifyutil -p com.apple.accessibility.cache.ax 2>/dev/null
sleep 2
printf '  wrote %s = 1, poked com.apple.accessibility.cache.ax\n' "${ax_keys[*]}"
printf '  after:  %s\n' "$(a11y)"

say "B. AppleInterfaceStyle via defaults — expect: key moves, appearance does not"
printf '  before: %s\n' "$start"
swift "$tmp/notewatch.swift" 8 >"$tmp/nw.out" 2>&1 &
sleep 2
if $start_dark; then defaults delete -g AppleInterfaceStyle 2>/dev/null; w="delete"; else defaults write -g AppleInterfaceStyle Dark; w="write Dark"; fi
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u >/dev/null 2>&1
sleep 2
printf '  %s + activateSettings -u → %s\n' "$w" "$(look)"
wait
cat "$tmp/nw.out"

say "C. Control: System Events — expect: appearance moves, notification posted"
swift "$tmp/notewatch.swift" 8 >"$tmp/nw.out" 2>&1 &
sleep 2
if $start_dark; then target=false; else target=true; fi
out="$(se_dark "$target")" || printf '  osascript refused: %s (no Automation grant? then C proves nothing)\n' "$out"
sleep 1
printf '  dark mode → %s: %s\n' "$target" "$(look)"
wait
cat "$tmp/nw.out"

say "Read it: A and B moving nothing only counts if C moved. Record in haus's docs/macos-settings.md."
