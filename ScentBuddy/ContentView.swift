import SwiftUI

struct ContentView: View {
    @State private var onboardingManager = OnboardingManager.shared
    @State private var showSplash: Bool = true
    @State private var notificationManager = NotificationManager.shared
    @Environment(\.scenePhase) private var scenePhase
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        ZStack {
            Group {
                if onboardingManager.hasCompletedOnboarding {
                    mainTabView
                } else {
                    OnboardingView()
                }
            }
            .opacity(showSplash ? 0 : 1)

            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
                    .zIndex(1)
            }
        }
        .task {
            try? await Task.sleep(for: .seconds(2.0))
            withAnimation(.easeOut(duration: 0.5)) {
                showSplash = false
            }
            if SupabaseService.shared.isAuthenticated {
                await UserProfileManager.shared.refreshProfile()
                await notificationManager.ensureNotificationPermission()
                notificationManager.startPolling()
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active && SupabaseService.shared.isAuthenticated {
                notificationManager.startPolling()
            } else if newPhase == .background {
                notificationManager.stopPolling()
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
