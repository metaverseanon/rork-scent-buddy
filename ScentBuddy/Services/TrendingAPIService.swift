import Foundation

@Observable
final class TrendingAPIService {
    private(set) var trendingPerfumes: [TrendingPerfume] = []
    private(set) var isLoading: Bool = false
    private(set) var lastUpdated: Date?
    private(set) var errorMessage: String?
    private(set) var dataSource: String?

    private let cacheKey = "cached_trending_perfumes_v5"
    private let cacheTimestampKey = "cached_trending_timestamp_v5"
    private let cacheDuration: TimeInterval = 4 * 60 * 60

    private var baseURL: String {
        Config.EXPO_PUBLIC_RORK_API_BASE_URL
    }

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

        if !baseURL.isEmpty {
            do {
                let perfumes = try await fetchFromBackend(forceRefresh: forceRefresh)
                trendingPerfumes = perfumes
                lastUpdated = Date()
                dataSource = "api"
                saveToCache(perfumes)
                return
            } catch {
                print("[TrendingAPI] Backend fetch failed: \(error.localizedDescription), falling back to local data")
            }
        }

        let perfumes = TrendingDataProvider.generateTrendingList()
        trendingPerfumes = perfumes
        lastUpdated = Date()
        dataSource = "local"
        saveToCache(perfumes)
    }

    private func fetchFromBackend(forceRefresh: Bool) async throws -> [TrendingPerfume] {
        var urlString = "\(baseURL)/trending"
        if forceRefresh {
            urlString += "?refresh=true"
        }

        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode < 400 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw URLError(.badServerResponse, userInfo: [NSLocalizedDescriptionKey: "Server returned \(statusCode)"])
        }

        let trendingResponse = try JSONDecoder().decode(TrendingResponse.self, from: data)
        return trendingResponse.trending
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
