import Foundation

nonisolated struct AppNotification: Codable, Sendable, Identifiable {
    var id: String
    var user_id: String
    var from_user_id: String
    var notification_type: String
    var message: String?
    var perfume_name: String?
    var perfume_brand: String?
    var is_read: Bool?
    var created_at: String?

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
