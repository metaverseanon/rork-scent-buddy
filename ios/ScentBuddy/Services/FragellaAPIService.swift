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

    func search(query: String, limit: Int = 10) async {
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

            var retries = 0
            let maxRetries = 2

            while true {
                let (data, response) = try await URLSession.shared.data(for: request)
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0

                if statusCode == 429 && retries < maxRetries {
                    retries += 1
                    try await Task.sleep(for: .seconds(Double(retries) * 1.5))
                    continue
                }

                guard statusCode == 200 else {
                    errorMessage = statusCode == 429 ? "Rate limited — please wait a moment" : "API error (status \(statusCode))"
                    return
                }

                let parsed = try parseFragrances(from: data)
                searchResults = rankResults(parsed, query: trimmed)
                return
            }
        } catch is CancellationError {
            return
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
            let rawImageURL = dict["Image URL"] as? String
                ?? dict["ImageURL"] as? String
                ?? dict["image_url"] as? String
                ?? dict["imageUrl"] as? String
                ?? dict["Image"] as? String
                ?? dict["image"] as? String
            let imageURL = Self.sanitizeImageURL(rawImageURL)
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

    private func rankResults(_ results: [FragellaFragrance], query: String) -> [FragellaFragrance] {
        let q = query.lowercased()
        return results.sorted { a, b in
            let aName = a.name.lowercased()
            let bName = b.name.lowercased()
            let aBrand = a.brand.lowercased()
            let bBrand = b.brand.lowercased()

            let aExact = aName == q || "\(aBrand) \(aName)".contains(q)
            let bExact = bName == q || "\(bBrand) \(bName)".contains(q)
            if aExact != bExact { return aExact }

            let aPrefix = aName.hasPrefix(q) || aBrand.hasPrefix(q)
            let bPrefix = bName.hasPrefix(q) || bBrand.hasPrefix(q)
            if aPrefix != bPrefix { return aPrefix }

            let aNameContains = aName.contains(q)
            let bNameContains = bName.contains(q)
            if aNameContains != bNameContains { return aNameContains }

            return aName.count < bName.count
        }
    }

    private static func sanitizeImageURL(_ raw: String?) -> String? {
        guard var urlString = raw, !urlString.isEmpty else { return nil }
        urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString.hasPrefix("//") {
            urlString = "https:" + urlString
        }
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        guard URL(string: urlString) != nil else { return nil }
        return urlString
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
