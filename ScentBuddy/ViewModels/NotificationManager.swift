import Foundation
import UserNotifications

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    private(set) var notifications: [AppNotification] = []
    private(set) var unreadCount: Int = 0
    private(set) var isLoading: Bool = false

    private let supabase = SupabaseService.shared
    private var profileCache: [String: SupabaseProfile] = [:]
    private let lastCheckedKey = "last_notification_check_id"
    private var pollingTask: Task<Void, Never>?

    private init() {}

    func startPolling() {
        stopPolling()
        pollingTask = Task {
            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(30))
                guard !Task.isCancelled else { break }
                await refreshUnreadCount()
                await checkAndSendPushNotifications()
            }
        }
    }

    func stopPolling() {
        pollingTask?.cancel()
        pollingTask = nil
    }

    func loadNotifications() async {
        guard let userId = supabase.currentUserId else { return }
        isLoading = true
        defer { isLoading = false }

        do {
            notifications = try await supabase.fetchNotifications(userId: userId)
            unreadCount = notifications.filter { $0.is_read != true }.count

            let uniqueUserIds = Set(notifications.map { $0.from_user_id })
            for uid in uniqueUserIds where profileCache[uid] == nil {
                if let profile = try? await supabase.fetchProfile(userId: uid) {
                    profileCache[uid] = profile
                }
            }
        } catch {
            print("[NotificationManager] Failed to load: \(error)")
        }
    }

    func refreshUnreadCount() async {
        guard let userId = supabase.currentUserId else { return }
        do {
            unreadCount = try await supabase.fetchUnreadNotificationCount(userId: userId)
        } catch {
            print("[NotificationManager] Failed to refresh count: \(error)")
        }
    }

    func checkAndSendPushNotifications() async {
        guard let userId = supabase.currentUserId else { return }

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else { return }

        do {
            let recent = try await supabase.fetchNotifications(userId: userId)
            let lastCheckedId = UserDefaults.standard.string(forKey: lastCheckedKey)

            let newNotifications: [AppNotification]
            if let lastId = lastCheckedId, let lastIndex = recent.firstIndex(where: { $0.id == lastId }) {
                newNotifications = Array(recent[..<lastIndex])
            } else if lastCheckedId != nil {
                newNotifications = recent.filter { $0.is_read != true }
            } else {
                newNotifications = recent.filter { $0.is_read != true }
            }

            if let firstId = recent.first?.id {
                UserDefaults.standard.set(firstId, forKey: lastCheckedKey)
            }

            for notification in newNotifications.prefix(5) {
                await sendLocalPush(for: notification)
            }
        } catch {
            print("[NotificationManager] Push check failed: \(error)")
        }
    }

    private func sendLocalPush(for notification: AppNotification) async {
        if profileCache[notification.from_user_id] == nil {
            if let profile = try? await supabase.fetchProfile(userId: notification.from_user_id) {
                profileCache[notification.from_user_id] = profile
            }
        }
        let name = displayName(for: notification.from_user_id)

        let content = UNMutableNotificationContent()
        content.sound = .default

        switch notification.notification_type {
        case "follow":
            content.title = "New Follower"
            content.body = "\(name) started following you"
        case "nose_bump", "sniff":
            let perfume = notification.perfume_name ?? "a fragrance"
            content.title = "New Sniff! \u{1F443}"
            content.body = "\(name) sniffed your \(perfume)"
        default:
            content.title = "ScentBuddy"
            content.body = "You have a new notification"
        }

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "social_\(notification.id)",
            content: content,
            trigger: trigger
        )
        try? await UNUserNotificationCenter.current().add(request)
    }

    func markAllRead() async {
        guard let userId = supabase.currentUserId else { return }
        do {
            try await supabase.markNotificationsRead(userId: userId)
            unreadCount = 0
        } catch {
            print("[NotificationManager] Failed to mark read: \(error)")
        }
    }

    func profileFor(_ userId: String) -> SupabaseProfile? {
        profileCache[userId]
    }

    func displayName(for userId: String) -> String {
        profileCache[userId]?.display_name ?? "Someone"
    }

    func avatarEmoji(for userId: String) -> String {
        profileCache[userId]?.avatar_emoji ?? "person.fill"
    }
}
