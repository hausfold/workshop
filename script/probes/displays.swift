import CoreGraphics
import ColorSync
import Foundation

var count: UInt32 = 0
CGGetActiveDisplayList(0, nil, &count)
var ids = [CGDirectDisplayID](repeating: 0, count: Int(count))
CGGetActiveDisplayList(count, &ids, &count)
print("active displays: \(count)")
for id in ids {
    let uuidRef = CGDisplayCreateUUIDFromDisplayID(id)?.takeRetainedValue()
    let uuid = uuidRef.map { CFUUIDCreateString(nil, $0) as String } ?? "nil"
    print("\n— display id=\(id) builtin=\(CGDisplayIsBuiltin(id) == 1) main=\(CGDisplayIsMain(id) == 1)")
    print("  persistent UUID: \(uuid)")
    let cur = CGDisplayCopyDisplayMode(id)
    if let m = cur {
        print("  current: \(m.width)x\(m.height) px  points=\(m.pixelWidth)x\(m.pixelHeight) refresh=\(m.refreshRate)")
    }
    let opts = [kCGDisplayShowDuplicateLowResolutionModes: kCFBooleanTrue] as CFDictionary
    guard let modes = CGDisplayCopyAllDisplayModes(id, opts) as? [CGDisplayMode] else { continue }
    // HiDPI ("looks like") modes: pixel dims are 2x the point dims
    let hidpi = modes.filter { $0.pixelWidth > $0.width }
    print("  total modes=\(modes.count)  HiDPI modes=\(hidpi.count)")
    for m in hidpi.sorted(by: { $0.width > $1.width }) {
        print("    looks-like \(m.width)x\(m.height)  (native \(m.pixelWidth)x\(m.pixelHeight))")
    }
}
