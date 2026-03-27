import SwiftData
import Foundation

@Model
class Perfume {
    var id: UUID
    var name: String
    var brand: String
    var imageURL: String?
    var concentration: String
    var topNotes: [String]
    var heartNotes: [String]
    var baseNotes: [String]
    var season: String
    var occasion: String
    var rating: Int
    var personalNotes: String
    var dateAdded: Date
    var isFavorite: Bool

    init(
        name: String,
        brand: String,
        imageURL: String? = nil,
        concentration: String = "Eau de Parfum",
        topNotes: [String] = [],
        heartNotes: [String] = [],
        baseNotes: [String] = [],
        season: String = "All Seasons",
        occasion: String = "Everyday",
        rating: Int = 0,
        personalNotes: String = "",
        isFavorite: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.imageURL = imageURL
        self.concentration = concentration
        self.topNotes = topNotes
        self.heartNotes = heartNotes
        self.baseNotes = baseNotes
        self.season = season
        self.occasion = occasion
        self.rating = rating
        self.personalNotes = personalNotes
        self.dateAdded = Date()
        self.isFavorite = isFavorite
    }

    var allNotes: [String] {
        topNotes + heartNotes + baseNotes
    }
}
