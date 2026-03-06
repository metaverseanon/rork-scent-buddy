import SwiftUI

struct ContentView: View {
    @State private var appearanceManager = AppearanceManager.shared

    var body: some View {
        TabView {
            Tab("Collection", systemImage: "square.grid.2x2.fill") {
                CollectionView()
            }

            Tab("Diary", systemImage: "book.fill") {
                WearDiaryView()
            }

            Tab("Scan", systemImage: "camera.viewfinder") {
                PhotoScanView()
            }

            Tab("For You", systemImage: "sparkles") {
                RecommendationsView()
            }

            Tab("Trending", systemImage: "flame.fill") {
                TrendingView()
            }

            Tab("Stats", systemImage: "chart.bar.fill") {
                CollectionStatsView()
            }

            Tab("Compare", systemImage: "arrow.left.arrow.right") {
                CompareView()
            }

            Tab("Wishlist", systemImage: "heart.fill") {
                WishlistView()
            }

            Tab("Profile", systemImage: "person.fill") {
                NavigationStack {
                    ProfileView()
                }
            }

            Tab("Settings", systemImage: "gearshape.fill") {
                SettingsView()
            }
        }
        .tint(appearanceManager.theme.tintColor)
        .preferredColorScheme(appearanceManager.theme.colorScheme)
    }
}
