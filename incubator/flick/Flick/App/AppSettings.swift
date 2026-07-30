import Foundation
import Combine

/// UserDefaults-backed settings (perch's `AppSettings` shape). Anything a
/// rule can express lives in `~/.config/flick/rules.json` instead — settings
/// here are app-level switches only.
@MainActor
final class AppSettings: ObservableObject {
    @Published var launchAtLogin: Bool {
        didSet {
            defaults.set(launchAtLogin, forKey: Keys.launchAtLogin)
            if launchAtLogin {
                SystemIntegration.registerAsLoginItem()
            } else {
                SystemIntegration.unregisterLoginItem()
            }
        }
    }

    /// Off = nothing about any event ever touches disk.
    @Published var persistHistory: Bool {
        didSet { defaults.set(persistHistory, forKey: Keys.persistHistory) }
    }

    @Published var systemMirrorEnabled: Bool {
        didSet { defaults.set(systemMirrorEnabled, forKey: Keys.systemMirror) }
    }

    private let defaults: UserDefaults

    private enum Keys {
        static let launchAtLogin = "launchAtLogin"
        static let persistHistory = "persistHistory"
        static let systemMirror = "systemMirrorEnabled"
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        defaults.register(defaults: [
            Keys.launchAtLogin: false,
            Keys.persistHistory: true,
            Keys.systemMirror: false, // experimental: always opt-in
        ])
        launchAtLogin = defaults.bool(forKey: Keys.launchAtLogin)
        persistHistory = defaults.bool(forKey: Keys.persistHistory)
        systemMirrorEnabled = defaults.bool(forKey: Keys.systemMirror)
    }
}
