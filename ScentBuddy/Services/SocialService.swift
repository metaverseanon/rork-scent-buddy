import Foundation

nonisolated struct SocialProfile: Codable, Sendable, Identifiable {
    let id: String
    let username: String
    let displayName: String
    let avatarEmoji: String
    let collectionCount: Int
    let favoriteNote: String
    let bio: String
    let memberSince: Date

    init(from supabaseProfile: SupabaseProfile) {
        self.id = supabaseProfile.id
        self.username = supabaseProfile.username ?? "user"
        self.displayName = supabaseProfile.display_name ?? "User"
        self.avatarEmoji = supabaseProfile.avatar_emoji ?? "drop.fill"
        self.collectionCount = 0
        self.favoriteNote = supabaseProfile.favorite_note ?? ""
        self.bio = supabaseProfile.bio ?? ""

        if let dateStr = supabaseProfile.created_at {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            self.memberSince = formatter.date(from: dateStr) ?? Date()
        } else {
            self.memberSince = Date()
        }
    }
}

@Observable
final class SocialService {
    static let shared = SocialService()

    private(set) var discoveredUsers: [SocialProfile] = []
    private(set) var followingUsers: [SocialProfile] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?

    private var followingIds: Set<String> = []

    private let supabase = SupabaseService.shared

    private init() {}

    var followingCount: Int { followingIds.count }

    func isFollowing(_ userId: String) -> Bool {
        followingIds.contains(userId)
    }

    func toggleFollow(_ userId: String) async {
        guard let currentUserId = supabase.currentUserId else { return }

        if followingIds.contains(userId) {
            followingIds.remove(userId)
            followingUsers.removeAll { $0.id == userId }
            do {
                try await supabase.unfollowUser(followerId: currentUserId, followingId: userId)
            } catch {
                followingIds.insert(userId)
                if let user = discoveredUsers.first(where: { $0.id == userId }) {
                    followingUsers.append(user)
                }
                errorMessage = error.localizedDescription
            }
        } else {
            followingIds.insert(userId)
            if let user = discoveredUsers.first(where: { $0.id == userId }) {
                followingUsers.append(user)
            }
            do {
                try await supabase.followUser(followerId: currentUserId, followingId: userId)
                try await supabase.insertActivity(ActivityFeedInsert(
                    user_id: currentUserId,
                    activity_type: "followed_user",
                    perfume_name: nil,
                    perfume_brand: nil,
                    target_user_id: userId
                ))
                try await supabase.insertNotification(AppNotificationInsert(
                    user_id: userId,
                    from_user_id: currentUserId,
                    notification_type: "follow",
                    perfume_name: nil,
                    perfume_brand: nil
                ))
            } catch {
                followingIds.remove(userId)
                followingUsers.removeAll { $0.id == userId }
                errorMessage = error.localizedDescription
            }
        }
    }

    func loadDiscoveredUsers() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let profiles = try await supabase.fetchAllProfiles()
            let currentId = supabase.currentUserId

            discoveredUsers = profiles
                .filter { $0.id != currentId }
                .map { SocialProfile(from: $0) }

            if let currentId {
                let follows = try await supabase.fetchFollowing(userId: currentId)
                followingIds = Set(follows.map { $0.following_id })
                followingUsers = discoveredUsers.filter { followingIds.contains($0.id) }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
