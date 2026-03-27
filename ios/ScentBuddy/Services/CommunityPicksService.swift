import Foundation

nonisolated struct CommunityPick: Sendable, Identifiable {
    let id: String
    let perfumeName: String
    let perfumeBrand: String
    let imageURL: String?
    let addCount: Int
    let uniqueUsers: Int
    let rank: Int
}

@Observable
final class CommunityPicksService {
    private(set) var picks: [CommunityPick] = []
    private(set) var isLoading: Bool = false
    private(set) var errorMessage: String?
    private(set) var lastFetched: Date?

    private let supabase = SupabaseService.shared

    private let cacheKey = "community_picks_cache_v1"
    private let cacheTimestampKey = "community_picks_timestamp_v1"
    private let cacheDuration: TimeInterval = 30 * 60

    init() {
        loadFromCache()
    }

    func fetchCommunityPicks(forceRefresh: Bool = false) async {
        if !forceRefresh, let lastFetched, Date().timeIntervalSince(lastFetched) < cacheDuration, !picks.isEmpty {
            return
        }

        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let items = try await fetchRecentCollections()
            let aggregated = aggregateAndRank(items)
            picks = aggregated
            lastFetched = Date()
            saveToCache(aggregated)
        } catch {
            errorMessage = "Couldn't load community picks"
            print("[CommunityPicks] Error: \(error.localizedDescription)")
        }
    }

    private func fetchRecentCollections() async throws -> [UserCollectionItem] {
        let supabaseURL = Config.EXPO_PUBLIC_SUPABASE_URL.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        let supabaseKey = Config.EXPO_PUBLIC_SUPABASE_ANON_KEY.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !supabaseURL.isEmpty, !supabaseKey.isEmpty else {
            throw SupabaseError.serverError("Not configured")
        }

        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        let dateStr = formatter.string(from: sevenDaysAgo)

        let urlString = "\(supabaseURL)/rest/v1/user_collections?select=id,user_id,perfume_name,perfume_brand,image_url,created_at&created_at=gte.\(dateStr)&order=created_at.desc&limit=500"
        guard let url = URL(string: urlString) else {
            throw SupabaseError.serverError("Invalid URL")
        }

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(supabaseKey, forHTTPHeaderField: "apikey")
        if let token = supabase.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            request.setValue("Bearer \(supabaseKey)", forHTTPHeaderField: "Authorization")
        }
        request.timeoutInterval = 15

        let (data, response) = try await URLSession.shared.data(for: request)
        guard let http = response as? HTTPURLResponse else {
            throw SupabaseError.networkError
        }

        if http.statusCode == 401 {
            await supabase.refreshTokenIfNeeded()
            var retryRequest = request
            if let token = supabase.accessToken {
                retryRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            let (retryData, retryResponse) = try await URLSession.shared.data(for: retryRequest)
            guard let retryHttp = retryResponse as? HTTPURLResponse, retryHttp.statusCode < 400 else {
                throw SupabaseError.serverError("Failed to fetch collections")
            }
            return try JSONDecoder().decode([UserCollectionItem].self, from: retryData)
        }

        guard http.statusCode < 400 else {
            throw SupabaseError.serverError("Failed to fetch collections (\(http.statusCode))")
        }

        return try JSONDecoder().decode([UserCollectionItem].self, from: data)
    }

    private func aggregateAndRank(_ items: [UserCollectionItem]) -> [CommunityPick] {
        struct PerfumeKey: Hashable {
            let name: String
            let brand: String
        }

        struct AggData {
            var count: Int = 0
            var uniqueUserIds: Set<String> = []
            var imageURL: String?
        }

        var map: [PerfumeKey: AggData] = [:]

        for item in items {
            let key = PerfumeKey(name: item.perfume_name, brand: item.perfume_brand)
            var agg = map[key] ?? AggData()
            agg.count += 1
            agg.uniqueUserIds.insert(item.user_id)
            if agg.imageURL == nil, let img = item.image_url, !img.isEmpty {
                agg.imageURL = img
            }
            map[key] = agg
        }

        let sorted = map.sorted { $0.value.count > $1.value.count }

        return sorted.prefix(20).enumerated().map { index, pair in
            CommunityPick(
                id: "\(pair.key.brand)-\(pair.key.name)",
                perfumeName: pair.key.name,
                perfumeBrand: pair.key.brand,
                imageURL: pair.value.imageURL,
                addCount: pair.value.count,
                uniqueUsers: pair.value.uniqueUserIds.count,
                rank: index + 1
            )
        }
    }

    private func saveToCache(_ picks: [CommunityPick]) {
        let encoded = picks.map { pick -> [String: Any] in
            var dict: [String: Any] = [
                "id": pick.id,
                "perfumeName": pick.perfumeName,
                "perfumeBrand": pick.perfumeBrand,
                "addCount": pick.addCount,
                "uniqueUsers": pick.uniqueUsers,
                "rank": pick.rank
            ]
            if let img = pick.imageURL { dict["imageURL"] = img }
            return dict
        }
        UserDefaults.standard.set(encoded, forKey: cacheKey)
        UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: cacheTimestampKey)
    }

    private func loadFromCache() {
        let timestamp = UserDefaults.standard.double(forKey: cacheTimestampKey)
        if timestamp > 0 {
            lastFetched = Date(timeIntervalSince1970: timestamp)
        }
        guard let arr = UserDefaults.standard.array(forKey: cacheKey) as? [[String: Any]] else { return }
        picks = arr.compactMap { dict in
            guard let id = dict["id"] as? String,
                  let name = dict["perfumeName"] as? String,
                  let brand = dict["perfumeBrand"] as? String,
                  let count = dict["addCount"] as? Int,
                  let users = dict["uniqueUsers"] as? Int,
                  let rank = dict["rank"] as? Int else { return nil }
            return CommunityPick(
                id: id,
                perfumeName: name,
                perfumeBrand: brand,
                imageURL: dict["imageURL"] as? String,
                addCount: count,
                uniqueUsers: users,
                rank: rank
            )
        }
    }
}
