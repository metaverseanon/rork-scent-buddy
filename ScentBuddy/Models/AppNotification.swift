import Foundation

nonisolated struct AppNotification: Codable, Sendable, Identifiable {
    let id: String
    let user_id: String
    let from_user_id: String
    let notification_type: String
    let message: String?
    let perfume_name: String?
    let perfume_brand: String?
    let is_read: Bool?
    let created_at: String?

    nonisolated enum CodingKeys: String, CodingKey {
        case id, user_id, from_user_id
        case notification_type = "type"
        case message
        case perfume_name, perfume_brand
        case is_read = "read"
        case created_at
    }
}

nonisolated struct AppNotificationInsert: Encodable, Sendable {
    let user_id: String
    let from_user_id: String
    let notification_type: String
    let message: String?
    let perfume_name: String?
    let perfume_brand: String?

    nonisolated enum CodingKeys: String, CodingKey {
        case user_id, from_user_id
        case notification_type = "type"
        case message
        case perfume_name, perfume_brand
    }
}
