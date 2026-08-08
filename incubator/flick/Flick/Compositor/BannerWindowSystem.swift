import AppKit

/// The compositor: consumes the queue's visible set and keeps exactly those
/// panels on screen. Rebuilds on every display-topology change (perch's
/// pattern); because event state lives in `BannerQueue`, a rebuild is pure
/// re-presentation — nothing queued or visible is ever lost to an unplugged
/// monitor.
@MainActor
final class BannerWindowSystem {
    private let queue: BannerQueue
    private let actionRouter: ActionRouter
    private var panels: [String: BannerPanelController] = [:]
    private var screenObserver: NSObjectProtocol?

    init(queue: BannerQueue, actionRouter: ActionRouter) {
        self.queue = queue
        self.actionRouter = actionRouter
        queue.onVisibleChanged = { [weak self] entries in
            self?.render(entries)
        }
    }

    func start() {
        syncCapacity()
        screenObserver = NotificationCenter.default.addObserver(
            forName: NSApplication.didChangeScreenParametersNotification,
            object: nil,
            queue: .main
        ) { _ in
            Task { @MainActor [weak self] in
                guard let self else { return }
                // Tear down and re-render from queue state on the new topology.
                self.panels.values.forEach { $0.close() }
                self.panels.removeAll()
                self.syncCapacity()
                self.render(self.queue.visible)
            }
        }
    }

    func stop() {
        if let screenObserver {
            NotificationCenter.default.removeObserver(screenObserver)
        }
        screenObserver = nil
        panels.values.forEach { $0.close() }
        panels.removeAll()
        queue.onVisibleChanged = nil
    }

    /// Banners live on the screen with the menu bar (`NSScreen.screens
    /// .first`), matching where the system draws its own. Per-display
    /// routing is a planned extension — the queue/panel split already
    /// supports it.
    private var targetScreen: ScreenDescriptor? {
        NSScreen.screens.first.map(ScreenDescriptor.init(screen:))
    }

    private static func frames(for entries: [BannerQueue.Entry], on screen: ScreenDescriptor) -> [CGRect?] {
        BannerGeometry.stackFrames(
            on: screen,
            sizes: entries.map {
                BannerGeometry.cardSize(foldedCount: $0.coalescedCount, expanded: $0.expanded)
            }
        )
    }

    private func syncCapacity() {
        let capacity = targetScreen.map { BannerGeometry.capacity(on: $0) } ?? 0
        queue.setCapacity(min(capacity, 3))
    }

    private func render(_ entries: [BannerQueue.Entry]) {
        guard let screen = targetScreen else {
            panels.values.forEach { $0.close() }
            panels.removeAll()
            return
        }

        // Close panels whose entries left the visible set.
        let liveIDs = Set(entries.map(\.id))
        for (id, panel) in panels where !liveIDs.contains(id) {
            panel.close()
            panels.removeValue(forKey: id)
        }

        // One layout pass for the whole stack: a hovered banner expands, and
        // every card under it has to move down by exactly that much. If the
        // expansion doesn't fit — a short display, a fold near the bottom of
        // the stack — the card stays collapsed rather than laying itself off
        // screen. Closing the panel under the pointer would strand the hover
        // (no exit event follows a panel that is simply gone) and pause the
        // queue for good; refusing to grow is the honest failure.
        var laidOut = entries
        var frames = Self.frames(for: laidOut, on: screen)
        if frames.contains(where: { $0 == nil }), let grown = laidOut.firstIndex(where: \.expanded) {
            laidOut[grown].expanded = false
            frames = Self.frames(for: laidOut, on: screen)
        }

        for (index, entry) in laidOut.enumerated() {
            guard let frame = frames[index] else {
                // An expanded fold can push the tail of the stack off screen.
                // Drop those panels — the entries stay in the queue, and the
                // next render (unhover, dismissal) puts them back.
                panels.removeValue(forKey: entry.id)?.close()
                continue
            }
            let hover: (Bool) -> Void = { [weak self] hovering in
                self?.queue.setHover(hovering, id: entry.id)
            }
            let dismiss: () -> Void = { [weak self] in
                self?.queue.dismiss(id: entry.id)
            }
            let activate: () -> Void = { [weak self] in
                self?.actionRouter.performDefault(for: entry.event)
                self?.queue.dismiss(id: entry.id)
            }
            if let existing = panels[entry.id] {
                existing.update(entry: entry, frame: frame, onHover: hover, onDismiss: dismiss, onActivate: activate)
            } else {
                panels[entry.id] = BannerPanelController(
                    entry: entry, frame: frame,
                    onHover: hover, onDismiss: dismiss, onActivate: activate
                )
            }
        }
    }
}

extension ScreenDescriptor {
    @MainActor
    init(screen: NSScreen) {
        let number = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")]
        self.init(
            id: (number as? NSNumber)?.stringValue ?? screen.localizedName,
            frame: screen.frame,
            visibleFrame: screen.visibleFrame
        )
    }
}
