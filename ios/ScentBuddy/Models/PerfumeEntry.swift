import Foundation

nonisolated struct PerfumeEntry: Sendable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let concentration: String
    let topNotes: [String]
    let heartNotes: [String]
    let baseNotes: [String]
    let gender: String
    let imageURL: String?

    var displayName: String { "\(name) — \(brand)" }
    var allNotes: [String] { topNotes + heartNotes + baseNotes }
}
