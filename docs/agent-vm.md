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
| `haus-vm-shot <lane> [dest.png]` | the capture half, which is not scruff's business: `tart ip` → `screencapture -x` on the guest → `scp` back → print the host path, one line, nothing else. `haus.ai.enable` puts it on PATH; it is one `exec` into the same adapter's `shot` subcommand, so the `scruff-<lane>` naming has one home. `test/vm-shot.bats` in haus pins what a human never sees: the one-line stdout, the silent `-x`, the `scruff-<lane>` VM name, the guest-side `rm`, and a failure that prints no path |
| the golden image | `haus`'s `script/build-golden-vm.sh` — clone the base, run a **pinned-tag** `bootstrap.sh` (never the floating `hausfold.co/hacker.sh`, which resolves the latest release and drifts), switch, stop, leave a tagged image lanes clone in seconds |

## The loop

```sh
scruff runtime up    my-lane --backend tart   # clone golden image, boot headless
scruff runtime enter my-lane --backend tart   # ssh in, or drive it from the host
scruff runtime down  my-lane --backend tart   # delete the clone
```

and, for the half that is not scruff's business:

```sh
haus-vm-shot scratch                               # the three below, as one verb, guest tidied after
tart ip scratch                                    # 192.168.64.5
ssh admin@192.168.64.5 '/usr/sbin/screencapture -x /tmp/s.png'
scp admin@192.168.64.5:/tmp/s.png "$SCRATCHPAD/"   # real pixels, 2048×1536
ssh admin@192.168.64.5 '/usr/bin/osascript \
  -e "tell application \"System Events\" to keystroke space using command down"'
```

What holds, measured:

- **`No route to host` on port 22 does not mean the guest is stuck.** It is
  equally the signature of a host-side `bridge100` fault: host→guest *unicast*
  is dropped while the guest is fully booted and answering. Discriminate before
  you go hunting for a console — `ping -c3 192.168.64.255` and watch for a reply
  from the guest's own address. A broadcast reply, with 100% loss on the unicast
  ping to that same address, is a bridge fault rather than a stalled boot, and
  nothing at the guest's screen will fix it: stop every VM and reset vmnet
  (`sudo ifconfig bridge100 down && sudo ifconfig bridge100 up`), or reboot the
  host. Check the cheap things first — `arp -an` against
  `/var/db/dhcpd_leases`, and `ifconfig bridge100`'s own address cache — but
  note that both can be perfectly correct while unicast still goes nowhere.
- **Passwordless SSH works** — the key is in the guest.
- **`screencapture -x` over SSH returns real pixels**, no GUI session juggling.
  `launchctl asuser 501` is *not* needed and in fact fails (`Could not switch to
  audit session`) — call the binary directly.
- **`osascript` → System Events drives the UI.** ⌘Space over SSH opens the
  Pounce palette.
- **The guest is auto-logged-in at the console**, with WindowServer, Dock and
  the bar running.

## Getting the picture out: it goes in the pull request

Attaching a file needs **gh 2.99.0 or newer**. Check `gh --version` before you
write the command: 2.98.0 has no `--attach` at all, and what any machine has is
whatever its nixpkgs pin carries. `--attach` is on `pr` and `issue` ×
`create`, `edit` and `comment`; it is repeatable, up to 50 files a command, and
alt text follows the path after `#`. `haus-vm-shot`'s one-line stdout is shaped
for the substitution:

```sh
gh pr create  --base main --title "…" --body-file - \
              --attach "$(haus-vm-shot my-lane)#the bar, after"
gh pr comment 42 --attach "$(haus-vm-shot my-lane)#⌘Space, no filter flash"
```

Images cap at 10 MB. A body reference like `![alt](./shot.png)` is rewritten in
place to point at the uploaded asset; an attachment the body never mentions is
appended. GitHub Enterprise Server is not supported. The release that shipped
the flag names OAuth and classic personal access tokens as what it
authenticates with and says nothing about fine-grained ones, so treat a job
running on a fine-grained token or a workflow's `GITHUB_TOKEN` as unproven
rather than as working.

**It is opt-in, per PR, and the cost is not the camera.** A capture is seconds;
a capture that shows *your* change needs `haus rebuild` inside the guest first,
which is minutes — so a screenshot earns its place only where the alternative is
a human feeling the change by hand. The visual repos (haus's bar and tiling,
nebelung's palette, pounce, perch, trill) are where that is true; a docs or
script PR gets nothing from a photograph of a desktop. A CLI change needs no
picture and no VM: paste the real output into the body as a fenced block.

The dialog problem is what makes this fail badly rather than obviously: an
unanswered modal does not block the capture (see *What the golden image has to
do about dialogs*, below), so the PR gets a picture that is 40% alert and 0%
evidence. Look at the frame before you upload it.

## Driving the keyboard: three things that read as "the feature is broken"

Every one of these was measured while pressing a desktop's whole keymap in a
guest, and each first showed up as a *finding about the desktop* that turned out
to be a fact about the harness.

- **AppleScript `keystroke` puts `1 . / - =` on the NUMERIC KEYPAD.** Those
  characters exist twice on a US layout, and System Events resolves them to the
  keypad key code — which no window-manager binding names. So every one of them
  reads as "unbound" on a machine where they are plainly bound, and only those
  five, which looks exactly like a real bug in the punctuation half of a keymap.
  Resolve the character yourself against the live layout (`UCKeyTranslate` over
  the main block only) and post a `CGEvent`.
- **A synthesized function key needs `maskSecondaryFn`.** `key code 123` (left
  arrow) and `key code 79` (F18, which is what a Caps-Lock leader is remapped to)
  reach nothing without it and work with it. Arrows and F-keys carry that flag on
  a real keyboard; a CGEvent does not add it for you. AppleScript's own
  `key code` does, which is why the two disagree.
- **One unanswered Automation prompt wedges System Events for EVERY caller.**
  The first time an app asks to control System Events — AeroSpace opening System
  Settings, pounce raising a window — the modal blocks every `osascript` on the
  machine, including the one you wrote to dismiss modals. Answer it with a
  synthesized click (`CGEvent`, which needs nothing from System Events), and keep
  the hot path off AppleScript entirely so a wedge stalls the sweeper and not the
  run.

**Read the layout, don't recall it.** `TISCopyCurrentKeyboardLayoutInputSource`
+ `UCKeyTranslate` over the ~48 main-block key codes, in all four
plain/⇧/⌥/⌥⇧ states, is ~60 lines of Swift and settles what a key prints without
a single guess. Every AZERTY claim worth writing down came out of that table.

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

**Two guests, machine-wide — that is the cap, not disk and not RAM.** `tart run`
refuses a third outright (*"The number of VMs exceeds the system limit"*, naming
the two already up), on a 32 GB M4 with memory half free. So "a VM per lane" is
false past the second lane, and a leaked VM does not cost disk so much as half
the lane capacity: two of them and the backend is full with nothing running that
anyone wants.

That is what makes the asymmetry in `scruff runtime` expensive. `up` clones and
boots; nothing reaps. A lane that dies without its `down` leaves a live headless
guest holding a slot, and once its lane directory is gone there is nothing left
on the machine that knows to clean it up — `tart list` is the only place it
shows. A concurrency guard, or a `runtime` verb that reaps by lane, is worth
more here than a cost-reporting one.

Disk is the cheap axis by comparison: a full macOS clone is tens of GB, but
`tart clone` is APFS copy-on-write (cheap at creation, grows as the guest
writes) and `tart suspend` beats a cold boot.

**The base OS is one decision, recorded in one place.** Every measurement here
was taken on Tahoe; an adapter header naming a Sequoia base pulls a second ~30 GB
image on which these findings may not hold.
