# The agent's own Mac

State, 2026-08-22. How an agent lane gets a macOS it is allowed to touch — boot
it, drive its UI, screenshot it — without ever reaching the screen the user is
sitting in front of.

Everything in §2 was measured on this machine today, against the live `scratch`
VM. §3 is what is still missing, in the order it should close.

## 0. Why this exists

`~/.claude/CLAUDE.md`'s **"the screen belongs to the person at it"** and haus's
`agent-desktop-guard` both say the same thing: an agent must not take the
pointer, the focus or the frontmost window on a Mac somebody is using. That is
right, and it leaves a hole — half of what this family ships **is** a desktop.
A lane cannot feel-test the palette, the bar, a tiling keybind or an installer
run by reading a diff, and "hand it back to the user" does not scale to N lanes.

The VM is what makes the guard livable: a second, disposable macOS the lane
owns outright, headless on the host so nothing renders to the user's display,
and real enough to run `darwin-rebuild switch` and draw the actual UI.

## 1. What already shipped

| | |
|---|---|
| `holt runtime up\|enter\|down <lane> --backend <id>` | holt `be5f571` (#52), docs `a81d64c` (#53). Generic: loads `~/.config/holt/adapters/runtime/<id>.toml`, renders each argv element through `text/template` with the §5.2 lane vars, execs it. Never automatic — create/reap never touch a backend |
| the `tart` adapter | haus `8a33c4b` (#456). `haus.ai.enable` writes `~/.config/holt/adapters/runtime/tart.toml` + `~/.config/haus/runtime/tart-adapter.sh` (from `modules/ai/runtime/tart-adapter.sh`), and the script does the multi-step dance holt's single-argv contract can't: `tart clone` → `tart run --no-graphics --dir=work:<lane path>` backgrounded → `tart ip --wait` → `ssh admin@$ip` |

Neither has ever booted a VM in anger: haus#456 was merged on the strength of
its error paths, and `tart` is not installed on this machine (see §3.1).

## 2. Measured today — the loop works end to end

Against `scratch` (a Tahoe 26.6.2 guest from an earlier hand-run session, with
haus already activated inside it), driven from a lane with no host UI touched:

```sh
tart ip scratch                                    # 192.168.64.5
ssh admin@192.168.64.5 '/usr/sbin/screencapture -x /tmp/s.png'
scp admin@192.168.64.5:/tmp/s.png "$SCRATCHPAD/"   # 2048×1536 PNG, real pixels
ssh admin@192.168.64.5 '/usr/bin/osascript \
  -e "tell application \"System Events\" to keystroke space using command down"'
```

- **Passwordless SSH already works** — the key is in the guest.
- **`screencapture -x` over SSH returns real pixels**, no prompt, no GUI session
  juggling. `launchctl asuser 501` is *not* needed and in fact fails
  (`Could not switch to audit session`) — call the binary directly.
- **`osascript` → System Events drives the UI.** ⌘Space over SSH opened haus's
  own Pounce palette; the screenshot proves it.
- **The guest is auto-logged-in at the console** (`who` shows `admin console`),
  with WindowServer, Dock and the sill bar running.

**Why none of that hits TCC — and it is not luck.** The cirruslabs base image
ships with **SIP disabled** (`csrutil status: disabled`), and its system
TCC.db carries pre-granted rows:

```
kTCCServiceAccessibility | /usr/libexec/sshd-keygen-wrapper | 2
kTCCServicePostEvent     | /usr/libexec/sshd-keygen-wrapper | 2
kTCCServiceAppleEvents   | /usr/libexec/sshd-keygen-wrapper | 2
kTCCServiceScreenCapture | /usr/bin/osascript               | 2
```

That is the single fact the whole capability rests on, and it is a property of
the **image**, not of tart. A golden image built any other way (a hand-installed
macOS, an MDM-managed one) does not inherit it, and every one of the commands
above then dies on a modal nobody can click. Write it down before someone
"cleans up" the base image.

## 3. What's missing, in closing order

### 3.1 `tart` is not installed, and the adapter's comment points the wrong way

`tart` is not on PATH here at all — only in the store, at
`/nix/store/…-tart-2.30.6/bin/tart`, from some earlier `nix shell`. So the
shipped adapter is still a dead end on a fresh machine. Two things to decide:

- **nixpkgs has `tart` 2.30.6.** The generated `tart.toml`'s header — written
  by `haus/modules/ai/default.nix:395`, *not* by the adapter script — says
  `brew install cirruslabs/cli/tart`, which is the wrong instruction on a
  machine whose every other tool arrives through the flake. Fix it there, and
  fix the same header's "edit `modules/ai/runtime/tart-adapter.sh`, not here"
  pointer while you are in it: the brew line isn't in that script either, so a
  reader chasing it lands twice in the wrong file. Either the AI room installs
  `tart` (behind its own option — it is a small binary; the *images* are the
  tens of GB) or the header names the nixpkgs attr.
- **Decide the base OS, and say so in one place.** That same header and the
  adapter's `HOLT_TART_BASE` error both name
  `ghcr.io/cirruslabs/macos-sequoia-base:latest` — but every measurement in §2,
  and §3.2's macOS-26 capture prompt, was taken on **Tahoe**. Following the
  shipped instruction pulls a second ~30 GB image on which those findings may
  not hold.
- The base image is already local here as `tahoe-base` (32 GB, stopped); the
  ~30 GB pull is a cost a *fresh* machine pays.

### 3.2 There is no golden image

haus#456's own PR body names this as its deliberate follow-up: a
`build-golden-vm.sh` (planned for a new top-level `script/` dir — haus has only
`test/` and `compat/` today), never written. Without it, `holt runtime
up --backend tart` clones a **bare** macOS: no Nix, no haus, nothing to test.
The script's job is to clone the base image, run a pinned-tag `bootstrap.sh`
(never the floating `hausfold.co/hacker.sh` — it resolves the latest release
and drifts), switch, stop, and leave a tagged image lanes clone from in seconds.

**And it has a second job nobody has costed: killing the dialog graveyard.**
`scratch`'s desktop today is four stacked modals and two notification banners —
"bash wants access to control System Events", a Keystroke Receiving prompt, "See
what's new in macOS Tahoe", "App Background Activity", an IINA/QuickTime
document-type dialog. They are harmless to SSH and fatal to a *screenshot*: the
agent's evidence is 40% unrelated modal. Worse, macOS 26 adds a new one the
moment you capture — **"com.apple.sshd-session is requesting to bypass the
system private window picker"** — which the existing pre-grants do not cover,
because they are keyed to `sshd-keygen-wrapper`, not to the `sshd-session`
bundle id. A golden image has to land with that row written and the first-run
banners already answered, or every lane rediscovers them.

### 3.3 Disk is the real concurrency cap, not RAM

31 GB free on this machine right now, against 108 GB already held by three
hand-made VMs. One more full clone barely fits. Before "a VM per lane" is even
proposable: `tart clone` is APFS CoW (cheap at creation, grows as the guest
writes), `tart suspend` exists and beats a cold boot, and the plan's flock-based
concurrency guard was never built. A `holt runtime` verb that reports what a
lane's backend is costing would be worth more than the guard.

### 3.4 `agent-desktop-guard` cannot tell a VM from the user's Mac

`modules/ai/desktop-guard.sh` greps the command string, and a guest's address
is not part of it. Fed real hook JSON, `ssh admin@192.168.64.5
'osascript … activate'`, `… 'sketchybar --reload'` and `… 'darwin-rebuild
switch'` each re-open the permission prompt — for actions that are, by
construction, invisible to the user. That is the exact failure the guard's own
comment warns about: "a long list stops being read and starts being clicked
through."

The mirror image is just as instructive: `ssh admin@… 'killall Dock'` does
**not** match, because that pattern is anchored to a command boundary
(`(^|[;&|] *)killall`) and the ssh quote isn't one. So the guard is
simultaneously too loud about the VM and blind to the one VM command that
looks most like screen theft — both symptoms of matching text rather than
target.

The blunt escape hatch already exists: `HAUS_DESKTOP_OK=1`
(`desktop-guard.sh:44`) turns the *whole* guard off for a pane, which is the
wrong granularity for a lane that also touches the real Mac. The open decision
is the fine-grained one — exempt a command whose first effective word is an
`ssh` to a `192.168.64.0/24` guest — and it wants deciding before agents use
the VM routinely, because the guard is what protects the real screen.

### 3.5 Nothing tells an agent any of this

The whole capability is currently one row in holt's `ai/SKILL.md` ("stand
up/enter/tear down a lane's VM"), which says nothing about screenshots, about
`osascript` being the input path, or about the loop in §2. Per
[`agent-surface.md`](./agent-surface.md), the instruction belongs where the
*tool* is: the runtime verbs in holt's `ai/SKILL.md`, and the **recipe** —
boot, drive, capture, fetch, tear down — in haus's `ai` room skill, because the
image, the adapter and the desktop being tested are all haus's. The one-line
version every lane needs is: *if you want to see it, don't take the screen —
take a VM.*

## 4. The shape to aim at

```sh
holt runtime up   my-lane --backend tart      # clone golden image, boot headless
holt runtime enter my-lane --backend tart     # ssh in, or drive it from the host
holt runtime down my-lane --backend tart      # delete the clone
```

with a documented one-liner beside it for the half that is not holt's business:

```sh
ssh admin@$(tart ip holt-my-lane) '/usr/sbin/screencapture -x /tmp/s.png' \
  && scp admin@$(tart ip holt-my-lane):/tmp/s.png "$SCRATCHPAD/shot.png"
```

Whether that pair earns a `holt runtime shot` verb is a real question and the
answer is probably no: holt is a substrate, screenshots are a macOS detail, and
SPEC.md §5.5 already frames a runtime as three argv slots and nothing more.
A `haus vm` verb wrapping the same commands is the better home.
