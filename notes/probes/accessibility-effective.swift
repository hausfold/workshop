import AppKit
import Foundation
// settle: let cfprefsd/UAServer propagate before sampling
Thread.sleep(forTimeInterval: 2.0)
let w = NSWorkspace.shared
print("effective: contrast=\(w.accessibilityDisplayShouldIncreaseContrast) transparency_reduced=\(w.accessibilityDisplayShouldReduceTransparency) motion_reduced=\(w.accessibilityDisplayShouldReduceMotion) diffWithoutColor=\(w.accessibilityDisplayShouldDifferentiateWithoutColor)")
