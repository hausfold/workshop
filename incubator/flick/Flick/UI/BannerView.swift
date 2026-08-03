import SwiftUI

/// The banner surface. Flat, quiet, nebelung-shaped: thin source accent,
/// small symbol, no sound, no bounce, eight points of motion at most —
/// and none at all under Reduce Motion.
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

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            // Thin source accent. Hex values stay in nebelung; until the
            // palette wiring lands this rides the system accent.
            Capsule()
                .fill(Color.accentColor)
                .frame(width: 3)
                .padding(.vertical, 2)

            VStack(alignment: .leading, spacing: 2) {
                HStack(spacing: 6) {
                    Text(event.source)
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    if entry.coalescedCount > 0 {
                        Text("+\(entry.coalescedCount) more")
                            .font(.caption2)
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
                    .font(.callout.weight(.semibold))
                    .lineLimit(1)

                if !redacted, let body = event.body ?? event.subtitle {
                    Text(body)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
            }

            Image(systemName: event.symbol ?? "circle.fill")
                .font(.system(size: 16, weight: .regular))
                .foregroundStyle(.secondary)
                .frame(width: 22, height: 22)
                .padding(.top, 2)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(
            width: BannerGeometry.size.width,
            height: BannerGeometry.size.height,
            alignment: .topLeading
        )
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.regularMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .strokeBorder(.separator, lineWidth: 1)
                )
        )
        .contentShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
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
        .accessibilityLabel("\(event.source): \(event.title)")
    }
}
