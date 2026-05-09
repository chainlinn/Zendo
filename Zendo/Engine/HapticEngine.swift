import AppKit

enum HapticEvent {
    case sessionStart
    case sessionComplete
    case skip
}

struct HapticEngine {
    static func play(_ event: HapticEvent) {
        let performer = NSHapticFeedbackManager.defaultPerformer
        switch event {
        case .sessionStart:
            performer.perform(.alignment, performanceTime: .now)
        case .sessionComplete:
            performer.perform(.levelChange, performanceTime: .now)
        case .skip:
            performer.perform(.alignment, performanceTime: .now)
        }
    }
}
