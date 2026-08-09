import Carbon.HIToolbox
import Foundation

// Enable / disable ONE keyboard input source through the documented Text Input
// Sources API, so locale-sweep.sh can compare the API path against a raw
// `defaults write com.apple.HIToolbox`.
//
// It never touches the SELECTED source — only membership of the enabled list —
// so the worst case is an extra layout in the input menu until it is disabled
// again. `TISSelectInputSource` is deliberately not wired here.
//
//   swift tis-toggle.swift list
//   swift tis-toggle.swift enable  com.apple.keylayout.French
//   swift tis-toggle.swift disable com.apple.keylayout.French

func id(_ s: TISInputSource) -> String {
  guard let r = TISGetInputSourceProperty(s, kTISPropertyInputSourceID)
  else { return "?" }
  return Unmanaged<CFString>.fromOpaque(r).takeUnretainedValue() as String
}

func sources(includeDisabled: Bool) -> [TISInputSource] {
  TISCreateInputSourceList(nil, includeDisabled)?.takeRetainedValue()
    as? [TISInputSource] ?? []
}

let args = Array(CommandLine.arguments.dropFirst())
guard let verb = args.first else {
  print("usage: tis-toggle.swift list | enable <id> | disable <id>")
  exit(2)
}

if verb == "list" {
  print(sources(includeDisabled: false).map(id).sorted().joined(separator: "\n"))
  exit(0)
}

guard args.count == 2 else {
  print("usage: tis-toggle.swift \(verb) <input-source-id>")
  exit(2)
}
let want = args[1]
guard let src = sources(includeDisabled: true).first(where: { id($0) == want }) else {
  print("✗ no such input source: \(want)")
  exit(1)
}

let status: OSStatus = verb == "enable"
  ? TISEnableInputSource(src)
  : TISDisableInputSource(src)

if status == noErr {
  print("✓ \(verb)d \(want)")
} else {
  print("✗ \(verb) failed for \(want) — OSStatus \(status)")
  exit(1)
}
