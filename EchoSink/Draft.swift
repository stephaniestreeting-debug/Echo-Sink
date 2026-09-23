import Foundation
import SwiftData

@Model
final class Draft {
    var text: String
    var label: String = ""
    var createdAt: Date
    var unlockAt: Date
    var duration: TimeInterval
    var hasPlayedSinkAnimation: Bool = false

    init(text: String, label: String = "", createdAt: Date = .now, duration: TimeInterval) {
        self.text = text
        self.label = label
        self.createdAt = createdAt
        self.duration = duration
        self.unlockAt = createdAt.addingTimeInterval(duration)
    }

    var isUnlocked: Bool {
        Date.now >= unlockAt
    }

    var remaining: TimeInterval {
        max(0, unlockAt.timeIntervalSinceNow)
    }

    var progress: Double {
        guard duration > 0 else { return 1 }
        let elapsed = duration - remaining
        return min(1, max(0, elapsed / duration))
    }

    func resink(text: String, duration: TimeInterval) {
        self.text = text
        self.duration = duration
        self.createdAt = .now
        self.unlockAt = Date.now.addingTimeInterval(duration)
        self.hasPlayedSinkAnimation = false
    }
}
