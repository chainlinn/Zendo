import SwiftUI
import AppKit

final class FloatingPanel: NSPanel {
    private let onScroll: ((Int) -> Void)?
    private let defaults = UserDefaults.standard

    init(contentView: some View, onScroll: ((Int) -> Void)? = nil) {
        self.onScroll = onScroll

        let savedFrame = FloatingPanel.savedFrame()
        let initialFrame = savedFrame ?? NSRect(x: 0, y: 0, width: 200, height: 200)

        super.init(
            contentRect: initialFrame,
            styleMask: [.borderless, .nonactivatingPanel, .resizable],
            backing: .buffered,
            defer: false
        )

        self.isFloatingPanel = true
        self.level = .floating
        self.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        self.isMovableByWindowBackground = true
        self.titleVisibility = .hidden
        self.titlebarAppearsTransparent = true
        self.isOpaque = false
        self.backgroundColor = .clear
        self.hasShadow = false
        self.animationBehavior = .none
        self.isReleasedWhenClosed = false

        self.contentMinSize = NSSize(width: 160, height: 160)
        self.contentMaxSize = NSSize(width: 400, height: 400)

        let hostingView = NSHostingView(rootView: contentView)
        hostingView.wantsLayer = true
        hostingView.layer?.cornerRadius = 12
        hostingView.layer?.masksToBounds = true

        self.contentView = hostingView

        // Observe frame changes for persistence
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(frameDidChange),
            name: NSWindow.didResizeNotification,
            object: self
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(frameDidChange),
            name: NSWindow.didMoveNotification,
            object: self
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func scrollWheel(with event: NSEvent) {
        let delta = event.scrollingDeltaY
        if abs(delta) > 0.5 {
            onScroll?(delta > 0 ? 1 : -1)
        }
    }

    func toggle(relativeTo button: NSStatusBarButton?) {
        if isVisible {
            orderOut(nil)
        } else {
            positionNearStatusBar(relativeTo: button)
            show()
        }
    }

    override func close() {
        orderOut(nil)
    }

    @objc private func frameDidChange() {
        Self.saveFrame(frame)
    }

    // MARK: - Frame Persistence

    private static func savedFrame() -> NSRect? {
        let defaults = UserDefaults.standard
        guard let dict = defaults.dictionary(forKey: "panelFrame"),
              let x = dict["x"] as? Double,
              let y = dict["y"] as? Double,
              let w = dict["w"] as? Double,
              let h = dict["h"] as? Double,
              w >= 160, h >= 160 else { return nil }
        let frame = NSRect(x: x, y: y, width: w, height: h)
        // Verify the saved frame is visible on at least one screen
        for screen in NSScreen.screens {
            if screen.visibleFrame.intersects(frame) { return frame }
        }
        return nil
    }

    private static func saveFrame(_ frame: NSRect) {
        let dict: [String: Double] = [
            "x": frame.origin.x,
            "y": frame.origin.y,
            "w": frame.size.width,
            "h": frame.size.height
        ]
        UserDefaults.standard.set(dict, forKey: "panelFrame")
    }

    // MARK: - Show / Hide

    private func show() {
        alphaValue = 0
        orderFront(nil)
        NSAnimationContext.runAnimationGroup { ctx in
            ctx.duration = 0.2
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            animator().alphaValue = 1.0
        }
    }

    private func positionNearStatusBar(relativeTo button: NSStatusBarButton?) {
        // Only auto-position if there's no saved frame
        guard Self.savedFrame() == nil else { return }

        guard let button, let buttonWindow = button.window else {
            guard let screen = NSScreen.main else { return }
            let screenFrame = screen.visibleFrame
            let panelSize = frame.size
            setFrameOrigin(NSPoint(
                x: screenFrame.midX - panelSize.width / 2,
                y: screenFrame.maxY - panelSize.height - 12
            ))
            return
        }
        let buttonFrame = buttonWindow.frame
        let panelSize = frame.size
        let x = buttonFrame.midX - panelSize.width / 2
        let y = buttonFrame.minY - panelSize.height - 4
        setFrameOrigin(NSPoint(x: x, y: y))
    }
}
