import SwiftData
import Foundation

@Model
class WishlistPerfume {
    var id: UUID
    var name: String
    var brand: String
    var imageURL: String?
    var concentration: String
    var notes: [String]
    var estimatedPrice: String
    var reason: String
    var dateAdded: Date
    var priority: Int

    init(
        name: String,
        brand: String,
        imageURL: String? = nil,
        concentration: String = "Eau de Parfum",
        notes: [String] = [],
        estimatedPrice: String = "",
        reason: String = "",
        priority: Int = 2
    ) {
        self.id = UUID()
        self.name = name
        self.brand = brand
        self.imageURL = imageURL
        self.concentration = concentration
        self.notes = notes
        self.estimatedPrice = estimatedPrice
        self.reason = reason
        self.dateAdded = Date()
        self.priority = priority
    }
}
