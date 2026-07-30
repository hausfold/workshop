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

        for (index, entry) in entries.enumerated() {
            guard let frame = BannerGeometry.slotFrame(on: screen, index: index) else { continue }
            let hover: (Bool) -> Void = { [weak self] hovering in
                self?.queue.setPaused(hovering)
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
