import Foundation

@Observable
final class OnboardingManager {
    static let shared = OnboardingManager()

    var hasCompletedOnboarding: Bool {
        didSet {
            UserDefaults.standard.set(hasCompletedOnboarding, forKey: "has_completed_onboarding")
        }
    }

    var notePreferences: NotePreferences {
        didSet { savePreferences() }
    }

    private let prefsKey = "note_preferences"

    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "has_completed_onboarding")
        if let data = UserDefaults.standard.data(forKey: prefsKey),
           let saved = try? JSONDecoder().decode(NotePreferences.self, from: data) {
            self.notePreferences = saved
        } else {
            self.notePreferences = NotePreferences()
        }
    }

    func completeOnboarding(with favoriteNotes: [String]) {
        notePreferences = NotePreferences(favoriteNotes: favoriteNotes, completedOnboarding: true)
        hasCompletedOnboarding = true
    }

    private func savePreferences() {
        if let data = try? JSONEncoder().encode(notePreferences) {
            UserDefaults.standard.set(data, forKey: prefsKey)
        }
    }
}
