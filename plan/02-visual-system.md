# 02 — Visual System

## Color Tokens

### Dark Mode (Primary — Status bar default)

Inspired by sumi ink on washi paper.

| Token | Value | Usage |
|---|---|---|
| `--color-bg` | `#1C1B1A` | Main background (warm black) |
| `--color-surface` | `#272524` | Floating panel, elevated surfaces |
| `--color-surface-hover` | `#302E2C` | Hover state on surface |
| `--color-text-primary` | `#F5F0EB` | Primary text (warm white) |
| `--color-text-secondary` | `#A09992` | Secondary text, labels |
| `--color-text-muted` | `#6B6560` | Disabled, tertiary info |
| `--color-accent-focus` | `#D53A1E` | Focus session — shu-iro (vermilion) |
| `--color-accent-break` | `#5B8C5A` | Break session — matcha green |
| `--color-ring-track` | `rgba(245,240,235,0.06)` | Timer ring background |
| `--color-border` | `rgba(245,240,235,0.08)` | Subtle borders |
| `--color-border-active` | `rgba(245,240,235,0.14)` | Active/hover border |

### Light Mode

Inspired by washi paper and sumi ink.

| Token | Value | Usage |
|---|---|---|
| `--color-bg` | `#FAF8F5` | Main background (washi) |
| `--color-surface` | `#FFFFFF` | Floating panel |
| `--color-surface-hover` | `#F5F2EE` | Hover state |
| `--color-text-primary` | `#2C2A28` | Primary text (sumi) |
| `--color-text-secondary` | `#6B6560` | Secondary text |
| `--color-text-muted` | `#A09992` | Disabled, tertiary |
| `--color-accent-focus` | `#C53316` | Focus session (adjusted for light bg) |
| `--color-accent-break` | `#4A7C59` | Break session (adjusted for light bg) |
| `--color-ring-track` | `rgba(44,42,40,0.06)` | Timer ring background |
| `--color-border` | `rgba(44,42,40,0.08)` | Subtle borders |
| `--color-border-active` | `rgba(44,42,40,0.14)` | Active/hover border |

### Accent Logic

- **Focus (work session)**: Warm vermilion. Active, alert, but not aggressive. The color of torii gates — boundary between mundane and sacred.
- **Break**: Muted matcha green. Rest, renewal, quiet. The color of whisked tea.
- **Idle (no session)**: No accent color. Just the muted text palette. The interface is at rest.

## Typography

### Mac Native Approach

For a truly native Mac experience, use SF Pro and SF Mono (system fonts). They cost zero rendering weight and feel native to macOS.

| Role | Font | Weight | Notes |
|---|---|---|---|
| Timer numerals | **SF Mono** | 200 (Ultralight) | Tabular figures keep digits from dancing |
| Panel labels | **SF Pro** | 400 (Regular) | "FOCUS" / "BREAK" labels |
| Status bar text | **SF Pro Text** | 500 (Medium) | Menu bar rendering |
| Session count dots | **SF Pro** | 400 | Subtle indicators |

### Web/Cross-Platform Fallback

If using web technology (Tauri): DM Sans for UI text, with tabular-nums for timer.

```css
--font-timer: 'SF Mono', 'JetBrains Mono', 'Fira Code', monospace;
--font-ui: 'SF Pro Display', 'DM Sans', -apple-system, sans-serif;
```

### Type Scale

| Token | Size | Line Height | Usage |
|---|---|---|---|
| `--text-timer` | `48px` | `1.0` | Main timer display |
| `--text-label` | `11px` | `1.0` | Section labels, state |
| `--text-body` | `13px` | `1.4` | Descriptions, tooltip |
| `--text-statusbar` | `12px` | `1.0` | Menu bar text |

Letter spacing: `0.04em` on labels (slightly open for clarity). Timer numerals at `-0.02em` (tight, precise).

## Spacing System

Based on 4px atomic unit.

| Token | Value | Usage |
|---|---|---|
| `--space-xs` | `4px` | Inner tight |
| `--space-sm` | `8px` | Icon gap, dot spacing |
| `--space-md` | `16px` | Panel padding, ring margin |
| `--space-lg` | `24px` | Section separation |
| `--space-xl` | `48px` | Panel breathing room |

Floating panel padding: `24px` all sides. Timer ring margin from panel edge: `20px`.

## Timer Ring

The central visual element. A circular progress indicator.

- **Stroke width**: `1.5px` — hairline, understated
- **Track**: `--color-ring-track`, always visible
- **Progress**: `--color-accent-focus` or `--color-accent-break`, advancing
- **Cap**: `round` — soft finish
- **Start/End**: `-90deg` — starts from top
- **Easing**: Custom bezier `cubic-bezier(0.4, 0.0, 0.2, 1.0)` — natural decay feel
- **Empty state**: Ring at full circle, no accent — at rest

### Enso Touch (Stretch)

The ring path uses a subtle organic distortion — not a perfect circle, but one with ±1px variance simulating hand-drawn brushwork. This is the "unforgettable detail."

## Panel Shape

- **Corner radius**: `12px` — modern but not trendy
- **Shadow**: None. Flat edges with hairline border.
- **Size**: `180px × 180px` (compact) or `220px × 220px` (standard)
- **Toggled via**: clicking status bar icon, or global hotkey

## Status Bar Icon

- **Monochrome glyph**: A simple circle (enso) outline
- **Idle state**: Hollow ring, `1px` stroke
- **Active state**: Ring fills clockwise as timer progresses (miniature version of the panel ring)
- **Break state**: Same ring, matcha green
- **Size**: Standard macOS menu bar icon (`18px` height, line width)
