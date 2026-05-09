import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 8)

            Text("禅道")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.tokenTextPrimary)

            Text("Zendo")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.tokenTextSecondary)
                .tracking(2)

            Text("1.0")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.tokenTextMuted)

            Spacer()

            Text("静けさの中で、時が流れる")
                .font(.system(size: 9, weight: .light))
                .foregroundColor(.tokenTextMuted)
                .padding(.bottom, 12)
        }
        .frame(width: 180, height: 120)
        .background(Color.tokenBg)
    }
}

#Preview {
    AboutView()
}
