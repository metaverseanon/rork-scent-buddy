import Foundation

nonisolated enum TrendingCategory: String, CaseIterable, Sendable, Codable {
    case newRelease = "newRelease"
    case viral = "viral"
    case classic = "classic"
    case niche = "niche"
    case seasonal = "seasonal"

    var displayName: String {
        switch self {
        case .newRelease: return "New Releases"
        case .viral: return "Viral on Social"
        case .classic: return "Timeless Classics"
        case .niche: return "Niche Gems"
        case .seasonal: return "Seasonal Picks"
        }
    }
}

nonisolated struct TrendingPerfume: Identifiable, Sendable, Codable {
    var id: String { "\(brand)-\(name)" }
    let name: String
    let brand: String
    let imageURL: String?
    let description: String
    let notes: [String]
    let trendReason: String
    let releaseYear: Int
    let concentration: String
    let category: TrendingCategory
    let tiktokMentions: String?
    let socialSource: String?
    let hashtagCount: String?
    let lastSeenTrending: String?

    nonisolated enum CodingKeys: String, CodingKey {
        case name, brand, imageURL, description, notes, trendReason, releaseYear, concentration, category
        case tiktokMentions, socialSource, hashtagCount, lastSeenTrending
    }
}

nonisolated struct TrendingResponse: Codable, Sendable {
    let trending: [TrendingPerfume]
    let lastUpdated: String
    let nextUpdateAt: String
    let source: String?
}
