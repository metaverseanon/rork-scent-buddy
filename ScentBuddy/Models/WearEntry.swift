import SwiftData
import Foundation

@Model
class WearEntry {
    var id: UUID
    var perfumeName: String
    var perfumeBrand: String
    var date: Date
    var occasion: String
    var mood: String
    var notes: String
    var rating: Int
    var sprays: Int

    init(
        perfumeName: String,
        perfumeBrand: String,
        date: Date = Date(),
        occasion: String = "Everyday",
        mood: String = "Confident",
        notes: String = "",
        rating: Int = 4,
        sprays: Int = 3
    ) {
        self.id = UUID()
        self.perfumeName = perfumeName
        self.perfumeBrand = perfumeBrand
        self.date = date
        self.occasion = occasion
        self.mood = mood
        self.notes = notes
        self.rating = rating
        self.sprays = sprays
    }
}
