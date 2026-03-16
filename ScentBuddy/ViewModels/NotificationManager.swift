import Foundation
import UserNotifications

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    private(set) var notifications: [AppNotification] = []
    private(set) var unreadCount: Int = 0
    private(set) var isLoading: Bool = false
    var shouldShowNotifications: Bool = false

    private let supabase = SupabaseService.shared
    private var profileCache: [String: SupabaseProfile] = [:]
    private let lastCheckedKey = "last_notification_check_ts"
    private var pollingTask: Task<Void, Never>?
    private var hasRequestedPermission: Bool = false

    private init() {}

    func ensureNotificationPermission() async {
        guard !hasRequestedPermission else { return }
        hasRequestedPermission = true

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        if settings.authorizationStatus == .notDetermined {
            let granted = try? await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            print("[NotificationManager] Permission requested, granted: \(granted ?? false)")
        }
    }

    func startPolling() {
        stopPolling()
        pollingTask = Task {
            await ensureNotificationPermission()
            await refreshUnreadCount()
            await checkAndSendPushNotifications()

            while !Task.isCancelled {
                try? await Task.sleep(for: .seconds(15))
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
            let count = try await supabase.fetchUnreadNotificationCount(userId: userId)
            unreadCount = count
        } catch {
            print("[NotificationManager] Failed to refresh count: \(error)")
        }
    }

    func checkAndSendPushNotifications() async {
        guard let userId = supabase.currentUserId else { return }

        let settings = await UNUserNotificationCenter.current().notificationSettings()
        guard settings.authorizationStatus == .authorized else {
            if settings.authorizationStatus == .notDetermined {
                await ensureNotificationPermission()
            }
            return
        }

        do {
            let recent = try await supabase.fetchNotifications(userId: userId)
            guard !recent.isEmpty else { return }

            let lastCheckedTs = UserDefaults.standard.string(forKey: lastCheckedKey)

            let newNotifications: [AppNotification]
            if let lastTs = lastCheckedTs {
                newNotifications = recent.filter { notification in
                    guard let createdAt = notification.created_at else { return false }
                    return createdAt > lastTs && notification.is_read != true
                }
            } else {
                newNotifications = []
                print("[NotificationManager] First run, setting baseline timestamp")
            }

            if let newestTs = recent.first?.created_at {
                UserDefaults.standard.set(newestTs, forKey: lastCheckedKey)
            }

            for notification in newNotifications.prefix(5) {
                await sendLocalPush(for: notification)
            }

            if !newNotifications.isEmpty {
                unreadCount = recent.filter { $0.is_read != true }.count
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
        content.categoryIdentifier = "SOCIAL_NOTIFICATION"

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
