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

    var tasteProfile: TasteProfile {
        didSet { saveTasteProfileData() }
    }

    var hasTasteProfile: Bool {
        tasteProfile.completedAt != nil
    }

    private let prefsKey = "note_preferences"
    private let tasteProfileKey = "taste_profile"

    private init() {
        self.hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "has_completed_onboarding")
        if let data = UserDefaults.standard.data(forKey: prefsKey),
           let saved = try? JSONDecoder().decode(NotePreferences.self, from: data) {
            self.notePreferences = saved
        } else {
            self.notePreferences = NotePreferences()
        }
        if let data = UserDefaults.standard.data(forKey: tasteProfileKey),
           let saved = try? JSONDecoder().decode(TasteProfile.self, from: data) {
            self.tasteProfile = saved
        } else {
            self.tasteProfile = TasteProfile()
        }
    }

    func completeOnboarding(with favoriteNotes: [String]) {
        notePreferences = NotePreferences(favoriteNotes: favoriteNotes, completedOnboarding: true)
        hasCompletedOnboarding = true
    }

    func saveTasteProfile(_ profile: TasteProfile) {
        tasteProfile = profile
        notePreferences = NotePreferences(
            favoriteNotes: profile.preferredNotes,
            completedOnboarding: true
        )
        hasCompletedOnboarding = true
    }

    private func savePreferences() {
        if let data = try? JSONEncoder().encode(notePreferences) {
            UserDefaults.standard.set(data, forKey: prefsKey)
        }
    }

    private func saveTasteProfileData() {
        if let data = try? JSONEncoder().encode(tasteProfile) {
            UserDefaults.standard.set(data, forKey: tasteProfileKey)
        }
    }
}
