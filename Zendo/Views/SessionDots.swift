import SwiftUI

struct SessionDots: View {
    let completed: Int
    var ringSize: CGFloat = 140
    private let maxDots = 4

    private var dotSize: CGFloat { ringSize * 0.022 }
    private var spacing: CGFloat { ringSize * 0.036 }

    var body: some View {
        HStack(spacing: spacing) {
            ForEach(0..<maxDots, id: \.self) { index in
                Circle()
                    .fill(index < (completed % maxDots)
                          ? Color.tokenAccentFocus.opacity(0.6)
                          : Color.tokenRingTrack)
                    .frame(width: dotSize, height: dotSize)
            }
        }
    }
}

#Preview {
    SessionDots(completed: 3)
        .padding()
        .background(Color.tokenBg)
}
