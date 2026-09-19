import UIKit

enum HapticManager {
    static func sink() {
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred(intensity: 1.0)
    }

    static func unlock() {
        let generator = UIImpactFeedbackGenerator(style: .rigid)
        generator.impactOccurred()
    }

    static func tap() {
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }

    static func success() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
