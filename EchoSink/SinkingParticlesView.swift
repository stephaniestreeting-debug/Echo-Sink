import SwiftUI

struct SinkingParticlesView: View {
    @State private var animate = false

    private let particles: [(dx: CGFloat, delay: Double, size: CGFloat)] = [
        (-42, 0.00, 5), (-20, 0.08, 7), (2, 0.02, 4),
        (24, 0.11, 6), (44, 0.04, 5), (-6, 0.16, 4),
        (14, 0.20, 5)
    ]

    var body: some View {
        ZStack {
            ForEach(particles.indices, id: \.self) { i in
                Circle()
                    .fill(Color("AccentSink"))
                    .frame(width: particles[i].size, height: particles[i].size)
                    .offset(x: particles[i].dx, y: animate ? 52 : -8)
                    .opacity(animate ? 0 : 0.95)
                    .animation(
                        .easeIn(duration: 0.9).delay(particles[i].delay),
                        value: animate
                    )
            }
        }
        .frame(height: 60)
        .onAppear { animate = true }
        .accessibilityHidden(true)
    }
}

#Preview {
    SinkingParticlesView()
        .padding()
}
