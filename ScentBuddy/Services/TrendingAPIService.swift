import Foundation

@Observable
final class TrendingAPIService {
    private(set) var trendingPerfumes: [TrendingPerfume] = []
    private(set) var isLoading: Bool = false
    private(set) var lastUpdated: Date?
    private(set) var errorMessage: String?
    private(set) var dataSource: String?

    private static let apiBaseURL: String? = {
        let configURL = Config.EXPO_PUBLIC_RORK_API_BASE_URL
        if !configURL.isEmpty {
            return configURL
        }
        if let url = Bundle.main.infoDictionary?["RORK_API_BASE_URL"] as? String, !url.isEmpty {
            return url
        }
        return nil
    }()

    private let cacheKey = "cached_trending_perfumes_v3"
    private let cacheTimestampKey = "cached_trending_timestamp_v3"
    private let cacheDuration: TimeInterval = 4 * 60 * 60

    init() {
        loadFromCache()
    }

    var isCacheStale: Bool {
        guard let lastUpdated else { return true }
        return Date().timeIntervalSince(lastUpdated) > cacheDuration
    }

    func fetchTrending(forceRefresh: Bool = false) async {
        if !forceRefresh && !isCacheStale && !trendingPerfumes.isEmpty {
            return
        }

        isLoading = true
        errorMessage = nil

        defer { isLoading = false }

        do {
            let perfumes = try await fetchFromAPI(forceRefresh: forceRefresh)
            trendingPerfumes = perfumes
            lastUpdated = Date()
            dataSource = "live"
            saveToCache(perfumes)
        } catch {
            errorMessage = error.localizedDescription
            if trendingPerfumes.isEmpty {
                loadFromCache()
            }
        }
    }

    private func fetchFromAPI(forceRefresh: Bool) async throws -> [TrendingPerfume] {
        guard let baseURL = Self.apiBaseURL else {
            throw URLError(.badURL)
        }

        let cleanBase = baseURL.hasSuffix("/") ? String(baseURL.dropLast()) : baseURL
        let urlString = "\(cleanBase)/api/trending\(forceRefresh ? "?refresh=true" : "")"

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 30
        request.cachePolicy = forceRefresh ? .reloadIgnoringLocalCacheData : .useProtocolCachePolicy
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }

        let decoded = try JSONDecoder().decode(TrendingResponse.self, from: data)
        return decoded.trending
    }

    private func saveToCache(_ perfumes: [TrendingPerfume]) {
        guard let data = try? JSONEncoder().encode(perfumes) else { return }
        UserDefaults.standard.set(data, forKey: cacheKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: cacheTimestampKey)
    }

    private func loadFromCache() {
        let timestamp = UserDefaults.standard.double(forKey: cacheTimestampKey)
        if timestamp > 0 {
            lastUpdated = Date(timeIntervalSince1970: timestamp)
        }

        guard let data = UserDefaults.standard.data(forKey: cacheKey),
              let perfumes = try? JSONDecoder().decode([TrendingPerfume].self, from: data),
              !perfumes.isEmpty else {
            return
        }

        trendingPerfumes = perfumes
        dataSource = "cache"
    }
}
