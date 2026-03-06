import Foundation
import Supabase

nonisolated final class UserDefaultsAuthStorage: AuthLocalStorage, @unchecked Sendable {
    private let defaults = UserDefaults.standard
    private let prefix = "supabase_auth_"

    func store(key: String, value: Data) throws {
        defaults.set(value, forKey: prefix + key)
    }

    func retrieve(key: String) throws -> Data? {
        defaults.data(forKey: prefix + key)
    }

    func remove(key: String) throws {
        defaults.removeObject(forKey: prefix + key)
    }
}

enum SupabaseManager {
    private static let lock = NSLock()
    private static var _client: SupabaseClient?
    private static var _initialized = false

    static var isConfigured: Bool {
        !Config.EXPO_PUBLIC_SUPABASE_URL.isEmpty && !Config.EXPO_PUBLIC_SUPABASE_ANON_KEY.isEmpty
    }

    static var client: SupabaseClient? {
        lock.lock()
        defer { lock.unlock() }

        if _initialized { return _client }
        _initialized = true

        let urlString = Config.EXPO_PUBLIC_SUPABASE_URL
        let key = Config.EXPO_PUBLIC_SUPABASE_ANON_KEY

        guard !urlString.isEmpty,
              let url = URL(string: urlString),
              !key.isEmpty else {
            _client = nil
            return nil
        }

        _client = SupabaseClient(
            supabaseURL: url,
            supabaseKey: key,
            options: .init(
                auth: .init(
                    storage: UserDefaultsAuthStorage()
                )
            )
        )
        return _client
    }

    static func clearAuthData() {
        let defaults = UserDefaults.standard
        let prefix = "supabase_auth_"
        for key in defaults.dictionaryRepresentation().keys where key.hasPrefix(prefix) {
            defaults.removeObject(forKey: key)
        }
    }
}
