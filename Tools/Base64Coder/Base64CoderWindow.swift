import AppKit
import SwiftUI

final class Base64CoderWindowController: NSWindowController {
    static let shared = Base64CoderWindowController()
    private init() {
        let hosting = NSHostingView(rootView: Base64CoderView())
        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 720, height: 520),
                           styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        win.title = "Base64 Coder"
        win.center()
        win.contentView = hosting
        super.init(window: win)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) { fatalError() }
    func show() { window?.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
}
