import Foundation
import Supabase

@Observable
final class SupabaseAuthService {
    static let shared = SupabaseAuthService()

    private(set) var isAuthenticated: Bool = false
    private(set) var currentUserID: String? = nil
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String? = nil
    private var hasStartedListening: Bool = false

    private init() {}

    func startListeningIfNeeded() {
        guard !hasStartedListening else { return }
        guard SupabaseManager.isConfigured else { return }
        hasStartedListening = true
        Task { @MainActor [weak self] in
            await self?.listenForAuthChanges()
        }
    }

    private func listenForAuthChanges() async {
        guard let client = SupabaseManager.client else { return }
        do {
            for await (event, session) in client.auth.authStateChanges {
                guard !Task.isCancelled else { return }
                if [.initialSession, .signedIn, .signedOut].contains(event) {
                    self.isAuthenticated = session != nil
                    self.currentUserID = session?.user.id.uuidString
                }
            }
        } catch {
            self.isAuthenticated = false
            self.currentUserID = nil
        }
    }

    func signUp(email: String, password: String, displayName: String, username: String, bio: String, favoriteNote: String, avatarEmoji: String) async -> Bool {
        guard let client = SupabaseManager.client else {
            errorMessage = "Service not configured"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let result = try await client.auth.signUp(
                email: email,
                password: password,
                data: [
                    "display_name": .string(displayName),
                    "username": .string(username),
                    "bio": .string(bio),
                    "favorite_note": .string(favoriteNote),
                    "avatar_emoji": .string(avatarEmoji)
                ]
            )
            currentUserID = result.user.id.uuidString
            isAuthenticated = result.session != nil

            if result.session != nil {
                await syncProfileToSupabase(
                    userId: result.user.id.uuidString,
                    email: email,
                    displayName: displayName,
                    username: username,
                    bio: bio,
                    favoriteNote: favoriteNote,
                    avatarEmoji: avatarEmoji
                )
            }

            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = parseAuthError(error)
            return false
        }
    }

    func signIn(email: String, password: String) async -> Bool {
        guard let client = SupabaseManager.client else {
            errorMessage = "Service not configured"
            return false
        }

        isLoading = true
        errorMessage = nil

        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            currentUserID = session.user.id.uuidString
            isAuthenticated = true

            await fetchProfileFromSupabase(userId: session.user.id.uuidString)

            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = parseAuthError(error)
            return false
        }
    }

    func signOut() async {
        do {
            if let client = SupabaseManager.client {
                try await client.auth.signOut()
            }
        } catch {}
        isAuthenticated = false
        currentUserID = nil
        UserProfileManager.shared.signOut()
    }

    func fetchProfileFromSupabase(userId: String) async {
        guard let client = SupabaseManager.client else { return }
        do {
            let response: ProfileRow = try await client
                .from("profiles")
                .select()
                .eq("id", value: userId)
                .single()
                .execute()
                .value

            UserProfileManager.shared.profile = UserProfile(
                displayName: response.display_name ?? "",
                username: response.username ?? "",
                email: response.email ?? "",
                bio: response.bio ?? "",
                favoriteNote: response.favorite_note ?? "",
                memberSince: response.created_at ?? Date(),
                avatarEmoji: response.avatar_emoji ?? "🧴"
            )
        } catch {}
    }

    func syncProfileToSupabase(userId: String, email: String, displayName: String, username: String, bio: String, favoriteNote: String, avatarEmoji: String) async {
        guard let client = SupabaseManager.client else { return }
        let row = ProfileUpsert(
            id: userId,
            email: email,
            display_name: displayName,
            username: username.isEmpty ? nil : username,
            bio: bio.isEmpty ? nil : bio,
            favorite_note: favoriteNote.isEmpty ? nil : favoriteNote,
            avatar_emoji: avatarEmoji
        )

        do {
            try await client
                .from("profiles")
                .upsert(row)
                .execute()
        } catch {}
    }

    private func parseAuthError(_ error: Error) -> String {
        let message = error.localizedDescription.lowercased()
        if message.contains("invalid login") || message.contains("invalid_credentials") {
            return "Invalid email or password"
        } else if message.contains("already registered") || message.contains("already been registered") {
            return "An account with this email already exists"
        } else if message.contains("weak_password") || message.contains("too short") {
            return "Password must be at least 6 characters"
        } else if message.contains("invalid_email") || message.contains("invalid email") {
            return "Please enter a valid email address"
        } else if message.contains("network") || message.contains("connection") {
            return "Network error. Please check your connection"
        }
        return "Something went wrong. Please try again"
    }
}

nonisolated struct ProfileRow: Codable, Sendable {
    let id: String
    let email: String?
    let display_name: String?
    let username: String?
    let bio: String?
    let favorite_note: String?
    let avatar_emoji: String?
    let created_at: Date?
}

nonisolated struct ProfileUpsert: Codable, Sendable {
    let id: String
    let email: String
    let display_name: String
    let username: String?
    let bio: String?
    let favorite_note: String?
    let avatar_emoji: String
}
