import AppKit
import SwiftUI

final class JWTInspectorWindowController: NSWindowController {
    static let shared = JWTInspectorWindowController()
    private init() {
        let hosting = NSHostingView(rootView: JWTInspectorView())
        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 760, height: 560),
                           styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        win.title = "JWT Inspector"
        win.center()
        win.contentView = hosting
        super.init(window: win)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) { fatalError() }
    func show() { window?.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
}
