import Foundation

final class StatsStore: ObservableObject {
    @Published var dailyMinutes: [String: Int] = [:]

    private let defaults = UserDefaults.standard
    private let key = "dailyFocusMinutes"

    init() {
        load()
    }

    func recordFocus(minutes: Int, date: Date = Date()) {
        let dayKey = dayString(from: date)
        dailyMinutes[dayKey, default: 0] += minutes
        save()
    }

    func minutes(for date: Date) -> Int {
        dailyMinutes[dayString(from: date)] ?? 0
    }

    // MARK: - Heatmap data

    /// Returns (weeks × 7) grid for the last `weeks` weeks ending today.
    func heatmapData(weeks: Int = 26) -> [[Date?]] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        // Align to Sunday (or Monday). GitHub uses Sunday-start.
        let weekday = calendar.component(.weekday, from: today) // 1=Sun
        let daysFromSunday = weekday - 1
        let endDate = calendar.date(byAdding: .day, value: -daysFromSunday, to: today)!

        let totalDays = weeks * 7
        let startDate = calendar.date(byAdding: .day, value: -(totalDays - 1), to: endDate)!

        var grid: [[Date?]] = Array(repeating: Array(repeating: nil, count: weeks), count: 7)

        for dayOffset in 0..<totalDays {
            guard let date = calendar.date(byAdding: .day, value: dayOffset, to: startDate) else { continue }
            let col = dayOffset / 7
            let row = dayOffset % 7
            if col < weeks, row < 7 {
                grid[row][col] = date
            }
        }
        return grid
    }

    // MARK: - Private

    private func dayString(from date: Date) -> String {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        return f.string(from: date)
    }

    private func load() {
        if let dict = defaults.dictionary(forKey: key) as? [String: Int] {
            dailyMinutes = dict
        }
    }

    private func save() {
        defaults.set(dailyMinutes, forKey: key)
    }
}
