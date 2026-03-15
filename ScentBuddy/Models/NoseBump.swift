import Foundation

nonisolated struct NoseBump: Codable, Sendable, Identifiable {
    let id: String
    let user_id: String
    let target_user_id: String
    let perfume_name: String
    let perfume_brand: String
    let created_at: String?
}

nonisolated struct NoseBumpInsert: Encodable, Sendable {
    let user_id: String
    let target_user_id: String
    let perfume_name: String
    let perfume_brand: String
}
