import SwiftUI

struct ContentView: View {
    @ObservedObject var engine: TimerEngine
    @State private var isVisible = false

    private var accentColor: Color {
        switch engine.state {
        case .breaking:
            return engine.currentTotalSeconds <= 5 * 60 + 1
                ? .tokenAccentBreakShort
                : .tokenAccentBreakLong
        case .focusing, .idle, .paused, .complete:
            return .tokenAccentFocus
        }
    }

    private var timerOpacity: Double {
        switch engine.state {
        case .idle: return 0.5
        case .complete: return 0.3
        case .focusing, .breaking, .paused: return 1.0
        }
    }

    var body: some View {
        GeometryReader { geometry in
            let availableSize = min(geometry.size.width, geometry.size.height)
            let ringSize = max(100, availableSize - 40)

            VStack(spacing: 0) {
                Spacer()

                ZStack {
                    TimerRingView(
                        progress: engine.progress,
                        accentColor: accentColor,
                        state: engine.state,
                        ringSize: ringSize
                    )

                    VStack(spacing: ringSize * 0.04) {
                        TimerDisplay(
                            timeString: engine.timeString,
                            opacity: timerOpacity,
                            ringSize: ringSize
                        )
                        .animation(.easeInOut(duration: 0.25), value: timerOpacity)

                        StateLabel(state: engine.state, accentColor: accentColor, ringSize: ringSize)
                            .id("label-\(engine.state.label)")
                            .transition(.opacity)
                    }
                    .animation(.easeInOut(duration: 0.2), value: engine.state)
                }

                Spacer()

                SessionDots(completed: engine.sessionCount, ringSize: ringSize)
                    .padding(.bottom, ringSize * 0.043)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
        .background(Color.tokenSurface)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.tokenBorder, lineWidth: 0.5)
        )
        .scaleEffect(isVisible ? 1.0 : 0.96)
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 4)
        .animation(.easeOut(duration: 0.2), value: isVisible)
        .onAppear {
            withAnimation(.easeOut(duration: 0.2)) {
                isVisible = true
            }
        }
        .onTapGesture { handleTap() }
        .onLongPressGesture(minimumDuration: 0.6, maximumDistance: 8) { handleLongPress() }
    }

    private func handleTap() {
        switch engine.state {
        case .idle:
            engine.startFocus()
        case .focusing, .breaking:
            engine.pause()
        case .paused:
            engine.resume()
        case .complete:
            break
        }
    }

    private func handleLongPress() {
        switch engine.state {
        case .focusing, .breaking, .paused:
            engine.skip()
        case .complete:
            engine.reset()
        case .idle:
            break
        }
    }
}

#Preview {
    ContentView(engine: TimerEngine())
        .frame(width: 200, height: 200)
}
