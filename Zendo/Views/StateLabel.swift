import SwiftUI

struct StateLabel: View {
    let state: TimerState
    var accentColor: Color = .tokenAccentFocus
    var ringSize: CGFloat = 140

    private var fontSize: CGFloat { ringSize * 0.04 }

    var body: some View {
        Text(state.label)
            .font(.system(size: fontSize, weight: .regular, design: .default))
            .tracking(2.0)
            .foregroundColor(state.isActive ? accentColor : .tokenTextMuted)
            .animation(.easeInOut(duration: 0.2), value: state.isActive ? accentColor : .tokenTextMuted)
    }
}

#Preview {
    VStack(spacing: 16) {
        StateLabel(state: .idle)
        StateLabel(state: .focusing, accentColor: .tokenAccentFocus)
        StateLabel(state: .breaking, accentColor: .tokenAccentBreakShort)
        StateLabel(state: .paused)
    }
    .padding()
    .background(Color.tokenBg)
}
