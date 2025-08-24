import AppKit
import SwiftUI

final class RegexTesterWindowController: NSWindowController {
    static let shared = RegexTesterWindowController()
    private init() {
        let hosting = NSHostingView(rootView: RegexTesterView())
        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 860, height: 560),
                           styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        win.title = "Regex Tester"
        win.center()
        win.contentView = hosting
        super.init(window: win)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) { fatalError() }
    func show() { window?.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
}
