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
