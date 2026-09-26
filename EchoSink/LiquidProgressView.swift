import SwiftUI

struct LiquidProgressView: View {
    var progress: Double
    var isReady: Bool

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color("CardSurface"))

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: isReady
                                ? [Color("AccentReady").opacity(0.85), Color("AccentReady")]
                                : [Color("AccentSink").opacity(0.7), Color("AccentSink")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(6, geo.size.width * progress))
                    .animation(.easeInOut(duration: 0.6), value: progress)

                Capsule()
                    .strokeBorder(Color.primary.opacity(0.08), lineWidth: 1)
            }
        }
        .frame(height: 8)
    }
}

#Preview {
    VStack(spacing: 20) {
        LiquidProgressView(progress: 0.15, isReady: false)
        LiquidProgressView(progress: 0.65, isReady: false)
        LiquidProgressView(progress: 1.0, isReady: true)
    }
    .padding()
}
