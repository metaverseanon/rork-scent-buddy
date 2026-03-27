import UIKit
import SwiftUI

final class ShareService {
    static let shared = ShareService()
    private init() {}

    private let deepLinkScheme = "scentbuddy"
    private let universalLinkBase = "https://scentbuddy.app"

    func deepLink(for perfumeName: String, brand: String) -> URL? {
        let encodedName = perfumeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? perfumeName
        let encodedBrand = brand.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? brand
        return URL(string: "\(deepLinkScheme)://perfume?name=\(encodedName)&brand=\(encodedBrand)")
    }

    func profileDeepLink(userId: String) -> URL? {
        URL(string: "\(deepLinkScheme)://profile?id=\(userId)")
    }

    func sharePerfumeText(name: String, brand: String, rating: Int, notes: [String]) -> String {
        var text = "\(name) by \(brand)"
        if rating > 0 {
            let stars = String(repeating: "⭐", count: rating)
            text += " \(stars)"
        }
        if !notes.isEmpty {
            let topNotes = notes.prefix(4).joined(separator: ", ")
            text += "\nNotes: \(topNotes)"
        }
        text += "\n\nShared via ScentBuddy 🫧"
        return text
    }

    func shareCollectionText(perfumeCount: Int, brandCount: Int, topPerfumes: [(String, String)]) -> String {
        var text = "My Fragrance Collection 🫧\n"
        text += "\(perfumeCount) fragrances from \(brandCount) brands\n"
        if !topPerfumes.isEmpty {
            text += "\nTop picks:\n"
            for (name, brand) in topPerfumes.prefix(3) {
                text += "• \(name) by \(brand)\n"
            }
        }
        text += "\nShared via ScentBuddy"
        return text
    }

    func presentShareSheet(items: [Any], from view: UIView? = nil) {
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        activityVC.excludedActivityTypes = [.assignToContact, .addToReadingList]

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = windowScene.windows.first?.rootViewController {
            if let popover = activityVC.popoverPresentationController {
                popover.sourceView = view ?? rootVC.view
                popover.sourceRect = view?.bounds ?? CGRect(x: rootVC.view.bounds.midX, y: rootVC.view.bounds.midY, width: 0, height: 0)
            }
            rootVC.present(activityVC, animated: true)
        }
    }
}
