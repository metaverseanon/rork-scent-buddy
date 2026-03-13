import Foundation

nonisolated struct SupabaseAuthResponse: Codable, Sendable {
    let access_token: String?
    let refresh_token: String?
    let user: SupabaseUser?
    let error: String?
    let error_description: String?
    let msg: String?
}

nonisolated struct SupabaseUser: Codable, Sendable {
    let id: String
    let email: String?
}

nonisolated struct SupabaseProfile: Codable, Sendable {
    let id: String
    let email: String?
    let display_name: String?
    let username: String?
    let bio: String?
    let favorite_note: String?
    let avatar_emoji: String?
    let created_at: String?
}

nonisolated struct SupabaseProfileInsert: Encodable, Sendable {
    let id: String
    let email: String
    let display_name: String
    let username: String
    let bio: String
    let favorite_note: String
    let avatar_emoji: String
}

nonisolated struct SupabaseErrorResponse: Codable, Sendable {
    let error: String?
    let error_description: String?
    let message: String?
    let msg: String?
    let code: Int?
}

@Observable
final class SupabaseService {
    static let shared = SupabaseService()

    private(set) var isAuthenticated: Bool = false
    private(set) var currentUserId: String?
    private(set) var accessToken: String?

    private let supabaseURL: String
    private let supabaseKey: String

    private let tokenKey = "supabase_access_token"
    private let refreshTokenKey = "supabase_refresh_token"
    private let userIdKey = "supabase_user_id"

    private init() {
        self.supabaseURL = Config.EXPO_PUBLIC_SUPABASE_URL
        self.supabaseKey = Config.EXPO_PUBLIC_SUPABASE_ANON_KEY

        if let token = UserDefaults.standard.string(forKey: tokenKey),
           let userId = UserDefaults.standard.string(forKey: userIdKey),
           !token.isEmpty {
            self.accessToken = token
            self.currentUserId = userId
            self.isAuthenticated = true
        }
    }

    func signUp(email: String, password: String) async throws -> SupabaseUser {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.notConfigured
        }

        let url = URL(string: "\(supabaseURL)/auth/v1/signup")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }

        if httpResponse.statusCode >= 400 {
            if let errorResp = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                let message = errorResp.msg ?? errorResp.message ?? errorResp.error_description ?? errorResp.error ?? "Sign up failed"
                throw SupabaseError.serverError(message)
            }
            throw SupabaseError.serverError("Sign up failed (status \(httpResponse.statusCode))")
        }

        let authResponse = try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)

        if let token = authResponse.access_token, let user = authResponse.user {
            saveSession(token: token, refreshToken: authResponse.refresh_token, userId: user.id)
            return user
        }

        if let user = authResponse.user {
            return user
        }

        throw SupabaseError.serverError("Unexpected response")
    }

    func signIn(email: String, password: String) async throws -> SupabaseUser {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.notConfigured
        }

        let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }

        if httpResponse.statusCode >= 400 {
            if let errorResp = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                let message = errorResp.msg ?? errorResp.message ?? errorResp.error_description ?? "Invalid email or password"
                throw SupabaseError.serverError(message)
            }
            throw SupabaseError.serverError("Sign in failed")
        }

        let authResponse = try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)

        guard let token = authResponse.access_token, let user = authResponse.user else {
            throw SupabaseError.serverError("Invalid credentials")
        }

        saveSession(token: token, refreshToken: authResponse.refresh_token, userId: user.id)
        return user
    }

    func signOut() async {
        if let token = accessToken, !supabaseURL.isEmpty {
            var request = URLRequest(url: URL(string: "\(supabaseURL)/auth/v1/logout")!)
            request.httpMethod = "POST"
            request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            _ = try? await URLSession.shared.data(for: request)
        }
        clearSession()
    }

    func insertProfile(_ profile: SupabaseProfileInsert) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.notConfigured
        }

        let url = URL(string: "\(supabaseURL)/rest/v1/profiles")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(profile)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }

        if httpResponse.statusCode >= 400 {
            if let errorResp = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                let message = errorResp.message ?? errorResp.msg ?? "Failed to create profile"
                throw SupabaseError.serverError(message)
            }
            throw SupabaseError.serverError("Failed to create profile")
        }
    }

    func fetchProfile(userId: String) async throws -> SupabaseProfile? {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.notConfigured
        }

        let url = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(userId)&select=*")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 400 else {
            return nil
        }

        let profiles = try JSONDecoder().decode([SupabaseProfile].self, from: data)
        return profiles.first
    }

    func fetchAllProfiles() async throws -> [SupabaseProfile] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.notConfigured
        }

        let url = URL(string: "\(supabaseURL)/rest/v1/profiles?select=*&order=created_at.desc")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to fetch profiles")
        }

        return try JSONDecoder().decode([SupabaseProfile].self, from: data)
    }

    func fetchFollowing(userId: String) async throws -> [SupabaseFollow] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.notConfigured
        }

        let url = URL(string: "\(supabaseURL)/rest/v1/follows?follower_id=eq.\(userId)&select=*")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to fetch follows")
        }

        return try JSONDecoder().decode([SupabaseFollow].self, from: data)
    }

    func followUser(followerId: String, followingId: String) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.notConfigured
        }

        let url = URL(string: "\(supabaseURL)/rest/v1/follows")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }

        let body = SupabaseFollowInsert(follower_id: followerId, following_id: followingId)
        request.httpBody = try JSONEncoder().encode(body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 400 else {
            if let errorResp = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                let message = errorResp.message ?? errorResp.msg ?? "Failed to follow user"
                throw SupabaseError.serverError(message)
            }
            throw SupabaseError.serverError("Failed to follow user")
        }
    }

    func unfollowUser(followerId: String, followingId: String) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.notConfigured
        }

        let url = URL(string: "\(supabaseURL)/rest/v1/follows?follower_id=eq.\(followerId)&following_id=eq.\(followingId)")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }

        let (_, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to unfollow user")
        }
    }

    private func saveSession(token: String, refreshToken: String?, userId: String) {
        accessToken = token
        currentUserId = userId
        isAuthenticated = true
        UserDefaults.standard.set(token, forKey: tokenKey)
        UserDefaults.standard.set(refreshToken, forKey: refreshTokenKey)
        UserDefaults.standard.set(userId, forKey: userIdKey)
    }

    private func clearSession() {
        accessToken = nil
        currentUserId = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: tokenKey)
        UserDefaults.standard.removeObject(forKey: refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: userIdKey)
    }
}

nonisolated struct SupabaseFollowInsert: Encodable, Sendable {
    let follower_id: String
    let following_id: String
}

nonisolated struct SupabaseFollow: Codable, Sendable {
    let id: String
    let follower_id: String
    let following_id: String
    let created_at: String?
}

nonisolated enum SupabaseError: LocalizedError, Sendable {
    case notConfigured
    case networkError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Supabase is not configured"
        case .networkError: return "Network error. Please try again."
        case .serverError(let msg): return msg
        }
    }
}
