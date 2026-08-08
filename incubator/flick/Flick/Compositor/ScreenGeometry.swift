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

/// Where banners live and how they stack. Top-right, dealt downward like a
/// deck — clamped to the visible frame, deliberately *near* Apple's geometry
/// so muscle memory holds, without gluing to their exact metrics.
///
/// **Why a deck and not a list.** Distinct banners used to sit in separate
/// rects 8pt apart, which read as a form, not as a pile of things that
/// arrived. Each card now laps a few points *over* the card above it and
/// steps the same few points further left, and every panel casts a real
/// shadow — so a run of banners reads as one stack with depth. The z-order
/// comes free: panels are created newest-last and `orderFrontRegardless`
/// puts each new one in front, so a newer card (lower on screen) covers the
/// bottom edge of its elder — dealt, not shuffled. This is a deliberate
/// look, not an accident of spacing.
enum BannerGeometry {
    /// The card's full height *including* the strip its successor laps over
    /// — the reading area is `height - overlap`, which is the number that
    /// used to be the whole card. Grow both together or text starts clipping.
    static let size = CGSize(width: 360, height: 82)
    static let inset: CGFloat = 12

    /// How far each card laps over the one above it. Small on purpose: the
    /// covered strip is the elder card's bottom padding, and anything much
    /// larger starts eating a two-line body.
    static let overlap: CGFloat = 6

    /// Lateral step per card, each one deeper in the stack sitting further
    /// *left*. Leftward, not rightward: the stack is pinned `inset` from the
    /// right edge, so stepping right would walk off screen after two cards.
    static let step: CGFloat = 6

    // MARK: - Expanded folds

    /// A hovered banner with folded thread-mates grows a list of them (see
    /// `BannerView`). These metrics are the contract between that view and
    /// the panel that has to be resized around it: the height is *computed*,
    /// never measured, because `NSHostingView.fittingSize` is stale in the
    /// same turn as the state change that grows the view.
    static let foldRowHeight: CGFloat = 18
    /// Divider plus the padding above and below the list. The bottom share of
    /// it is at least `overlap`, so the card below still has only padding to
    /// tuck over once a fold is open.
    static let foldListInset: CGFloat = 12
    /// Folded events listed individually; the rest collapse into one
    /// "and N earlier" row.
    static let maxFoldRows = 4

    /// Folded events the expanded list names one by one.
    static func foldListedCount(folded: Int) -> Int {
        min(max(folded, 0), maxFoldRows)
    }

    /// Rows the expanded list draws for `folded` folded events — the listed
    /// ones plus, when there are more, the single "and N earlier" line. The
    /// view draws its rows off these two functions rather than repeating the
    /// arithmetic: the card's height is fixed, so a disagreement between the
    /// two would clip a row silently instead of failing.
    static func foldRowCount(folded: Int) -> Int {
        guard folded > 0 else { return 0 }
        return foldListedCount(folded: folded) + (folded > maxFoldRows ? 1 : 0)
    }

    /// Size of one card. Collapsed is always `size`; expanded adds exactly
    /// the fold list's rows, so the panel and the view agree on the number
    /// without either of them measuring anything.
    static func cardSize(foldedCount: Int, expanded: Bool) -> CGSize {
        let rows = expanded ? foldRowCount(folded: foldedCount) : 0
        guard rows > 0 else { return size }
        return CGSize(
            width: size.width,
            height: size.height + foldListInset + CGFloat(rows) * foldRowHeight
        )
    }

    // MARK: - Placement

    /// How many banners fit on this screen without escaping the visible
    /// frame. The queue holds anything beyond this — resize/topology changes
    /// shrink the visible set, never lose events. Counted for collapsed
    /// cards: expanding one is a hover-scoped event, and a card the expansion
    /// pushes off screen is dropped by the compositor and comes straight back
    /// on unhover.
    static func capacity(on screen: ScreenDescriptor, bannerSize: CGSize = size) -> Int {
        let usable = screen.visibleFrame.height - inset * 2
        guard usable >= bannerSize.height else { return 0 }
        let advance = max(1, bannerSize.height - overlap)
        return 1 + Int((usable - bannerSize.height) / advance)
    }

    /// Frames for a whole stack, index 0 topmost, in the same global
    /// coordinate space as the descriptor. Cards may differ in height (a
    /// hovered fold expands), so placement is cumulative rather than a closed
    /// form. A card that would escape the visible frame — and every card
    /// after it, since it only gets worse — comes back nil.
    static func stackFrames(on screen: ScreenDescriptor, sizes: [CGSize]) -> [CGRect?] {
        let visible = screen.visibleFrame
        var frames: [CGRect?] = []
        var top = visible.maxY - inset
        var escaped = false

        for (index, cardSize) in sizes.enumerated() {
            let x = visible.maxX - inset - cardSize.width - CGFloat(index) * step
            let frame = CGRect(
                origin: CGPoint(x: x, y: top - cardSize.height),
                size: cardSize
            )
            let fits = visible.contains(frame) || visible.intersection(frame) == frame
            escaped = escaped || !fits
            frames.append(escaped ? nil : frame)
            top -= cardSize.height - overlap
        }
        return frames
    }

    /// Frame for the banner at `index` (0 = topmost) in a stack of uniform
    /// cards. Returns nil when the slot would leave the visible frame.
    static func slotFrame(
        on screen: ScreenDescriptor,
        index: Int,
        bannerSize: CGSize = size
    ) -> CGRect? {
        guard index >= 0, index < capacity(on: screen, bannerSize: bannerSize) else { return nil }
        return stackFrames(
            on: screen,
            sizes: Array(repeating: bannerSize, count: index + 1)
        )[index]
    }
}
