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
    var layeredPerfumeNames: [String]
    var layeredPerfumeBrands: [String]

    var isLayered: Bool {
        !layeredPerfumeNames.isEmpty
    }

    init(
        perfumeName: String,
        perfumeBrand: String,
        date: Date = Date(),
        occasion: String = "Everyday",
        mood: String = "Confident",
        notes: String = "",
        rating: Int = 4,
        sprays: Int = 3,
        layeredPerfumeNames: [String] = [],
        layeredPerfumeBrands: [String] = []
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
        self.layeredPerfumeNames = layeredPerfumeNames
        self.layeredPerfumeBrands = layeredPerfumeBrands
    }
}
