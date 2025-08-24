import AppKit
import SwiftUI

final class SystemInfoWindowController: NSWindowController {
    static let shared = SystemInfoWindowController()
    private init() {
        let hosting = NSHostingView(rootView: SystemInfoView())
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 800, height: 600),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false
        )
        win.title = "System Info"
        win.center()
        win.contentView = hosting
        super.init(window: win)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) { fatalError() }
    func show() { window?.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
}
