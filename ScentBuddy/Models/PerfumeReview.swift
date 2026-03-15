import Foundation

nonisolated struct PerfumeReview: Codable, Sendable, Identifiable {
    let id: String
    let user_id: String
    let perfume_name: String
    let perfume_brand: String
    let rating: Int
    let review_text: String?
    let longevity: Int?
    let sillage: Int?
    let value_for_money: Int?
    let created_at: String?
    let updated_at: String?
}

nonisolated struct PerfumeReviewInsert: Encodable, Sendable {
    let user_id: String
    let perfume_name: String
    let perfume_brand: String
    let rating: Int
    let review_text: String?
    let longevity: Int?
    let sillage: Int?
    let value_for_money: Int?
}

nonisolated struct ReviewLike: Codable, Sendable {
    let id: String
    let user_id: String
    let review_id: String
    let created_at: String?
}

nonisolated struct ReviewLikeInsert: Encodable, Sendable {
    let user_id: String
    let review_id: String
}
