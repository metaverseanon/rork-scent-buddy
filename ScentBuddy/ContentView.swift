import SwiftUI

struct ContentView: View {
    @State private var appearanceManager = AppearanceManager.shared

    var body: some View {
        TabView {
            Tab("Collection", systemImage: "square.grid.2x2.fill") {
                NavigationStack {
                    CollectionView()
                }
            }

            Tab("Diary", systemImage: "book.fill") {
                NavigationStack {
                    WearDiaryView()
                }
            }

            Tab("Trending", systemImage: "flame.fill") {
                NavigationStack {
                    TrendingView()
                }
            }

            Tab("Wishlist", systemImage: "heart.fill") {
                NavigationStack {
                    WishlistView()
                }
            }

            Tab("Profile", systemImage: "person.fill") {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(appearanceManager.theme.tintColor)
        .preferredColorScheme(appearanceManager.theme.colorScheme)
    }
}
