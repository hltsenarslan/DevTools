import AppKit
import SwiftUI

final class JSONBeautifierWindowController: NSWindowController {
    static let shared = JSONBeautifierWindowController()

    private init() {
        let root = JSONBeautifierView()
        let hosting = NSHostingView(rootView: root)
        let window = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 720, height: 520),
                              styleMask: [.titled, .closable, .miniaturizable, .resizable],
                              backing: .buffered, defer: false)
        window.title = "JSON Beautifier"
        window.center()
        window.contentView = hosting
        super.init(window: window)
    }

    @available(*, unavailable) required init?(coder: NSCoder) { fatalError() }

    func show() {
        self.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}