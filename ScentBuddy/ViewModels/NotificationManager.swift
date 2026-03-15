import Foundation

@Observable
final class NotificationManager {
    static let shared = NotificationManager()

    private(set) var notifications: [AppNotification] = []
    private(set) var unreadCount: Int = 0
    private(set) var isLoading: Bool = false

    private let supabase = SupabaseService.shared
    private var profileCache: [String: SupabaseProfile] = [:]

    private init() {}

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
