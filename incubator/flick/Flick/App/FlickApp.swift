import AppKit
import SwiftUI

/// Entry point. One binary, two personalities (the pounce trick):
///
///   `Flick.app` launched normally  → the LSUIElement daemon + compositor;
///   `flick send --title …`         → a short-lived CLI talking to the
///                                    daemon's socket, no NSApplication.
///
/// The `flick` command on PATH is a shim to
/// `Flick.app/Contents/MacOS/Flick`, installed by the rice.
@main
enum FlickMain {
    static func main() {
        let arguments = Array(CommandLine.arguments.dropFirst())
        if let first = arguments.first, FlickCLI.subcommands.contains(first) {
            exit(FlickCLI.run(arguments: arguments))
        }

        let app = NSApplication.shared
        let delegate = FlickAppDelegate()
        app.delegate = delegate
        app.setActivationPolicy(.accessory) // belt-and-braces with LSUIElement
        app.run()
    }
}

/// AppKit-only, so the whole delegate lives on the main actor — the `@objc`
/// menu selectors touch `AppRuntime` (itself `@MainActor`) and would otherwise
/// be inferred `nonisolated`.
@MainActor
final class FlickAppDelegate: NSObject, NSApplicationDelegate {
    private var runtime: AppRuntime?
    private var inboxWindow: NSWindow?
    private var settingsWindow: NSWindow?
    private var statusItem: NSStatusItem?
    private let windowManager = UtilityWindowManager()

    func applicationDidFinishLaunching(_ notification: Notification) {
        let runtime = AppRuntime()
        self.runtime = runtime
        runtime.start()
        installStatusItem()
    }

    func applicationWillTerminate(_ notification: Notification) {
        runtime?.stop()
    }

    /// Quiet by default: a template glyph, an inbox, settings, quit.
    private func installStatusItem() {
        let item = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        item.button?.image = NSImage(
            systemSymbolName: "circle.dotted",
            accessibilityDescription: "Flick"
        )

        let menu = NSMenu()
        menu.addItem(withTitle: "Inbox", action: #selector(showInbox), keyEquivalent: "i").target = self
        menu.addItem(withTitle: "Settings…", action: #selector(showSettings), keyEquivalent: ",").target = self
        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit Flick", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        item.menu = menu
        statusItem = item
    }

    @objc private func showInbox() {
        inboxWindow?.close()

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 480, height: 420),
            styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
            backing: .buffered,
            defer: false
        )
        window.titlebarAppearsTransparent = true
        window.contentView = NSHostingView(
            rootView: InboxView(database: runtime?.inboxDatabase)
        )
        inboxWindow = window
        windowManager.show(window)
    }

    @objc private func showSettings() {
        guard let runtime else { return }
        Task { @MainActor in
            let status = await runtime.providerStatusSnapshot()
            settingsWindow?.close()

            // A deterministic frame, not one measured off SwiftUI's
            // fittingSize (which can read stale content from the same run
            // loop turn as a @State change) — an unsized NSWindow shows
            // only its titlebar, which is the bug this replaced. Form's
            // own scrolling absorbs any content taller than this.
            //
            // contentView (NSHostingView), not contentViewController
            // (NSHostingController) — the controller variant auto-resizes
            // the window to the view's "preferred content size" once
            // layout settles, which for a Form without a fixed height
            // collapses it back down to titlebar-only, silently undoing
            // this frame.
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 440, height: 420),
                styleMask: [.titled, .closable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.title = "Flick Settings"
            window.contentView = NSHostingView(
                rootView: SettingsView(
                    settings: runtime.settings,
                    providerStatus: status,
                    onRequestFullDiskAccess: { [weak self] in
                        self?.presentFullDiskAccessAssistant(runtime: runtime)
                    }
                )
            )
            settingsWindow = window
            windowManager.show(window)
        }
    }

    private func presentFullDiskAccessAssistant(runtime: AppRuntime) {
        // Order is load-bearing: closing the Settings window first drops
        // the app back to `.accessory` (UtilityWindowManager), and an
        // accessory app has no active-app status to hand over — macOS then
        // launches System Settings *behind* whatever was in front, which
        // under AeroSpace means behind the tile the user is staring at. So
        // open the deep link while flick is still the frontmost regular
        // app, and tidy our own window up on the next runloop turn.
        SystemIntegration.presentFullDiskAccessAssistant(
            onGrantConfirmed: { runtime.settings.systemMirrorEnabled = true },
            onDismiss: { [weak self] in self?.showSettings() }
        )
        DispatchQueue.main.async { [weak self] in
            self?.settingsWindow?.close()
        }
    }
}
