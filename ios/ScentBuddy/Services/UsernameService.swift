import Foundation

@Observable
final class UsernameService {
    static let shared = UsernameService()

    private(set) var isChecking: Bool = false
    private(set) var isAvailable: Bool? = nil
    private(set) var errorMessage: String? = nil

    private var checkTask: Task<Void, Never>?

    private static let apiBaseURL: String? = {
        if let url = Bundle.main.infoDictionary?["RORK_API_BASE_URL"] as? String, !url.isEmpty {
            return url
        }
        let configURL = Config.EXPO_PUBLIC_RORK_API_BASE_URL
        if !configURL.isEmpty {
            return configURL
        }
        return nil
    }()

    private init() {}

    func checkUsername(_ username: String) {
        checkTask?.cancel()
        let trimmed = username.trimmingCharacters(in: .whitespaces).lowercased()

        guard trimmed.count >= 3 else {
            isAvailable = nil
            errorMessage = trimmed.isEmpty ? nil : "Username must be at least 3 characters"
            isChecking = false
            return
        }

        guard trimmed.count <= 20 else {
            isAvailable = false
            errorMessage = "Username must be 20 characters or less"
            isChecking = false
            return
        }

        let pattern = /^[a-z0-9._]+$/
        guard trimmed.wholeMatch(of: pattern) != nil else {
            isAvailable = false
            errorMessage = "Only letters, numbers, dots, and underscores"
            isChecking = false
            return
        }

        isChecking = true
        isAvailable = nil
        errorMessage = nil

        checkTask = Task {
            try? await Task.sleep(for: .milliseconds(500))
            guard !Task.isCancelled else { return }

            guard let baseURL = Self.apiBaseURL else {
                isChecking = false
                isAvailable = nil
                errorMessage = "Service unavailable"
                return
            }

            guard let url = URL(string: "\(baseURL)/api/usernames/check?username=\(trimmed)") else {
                isChecking = false
                return
            }

            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                guard !Task.isCancelled else { return }
                let response = try JSONDecoder().decode(UsernameCheckResponse.self, from: data)
                isAvailable = response.available
                errorMessage = response.available ? nil : "Username is already taken"
            } catch {
                guard !Task.isCancelled else { return }
                isAvailable = nil
                errorMessage = nil
            }
            isChecking = false
        }
    }

    func registerUsername(_ username: String) async -> Bool {
        let trimmed = username.trimmingCharacters(in: .whitespaces).lowercased()

        guard let baseURL = Self.apiBaseURL,
              let url = URL(string: "\(baseURL)/api/usernames/register") else {
            return false
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONEncoder().encode(["username": trimmed])

        do {
            let (data, _) = try await URLSession.shared.data(for: request)
            let response = try JSONDecoder().decode(UsernameRegisterResponse.self, from: data)
            return response.success
        } catch {
            return false
        }
    }

    func reset() {
        checkTask?.cancel()
        isChecking = false
        isAvailable = nil
        errorMessage = nil
    }
}

nonisolated struct UsernameCheckResponse: Codable, Sendable {
    let available: Bool
    var error: String?
    var username: String?
}

nonisolated struct UsernameRegisterResponse: Codable, Sendable {
    let success: Bool
    var error: String?
    var username: String?
}
