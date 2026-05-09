import SwiftUI

struct TimerRingView: View {
    let progress: Double
    let accentColor: Color
    let state: TimerState
    var ringSize: CGFloat = 140

    private let strokeWidth: CGFloat = 1.5
    private let totalPoints = 1200   // 点数提高，波形更平滑

    // 尺寸缩放：规格稿 380px → 140px
    private var baseRadius: CGFloat { ringSize * 0.376 }
    private var clipHalfWidth: CGFloat { baseRadius * 0.28 }

    // 波形参数 — 全圈均匀，四频叠加
    private let freq1: Double = 22.0   // 主波，细密
    private let freq2: Double = 11.0   // 副波，舒缓
    private let freq3: Double = 37.0   // 高频细纹
    private let freq4: Double =  7.0   // 低频慢涌

    // 振幅（压浅版）按 ringSize 比例缩放
    private var amp1: Double { Double(ringSize) *  6.0 / 380.0 }
    private var amp2: Double { Double(ringSize) *  3.0 / 380.0 }
    private var amp3: Double { Double(ringSize) *  1.8 / 380.0 }
    private var amp4: Double { Double(ringSize) *  1.0 / 380.0 }

    @State private var dissolveScale: CGFloat = 1.0
    @State private var dissolveOpacity: Double = 1.0

    private var progressAngle: Double {
        -Double.pi / 2 + progress * 2 * Double.pi
    }

    private var ampMultiplier: Double {
        state == .paused ? 0.15 : 1.0
    }

    private var isAnimating: Bool {
        state == .focusing || state == .breaking
    }

    // MARK: - Body

    var body: some View {
        TimelineView(.animation(minimumInterval: 1.0 / 30.0, paused: !isAnimating)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let center = CGPoint(x: size.width / 2, y: size.height / 2)

                let breathingScale = isAnimating
                    ? 1.0 + CGFloat(sin(time * 1.1)) * 0.013
                    : 1.0

                context.translateBy(x: center.x, y: center.y)
                context.scaleBy(x: breathingScale, y: breathingScale)
                context.translateBy(x: -center.x, y: -center.y)

                let wavePath = buildWaveformPath(center: center, time: time)

                drawRemainingArc(&context, center: center, wavePath: wavePath)
                drawElapsedArc(&context, center: center, wavePath: wavePath)
            }
        }
        .frame(width: ringSize, height: ringSize)
        .scaleEffect(dissolveScale)
        .opacity(dissolveOpacity)
        .onChange(of: state) { _, newValue in
            if newValue == .complete { triggerDissolve() }
            else { dissolveScale = 1.0; dissolveOpacity = 1.0 }
        }
    }

    // MARK: - Drawing

    private func drawRemainingArc(
        _ context: inout GraphicsContext,
        center: CGPoint,
        wavePath: Path
    ) {
        guard progress < 0.9999 else { return }

        let clip = donutSlice(
            center: center,
            innerR: baseRadius - clipHalfWidth,
            outerR: baseRadius + clipHalfWidth,
            startAngle: progressAngle,
            endAngle: -Double.pi / 2 + 2 * Double.pi,
            clockwise: false
        )
        context.drawLayer { ctx in
            ctx.clip(to: clip)
            // 未用弧段：淡化（等待走过的时间）
            ctx.stroke(wavePath, with: .color(accentColor.opacity(0.22)), lineWidth: strokeWidth)
        }
    }

    private func drawElapsedArc(
        _ context: inout GraphicsContext,
        center: CGPoint,
        wavePath: Path
    ) {
        let start = -Double.pi / 2
        let end   = progressAngle
        guard abs(end - start) > 0.001 else { return }

        let clip = donutSlice(
            center: center,
            innerR: baseRadius - clipHalfWidth,
            outerR: baseRadius + clipHalfWidth,
            startAngle: start,
            endAngle: end,
            clockwise: false
        )
        context.drawLayer { ctx in
            ctx.clip(to: clip)
            // 已用弧段：原色（走过的时间饱满）
            ctx.stroke(wavePath, with: .color(accentColor), lineWidth: strokeWidth)
        }
    }

    // MARK: - Waveform Path

    private func buildWaveformPath(center: CGPoint, time: Double) -> Path {
        var path = Path()
        let m = ampMultiplier

        // 四个波的相位速度各不相同，正反方向交替，产生涌动感
        let p1 =  time * 2.2
        let p2 = -time * 1.5
        let p3 =  time * 3.4
        let p4 = -time * 0.9

        for i in 0...totalPoints {
            let frac  = Double(i) / Double(totalPoints)
            let angle = -Double.pi / 2 + frac * 2 * Double.pi

            let wave =
                sin(frac * 2 * .pi * freq1 + p1) * amp1 * m +
                sin(frac * 2 * .pi * freq2 + p2) * amp2 * m +
                sin(frac * 2 * .pi * freq3 + p3) * amp3 * m +
                sin(frac * 2 * .pi * freq4 + p4) * amp4 * m

            let r  = Double(baseRadius) + wave
            let px = center.x + CGFloat(cos(angle)) * CGFloat(r)
            let py = center.y + CGFloat(sin(angle)) * CGFloat(r)

            if i == 0 { path.move(to: CGPoint(x: px, y: py)) }
            else       { path.addLine(to: CGPoint(x: px, y: py)) }
        }
        path.closeSubpath()
        return path
    }

    // MARK: - Donut Slice Clip

    private func donutSlice(
        center: CGPoint,
        innerR: CGFloat,
        outerR: CGFloat,
        startAngle: Double,
        endAngle: Double,
        clockwise: Bool
    ) -> Path {
        var p = Path()
        p.addArc(
            center: center, radius: outerR,
            startAngle: Angle(radians: startAngle),
            endAngle:   Angle(radians: endAngle),
            clockwise:  clockwise
        )
        p.addLine(to: CGPoint(
            x: center.x + CGFloat(cos(endAngle)) * innerR,
            y: center.y + CGFloat(sin(endAngle)) * innerR
        ))
        p.addArc(
            center: center, radius: innerR,
            startAngle: Angle(radians: endAngle),
            endAngle:   Angle(radians: startAngle),
            clockwise:  !clockwise
        )
        p.closeSubpath()
        return p
    }

    // MARK: - Dissolve

    private func triggerDissolve() {
        withAnimation(.easeOut(duration: 0.3)) {
            dissolveScale   = 1.06
            dissolveOpacity = 0
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(.easeOut(duration: 0.25)) {
                dissolveScale   = 1.0
                dissolveOpacity = 1.0
            }
        }
    }
}

// MARK: - Previews

#Preview("Focusing") {
    TimerRingView(progress: 0.6, accentColor: .tokenAccentFocus, state: .focusing)
        .padding(40)
        .background(Color.tokenBg)
}

#Preview("Paused") {
    TimerRingView(progress: 0.4, accentColor: .tokenAccentFocus, state: .paused)
        .padding(40)
        .background(Color.tokenBg)
}

#Preview("Breaking") {
    TimerRingView(progress: 0.8, accentColor: .tokenAccentBreakShort, state: .breaking)
        .padding(40)
        .background(Color.tokenBg)
}