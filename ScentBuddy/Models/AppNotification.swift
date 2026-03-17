import Foundation

nonisolated struct AppNotification: Sendable, Identifiable {
    var id: String
    var user_id: String
    var from_user_id: String
    var notification_type: String
    var message: String?
    var perfume_name: String?
    var perfume_brand: String?
    var is_read: Bool?
    var created_at: String?
}

extension AppNotification: Decodable {
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: FlexibleCodingKey.self)
        let rawId = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "id"))
        let intId = try? container.decode(Int.self, forKey: FlexibleCodingKey(stringValue: "id"))
        self.id = rawId ?? (intId.map { String($0) } ?? UUID().uuidString)
        self.user_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "user_id"))) ?? ""
        self.from_user_id = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "from_user_id"))) ?? ""
        self.notification_type = (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "notification_type"))) ?? (try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "type"))) ?? ""
        self.message = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "message"))
        self.perfume_name = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_name"))
        self.perfume_brand = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "perfume_brand"))
        self.is_read = (try? container.decode(Bool.self, forKey: FlexibleCodingKey(stringValue: "is_read"))) ?? (try? container.decode(Bool.self, forKey: FlexibleCodingKey(stringValue: "read")))
        self.created_at = try? container.decode(String.self, forKey: FlexibleCodingKey(stringValue: "created_at"))
    }
}

nonisolated struct FlexibleCodingKey: CodingKey, Sendable {
    var stringValue: String
    var intValue: Int?
    init(stringValue: String) { self.stringValue = stringValue; self.intValue = nil }
    init?(intValue: Int) { self.stringValue = String(intValue); self.intValue = intValue }
}

nonisolated struct AppNotificationInsert: Encodable, Sendable {
    let user_id: String
    let from_user_id: String
    let notification_type: String
    let message: String?
    let perfume_name: String?
    let perfume_brand: String?
}
