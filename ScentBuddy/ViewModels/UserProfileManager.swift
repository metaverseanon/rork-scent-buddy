import SwiftUI

@Observable
final class UserProfileManager {
    static let shared = UserProfileManager()

    var profile: UserProfile {
        didSet { saveLocal() }
    }

    var isLoggedIn: Bool {
        !profile.displayName.isEmpty
    }

    var isLoading: Bool = false
    var errorMessage: String?

    private let key = "user_profile"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = saved
        } else {
            self.profile = UserProfile()
        }
    }

    private func saveLocal() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func signUp(
        email: String,
        password: String,
        displayName: String,
        username: String,
        bio: String,
        favoriteNote: String,
        avatarEmoji: String
    ) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await SupabaseService.shared.signUp(email: email, password: password)

            let profileInsert = SupabaseProfileInsert(
                id: user.id,
                email: email,
                display_name: displayName,
                username: username,
                bio: bio,
                favorite_note: favoriteNote,
                avatar_emoji: avatarEmoji
            )

            try await SupabaseService.shared.insertProfile(profileInsert)

            profile = UserProfile(
                displayName: displayName,
                username: username,
                email: email,
                bio: bio,
                favoriteNote: favoriteNote,
                memberSince: Date(),
                avatarEmoji: avatarEmoji
            )

            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        isLoading = true
        errorMessage = nil

        do {
            let user = try await SupabaseService.shared.signIn(email: email, password: password)

            if let supaProfile = try await SupabaseService.shared.fetchProfile(userId: user.id) {
                profile = UserProfile(
                    displayName: supaProfile.display_name ?? "",
                    username: supaProfile.username ?? "",
                    email: supaProfile.email ?? email,
                    bio: supaProfile.bio ?? "",
                    favoriteNote: supaProfile.favorite_note ?? "",
                    memberSince: parseDate(supaProfile.created_at),
                    avatarEmoji: supaProfile.avatar_emoji ?? "drop.fill"
                )
            } else {
                profile = UserProfile(
                    displayName: user.email ?? email,
                    username: "",
                    email: email,
                    bio: "",
                    favoriteNote: "",
                    memberSince: Date(),
                    avatarEmoji: "drop.fill"
                )
            }

            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func updateProfile(
        displayName: String,
        username: String,
        bio: String,
        favoriteNote: String,
        avatarEmoji: String
    ) async -> Bool {
        guard let userId = SupabaseService.shared.currentUserId else {
            errorMessage = "Not signed in"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let update = SupabaseProfileUpdate(
                display_name: displayName,
                username: username,
                bio: bio,
                favorite_note: favoriteNote,
                avatar_emoji: avatarEmoji
            )
            try await SupabaseService.shared.updateProfile(userId: userId, update: update)

            profile.displayName = displayName
            profile.username = username
            profile.bio = bio
            profile.favoriteNote = favoriteNote
            profile.avatarEmoji = avatarEmoji

            isLoading = false
            return true
        } catch {
            errorMessage = error.localizedDescription
            isLoading = false
            return false
        }
    }

    func refreshProfile() async {
        guard let userId = SupabaseService.shared.currentUserId else { return }

        await SupabaseService.shared.refreshTokenIfNeeded()

        if let supaProfile = try? await SupabaseService.shared.fetchProfile(userId: userId) {
            profile = UserProfile(
                displayName: supaProfile.display_name ?? profile.displayName,
                username: supaProfile.username ?? profile.username,
                email: supaProfile.email ?? profile.email,
                bio: supaProfile.bio ?? "",
                favoriteNote: supaProfile.favorite_note ?? "",
                memberSince: parseDate(supaProfile.created_at),
                avatarEmoji: supaProfile.avatar_emoji ?? "drop.fill"
            )
        }
    }

    func signOut() {
        Task {
            await SupabaseService.shared.signOut()
        }
        profile = UserProfile()
        UserDefaults.standard.removeObject(forKey: key)
    }

    private func parseDate(_ dateStr: String?) -> Date {
        guard let dateStr else { return Date() }
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter.date(from: dateStr) ?? Date()
    }
}
