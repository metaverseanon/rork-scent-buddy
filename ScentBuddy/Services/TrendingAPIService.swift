import Foundation

@Observable
final class TrendingAPIService {
    private(set) var trendingPerfumes: [TrendingPerfume] = []
    private(set) var isLoading: Bool = false
    private(set) var lastUpdated: Date?
    private(set) var errorMessage: String?
    private(set) var dataSource: String?

    private let cacheKey = "cached_trending_perfumes_v4"
    private let cacheTimestampKey = "cached_trending_timestamp_v4"
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

        let perfumes = TrendingDataProvider.generateTrendingList()
        trendingPerfumes = perfumes
        lastUpdated = Date()
        dataSource = "live"
        saveToCache(perfumes)
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
