# The agent's own Mac

**How an agent lane gets a macOS it is allowed to touch — boot it, drive its UI,
screenshot it — without ever reaching the screen the user is sitting in front
of.** The one-line version every lane needs: *if you want to see it, don't take
the screen — take a VM.*

## The pieces

| | |
|---|---|
| `scruff runtime up\|enter\|down <lane> --backend <id>` | generic: loads `~/.config/scruff/adapters/runtime/<id>.toml`, renders each argv element through `text/template` with the lane vars, execs it. Never automatic — create/reap never touch a backend |
| the `tart` adapter | `haus.ai.enable` writes `~/.config/scruff/adapters/runtime/tart.toml` + `~/.config/haus/runtime/tart-adapter.sh` (from `modules/ai/runtime/tart-adapter.sh`). The script does the multi-step dance scruff's single-argv contract can't: `tart clone` → `tart run --no-graphics --dir=work:<lane path>` backgrounded → `tart ip --wait` → `ssh admin@$ip` |
| the golden image | `haus`'s `script/build-golden-vm.sh` — clone the base, run a **pinned-tag** `bootstrap.sh` (never the floating `hausfold.co/hacker.sh`, which resolves the latest release and drifts), switch, stop, leave a tagged image lanes clone in seconds |

## The loop

```sh
scruff runtime up    my-lane --backend tart   # clone golden image, boot headless
scruff runtime enter my-lane --backend tart   # ssh in, or drive it from the host
scruff runtime down  my-lane --backend tart   # delete the clone
```

and, for the half that is not scruff's business:

```sh
tart ip scratch                                    # 192.168.64.5
ssh admin@192.168.64.5 '/usr/sbin/screencapture -x /tmp/s.png'
scp admin@192.168.64.5:/tmp/s.png "$SCRATCHPAD/"   # real pixels, 2048×1536
ssh admin@192.168.64.5 '/usr/bin/osascript \
  -e "tell application \"System Events\" to keystroke space using command down"'
```

What holds, measured:

- **A fresh clone stops at a disk-unlock modal before SSH exists.** The base
  image's `Nix Store` APFS volume is FileVault-encrypted (`disk2s7`), and every
  clone comes up with `/nix` unmounted and *"Enter a password to unlock the
  disk 'Nix Store'"* on the guest's console — port 22 gives `No route to host`
  (not a refusal) until the modal is answered, which reads like a dead network
  but is a stalled boot. Typing the guest admin password (`admin`) mounts the
  volume and SSH answers within seconds; the passphrase is already in the
  guest's System keychain (`security find-generic-password -s "Nix Store"`), so
  this is a boot-time mount gap, being fixed in the image
  (`haus`'s `script/build-golden-vm.sh`). Until it lands, a headless lane needs
  one answer at a console (`tart run` headful) before `scruff runtime enter`
  will ever connect.
- **Passwordless SSH works** — the key is in the guest.
- **`screencapture -x` over SSH returns real pixels**, no GUI session juggling.
  `launchctl asuser 501` is *not* needed and in fact fails (`Could not switch to
  audit session`) — call the binary directly.
- **`osascript` → System Events drives the UI.** ⌘Space over SSH opens the
  Pounce palette.
- **The guest is auto-logged-in at the console**, with WindowServer, Dock and
  the bar running.

## TCC prompts fire — they just don't block

The operation succeeds *and* a permission dialog appears. Both. The guest's
system TCC.db is written with `auth_value = 2` at the same instant the dialog
goes up, so the command returns real data while the modal sits there unanswered
forever. **One prompt per (service, client) on first use, not per call** — the
graveyard is a fixed, enumerable set, not a growing nag.

⚠️ **The enabling fact is a property of the image, not of tart.** The cirruslabs
base ships with **SIP disabled** (`csrutil status: disabled`), which is what
lets a grant be written rather than merely requested. A golden image built any
other way — a hand-installed macOS, an MDM-managed one — does not inherit it,
and the same commands then *do* block on a modal nobody can click. **Write that
down before someone "cleans up" the base image.**

## What the golden image has to do about dialogs

Unanswered dialogs stack on a fresh guest's desktop — document-type and
permission alerts, the macOS 26 *"com.apple.sshd-session is requesting to bypass
the system private window picker"* capture prompt, a Keystroke Receiving prompt,
and Notification Center banners. Harmless to SSH, **fatal to a screenshot**: the
agent's evidence is 40% unrelated modal and the thing it was sent to look at is
behind them.

Most are scriptable — System Events enumerates every alert window and its
buttons over SSH:

```applescript
tell process "UserNotificationCenter" to click button "Allow" of window 1
tell process "CoreServicesUIAgent"    to click button "Keep “QuickTime Player”" of window 1
```

Three survive, and they are what the build script actually has to handle:

- **The Keystroke Receiving prompt is haus's own**, for `sleepwatcher`
  (AeroSpace's on-wake watcher). Its only dismissing button is `Deny`, which is
  the wrong answer — the grant has to be **written**, not clicked, which means
  an explicit reviewed TCC.db insert in the build script.
- **`sleepwatcher` runs from a nix store path.** A TCC row keyed to
  `/nix/store/<hash>-sleepwatcher-2.2.1/bin/sleepwatcher` dies at the next
  version bump, the same trap as a Homebrew Cellar path. Grant to something
  stable, or re-grant on every rebuild.
- **The two Notification Center banners have no clickable close** from System
  Events; they need their own dismissal, or suppression before they are posted.

## The “Nix Store” disk-unlock modal — cosmetic, but not to an agent

Determinate's installer encrypts the "Nix Store" volume (`disk2s7`) and stashes
the passphrase in the guest's System keychain for a boot-time auto-unlock. On a
Tahoe guest that consumer never runs: at boot APFSUserAgent pops **"Enter a
password to unlock the disk 'Nix Store'"** (log: `_DMAPFSHintForCryptoUserForVolume
IntErr=2` — no crypto-user hint), and the dialog sits on the desktop forever.

**Nothing is actually blocked.** `determinate-nixd`'s `systems.determinate.nix-store`
daemon mounts `/nix` itself from the keychain ~41s after boot, and passwordless
SSH is reachable the whole time — a clone that "needs the screen to boot" was a
misread of the ~40s boot window. But a stale password modal on a lane's first
screenshot is still a wrong answer, so the golden image **decrypts the volume**
(`diskutil apfs decryptVolume`, online, ~1 min for a ~12GB store — the step is
in `build-golden-vm.sh` 2.5). A decrypted volume cannot prompt: measured, zero
`DiskUnlock` prompts after decryption, `/nix` mounted, SSH up ~10s after reboot.
A lane VM gains nothing from FileVault.

## `agent-desktop-guard` and the VM

`modules/ai/desktop-guard.sh` splits a command at unquoted `;`, `&&`, `||`, `|`
and newlines, drops the segments that run on another machine, and lets its
patterns see only what is left. The split is quote-aware — `ssh h 'a; b'` is ONE
remote segment, not a remote one and a local `b` — and length-preserving, so a
kept segment is re-emitted as its own original text.

| command | gated? |
|---|---|
| `ssh admin@<guest> 'haus rebuild'` · `'sketchybar --reload'` · `'killall Dock'` | no |
| `ssh admin@<guest> "…" && killall Dock` | **yes** — the local half |
| `ssh localhost '…'` · `ssh -X …` | **yes** — both really do draw here |
| `tart run <vm> --no-graphics &` | no |
| `tart run <vm>` | **yes** — it opens the guest's window on the user's display |
| `haus rebuild` · `open -a Ghostty` · `aerospace focus left` | **yes** |

Whatever the mask can't classify (a heredoc body, a `$(…)`, an ssh whose host is
a variable) counts as **local**, so the failure mode is one extra prompt, never
a missed one. `test/desktop-guard.bats` pins both sides of that line, including
the false-negative direction, and runs green under BWK awk, mawk and gawk.

`HAUS_DESKTOP_OK=1` is the blunt whole-guard hatch for a pane — for a long
unattended run, not for the VM.

## Constraints worth knowing before "a VM per lane"

**Disk is the cap, not RAM.** A full macOS clone is tens of GB. `tart clone` is
APFS copy-on-write (cheap at creation, grows as the guest writes) and `tart
suspend` beats a cold boot. A `scruff runtime` verb reporting what a lane's
backend costs would be worth more than a concurrency guard.

**The base OS is one decision, recorded in one place.** Every measurement here
was taken on Tahoe; an adapter header naming a Sequoia base pulls a second ~30 GB
image on which these findings may not hold.
