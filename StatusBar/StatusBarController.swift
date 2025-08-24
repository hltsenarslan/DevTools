// StatusBar/StatusBarController.swift
import AppKit
import SwiftUI

final class StatusBarController: NSObject {
    private var statusItem: NSStatusItem!
    private var panel: TopPanelWindow?
    private var globalMonitor: Any?
    private var localMonitor: Any?
    private var appearanceObserver: Any?

    private var isTouchBarOpen: Bool { TouchBarController.shared.isVisible }

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "hammer", accessibilityDescription: "DevTools")
            button.action = #selector(togglePanel)
            button.target = self
        }

        GlobalHotKey.register { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                if self.panel?.isVisible != true { self.openPanel() }

                let manifest = ManifestSource.load()
                TouchBarController.shared.present(tools: manifest.tools) { item in
                    switch item.type {
                    case .builtin: ToolRegistry.openBuiltin(id: item.id)
                    case .url: if let u = item.url { NSWorkspace.shared.open(u) }
                    }
                    TouchBarController.shared.dismiss()
                    self.closePanel()
                }
            }
        }
    }

    @objc private func togglePanel() {
        if panel?.isVisible == true { closePanel() } else { openPanel() }
    }

    private func openPanel() {
        // FULL-LIST view (sağ alan kaldırıldı)
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
        applyAppearance(to: panel)
        appearanceObserver = NotificationCenter.default.addObserver(
            forName: AppearanceDidChange, object: nil, queue: .main
        ) { [weak self] _ in
            if let p = self?.panel { self?.applyAppearance(to: p) }
        }
        panel.orderFrontRegardless()
        position(panel: panel)
        self.panel = panel

        NSApp.activate(ignoringOtherApps: true) // uygulamayı öne getir
        panel.makeKeyAndOrderFront(nil) // tek çağrı: key + front
        position(panel: panel)

        // ESC ile kapansın
        panel.makeKey() // key window olsun ki Esc çalışsın

        // Dış tıklama kapanışı
        globalMonitor = NSEvent.addGlobalMonitorForEvents(matching: [.leftMouseDown, .rightMouseDown]) { [weak self] event in
            guard let self, let panel = self.panel else { return }
            if self.isTouchBarOpen { return } // Touch Bar açıkken paneli kapatma
            let pt = event.locationInWindow
            let screenPt = event.window?.convertPoint(toScreen: pt) ?? pt
            if !panel.frame.contains(screenPt) {
                self.closePanel()
            }
        }
        // İçerideki tıklamaların normal akmasını sağla (bazı kombinasyonlarda gerekebilir)
        localMonitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown]) { [weak self] e in
            if e.keyCode == 53 { // Esc
                self?.closePanel()
                return nil
            }
            return e
        }
    }

    private func position(panel: TopPanelWindow) {
        guard let screen = NSScreen.screens.first else { return }
        let height: CGFloat = 600
        let width: CGFloat = 360
        let x = screen.visibleFrame.maxX - width - 12
        let y = screen.visibleFrame.maxY - height - 8
        panel.setFrame(NSRect(x: x, y: y, width: width, height: height), display: true)
    }

    private func closePanel() {
        if let gm = globalMonitor { NSEvent.removeMonitor(gm) }
        if let lm = localMonitor { NSEvent.removeMonitor(lm) }
        if let obs = appearanceObserver { NotificationCenter.default.removeObserver(obs) }
        appearanceObserver = nil
        globalMonitor = nil
        localMonitor = nil
        panel?.close()
        panel = nil
    }

    private func applyAppearance(to panel: NSWindow) {
        switch AppearancePrefs.current() {
        case .system: panel.appearance = nil
        case .light: panel.appearance = NSAppearance(named: .vibrantLight)
        case .dark: panel.appearance = NSAppearance(named: .vibrantDark)
        }
    }
}
