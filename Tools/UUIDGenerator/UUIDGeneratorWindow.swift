import AppKit
import SwiftUI

final class UUIDGeneratorWindowController: NSWindowController {
    static let shared = UUIDGeneratorWindowController()
    private init() {
        let hosting = NSHostingView(rootView: UUIDGeneratorView())
        let win = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 560, height: 420),
            styleMask: [.titled, .closable, .resizable],
            backing: .buffered, defer: false
        )
        win.title = "UUID Generator"
        win.center()
        win.contentView = hosting
        super.init(window: win)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) { fatalError() }
    func show() { window?.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
}
