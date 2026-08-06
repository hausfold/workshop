# Capability probes

Re-runnable evidence for [`../macos-settings-matrix.md`](../macos-settings-matrix.md).
The matrix is one macOS release away from being wrong — rerun these on every bump.
(Two probes here aren't about macOS at all — `pack-priority.nix` and
`preset-composition.nix`, at the bottom — but they earn the same shelf: a claim
in a notes file, with the command that proves it beside it.)

```sh
swift notes/probes/accessibility-effective.swift   # effective a11y state (NSWorkspace)
swift notes/probes/displays.swift                  # displays, persistent UUIDs, HiDPI modes
./notes/probes/ncprefs-flags.sh                    # per-app notification switches
```

`accessibility-effective.swift` reports what macOS *actually* honours, not what
the plist says. That distinction is the whole point: on 26.6, writing
`com.apple.Accessibility` changes the plist and nothing else.

## The open question — `universalaccess-fda-test.sh`

**Run this from a terminal that holds Full Disk Access.** It's the one thing the
matrix can't settle on its own: whether `com.apple.universalaccess` writes work
when the invoking app has FDA.

```sh
./notes/probes/universalaccess-fda-test.sh
```

It answers **two** questions, because they're not the same — `com.apple.Accessibility`
already demonstrated that a write can succeed and still change nothing:

1. does the write **succeed**?
2. does the value **take effect**?

Only "yes" to both makes nix-darwin's five `system.defaults.universalaccess.*`
options real on macOS 26. The script prints a verdict saying which doc lines to
update either way.

Safe by construction: snapshots the domain, restores on exit via a trap (even on
Ctrl-C), and refuses to run at all — before touching anything — from a terminal
without FDA, since that can only reproduce the original refusal.

To grant FDA: System Settings ▸ Privacy & Security ▸ Full Disk Access ▸ (+), add
the terminal, then fully quit and reopen it. On macOS 26 a *stale* grant often
has to be removed and re-added with (+) before it takes.

## `ncprefs-flags.sh` — where the notification switches really live

Settled on 26.6, 2026-08-01, by holding one app's switches in a known state and
diffing — not by trusting the flag tables in circulation, all of which point at
the wrong file now.

The per-app switches in System Settings ▸ Notifications live in
`group.com.apple.usernoted`'s container prefs. **`com.apple.ncprefs` is a stale
mirror**: it still has an `apps` array with plausible `flags`, and on this
machine it sat unchanged for two weeks while the real settings moved. `--legacy`
prints the drift (9 apps disagreed the day this was written, including the one
under test). Anything built on ncprefs reports confidently wrong state.

Three bits matter, all verified against the live UI:

| bit | mask | switch |
|---|---|---|
| 3 | `0x8` | **Desktop**, Temporary style — a banner |
| 4 | `0x10` | **Desktop**, Persistent style — an alert |
| 2 | `0x4` | **Play sound for notification** |

Bits 3 and 4 are one control in two styles, and this table said only bit 3
until 2026-08-04, which reports every Persistent app as quiet while macOS is
still drawing alerts for it. Corrected against live data: no app in a 108-app
store carries both bits, and unticking Desktop on a Persistent app clears bit
4 (Reminders, `9437708310` → `9437708358`, watched as the switch moved).
**Desktop is on when either bit is set.**

All three clear = silent, drawing nothing, still reaching Notification Center. That
is the end state to steer an app to when something else is rendering its
banners; turning *Allow notifications* off instead would stop the events
reaching the store at all.

The container is TCC-protected, so this needs **Full Disk Access** — and a
terminal that already holds FDA reads it without complaint while telling you
nothing about an un-granted process. `--tcc` makes that distinction explicit.
Any checker built on this has three verdicts, not two: noisy, quiet, and
*can't tell* — and "can't tell" must never render as "all clear".

macOS 26 also retired the old alert-style radio. There is no "Banners"
checkbox to uncheck any more: it's the **Desktop** checkbox plus an
Alert Style Temporary/Persistent pair.

## `accessibility-sweep.sh`

The follow-up to the settled question. `universalaccess-fda-test.sh` proved the
*mechanism* on one key; this fills in the rest of the family, including the two
that aren't typed by nix-darwin and are the point of the exercise:

- **`increaseContrast`** — the high-contrast lever
- **`FontSizeCategory`** — macOS 26's per-app text size ("larger text")

```sh
./notes/probes/accessibility-sweep.sh   # from an FDA terminal
```

It separates keys with an `NSWorkspace` oracle (definitive: writes *and* takes
effect) from keys with none (persistence only — it pauses ~10s so you can look).
That split is deliberate: "the write succeeded" was never sufficient evidence
here, since `com.apple.Accessibility` writes succeed and change nothing.

## `pack-priority.nix` — the one probe that isn't about macOS

Evidence for [`../options-roadmap.md`](../options-roadmap.md) §6's limit 3
instead of the matrix: what a shared **pack** must ship so a consumer's own host
wins, rather than colliding with it.

```sh
nix-instantiate --eval --strict --json notes/probes/pack-priority.nix
nix-instantiate --eval --strict --json notes/probes/pack-priority.nix \
  --arg rice ~/code/workshop/nebelhaus      # from a workshop worktree
```

No machine, no darwin system, no build — it evaluates the rice's pure-lib option
surface with the real `packs/writing.nix` and a fake host, in seconds. It is
here because it belongs to the same family as the rest: **the obvious answer is
the one that fails silently.** `mkDefault` on the whole `roster` attrset looks
like the cheap version and drops three of the pack's four apps without an error;
only per-leaf priority does what the roadmap wanted. Six compositions, verdicts
in the file header.

## `preset-composition.nix` — the other half of the same question

What happens when two whole **rices** meet, rather than a pack and a host.
`lib.pack` fixed host-vs-pack; this measures the case the roadmap left open and
the one a gallery produces.

```sh
nix-instantiate --eval --strict --json notes/probes/preset-composition.nix \
  --arg rice ~/code/workshop/nebelhaus
```

All six pairs of the four shipped presets, both escape hatches, and two candidate
seams. Same family lesson as the rest of this shelf, twice: **the assumption
nobody ran was wrong** (overlap isn't collision, and the conflict error names
both files), and **the quiet outcome is the dangerous one** — two rices' list
options merge with no error at all, so a pair that "composes" may just be one
that blends.

✅ **The pinnable subset of this moves into the rice** as `nix flake check`'s
`preset-composition` (rice#239, open when this was written), so the pairs the
docs advertise as stackable can't quietly stop stacking. The probe stays for the questions a golden table
can't ask — it prints resolved values and the `compose []` ordering experiment,
which is what you want the first time, not the hundredth.
