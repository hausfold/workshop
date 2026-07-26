# macOS capability probes

Re-runnable evidence for [`../macos-settings-matrix.md`](../macos-settings-matrix.md).
The matrix is one macOS release away from being wrong — rerun these on every bump.

```sh
swift notes/probes/accessibility-effective.swift   # effective a11y state (NSWorkspace)
swift notes/probes/displays.swift                  # displays, persistent UUIDs, HiDPI modes
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
