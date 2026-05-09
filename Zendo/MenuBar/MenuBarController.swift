import SwiftUI
import AppKit
import Combine
import ServiceManagement

final class MenuBarController: NSObject, NSWindowDelegate {
    private var statusItem: NSStatusItem?
    private var floatingPanel: FloatingPanel?
    private let engine = TimerEngine()
    private var cancellables = Set<AnyCancellable>()
    private var aboutWindow: NSWindow?
    private var statsWindow: NSWindow?

    func setup() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusItem?.button {
            button.image = buildPillIcon()
            button.image?.isTemplate = true
            button.title = ""
            button.target = self
            button.action = #selector(statusBarClicked)
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }

        let panel = FloatingPanel(contentView: ContentView(engine: engine)) { [weak self] delta in
            self?.engine.adjustDuration(by: delta)
        }
        panel.delegate = self
        self.floatingPanel = panel

        engine.objectWillChange
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.statusItem?.button?.image = self?.buildPillIcon()
            }
            .store(in: &cancellables)

    }

    @objc private func statusBarClicked() {
        guard let event = NSApp.currentEvent else { return }

        if event.type == .rightMouseUp {
            showMenu()
        } else {
            floatingPanel?.toggle(relativeTo: statusItem?.button)
        }
    }

    // MARK: - Menu

    private func showMenu() {
        let menu = NSMenu()

        // Focus submenu
        let focusMenu = NSMenu()
        for preset in DurationPreset.focusPresets {
            let item = NSMenuItem(
                title: "专注 \(preset.label)",
                action: #selector(startFocusFromMenu(_:)),
                keyEquivalent: ""
            )
            item.representedObject = preset.seconds
            item.target = self
            focusMenu.addItem(item)
        }
        focusMenu.addItem(.separator())
        let customFocusItem = NSMenuItem(
            title: "自定义…",
            action: #selector(customFocusFromMenu),
            keyEquivalent: ""
        )
        customFocusItem.target = self
        focusMenu.addItem(customFocusItem)
        let focusItem = NSMenuItem(title: "开始专注", action: nil, keyEquivalent: "")
        focusItem.submenu = focusMenu
        menu.addItem(focusItem)

        // Break submenu
        let breakMenu = NSMenu()
        for preset in DurationPreset.breakPresets {
            let item = NSMenuItem(
                title: "休息 \(preset.label)",
                action: #selector(startBreakFromMenu(_:)),
                keyEquivalent: ""
            )
            item.representedObject = preset.seconds
            item.target = self
            breakMenu.addItem(item)
        }
        breakMenu.addItem(.separator())
        let customBreakItem = NSMenuItem(
            title: "自定义…",
            action: #selector(customBreakFromMenu),
            keyEquivalent: ""
        )
        customBreakItem.target = self
        breakMenu.addItem(customBreakItem)
        let breakItem = NSMenuItem(title: "开始休息", action: nil, keyEquivalent: "")
        breakItem.submenu = breakMenu
        menu.addItem(breakItem)

        menu.addItem(.separator())

        // State-dependent actions
        if engine.state.isActive {
            menu.addItem(NSMenuItem(title: "暂停", action: #selector(pauseFromMenu), keyEquivalent: "p"))
            menu.addItem(NSMenuItem(title: "跳过", action: #selector(skipFromMenu), keyEquivalent: "s"))
        }
        if case .paused = engine.state {
            menu.addItem(NSMenuItem(title: "继续", action: #selector(resumeFromMenu), keyEquivalent: "r"))
        }
        if case .complete = engine.state {
            menu.addItem(NSMenuItem(title: "重置", action: #selector(resetFromMenu), keyEquivalent: "r"))
        }
        if case .idle = engine.state {
            menu.addItem(NSMenuItem(title: "重置", action: #selector(resetFromMenu), keyEquivalent: "r"))
        }

        menu.addItem(.separator())

        // Login item toggle
        let loginItem = NSMenuItem(
            title: "登录时启动",
            action: #selector(toggleLoginItem),
            keyEquivalent: ""
        )
        loginItem.state = SMAppService.mainApp.status == .enabled ? .on : .off
        loginItem.target = self
        menu.addItem(loginItem)

        menu.addItem(.separator())

        menu.addItem(NSMenuItem(title: "统计", action: #selector(showStats), keyEquivalent: ""))

        // About
        menu.addItem(NSMenuItem(title: "关于 Zendo", action: #selector(showAbout), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "退出 Zendo", action: #selector(quitApp), keyEquivalent: "q"))

        menu.items.forEach { $0.target = self }
        statusItem?.popUpMenu(menu)
    }

    // MARK: - Menu Actions

    @objc private func startFocusFromMenu(_ sender: NSMenuItem) {
        let seconds = sender.representedObject as? TimeInterval ?? DurationPreset.defaultFocus.seconds
        engine.startFocus(duration: seconds)
        floatingPanel?.close()
    }

    @objc private func startBreakFromMenu(_ sender: NSMenuItem) {
        let seconds = sender.representedObject as? TimeInterval ?? DurationPreset.defaultBreak.seconds
        engine.startBreak(duration: seconds)
        floatingPanel?.close()
    }

    @objc private func pauseFromMenu() { engine.pause() }
    @objc private func resumeFromMenu() { engine.resume() }
    @objc private func skipFromMenu() { engine.skip() }
    @objc private func resetFromMenu() { engine.reset() }

    @objc private func toggleLoginItem() {
        do {
            if SMAppService.mainApp.status == .enabled {
                try SMAppService.mainApp.unregister()
            } else {
                try SMAppService.mainApp.register()
            }
        } catch {
            print("Zendo: login item toggle failed: \(error)")
        }
    }

    @objc private func customFocusFromMenu() {
        promptCustomDuration(title: "自定义专注时长", current: Int(engine.currentFocusDuration / 60), range: 1...60) { minutes in
            self.engine.startFocus(duration: TimeInterval(minutes) * 60)
            self.floatingPanel?.close()
        }
    }

    @objc private func customBreakFromMenu() {
        promptCustomDuration(title: "自定义休息时长", current: Int(engine.currentBreakDuration / 60), range: 1...30) { minutes in
            self.engine.startBreak(duration: TimeInterval(minutes) * 60)
            self.floatingPanel?.close()
        }
    }

    private func promptCustomDuration(title: String, current: Int, range: ClosedRange<Int>, completion: @escaping (Int) -> Void) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = "输入 \(range.lowerBound)–\(range.upperBound) 分钟"
        alert.alertStyle = .informational

        let input = NSTextField(frame: NSRect(x: 0, y: 0, width: 200, height: 24))
        input.stringValue = String(current)
        input.font = .systemFont(ofSize: 14)
        input.alignment = .center
        input.formatter = {
            let f = NumberFormatter()
            f.minimum = range.lowerBound as NSNumber
            f.maximum = range.upperBound as NSNumber
            f.allowsFloats = false
            return f
        }()
        alert.accessoryView = input

        alert.addButton(withTitle: "确定")
        alert.addButton(withTitle: "取消")

        alert.window.initialFirstResponder = input

        if alert.runModal() == .alertFirstButtonReturn {
            let minutes = max(range.lowerBound, min(range.upperBound, Int(input.stringValue) ?? current))
            completion(minutes)
        }
    }

    @objc private func showStats() {
        if statsWindow == nil {
            let hosting = NSHostingView(rootView: StatsView(store: engine.stats))
            hosting.frame = NSRect(x: 0, y: 0, width: 780, height: 320)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 780, height: 320),
                styleMask: [.titled, .closable, .resizable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.contentMinSize = NSSize(width: 420, height: 140)
            window.contentMaxSize = NSSize(width: 1200, height: 600)
            window.center()
            window.contentView = hosting
            window.isReleasedWhenClosed = false
            window.title = "统计"
            statsWindow = window
        }
        statsWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func showAbout() {
        if aboutWindow == nil {
            let aboutView = AboutView()
            let hosting = NSHostingView(rootView: aboutView)
            hosting.frame = NSRect(x: 0, y: 0, width: 180, height: 120)

            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 180, height: 120),
                styleMask: [.titled, .closable, .fullSizeContentView],
                backing: .buffered,
                defer: false
            )
            window.titlebarAppearsTransparent = true
            window.isMovableByWindowBackground = true
            window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
            window.center()
            window.contentView = hosting
            window.isReleasedWhenClosed = false
            window.title = "关于 Zendo"
            aboutWindow = window
        }
        aboutWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    @objc private func quitApp() { NSApp.terminate(nil) }

    // MARK: - Three-phase accent color

    private var accentNSColor: NSColor {
        switch engine.state {
        case .breaking:
            return engine.currentTotalSeconds <= 5 * 60 + 1
                ? nsColor(from: .tokenAccentBreakShort)
                : nsColor(from: .tokenAccentBreakLong)
        case .focusing, .idle, .paused, .complete:
            return nsColor(from: .tokenAccentFocus)
        }
    }

    private func nsColor(from color: Color) -> NSColor {
        let resolved = color.resolve(in: .init())
        return NSColor(
            red: Double(resolved.red),
            green: Double(resolved.green),
            blue: Double(resolved.blue),
            alpha: Double(resolved.opacity)
        )
    }

    // MARK: - Pill Icon

    private func buildPillIcon() -> NSImage {
        let pillH: CGFloat = 14
        let font = NSFont.monospacedDigitSystemFont(ofSize: 11, weight: .medium)
        let text = engine.timeString as NSString
        let textSize = text.size(withAttributes: [.font: font])
        let innerPad: CGFloat = 12

        let pillW = max(textSize.width + innerPad * 2, 54)
        let size = NSSize(width: pillW, height: 22)

        return NSImage(size: size, flipped: false) { [weak self] rect in
            guard let self, let ctx = NSGraphicsContext.current?.cgContext else { return false }

            let pillRect = CGRect(x: rect.minX, y: rect.midY - pillH / 2, width: rect.width, height: pillH)
            let pillPath = CGPath(roundedRect: pillRect, cornerWidth: pillH / 2, cornerHeight: pillH / 2, transform: nil)

            // Progress fill — clip pill to elapsed width from left
            if self.engine.state.isActive {
                let elapsed = 1.0 - self.engine.progress
                let fillW = rect.width * CGFloat(max(0, min(1, elapsed)))
                if fillW > 0 {
                    ctx.saveGState()
                    ctx.beginPath()
                    ctx.addRect(CGRect(x: 0, y: 0, width: fillW, height: rect.height))
                    ctx.clip()
                    ctx.setFillColor(self.accentNSColor.cgColor)
                    ctx.addPath(pillPath)
                    ctx.fillPath()
                    ctx.restoreGState()
                }
            }

            // Capsule outline
            ctx.setStrokeColor(NSColor.tertiaryLabelColor.cgColor)
            ctx.setLineWidth(1.0)
            ctx.addPath(pillPath)
            ctx.strokePath()

            // Time text centred inside
            let textPoint = NSPoint(
                x: rect.midX - textSize.width / 2,
                y: rect.midY - textSize.height / 2
            )
            let textColor = self.engine.state.isActive
                ? NSColor.labelColor
                : NSColor.tertiaryLabelColor
            text.draw(at: textPoint, withAttributes: [
                .font: font,
                .foregroundColor: textColor
            ])

            return true
        }
    }
}
