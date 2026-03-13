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
}

nonisolated struct FollowRelation: Codable, Sendable {
    let followerId: String
    let followingId: String
    let timestamp: Date
}

@Observable
final class SocialService {
    static let shared = SocialService()

    private(set) var discoveredUsers: [SocialProfile] = []
    private(set) var followingUsers: [SocialProfile] = []
    private(set) var isLoading: Bool = false

    private var followingIds: Set<String> {
        didSet { saveFollowing() }
    }

    private let followingKey = "following_user_ids"

    private init() {
        let saved = UserDefaults.standard.stringArray(forKey: followingKey) ?? []
        self.followingIds = Set(saved)
    }

    var followingCount: Int { followingIds.count }

    func isFollowing(_ userId: String) -> Bool {
        followingIds.contains(userId)
    }

    func toggleFollow(_ userId: String) {
        if followingIds.contains(userId) {
            followingIds.remove(userId)
            followingUsers.removeAll { $0.id == userId }
        } else {
            followingIds.insert(userId)
            if let user = discoveredUsers.first(where: { $0.id == userId }) {
                followingUsers.append(user)
            }
        }
    }

    func loadDiscoveredUsers() async {
        isLoading = true
        defer { isLoading = false }

        try? await Task.sleep(for: .milliseconds(800))

        let sampleUsers: [SocialProfile] = [
            SocialProfile(id: "usr_001", username: "scentlover", displayName: "Alex Noir", avatarEmoji: "🖤", collectionCount: 47, favoriteNote: "Oud", bio: "Niche fragrance collector. Oud enthusiast.", memberSince: Date().addingTimeInterval(-86400 * 180)),
            SocialProfile(id: "usr_002", username: "floralbabe", displayName: "Lily Rose", avatarEmoji: "🌸", collectionCount: 32, favoriteNote: "Rose", bio: "Floral & feminine scents only.", memberSince: Date().addingTimeInterval(-86400 * 90)),
            SocialProfile(id: "usr_003", username: "woodsy.vibes", displayName: "Marcus Cedar", avatarEmoji: "🌿", collectionCount: 28, favoriteNote: "Sandalwood", bio: "Woody fragrances & leather. MFK fan.", memberSince: Date().addingTimeInterval(-86400 * 120)),
            SocialProfile(id: "usr_004", username: "vanillacloud", displayName: "Sophie Sweet", avatarEmoji: "✨", collectionCount: 55, favoriteNote: "Vanilla", bio: "Sweet gourmand lover. 200+ tested.", memberSince: Date().addingTimeInterval(-86400 * 365)),
            SocialProfile(id: "usr_005", username: "freshking", displayName: "David Blue", avatarEmoji: "💎", collectionCount: 19, favoriteNote: "Bergamot", bio: "Fresh & clean scents for everyday.", memberSince: Date().addingTimeInterval(-86400 * 60)),
            SocialProfile(id: "usr_006", username: "amber.witch", displayName: "Nina Amber", avatarEmoji: "🔥", collectionCount: 41, favoriteNote: "Amber", bio: "Oriental & amber obsessed.", memberSince: Date().addingTimeInterval(-86400 * 200)),
            SocialProfile(id: "usr_007", username: "creed.collector", displayName: "James Royal", avatarEmoji: "💐", collectionCount: 63, favoriteNote: "Iris", bio: "Creed & Tom Ford private blend collector.", memberSince: Date().addingTimeInterval(-86400 * 400)),
            SocialProfile(id: "usr_008", username: "citrus.queen", displayName: "Maria Sol", avatarEmoji: "🍊", collectionCount: 22, favoriteNote: "Lemon", bio: "Citrus & Mediterranean vibes.", memberSince: Date().addingTimeInterval(-86400 * 75)),
        ]

        discoveredUsers = sampleUsers
        followingUsers = sampleUsers.filter { followingIds.contains($0.id) }
    }

    private func saveFollowing() {
        UserDefaults.standard.set(Array(followingIds), forKey: followingKey)
    }
}
