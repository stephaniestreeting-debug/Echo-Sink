import SwiftUI

struct SinkButtonStyle: ButtonStyle {
    var isEnabled: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(.headline, design: .serif))
            .foregroundStyle(isEnabled ? Color("BackgroundPrimary") : .secondary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Capsule()
                    .fill(isEnabled ? Color("AccentSink") : Color("CardSurface"))
            )
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}
