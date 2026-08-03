import AppKit
import Foundation
import os.log

/// What macOS itself will do with one app's notifications.
///
/// This is the *other* app's settings, not flick's: the row you'd see under
/// System Settings → Notifications → <app>. flick reads it to answer one
/// question — "if I draw this event, will Apple draw it too?" — because a
/// mirrored notification that macOS also banners is a duplicate, and one it
/// also sounds is a duplicate that beeps.
struct NativeNotificationSettings: Sendable, Equatable, Codable {
    /// The "Alert style" radio group. `none` means macOS puts the
    /// notification in Notification Center but never draws it on screen —
    /// which is exactly the state flick wants an app it mirrors to be in.
    enum AlertStyle: String, Sendable, Codable {
        case none, banners, alerts
    }

    var bundleID: String
    var alertStyle: AlertStyle
    var playsSound: Bool
    var badgesIcon: Bool

    /// The whole point of the audit. True when macOS will still draw or sound
    /// this app's notifications itself.
    var isNoisy: Bool { alertStyle != .none || playsSound }

    /// One line naming only what's still wrong, for a banner body or a CLI row.
    var complaint: String? {
        var parts: [String] = []
        switch alertStyle {
        case .banners: parts.append("banners")
        case .alerts: parts.append("alerts")
        case .none: break
        }
        if playsSound { parts.append("sound") }
        guard !parts.isEmpty else { return nil }
        return "macOS still shows " + parts.joined(separator: " + ")
    }
}

/// Reads Apple's per-app notification preferences and reports which apps
/// would double up with flick.
///
/// **Read-only, and undocumented.** `com.apple.ncprefs` is a private
/// preference domain: Apple documents no reader, no writer, and no bit
/// layout. So this file follows the same quarantine rule System Mirror does —
/// it decodes defensively, never writes (silencing an app is always the
/// user's click in System Settings, never ours), and a layout it can't make
/// sense of degrades to "nothing to report" rather than to a wrong answer.
///
/// The flag bits below are reverse-engineered, and were confirmed two
/// independent ways before being relied on: against the long-standing
/// community tool (`drewdiver/ncprefs.py`, itself a descendant of Jacob
/// Salmela's NCUtil), and empirically against this machine's own 92-app
/// preference file — where `(flags >> 3) & 0b11` took only the values 0, 1
/// and 2 across every app, which is what a two-bit style field looks like and
/// not what three unrelated booleans look like.
enum NotificationSettingsAudit {
    private static let log = Logger(subsystem: "com.nebelhaus.flick", category: "audit")

    /// flick reads exactly the three bits it needs, and deliberately ignores
    /// the rest. Several other bits in this field (lock-screen visibility,
    /// time-sensitive, critical) have plausible community mappings that this
    /// machine's data does *not* corroborate, so acting on them would be
    /// guessing. Alert style and sound are the two that matter and the two
    /// that are solid.
    enum Flag {
        /// Bits 3–5 hold the alert style; 3 = banners, 4 = alerts, neither = none.
        static let banners: UInt64 = 1 << 3
        static let alerts: UInt64 = 1 << 4
        static let playSound: UInt64 = 1 << 2
        static let badgeAppIcon: UInt64 = 1 << 1
    }

    /// The preference domain, and the file it lands in. Read through
    /// CFPreferences first so a change made in System Settings a second ago is
    /// visible without waiting for cfprefsd to flush.
    private static let domain = "com.apple.ncprefs"

    // MARK: - Pure decoding (tested)

    /// Decode one app's flags word. Pure — the tests drive this directly.
    static func decode(bundleID: String, flags: UInt64) -> NativeNotificationSettings {
        let style: NativeNotificationSettings.AlertStyle
        if flags & Flag.banners != 0 {
            style = .banners
        } else if flags & Flag.alerts != 0 {
            style = .alerts
        } else {
            style = .none
        }
        return NativeNotificationSettings(
            bundleID: bundleID,
            alertStyle: style,
            playsSound: flags & Flag.playSound != 0,
            badgesIcon: flags & Flag.badgeAppIcon != 0
        )
    }

    /// Entries macOS manages on its own behalf — software updates, keychain
    /// prompts, the account-security alerts. They're prefixed in the store,
    /// the user can't meaningfully retune them, and flick never mirrors them,
    /// so they'd be pure noise in an audit aimed at "apps you use".
    static func isSystemManaged(bundleID: String) -> Bool {
        bundleID.hasPrefix("_SYSTEM_CENTER_:")
    }

    /// Decode a whole `apps` array as read from the preference domain.
    /// Pure, so the tests can feed it a fixture instead of a real Mac.
    static func decode(appsArray: [[String: Any]]) -> [NativeNotificationSettings] {
        appsArray.compactMap { entry in
            guard let bundleID = entry["bundle-id"] as? String,
                  !isSystemManaged(bundleID: bundleID),
                  // `flags` is a plist integer; NSNumber covers every width
                  // it's been seen as, and some entries have grown past 32
                  // bits on recent macOS.
                  let flags = (entry["flags"] as? NSNumber)?.uint64Value
            else { return nil }
            return decode(bundleID: bundleID, flags: flags)
        }
    }

    // MARK: - Reading the live store

    /// Every app macOS has notification preferences for, keyed by bundle id.
    /// Empty when the store can't be read or has changed shape — never a
    /// partial guess.
    static func readAll() -> [String: NativeNotificationSettings] {
        guard let apps = readAppsArray() else {
            log.info("ncprefs unreadable or reshaped — audit reporting nothing")
            return [:]
        }
        let decoded = decode(appsArray: apps)
        return Dictionary(decoded.map { ($0.bundleID, $0) }, uniquingKeysWith: { _, last in last })
    }

    private static func readAppsArray() -> [[String: Any]]? {
        // cfprefsd holds the authoritative copy; the on-disk plist can lag it
        // by minutes after a change in System Settings, which for a flow whose
        // whole job is "did you flip it yet?" would read as flick being wrong.
        //
        // The synchronize is load-bearing, not hygiene: CFPreferences caches
        // another process's domain in *ours*, so without it the helper panel
        // would poll a snapshot taken before the user touched anything and
        // never notice the fix.
        CFPreferencesAppSynchronize(domain as CFString)
        if let live = CFPreferencesCopyAppValue("apps" as CFString, domain as CFString)
            as? [[String: Any]], !live.isEmpty {
            return live
        }
        // Fallback for the case where cfprefsd declines to answer for another
        // process's domain: read the file ourselves.
        let url = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Preferences/\(domain).plist")
        guard let data = try? Data(contentsOf: url),
              let plist = try? PropertyListSerialization.propertyList(
                  from: data, options: [], format: nil
              ) as? [String: Any],
              let apps = plist["apps"] as? [[String: Any]]
        else { return nil }
        return apps
    }

    // MARK: - The audit

    /// The apps flick is expected to keep quiet, in the order they should be
    /// dealt with.
    ///
    /// `scope` is what "a listed app" means in practice — see
    /// `NotificationSettingsAudit.Scope`.
    enum Scope: Sendable, Equatable {
        /// Exactly these bundle ids (a `flick doctor com.foo.bar` invocation,
        /// or the sources named in `rules.json`).
        case only([String])
        /// Every non-system app macOS holds preferences for. What `--all`
        /// means, and the honest default once System Mirror is on: mirroring
        /// redraws *everything*, so everything noisy is a duplicate.
        case everything
    }

    /// The bundle ids a rule set names — flick's "listed apps", and the
    /// default scope for a bare `flick doctor`.
    ///
    /// A rule's `source` is either a short slug (`deploy`, `ci`) or a bundle
    /// id for a mirrored system app; only the latter has notification
    /// settings to audit, and a dot is what tells them apart.
    static func listedBundleIDs(in ruleSet: RuleSet) -> [String] {
        var seen: Set<String> = []
        return ruleSet.rules
            .compactMap(\.match.source)
            .filter { $0.contains(".") }
            .filter { seen.insert($0).inserted }
    }

    /// flick's own row is in this store too, and telling the user to silence
    /// flick's banners in order to stop duplicate flick banners is a loop.
    private static var ownBundleID: String {
        Bundle.main.bundleIdentifier ?? "com.nebelhaus.flick"
    }

    /// Does something on this Mac actually claim this bundle id? Injectable
    /// so `findings` stays testable without a real LaunchServices database.
    static let bundleIsInstalled: @Sendable (String) -> Bool = { bundleID in
        NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID) != nil
    }

    /// The noisy apps in scope, worst first (alerts before banners, sound
    /// breaking ties), then alphabetical so the order is stable between runs.
    static func findings(
        scope: Scope,
        settings: [String: NativeNotificationSettings]? = nil,
        isInstalled: (String) -> Bool = bundleIsInstalled
    ) -> [NativeNotificationSettings] {
        let all = settings ?? readAll()
        let candidates: [NativeNotificationSettings]
        switch scope {
        case .only(let ids):
            // Named explicitly, so it's reported even if nothing on this Mac
            // claims the id — an app you uninstalled still has a row, and
            // silently dropping it would look like the audit was broken.
            candidates = ids.compactMap { all[$0] }
        case .everything:
            // A stock Mac holds preferences for dozens of invisible system
            // agents — tccd, PlatformSSO, the timezone notifier — which have
            // no row a user would recognise, no app to open, and nothing
            // flick would ever mirror. On this machine they were 26 of 68
            // "findings": enough noise to make `--all` useless as a worklist.
            candidates = all.values.filter { isInstalled($0.bundleID) }
        }
        return candidates
            .filter { $0.isNoisy && $0.bundleID != ownBundleID }
            .sorted { lhs, rhs in
                let rank = { (s: NativeNotificationSettings) -> Int in
                    (s.alertStyle == .alerts ? 2 : s.alertStyle == .banners ? 1 : 0)
                        + (s.playsSound ? 1 : 0)
                }
                if rank(lhs) != rank(rhs) { return rank(lhs) > rank(rhs) }
                return lhs.bundleID < rhs.bundleID
            }
    }

    // MARK: - Reporting as banners

    /// How many individual apps are worth one banner each before the report
    /// collapses into a single summary. Past this, a banner per app *is* the
    /// notification storm flick exists to prevent.
    static let individualBannerLimit = 3

    /// The banner(s) `flick doctor --notify` puts on screen. Pure, so the
    /// wording and the collapse threshold are testable without a display.
    ///
    /// One action, always — clicking the banner opens the helper. There is no
    /// "fix it for me" here and there can't be: Apple exposes no API to write
    /// another app's notification settings, so the honest offer is to open the
    /// right pane and show the user exactly which two boxes to clear.
    static func bannerEvents(for findings: [NativeNotificationSettings]) -> [NotificationEvent] {
        guard !findings.isEmpty else { return [] }

        func action(target: String?) -> NotificationEvent.Action {
            .init(id: "silence", label: "Silence Native Banners", kind: .silenceNative, target: target)
        }

        // Too many to list: one banner for the lot, and the helper steps
        // through them. Better than burying the screen in its own duplicates.
        guard findings.count <= individualBannerLimit else {
            return [NotificationEvent(
                source: "flick",
                title: "\(findings.count) apps still show native banners",
                body: "macOS is drawing these itself, so you'll see everything twice.",
                symbol: "bell.badge.slash",
                thread: "flick-doctor",
                actions: [action(target: nil)]
            )]
        }

        return findings.map { finding in
            NotificationEvent(
                source: "flick",
                title: "\(displayName(for: finding.bundleID)) still shows native banners",
                body: finding.complaint,
                symbol: "bell.badge.slash",
                thread: "flick-doctor",
                actions: [action(target: finding.bundleID)]
            )
        }
    }

    // MARK: - Naming

    /// A human name for a bundle id, or the id back when nothing on this Mac
    /// claims it (an app that was uninstalled still has a preferences row).
    static func displayName(for bundleID: String) -> String {
        guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: bundleID)
        else { return bundleID }
        return FileManager.default.displayName(atPath: url.path)
            .replacingOccurrences(of: ".app", with: "")
    }
}
