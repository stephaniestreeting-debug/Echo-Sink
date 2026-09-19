import Foundation
import UserNotifications

enum NotificationManager {
    static func scheduleUnlockNotification(for draft: Draft) {
        let center = UNUserNotificationCenter.current()
        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional:
                addRequest(for: draft, center: center)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound]) { granted, _ in
                    guard granted else { return }
                    addRequest(for: draft, center: center)
                }
            default:
                break
            }
        }
    }

    static func cancelUnlockNotification(for draft: Draft) {
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: [identifier(for: draft)])
    }

    private static func addRequest(for draft: Draft, center: UNUserNotificationCenter) {
        let content = UNMutableNotificationContent()
        content.title = "The Echo Sink"
        content.body = "A draft has finished cooling. Read it when you're ready — no rush."
        content.sound = .default

        let interval = max(1, draft.unlockAt.timeIntervalSinceNow)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: interval, repeats: false)
        let request = UNNotificationRequest(identifier: identifier(for: draft), content: content, trigger: trigger)

        center.add(request)
    }

    private static func identifier(for draft: Draft) -> String {
        "\(draft.persistentModelID)"
    }
}
