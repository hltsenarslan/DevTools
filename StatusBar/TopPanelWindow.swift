// StatusBar/TopPanelWindow.swift
import AppKit

final class TopPanelWindow: NSPanel {
    // init DIŞINDA override’lar:
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { false }

    init(contentView: NSView) {
        super.init(
            contentRect: .zero,
            styleMask: [.nonactivatingPanel, .borderless],
            backing: .buffered,
            defer: false
        )

        // Tam şeffaf pencere + gölge
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        level = .statusBar
        hidesOnDeactivate = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        ignoresMouseEvents = false
        isFloatingPanel = true
        becomesKeyOnlyIfNeeded = false

        // Blur katmanı
        let blur = NSVisualEffectView(frame: .zero)
        blur.material = .menu // alternatif: .sidebar, .underWindowBackground
        blur.blendingMode = .withinWindow // cam efekti için daha iyi
        blur.state = .active
        blur.wantsLayer = true
        blur.layer?.cornerRadius = 18
        blur.layer?.masksToBounds = true
        blur.translatesAutoresizingMaskIntoConstraints = false

        contentView.translatesAutoresizingMaskIntoConstraints = false
        blur.addSubview(contentView)
        self.contentView = blur

        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: blur.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: blur.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: blur.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: blur.bottomAnchor),
        ])
    }
}
