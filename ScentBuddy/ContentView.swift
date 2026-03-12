import SwiftUI

struct ContentView: View {
    @State private var onboardingManager = OnboardingManager.shared
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        Group {
            if onboardingManager.hasCompletedOnboarding {
                mainTabView
            } else {
                OnboardingView()
            }
        }
    }

    private var mainTabView: some View {
        TabView {
            Tab("Home", systemImage: "house.fill") {
                NavigationStack {
                    DashboardView()
                }
            }

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
