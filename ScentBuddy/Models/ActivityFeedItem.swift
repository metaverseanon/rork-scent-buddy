import Foundation

nonisolated struct ActivityFeedItem: Sendable, Identifiable {
    let id: String
    let user_id: String
    let activity_type: String
    let perfume_name: String?
    let perfume_brand: String?
    let target_user_id: String?
    let metadata: String?
    let created_at: String?
}

extension ActivityFeedItem: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        let rawId = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "id"))
        let intId = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "id"))
        self.id = rawId ?? (intId.map { String($0) } ?? UUID().uuidString)
        self.user_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "user_id"))) ?? ""
        self.activity_type = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "activity_type"))) ?? ""
        self.perfume_name = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_name"))
        self.perfume_brand = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_brand"))
        self.target_user_id = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "target_user_id"))
        self.metadata = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "metadata"))
        self.created_at = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "created_at"))
    }
}

nonisolated struct ActivityFeedInsert: Encodable, Sendable {
    let user_id: String
    let activity_type: String
    let perfume_name: String?
    let perfume_brand: String?
    let target_user_id: String?
}

nonisolated struct UserCollectionItem: Sendable, Identifiable {
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

extension UserCollectionItem: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        let rawId = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "id"))
        let intId = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "id"))
        self.id = rawId ?? (intId.map { String($0) } ?? UUID().uuidString)
        self.user_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "user_id"))) ?? ""
        self.perfume_name = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_name"))) ?? ""
        self.perfume_brand = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_brand"))) ?? ""
        self.image_url = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "image_url"))
        self.concentration = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "concentration"))
        self.top_notes = try? container.decode([String].self, forKey: FlexibleCodingKey(stringValue: "top_notes"))
        self.heart_notes = try? container.decode([String].self, forKey: FlexibleCodingKey(stringValue: "heart_notes"))
        self.base_notes = try? container.decode([String].self, forKey: FlexibleCodingKey(stringValue: "base_notes"))
        self.season = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "season"))
        self.occasion = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "occasion"))
        self.rating = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "rating"))
        self.personal_notes = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "personal_notes"))
        self.is_favorite = try? container.decode(Bool.self, forKey: FlexibleCodingKey(stringValue: "is_favorite"))
        self.date_added = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "date_added"))
        self.created_at = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "created_at"))
    }
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

nonisolated struct UserWishlistItem: Sendable, Identifiable {
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

extension UserWishlistItem: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        let rawId = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "id"))
        let intId = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "id"))
        self.id = rawId ?? (intId.map { String($0) } ?? UUID().uuidString)
        self.user_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "user_id"))) ?? ""
        self.perfume_name = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_name"))) ?? ""
        self.perfume_brand = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_brand"))) ?? ""
        self.image_url = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "image_url"))
        self.concentration = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "concentration"))
        self.notes = try? container.decode([String].self, forKey: FlexibleCodingKey(stringValue: "notes"))
        self.estimated_price = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "estimated_price"))
        self.reason = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "reason"))
        self.priority = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "priority"))
        self.date_added = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "date_added"))
        self.created_at = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "created_at"))
    }
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
