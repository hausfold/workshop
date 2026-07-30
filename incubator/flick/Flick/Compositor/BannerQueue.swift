import Foundation

/// Main-actor banner scheduling: what is visible, what waits, what coalesces.
/// The queue owns event state so panels stay disposable — a display topology
/// rebuild throws every panel away and redraws from here, losing nothing.
@MainActor
final class BannerQueue {
    struct Entry: Identifiable, Equatable {
        var event: NotificationEvent
        /// Number of additional thread-mates folded into this banner during
        /// a burst ("+3 more").
        var coalescedCount: Int = 0
        var id: String { event.id }
    }

    /// Redraw callback; the window system owns the panels.
    var onVisibleChanged: (([Entry]) -> Void)?

    private(set) var visible: [Entry] = []
    private var waiting: [Entry] = []
    private var capacity: Int
    private var paused = false
    private var dismissTimers: [String: Task<Void, Never>] = [:]

    private let displayDuration: Duration
    /// Thread-mates arriving within this window fold into the existing
    /// banner instead of stacking a new one.
    private let coalesceWindow: TimeInterval
    private var lastThreadArrival: [String: (id: String, at: Date)] = [:]

    init(capacity: Int = 3, displayDuration: Duration = .seconds(6), coalesceWindow: TimeInterval = 10) {
        self.capacity = max(0, capacity)
        self.displayDuration = displayDuration
        self.coalesceWindow = coalesceWindow
    }

    // MARK: - Intake

    func enqueue(_ event: NotificationEvent, now: Date = .now) {
        if let thread = event.thread,
           let last = lastThreadArrival[thread],
           now.timeIntervalSince(last.at) < coalesceWindow,
           coalesce(into: last.id, latest: event) {
            lastThreadArrival[thread] = (last.id, now)
            return
        }

        if let thread = event.thread {
            lastThreadArrival[thread] = (event.id, now)
        }

        let entry = Entry(event: event)
        if visible.count < capacity && !paused {
            show(entry)
        } else {
            waiting.append(entry)
        }
        notify()
    }

    /// Fold `latest` into an existing banner/queued entry for its thread.
    /// The newest content wins the face of the banner; the count says how
    /// much is behind it.
    private func coalesce(into id: String, latest: NotificationEvent) -> Bool {
        if let i = visible.firstIndex(where: { $0.id == id }) {
            visible[i].event.title = latest.title
            visible[i].event.body = latest.body
            visible[i].coalescedCount += 1
            armDismiss(for: visible[i].id) // fresh content, fresh clock
            notify()
            return true
        }
        if let i = waiting.firstIndex(where: { $0.id == id }) {
            waiting[i].event.title = latest.title
            waiting[i].event.body = latest.body
            waiting[i].coalescedCount += 1
            return true
        }
        return false
    }

    // MARK: - Lifecycle

    func dismiss(id: String) {
        dismissTimers.removeValue(forKey: id)?.cancel()
        visible.removeAll { $0.id == id }
        refill()
        notify()
    }

    func dismissAll() {
        dismissTimers.values.forEach { $0.cancel() }
        dismissTimers.removeAll()
        visible.removeAll()
        waiting.removeAll()
        notify()
    }

    /// Hover pause: while the pointer is over any banner, nothing auto-
    /// dismisses and nothing new rotates in under the cursor.
    func setPaused(_ pause: Bool) {
        guard paused != pause else { return }
        paused = pause
        if pause {
            dismissTimers.values.forEach { $0.cancel() }
            dismissTimers.removeAll()
        } else {
            visible.forEach { armDismiss(for: $0.id) }
            refill()
            notify()
        }
    }

    /// Display capacity changed (topology rebuild, smaller screen). Overflow
    /// slides back into the waiting line — events survive every rebuild.
    func setCapacity(_ newCapacity: Int) {
        capacity = max(0, newCapacity)
        while visible.count > capacity {
            let overflow = visible.removeLast()
            dismissTimers.removeValue(forKey: overflow.id)?.cancel()
            waiting.insert(overflow, at: 0)
        }
        refill()
        notify()
    }

    // MARK: - Internals

    private func show(_ entry: Entry) {
        visible.append(entry)
        armDismiss(for: entry.id)
    }

    private func refill() {
        while !paused, visible.count < capacity, !waiting.isEmpty {
            show(waiting.removeFirst())
        }
    }

    private func armDismiss(for id: String) {
        dismissTimers[id]?.cancel()
        guard !paused else { return }
        dismissTimers[id] = Task { [weak self, displayDuration] in
            try? await Task.sleep(for: displayDuration)
            guard !Task.isCancelled else { return }
            self?.dismiss(id: id)
        }
    }

    private func notify() {
        onVisibleChanged?(visible)
    }
}
