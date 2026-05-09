import SwiftUI

struct AboutView: View {
    var body: some View {
        VStack(spacing: 10) {
            Spacer().frame(height: 8)

            Text("Zendo")
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(.tokenTextPrimary)

            Text("极简番茄钟")
                .font(.system(size: 11, weight: .regular))
                .foregroundColor(.tokenTextSecondary)
                .tracking(2)

            Text("1.0")
                .font(.system(size: 10, weight: .regular, design: .monospaced))
                .foregroundColor(.tokenTextMuted)

            Spacer()

            Text("专注当下，保持简单")
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
