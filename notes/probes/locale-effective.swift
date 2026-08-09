import Carbon.HIToolbox
import Foundation

// The locale/input-source counterpart of accessibility-effective.swift: what
// macOS *resolved*, not what the plist says. Every value below is read through
// Foundation/Carbon in a FRESH process, because a fresh process is the only
// reader that re-reads the domain — see --watch for why that matters.
//
//   swift locale-effective.swift              # one census line
//   swift locale-effective.swift --watch 14   # sample every 2s for 14s
//
// --watch exists to answer the question this group turns on: does an app that
// is ALREADY RUNNING notice a locale write? It samples both Locale flavours,
// because `autoupdatingCurrent` is the one documented to track changes and the
// answer is the same for both.

let args = Array(CommandLine.arguments.dropFirst())
var watchFor: Double = 0
if let i = args.firstIndex(of: "--watch"), i + 1 < args.count {
  watchFor = Double(args[i + 1]) ?? 0
}

func hourSkeleton(_ l: Locale) -> String {
  // "j" is ICU's hour-of-day skeleton: it renders "H"-ish where the locale is
  // 24-hour and "h a" where it is 12-hour, which is what
  // AppleICUForce24HourTime is supposed to move.
  DateFormatter.dateFormat(fromTemplate: "j", options: 0, locale: l) ?? "?"
}

func measurement(_ l: Locale) -> String { l.measurementSystem.identifier }

// AppleTemperatureUnit is a separate lever from the measurement system, and
// Foundation exposes it only through formatting: .naturalScale converts into
// whatever unit the resolved locale prefers.
func temperature(_ l: Locale) -> String {
  let mf = MeasurementFormatter()
  mf.locale = l
  mf.unitOptions = [.naturalScale]
  return mf.string(from: Measurement(value: 20, unit: UnitTemperature.celsius))
}

func tisID(_ s: TISInputSource) -> String {
  guard let r = TISGetInputSourceProperty(s, kTISPropertyInputSourceID)
  else { return "?" }
  return Unmanaged<CFString>.fromOpaque(r).takeUnretainedValue() as String
}

func census() -> String {
  let l = Locale.current
  let skel = hourSkeleton(l)
  var current = "?"
  if let cur = TISCopyCurrentKeyboardInputSource()?.takeRetainedValue() {
    current = tisID(cur)
  }
  // TISCreateInputSourceList(nil, false) = the ENABLED sources, i.e. the list
  // System Settings ▸ Keyboard ▸ Input Sources draws. Filtering to keyboard
  // layouts keeps the two always-present input methods out of the comparison.
  var enabled: [String] = []
  if let list = TISCreateInputSourceList(nil, false)?.takeRetainedValue()
    as? [TISInputSource]
  {
    enabled = list.map(tisID).filter { $0.hasPrefix("com.apple.keylayout.") }.sorted()
  }
  return "effective: locale=\(l.identifier) "
    + "languages=[\(Locale.preferredLanguages.joined(separator: ","))] "
    + "measurement=\(measurement(l)) temp=\(temperature(l)) "
    + "hourSkeleton=\(skel) force24=\(!skel.lowercased().contains("a")) "
    + "firstWeekday=\(Calendar.current.firstWeekday) "
    + "inputCurrent=\(current) "
    + "inputEnabled=[\(enabled.joined(separator: ","))]"
}

if watchFor <= 0 {
  Thread.sleep(forTimeInterval: 3.0)  // settle: let cfprefsd publish the write
  print(census())
  exit(0)
}

var t = 0.0
while t < watchFor {
  let a = Locale.autoupdatingCurrent, c = Locale.current
  print(
    "t=\(Int(t))s auto[hour=\(hourSkeleton(a)) unit=\(measurement(a))] "
      + "current[hour=\(hourSkeleton(c)) unit=\(measurement(c))]")
  fflush(stdout)
  Thread.sleep(forTimeInterval: 2.0)
  t += 2
}
