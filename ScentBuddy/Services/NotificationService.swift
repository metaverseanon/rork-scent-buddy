import UserNotifications
import SwiftUI

@Observable
final class NotificationService {
    static let shared = NotificationService()

    var isAuthorized: Bool = false
    var dailyReminderEnabled: Bool {
        didSet { UserDefaults.standard.set(dailyReminderEnabled, forKey: "daily_reminder_enabled") }
    }
    var weeklyPicksEnabled: Bool {
        didSet { UserDefaults.standard.set(weeklyPicksEnabled, forKey: "weekly_picks_enabled") }
    }
    var dailyReminderHour: Int {
        didSet {
            UserDefaults.standard.set(dailyReminderHour, forKey: "daily_reminder_hour")
            if dailyReminderEnabled { scheduleDailyReminder() }
        }
    }

    private let center = UNUserNotificationCenter.current()

    private init() {
        self.dailyReminderEnabled = UserDefaults.standard.bool(forKey: "daily_reminder_enabled")
        self.weeklyPicksEnabled = UserDefaults.standard.bool(forKey: "weekly_picks_enabled")
        let storedHour = UserDefaults.standard.integer(forKey: "daily_reminder_hour")
        self.dailyReminderHour = storedHour > 0 ? storedHour : 9
        Task { await checkAuthorizationStatus() }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    func checkAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func scheduleDailyReminder() {
        center.removePendingNotificationRequests(withIdentifiers: ["daily_wear_reminder"])

        guard dailyReminderEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "What are you wearing today?"
        content.body = wearReminderBody()
        content.sound = .default
        content.categoryIdentifier = "WEAR_REMINDER"

        var dateComponents = DateComponents()
        dateComponents.hour = dailyReminderHour
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_wear_reminder", content: content, trigger: trigger)

        center.add(request)
    }

    func scheduleWeeklySmartPicks() {
        center.removePendingNotificationRequests(withIdentifiers: ["weekly_smart_picks"])

        guard weeklyPicksEnabled else { return }

        let content = UNMutableNotificationContent()
        content.title = "Your Weekly Scent Picks"
        content.body = "We've got fresh fragrance suggestions just for you. Check out this week's smart picks!"
        content.sound = .default
        content.categoryIdentifier = "WEEKLY_PICKS"

        var dateComponents = DateComponents()
        dateComponents.weekday = 7
        dateComponents.hour = 10
        dateComponents.minute = 0

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "weekly_smart_picks", content: content, trigger: trigger)

        center.add(request)
    }

    func toggleDailyReminder(_ enabled: Bool) async {
        if enabled && !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }
        dailyReminderEnabled = enabled
        if enabled {
            scheduleDailyReminder()
        } else {
            center.removePendingNotificationRequests(withIdentifiers: ["daily_wear_reminder"])
        }
    }

    func toggleWeeklyPicks(_ enabled: Bool) async {
        if enabled && !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }
        weeklyPicksEnabled = enabled
        if enabled {
            scheduleWeeklySmartPicks()
        } else {
            center.removePendingNotificationRequests(withIdentifiers: ["weekly_smart_picks"])
        }
    }

    func sendTestNotification() async {
        if !isAuthorized {
            let granted = await requestAuthorization()
            guard granted else { return }
        }

        let content = UNMutableNotificationContent()
        content.title = "ScentBuddy"
        content.body = "Notifications are working! You're all set."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification", content: content, trigger: trigger)
        try? await center.add(request)
    }

    private func wearReminderBody() -> String {
        let bodies = [
            "Log your fragrance and keep your scent diary up to date.",
            "Don't forget to track today's scent! Your diary is waiting.",
            "Which fragrance matches your mood today? Log it now!",
            "Time to pick your scent of the day. What will it be?",
            "Your fragrance diary misses you. Log today's wear!"
        ]
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 0
        return bodies[day % bodies.count]
    }
}
