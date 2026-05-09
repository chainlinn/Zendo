# Zendo

> 静けさの中で、時が流れる — In stillness, time flows.

A minimalist Mac Pomodoro timer. Menu bar icon + floating overlay panel.
Design philosophy: Japanese Zen × Exaggerated Minimalism.

## Features

- **Floating timer panel** — toggle from menu bar, stays visible across spaces
- **Live waveform ring** — four-frequency organic wave, flows during countdown, breathes on pause
- **Three-phase colors** — vermilion focus, blue short break, green long break
- **GitHub-style heatmap** — 26-week contribution graph tracking daily focus minutes
- **Custom durations** — presets (15/25/50 min) or arbitrary via inline prompt
- **Resizable panels** — both timer and stats windows freely resizable
- **Persistent** — last-used durations and panel position remembered
- **Zero dependencies** — pure SwiftUI + AppKit, no third-party packages

## Requirements

- macOS 14.0+ (Sonoma or later)
- Apple Silicon (arm64)

## Install

Download the latest `Zendo.dmg` from [Releases](https://github.com/chainlinn/Zendo/releases),
open and drag Zendo to Applications.

## Build from source

```bash
make build          # Compile → .build/Zendo.app
make run            # Build + launch
make dmg            # Build + create DMG
make clean          # Remove build artifacts
```

## Usage

| Action | How |
|---|---|
| Toggle timer panel | Click menu bar pill icon |
| Start focus | Click ring, or right-click → 开始专注 |
| Pause / Resume | Click ring during session |
| Skip / Reset | Long-press ring (0.6s) or right-click menu |
| Adjust duration | Scroll on panel while idle, or menu → custom |
| Stats | Right-click → 统计 |
| Launch at login | Right-click → 登录时启动 |

## License

MIT
