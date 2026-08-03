import AppKit
import os.log

/// Delegates actions back to the world: open the source app, open a URL.
/// Capability-gated — the router only ever performs actions the event
/// actually carries, and unknown targets fail quietly into the log, never
/// into a dialog.
@MainActor
final class ActionRouter {
    private static let log = Logger(subsystem: "com.nebelhaus.flick", category: "actions")

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
            // A bundle id walks that one app; no target means "everything the
            // audit just flagged", which is what the collapsed summary banner
            // sends. Re-running the audit here rather than trusting the
            // event's payload keeps the window honest about *now* — the user
            // may have fixed one of them while the banner sat on screen.
            let scope: NotificationSettingsAudit.Scope =
                action.target.map { .only([$0]) } ?? .everything
            SystemIntegration.presentNativeBannerAssistant(
                findings: NotificationSettingsAudit.findings(scope: scope)
            )
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
