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
    private var statusItem: NSStatusItem?

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
        if inboxWindow == nil {
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 480, height: 420),
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.titlebarAppearsTransparent = true
            window.isReleasedWhenClosed = false
            window.center()
            window.contentView = NSHostingView(
                rootView: InboxView(database: runtime?.inboxDatabase)
            )
            inboxWindow = window
        }
        inboxWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate()
    }

    @objc private func showSettings() {
        guard let runtime else { return }
        Task { @MainActor in
            let status = await runtime.providerStatusSnapshot()
            let window = NSWindow(
                contentRect: .zero,
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            window.title = "Flick Settings"
            window.isReleasedWhenClosed = false
            window.contentView = NSHostingView(
                rootView: SettingsView(settings: runtime.settings, providerStatus: status)
            )
            window.center()
            window.makeKeyAndOrderFront(nil)
            NSApp.activate()
        }
    }
}
