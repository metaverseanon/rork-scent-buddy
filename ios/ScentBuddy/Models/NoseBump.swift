import Foundation

nonisolated struct NoseBump: Sendable, Identifiable {
    let id: String
    let user_id: String
    let target_user_id: String
    let perfume_name: String
    let perfume_brand: String
    let created_at: String?
}

extension NoseBump: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        let rawId = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "id"))
        let intId = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "id"))
        self.id = rawId ?? (intId.map { String($0) } ?? UUID().uuidString)
        self.user_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "user_id"))) ?? ""
        self.target_user_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "target_user_id"))) ?? ""
        self.perfume_name = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_name"))) ?? ""
        self.perfume_brand = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_brand"))) ?? ""
        self.created_at = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "created_at"))
    }
}

nonisolated struct NoseBumpInsert: Encodable, Sendable {
    let user_id: String
    let target_user_id: String
    let perfume_name: String
    let perfume_brand: String
}
