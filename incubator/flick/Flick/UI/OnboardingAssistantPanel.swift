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
        case appMigration(bundleID: String, appName: String)
    }

    let mode: Mode
    /// Fires once, when the probe first sees Full Disk Access land — the
    /// caller commits the setting through `AppSettings` so it's flushed to
    /// disk, then this panel closes itself and hands back to Settings.
    var onGrantConfirmed: () -> Void = {}
    let onClose: () -> Void

    @State private var pollTimer: Timer?
    @State private var selectedTab = 0

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
                    .font(.headline)
                Spacer()
            }

            Divider()

            switch mode {
            case .fullDiskAccess:
                fullDiskAccessContent
            case .appMigration(let bundleID, let appName):
                appMigrationContent(bundleID: bundleID, appName: appName)
            }
        }
        .padding(16)
        // The panel's height is fixed per mode (it can't be measured — see
        // the controller), so any slack goes to the bottom rather than being
        // split into two gaps around vertically-centred content.
        .frame(width: 350, alignment: .top)
        .frame(maxHeight: .infinity, alignment: .top)
        .background(.ultraThinMaterial)
        .onAppear {
            if case .fullDiskAccess = mode {
                startFDAPolling()
            }
        }
        .onDisappear {
            pollTimer?.invalidate()
        }
    }

    private var modeIcon: String {
        switch mode {
        case .fullDiskAccess: return "lock.shield"
        case .appMigration: return "bell.slash"
        }
    }

    private var modeTitle: String {
        switch mode {
        case .fullDiskAccess: return "Full Disk Access Setup"
        case .appMigration(_, let appName): return "Migrate \(appName) Banners"
        }
    }

    @ViewBuilder
    private var fullDiskAccessContent: some View {
        // An ad-hoc signed build has its TCC grant pinned to the binary's
        // cdhash, so the switch flips itself back off on the next rebuild.
        // Say so here rather than letting the user re-grant forever.
        if let warning = SystemIntegration.permissionPersistenceWarning {
            Label(warning, systemImage: "exclamationmark.triangle.fill")
                .font(.caption2)
                .foregroundStyle(.orange)
                .fixedSize(horizontal: false, vertical: true)
        }

        Picker("", selection: $selectedTab) {
            Text("If Already in List").tag(0)
            Text("If Missing").tag(1)
        }
        .pickerStyle(.segmented)
        .controlSize(.small)

        if selectedTab == 0 {
            VStack(alignment: .leading, spacing: 8) {
                Text("Find **Flick** in System Settings and turn its switch **ON**. If Apple prompts, click **Later**:")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                FlickSwitchDemo()
            }
        } else {
            VStack(alignment: .leading, spacing: 8) {
                Text("Drag the tile below into System Settings (or click **+**):")
                    .font(.caption)
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
                .font(.caption)
                .foregroundStyle(.tint)
            Text("Picked up the instant you flip it.")
                .font(.caption)
                .foregroundStyle(.secondary)
            Spacer()
            Button("Open Settings") {
                SystemIntegration.openFullDiskAccessSettings()
            }
            .font(.caption)
            .buttonStyle(.borderless)
        }
        .padding(.top, 4)
    }

    @ViewBuilder
    private func appMigrationContent(bundleID: String, appName: String) -> some View {
        Text("Prevent duplicate banners by adjusting Apple's notification settings for **\(appName)**:")
            .font(.subheadline)
            .foregroundStyle(.secondary)

        VStack(alignment: .leading, spacing: 8) {
            Label("Keep \"Allow Notifications\" ON", systemImage: "checkmark.circle")
                .font(.caption)
                .foregroundStyle(.green)
            Label("Uncheck \"Banners\"", systemImage: "xmark.circle")
                .font(.caption)
                .foregroundStyle(.orange)
            Label("Uncheck \"Play Sound\"", systemImage: "speaker.slash")
                .font(.caption)
                .foregroundStyle(.orange)
        }
        .padding(8)
        .background(Color.primary.opacity(0.05))
        .cornerRadius(6)

        Button("Open \(appName) Settings") {
            SystemIntegration.openNotificationSettings(for: bundleID)
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.small)
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
                .frame(width: 28, height: 28)
            Text("Flick")
                .font(.subheadline)
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
        let height: CGFloat
        switch mode {
        case .fullDiskAccess:
            height = SystemIntegration.permissionPersistenceWarning == nil ? 264 : 320
        case .appMigration:
            height = 300
        }

        let newPanel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 350, height: height),
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
            let x = visibleFrame.maxX - 360
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
