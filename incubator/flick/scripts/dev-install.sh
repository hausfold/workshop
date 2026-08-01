#!/usr/bin/env bash
#
# dev-install.sh — build Flick from this checkout, sign it with a *stable*
# identity, and leave exactly one copy where macOS will find it.
#
# WHY THIS EXISTS (the Full Disk Access bug it fixes permanently)
#
# `xcodebuild … CODE_SIGNING_ALLOWED=NO` — the command in BOOTSTRAP.md, fine
# for tests — produces an **ad-hoc signed** bundle. macOS stores a TCC grant
# (Full Disk Access) against the app's *designated requirement*, and for an
# ad-hoc bundle that requirement pins the binary's **cdhash**, which changes on
# every single build. The moment a differently-hashed `com.nebelhaus.flick`
# launches, macOS can no longer match the app it granted, so it revokes: the
# switch in System Settings turns itself back off while you watch.
#
# Signing with the Developer ID makes that requirement name the **team**
# (88M28542LQ) instead of a hash — so the grant survives every rebuild, and
# you grant Full Disk Access once, ever.
#
# The other half of the same bug: several stale `Flick.app` copies
# (DerivedData, `build/`, old installs) all claim `com.nebelhaus.flick`, and
# Apple's own "Quit & Reopen" button relaunches **by bundle id** — so it can
# relaunch a copy the grant was never made against. This script unregisters
# the strays and leaves one canonical install at ~/Applications/Flick.app.
#
# Usage:
#   scripts/dev-install.sh                  build, sign, install, relaunch
#   scripts/dev-install.sh --reset-permissions
#                                           …and wipe flick's existing TCC
#                                           rows first (needed once, when
#                                           switching from an ad-hoc build:
#                                           the stale row can't be matched
#                                           against the new signature)
#
# Override the identity with FLICK_SIGN_IDENTITY= if you sign under another
# team.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUNDLE_ID="com.nebelhaus.flick"
INSTALL_PATH="$HOME/Applications/Flick.app"
DERIVED="$REPO_ROOT/build/dev-install"
LSREGISTER="/System/Library/Frameworks/CoreServices.framework/Frameworks/LaunchServices.framework/Support/lsregister"

RESET_PERMISSIONS=0
[[ "${1:-}" == "--reset-permissions" ]] && RESET_PERMISSIONS=1

say() { printf '\033[1;34m==>\033[0m %s\n' "$*"; }
die() { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# --- 1. resolve a stable signing identity ------------------------------------

IDENTITY="${FLICK_SIGN_IDENTITY:-}"
if [[ -z "$IDENTITY" ]]; then
  IDENTITY="$(security find-identity -v -p codesigning \
    | sed -n 's/.*"\(Developer ID Application: .*\)"/\1/p' | head -1)"
fi
[[ -n "$IDENTITY" ]] || die "no 'Developer ID Application' identity in the keychain.
An ad-hoc build cannot hold a Full Disk Access grant across rebuilds — that is
the bug this script exists to fix. Install the Developer ID cert, or set
FLICK_SIGN_IDENTITY to another identity with a Team ID."

TEAM_ID="$(printf '%s' "$IDENTITY" | sed -n 's/.*(\([A-Z0-9]*\))$/\1/p')"
say "signing as: $IDENTITY"

# --- 2. build ----------------------------------------------------------------

say "building Release…"
xcodebuild \
  -project "$REPO_ROOT/Flick.xcodeproj" \
  -scheme Flick \
  -configuration Release \
  -destination 'platform=macOS' \
  -derivedDataPath "$DERIVED" \
  CODE_SIGN_STYLE=Manual \
  CODE_SIGN_IDENTITY="$IDENTITY" \
  DEVELOPMENT_TEAM="$TEAM_ID" \
  OTHER_CODE_SIGN_FLAGS='--timestamp' \
  build | tail -5

BUILT_APP="$DERIVED/Build/Products/Release/Flick.app"
[[ -d "$BUILT_APP" ]] || die "build produced no app at $BUILT_APP"

# --- 3. evict every other copy that claims this bundle id --------------------
#
# Not cosmetic: whichever copy LaunchServices resolves is the one Apple's
# "Quit & Reopen" relaunches and the one System Settings' + button adds.

say "unregistering stale $BUNDLE_ID bundles…"
"$LSREGISTER" -dump 2>/dev/null \
  | sed -n 's/^[[:space:]]*path:[[:space:]]*\(.*Flick\.app\)[[:space:]]*(.*/\1/p' \
  | sort -u \
  | while read -r stale; do
      [[ "$stale" == "$INSTALL_PATH" ]] && continue
      printf '    - %s\n' "$stale"
      "$LSREGISTER" -u "$stale" 2>/dev/null || true
    done

# --- 4. install the one canonical copy ---------------------------------------

say "installing → $INSTALL_PATH"
/usr/bin/pkill -x Flick 2>/dev/null || true
rm -rf "$INSTALL_PATH"
mkdir -p "$(dirname "$INSTALL_PATH")"
/usr/bin/ditto "$BUILT_APP" "$INSTALL_PATH"

# Re-sign in place: `ditto` preserves the signature, but signing the installed
# path is what makes `codesign --verify` and TCC agree on this exact bundle.
codesign --force --options runtime --timestamp \
  --entitlements "$REPO_ROOT/Flick/Config/Flick.entitlements" \
  --sign "$IDENTITY" "$INSTALL_PATH"
codesign --verify --strict --verbose=1 "$INSTALL_PATH"

ACTUAL_TEAM="$(codesign -dvvv "$INSTALL_PATH" 2>&1 | sed -n 's/^TeamIdentifier=//p')"
[[ "$ACTUAL_TEAM" != "not set" && -n "$ACTUAL_TEAM" ]] \
  || die "installed bundle still has no Team ID — the grant would not survive a rebuild"
say "team identifier: $ACTUAL_TEAM (grants now survive rebuilds)"

"$LSREGISTER" -f "$INSTALL_PATH"

# --- 5. optional: clear the un-matchable TCC rows ----------------------------

if (( RESET_PERMISSIONS )); then
  say "resetting flick's TCC rows (you will re-grant Full Disk Access once)"
  sudo tccutil reset SystemPolicyAllFiles "$BUNDLE_ID" || true
  tccutil reset All "$BUNDLE_ID" 2>/dev/null || true
fi

# --- 6. launch ---------------------------------------------------------------

say "launching"
open "$INSTALL_PATH"

cat <<EOF

Installed: $INSTALL_PATH  (Team $ACTUAL_TEAM)

Full Disk Access, once:
  Flick menu bar → Settings… → Unlock System Mirror…
  The assistant walks you through the pane, then closes itself and reopens
  Settings the moment the grant lands. No relaunch — ignore Apple's own
  "Quit & Reopen" prompt (its "Later" button grants access just the same).

Every later run of this script keeps that grant.
EOF
