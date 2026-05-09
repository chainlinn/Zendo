import SwiftUI
import AppKit

extension Color {
    // MARK: - Light Mode Values
    private enum Light {
        static let bg            = hex(0xFAF8F5)
        static let surface       = hex(0xFFFFFF)
        static let textPrimary   = hex(0x2C2A28)
        static let textSecondary = hex(0x6B6560)
        static let textMuted     = hex(0xA09992)
        static let accentFocus   = hex(0xE05C5C)
        static let accentBreakShort = hex(0x5C9EE0)
        static let accentBreakLong  = hex(0x5CE09A)
        static let ringTrack     = Color(.sRGB, red: 0.1725, green: 0.1647, blue: 0.1569, opacity: 0.06)
        static let border        = Color(.sRGB, red: 0.1725, green: 0.1647, blue: 0.1569, opacity: 0.08)
    }

    // MARK: - Dark Mode Values
    private enum Dark {
        static let bg            = hex(0x1C1B1A)
        static let surface       = hex(0x272524)
        static let textPrimary   = hex(0xF5F0EB)
        static let textSecondary = hex(0xA09992)
        static let textMuted     = hex(0x6B6560)
        static let accentFocus   = hex(0xE05C5C)
        static let accentBreakShort = hex(0x5C9EE0)
        static let accentBreakLong  = hex(0x5CE09A)
        static let ringTrack     = Color(.sRGB, red: 0.9608, green: 0.9412, blue: 0.9216, opacity: 0.06)
        static let border        = Color(.sRGB, red: 0.9608, green: 0.9412, blue: 0.9216, opacity: 0.08)
    }

    private static func hex(_ hex: UInt32) -> Color {
        let r = Double((hex >> 16) & 0xFF) / 255.0
        let g = Double((hex >> 8) & 0xFF) / 255.0
        let b = Double(hex & 0xFF) / 255.0
        return Color(.sRGB, red: r, green: g, blue: b)
    }

    private static func dynamic(light: Color, dark: Color) -> Color {
        Color(NSColor(name: nil) { appearance in
            appearance.name == .darkAqua || appearance.name == .vibrantDark
                ? NSColor(dark)
                : NSColor(light)
        })
    }

    // MARK: - Token Accessors

    static let tokenBg            = dynamic(light: Light.bg,            dark: Dark.bg)
    static let tokenSurface       = dynamic(light: Light.surface,       dark: Dark.surface)
    static let tokenTextPrimary   = dynamic(light: Light.textPrimary,   dark: Dark.textPrimary)
    static let tokenTextSecondary = dynamic(light: Light.textSecondary, dark: Dark.textSecondary)
    static let tokenTextMuted     = dynamic(light: Light.textMuted,     dark: Dark.textMuted)
    static let tokenAccentFocus   = dynamic(light: Light.accentFocus,      dark: Dark.accentFocus)
    static let tokenAccentBreakShort = dynamic(light: Light.accentBreakShort, dark: Dark.accentBreakShort)
    static let tokenAccentBreakLong  = dynamic(light: Light.accentBreakLong,  dark: Dark.accentBreakLong)
    static let tokenRingTrack     = dynamic(light: Light.ringTrack,        dark: Dark.ringTrack)
    static let tokenBorder        = dynamic(light: Light.border,           dark: Dark.border)
    static let tokenRingRemaining = Color.white.opacity(0.18)
}

private extension NSColor {
    convenience init(_ color: Color) {
        let resolved = color.resolve(in: .init())
        self.init(
            red: Double(resolved.red),
            green: Double(resolved.green),
            blue: Double(resolved.blue),
            alpha: Double(resolved.opacity)
        )
    }
}
