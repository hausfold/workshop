import AppKit
import SwiftUI

// MARK: - Draggable App Tile (AppKit)

final class DraggableAppTileNSView: NSView, NSDraggingSource {
    let fileURL: URL
    let appIcon: NSImage
    let title: String

    init(fileURL: URL, appIcon: NSImage, title: String) {
        self.fileURL = fileURL
        self.appIcon = appIcon
        self.title = title
        super.init(frame: NSRect(x: 0, y: 0, width: 180, height: 64))
        wantsLayer = true
        layer?.cornerRadius = 10
        layer?.backgroundColor = NSColor.quaternaryLabelColor.cgColor
        layer?.borderWidth = 1
        layer?.borderColor = NSColor.separatorColor.cgColor

        setupSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupSubviews() {
        let iconView = NSImageView(image: appIcon)
        iconView.imageScaling = .scaleProportionallyUpOrDown
        iconView.frame = NSRect(x: 12, y: 12, width: 40, height: 40)
        addSubview(iconView)

        let label = NSTextField(labelWithString: title)
        label.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        label.frame = NSRect(x: 60, y: 22, width: 80, height: 20)
        addSubview(label)

        if let dragSymbol = NSImage(systemSymbolName: "line.3.horizontal", accessibilityDescription: "Drag") {
            let dragView = NSImageView(image: dragSymbol)
            dragView.contentTintColor = .secondaryLabelColor
            dragView.frame = NSRect(x: 152, y: 22, width: 16, height: 20)
            addSubview(dragView)
        }
    }

    override var mouseDownCanMoveWindow: Bool { false }

    override func mouseDown(with event: NSEvent) {
        let draggingItem = NSDraggingItem(pasteboardWriter: fileURL as NSURL)
        let dragBounds = bounds

        let image = NSImage(size: dragBounds.size)
        image.lockFocus()
        if let ctx = NSGraphicsContext.current?.cgContext {
            layer?.render(in: ctx)
        }
        image.unlockFocus()

        draggingItem.setDraggingFrame(dragBounds, contents: image)
        beginDraggingSession(with: [draggingItem], event: event, source: self)
    }

    func draggingSession(_ session: NSDraggingSession, sourceOperationMaskFor context: NSDraggingContext) -> NSDragOperation {
        return .copy
    }
}

struct DraggableAppTile: NSViewRepresentable {
    let fileURL: URL
    let appIcon: NSImage
    let title: String

    func makeNSView(context: Context) -> DraggableAppTileNSView {
        DraggableAppTileNSView(fileURL: fileURL, appIcon: appIcon, title: title)
    }

    func updateNSView(_ nsView: DraggableAppTileNSView, context: Context) {}
}

// MARK: - Type scale

/// One type scale for the whole helper.
///
/// This panel is not an inspector — it's read at arm's length, mid-task,
/// while the user's eyes are mostly on System Settings and their hand is on
/// the mouse. The first cut used `.caption`/`.caption2` (10pt) throughout,
/// which is the size you reach for when text sits *beside* the thing it
/// describes; here the text **is** the product, so everything moved up a
/// couple of steps and the panel widened to carry it.
private enum HelperType {
    /// The panel's own header.
    static let title = Font.title3
    /// The sentences that carry the instruction — the ones that have to be
    /// readable without leaning in.
    static let body = Font.body
    /// Supporting detail beside an instruction: step labels, warnings,
    /// the status line.
    static let detail = Font.callout
    /// Incidentals inside the System Settings replica, where matching Apple's
    /// own row proportions matters more than legibility.
    static let micro = Font.caption
}

// MARK: - Onboarding Assistant View

/// The floating helper that rides alongside System Settings during a
/// permission grant or an app-migration walkthrough. Deliberately shown in
/// a non-activating panel (see `OnboardingAssistantPanelController`) — the
/// whole point is that System Settings keeps focus while this stays
/// visible, so it must never route through `UtilityWindowManager`'s
/// activation dance.
struct OnboardingAssistantView: View {
    enum Mode {
        case fullDiskAccess
        /// Walk the user through turning Apple's own banners off, one app at a
        /// time. Carries the whole worklist rather than a single app: the
        /// audit usually finds several, and four panels opening in sequence
        /// is the notification pile-up flick exists to stop.
        case nativeBanners(findings: [NativeNotificationSettings])
    }

    /// Wide enough that the instruction sentences hold their line count at
    /// the larger type (see `HelperType`) — the panel got taller when the
    /// text grew, and re-wrapping into an extra line each would have made it
    /// taller still. The controller sizes the window from the same constant.
    nonisolated static let panelWidth: CGFloat = 400

    let mode: Mode
    /// Fires once, when the probe first sees Full Disk Access land — the
    /// caller commits the setting through `AppSettings` so it's flushed to
    /// disk, then this panel closes itself and hands back to Settings.
    var onGrantConfirmed: () -> Void = {}
    let onClose: () -> Void

    @State private var pollTimer: Timer?
    @State private var selectedTab = 0
    /// Bundle ids the poll has since seen go quiet. Kept as a set rather than
    /// a cursor because the user is free to fix them in any order — or to fix
    /// three at once in a pane they already had open.
    @State private var resolved: Set<String> = []
    /// Briefly true when the last app goes quiet, so the panel can say so
    /// before it closes instead of just vanishing.
    @State private var allClear = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // No in-content close button: the panel is `.titled`/`.closable`,
            // so it already has the native red traffic light. Two ways to
            // shut one small window is one too many.
            HStack {
                Image(systemName: modeIcon)
                    .foregroundStyle(.tint)
                    .font(.title2)
                Text(modeTitle)
                    .font(HelperType.title)
                    .fontWeight(.semibold)
                Spacer()
            }

            Divider()

            switch mode {
            case .fullDiskAccess:
                fullDiskAccessContent
            case .nativeBanners(let findings):
                nativeBannersContent(findings: findings)
            }
        }
        .padding(16)
        // The panel's height is fixed per mode (it can't be measured — see
        // the controller), so any slack goes to the bottom rather than being
        // split into two gaps around vertically-centred content.
        .frame(width: Self.panelWidth, alignment: .top)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.ultraThinMaterial)
        .onAppear {
            switch mode {
            case .fullDiskAccess: startFDAPolling()
            case .nativeBanners(let findings): startNativeBannerPolling(findings: findings)
            }
        }
        .onDisappear {
            pollTimer?.invalidate()
        }
    }

    private var modeIcon: String {
        switch mode {
        case .fullDiskAccess: return "lock.shield"
        case .nativeBanners: return "bell.slash"
        }
    }

    private var modeTitle: String {
        switch mode {
        case .fullDiskAccess: return "Full Disk Access Setup"
        case .nativeBanners: return "Silence Native Banners"
        }
    }

    @ViewBuilder
    private var fullDiskAccessContent: some View {
        // An ad-hoc signed build has its TCC grant pinned to the binary's
        // cdhash, so the switch flips itself back off on the next rebuild.
        // Say so here rather than letting the user re-grant forever.
        if let warning = SystemIntegration.permissionPersistenceWarning {
            Label(warning, systemImage: "exclamationmark.triangle.fill")
                .font(HelperType.detail)
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
        }

        Picker("", selection: $selectedTab) {
            Text("If Already in List").tag(0)
            Text("If Missing").tag(1)
        }
        .pickerStyle(.segmented)

        if selectedTab == 0 {
            VStack(alignment: .leading, spacing: 8) {
                Text("Find **Flick** in System Settings and turn its switch **ON**. If Apple prompts, click **Later**:")
                    .font(HelperType.body)
                    .foregroundStyle(.secondary)

                FlickSwitchDemo()
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Drag the tile below into System Settings (or click **+**):")
                    .font(HelperType.body)
                    .foregroundStyle(.secondary)

                HStack {
                    Spacer()
                    DraggableAppTile(
                        fileURL: Bundle.main.bundleURL,
                        appIcon: NSApp.applicationIconImage ?? NSImage(named: NSImage.applicationIconName)!,
                        title: "Flick.app"
                    )
                    .frame(width: 180, height: 56)
                    Spacer()
                }
            }
        }

        // No spinner here. Nothing is loading — flick is waiting on a human,
        // and a spinner in that spot claims the app is busy when the ball is
        // squarely in the user's court.
        HStack(spacing: 6) {
            Image(systemName: "bolt.horizontal.circle")
                .font(HelperType.detail)
                .foregroundStyle(.tint)
            Text("Picked up the instant you flip it.")
                .font(HelperType.detail)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Open Settings") {
                SystemIntegration.openFullDiskAccessSettings()
            }
            .font(HelperType.detail)
            .buttonStyle(.borderless)
        }
        .padding(.top, 4)
    }

    // MARK: - Native banners

    /// The app the panel is currently pointed at: the first one the poll
    /// hasn't yet seen go quiet. Derived rather than stored, so a user who
    /// fixes the third app first simply skips it.
    private func currentFinding(in findings: [NativeNotificationSettings])
        -> NativeNotificationSettings?
    {
        findings.first { !resolved.contains($0.bundleID) }
    }

    @ViewBuilder
    private func nativeBannersContent(findings: [NativeNotificationSettings]) -> some View {
        if allClear || currentFinding(in: findings) == nil {
            allClearContent(total: findings.count)
        } else if let finding = currentFinding(in: findings) {
            let appName = NotificationSettingsAudit.displayName(for: finding.bundleID)

            // Only worth saying when there's more than one; "1 of 1" is noise.
            if findings.count > 1 {
                stepIndicator(findings: findings)
            }

            Text("macOS is drawing **\(appName)**'s notifications itself, so you'd see each one twice. Turn Apple's off — flick keeps showing them.")
                .font(HelperType.body)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            // Apple dropped per-app anchors from the Notifications deep link:
            // the URL lands on the top of the pane no matter which app id it
            // carries. So the first real step is *finding* the row, and the
            // honest thing is to show exactly what it looks like — icon,
            // name, and the same summary line System Settings writes under it.
            VStack(alignment: .leading, spacing: 4) {
                Text("1 · Find this row under Application Notifications")
                    .font(HelperType.detail)
                    .foregroundStyle(.secondary)
                settingsRowMock(for: finding, appName: appName)
                // Reached by naming the app explicitly — `--all` filters these
                // out. Say it plainly rather than letting someone scroll a
                // list for a row macOS never puts there.
                if !finding.hasSettingsRow {
                    Label(
                        "macOS doesn't list \(appName) here — there's no row to change.",
                        systemImage: "exclamationmark.triangle.fill"
                    )
                    .font(HelperType.detail)
                    .foregroundStyle(.orange)
                    .fixedSize(horizontal: false, vertical: true)
                }
            }

            // `.init` so the bold markup is parsed — Text(String) renders it
            // literally, Text(LocalizedStringKey) doesn't.
            Text(.init(step2Instruction(for: finding)))
                .font(HelperType.detail)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            NativeBannerDemo(
                appName: appName,
                bundleID: finding.bundleID,
                needsDesktopChange: finding.showsOnDesktop,
                needsSoundChange: finding.playsSound
            )

            HStack(spacing: 6) {
                Image(systemName: "bolt.horizontal.circle")
                    .font(HelperType.detail)
                    .foregroundStyle(.tint)
                Text("Picked up the instant you change it.")
                    .font(HelperType.detail)
                    .foregroundStyle(.secondary)
                Spacer()
            }

            Button {
                SystemIntegration.openNotificationSettings(for: finding.bundleID)
            } label: {
                // Not "Open <App> Settings" — it can't do that, and a button
                // that overpromises by one step is what sends someone hunting
                // for a pane that never opened.
                Label("Open Notification Settings", systemImage: "arrow.up.forward.app")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    /// Name only the controls this app actually needs touched. An app that's
    /// merely loud shouldn't be told to untick Desktop, and one that's merely
    /// visible shouldn't be sent hunting for a sound switch.
    private func step2Instruction(for finding: NativeNotificationSettings) -> String {
        switch (finding.showsOnDesktop, finding.playsSound) {
        case (true, true): return "2 · Untick **Desktop**, and turn **Play sound** off"
        case (true, false): return "2 · Untick **Desktop**"
        case (false, true): return "2 · Turn **Play sound for notification** off"
        case (false, false): return "2 · Nothing left to change"
        }
    }

    /// A replica of the app's row in System Settings → Notifications, down to
    /// the summary line, so the user can scan the list for a shape they've
    /// already seen rather than a name they have to remember.
    @ViewBuilder
    private func settingsRowMock(for finding: NativeNotificationSettings, appName: String) -> some View {
        HStack(spacing: 8) {
            if let icon = NotificationSettingsAudit.icon(for: finding.bundleID) {
                Image(nsImage: icon)
                    .resizable()
                    .frame(width: 30, height: 30)
            } else {
                RoundedRectangle(cornerRadius: 6, style: .continuous)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 30, height: 30)
            }
            VStack(alignment: .leading, spacing: 0) {
                Text(appName)
                    .font(HelperType.detail)
                    .fontWeight(.medium)
                Text(finding.settingsSubtitle)
                    .font(HelperType.micro)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(HelperType.micro)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(Color.primary.opacity(0.06))
        )
    }

    /// Past this many apps the dots stop being countable at a glance and
    /// start being a grey smear — a stock Mac has ~68 apps macOS notifies
    /// for, so `--all` reaches this routinely.
    private static let dottedStepLimit = 8

    /// One dot per app, filled as each goes quiet. Deliberately not a
    /// percentage or a progress bar — a short list is countable, and a bar
    /// would imply flick is doing the work rather than the user. Long lists
    /// drop to the count alone, which stays honest at any length.
    @ViewBuilder
    private func stepIndicator(findings: [NativeNotificationSettings]) -> some View {
        let done = findings.filter { resolved.contains($0.bundleID) }.count
        HStack(spacing: 6) {
            if findings.count <= Self.dottedStepLimit {
                ForEach(findings, id: \.bundleID) { finding in
                    let isDone = resolved.contains(finding.bundleID)
                    let isCurrent = currentFinding(in: findings)?.bundleID == finding.bundleID
                    Image(systemName: isDone ? "checkmark.circle.fill" : "circle")
                        .font(.system(size: 13))
                        .foregroundStyle(isDone ? Color.green : (isCurrent ? Color.accentColor : Color.secondary.opacity(0.4)))
                }
            } else {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 13))
                    .foregroundStyle(done > 0 ? Color.green : Color.secondary.opacity(0.4))
            }
            Spacer()
            Text("\(done) of \(findings.count) silenced")
                .font(HelperType.detail)
                .foregroundStyle(.secondary)
                .contentTransition(.numericText())
        }
    }

    @ViewBuilder
    private func allClearContent(total: Int) -> some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .font(.title2)
                .foregroundStyle(.green)
            VStack(alignment: .leading, spacing: 2) {
                Text(total > 1 ? "All \(total) apps are quiet" : "That's it — it's quiet")
                    .font(HelperType.title)
                    .fontWeight(.semibold)
                Text("macOS has stopped drawing them. flick has it from here.")
                    .font(HelperType.body)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
        }
        .padding(.vertical, 4)
    }

    /// Re-reads Apple's own preferences once a second and ticks apps off as
    /// they go quiet. Polling rather than watching the file: the store is
    /// cfprefsd-owned and undocumented, and a one-second poll of a small
    /// plist costs nothing next to guessing at a change-notification
    /// mechanism Apple doesn't promise.
    private func startNativeBannerPolling(findings: [NativeNotificationSettings]) {
        // Anything already quiet by the time the panel opens (the user got
        // there first) starts ticked.
        refreshResolved(findings: findings)

        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                refreshResolved(findings: findings)
                guard resolved.count >= findings.count, !allClear else { return }
                pollTimer?.invalidate()
                pollTimer = nil
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) { allClear = true }
                // Long enough to read, short enough that it doesn't become a
                // window the user has to dismiss.
                try? await Task.sleep(nanoseconds: 2_200_000_000)
                onClose()
            }
        }
    }

    private func refreshResolved(findings: [NativeNotificationSettings]) {
        let current = NotificationSettingsAudit.readAll()
        let quiet = findings
            .filter { finding in current[finding.bundleID]?.isNoisy != true }
            .map(\.bundleID)
        guard !quiet.isEmpty else { return }
        withAnimation(.easeOut(duration: 0.25)) {
            resolved.formUnion(quiet)
        }
    }

    /// The grant is the end of this panel's job. Rather than swapping in a
    /// "granted, click Done" state the user has to dismiss, close — the
    /// caller reopens Settings, where the now-unlocked toggle is the payoff.
    private func startFDAPolling() {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                let provider = SystemMirrorProvider()
                let health = await provider.probe()
                if case .ready = health {
                    pollTimer?.invalidate()
                    pollTimer = nil
                    onGrantConfirmed()
                    onClose()
                }
            }
        }
    }
}

// MARK: - Looping "flip the switch" demo

/// A silent, non-interactive re-enactment of the single thing the user has
/// to do in System Settings: find flick's row and turn its switch on.
///
/// It starts **off** on purpose — off is the state they're staring at, and a
/// mock that's already on illustrates the destination while hiding the
/// action. A pointer glides in, clicks, the switch flips, then the whole
/// thing resets and loops.
private struct FlickSwitchDemo: View {
    @State private var isOn = false
    /// 1 = pointer parked off to the lower right, 0 = resting on the switch.
    @State private var cursorTravel: CGFloat = 1
    @State private var cursorVisible = false
    @State private var pressed = false
    @State private var ripple = false

    private var appIcon: NSImage {
        NSApp.applicationIconImage ?? NSImage(named: NSImage.applicationIconName)!
    }

    var body: some View {
        HStack(spacing: 12) {
            Image(nsImage: appIcon)
                .resizable()
                .frame(width: 30, height: 30)
            Text("Flick")
                .font(HelperType.body)
                .bold()
            Spacer()
            Toggle("", isOn: .constant(isOn))
                .labelsHidden()
                .toggleStyle(.switch)
                .controlSize(.small)
                .allowsHitTesting(false)
                .scaleEffect(pressed ? 0.93 : 1)
                .overlay {
                    Circle()
                        .strokeBorder(Color.accentColor.opacity(0.9), lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                        .scaleEffect(ripple ? 1.8 : 0.4)
                        .opacity(ripple ? 0 : 0.9)
                        .allowsHitTesting(false)
                }
                .overlay {
                    Image(systemName: pressed ? "cursorarrow.click" : "cursorarrow")
                        .font(.system(size: 15))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.6), radius: 1.5, y: 0.5)
                        .offset(x: 6 + cursorTravel * 40, y: 9 + cursorTravel * 30)
                        .opacity(cursorVisible ? 1 : 0)
                        .allowsHitTesting(false)
                }
        }
        .padding(10)
        .background(Color.primary.opacity(0.06))
        .cornerRadius(8)
        // `.task` is tied to the view's lifetime, so the loop cancels itself
        // when the panel goes away — no timer to invalidate.
        .task { await runLoop() }
    }

    private func runLoop() async {
        while !Task.isCancelled {
            withTransaction(Transaction(animation: nil)) {
                isOn = false
                cursorTravel = 1
                cursorVisible = false
                pressed = false
                ripple = false
            }
            try? await Task.sleep(nanoseconds: 600_000_000)
            if Task.isCancelled { return }

            withAnimation(.easeOut(duration: 0.25)) { cursorVisible = true }
            withAnimation(.easeInOut(duration: 0.75)) { cursorTravel = 0 }
            try? await Task.sleep(nanoseconds: 900_000_000)
            if Task.isCancelled { return }

            withAnimation(.easeIn(duration: 0.08)) { pressed = true }
            withAnimation(.easeOut(duration: 0.55)) { ripple = true }
            try? await Task.sleep(nanoseconds: 130_000_000)
            if Task.isCancelled { return }

            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) { isOn = true }
            withAnimation(.easeOut(duration: 0.15)) { pressed = false }
            try? await Task.sleep(nanoseconds: 1_500_000_000)
            if Task.isCancelled { return }

            withAnimation(.easeIn(duration: 0.3)) {
                cursorVisible = false
                cursorTravel = 1
            }
            try? await Task.sleep(nanoseconds: 1_100_000_000)
        }
    }
}

// MARK: - Looping "stop drawing this on the Desktop" demo

/// A silent, non-interactive re-enactment of what the user has to do in
/// System Settings → Notifications → <app>: untick **Desktop**, and turn
/// **Play sound for notification** off.
///
/// This mirrors the macOS 26 (Tahoe) pane, which is not the one most
/// write-ups describe. Tahoe replaced the old None/Banners/Alerts radio with
/// three checkboxes — Desktop, Notification Center, Lock Screen — and a
/// Temporary/Persistent radio that only applies while Desktop is ticked.
/// "Turn the alert style to None" is no longer a thing anyone can do, so the
/// demo must not mime it. **Desktop** is the one control that stops macOS
/// drawing over your work, and the only one flick asks anyone to touch:
/// Notification Center and Lock Screen stay ticked, because flick redraws the
/// banner but does not replace the notification.
///
/// Same reasoning as `FlickSwitchDemo`: it starts in the *wrong* state,
/// because wrong is what they're looking at, and a mock already showing the
/// destination illustrates the answer while hiding the move. A pointer glides
/// in, clicks each control in turn, then the whole thing resets and loops.
///
/// It only demonstrates the steps this app actually needs — an app whose
/// sound is already off never sees the sound step, so the loop can't teach a
/// click that isn't there.
private struct NativeBannerDemo: View {
    let appName: String
    let bundleID: String
    let needsDesktopChange: Bool
    let needsSoundChange: Bool

    /// Which control the pointer is currently over.
    private enum Target { case parked, desktop, sound }

    @State private var desktopChecked = true
    @State private var soundIsOn = true
    @State private var target: Target = .parked
    @State private var cursorVisible = false
    @State private var pressed = false
    @State private var ripple = false

    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private enum Geo {
        static let gap: CGFloat = 8
        /// Derived, not hand-picked: three tiles and two gaps fill whatever
        /// the panel leaves after its own 16pt padding on each side and this
        /// box's 10pt — so widening `panelWidth` widens the replica instead
        /// of leaving it stranded in the corner.
        static let tileWidth: CGFloat =
            (OnboardingAssistantView.panelWidth - 2 * 16 - 2 * 10 - gap * 2) / 3
        static let width: CGFloat = tileWidth * 3 + gap * 2
        /// Illustration + label + the checkbox under it, and the 4pt gaps
        /// between: 34 + 4 + 26 + 4 + 16. Kept exact because the pointer
        /// anchors below are measured off it.
        static let tileHeight: CGFloat = 84
        static let soundRowHeight: CGFloat = 28
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: Geo.gap) {
                destinationTile(.desktop, label: "Desktop", checked: desktopChecked)
                destinationTile(.notificationCenter, label: "Notification\nCenter", checked: true)
                destinationTile(.lockScreen, label: "Lock Screen", checked: true)
            }

            Divider()
                .padding(.vertical, 8)

            HStack {
                Text("Play sound for notification")
                    .font(HelperType.detail)
                Spacer()
                Toggle("", isOn: .constant(soundIsOn))
                    .labelsHidden()
                    .toggleStyle(.switch)
                    .controlSize(.small)
                    .allowsHitTesting(false)
            }
            .frame(height: Geo.soundRowHeight)
        }
        .frame(width: Geo.width, alignment: .leading)
        .padding(10)
        .background(Color.primary.opacity(0.06))
        .cornerRadius(8)
        .overlay(alignment: .topLeading) { pointer }
        // Tied to the view's lifetime, so switching to the next app cancels
        // this loop and the new one starts from its own first step.
        .task(id: bundleID) { await runLoop() }
        // The animation is decoration; the instruction is the sentence. Say
        // it once, plainly, for anyone not watching it.
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            "In System Settings for \(appName), untick Desktop"
                + (needsSoundChange ? ", and turn off play sound for notification." : ".")
        )
    }

    // MARK: Pieces

    private enum Destination { case desktop, notificationCenter, lockScreen }

    /// One of Tahoe's three destination checkboxes: a little illustration of
    /// where the notification lands, its name, and a checkbox underneath.
    @ViewBuilder
    private func destinationTile(_ destination: Destination, label: String, checked: Bool) -> some View {
        VStack(spacing: 4) {
            ZStack {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.accentColor.opacity(0.45), Color.purple.opacity(0.4)],
                            startPoint: .top, endPoint: .bottom
                        )
                    )
                switch destination {
                case .desktop:
                    // One banner, top-right, over an empty desktop.
                    RoundedRectangle(cornerRadius: 1.5)
                        .fill(.white.opacity(0.9))
                        .frame(width: 18, height: 5)
                        .offset(x: 12, y: -8)
                case .notificationCenter:
                    // The stack down the right edge.
                    VStack(spacing: 1.5) {
                        ForEach(0..<5, id: \.self) { _ in
                            RoundedRectangle(cornerRadius: 1.5)
                                .fill(.white.opacity(0.9))
                                .frame(width: 18, height: 4)
                        }
                    }
                    .offset(x: 12)
                case .lockScreen:
                    // A clock, centred.
                    Text("9:41")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundStyle(.white.opacity(0.95))
                        .offset(y: -6)
                }
            }
            .frame(width: Geo.tileWidth - 10, height: 34)

            Text(label)
                .font(.system(size: 10))
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
                // Two lines' worth: "Notification / Center" is the widest
                // label, and a height that only fits one truncates it to
                // "Notification…" rather than wrapping.
                .frame(height: 26)

            checkbox(checked: checked, emphasised: destination == .desktop)
        }
        .frame(width: Geo.tileWidth, height: Geo.tileHeight, alignment: .top)
    }

    @ViewBuilder
    private func checkbox(checked: Bool, emphasised: Bool) -> some View {
        RoundedRectangle(cornerRadius: 3, style: .continuous)
            .fill(checked ? Color.accentColor : Color.primary.opacity(0.12))
            .overlay {
                if checked {
                    Image(systemName: "checkmark")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 3, style: .continuous)
                    .strokeBorder(Color.primary.opacity(checked ? 0 : 0.25), lineWidth: 1)
            }
            .frame(width: 16, height: 16)
            .scaleEffect(pressed && emphasised && target == .desktop ? 0.85 : 1)
    }

    /// The pointer, plus the click ripple, positioned over whichever control
    /// the current step is about.
    @ViewBuilder
    private var pointer: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .strokeBorder(Color.accentColor.opacity(0.9), lineWidth: 1.5)
                .frame(width: 24, height: 24)
                .scaleEffect(ripple ? 1.7 : 0.4)
                .opacity(ripple ? 0 : 0.9)
                .offset(x: anchor.x - 12, y: anchor.y - 12)

            Image(systemName: pressed ? "cursorarrow.click" : "cursorarrow")
                .font(.system(size: 15))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.6), radius: 1.5, y: 0.5)
                .offset(x: anchor.x, y: anchor.y)
        }
        .opacity(cursorVisible ? 1 : 0)
        .allowsHitTesting(false)
    }

    /// Where the pointer sits for the current target, in the demo's own
    /// coordinates (offset by the container's 10pt padding).
    private var anchor: CGPoint {
        let padding: CGFloat = 10
        switch target {
        case .desktop:
            // The checkbox under the first tile — half its 16pt height up
            // from the tile's bottom edge.
            return CGPoint(x: padding + Geo.tileWidth / 2, y: padding + Geo.tileHeight - 8)
        case .sound:
            return CGPoint(
                x: padding + Geo.width - 14,
                y: padding + Geo.tileHeight + 17 + Geo.soundRowHeight / 2
            )
        case .parked:
            // Off the bottom-right corner, where it fades in and out of.
            return CGPoint(
                x: padding + Geo.width - 4,
                y: padding + Geo.tileHeight + 17 + Geo.soundRowHeight + 30
            )
        }
    }

    // MARK: The loop

    private func runLoop() async {
        // Under Reduce Motion the demo holds the *answer* still instead of
        // animating toward it — the sentence above carries the instruction
        // either way.
        guard !reduceMotion else {
            desktopChecked = false
            soundIsOn = false
            return
        }

        while !Task.isCancelled {
            withTransaction(Transaction(animation: nil)) {
                desktopChecked = true
                soundIsOn = true
                target = .parked
                cursorVisible = false
                pressed = false
                ripple = false
            }
            if await sleep(0.6) { return }

            if needsDesktopChange {
                withAnimation(.easeOut(duration: 0.25)) { cursorVisible = true }
                withAnimation(.easeInOut(duration: 0.7)) { target = .desktop }
                if await sleep(0.85) { return }
                if await click({ desktopChecked = false }) { return }
                if await sleep(0.9) { return }
            }

            if needsSoundChange {
                if !cursorVisible {
                    withAnimation(.easeOut(duration: 0.25)) { cursorVisible = true }
                }
                withAnimation(.easeInOut(duration: 0.6)) { target = .sound }
                if await sleep(0.75) { return }
                if await click({ soundIsOn = false }) { return }
                if await sleep(1.2) { return }
            }

            withAnimation(.easeIn(duration: 0.3)) {
                cursorVisible = false
                target = .parked
            }
            if await sleep(1.1) { return }
        }
    }

    /// Press, ripple, commit the change, release. Returns true if cancelled.
    private func click(_ commit: @escaping () -> Void) async -> Bool {
        withAnimation(.easeIn(duration: 0.08)) { pressed = true }
        withAnimation(.easeOut(duration: 0.5)) { ripple = true }
        if await sleep(0.13) { return true }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) { commit() }
        withAnimation(.easeOut(duration: 0.15)) { pressed = false }
        withTransaction(Transaction(animation: nil)) { ripple = false }
        return false
    }

    /// `true` when the view went away mid-sleep and the loop should stop.
    private func sleep(_ seconds: Double) async -> Bool {
        try? await Task.sleep(nanoseconds: UInt64(seconds * 1_000_000_000))
        return Task.isCancelled
    }
}


// MARK: - Onboarding Assistant Panel Controller

@MainActor
final class OnboardingAssistantPanelController: NSObject, NSWindowDelegate {
    static let shared = OnboardingAssistantPanelController()

    private var panel: NSPanel?
    private var onDismiss: (() -> Void)?

    func present(
        mode: OnboardingAssistantView.Mode,
        onGrantConfirmed: @escaping () -> Void = {},
        onDismiss: (() -> Void)? = nil
    ) {
        if panel != nil {
            dismiss()
        }

        self.onDismiss = onDismiss

        // A deterministic content height per mode, not one measured off
        // SwiftUI (`fittingSize` can read stale on macOS 26) — an NSPanel
        // that guesses wrong clips the content or leaves a dead band under
        // it. The ad-hoc-signing warning is the only conditional block.
        //
        // Measured, not guessed — and re-measured when the type scale
        // (`HelperType`) grew. Each mode was hosted in an off-screen
        // `NSHostingView` at `panelWidth` and its `fittingSize` read once: a
        // single static layout is the one case that read is trustworthy, it
        // goes stale only against a same-turn state change. Content came out
        // at 233 (Full Disk Access), 452 (one app) and 479 (several), and the
        // ad-hoc-signing warning adds 61 + 12pt of stack spacing on top of
        // the first.
        //
        // Every constant below is a measurement plus ~20pt, because the
        // measured layouts used one short app name and the blurb names the
        // app: a long one buys a line. Slack falls to the bottom of the
        // panel; being short clips the button off it.
        let height: CGFloat
        switch mode {
        case .fullDiskAccess:
            height = SystemIntegration.permissionPersistenceWarning == nil ? 256 : 328
        case .nativeBanners(let findings):
            // Header, blurb, the row replica, the demo (fixed size by
            // construction), status line and button — plus one row for the
            // step dots, which only exist when there's more than one app.
            var banners: CGFloat = findings.count > 1 ? 504 : 476
            // Not in either measurement: the "macOS doesn't list this app"
            // warning, which only an explicitly-named app ever reaches.
            if findings.contains(where: { !$0.hasSettingsRow }) {
                banners += 40
            }
            height = banners
        }

        let width = OnboardingAssistantView.panelWidth
        let newPanel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: width, height: height),
            styleMask: [.titled, .closable, .utilityWindow, .nonactivatingPanel, .hudWindow],
            backing: .buffered,
            defer: false
        )
        newPanel.level = .popUpMenu
        newPanel.isFloatingPanel = true
        newPanel.titleVisibility = .hidden
        newPanel.titlebarAppearsTransparent = true
        newPanel.isMovableByWindowBackground = false
        newPanel.isReleasedWhenClosed = false
        // The whole point of this panel is to be readable *while* the user
        // is in System Settings. Under a tiling WM (AeroSpace) that's a
        // different workspace than the one flick's window was on, and a
        // panel bound to one space would simply vanish at the moment it's
        // needed — so join all of them.
        newPanel.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .ignoresCycle]
        newPanel.hidesOnDeactivate = false

        let hostingView = NSHostingView(
            rootView: OnboardingAssistantView(
                mode: mode,
                onGrantConfirmed: onGrantConfirmed,
                onClose: { [weak self] in
                    self?.dismiss()
                }
            )
        )
        newPanel.contentView = hostingView

        // Bottom-right of the screen the user is actually looking at —
        // `NSScreen.main` follows the *key window*, which by now belongs to
        // System Settings on some other display; the pointer is the better
        // proxy for where the user's attention is.
        let pointerScreen = NSScreen.screens.first { $0.frame.contains(NSEvent.mouseLocation) }
        if let screen = pointerScreen ?? NSScreen.main {
            let visibleFrame = screen.visibleFrame
            let x = visibleFrame.maxX - (width + 10)
            let y = visibleFrame.minY + 40
            newPanel.setFrameOrigin(NSPoint(x: x, y: y))
        } else {
            newPanel.center()
        }

        // The native red traffic light is now the only way to close this by
        // hand, so it has to run the same teardown the in-content button
        // used to — otherwise clicking it would strand `onDismiss` and
        // Settings would never come back.
        newPanel.delegate = self

        newPanel.orderFrontRegardless()
        self.panel = newPanel
    }

    func dismiss() {
        panel?.close() // `windowWillClose` does the teardown, once.
    }

    func windowWillClose(_ notification: Notification) {
        guard let closing = notification.object as? NSWindow, closing === panel else { return }
        closing.delegate = nil
        panel = nil
        let callback = onDismiss
        onDismiss = nil
        callback?()
    }
}
