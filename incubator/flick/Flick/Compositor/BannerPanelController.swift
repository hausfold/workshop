import AppKit
import SwiftUI

/// One borderless, non-activating panel per visible banner. Panels join all
/// Spaces and float over fullscreen apps; they never take key focus, so a
/// banner can never steal a keystroke from whatever you're typing into.
@MainActor
final class BannerPanelController {
    let entryID: String
    private let panel: NSPanel

    init(
        entry: BannerQueue.Entry,
        frame: CGRect,
        onHover: @escaping (Bool) -> Void,
        onDismiss: @escaping () -> Void,
        onActivate: @escaping () -> Void
    ) {
        entryID = entry.id

        panel = NSPanel(
            contentRect: frame,
            styleMask: [.borderless, .nonactivatingPanel],
            backing: .buffered,
            defer: false
        )
        panel.level = .statusBar
        panel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        panel.isOpaque = false
        panel.backgroundColor = .clear
        panel.hasShadow = false // the view draws its own quiet edge instead
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.isMovable = false
        panel.animationBehavior = .none // motion is the view's job, and it is small

        let view = BannerView(
            entry: entry,
            onHover: onHover,
            onDismiss: onDismiss,
            onActivate: onActivate
        )
        panel.contentView = NSHostingView(rootView: view)
        panel.orderFrontRegardless()
    }

    func update(entry: BannerQueue.Entry, frame: CGRect, onHover: @escaping (Bool) -> Void, onDismiss: @escaping () -> Void, onActivate: @escaping () -> Void) {
        panel.setFrame(frame, display: true)
        panel.contentView = NSHostingView(rootView: BannerView(
            entry: entry,
            onHover: onHover,
            onDismiss: onDismiss,
            onActivate: onActivate
        ))
    }

    func close() {
        panel.orderOut(nil)
    }
}
