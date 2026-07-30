import Foundation

/// Pure description of a display — the compositor's geometry consumes this,
/// never `NSScreen`, so placement is unit-testable without an attached
/// display (perch's `ScreenDescriptor` move).
struct ScreenDescriptor: Sendable, Equatable {
    var id: String
    /// Full screen bounds in global (bottom-left-origin) coordinates.
    var frame: CGRect
    /// Bounds minus menu bar / Dock — banners never overlap either.
    var visibleFrame: CGRect
}

/// Where banners live and how they stack. Top-right, stacking downward,
/// clamped to the visible frame — deliberately *near* Apple's geometry so
/// muscle memory holds, without gluing to their exact metrics.
enum BannerGeometry {
    static let size = CGSize(width: 360, height: 76)
    static let inset: CGFloat = 12
    static let spacing: CGFloat = 8

    /// How many banners fit on this screen without escaping the visible
    /// frame. The queue holds anything beyond this — resize/topology changes
    /// shrink the visible set, never lose events.
    static func capacity(on screen: ScreenDescriptor, bannerSize: CGSize = size) -> Int {
        let usable = screen.visibleFrame.height - inset * 2
        guard usable >= bannerSize.height else { return 0 }
        return 1 + Int((usable - bannerSize.height) / (bannerSize.height + spacing))
    }

    /// Frame for the banner at `index` (0 = topmost), in the same global
    /// coordinate space as the descriptor. Returns nil when the slot would
    /// leave the visible frame.
    static func slotFrame(
        on screen: ScreenDescriptor,
        index: Int,
        bannerSize: CGSize = size
    ) -> CGRect? {
        guard index >= 0, index < capacity(on: screen, bannerSize: bannerSize) else { return nil }
        let visible = screen.visibleFrame
        let x = visible.maxX - inset - bannerSize.width
        let top = visible.maxY - inset - CGFloat(index) * (bannerSize.height + spacing)
        let y = top - bannerSize.height
        let frame = CGRect(origin: CGPoint(x: x, y: y), size: bannerSize)
        return visible.contains(frame) || visible.intersection(frame) == frame ? frame : nil
    }
}
