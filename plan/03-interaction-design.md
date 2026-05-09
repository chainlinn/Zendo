# 03 — Interaction Design

## Core States

```
         ┌──────────────────────────────────┐
         │             IDLE                  │
         │  (no session, ring at rest)       │
         └─────┬──────────────┬──────────────┘
               │ click "25"   │ click "5"
               ▼              ▼
    ┌──────────────┐  ┌──────────────┐
    │   FOCUSING   │  │   BREAKING   │
    │  (vermilion) │  │  (matcha)    │
    └──┬───┬───┬───┘  └──┬───┬───┬───┘
       │   │   │          │   │   │
       ▼   ▼   ▼          ▼   ▼   ▼
    PAUSE SKIP COMPLETE (same transitions)
```

### State: IDLE

- **Panel**: Timer ring full circle, hollow, muted color. Shows "25:00" in muted text. Below the ring: "FOCUS" label.
- **Status bar**: Hollow enso ring, no fill.
- **Available actions**: Click to start focus (25min default). Right-click for: 15min, 25min, 50min, or custom. Option-click to start break (5min default).

### State: FOCUSING

- **Panel**: Timer ring animates, subtracting clockwise. Vermillion (`--color-accent-focus`) progress. Numerals count down with tabular figures (no jitter). Below: "FOCUS" label in full accent color.
- **Status bar**: Ring fills clockwise.
- **Available actions**: 
  - Click ring → **Pause** (primary action)
  - Double-click label → **Skip** to break
  - Right-click → Reset, Skip, Switch to Break

### State: PAUSED (Focus or Break)

- **Panel**: Ring animation pauses. Numerals hold. Ring pulse: subtle opacity breathing (1.2s cycle, opacity 0.4 ↔ 1.0 on the progress arc). Label reads "PAUSED".
- **Status bar**: Ring holds. Subtle pulse.
- **Available actions**:
  - Click ring → **Resume**
  - Double-click → **Reset** to idle

### State: COMPLETE

- **Panel**: Ring is full color (session complete). Brief dissolve animation (300ms): the accent color softly diffuses outward, then fades. Panel switches to break/idle state with a gentle crossfade.
- **No alert sound.** Instead: a single, quiet haptic tap (NSHapticFeedbackManager on macOS).
- **Auto-transition**: After 3s pause, auto-starts break (if focus just completed) or returns to idle (if break completed).

## Interaction Map

### Status Bar Icon

| Action | Result |
|---|---|
| Left click | Toggle floating panel visibility |
| Right click | Context menu: Start Focus (25/15/50/Custom), Start Break (5/15), Reset, Quit |
| Drag | Standard macOS menu bar drag (reorder) |

### Floating Panel

| Action | Target | State | Result |
|---|---|---|---|
| Left click | Ring/circle area | Idle | Start 25min Focus |
| Left click | Ring/circle area | Focusing/Breaking | Pause |
| Left click | Ring/circle area | Paused | Resume |
| Double click | Ring | Focusing/Breaking | Skip to next phase |
| Right click | Anywhere | Any | Context menu |
| Scroll | Ring edge | Idle | Adjust duration ±1min |
| Option + click | Ring | Idle | Start Break |

### Global Hotkey (Default: unset, user-configurable)

| Combo | Result |
|---|---|
| User-defined | Toggle panel visibility |
| User-defined | Start/Pause timer |

## Animation Specifications

### Timer Ring Progression
- **Duration**: Continuous over session length (e.g., 25min)
- **Easing**: Linear (constant subtraction)
- **Update rate**: ~60fps via requestAnimationFrame or CADisplayLink

### State Transitions

| Transition | Duration | Easing | Effect |
|---|---|---|---|
| Idle → Active | `200ms` | `ease-out` | Ring color fades in from muted to accent. Numerals brighten. |
| Active → Paused | `250ms` | `ease-in-out` | Ring color desaturates. Label crossfades to "PAUSED". |
| Paused → Active | `200ms` | `ease-out` | Reverse of above. |
| Active → Complete | `300ms` | `ease-out` | Ring dissolves outward (scale 1.0→1.05, opacity 1→0). New state fades in. |
| Panel show | `200ms` | `ease-out` | Scale 0.96→1.0, opacity 0→1. Slight upward translate (4px). |
| Panel hide | `150ms` | `ease-in` | Scale 1.0→0.97, opacity 1→0. Slight downward translate (2px). |

### Breathing Pulse (Paused State)

```css
@keyframes pulse-subtle {
  0%, 100% { opacity: 0.4; }
  50% { opacity: 1.0; }
}
/* duration: 1.8s, easing: ease-in-out, infinite */
```

### Haptic Feedback

| Event | Haptic |
|---|---|
| Session start | `alignment` — subtle, confirming |
| Session complete | `levelChange` — gentle nudge |
| Pause/Resume | None (silence is meaningful) |
| Skip | `alignment` |

## Accessibility

- Full keyboard navigation: Tab to ring, Space to start/pause, Escape to dismiss panel
- VoiceOver: Timer announces time remaining every 5 minutes, and at 1-minute mark
- Reduced motion: All animations disabled; cuts to final state instantly
- Minimum contrast: All text meets 4.5:1 ratio. Ring progress against track meets 3:1.
- Focus ring visible when navigating via keyboard, hidden on mouse
