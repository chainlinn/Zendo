# 04 — Architecture

## Technology Decision

### Recommendation: SwiftUI Native macOS App

| Factor | SwiftUI | Tauri (Web) | Electron |
|---|---|---|---|
| Binary size | ~5MB | ~8MB | ~150MB |
| Memory (idle) | ~15MB | ~40MB | ~150MB |
| Native feel | ★★★★★ | ★★★☆☆ | ★★☆☆☆ |
| Status bar API | First-class (NSStatusBar) | Needs plugin/FFI | Needs plugin |
| Haptic API | First-class | Needs bridge | Needs bridge |
| Menu bar integration | Native NSMenu | Tauri menu API | Limited |
| Design iteration speed | Preview slow | Fast (HMR) | Fast (HMR) |
| Accessibility | Full VoiceOver | Good | Decent |

**Decision: SwiftUI + AppKit bridge for status bar control.**

The status bar item and floating panel behavior require tight macOS API integration. SwiftUI provides the rendering layer; AppKit provides `NSStatusBar`, `NSPopover`/`NSWindow` for the floating panel, and `NSHapticFeedbackManager`.

## Component Tree

```
App Entry (ZendoApp)
├── MenuBarController (AppKit)
│   ├── NSStatusBarButton (enso icon, animated)
│   └── NSMenu (right-click context actions)
├── FloatingPanelController (AppKit)
│   └── NSWindow (transparent, floating, non-activating)
│       └── ContentView (SwiftUI)
│           ├── TimerRingView
│           │   ├── TrackArc (background ring)
│           │   └── ProgressArc (animated progress)
│           ├── TimerDisplay (SF Mono numerals)
│           ├── StateLabel ("FOCUS" / "BREAK" / "PAUSED")
│           └── SessionDots (session counter: ●●○○)
└── TimerEngine (ObservableObject)
    ├── State machine (idle/focusing/breaking/paused/complete)
    ├── Countdown timer (CADisplayLink-driven)
    ├── Duration settings
    └── Haptic feedback trigger
```

## Data Flow

```
TimerEngine (single source of truth)
    │
    ├──▶ ContentView (SwiftUI @ObservedObject)
    │       ├──▶ TimerRingView (progress: Double 0...1)
    │       ├──▶ TimerDisplay (timeString: String)
    │       └──▶ StateLabel (sessionState: State)
    │
    ├──▶ MenuBarController
    │       └──▶ NSStatusBarButton (progress, state icon)
    │
    └──▶ HapticEngine (send feedback on state transitions)
```

## File Structure

```
Zendo/
├── ZendoApp.swift              // @main entry
├── Models/
│   ├── TimerState.swift        // Enum + state machine
│   └── DurationPreset.swift    // 15/25/50 min presets
├── Engine/
│   ├── TimerEngine.swift       // ObservableObject, countdown logic
│   └── HapticEngine.swift      // NSHapticFeedback wrapper
├── Views/
│   ├── ContentView.swift       // Floating panel root
│   ├── TimerRingView.swift     // Custom Shape + animation
│   ├── TimerDisplay.swift      // SF Mono numerals
│   ├── StateLabel.swift        // FOCUS/BREAK/PAUSED
│   └── SessionDots.swift       // ●●○○ indicator
├── MenuBar/
│   ├── MenuBarController.swift // NSStatusBar + NSMenu
│   └── StatusBarIcon.swift     // Animated enso icon
├── Window/
│   └── FloatingPanel.swift     // NSWindow configuration
├── Extensions/
│   └── Color+Tokens.swift      // Design token extensions
└── Resources/
    └── Assets.xcassets         // App icon, enso variations

ZendoTests/
└── TimerEngineTests.swift      // State machine + timer logic
```

## Key Technical Decisions

### Floating Panel Window Configuration

```swift
// Non-activating, stays above other apps but doesn't steal focus
window.level = .floating
window.collectionBehavior = [.canJoinAllSpaces, .transient]
window.isMovableByWindowBackground = true
window.styleMask = [.borderless, .nonactivatingPanel]
window.backgroundColor = .clear  // SwiftUI handles bg
window.hasShadow = false        // We draw our own border
```

### Timer Precision

Use `CADisplayLink` for smooth 60fps ring animation, synchronized to display refresh. The actual countdown uses `Timer.publish(every: 1.0)` for the second tick. DisplayLink drives ring progress between seconds for smooth continuous animation.

### Duration Persistence

Store only the last-used duration preset and session count in `UserDefaults`. No session history, no statistics. A single `Int` for lifetime sessions completed — used only for the subtle dot indicator (1–4 dots showing recent sessions).

### App Icon

A simple enso circle on a warm black background. No text. The icon is the same shape as the timer ring — instant recognition.
