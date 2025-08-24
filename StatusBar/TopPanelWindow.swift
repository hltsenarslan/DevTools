import AppKit

final class TopPanelWindow: NSPanel {
    init(contentView: NSView) {
        let style: NSWindow.StyleMask = [.nonactivatingPanel, .borderless]
        super.init(contentRect: .zero, styleMask: style, backing: .buffered, defer: false)
        self.isOpaque = false
        self.backgroundColor = .clear
        self.level = .statusBar
        self.hidesOnDeactivate = false
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.hasShadow = true
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.standardWindowButton(.closeButton)?.isHidden = true
        self.standardWindowButton(.miniaturizeButton)?.isHidden = true
        self.standardWindowButton(.zoomButton)?.isHidden = true

        let container = NSVisualEffectView()
        container.material = .sidebar
        container.state = .active
        container.blendingMode = .behindWindow
        container.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(contentView)

        self.contentView = container

        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: container.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])

        isMovableByWindowBackground = true
        ignoresMouseEvents = false
        isFloatingPanel = true
    }
}