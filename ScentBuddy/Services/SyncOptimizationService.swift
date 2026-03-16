import Foundation
import SwiftData

@Observable
final class SyncOptimizationService {
    static let shared = SyncOptimizationService()

    private(set) var isSyncing: Bool = false
    private(set) var lastSyncDate: Date?

    private let lastSyncKey = "last_cloud_sync_date"
    private let syncedCollectionKeysKey = "synced_collection_keys"
    private let syncedWishlistKeysKey = "synced_wishlist_keys"

    private init() {
        lastSyncDate = UserDefaults.standard.object(forKey: lastSyncKey) as? Date
    }

    var needsSync: Bool {
        guard let last = lastSyncDate else { return true }
        return Date().timeIntervalSince(last) > 300
    }

    func syncIfNeeded(perfumes: [Perfume], wishlist: [WishlistPerfume]) {
        guard needsSync else { return }
        guard !isSyncing else { return }
        guard SupabaseService.shared.isAuthenticated,
              let userId = SupabaseService.shared.currentUserId else { return }

        let perfumeData = perfumes.map { extractPerfumeData($0, userId: userId) }
        let wishlistData = wishlist.map { extractWishlistData($0, userId: userId) }

        Task { await performSync(userId: userId, perfumeInserts: perfumeData, wishlistInserts: wishlistData) }
    }

    func forceSync(perfumes: [Perfume], wishlist: [WishlistPerfume]) {
        guard !isSyncing else { return }
        guard SupabaseService.shared.isAuthenticated,
              let userId = SupabaseService.shared.currentUserId else { return }

        let perfumeData = perfumes.map { extractPerfumeData($0, userId: userId) }
        let wishlistData = wishlist.map { extractWishlistData($0, userId: userId) }

        Task { await performSync(userId: userId, perfumeInserts: perfumeData, wishlistInserts: wishlistData) }
    }

    private func extractPerfumeData(_ perfume: Perfume, userId: String) -> SyncPerfumeData {
        SyncPerfumeData(
            key: "\(perfume.name)|\(perfume.brand)",
            insert: UserCollectionInsert(
                user_id: userId,
                perfume_name: perfume.name,
                perfume_brand: perfume.brand,
                image_url: perfume.imageURL,
                concentration: perfume.concentration,
                top_notes: perfume.topNotes,
                heart_notes: perfume.heartNotes,
                base_notes: perfume.baseNotes,
                season: perfume.season,
                occasion: perfume.occasion,
                rating: perfume.rating,
                personal_notes: perfume.personalNotes,
                is_favorite: perfume.isFavorite
            )
        )
    }

    private func extractWishlistData(_ item: WishlistPerfume, userId: String) -> SyncWishlistData {
        SyncWishlistData(
            key: "\(item.name)|\(item.brand)",
            insert: UserWishlistInsert(
                user_id: userId,
                perfume_name: item.name,
                perfume_brand: item.brand,
                image_url: item.imageURL,
                concentration: item.concentration,
                notes: item.notes,
                estimated_price: item.estimatedPrice,
                reason: item.reason,
                priority: item.priority
            )
        )
    }

    private func performSync(userId: String, perfumeInserts: [SyncPerfumeData], wishlistInserts: [SyncWishlistData]) async {
        isSyncing = true
        defer {
            isSyncing = false
            lastSyncDate = Date()
            UserDefaults.standard.set(lastSyncDate, forKey: lastSyncKey)
        }

        let syncedCollectionKeys = Set(UserDefaults.standard.stringArray(forKey: syncedCollectionKeysKey) ?? [])
        let syncedWishlistKeys = Set(UserDefaults.standard.stringArray(forKey: syncedWishlistKeysKey) ?? [])

        var newCollectionKeys = syncedCollectionKeys
        var newWishlistKeys = syncedWishlistKeys

        let unsyncedPerfumes = perfumeInserts.filter { !syncedCollectionKeys.contains($0.key) }
        let unsyncedWishlist = wishlistInserts.filter { !syncedWishlistKeys.contains($0.key) }

        if unsyncedPerfumes.isEmpty && unsyncedWishlist.isEmpty {
            let existingRemote = (try? await SupabaseService.shared.fetchUserCollection(userId: userId)) ?? []
            let existingKeys = Set(existingRemote.map { "\($0.perfume_name)|\($0.perfume_brand)" })
            let trulyUnsynced = perfumeInserts.filter { !existingKeys.contains($0.key) }
            for data in trulyUnsynced {
                try? await SupabaseService.shared.insertCollectionItem(data.insert)
                newCollectionKeys.insert(data.key)
            }
            UserDefaults.standard.set(Array(newCollectionKeys), forKey: syncedCollectionKeysKey)
            return
        }

        for data in unsyncedPerfumes {
            try? await SupabaseService.shared.insertCollectionItem(data.insert)
            newCollectionKeys.insert(data.key)
        }

        for data in unsyncedWishlist {
            try? await SupabaseService.shared.insertWishlistItem(data.insert)
            newWishlistKeys.insert(data.key)
        }

        UserDefaults.standard.set(Array(newCollectionKeys), forKey: syncedCollectionKeysKey)
        UserDefaults.standard.set(Array(newWishlistKeys), forKey: syncedWishlistKeysKey)
    }

    func markSynced(perfumeName: String, perfumeBrand: String) {
        var keys = Set(UserDefaults.standard.stringArray(forKey: syncedCollectionKeysKey) ?? [])
        keys.insert("\(perfumeName)|\(perfumeBrand)")
        UserDefaults.standard.set(Array(keys), forKey: syncedCollectionKeysKey)
    }

    func markWishlistSynced(name: String, brand: String) {
        var keys = Set(UserDefaults.standard.stringArray(forKey: syncedWishlistKeysKey) ?? [])
        keys.insert("\(name)|\(brand)")
        UserDefaults.standard.set(Array(keys), forKey: syncedWishlistKeysKey)
    }

    func resetSyncState() {
        UserDefaults.standard.removeObject(forKey: lastSyncKey)
        UserDefaults.standard.removeObject(forKey: syncedCollectionKeysKey)
        UserDefaults.standard.removeObject(forKey: syncedWishlistKeysKey)
        lastSyncDate = nil
    }
}

nonisolated struct SyncPerfumeData: Sendable {
    let key: String
    let insert: UserCollectionInsert
}

nonisolated struct SyncWishlistData: Sendable {
    let key: String
    let insert: UserWishlistInsert
}
