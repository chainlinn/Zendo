import SwiftUI
import Combine

final class TimerEngine: ObservableObject {
    @Published var state: TimerState = .idle
    @Published var progress: Double = 1.0
    @Published var timeString: String = "25:00"
    @Published var sessionCount: Int = 0

    let stats = StatsStore()

    /// Current session durations (persisted).
    var currentFocusDuration: TimeInterval { focusDuration }
    var currentBreakDuration: TimeInterval { breakDuration }

    /// Exposed for three-phase color logic: focus / short break / long break.
    var currentTotalSeconds: TimeInterval { totalSeconds }

    private var totalSeconds: TimeInterval = 0
    private var remainingSeconds: TimeInterval = 0
    private var timerCancellable: AnyCancellable?
    private var startTime: Date?
    private var pausedElapsed: TimeInterval = 0
    private var sessionIsFocus: Bool = true

    private var focusDuration: TimeInterval = 25 * 60
    private var breakDuration: TimeInterval = 5 * 60

    private let defaults = UserDefaults.standard

    init() {
        sessionCount = defaults.integer(forKey: "sessionCount")
        loadDurations()
        updateDisplay(for: focusDuration)
    }

    // MARK: - Duration Persistence

    private func loadDurations() {
        let savedFocus = defaults.double(forKey: "focusDuration")
        let savedBreak = defaults.double(forKey: "breakDuration")
        focusDuration = savedFocus > 0 ? savedFocus : 25 * 60
        breakDuration = savedBreak > 0 ? savedBreak : 5 * 60
    }

    private func saveDurations() {
        defaults.set(focusDuration, forKey: "focusDuration")
        defaults.set(breakDuration, forKey: "breakDuration")
    }

    // MARK: - Actions

    func startFocus(duration: TimeInterval? = nil) {
        let d = duration ?? focusDuration
        focusDuration = d
        saveDurations()
        totalSeconds = d
        updateDisplay(for: d)
        startSession(duration: d, state: .focusing)
        HapticEngine.play(.sessionStart)
    }

    func startBreak(duration: TimeInterval? = nil) {
        let d = duration ?? breakDuration
        breakDuration = d
        saveDurations()
        totalSeconds = d
        updateDisplay(for: d)
        startSession(duration: d, state: .breaking)
        HapticEngine.play(.sessionStart)
    }

    func pause() {
        guard state.isRunning else { return }
        timerCancellable?.cancel()
        timerCancellable = nil
        if let start = startTime {
            pausedElapsed += Date().timeIntervalSince(start)
        }
        startTime = nil
        state = .paused
    }

    func resume() {
        guard case .paused = state else { return }
        state = sessionIsFocus ? .focusing : .breaking
        startTime = Date()
        startTimer()
    }

    func skip() {
        timerCancellable?.cancel()
        timerCancellable = nil
        completeSession()
    }

    func reset() {
        timerCancellable?.cancel()
        timerCancellable = nil
        startTime = nil
        pausedElapsed = 0
        state = .idle
        remainingSeconds = totalSeconds
        updateDisplay(for: totalSeconds)
        progress = 1.0
    }

    func adjustDuration(by deltaMinutes: Int) {
        guard case .idle = state else { return }
        // Determine which duration to adjust based on what's currently displayed
        if totalSeconds == focusDuration {
            focusDuration = max(1 * 60, min(60 * 60, focusDuration + TimeInterval(deltaMinutes) * 60))
            totalSeconds = focusDuration
        } else {
            breakDuration = max(1 * 60, min(30 * 60, breakDuration + TimeInterval(deltaMinutes) * 60))
            totalSeconds = breakDuration
        }
        remainingSeconds = totalSeconds
        updateDisplay(for: totalSeconds)
        progress = 1.0
        saveDurations()
    }

    func setFocusCustomDuration(minutes: Int) {
        guard case .idle = state else { return }
        focusDuration = TimeInterval(max(1, min(60, minutes))) * 60
        totalSeconds = focusDuration
        remainingSeconds = totalSeconds
        updateDisplay(for: totalSeconds)
        progress = 1.0
        saveDurations()
    }

    func setBreakCustomDuration(minutes: Int) {
        guard case .idle = state else { return }
        breakDuration = TimeInterval(max(1, min(30, minutes))) * 60
        totalSeconds = breakDuration
        remainingSeconds = totalSeconds
        updateDisplay(for: totalSeconds)
        progress = 1.0
        saveDurations()
    }

    /// Switch idle display between focus and break duration (for scroll context).
    func showFocusDuration() {
        guard case .idle = state else { return }
        totalSeconds = focusDuration
        remainingSeconds = totalSeconds
        updateDisplay(for: totalSeconds)
        progress = 1.0
    }

    func showBreakDuration() {
        guard case .idle = state else { return }
        totalSeconds = breakDuration
        remainingSeconds = totalSeconds
        updateDisplay(for: totalSeconds)
        progress = 1.0
    }

    // MARK: - Session Lifecycle

    private func startSession(duration: TimeInterval, state: TimerState) {
        timerCancellable?.cancel()
        totalSeconds = duration
        remainingSeconds = duration
        pausedElapsed = 0
        sessionIsFocus = state == .focusing
        self.state = state
        startTime = Date()
        updateDisplay(for: duration)
        progress = 1.0
        updateDisplay(for: duration)
        startTimer()
    }

    // MARK: - Timer

    private func startTimer() {
        timerCancellable = Timer.publish(every: 1.0 / 60.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] now in
                self?.tick(at: now)
            }
    }

    private func tick(at now: Date) {
        guard state.isRunning, let start = startTime else { return }

        let elapsed = now.timeIntervalSince(start) + pausedElapsed
        remainingSeconds = max(0, totalSeconds - elapsed)
        progress = totalSeconds > 0 ? remainingSeconds / totalSeconds : 0

        updateDisplay(for: remainingSeconds)

        if remainingSeconds <= 0 {
            completeSession()
        }
    }

    private func completeSession() {
        timerCancellable?.cancel()
        timerCancellable = nil
        startTime = nil
        pausedElapsed = 0

        let wasFocusing = sessionIsFocus

        state = .complete
        progress = 1.0
        remainingSeconds = 0
        updateDisplay(for: 0)
        HapticEngine.play(.sessionComplete)

        if wasFocusing {
            sessionCount += 1
            defaults.set(sessionCount, forKey: "sessionCount")
            let minutes = Int(totalSeconds / 60)
            stats.recordFocus(minutes: minutes)
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let self, case .complete = self.state else { return }
            if wasFocusing {
                self.startBreak()
            } else {
                self.reset()
            }
        }
    }

    // MARK: - Display

    private func updateDisplay(for seconds: TimeInterval) {
        let total = Int(ceil(seconds))
        let mins = total / 60
        let secs = total % 60
        timeString = String(format: "%d:%02d", mins, secs)
    }
}
