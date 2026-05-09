import Foundation

enum TimerState: Equatable {
    case idle
    case focusing
    case breaking
    case paused
    case complete

    var label: String {
        switch self {
        case .idle:     return "就绪"
        case .focusing: return "专注"
        case .breaking: return "休息"
        case .paused:   return "暂停"
        case .complete: return "完成"
        }
    }

    var isActive: Bool {
        switch self {
        case .focusing, .breaking: return true
        case .idle, .paused, .complete: return false
        }
    }

    var isRunning: Bool {
        switch self {
        case .focusing, .breaking: return true
        case .idle, .paused, .complete: return false
        }
    }
}
