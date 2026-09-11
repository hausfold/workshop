#!/usr/bin/env bash
# shoot-hero.sh — stage this Mac and take the family's one desktop hero: the
# frame `assets/SHOTLIST.md` row 2 owns, which ships as `haus/assets/hero.png`.
#
#   ./script/shoot-hero.sh            stage, shoot, restore
#   ./script/shoot-hero.sh --restore  just put the machine back
#
# WHY this is a script and not a checklist: the frame has to clear a
# disqualifier list, and every item on that list is a different mechanism — a
# haus option, a lazygit panel mode, a page scroll, the system clock. The
# frame this replaced carried four of them at once — a battery percentage, a
# 4:22 clock, an email-bearing panel and a half-covered contact line — because
# a disqualifier is only findable by reading the capture back against the list
# afterwards. So the list runs as stages, and the last stage hands the file to
# a reader instead of declaring victory.
#
# It needs the screen and it needs a human. Nothing here runs unattended.
set -euo pipefail

TOTAL=7; STEP=0
b=$'\033[1m'; d=$'\033[2m'; g=$'\033[32m'; y=$'\033[33m'; r=$'\033[0m'

stage() { STEP=$((STEP+1)); printf '\n%s[%d/%d] %s%s\n' "$b" "$STEP" "$TOTAL" "$1" "$r"; }
note()  { printf '%s      %s%s\n' "$d" "$1" "$r"; }
warn()  { printf '%s      ! %s%s\n' "$y" "$1" "$r"; }
ok()    { printf '%s      ✓ %s%s\n' "$g" "$1" "$r"; }
pause() { read -r -p "      press ↵ when done (Ctrl-C to stop) "; }
confirm(){ local a; read -r -p "      type $1 to continue: " a; [ "$a" = "$1" ] || { echo "      stopped."; exit 1; }; }

# A picked ROW comes back bare, but Return on text that matched none comes back
# as "<action>⇥<text>" (pounce's Entry.swift) — so strip anything up to a tab or
# every `case` below reads a keystroke name instead of an answer. Esc is exit 1,
# which every caller answers with its own default rather than dying under `set -e`.
choose() { # choose "prompt" opt1 opt2 …
  local p="$1" out; shift
  if command -v pounce >/dev/null 2>&1; then out="$(printf '%s\n' "$@" | pounce -p "$p")" || return 1
  else printf '%s\n' "      $p" >&2; select out in "$@"; do [ -n "$out" ] && break; done; fi
  printf '%s' "${out##*$'\t'}"
}

# Set the moment anything about this Mac is not how it was found, cleared by
# restore(). The trap is the only thing standing between a Ctrl-C and a machine
# left with its pills off and its clock at 09:41.
STAGED=0
still_staged() {
  [ "$STAGED" = "1" ] || return 0
  printf '\n%s      ! this Mac is still staged. Put it back with:%s\n' "$y" "$r"
  printf '%s        %s --restore%s\n\n' "$y" "$0" "$r"
}
trap still_staged EXIT

STATE="${XDG_CACHE_HOME:-$HOME/.cache}/hausfold/shoot-hero"
SHOT_DIR="${SHOT_DIR:-$HOME/Pictures/hausfold-hero}"
DELAY="${DELAY:-25}"
mkdir -p "$STATE"

# The one host dir under ~/.config/nix/hosts — this Mac's, whatever it is named.
host_dir() {
  local dir
  for dir in "$HOME"/.config/nix/hosts/*/; do
    [ -d "$dir" ] || continue
    printf '%s' "${dir%/}"; return 0
  done
  return 1
}
HOST_DIR="$(host_dir)" || { echo "no host dir under ~/.config/nix/hosts"; exit 1; }
SCENE_FILE="$HOST_DIR/scenes.nix"

# Every override this script makes, in one list, so staging and restoring can
# never drift apart.
PILLS=(
  bar.battery.hideOver 5
  bar.items.aiUsage false
  bar.bottom.items.aiUsage false
  bar.items.elgato false
  bar.bottom.items.elgato false
  bar.items.harvest false
  bar.bottom.items.harvest false
)
pill_paths() { local i; for ((i=0; i<${#PILLS[@]}; i+=2)); do printf '%s\n' "${PILLS[i]}"; done; }

restore() {
  local p; local -a paths=(); while IFS= read -r p; do paths+=("$p"); done < <(pill_paths)
  note "haus reset ${paths[*]} — one rebuild, ~1 min"
  haus reset "${paths[@]}" || warn "haus reset said no — check 'haus get bar.battery.hideOver'"
  if [ -e "$SCENE_FILE" ]; then rm -f "$SCENE_FILE"; ok "removed $SCENE_FILE"; fi
  if [ -e "$STATE/clock" ]; then
    note "putting the clock back on network time (sudo)"
    sudo systemsetup -setusingnetworktime on >/dev/null && rm -f "$STATE/clock"
    ok "network time back on"
  fi
  STAGED=0
  ok "machine restored"
}

case "${1:-}" in
  --restore) printf '%s\n' "${b}Putting the Mac back${r}"; restore; exit 0 ;;
  "") ;;
  *) echo "usage: $0 [--restore]"; exit 1 ;;
esac

printf '%s\n%s\n' "${b}Shooting the desktop hero${r}" \
  "${d}Ctrl-C any time. Re-running is safe and skips what is already done.${r}"

# ---- stages ----------------------------------------------------------------

stage "Check the tools and read the disqualifier list"
for tool in haus lazygit pounce screencapture sips; do
  command -v "$tool" >/dev/null 2>&1 || { echo "      missing: $tool"; exit 1; }
done
ok "haus, lazygit, pounce, screencapture, sips all here"
note "the frame is disqualified by ANY of these — assets/SHOTLIST.md row 2:"
note "  · a STALE wordmark or org name, a username, an uptime, a battery %"
note "  · a SELECTED commit — lazygit then puts Author: … <email> in the main"
note "    panel. The Commits rows themselves are initials, and are fine"
note "  · a clock that says something about you. 9:41 by convention"
note "  · this script's own settings/*.nix visible in lazygit's file tree"
note "the shot is 3024×1964, the built-in retina panel, no external display in play"

stage "Drop the personal pills"
if [ "$(haus get bar.battery.hideOver 2>/dev/null)" = "5" ]; then
  STAGED=1
  ok "already staged (battery hideOver is 5)"
else
  STAGED=1
  note "battery pill hides over 5% · aiUsage, elgato and harvest off, both bars"
  note "everything else this host runs STAYS — agents, github, media, cpu,"
  note "memory, caffeinate, calendar, trill. A desktop visibly doing work sells"
  note "better than a staged one, and SHOTLIST says so"
  note "one rebuild, ~1 min"
  haus set "${PILLS[@]}"
  ok "pills staged — 'haus reset' puts them back, and stage 6 does it for you"
fi

stage "The clock"
if [ "$(date +%H%M)" = "0941" ]; then
  ok "the clock already reads 9:41"
else
  pick="$(choose "clock reads $(date '+%-H:%M') — SHOTLIST wants 9:41" \
    "wait and shoot at 09:41" "set the clock to 09:41 now" "shoot with the real time")" \
    || pick="shoot with the real time"
  case "$pick" in
    set*)
      warn "this moves system time — launchd timers, git timestamps and TLS all see it"
      confirm CLOCK
      # Marker first: a sudo that fails halfway still has to be undoable, and
      # restore() keys on nothing else.
      touch "$STATE/clock"; STAGED=1
      sudo systemsetup -setusingnetworktime off >/dev/null
      sudo date 0941 >/dev/null
      ok "clock set to 09:41 — stage 6 puts network time back"
      ;;
    wait*)
      note "come back at 09:41 and re-run: stages 1–2 skip, so it picks up here"
      note "leave it staged, or './script/shoot-hero.sh --restore' in the meantime"
      exit 0
      ;;
    *)  warn "shooting with the real time — the frame carries it, and SHOTLIST says it shouldn't" ;;
  esac
fi

stage "Stage the scene"
cat > "$SCENE_FILE" <<'SCENE'
# One word to the launcher —
# the Mac changes shape.
{
  haus.focus.scenes = {
    writing = {
      description = "no interrupts";
      dnd = true;
      apps = {
        open = [ "Obsidian" "Zen" ];
        closeOnExit = true;
      };
    };

    call = {
      description = "camera on";
      dnd = true;
      preventSleep = true;
      audio.input = "Studio Mic";
      apps.open = [ "Zoom" ];
    };
  };

  haus.shelf.watchScreenshots = true;
  haus.terminal.ghDash.enable = true;
}
SCENE
ok "wrote $SCENE_FILE — untracked, so no build ever sees it"

note "opening github.com/hausfold"
open -a Zen "https://github.com/hausfold" 2>/dev/null || open "https://github.com/hausfold"
note "now set the frame, left to right:"
note "  1. Zen on github.com/hausfold — SCROLL until the ✉ contact line is gone."
note "     Half-behind the Pounce panel is not gone — that still reads 'jul…'."
note "  2. Ghostty right, lazygit over your ~/.config/nix tree, normal screen"
note "     mode — NOT '+', which widens the tree and squeezes the diff panel"
note "     until every line of nix wraps. Press 2 to focus Files."
note "     ⚠ do not select a COMMIT: lazygit then draws Author: … <email> in"
note "     the main panel, and an email in frame is the one hard strike."
note "  3. \`haus set\` wrote its overrides into hosts/mbp/settings/, which is"
note "     the very tree you are photographing — a frame showing"
note "     bar.battery.hideOver.nix is a frame explaining how it was faked."
note "     Put the cursor on the 'settings' folder and press ENTER to fold it"
note "     away (← / → switch the Files/Worktrees tabs, they do not collapse)."
note "     Then select scenes.nix so the diff panel carries it."
note "  4. ⌘Space and type NOTHING. The empty palette is the frame: a query"
note "     highlights one row and hides the action tiles, which are the part"
note "     that says what the launcher is for."
note "  5. Both bars on. No external display. Music pill is fine; pause it if"
note "     the track name is not one you want on Hacker News."
pause
ok "scene staged"

stage "Shoot it"
mkdir -p "$SHOT_DIR"
OUT="$SHOT_DIR/hero-$(date +%Y%m%d-%H%M%S).png"
# Pounce draws the top clipboard entry in the palette, so the clipboard is IN
# the frame. Put something chosen there rather than whatever was last copied.
printf '%s' "https://hausfold.co" | pbcopy
note "clipboard set to hausfold.co — it shows in Pounce's palette"
note "press ↵ and you have ${DELAY}s. The shutter SOUND is left on as the cue,"
note "so you know the frame is taken without watching this window."
note "in those ${DELAY}s: switch to the staged workspace · ⌘Space · type 's' ·"
note "leave the pointer somewhere harmless · hold still."
pause
screencapture -T "$DELAY" -t png -D 1 "$OUT" &
shutter=$!
wait "$shutter" || true
[ -s "$OUT" ] || { echo "      no file at $OUT — nothing was captured."; exit 1; }
W="$(sips -g pixelWidth "$OUT" | awk '/pixelWidth/{print $2}')"
H="$(sips -g pixelHeight "$OUT" | awk '/pixelHeight/{print $2}')"
ok "captured ${W}×${H} → $OUT"
[ "$W" = "3024" ] && [ "$H" = "1964" ] || \
  warn "the shipped hero is 3024×1964 — a different size means a different display"

stage "Put the machine back"
pick="$(choose "restore now, or leave it staged for another take?" \
  "restore now" "leave it staged")" || pick="leave it staged"
case "$pick" in
  restore*) restore ;;
  *) note "left staged. './script/shoot-hero.sh --restore' when you are done"
     note "(re-running the whole script is also fine — it skips what is done)" ;;
esac

stage "Hand it to a reader"
printf '\n%s✓ done.%s  the frame is at:\n\n      %s\n\n' "$g" "$r" "$OUT"
note "paste that path to Claude and ask it to read the capture against"
note "SHOTLIST row 2's disqualifier list before anything is committed."
note "a capture nobody read back is how the frame on disk shipped with four."
note "⚠ with no Screen Recording permission this is a wallpaper-only PNG at the"
note "right size and exit 0 — both checks above pass it. Look before you trust it."
