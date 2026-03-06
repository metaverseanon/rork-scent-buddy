import SwiftUI

@Observable
final class UserProfileManager {
    static let shared = UserProfileManager()

    var profile: UserProfile {
        didSet { save() }
    }

    var isLoggedIn: Bool {
        !profile.displayName.isEmpty
    }

    private let key = "user_profile"

    private init() {
        if let data = UserDefaults.standard.data(forKey: key),
           let saved = try? JSONDecoder().decode(UserProfile.self, from: data) {
            self.profile = saved
        } else {
            self.profile = UserProfile()
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func signOut() {
        profile = UserProfile()
        UserDefaults.standard.removeObject(forKey: key)
    }
}
