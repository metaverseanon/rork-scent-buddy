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

nonisolated struct SupabaseProfileUpdate: Encodable, Sendable {
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
        var rawURL = Config.EXPO_PUBLIC_SUPABASE_URL.trimmingCharacters(in: .whitespacesAndNewlines)
        if rawURL.hasSuffix("/") { rawURL = String(rawURL.dropLast()) }
        if !rawURL.isEmpty && !rawURL.hasPrefix("http://") && !rawURL.hasPrefix("https://") {
            rawURL = "https://" + rawURL
        }
        self.supabaseURL = rawURL
        self.supabaseKey = Config.EXPO_PUBLIC_SUPABASE_ANON_KEY.trimmingCharacters(in: .whitespacesAndNewlines)
        print("[SupabaseService] Initialized with URL: '\(rawURL)' key length: \(self.supabaseKey.count)")

        if let token = UserDefaults.standard.string(forKey: tokenKey),
           let userId = UserDefaults.standard.string(forKey: userIdKey),
           !token.isEmpty {
            self.accessToken = token
            self.currentUserId = userId
            self.isAuthenticated = true
        }
    }

    nonisolated struct SignUpResult: Sendable {
        let user: SupabaseUser
        let needsEmailConfirmation: Bool
    }

    func signUp(email: String, password: String) async throws -> SignUpResult {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.serverError("Service not configured. Please check your Supabase settings.")
        }

        guard let url = URL(string: "\(supabaseURL)/auth/v1/signup") else {
            throw SupabaseError.serverError("Service not configured. Please check your Supabase settings.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 30

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw SupabaseError.serverError("Could not connect to server. Please check your internet connection.")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }

        if httpResponse.statusCode >= 400 {
            if let errorResp = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                let message = errorResp.msg ?? errorResp.message ?? errorResp.error_description ?? errorResp.error ?? "Sign up failed"
                throw SupabaseError.serverError(message)
            }
            throw SupabaseError.serverError("Sign up failed. Please try again.")
        }

        let authResponse = try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)

        if let token = authResponse.access_token, !token.isEmpty, let user = authResponse.user {
            saveSession(token: token, refreshToken: authResponse.refresh_token, userId: user.id)
            return SignUpResult(user: user, needsEmailConfirmation: false)
        }

        if let user = authResponse.user {
            return SignUpResult(user: user, needsEmailConfirmation: true)
        }

        throw SupabaseError.serverError("Unexpected response from server")
    }

    func signIn(email: String, password: String) async throws -> SupabaseUser {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.serverError("Service not configured. Please check your Supabase settings.")
        }

        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=password") else {
            throw SupabaseError.serverError("Service not configured. Please check your Supabase settings.")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 30

        let body: [String: String] = ["email": email, "password": password]
        request.httpBody = try JSONEncoder().encode(body)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw SupabaseError.serverError("Could not connect to server. Please check your internet connection.")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }

        if httpResponse.statusCode >= 400 {
            if let errorResp = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                let message = errorResp.msg ?? errorResp.message ?? errorResp.error_description ?? "Invalid email or password"
                throw SupabaseError.serverError(message)
            }
            throw SupabaseError.serverError("Sign in failed. Please try again.")
        }

        let authResponse = try JSONDecoder().decode(SupabaseAuthResponse.self, from: data)

        guard let token = authResponse.access_token, let user = authResponse.user else {
            throw SupabaseError.serverError("Invalid credentials")
        }

        saveSession(token: token, refreshToken: authResponse.refresh_token, userId: user.id)
        return user
    }

    static let magicLinkRedirectURL = "scentbuddy://auth/callback"

    func sendMagicLink(email: String) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.serverError("Service not configured.")
        }
        guard let url = URL(string: "\(supabaseURL)/auth/v1/magiclink") else {
            throw SupabaseError.serverError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 30
        let body: [String: Any] = [
            "email": email,
            "options": ["redirectTo": Self.magicLinkRedirectURL]
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.networkError }
        if http.statusCode >= 400 {
            if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.serverError(e.msg ?? e.message ?? e.error_description ?? "Failed to send magic link")
            }
            throw SupabaseError.serverError("Failed to send magic link")
        }
    }

    func handleMagicLinkURL(_ url: URL) async -> Bool {
        let urlString = url.absoluteString

        var fragment = url.fragment
        if fragment == nil, let range = urlString.range(of: "#") {
            fragment = String(urlString[range.upperBound...])
        }

        var params: [String: String] = [:]

        if let fragment {
            let pairs = fragment.components(separatedBy: "&")
            for pair in pairs {
                let kv = pair.components(separatedBy: "=")
                if kv.count == 2 {
                    params[kv[0]] = kv[1].removingPercentEncoding ?? kv[1]
                }
            }
        }

        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
            for item in components.queryItems ?? [] {
                if let value = item.value {
                    params[item.name] = value
                }
            }
        }

        if let accessToken = params["access_token"],
           let refreshToken = params["refresh_token"] {
            saveSession(token: accessToken, refreshToken: refreshToken, userId: "")
            if let userInfo = try? await fetchCurrentUser(token: accessToken) {
                currentUserId = userInfo.id
                UserDefaults.standard.set(userInfo.id, forKey: userIdKey)
            }
            return true
        }

        if let code = params["code"] {
            return await exchangeCodeForSession(code: code)
        }

        return false
    }

    private func fetchCurrentUser(token: String) async throws -> SupabaseUser? {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/user") else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 15
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else { return nil }
        return try JSONDecoder().decode(SupabaseUser.self, from: data)
    }

    private func exchangeCodeForSession(code: String) async -> Bool {
        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=pkce") else { return false }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 15
        let body: [String: String] = ["auth_code": code]
        request.httpBody = try? JSONEncoder().encode(body)
        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse, http.statusCode < 400,
              let authResponse = try? JSONDecoder().decode(SupabaseAuthResponse.self, from: data),
              let token = authResponse.access_token,
              let user = authResponse.user else {
            return false
        }
        saveSession(token: token, refreshToken: authResponse.refresh_token, userId: user.id)
        return true
    }

    func sendPasswordReset(email: String) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.serverError("Service not configured.")
        }
        guard let url = URL(string: "\(supabaseURL)/auth/v1/recover") else {
            throw SupabaseError.serverError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 30
        let body: [String: String] = ["email": email]
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.networkError }
        if http.statusCode >= 400 {
            if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.serverError(e.msg ?? e.message ?? e.error_description ?? "Failed to send reset email")
            }
            throw SupabaseError.serverError("Failed to send reset email")
        }
    }

    func updateEmail(newEmail: String) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty, let token = accessToken else {
            throw SupabaseError.serverError("Not authenticated")
        }
        guard let url = URL(string: "\(supabaseURL)/auth/v1/user") else {
            throw SupabaseError.serverError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        let body: [String: String] = ["email": newEmail]
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.networkError }
        if http.statusCode >= 400 {
            if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.serverError(e.msg ?? e.message ?? e.error_description ?? "Failed to update email")
            }
            throw SupabaseError.serverError("Failed to update email")
        }
    }

    func updatePassword(newPassword: String) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty, let token = accessToken else {
            throw SupabaseError.serverError("Not authenticated")
        }
        guard let url = URL(string: "\(supabaseURL)/auth/v1/user") else {
            throw SupabaseError.serverError("Invalid URL")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 30
        let body: [String: String] = ["password": newPassword]
        request.httpBody = try JSONEncoder().encode(body)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.networkError }
        if http.statusCode >= 400 {
            if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.serverError(e.msg ?? e.message ?? e.error_description ?? "Failed to update password")
            }
            throw SupabaseError.serverError("Failed to update password")
        }
    }

    func signOut() async {
        if let token = accessToken, !supabaseURL.isEmpty, let logoutURL = URL(string: "\(supabaseURL)/auth/v1/logout") {
            var request = URLRequest(url: logoutURL)
            request.httpMethod = "POST"
            request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            _ = try? await URLSession.shared.data(for: request)
        }
        clearSession()
    }

    func insertProfile(_ profile: SupabaseProfileInsert) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.serverError("Supabase is not configured.")
        }

        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles") else {
            throw SupabaseError.serverError("Invalid Supabase URL configuration")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.setValue("return=minimal", forHTTPHeaderField: "Prefer")
        request.timeoutInterval = 30

        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }

        request.httpBody = try JSONEncoder().encode(profile)

        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await URLSession.shared.data(for: request)
        } catch {
            throw SupabaseError.serverError("Could not save profile. Please check your connection.")
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }

        if httpResponse.statusCode == 409 || httpResponse.statusCode == 23505 {
            return
        }

        if httpResponse.statusCode >= 400 {
            if let errorResp = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                let message = errorResp.message ?? errorResp.msg ?? "Failed to create profile"
                if message.contains("duplicate") || message.contains("already exists") {
                    return
                }
                throw SupabaseError.serverError(message)
            }
            let bodyStr = String(data: data, encoding: .utf8) ?? "no body"
            throw SupabaseError.serverError("Failed to create profile (\(httpResponse.statusCode)): \(bodyStr)")
        }
    }

    func refreshTokenIfNeeded() async {
        guard let refreshToken = UserDefaults.standard.string(forKey: refreshTokenKey),
              !refreshToken.isEmpty,
              !supabaseURL.isEmpty,
              !supabaseKey.isEmpty else { return }

        guard let url = URL(string: "\(supabaseURL)/auth/v1/token?grant_type=refresh_token") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        request.timeoutInterval = 15

        let body: [String: String] = ["refresh_token": refreshToken]
        request.httpBody = try? JSONEncoder().encode(body)

        guard let (data, response) = try? await URLSession.shared.data(for: request),
              let http = response as? HTTPURLResponse, http.statusCode < 400,
              let authResponse = try? JSONDecoder().decode(SupabaseAuthResponse.self, from: data),
              let newToken = authResponse.access_token,
              let user = authResponse.user else {
            return
        }

        saveSession(token: newToken, refreshToken: authResponse.refresh_token ?? refreshToken, userId: user.id)
    }

    func fetchProfile(userId: String) async throws -> SupabaseProfile? {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.serverError("Supabase is not configured.")
        }

        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(userId)&select=*") else {
            throw SupabaseError.serverError("Invalid URL")
        }
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
            throw SupabaseError.serverError("Supabase is not configured.")
        }

        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles?select=*&order=created_at.desc") else {
            throw SupabaseError.serverError("Invalid URL")
        }
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
            throw SupabaseError.serverError("Supabase is not configured.")
        }

        guard let url = URL(string: "\(supabaseURL)/rest/v1/follows?follower_id=eq.\(userId)&select=*") else {
            throw SupabaseError.serverError("Invalid URL")
        }
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
            throw SupabaseError.serverError("Supabase is not configured.")
        }

        guard let url = URL(string: "\(supabaseURL)/rest/v1/follows") else {
            throw SupabaseError.serverError("Invalid URL")
        }
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
            throw SupabaseError.serverError("Supabase is not configured.")
        }

        guard let url = URL(string: "\(supabaseURL)/rest/v1/follows?follower_id=eq.\(followerId)&following_id=eq.\(followingId)") else {
            throw SupabaseError.serverError("Invalid URL")
        }
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

    private func authenticatedRequest(url: URL, method: String = "GET", prefer: String? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        if let prefer { request.setValue(prefer, forHTTPHeaderField: "Prefer") }
        if let token = accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }
        return request
    }

    func fetchUserCollection(userId: String) async throws -> [UserCollectionItem] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/user_collections?user_id=eq.\(userId)&select=*&order=date_added.desc") else { throw SupabaseError.serverError("Invalid URL") }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to fetch collection")
        }
        return try JSONDecoder().decode([UserCollectionItem].self, from: data)
    }

    func fetchUserWishlist(userId: String) async throws -> [UserWishlistItem] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/user_wishlists?user_id=eq.\(userId)&select=*&order=date_added.desc") else { throw SupabaseError.serverError("Invalid URL") }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to fetch wishlist")
        }
        return try JSONDecoder().decode([UserWishlistItem].self, from: data)
    }

    func insertCollectionItem(_ item: UserCollectionInsert) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/user_collections") else { throw SupabaseError.serverError("Invalid URL") }
        var request = authenticatedRequest(url: url, method: "POST", prefer: "return=minimal")
        request.httpBody = try JSONEncoder().encode(item)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.serverError(e.message ?? "Failed to sync collection")
            }
            throw SupabaseError.serverError("Failed to sync collection")
        }
    }

    func insertWishlistItem(_ item: UserWishlistInsert) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/user_wishlists") else { throw SupabaseError.serverError("Invalid URL") }
        var request = authenticatedRequest(url: url, method: "POST", prefer: "return=minimal")
        request.httpBody = try JSONEncoder().encode(item)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.serverError(e.message ?? "Failed to sync wishlist")
            }
            throw SupabaseError.serverError("Failed to sync wishlist")
        }
    }

    func fetchReviews(perfumeName: String, perfumeBrand: String) async throws -> [PerfumeReview] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        let encodedName = perfumeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeName
        let encodedBrand = perfumeBrand.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeBrand
        guard let url = URL(string: "\(supabaseURL)/rest/v1/perfume_reviews?perfume_name=eq.\(encodedName)&perfume_brand=eq.\(encodedBrand)&select=*&order=created_at.desc") else { throw SupabaseError.serverError("Invalid URL") }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to fetch reviews")
        }
        return try JSONDecoder().decode([PerfumeReview].self, from: data)
    }

    func fetchUserReviews(userId: String) async throws -> [PerfumeReview] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/perfume_reviews?user_id=eq.\(userId)&select=*&order=created_at.desc") else { throw SupabaseError.serverError("Invalid URL") }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to fetch reviews")
        }
        return try JSONDecoder().decode([PerfumeReview].self, from: data)
    }

    func insertReview(_ review: PerfumeReviewInsert) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/perfume_reviews") else { throw SupabaseError.serverError("Invalid URL") }
        var request = authenticatedRequest(url: url, method: "POST", prefer: "return=minimal")
        request.httpBody = try JSONEncoder().encode(review)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else { throw SupabaseError.networkError }
        if http.statusCode == 401 {
            await refreshTokenIfNeeded()
            var retryRequest = authenticatedRequest(url: url, method: "POST", prefer: "return=minimal")
            retryRequest.httpBody = try JSONEncoder().encode(review)
            let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
            guard let retryHttp = retryResponse as? HTTPURLResponse, retryHttp.statusCode < 400 else {
                if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: retryData) {
                    throw SupabaseError.serverError(e.message ?? e.msg ?? "Failed to post review")
                }
                throw SupabaseError.serverError("Failed to post review")
            }
            return
        }
        if http.statusCode >= 400 {
            if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.serverError(e.message ?? e.msg ?? "Failed to post review")
            }
            throw SupabaseError.serverError("Failed to post review (\(http.statusCode))")
        }
    }

    func fetchReviewLikes(reviewIds: [String]) async throws -> [ReviewLike] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty, !reviewIds.isEmpty else { return [] }
        let ids = reviewIds.joined(separator: ",")
        guard let url = URL(string: "\(supabaseURL)/rest/v1/review_likes?review_id=in.(\(ids))&select=*") else { return [] }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else { return [] }
        return try JSONDecoder().decode([ReviewLike].self, from: data)
    }

    func toggleReviewLike(userId: String, reviewId: String, isLiked: Bool) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        if isLiked {
            guard let url = URL(string: "\(supabaseURL)/rest/v1/review_likes?user_id=eq.\(userId)&review_id=eq.\(reviewId)") else { throw SupabaseError.serverError("Invalid URL") }
            let request = authenticatedRequest(url: url, method: "DELETE")
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
                throw SupabaseError.serverError("Failed to unlike review")
            }
        } else {
            guard let url = URL(string: "\(supabaseURL)/rest/v1/review_likes") else { throw SupabaseError.serverError("Invalid URL") }
            var request = authenticatedRequest(url: url, method: "POST", prefer: "return=minimal")
            request.httpBody = try JSONEncoder().encode(ReviewLikeInsert(user_id: userId, review_id: reviewId))
            let (_, response) = try await URLSession.shared.data(for: request)
            guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
                throw SupabaseError.serverError("Failed to like review")
            }
        }
    }

    func fetchActivityFeed(userIds: [String]) async throws -> [ActivityFeedItem] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty, !userIds.isEmpty else { return [] }
        let ids = userIds.joined(separator: ",")
        guard let url = URL(string: "\(supabaseURL)/rest/v1/activity_feed?user_id=in.(\(ids))&select=*&order=created_at.desc&limit=50") else { return [] }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to fetch activity feed")
        }
        return try JSONDecoder().decode([ActivityFeedItem].self, from: data)
    }

    func insertActivity(_ activity: ActivityFeedInsert) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { return }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/activity_feed") else { return }
        var request = authenticatedRequest(url: url, method: "POST", prefer: "return=minimal")
        request.httpBody = try JSONEncoder().encode(activity)
        let (_, response) = try await URLSession.shared.data(for: request)
        if let http = response as? HTTPURLResponse, http.statusCode == 401 {
            await refreshTokenIfNeeded()
            var retryRequest = authenticatedRequest(url: url, method: "POST", prefer: "return=minimal")
            retryRequest.httpBody = try JSONEncoder().encode(activity)
            _ = try? await URLSession.shared.data(for: retryRequest)
        }
    }

    func fetchFollowers(userId: String) async throws -> [SupabaseFollow] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/follows?following_id=eq.\(userId)&select=*") else { throw SupabaseError.serverError("Invalid URL") }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to fetch followers")
        }
        return try JSONDecoder().decode([SupabaseFollow].self, from: data)
    }

    func sendNoseBump(_ bump: NoseBumpInsert) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/sniffs") else { throw SupabaseError.serverError("Invalid URL") }
        var request = authenticatedRequest(url: url, method: "POST", prefer: "return=minimal")
        request.httpBody = try JSONEncoder().encode(bump)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.serverError(e.message ?? "Failed to send nose bump")
            }
            throw SupabaseError.serverError("Failed to send nose bump")
        }
    }

    func fetchNoseBumps(targetUserId: String, perfumeName: String, perfumeBrand: String) async throws -> [NoseBump] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { return [] }
        let encodedName = perfumeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeName
        let encodedBrand = perfumeBrand.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeBrand
        guard let url = URL(string: "\(supabaseURL)/rest/v1/sniffs?target_user_id=eq.\(targetUserId)&perfume_name=eq.\(encodedName)&perfume_brand=eq.\(encodedBrand)&select=*") else { return [] }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else { return [] }
        return try JSONDecoder().decode([NoseBump].self, from: data)
    }

    func fetchNoseBumpsForUser(targetUserId: String) async throws -> [NoseBump] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { return [] }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/sniffs?target_user_id=eq.\(targetUserId)&select=*&order=created_at.desc") else { return [] }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else { return [] }
        return try JSONDecoder().decode([NoseBump].self, from: data)
    }

    func hasUserBumped(userId: String, targetUserId: String, perfumeName: String, perfumeBrand: String) async throws -> Bool {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { return false }
        let encodedName = perfumeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeName
        let encodedBrand = perfumeBrand.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeBrand
        guard let url = URL(string: "\(supabaseURL)/rest/v1/sniffs?user_id=eq.\(userId)&target_user_id=eq.\(targetUserId)&perfume_name=eq.\(encodedName)&perfume_brand=eq.\(encodedBrand)&select=id&limit=1") else { return false }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else { return false }
        let items = try JSONDecoder().decode([NoseBump].self, from: data)
        return !items.isEmpty
    }

    func removeNoseBump(userId: String, targetUserId: String, perfumeName: String, perfumeBrand: String) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { throw SupabaseError.serverError("Supabase is not configured.") }
        let encodedName = perfumeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeName
        let encodedBrand = perfumeBrand.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeBrand
        guard let url = URL(string: "\(supabaseURL)/rest/v1/sniffs?user_id=eq.\(userId)&target_user_id=eq.\(targetUserId)&perfume_name=eq.\(encodedName)&perfume_brand=eq.\(encodedBrand)") else { throw SupabaseError.serverError("Invalid URL") }
        let request = authenticatedRequest(url: url, method: "DELETE")
        let (_, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to remove nose bump")
        }
    }

    func fetchNotifications(userId: String) async throws -> [AppNotification] {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { return [] }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/notifications?user_id=eq.\(userId)&select=*&order=created_at.desc&limit=50") else { return [] }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else { return [] }
        return try JSONDecoder().decode([AppNotification].self, from: data)
    }

    func insertNotification(_ notification: AppNotificationInsert) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { return }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/notifications") else { return }
        var request = authenticatedRequest(url: url, method: "POST", prefer: "return=minimal")
        request.httpBody = try JSONEncoder().encode(notification)
        _ = try? await URLSession.shared.data(for: request)
    }

    func markNotificationsRead(userId: String) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { return }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/notifications?user_id=eq.\(userId)&read=eq.false") else { return }
        var request = authenticatedRequest(url: url, method: "PATCH", prefer: "return=minimal")
        let body: [String: Bool] = ["read": true]
        request.httpBody = try JSONEncoder().encode(body)
        _ = try? await URLSession.shared.data(for: request)
    }

    func fetchUnreadNotificationCount(userId: String) async throws -> Int {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { return 0 }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/notifications?user_id=eq.\(userId)&read=eq.false&select=id") else { return 0 }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else { return 0 }
        let items = try JSONDecoder().decode([AppNotification].self, from: data)
        return items.count
    }

    func updateProfile(userId: String, update: SupabaseProfileUpdate) async throws {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.serverError("Supabase is not configured.")
        }
        guard let url = URL(string: "\(supabaseURL)/rest/v1/profiles?id=eq.\(userId)") else {
            throw SupabaseError.serverError("Invalid URL")
        }
        var request = authenticatedRequest(url: url, method: "PATCH", prefer: "return=minimal")
        request.httpBody = try JSONEncoder().encode(update)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }
        if http.statusCode == 401 {
            await refreshTokenIfNeeded()
            var retryRequest = authenticatedRequest(url: url, method: "PATCH", prefer: "return=minimal")
            retryRequest.httpBody = try JSONEncoder().encode(update)
            let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
            guard let retryHttp = retryResponse as? HTTPURLResponse, retryHttp.statusCode < 400 else {
                if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: retryData) {
                    throw SupabaseError.serverError(e.message ?? "Failed to update profile")
                }
                throw SupabaseError.serverError("Failed to update profile")
            }
            return
        }
        if http.statusCode >= 400 {
            if let e = try? JSONDecoder().decode(SupabaseErrorResponse.self, from: data) {
                throw SupabaseError.serverError(e.message ?? "Failed to update profile")
            }
            throw SupabaseError.serverError("Failed to update profile (\(http.statusCode))")
        }
    }

    func fetchNoseBumpCount(targetUserId: String, perfumeName: String, perfumeBrand: String) async throws -> Int {
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else { return 0 }
        let encodedName = perfumeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeName
        let encodedBrand = perfumeBrand.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeBrand
        guard let url = URL(string: "\(supabaseURL)/rest/v1/sniffs?target_user_id=eq.\(targetUserId)&perfume_name=eq.\(encodedName)&perfume_brand=eq.\(encodedBrand)&select=id") else { return 0 }
        let request = authenticatedRequest(url: url)
        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse, http.statusCode < 400 else { return 0 }
        let items = try JSONDecoder().decode([NoseBump].self, from: data)
        return items.count
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
    case networkError
    case serverError(String)

    var errorDescription: String? {
        switch self {
        case .networkError: return "Network error. Please try again."
        case .serverError(let msg): return msg
        }
    }
}
