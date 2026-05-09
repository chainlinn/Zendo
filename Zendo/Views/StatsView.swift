import SwiftUI

struct StatsView: View {
    @ObservedObject var store: StatsStore
    private let weeks = 26

    // Matcha green scale
    private let colors: [Color] = [
        Color(red: 0.18, green: 0.18, blue: 0.18),
        Color(red: 0.15, green: 0.38, blue: 0.25),
        Color(red: 0.18, green: 0.48, blue: 0.30),
        Color(red: 0.22, green: 0.58, blue: 0.36),
        Color(red: 0.28, green: 0.68, blue: 0.42),
    ]

    @State private var tooltipText: String = ""
    @State private var showTooltip: Bool = false
    @State private var hideWorkItem: DispatchWorkItem?

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "M月d日"
        return f
    }()

    var body: some View {
        let grid = store.heatmapData(weeks: weeks)
        let totalFocus = store.dailyMinutes.values.reduce(0, +)
        let totalHours = totalFocus / 60

        GeometryReader { geometry in
            let availableW = geometry.size.width - 14 - 16 - 8
            let cellSpacing: CGFloat = max(2, availableW * 0.011)
            let cellSize = max(6, (availableW - cellSpacing * CGFloat(weeks - 1)) / CGFloat(weeks))

            VStack(spacing: 0) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("统计")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.tokenTextPrimary)
                        if showTooltip {
                            Text(tooltipText)
                                .font(.system(size: 10))
                                .foregroundColor(.tokenAccentBreakShort)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(Color.tokenAccentBreakShort.opacity(0.10))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                                .transition(.opacity.animation(.easeInOut(duration: 0.12)))
                        } else {
                            Text("近 \(weeks) 周累计")
                                .font(.system(size: 10))
                                .foregroundColor(.tokenTextMuted)
                        }
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(totalHours) 小时")
                            .font(.system(size: 13, weight: .medium, design: .monospaced))
                            .foregroundColor(.tokenTextPrimary)
                        Text("\(totalFocus) 分钟")
                            .font(.system(size: 10))
                            .foregroundColor(.tokenTextMuted)
                    }
                }
                .padding(.horizontal, 12)
                .padding(.top, 8)

                Spacer(minLength: 4)

                // Day labels + grid
                HStack(alignment: .top, spacing: 2) {
                    VStack(spacing: cellSpacing) {
                        ForEach(0..<7, id: \.self) { row in
                            Text(dayLabel(row))
                                .font(.system(size: min(10, cellSize * 1.1)))
                                .foregroundColor(.tokenTextMuted)
                                .frame(width: 14, height: cellSize, alignment: .trailing)
                        }
                    }

                    VStack(spacing: cellSpacing) {
                        ForEach(0..<7, id: \.self) { row in
                            HStack(spacing: cellSpacing) {
                                ForEach(0..<weeks, id: \.self) { col in
                                    let date = grid[row][col]
                                    let minutes = date.flatMap { store.minutes(for: $0) } ?? 0
                                    RoundedRectangle(cornerRadius: max(1, cellSize * 0.22))
                                        .fill(cellColor(for: minutes))
                                        .frame(width: cellSize, height: cellSize)
                                        .onHover { hovering in
                                            hideWorkItem?.cancel()
                                            if hovering, let date {
                                                let h = minutes / 60
                                                let m = minutes % 60
                                                let dateStr = dateFormatter.string(from: date)
                                                if h > 0 {
                                                    tooltipText = "\(h)h \(m)min · \(dateStr)"
                                                } else if minutes > 0 {
                                                    tooltipText = "\(m)min · \(dateStr)"
                                                } else {
                                                    tooltipText = "无记录 · \(dateStr)"
                                                }
                                                withAnimation(.easeInOut(duration: 0.10)) {
                                                    showTooltip = true
                                                }
                                            } else {
                                                let work = DispatchWorkItem {
                                                    withAnimation(.easeInOut(duration: 0.10)) {
                                                        showTooltip = false
                                                    }
                                                }
                                                hideWorkItem = work
                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.08, execute: work)
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)

                Spacer(minLength: 4)

                // Legend
                HStack(spacing: 4) {
                    Text("少")
                        .font(.system(size: 9))
                        .foregroundColor(.tokenTextMuted)
                    ForEach(0..<5, id: \.self) { level in
                        RoundedRectangle(cornerRadius: max(1, cellSize * 0.22))
                            .fill(colors[level])
                            .frame(width: cellSize, height: cellSize)
                    }
                    Text("多")
                        .font(.system(size: 9))
                        .foregroundColor(.tokenTextMuted)
                }
                .padding(.bottom, 8)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color.tokenSurface)
    }

    private func cellColor(for minutes: Int) -> Color {
        switch minutes {
        case 0:      return colors[0]
        case 1...15: return colors[1]
        case 16...30: return colors[2]
        case 31...60: return colors[3]
        default:     return colors[4]
        }
    }

    private func dayLabel(_ row: Int) -> String {
        ["日", "一", "二", "三", "四", "五", "六"][row]
    }
}

#Preview {
    StatsView(store: StatsStore())
        .background(Color.tokenBg)
        .frame(width: 540, height: 300)
}
