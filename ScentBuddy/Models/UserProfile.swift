import Foundation

nonisolated struct UserProfile: Codable, Sendable {
    var displayName: String
    var username: String
    var email: String
    var bio: String
    var favoriteNote: String
    var memberSince: Date
    var avatarEmoji: String

    init(
        displayName: String = "",
        username: String = "",
        email: String = "",
        bio: String = "",
        favoriteNote: String = "",
        memberSince: Date = Date(),
        avatarEmoji: String = "🧴"
    ) {
        self.displayName = displayName
        self.username = username
        self.email = email
        self.bio = bio
        self.favoriteNote = favoriteNote
        self.memberSince = memberSince
        self.avatarEmoji = avatarEmoji
    }
}
