import Foundation

nonisolated struct RecommendedPerfume: Identifiable, Sendable {
    let id = UUID()
    let name: String
    let brand: String
    let imageURL: String?
    let description: String
    let notes: [String]
    let matchReason: String
    let matchPercentage: Int
    let concentration: String
}
