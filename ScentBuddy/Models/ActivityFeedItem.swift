import Foundation

nonisolated struct ActivityFeedItem: Codable, Sendable, Identifiable {
    let id: String
    let user_id: String
    let activity_type: String
    let perfume_name: String?
    let perfume_brand: String?
    let target_user_id: String?
    let metadata: String?
    let created_at: String?
}

nonisolated struct ActivityFeedInsert: Encodable, Sendable {
    let user_id: String
    let activity_type: String
    let perfume_name: String?
    let perfume_brand: String?
    let target_user_id: String?
}

nonisolated struct UserCollectionItem: Codable, Sendable, Identifiable {
    let id: String
    let user_id: String
    let perfume_name: String
    let perfume_brand: String
    let image_url: String?
    let concentration: String?
    let top_notes: [String]?
    let heart_notes: [String]?
    let base_notes: [String]?
    let season: String?
    let occasion: String?
    let rating: Int?
    let personal_notes: String?
    let is_favorite: Bool?
    let date_added: String?
    let created_at: String?
}

nonisolated struct UserCollectionInsert: Encodable, Sendable {
    let user_id: String
    let perfume_name: String
    let perfume_brand: String
    let image_url: String?
    let concentration: String
    let top_notes: [String]
    let heart_notes: [String]
    let base_notes: [String]
    let season: String
    let occasion: String
    let rating: Int
    let personal_notes: String
    let is_favorite: Bool
}

nonisolated struct UserWishlistItem: Codable, Sendable, Identifiable {
    let id: String
    let user_id: String
    let perfume_name: String
    let perfume_brand: String
    let image_url: String?
    let concentration: String?
    let notes: [String]?
    let estimated_price: String?
    let reason: String?
    let priority: Int?
    let date_added: String?
    let created_at: String?
}

nonisolated struct UserWishlistInsert: Encodable, Sendable {
    let user_id: String
    let perfume_name: String
    let perfume_brand: String
    let image_url: String?
    let concentration: String
    let notes: [String]
    let estimated_price: String
    let reason: String
    let priority: Int
}
