import Foundation

nonisolated struct AppNotification: Codable, Sendable, Identifiable {
    let id: String
    let user_id: String
    let from_user_id: String
    let notification_type: String
    let perfume_name: String?
    let perfume_brand: String?
    let is_read: Bool?
    let created_at: String?
}

nonisolated struct AppNotificationInsert: Encodable, Sendable {
    let user_id: String
    let from_user_id: String
    let notification_type: String
    let perfume_name: String?
    let perfume_brand: String?
}
