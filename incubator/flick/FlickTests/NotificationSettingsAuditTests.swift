import XCTest
@testable import Flick

/// The flag decoding is reverse-engineered, so these tests pin it against
/// **real** values lifted out of a live `com.apple.ncprefs.plist` rather than
/// against numbers invented to match the implementation. If a macOS update
/// moves the layout, this is where it should fail.
final class NotificationSettingsAuditTests: XCTestCase {
    private func decode(_ flags: UInt64) -> NativeNotificationSettings {
        NotificationSettingsAudit.decode(bundleID: "com.example.app", flags: flags)
    }

    // MARK: - Alert style

    func testBannersStyleFromRealFlags() {
        // com.mitchellh.ghostty, Slack, Notes, Photos — the common default.
        let settings = decode(276_832_270)
        XCTAssertEqual(settings.alertStyle, .banners)
        XCTAssertTrue(settings.playsSound)
        XCTAssertTrue(settings.badgesIcon)
        XCTAssertTrue(settings.isNoisy)
    }

    func testAlertsStyleFromRealFlags() {
        // com.apple.iCal — Calendar defaults to persistent alerts.
        let settings = decode(814_219_286)
        XCTAssertEqual(settings.alertStyle, .alerts)
        XCTAssertTrue(settings.isNoisy)
    }

    func testNoneStyleFromRealFlags() {
        // com.apple.Home — alert style None.
        let settings = decode(2_986_868_742)
        XCTAssertEqual(settings.alertStyle, .none)
    }

    func testBannersWinsWhenBothStyleBitsAreSet() {
        // Not a state System Settings can produce, but the store is Apple's
        // and undocumented: decode it deterministically instead of trapping.
        XCTAssertEqual(decode(0b11000).alertStyle, .banners)
    }

    // MARK: - Sound and badge

    func testSoundBitIsIndependentOfStyle() {
        XCTAssertTrue(decode(0b00100).playsSound)
        XCTAssertFalse(decode(0b11011).playsSound)
    }

    func testBadgeBit() {
        XCTAssertTrue(decode(0b00010).badgesIcon)
        XCTAssertFalse(decode(0b11101).badgesIcon)
    }

    // MARK: - Noisiness is the only question that matters

    func testSilentAppIsNotNoisy() {
        // Style none, no sound: exactly the state the helper walks users to.
        let settings = decode(0b00010)
        XCTAssertFalse(settings.isNoisy)
        XCTAssertNil(settings.complaint)
    }

    func testSoundAloneIsStillNoisy() {
        // Alert style None but "Play sound" left on — the case a
        // style-only check would miss.
        let settings = decode(0b00100)
        XCTAssertEqual(settings.alertStyle, .none)
        XCTAssertTrue(settings.isNoisy)
        XCTAssertEqual(settings.complaint, "macOS still shows sound")
    }

    // MARK: - The System Settings summary line

    func testSubtitleMatchesTheStringSystemSettingsWrites() {
        // Real ghostty flags: badge + sound + banners.
        XCTAssertEqual(decode(276_832_270).settingsSubtitle, "Badges, Sounds, and Desktop")
    }

    func testSubtitleTwoPartsUsesAndWithoutAComma() {
        XCTAssertEqual(decode(0b00110).settingsSubtitle, "Badges and Sounds")
    }

    func testSubtitleOfASilencedAppIsOff() {
        XCTAssertEqual(decode(0).settingsSubtitle, "Off")
    }

    func testComplaintNamesBothProblems() {
        XCTAssertEqual(decode(0b01100).complaint, "macOS still shows banners + sound")
    }

    // MARK: - The apps array

    private func entry(_ bundleID: String, _ flags: UInt64) -> [String: Any] {
        ["bundle-id": bundleID, "flags": NSNumber(value: flags)]
    }

    func testSystemManagedEntriesAreDropped() {
        let decoded = NotificationSettingsAudit.decode(appsArray: [
            entry("_SYSTEM_CENTER_:com.apple.mdmclient", 41_943_575),
            entry("com.tinyspeck.slackmacgap", 310_386_702),
        ])
        XCTAssertEqual(decoded.map(\.bundleID), ["com.tinyspeck.slackmacgap"])
    }

    func testEntriesWithoutFlagsAreSkippedNotGuessed() {
        let decoded = NotificationSettingsAudit.decode(appsArray: [
            ["bundle-id": "com.example.broken"],
            entry("com.example.fine", 0b01110),
        ])
        XCTAssertEqual(decoded.map(\.bundleID), ["com.example.fine"])
    }

    func testFlagsWiderThan32BitsSurvive() {
        // com.apple.MobileSMS on this macOS: bit 33 is set, so a UInt32
        // decode would silently lose the top half.
        let decoded = NotificationSettingsAudit.decode(appsArray: [
            entry("com.apple.MobileSMS", 9_490_137_102),
        ])
        XCTAssertEqual(decoded.first?.alertStyle, .banners)
    }

    // MARK: - Scoping

    private var fixture: [String: NativeNotificationSettings] {
        let all = NotificationSettingsAudit.decode(appsArray: [
            entry("com.apple.iCal", 814_219_286),          // alerts + sound
            entry("com.tinyspeck.slackmacgap", 310_386_702), // banners + sound
            entry("com.quiet.app", 0b00010),               // already silent
        ])
        return Dictionary(all.map { ($0.bundleID, $0) }, uniquingKeysWith: { _, l in l })
    }

    func testFindingsSkipAlreadySilentApps() {
        let found = NotificationSettingsAudit.findings(
            scope: .everything, settings: fixture, isInstalled: { _ in true }
        )
        XCTAssertEqual(Set(found.map(\.bundleID)), ["com.apple.iCal", "com.tinyspeck.slackmacgap"])
    }

    func testFindingsRankAlertsAboveBanners() {
        let found = NotificationSettingsAudit.findings(
            scope: .everything, settings: fixture, isInstalled: { _ in true }
        )
        XCTAssertEqual(found.first?.bundleID, "com.apple.iCal")
    }

    func testOnlyScopeIgnoresUnlistedApps() {
        let found = NotificationSettingsAudit.findings(
            scope: .only(["com.tinyspeck.slackmacgap"]), settings: fixture
        )
        XCTAssertEqual(found.map(\.bundleID), ["com.tinyspeck.slackmacgap"])
    }

    func testOnlyScopeToleratesUnknownBundleIDs() {
        let found = NotificationSettingsAudit.findings(
            scope: .only(["com.not.installed"]), settings: fixture
        )
        XCTAssertTrue(found.isEmpty)
    }

    func testEverythingSkipsBundleIDsNothingOnThisMacClaims() {
        // The invisible system agents: a preferences row, but no app, no
        // recognisable System Settings entry, and nothing flick would mirror.
        let found = NotificationSettingsAudit.findings(
            scope: .everything,
            settings: fixture,
            isInstalled: { $0 != "com.apple.iCal" }
        )
        XCTAssertEqual(found.map(\.bundleID), ["com.tinyspeck.slackmacgap"])
    }

    func testNamedAppsAreReportedEvenWhenUninstalled() {
        // Explicitly asked for, so answer — silently dropping it would read
        // as the audit being broken.
        let found = NotificationSettingsAudit.findings(
            scope: .only(["com.apple.iCal"]),
            settings: fixture,
            isInstalled: { _ in false }
        )
        XCTAssertEqual(found.map(\.bundleID), ["com.apple.iCal"])
    }

    func testListedBundleIDsTakesOnlyBundleShapedSources() {
        let rules = RuleSet(
            rules: [
                .init(match: .init(source: "com.tinyspeck.slackmacgap"), delivery: .banner),
                .init(match: .init(source: "deploy"), delivery: .inbox),
                .init(match: .init(source: "com.tinyspeck.slackmacgap"), delivery: .drop),
                .init(match: .init(titleContains: "build"), delivery: .drop),
            ],
            quietHours: nil
        )
        XCTAssertEqual(
            NotificationSettingsAudit.listedBundleIDs(in: rules),
            ["com.tinyspeck.slackmacgap"]
        )
    }

    // MARK: - What the audit puts on screen

    func testNothingFoundMeansNoBanners() {
        XCTAssertTrue(NotificationSettingsAudit.bannerEvents(for: []).isEmpty)
    }

    func testEachFindingGetsItsOwnBannerUpToTheLimit() {
        let findings = NotificationSettingsAudit.findings(scope: .everything, settings: fixture)
        let events = NotificationSettingsAudit.bannerEvents(for: findings)
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(events.first?.actions.first?.kind, .silenceNative)
        // Each carries the app it's about, so the helper opens on that one.
        XCTAssertEqual(
            Set(events.compactMap(\.actions.first?.target)),
            Set(findings.map(\.bundleID))
        )
    }

    func testTooManyFindingsCollapseToOneSummaryBanner() {
        let many = (0...NotificationSettingsAudit.individualBannerLimit).map {
            NotificationSettingsAudit.decode(bundleID: "com.example.app\($0)", flags: 0b01110)
        }
        let events = NotificationSettingsAudit.bannerEvents(for: many)
        XCTAssertEqual(events.count, 1)
        XCTAssertTrue(events[0].title.contains("\(many.count) apps"))
        // No target: the helper opens on the whole worklist.
        XCTAssertNil(events[0].actions.first?.target)
    }

    func testBannersShareAThreadSoTheyCoalesceRatherThanPileUp() {
        let findings = NotificationSettingsAudit.findings(scope: .everything, settings: fixture)
        let threads = Set(NotificationSettingsAudit.bannerEvents(for: findings).compactMap(\.thread))
        XCTAssertEqual(threads, ["flick-doctor"])
    }

    // MARK: - The doctor wire verb

    private func doctorRequest(_ json: String) -> SocketProvider.DoctorRequest? {
        guard case .doctor(let request) = SocketProvider.handle(line: Data(json.utf8)) else {
            return nil
        }
        return request
    }

    func testBareDoctorLetsTheDaemonPickTheScope() {
        let request = doctorRequest(#"{"verb":"doctor"}"#)
        XCTAssertNil(request?.scope)
        XCTAssertEqual(request?.notify, false)
    }

    func testDoctorAllMeansEverything() {
        XCTAssertEqual(doctorRequest(#"{"verb":"doctor","all":true}"#)?.scope, .everything)
    }

    func testNamedAppsBeatAll() {
        let request = doctorRequest(#"{"verb":"doctor","all":true,"apps":["com.a.b"]}"#)
        XCTAssertEqual(request?.scope, .only(["com.a.b"]))
    }

    func testDoctorNotifyIsCarried() {
        XCTAssertEqual(doctorRequest(#"{"verb":"doctor","notify":true}"#)?.notify, true)
    }

    // MARK: - The doctor CLI

    private func parse(_ args: [String]) -> FlickCLI.DoctorInvocation? {
        guard case .success(let invocation) = FlickCLI.parseDoctor(args) else { return nil }
        return invocation
    }

    func testCLIDoctorDefaultsToAskingTheDaemon() {
        let invocation = parse([])
        XCTAssertNil(invocation?.request.apps)
        XCTAssertNil(invocation?.request.all)
        XCTAssertNil(invocation?.request.notify)
        XCTAssertEqual(invocation?.json, false)
    }

    func testCLIDoctorFlagsAndBundleIDs() {
        let invocation = parse(["--all", "--notify", "--json", "com.a.b"])
        XCTAssertEqual(invocation?.request.apps, ["com.a.b"])
        XCTAssertEqual(invocation?.request.all, true)
        XCTAssertEqual(invocation?.request.notify, true)
        XCTAssertEqual(invocation?.json, true)
    }

    func testCLIDoctorRefusesUnknownFlags() {
        guard case .failure = FlickCLI.parseDoctor(["--fix-it-for-me"]) else {
            return XCTFail("expected a parse failure")
        }
    }
}
