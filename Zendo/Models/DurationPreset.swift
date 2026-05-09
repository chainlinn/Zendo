import Foundation

struct DurationPreset: Identifiable, Equatable {
    let id: String
    let label: String
    let seconds: TimeInterval

    static let focus15    = DurationPreset(id: "focus15", label: "15 分钟", seconds: 15 * 60)
    static let focus25    = DurationPreset(id: "focus25", label: "25 分钟", seconds: 25 * 60)
    static let focus50    = DurationPreset(id: "focus50", label: "50 分钟", seconds: 50 * 60)
    static let break5     = DurationPreset(id: "break5",  label: "5 分钟",  seconds: 5 * 60)
    static let break15    = DurationPreset(id: "break15", label: "15 分钟", seconds: 15 * 60)

    static let focusPresets: [DurationPreset] = [.focus15, .focus25, .focus50]
    static let breakPresets: [DurationPreset] = [.break5, .break15]
    static let defaultFocus = focus25
    static let defaultBreak = break5
}
