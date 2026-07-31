import AppKit
import ServiceManagement
import UserNotifications
import os.log

/// Every supported hook into Apple's own notification machinery lives here,
/// so the honest boundary is one file wide:
///
///   - login-item registration via `SMAppService` (the supported way to be
///     a resident daemon the user can see and revoke in System Settings);
///   - deep links into System Settings → Notifications, where the user
///     turns Apple's banners off per-app when flick takes over rendering —
///     there is no public API that does that for them;
///   - flick's *own* `UNUserNotificationCenter` registration, used as a
///     diagnostics fallback ("post one through Apple") so side-by-side
///     comparison during onboarding is one click.
///
/// What is deliberately NOT here: any attempt to suppress or intercept other
/// apps' banners programmatically. Suppression is Focus + per-app settings
/// (the Hush lane in the rice); capture is System Mirror's quarantined job.
@MainActor
enum SystemIntegration {
    private static let log = Logger(subsystem: "com.nebelhaus.flick", category: "system")

    // MARK: - Login item

    static func registerAsLoginItem() {
        do {
            try SMAppService.mainApp.register()
        } catch {
            // Already registered or user-denied: both fine, both visible in
            // System Settings > General > Login Items.
            log.info("login item registration: \(error.localizedDescription, privacy: .public)")
        }
    }

    static func unregisterLoginItem() {
        try? SMAppService.mainApp.unregister()
    }

    static var loginItemStatus: SMAppService.Status {
        SMAppService.mainApp.status
    }

    // MARK: - System Settings deep links

    /// System Settings → Notifications (the whole pane).
    static func openNotificationSettings() {
        open("x-apple.systempreferences:com.apple.Notifications-Settings.extension")
    }

    /// System Settings → Notifications, ideally focused on one app. The
    /// per-app anchor is best-effort — macOS versions differ — the pane
    /// itself always opens.
    static func openNotificationSettings(for bundleID: String) {
        open("x-apple.systempreferences:com.apple.Notifications-Settings.extension?id=\(bundleID)")
    }

    /// System Settings → Focus, for wiring the Hush-backed replacement mode.
    static func openFocusSettings() {
        open("x-apple.systempreferences:com.apple.Focus-Settings.extension")
    }

    /// System Settings → Privacy & Security → Full Disk Access.
    static func openFullDiskAccessSettings() {
        open("x-apple.systempreferences:com.apple.settings.PrivacySecurity.extension?Privacy_AllFiles")
    }

    // MARK: - Onboarding assistant

    /// Self-relaunch, e.g. right after a TCC entitlement change like Full
    /// Disk Access — cleaner than waiting on the user to notice Apple's own
    /// "Quit & Reopen" prompt.
    static func relaunch() {
        let url = Bundle.main.bundleURL
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = true
        NSWorkspace.shared.openApplication(at: url, configuration: configuration) { _, _ in
            exit(0)
        }
    }

    /// Opens the Full Disk Access pane and floats a non-activating helper
    /// panel alongside it. `onGrantConfirmed` commits the setting (through
    /// `AppSettings`, so it's flushed to disk) before `onDismiss` reopens
    /// Settings — the panel itself never touches `UserDefaults` directly.
    static func presentFullDiskAccessAssistant(
        onGrantConfirmed: @escaping () -> Void,
        onDismiss: (() -> Void)? = nil
    ) {
        openFullDiskAccessSettings()
        OnboardingAssistantPanelController.shared.present(
            mode: .fullDiskAccess,
            onGrantConfirmed: onGrantConfirmed,
            onDismiss: onDismiss
        )
    }

    /// Launch the app-migration assistant for a given app (turn Apple's
    /// native banners off for it once flick is rendering them instead).
    static func presentAppMigrationAssistant(for bundleID: String, appName: String, onDismiss: (() -> Void)? = nil) {
        openNotificationSettings(for: bundleID)
        OnboardingAssistantPanelController.shared.present(
            mode: .appMigration(bundleID: bundleID, appName: appName),
            onDismiss: onDismiss
        )
    }

    private static func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    // MARK: - Own UN registration (diagnostics)

    static func requestOwnNotificationAuthorization() async -> Bool {
        let center = UNUserNotificationCenter.current()
        return (try? await center.requestAuthorization(options: [.alert])) ?? false
    }

    /// Post an event through Apple's pipeline instead of flick's — used by
    /// onboarding/diagnostics to compare the two renderings side by side.
    static func postThroughApple(_ event: NotificationEvent) async {
        let content = UNMutableNotificationContent()
        content.title = event.title
        if let subtitle = event.subtitle { content.subtitle = subtitle }
        if let body = event.body { content.body = body }
        // No .sound, ever.
        let request = UNNotificationRequest(
            identifier: event.id, content: content, trigger: nil
        )
        try? await UNUserNotificationCenter.current().add(request)
    }
}
