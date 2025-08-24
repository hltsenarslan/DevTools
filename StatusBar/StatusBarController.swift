import AppKit
import SwiftUI

final class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var panel: TopPanelWindow?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "hammer", accessibilityDescription: "DevTools")
            button.action = #selector(togglePanel)
            button.target = self
        }
    }

    @objc private func togglePanel() {
        if panel?.isVisible == true { closePanel() } else { openPanel() }
    }

    private func openPanel() {
        let hosting = NSHostingView(rootView: TopPanelView(onSelect: { [weak self] action in
            switch action {
            case let .openBuiltin(id):
                ToolRegistry.openBuiltin(id: id)
                self?.closePanel()
            case let .openURL(url):
                NSWorkspace.shared.open(url)
                self?.closePanel()
            case .quit:
                NSApp.terminate(nil)
            }
        }))

        let panel = TopPanelWindow(contentView: hosting)
        panel.orderFrontRegardless()
        position(panel: panel)
        self.panel = panel
    }

    private func position(panel: TopPanelWindow) {
        guard let screen = NSScreen.screens.first else { return }
        let height: CGFloat = 400
        let width: CGFloat = 800
        let x = screen.visibleFrame.maxX - width - 12
        let y = screen.visibleFrame.maxY - height - 8
        panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
    }

    private func closePanel() { panel?.close(); panel = nil }
}
