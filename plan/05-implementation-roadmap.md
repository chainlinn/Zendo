# 05 — Implementation Roadmap

## Phase 1: Skeleton (Day 1)

Bare minimum working timer in a floating window.

- [ ] Xcode project setup, SwiftUI lifecycle
- [ ] `TimerEngine` — state machine + countdown logic
- [ ] `TimerState` enum: `idle`, `focusing`, `breaking`, `paused`, `complete`
- [ ] `ContentView` — basic layout with timer display
- [ ] `FloatingPanel` — borderless NSWindow, floating level
- [ ] Start/Pause/Reset via button clicks (simple buttons, no ring yet)
- [ ] Unit tests for state transitions

**Exit criteria**: Can start a 25-min timer, see it count down, pause/resume, and see state transitions. Ugly but functional.

## Phase 2: Visual Core (Day 2–3)

The timer ring and design system.

- [ ] `Color+Tokens` — all design tokens as SwiftUI Color extensions
- [ ] `TimerRingView` — track arc + progress arc, custom Shape
- [ ] Smooth `CADisplayLink`-driven ring animation
- [ ] `TimerDisplay` — SF Mono ultralight numerals, tabular figures
- [ ] `StateLabel` — FOCUS/BREAK/PAUSED label
- [ ] Panel styling: background, border, corner radius
- [ ] Dark mode / Light mode adaptation via `@Environment(\.colorScheme)`
- [ ] Enso "organic" ring variance (stretch goal)

**Exit criteria**: Floating panel looks and feels polished. Ring animates smoothly. Colors adapt to light/dark.

## Phase 3: Menu Bar (Day 3–4)

Status bar integration.

- [ ] `MenuBarController` — NSStatusBar item
- [ ] `StatusBarIcon` — enso ring icon, monochrome
- [ ] Icon animation: ring fills as timer progresses
- [ ] Left-click: show/hide floating panel (positioned below status bar icon)
- [ ] Right-click: context menu (Start Focus durations, Break, Reset, Quit)
- [ ] Panel positioning: centers below status bar icon, within screen bounds

**Exit criteria**: App lives entirely in menu bar. Clicking the icon toggles the floating panel. Icon animates during sessions.

## Phase 4: Polish & Feel (Day 4–5)

Animation, haptics, accessibility.

- [ ] Panel show/hide animations (scale + opacity + translate)
- [ ] State transition animations (crossfade labels, ring color transitions)
- [ ] Completion dissolve animation (ring expands + fades)
- [ ] Paused breathing pulse
- [ ] `HapticEngine` — NSHapticFeedbackManager integration
- [ ] `SessionDots` — ●●○○ indicator
- [ ] Scroll-to-adjust duration on ring
- [ ] Duration persistence in UserDefaults
- [ ] Accessibility: keyboard navigation, VoiceOver labels, reduced-motion support
- [ ] Global hotkey registration (optional, user-configurable)

**Exit criteria**: Every interaction feels polished. Animations are smooth and meaningful. App is accessible.

## Phase 5: Ship (Day 5–6)

Final polish, icon, distribution.

- [ ] App icon design (enso on warm black)
- [ ] Launch at login helper
- [ ] About panel (minimal: name, version, a single haiku)
- [ ] Code signing
- [ ] DMG packaging
- [ ] Test on macOS 14.x and 15.x
- [ ] Performance verification: <15MB memory idle, <1% CPU

**Exit criteria**: Ready for distribution.

## Future Considerations (Intentionally Deferred)

These are explicitly NOT in scope for v1. They're noted here to clarify boundaries:

- ~~Multiple timers / task labels~~
- ~~Statistics / history~~
- ~~Notifications (sound, banner)~~
- ~~iOS companion~~
- ~~iCloud sync~~
- ~~Apple Watch app~~
- ~~Shortcuts integration~~
- ~~Scripting / CLI~~
