import Foundation

nonisolated struct FragellaNote: Sendable {
    let name: String
    let occurrence: String?
    let description: String?
}

nonisolated struct FragellaFragrance: Sendable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let concentration: String
    let topNotes: [String]
    let heartNotes: [String]
    let baseNotes: [String]
    let imageURL: String?
    let year: String?

    var allNotes: [String] { topNotes + heartNotes + baseNotes }
}

@Observable
final class FragellaAPIService {
    private(set) var isSearching: Bool = false
    var searchResults: [FragellaFragrance] = []
    private(set) var errorMessage: String?

    private static let apiKey: String = Config.EXPO_PUBLIC_FRAGELLA_API_KEY
    private static let baseURL = "https://api.fragella.com/api/v1"

    var isConfigured: Bool {
        !Self.apiKey.isEmpty
    }

    func search(query: String, limit: Int = 20) async {
        let trimmed = query.trimmingCharacters(in: .whitespaces)
        guard trimmed.count >= 3 else {
            searchResults = []
            return
        }

        isSearching = true
        errorMessage = nil
        defer { isSearching = false }

        do {
            var components = URLComponents(string: "\(Self.baseURL)/fragrances")!
            components.queryItems = [
                URLQueryItem(name: "search", value: trimmed),
                URLQueryItem(name: "limit", value: "\(limit)")
            ]

            guard let url = components.url else {
                errorMessage = "Invalid search URL"
                return
            }

            var request = URLRequest(url: url)
            request.setValue(Self.apiKey, forHTTPHeaderField: "x-api-key")
            request.timeoutInterval = 10

            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
                errorMessage = "API error (status \(statusCode))"
                return
            }

            let parsed = try parseFragrances(from: data)
            searchResults = parsed
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func parseFragrances(from data: Data) throws -> [FragellaFragrance] {
        guard let jsonArray = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }

        return jsonArray.compactMap { dict -> FragellaFragrance? in
            guard let name = dict["Name"] as? String,
                  let brand = dict["Brand"] as? String else { return nil }

            let concentration = (dict["OilType"] as? String) ?? "Eau de Parfum"
            let imageURL = dict["Image URL"] as? String
            let year = dict["Year"] as? String

            var topNotes: [String] = []
            var heartNotes: [String] = []
            var baseNotes: [String] = []

            if let notes = dict["Notes"] as? [String: Any] {
                topNotes = extractNoteNames(from: notes["TopNotes"] ?? notes["Top Notes"])
                heartNotes = extractNoteNames(from: notes["HeartNotes"] ?? notes["Heart Notes"] ?? notes["MiddleNotes"] ?? notes["Middle Notes"])
                baseNotes = extractNoteNames(from: notes["BaseNotes"] ?? notes["Base Notes"])
            }

            let id = "\(brand.lowercased().replacingOccurrences(of: " ", with: "-"))-\(name.lowercased().replacingOccurrences(of: " ", with: "-"))"

            return FragellaFragrance(
                id: id,
                name: name,
                brand: brand,
                concentration: concentration,
                topNotes: topNotes,
                heartNotes: heartNotes,
                baseNotes: baseNotes,
                imageURL: imageURL,
                year: year
            )
        }
    }

    private func extractNoteNames(from value: Any?) -> [String] {
        guard let value else { return [] }

        if let stringArray = value as? [String] {
            return stringArray
        }

        if let dictArray = value as? [[String: Any]] {
            return dictArray.compactMap { $0["Name"] as? String ?? $0["name"] as? String }
        }

        return []
    }
}
