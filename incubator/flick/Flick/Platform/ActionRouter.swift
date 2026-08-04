import AppKit
import os.log

/// Delegates actions back to the world: open the source app, open a URL.
/// Capability-gated — the router only ever performs actions the event
/// actually carries, and unknown targets fail quietly into the log, never
/// into a dialog.
@MainActor
final class ActionRouter {
    private static let log = Logger(subsystem: "com.nebelhaus.flick", category: "actions")

    /// The bundle ids flick is meant to keep macOS quiet for — the sources
    /// the current `rules.json` names. Injected because the router must never
    /// fall back to "every app on this Mac": see `silenceNative` below.
    private let listedApps: () -> [String]

    init(listedApps: @escaping () -> [String] = { [] }) {
        self.listedApps = listedApps
    }

    /// Click on the banner body: first declared action wins, falling back to
    /// activating the source app when the event's source looks like a
    /// bundle id.
    func performDefault(for event: NotificationEvent) {
        if let action = event.actions.first {
            perform(action, for: event)
        } else if event.source.contains(".") {
            openApp(bundleID: event.source)
        }
    }

    func perform(_ action: NotificationEvent.Action, for event: NotificationEvent) {
        switch action.kind {
        case .openApp:
            openApp(bundleID: action.target ?? event.source)
        case .openURL:
            guard let target = action.target,
                  let url = URL(string: target),
                  ["https", "http", "file"].contains(url.scheme?.lowercased() ?? "")
            else {
                Self.log.info("refused non-web/file URL action for \(event.id, privacy: .public)")
                return
            }
            NSWorkspace.shared.open(url)
        case .command:
            // User-declared hooks arrive with the rules engine work
            // (PRD milestone 2); until then the action is inert.
            Self.log.info("command hooks not yet enabled (\(event.id, privacy: .public))")
        case .silenceNative:
            // The target names the apps this banner was about — one id, or the
            // whole worklist the collapsed summary counted. A target-less
            // event (hand-authored, or from an older flick) falls back to the
            // apps `rules.json` lists, never to every app on the Mac: flick
            // asks people to silence what it's been told to redraw, not to
            // switch macOS's notifications off wholesale.
            let scope = NotificationSettingsAudit.scope(forActionTarget: action.target)
                ?? .only(listedApps())
            // Re-running the audit rather than trusting the event's payload
            // keeps the window honest about *now* — the user may have fixed
            // one of them while the banner sat on screen.
            let findings = NotificationSettingsAudit.findings(scope: scope)
            guard !findings.isEmpty else {
                Self.log.info("silence action for \(event.id, privacy: .public): nothing left to silence")
                return
            }
            SystemIntegration.presentNativeBannerAssistant(findings: findings)
        }
    }

    private func openApp(bundleID: String) {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) else {
            Self.log.info("no app for bundle id \(bundleID, privacy: .public)")
            return
        }
        NSWorkspace.shared.openApplication(at: url, configuration: .init())
    }
}
