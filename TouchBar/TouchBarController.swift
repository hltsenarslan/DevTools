// TouchBar/TouchBarController.swift
import Cocoa

/// Manifest’teki tool’ları Touch Bar’da gösterir.
/// Kalıcı, görünmez bir host pencere & view kullanır; böylece responder/yaşam döngüsü stabil kalır.
final class TouchBarController: NSObject, NSTouchBarDelegate {
    static let shared = TouchBarController()

    // Ekran durumu
    private(set) var isVisible = false

    // İçerik
    private var tools: [ToolItem] = []
    private var onSelect: ((ToolItem) -> Void)?

    // Kalıcı host pencere & view
    private let hostWindow: KeyHostWindow
    private let hostView: HostView

    override init() {
        // 1×1, borderless, şeffaf, tüm alanlarda görünen, **key olabilen** pencere
        let win = KeyHostWindow(
            contentRect: NSRect(x: 0, y: 0, width: 1, height: 1),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        win.isOpaque = false
        win.backgroundColor = .clear
        win.hasShadow = false
        win.level = .statusBar
        win.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        win.isReleasedWhenClosed = false
        win.ignoresMouseEvents = true // Görünmez/etkisiz; sadece Touch Bar kaynağı

        let view = HostView()
        win.contentView = view

        hostWindow = win
        hostView = view
        super.init()
    }

    /// Touch Bar’ı göster / güncelle.
    func present(tools: [ToolItem], onSelect: @escaping (ToolItem) -> Void) {
        guard !tools.isEmpty else { return }
        self.tools = tools
        self.onSelect = onSelect

        // İçeriği host view’a ver
        hostView.configure(tools: tools) { [weak self] item in
            guard let self else { return }
            self.onSelect?(item)
            self.dismiss()
        }

        // Uygulamayı öne al + host’u KEY/FirstResponder yap
        NSApp.activate(ignoringOtherApps: true)
        hostWindow.makeKeyAndOrderFront(nil)
        hostWindow.orderFrontRegardless()
        hostWindow.makeFirstResponder(hostView)

        // Touch Bar’ı yeniden oluştur: responder toggle + varsa invalidateTouchBar selector
        if hostWindow.firstResponder === hostView { hostWindow.makeFirstResponder(nil) }
        hostWindow.makeFirstResponder(hostView)
        let sel = NSSelectorFromString("invalidateTouchBar")
        if hostView.responds(to: sel) { _ = hostView.perform(sel) }

        // İlk karelerde responder kaybı olmasın diye kısa re-assert
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            guard let self else { return }
            self.hostWindow.makeFirstResponder(self.hostView)
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
            guard let self else { return }
            self.hostWindow.makeFirstResponder(self.hostView)
        }

        isVisible = true
    }

    /// Touch Bar’ı kapat (host pencere saklanır; yeniden kullanım için tutulur).
    func dismiss() {
        isVisible = false
        hostWindow.orderOut(nil)
        tools.removeAll()
        onSelect = nil
    }

    // MARK: - İç Host View (Touch Bar kaynağı)

    private final class HostView: NSView, NSTouchBarDelegate {
        private var tools: [ToolItem] = []
        private var onSelect: ((ToolItem) -> Void)?

        func configure(tools: [ToolItem], onSelect: @escaping (ToolItem) -> Void) {
            self.tools = tools
            self.onSelect = onSelect
        }

        override var acceptsFirstResponder: Bool { true }
        override var canBecomeKeyView: Bool { true }

        override func makeTouchBar() -> NSTouchBar? {
            let tb = NSTouchBar()
            tb.delegate = self
            tb.defaultItemIdentifiers = tools.map { NSTouchBarItem.Identifier($0.id) }
            return tb
        }

        func touchBar(_: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
            guard let idx = tools.firstIndex(where: { $0.id == identifier.rawValue }) else { return nil }
            let tool = tools[idx]
            let item = NSCustomTouchBarItem(identifier: identifier)

            let button = NSButton(title: tool.name, target: self, action: #selector(tap(_:)))
            button.bezelStyle = .texturedRounded
            button.tag = idx
            item.view = button
            return item
        }

        @objc private func tap(_ sender: NSButton) {
            let idx = sender.tag
            guard idx >= 0, idx < tools.count else { return }
            let tool = tools[idx]
            onSelect?(tool)
            window?.orderOut(nil)
        }
    }
}

/// Borderless pencerenin **key** olmasına izin veren alt sınıf
private final class KeyHostWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }
}
