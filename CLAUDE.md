# CLAUDE.md — Zendo

## Project

Zendo is a minimalist Mac Pomodoro timer. Menu bar icon + floating overlay panel.
Design philosophy: **Japanese Zen × Exaggerated Minimalism** — stillness, understated elegance, presence.

## Quick Start

```bash
make build          # Compile → .build/Zendo.app
make run            # Build + launch
make clean          # Remove build artifacts
```

Manual build:
```bash
swiftc -sdk $(xcrun --show-sdk-path --sdk macosx) \
       -target arm64-apple-macos14.0 -O \
       -o .build/Zendo.app/Contents/MacOS/Zendo \
       Zendo/**/*.swift
```

The app is a menu bar accessory (LSUIElement=true). Look for the enso circle icon in the menu bar. Click to toggle the floating panel.

## Design System

### Colors (Dark Mode Default)
- Background: `#1C1B1A` (warm sumi black)
- Surface: `#272524`
- Text primary: `#F5F0EB` (warm white), secondary: `#A09992`, muted: `#6B6560`
- Accent focus: `#D53A1E` (vermilion/torii red)
- Accent break: `#5B8C5A` (matcha green)
- Ring track: `rgba(245,240,235,0.06)`, border: `rgba(245,240,235,0.08)`

### Typography
- Timer numerals: **SF Mono**, Ultralight (200), tabular figures — no jitter on countdown
- Labels: **SF Pro**, Regular (400), `0.04em` letter spacing
- Status bar: **SF Pro Text**, Medium (500)

### Spacing
4px atomic unit. Panel padding 24px. Ring stroke 1.5px. Corner radius 12px.

### Key Visual
A single hairline timer ring (enso circle). Subtle organic ±1px variance for hand-brush feel (stretch). No shadows, no gradients, no glassmorphism.

### Anti-Patterns
- Never use Inter, Roboto, Arial
- Never add gradients, drop shadows, glassmorphism, neon
- Never add gamification, streaks, statistics, social features
- Never use emojis as icons
- Never add notifications with sound
- Never add task lists or todo integration

## Tech Stack

**SwiftUI + AppKit bridge** for native macOS feel.
- Status bar: `NSStatusBar` + `NSStatusBarButton`
- Floating panel: `NSWindow` with `.floating` level, `.borderless` style, non-activating
- Timer engine: `ObservableObject` with `CADisplayLink` for ring animation
- Haptics: `NSHapticFeedbackManager`
- Storage: `UserDefaults` for last-used duration + session count only

## File Structure
```
Zendo/
├── ZendoApp.swift              // @main
├── Models/
│   ├── TimerState.swift        // idle/focusing/breaking/paused/complete
│   └── DurationPreset.swift
├── Engine/
│   ├── TimerEngine.swift       // ObservableObject, countdown
│   └── HapticEngine.swift
├── Views/
│   ├── ContentView.swift
│   ├── TimerRingView.swift     // Custom Shape, CADisplayLink
│   ├── TimerDisplay.swift      // SF Mono numerals
│   ├── StateLabel.swift
│   └── SessionDots.swift
├── MenuBar/
│   ├── MenuBarController.swift
│   └── StatusBarIcon.swift
├── Window/
│   └── FloatingPanel.swift
├── Extensions/
│   └── Color+Tokens.swift
└── Resources/
    └── Assets.xcassets
```

## Development Conventions

- All color values use semantic tokens (`Color.tokenBg`, `Color.tokenTextPrimary`), never raw hex
- Timer state is a single enum with exhaustive switch handling — no `default:` branches
- Ring animation uses `CADisplayLink`, not `Timer` or `withAnimation`
- Floating panel is non-activating (doesn't steal focus)
- Panel toggles via status bar click; positions below status bar icon
- No third-party dependencies for core features. Keep it zero-dependency.
- Target macOS 14.0+ (Sonoma)
- Unit tests for TimerEngine state machine transitions only

## Design Documents

See `/plan/` for full design specification:
- `01-design-vision.md` — Philosophy, tone, anti-vision
- `02-visual-system.md` — Color tokens, typography, spacing, ring spec
- `03-interaction-design.md` — States, interaction map, animation specs
- `04-architecture.md` — Tech decision, component tree, data flow
- `05-implementation-roadmap.md` — Phased build plan

## Session Behavior

When implementing features for Zendo:
1. Prioritize stillness — add only what's essential
2. Every visual element must earn its place
3. Test in both light and dark mode
4. Respect `reduceMotion` accessibility setting
5. Verify tabular figures (no layout shift on timer ticks)
6. Never add features from the "Future Considerations" list without explicit user request

## Tip
Use Chines with user
