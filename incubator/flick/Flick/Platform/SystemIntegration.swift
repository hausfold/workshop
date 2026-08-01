import AppKit
import Security
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

    /// Opens the Full Disk Access pane and floats a non-activating helper
    /// panel alongside it. Access is picked up live without quitting or
    /// relaunching the app. `onGrantConfirmed` commits the setting
    /// (through `AppSettings`, so it's flushed to disk) before `onDismiss`
    /// reopens Settings — the panel itself never touches `UserDefaults` directly.
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

    /// Every deep link above lands in this one app.
    private static let systemSettingsBundleID = "com.apple.systempreferences"

    private static var raiseTask: Task<Void, Never>?

    private static func open(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        // The deprecated `open(_:)` never asks for activation, so System
        // Settings came up *behind* whatever the user was looking at. The
        // configuration variant asks; `raiseSystemSettings` insists.
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.activates = true
        NSWorkspace.shared.open(url, configuration: configuration) { _, _ in
            Task { @MainActor in raiseSystemSettings() }
        }
        raiseSystemSettings()
    }

    /// Bring System Settings to the front, and keep asking for a beat.
    ///
    /// One activation request is not enough here for two independent
    /// reasons: on a cold launch the process exists before its window does
    /// (activating a windowless app is a no-op), and under a tiling window
    /// manager like AeroSpace the WM re-asserts its own focus right after
    /// the app appears. So poll until it actually reports active, then stop
    /// — never longer, or we'd yank focus back from a user who moved on.
    private static func raiseSystemSettings() {
        raiseTask?.cancel()
        raiseTask = Task { @MainActor in
            for attempt in 0..<12 {
                if attempt > 0 {
                    try? await Task.sleep(nanoseconds: 250_000_000)
                }
                if Task.isCancelled { return }
                guard let app = NSRunningApplication.runningApplications(
                    withBundleIdentifier: systemSettingsBundleID
                ).first else { continue }
                if app.isActive && attempt > 0 { return }
                app.unhide()
                app.activate(options: [.activateAllWindows])
            }
        }
    }

    // MARK: - Signing identity (why a grant does or doesn't persist)

    /// The Team ID this build is signed with, or nil when it's ad-hoc /
    /// unsigned.
    ///
    /// This is load-bearing for the Full Disk Access flow, not trivia.
    /// macOS stores a TCC grant against the app's *designated requirement*.
    /// Signed with a Developer ID, that requirement names the team, so the
    /// grant survives every rebuild. Ad-hoc, it names the binary's cdhash —
    /// which changes on every single build — so macOS quietly revokes the
    /// grant (the switch in System Settings flips itself back off) the next
    /// time a differently-hashed Flick.app with this bundle id launches.
    static var teamIdentifier: String? {
        var code: SecCode?
        guard SecCodeCopySelf(SecCSFlags(), &code) == errSecSuccess,
              let code else { return nil }
        var staticCode: SecStaticCode?
        guard SecCodeCopyStaticCode(code, SecCSFlags(), &staticCode) == errSecSuccess,
              let staticCode else { return nil }
        var info: CFDictionary?
        guard SecCodeCopySigningInformation(
            staticCode, SecCSFlags(rawValue: kSecCSSigningInformation), &info
        ) == errSecSuccess,
            let dict = info as? [String: Any] else { return nil }
        return dict[kSecCodeInfoTeamIdentifier as String] as? String
    }

    /// nil when permissions granted to this build will stick; otherwise the
    /// reason they won't, in one sentence the user can act on.
    static var permissionPersistenceWarning: String? {
        guard teamIdentifier == nil else { return nil }
        return "This is an ad-hoc signed build, so macOS drops its Full Disk Access "
            + "grant every time Flick is rebuilt. Install a Developer ID-signed build "
            + "(scripts/dev-install.sh) to grant it once and keep it."
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
