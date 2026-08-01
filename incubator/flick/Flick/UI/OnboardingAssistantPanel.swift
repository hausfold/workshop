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
    /// Fires once, right before relaunching, when the user confirms Full
    /// Disk Access was granted — the caller commits the setting through
    /// `AppSettings` so it's flushed to disk before the process exits.
    var onGrantConfirmed: () -> Void = {}
    let onClose: () -> Void

    @State private var isFDAGranted = false
    @State private var pollTimer: Timer?
    @State private var selectedTab = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: modeIcon)
                    .foregroundStyle(.tint)
                    .font(.title2)
                Text(modeTitle)
                    .font(.headline)
                Spacer()
                Button(action: onClose) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
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
        .frame(width: 350)
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

                HStack(spacing: 12) {
                    Image(nsImage: NSApp.applicationIconImage ?? NSImage(named: NSImage.applicationIconName)!)
                        .resizable()
                        .frame(width: 28, height: 28)
                    Text("Flick")
                        .font(.subheadline)
                        .bold()
                    Spacer()
                    Toggle("", isOn: .constant(true))
                        .labelsHidden()
                        .toggleStyle(.switch)
                        .controlSize(.small)
                }
                .padding(10)
                .background(Color.primary.opacity(0.06))
                .cornerRadius(8)
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

        if isFDAGranted {
            VStack(alignment: .leading, spacing: 8) {
                Label("Full Disk Access Granted", systemImage: "checkmark.circle.fill")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(.green)

                Text("System Mirror is active. No quit or restart required.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)

                HStack {
                    Spacer()
                    Button("Done") { onClose() }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.small)
                    Spacer()
                }
            }
            .padding(.top, 4)
        } else {
            HStack {
                ProgressView()
                    .controlSize(.small)
                Text("Waiting for switch toggle…")
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

    private func startFDAPolling() {
        pollTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            Task { @MainActor in
                let provider = SystemMirrorProvider()
                let health = await provider.probe()
                if case .ready = health {
                    isFDAGranted = true
                    pollTimer?.invalidate()
                    onGrantConfirmed()
                }
            }
        }
    }
}

// MARK: - Onboarding Assistant Panel Controller

@MainActor
final class OnboardingAssistantPanelController {
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

        let newPanel = NSPanel(
            contentRect: NSRect(x: 0, y: 0, width: 340, height: 260),
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

        newPanel.orderFrontRegardless()
        self.panel = newPanel
    }

    func dismiss() {
        panel?.close()
        panel = nil
        let callback = onDismiss
        onDismiss = nil
        callback?()
    }
}
