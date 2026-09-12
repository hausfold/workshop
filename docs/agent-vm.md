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
| the golden image | `haus`'s `script/build-golden-vm.sh` — clone the base, grow its disk to 90 GB (the base's is 50, and a raised house fills 45), put Gatekeeper back (the base ships it off, and App-Store-only underneath), run a **pinned-tag** `bootstrap.sh` (never the floating `hausfold.co/hacker.sh`, which resolves the latest release and drifts), switch, stop, leave a tagged image lanes clone in seconds |

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

- **`No route to host` on port 22 has three causes, and only one is the guest.**
  Run `ping -c3 192.168.64.255` and read the answer three ways. **A reply from
  the guest's own address, with 100% loss on the unicast ping to that same
  address**, is a host-side `bridge100` fault: the guest is fully booted and
  answering, and host→guest unicast alone is being dropped, so nothing at the
  guest's screen can help. **No reply at all, within the first minute of boot**,
  is just the boot window — wait, and see *The "Nix Store" disk-unlock modal*
  below before concluding anything. **No reply after that** is the guest.
  Check `arp -an` against `/var/db/dhcpd_leases`, and `ifconfig bridge100`'s own
  address cache, but do not stop when they look right: both can be exactly
  correct while unicast still goes nowhere. The broadcast test assumes the guest
  answers subnet-broadcast ICMP, which `haus-golden` does; an image that has
  turned it off will read as the third case whatever is true.

  ⚠️ **The cure is machine-wide, so it is the user's, not yours.** A vmnet reset
  (`sudo ifconfig bridge100 down && sudo ifconfig bridge100 up`, every VM
  stopped first) drops networking for every guest on the box, and with a cap of
  two the other one is quite likely another lane's. `sudo` here prompts for a
  password, so an unattended pane hangs on it rather than failing. Hand the user
  the command, or ask for the reboot; do not run either yourself. **The reboot is
  the one with a measured result behind it** — after one, a bare `tahoe-base`
  clone answered unicast at 0% loss and took SSH on the first try (2026-09-04).
  The vmnet reset is the smaller blast radius and the reboot is the known cure,
  so say which you are asking for and why.
- **Never pipe `scruff runtime up`, or capture it in `$(…)`.** The tart adapter
  backgrounds `tart run` (`haus`'s `modules/ai/runtime/tart-adapter.sh:40`) with
  no redirection, so that child inherits the adapter's stdout and holds the write
  end of your pipe open for the whole life of the guest. Your reader therefore
  never sees EOF: `| tail` and `$(…)` hang with **no output at all**, and `| tee`
  hangs after printing everything. Meanwhile the guest is up — the adapter had
  already echoed its `… is up at <ip>` line. Let it write straight to the
  terminal, or redirect to a file, and read the guest's real state from `tart
  list` and `tart ip` rather than from whether the command returned. Two things
  make this worth naming rather than living with: the adapter can end the hazard
  by redirecting that line 40 into a lane log, and its `tart ip --wait 60`
  ceiling means a boot slower than a minute exits non-zero having printed nothing
  either — same silence, opposite cause.
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

## Gatekeeper in the base is wrong twice, and the second one lies about your app

The cirruslabs base is a CI worker image, so it ships Gatekeeper off. That is
two separate settings, and only the first is obvious:

1. **assessments off wholesale** — `spctl --status` reads `assessments
   disabled`. A Developer ID app opened here raises **no dialog at all**.
2. **underneath that, the policy DB has the Developer ID rules disabled** —
   the "App Store" setting, not the "App Store and identified developers"
   every real Mac ships with. Turn assessments back on and a signed,
   notarized app is refused as **"not downloaded from the App Store"**.

Neither state is what a user sees, so neither is evidence. The second is the
expensive one: it reads as a signing or notarization fault in the app under
test, and the app is fine. It cost perch's 2026-09-11 release a day.

**The DB is not where you think, and the wrong path is booby-trapped.** On
macOS 26 there is no `/var/db/SystemPolicy` — the file is
`/var/db/SystemPolicyConfiguration/SystemPolicy`. Reading the old path gets
you nothing, and *writing* it (a `sudo cp` of `.SystemPolicy-default`, say)
silently creates a decoy that syspolicyd never reads, so the symptom does not
move and you conclude the image is damaged. It is not damaged; it is
configured. `ls` the directory, not the glob: `/var/db/SystemPolicy*` matches
`SystemPolicyConfiguration/` and lists its contents, which looks like the
answer and is not.

Check the rules rather than the summary line:

```sh
sudo sqlite3 /var/db/SystemPolicyConfiguration/SystemPolicy \
  'SELECT id, label, disabled FROM authority WHERE label LIKE "%Developer ID%";'
```

**Restoring it is a write, not a click.** `spctl --enable --label "Developer
ID"` is how this was spelled until macOS 15 removed the subcommand, so the
rows go in directly — legal for the same reason the TCC insert above is: SIP
is off in this base.

```sh
sudo spctl --global-enable          # --master-enable on older releases
sudo sqlite3 /var/db/SystemPolicyConfiguration/SystemPolicy \
  "UPDATE authority SET disabled = 0 WHERE label IN ('Developer ID', 'Notarized Developer ID');"
sudo killall syspolicyd
spctl --status --verbose            # assessments enabled / developer id enabled
```

Measured on Tahoe 26.6.2, 2026-09-12: it reads back correct with no reboot,
and survives one. `Unnotarized Developer ID` and `Testflight` stay disabled —
they are disabled on a stock Mac too, and enabling them would make the image
lie in the other direction. `haus`'s `script/build-golden-vm.sh` does this as
step 1.6, before bootstrap, so a base that has moved fails in a minute rather
than forty.

**What a correct first open looks like, measured 2026-09-12.** Bare base
clone, Gatekeeper restored, perch v2026.09.11-2 fetched through Safari from
`hausfold.co/download/perch`:

> **"Perch" is an app downloaded from the Internet. Are you sure you want to
> open it?**
> Safari downloaded this file today at 7:41 AM. Apple checked it for malicious
> software and none was detected.  ·  [Cancel] [Open]

That is the pass. "Unidentified developer" or "not downloaded from the App
Store" is a fail, and on this image the second one means step 1.6 did not run,
not that the app is unsigned. `spctl -a -t exec -vv` is the non-visual half of
the same answer and does not need a screen: `accepted` /
`source=Notarized Developer ID`.

Three things the run turned up that cost time if you meet them cold:

- **Safari asks before it downloads.** "Do you want to allow downloads on
  release-assets.githubusercontent.com?" — GitHub's release redirect, so the
  host in the prompt is never the one you typed. It is not a Safari *sheet*;
  `sheet 1 of window 1` throws `Invalid index`, and pressing Return over an
  activated Safari is what gets past it.
- **Safari expands the zip for you**, so what lands is `~/Downloads/Perch.app`
  and not the archive. Quarantine on it reads `0083;…;Safari;…`, and rises to
  `00c3` once the dialog is answered — a cheap way to prove the approval was
  recorded without taking a second picture.
- **Installing with `cp`/`ditto` translocates the app.** It runs from
  `/private/var/folders/…/AppTranslocation/…/d/Perch.app`, read-only and at a
  path that changes per launch, which breaks anything that registers itself by
  location. A Finder *move* is what avoids it, which is why the canonical
  install is a drag and why a scripted `ditto` is not a substitute for one.
  The Gatekeeper dialog is identical either way — it keys on the quarantine
  xattr — so this changes what you can conclude about the app, not about
  Gatekeeper. What it *does* invalidate is anything that reads the app's
  path: a translocated perch registers a login item whose URL points into the
  per-launch mount, so a login-item check passes and then points at a path
  that will not exist next boot. **Stripping the quarantine xattr before the
  copy** (`xattr -d com.apple.quarantine`, the scripted stand-in for a user's
  Open click) also avoids translocation, and is what makes a `ditto` install
  safe to draw conclusions from — measured both ways, 2026-09-12:
  `perch doctor` read `/Applications/Perch.app` and BTM's login item URL was
  `file:///Applications/Perch.app/`. Keep the quarantine and script the copy
  and you get neither.

⚠️ **A first-open test needs a bare base clone, not the golden image.** The
golden has haus on it, and haus installs `/Applications/Perch.app` with its
LaunchServices registrations already made — so the one thing the test is
looking for, a virgin first launch, cannot happen there. Clone `tahoe-base`,
apply the block above, and test on that. The clone is copy-on-write and costs
seconds.

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
SSH is reachable the whole time. The modal never has to be answered for a lane
to connect; what it costs is the ~40s of boot window, which reads like a clone
that needs the screen. But a stale password modal on a lane's first
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

**A guest count is the cap, not disk and not RAM — measured here as two.**
`tart run` refuses a third outright (*"The number of VMs exceeds the system
limit"*, naming the two already up) on this 32 GB M4, with memory half free at
the time — so the number is this Mac's, pinned the same way the Tahoe note below
is, and worth re-measuring on a host with different memory before relying on it.
Whatever it is, it is small and it binds first. So "a VM per lane" is
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

The guest's own disk is the one that bites. The cirruslabs base ships a 50 GB
disk and a raised house fills 45 of it, so a clone that inherits the base's
size has about 5 GB to work with, and `haus update` fills that the first time
nixpkgs moves. `build-golden-vm.sh` therefore grows the disk to 90 GB right
after `tart clone` (`--disk-size`, default 90). The guest half of that is the
base's tart-guest-agent daemon: at every boot it grows the partition and then
the APFS container out to the disk, on its own schedule. That schedule is the
trap. The Nix installer adds a volume to the same container, and on the one
bake where the two overlapped, diskmanagementd deadlocked for good: partition
grown, container not, the installer stuck at "Create an encrypted APFS
volume", every new ssh session hung behind them (2026-09-05). The script now
waits for `df /` to report the grown size before it runs bootstrap. Anything
else that boots a freshly resized guest and touches its disk wants the same
wait.

**The base OS is one decision, recorded in one place.** Every measurement here
was taken on Tahoe; an adapter header naming a Sequoia base pulls a second ~30 GB
image on which these findings may not hold.
