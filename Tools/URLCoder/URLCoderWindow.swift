import AppKit
import SwiftUI

final class URLCoderWindowController: NSWindowController {
    static let shared = URLCoderWindowController()
    private init() {
        let hosting = NSHostingView(rootView: URLCoderView())
        let win = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 720, height: 520),
                           styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
        win.title = "URL Encoder / Decoder"
        win.center()
        win.contentView = hosting
        super.init(window: win)
    }

    @available(*, unavailable) required init?(coder _: NSCoder) { fatalError() }
    func show() { window?.makeKeyAndOrderFront(nil); NSApp.activate(ignoringOtherApps: true) }
}
