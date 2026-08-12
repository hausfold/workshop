---
title: Troubleshooting
description: The handful of things that go sideways on macOS — a wedged agent, a missing grant, a stubborn cask — and the exact command to unstick each one.
---

Most nebelhaus trouble is one of a few known macOS quirks with a known fix. Work
top-down; `haus doctor` is a good first stop for any of them.

```sh
haus doctor    # Nix, the Xcode CLT, the GUI agents, and cask drift, in one shot
```

## ⌘Space / Pounce does nothing

The launcher is a launchd **user agent**. If it isn't answering:

```sh
# Is it running?
launchctl list | grep pounce

# Bounce it (the clean recover for any wedged user agent):
launchctl bootout gui/$(id -u)/org.nixos.pounce 2>/dev/null
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.nixos.pounce.plist
```

If it opens but **clipboard/emoji paste** don't work, it's missing the
Accessibility grant:

```sh
pounce --request-accessibility   # approve the system dialog
pounce --check-accessibility     # prints true when granted
```

Set `haus.pounce.signingIdentity` so this grant survives rebuilds — see
[Pounce config](/reference/pounce/). If ⌘Space still opens **Spotlight**, log
out and back in once so the symbolic-hotkey reassignment takes.

**Palette opens, but slowly?** An external hotkey tool — skhd, AeroSpace, Raycast —
bound to the same key grabs it with an event tap *ahead* of pounce, so every summon
spawns a fresh client instead of hitting the daemon's fast in-process path.
Registration still reports success and the palette still opens, which is what makes
this one so hard to spot. One command names the culprit:

```sh
pounce doctor
```

It combines the daemon's live hotkey self-report with outside-in probes — a macOS
system-shortcut clash, running external hotkey daemons, and their configs scanned
for a binding on pounce's key — and tells you what to unbind.

## Windows won't tile / AeroSpace isn't running

This is almost always the **cold-boot GUI race**: an agent launched before the
desktop session was ready parked itself (exit 78) instead of starting. The rice
guards against it, but if you land in this state, bounce the agent:

```sh
launchctl bootout gui/$(id -u)/org.nixos.aerospace 2>/dev/null
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.nixos.aerospace.plist
```

Other quick fixes:

- **Windows scrambled after sleep?** They self-heal after a couple seconds; force
  it by tapping ⇪, then `Backtick`.
- **A binding you changed didn't take?** A rebuild rewrites the config but the
  live daemon caches the old one — normally auto-reloaded, but you can force it:
  `aerospace reload-config`.
- **A window landed on the wrong workspace?** Tap ⇪, then `Backtick` to re-sort
  everything to its roster home.

## The bar (SketchyBar) is blank or missing

```sh
launchctl bootout gui/$(id -u)/org.nixos.sketchybar 2>/dev/null
launchctl bootstrap gui/$(id -u) ~/Library/LaunchAgents/org.nixos.sketchybar.plist
```

**Running, but stale?** A pill you added isn't there, or a colour change didn't
land. A rebuild rewrites the bar's config but the live bar read it once at boot —
normally auto-reloaded, but you can force it:

```sh
sketchybar  --reload ~/.config/sketchybar/sketchybarrc    # the menu-bar bar
sill-bottom --reload ~/.config/sketchybar/sill-bottomrc   # the bottom bar, if
                                                          # haus.sill.bottom.enable is on
```

Two things to get right there, and they bite independently:

- **Each bar takes its own reload.** They're separate instances under separate
  names, so a lone `sketchybar --reload` leaves the bottom bar exactly as it was.
- **Always name the rc.** `--reload` on its own doesn't mean "re-read your
  config", it means *"re-run the path you resolved at startup"* — and that path
  is a symlink into `/nix/store`, resolved once. So a bare reload can keep
  replaying the config from the generation the bar booted on, while exiting 0 and
  logging `configuration loaded..`. The bottom bar is the one this actually bites
  (it's the one launched with `--config`); naming the path re-resolves the
  symlink now.

Easier: run **Reload SketchyBar** from the ⌘Space palette, or the same row in the
logo pill's dropdown. Both do both bars, both name the rc.

If you'd rather not run a custom bar at all, set `haus.sill.enable = false`
and the native macOS menu bar comes back.

## After a macOS upgrade, *all* my agents are dead (macOS 26 Tahoe+)

If the bar, tiling, and ⌘Space all come up dead at once right after upgrading to
**macOS 26 Tahoe or later**, the culprit is usually **Background Task Management
(BTM)**. Tahoe gates login items whose executable isn't Apple-signed, and every
nix agent launches through `/bin/sh -c "…"` — which BTM files under "unidentified
developer" and can silently refuse to start. The agents register fine; they just
never run. `haus doctor` flags this on Tahoe+; confirm and get the fix with:

```sh
haus btm     # no-op before Tahoe; on Tahoe+ it reads the BTM store and instructs
```

There's **no declarative fix** — the toggle lives in macOS's BTM store, which has
no CLI to set it (`sfltool` can only dump it). So it's a one-time manual step:

1. **System Settings → General → Login Items & Extensions**
2. Scroll to **"Allow in the Background"**
3. Find the entries named **`sh`** — subtitle *"Item from unidentified developer"*
4. Toggle them **on**, then reboot
   *(already on but still blocked? flip off then on to force a database write)*

Inspect the store by hand any time with:

```sh
sudo sfltool dumpbtm | grep -B2 -A8 -iE "nixos|darwin-store"   # look for "disallowed"
```

## Touch ID for sudo beachballs (inside tmux/zellij)

If the Touch ID prompt hangs when you `sudo` inside a multiplexer, the
`pam_reattach` shim isn't loading. It ships with the **collar** room and is on by
default; confirm the order in `/etc/pam.d/sudo_local` (reattach must come *before*
the Touch ID line). Outside a multiplexer, Touch ID should just work; cancel the
prompt to fall back to your password.

## "Refusing to load cask … from an untrusted tap"

Third-party taps fail Homebrew's trust check under sudo-driven activation. The
rice disables that requirement globally (`HOMEBREW_NO_REQUIRE_TAP_TRUST=1` in
`/etc/homebrew/brew.env`). If you see this, that file didn't land — re-run
`haus rebuild`, or set the variable in your shell for the one-off.

## An app I removed from my config is still installed

By design. `haus.homebrew.cleanup` defaults to `"none"`, so nothing you
installed is ever auto-deleted, and **`haus rollback` doesn't rewind Homebrew
apps** (they're not in Nix generations). Remove one by hand:

```sh
brew uninstall --zap <cask>
```

Want a fully declarative machine where undeclared casks get removed on rebuild?
Set `haus.homebrew.cleanup = "zap";` — see
[Making it yours](/guides/making-it-yours/#homebrew-behaviour).

## A rebuild broke something — get back fast

```sh
haus rollback       # atomically return to the previous generation
haus generations    # see what you can roll back to
```

`haus rebuild` always builds *before* switching, so a config with an error can't
activate — you just see the build fail. For macOS **settings** (not packages),
the APFS/Time-Machine snapshot the installer took is the coarser rewind.

Want to go further than one generation — disable a room, or remove nebelhaus
entirely? [Leaving nebelhaus](/guides/leaving/) walks each exit, smallest first.

## The installer refuses to run — "expects Determinate Nix"

nebelhaus is built on [Determinate Nix](https://docs.determinate.systems/) and
won't install on top of a stock/single-user Nix rather than risk breaking it. If
you have an existing Nix you don't need, uninstall it and re-run the one-liner;
if you want to keep it, migrating to Determinate is the supported path. Fresh
Macs need none of this — the bootstrap installs Determinate for you.

## Still stuck?

- [Keybindings cheatsheet](/reference/keybindings/) — or tap `⇪` then `/` for the
  live, roster-aware version.
- [haus.* options](/reference/options/) — every knob and its default.
- [Open an issue](https://github.com/hausfold/haus/issues) with the output
  of `haus doctor`.
