import Foundation
import WidgetKit

struct WidgetDataService {
    private static let suiteName = "group.app.rork.scent-buddy"

    static func updateWidgetData(
        collectionCount: Int,
        wearCount: Int,
        wishlistCount: Int,
        scentOfTheDay: String?,
        scentOfTheDayBrand: String?
    ) {
        guard let shared = UserDefaults(suiteName: suiteName) else { return }
        shared.set(collectionCount, forKey: "widget_collection_count")
        shared.set(wearCount, forKey: "widget_wear_count")
        shared.set(wishlistCount, forKey: "widget_wishlist_count")
        if let name = scentOfTheDay {
            shared.set(name, forKey: "widget_scent_name")
        }
        if let brand = scentOfTheDayBrand {
            shared.set(brand, forKey: "widget_scent_brand")
        }
        shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
        WidgetCenter.shared.reloadAllTimelines()
    }
}
