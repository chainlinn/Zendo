import SwiftUI

struct TimerDisplay: View {
    let timeString: String
    let opacity: Double
    var ringSize: CGFloat = 140

    private var fontSize: CGFloat { ringSize * 0.12 }

    var body: some View {
        Text(timeString)
            .font(.system(size: fontSize, weight: .ultraLight, design: .monospaced))
            .monospacedDigit()
            .tracking(-0.5)
            .foregroundColor(.tokenTextPrimary)
            .opacity(opacity)
    }
}

#Preview {
    TimerDisplay(timeString: "25:00", opacity: 1.0)
        .padding()
        .background(Color.tokenBg)
}
