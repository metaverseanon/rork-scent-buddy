import Foundation

nonisolated struct PerfumeReview: Sendable, Identifiable {
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

extension PerfumeReview: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        let rawId = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "id"))
        let intId = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "id"))
        self.id = rawId ?? (intId.map { String($0) } ?? UUID().uuidString)
        self.user_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "user_id"))) ?? ""
        self.perfume_name = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_name"))) ?? ""
        self.perfume_brand = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_brand"))) ?? ""
        self.rating = (try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "rating"))) ?? 0
        self.review_text = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "review_text"))
        self.longevity = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "longevity"))
        self.sillage = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "sillage"))
        self.value_for_money = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "value_for_money"))
        self.created_at = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "created_at"))
        self.updated_at = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "updated_at"))
    }
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

nonisolated struct ReviewLike: Sendable {
    let id: String
    let user_id: String
    let review_id: String
    let created_at: String?
}

extension ReviewLike: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        let rawId = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "id"))
        let intId = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "id"))
        self.id = rawId ?? (intId.map { String($0) } ?? UUID().uuidString)
        self.user_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "user_id"))) ?? ""
        self.review_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "review_id"))) ?? ""
        self.created_at = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "created_at"))
    }
}

nonisolated struct ReviewLikeInsert: Encodable, Sendable {
    let user_id: String
    let review_id: String
}
