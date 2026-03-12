import SwiftUI

struct ContentView: View {
    private var theme: AppTheme { AppearanceManager.shared.theme }

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
        .tint(theme.tintColor)
        .preferredColorScheme(theme.colorScheme)
    }
}
