import Foundation

nonisolated struct NotePreferences: Codable, Sendable {
    var favoriteNotes: [String]
    var completedOnboarding: Bool

    init(favoriteNotes: [String] = [], completedOnboarding: Bool = false) {
        self.favoriteNotes = favoriteNotes
        self.completedOnboarding = completedOnboarding
    }
}
