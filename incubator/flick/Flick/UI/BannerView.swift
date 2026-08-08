import SwiftUI

/// The banner surface. Flat, quiet, nebelung-shaped: thin source accent,
/// small symbol, no sound, no bounce, eight points of motion at most —
/// and none at all under Reduce Motion.
///
/// A coalesced banner shows the newest thread-mate on its face and a count
/// of what folded in behind it; hovering deepens that count into an actual
/// list. Hover already pauses the dismiss clock, so the list stays up as
/// long as you are reading it, and the banner costs nothing extra when
/// you're not.
struct BannerView: View {
    let entry: BannerQueue.Entry
    var onHover: (Bool) -> Void
    var onDismiss: () -> Void
    var onActivate: () -> Void

    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @State private var arrived = false
    @State private var hovering = false

    private var event: NotificationEvent { entry.event }
    private var redacted: Bool { event.privacy == .redacted }

    /// The same arithmetic the compositor sized the panel with — never a
    /// measured height (`fittingSize` lags a state change by a turn on
    /// macOS 26, and the panel would settle on the wrong number).
    private var cardSize: CGSize {
        BannerGeometry.cardSize(foldedCount: entry.coalescedCount, expanded: entry.expanded)
    }

    private var urgencyAccent: Color {
        switch event.urgency {
        case .low: return .secondary
        case .normal: return .accentColor
        case .critical: return .red
        }
    }

    private var titleWeight: Font.Weight {
        event.urgency == .critical ? .bold : .semibold
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            face
            if entry.expanded {
                foldList
            }
        }
        .frame(width: cardSize.width, height: cardSize.height, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.separator, lineWidth: 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
        // The whole card is one click target, fold list included: clicking a
        // folded line runs the face event's default action, same as anywhere
        // else on the banner. A per-row target would be a second meaning for
        // the same gesture.
        .onTapGesture(perform: onActivate)
        .onHover { inside in
            hovering = inside
            onHover(inside)
        }
        .opacity(arrived ? 1 : 0)
        .offset(y: arrived || reduceMotion ? 0 : -8)
        .onAppear {
            withAnimation(reduceMotion ? nil : .easeOut(duration: 0.18)) {
                arrived = true
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityText)
    }

    /// The face: what a banner has always been. Its height is fixed whether
    /// or not the fold list is showing, so expanding never reflows the part
    /// you were already reading — and the bottom `BannerGeometry.overlap`
    /// points of it are padding the next card in the stack tucks over.
    private var face: some View {
        HStack(alignment: .top, spacing: 10) {
            // Thin source accent. Hex values stay in nebelung; until the
            // palette wiring lands this rides the system accent — except
            // urgency, which always wins so critical reads as critical.
            Capsule()
                .fill(urgencyAccent)
                .frame(width: 3)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(event.source)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    if entry.coalescedCount > 0 {
                        // Collapsed this is the whole receipt; expanded it is
                        // the label on the list underneath.
                        Text("+\(entry.coalescedCount) more")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                    // The banner body is the click target (`performDefault`
                    // runs the first action), so a single-action event needs
                    // to *say* what clicking does — otherwise the action is
                    // real but invisible. Rides the existing row rather than
                    // adding a button row: the banner's height is fixed.
                    if let action = event.actions.first, event.actions.count == 1 {
                        Text(action.label)
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.tint)
                            .lineLimit(1)
                            .padding(.horizontal, 5)
                            .padding(.vertical, 1)
                            .background(
                                Capsule().fill(Color.accentColor.opacity(0.14))
                            )
                    }
                    Spacer(minLength: 0)
                    if hovering {
                        Button(action: onDismiss) {
                            Image(systemName: "xmark")
                                .font(.system(size: 9, weight: .bold))
                        }
                        .buttonStyle(.plain)
                        .foregroundStyle(.secondary)
                        .accessibilityLabel("Dismiss")
                    }
                }

                Text(event.title)
                    .font(.title3.weight(titleWeight))
                    .lineLimit(1)

                if !redacted, let body = event.body ?? event.subtitle {
                    Text(body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            if let symbol = event.symbol {
                Image(systemName: symbol)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundStyle(urgencyAccent)
                    .frame(width: 22, height: 22)
                    .padding(.top, 2)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(
            width: BannerGeometry.size.width,
            height: BannerGeometry.size.height,
            alignment: .topLeading
        )
    }

    /// The fold, opened. One line per thread-mate, newest first, oldest
    /// collapsed into a single "and N earlier" — a burst of fifty is still a
    /// glance, not a scroll view. Row heights are fixed so the total matches
    /// `BannerGeometry.cardSize` exactly.
    private var foldList: some View {
        VStack(alignment: .leading, spacing: 0) {
            Divider()
                .padding(.bottom, 5)

            ForEach(Array(entry.folded.prefix(BannerGeometry.maxFoldRows).enumerated()), id: \.offset) { _, folded in
                HStack(spacing: 6) {
                    Text(folded.title)
                        .font(.caption)
                        .lineLimit(1)
                    if !redacted, let body = folded.body ?? folded.subtitle {
                        Text(body)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer(minLength: 0)
                }
                .frame(height: BannerGeometry.foldRowHeight)
            }

            if entry.coalescedCount > BannerGeometry.maxFoldRows {
                Text("and \(entry.coalescedCount - BannerGeometry.maxFoldRows) earlier")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .frame(height: BannerGeometry.foldRowHeight)
            }
        }
        .padding(.horizontal, 12)
        // Divider (1) + 5 above + 6 below == BannerGeometry.foldListInset,
        // and the 6 below is what the next card tucks over.
        .padding(.bottom, 6)
    }

    private var accessibilityText: String {
        let head = "\(event.source): \(event.title)"
        guard entry.coalescedCount > 0 else { return head }
        return "\(head), \(entry.coalescedCount) more in this thread"
    }
}
