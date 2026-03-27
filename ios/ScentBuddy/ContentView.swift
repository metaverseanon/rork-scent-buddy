import SwiftUI

enum AppTab: Int, Hashable {
    case home = 0
    case collection = 1
    case diary = 2
    case wishlist = 3
    case profile = 4
}

struct ContentView: View {
    @State private var onboardingManager = OnboardingManager.shared
    @State private var showSplash: Bool = true
    @State private var notificationManager = NotificationManager.shared
    @State private var selectedTab: AppTab = .home
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
        .onReceive(NotificationCenter.default.publisher(for: .navigateToTab)) { notification in
            if let tab = notification.userInfo?["tab"] as? AppTab {
                selectedTab = tab
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: .showNotifications)) { _ in
            selectedTab = .home
            notificationManager.shouldShowNotifications = true
        }
    }

    private var mainTabView: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: .home) {
                NavigationStack {
                    DashboardView()
                }
            }
            .badge(notificationManager.unreadCount)

            Tab("Collection", systemImage: "square.grid.2x2.fill", value: .collection) {
                NavigationStack {
                    CollectionView()
                }
            }

            Tab("Diary", systemImage: "book.fill", value: .diary) {
                NavigationStack {
                    WearDiaryView()
                }
            }

            Tab("Wishlist", systemImage: "heart.fill", value: .wishlist) {
                NavigationStack {
                    WishlistView()
                }
            }

            Tab("Profile", systemImage: "person.fill", value: .profile) {
                NavigationStack {
                    ProfileView()
                }
            }
        }
        .tint(theme.tintColor)
        .preferredColorScheme(theme.colorScheme)
        .sensoryFeedback(.selection, trigger: selectedTab)
    }
}

extension Notification.Name {
    static let navigateToTab = Notification.Name("navigateToTab")
    static let showNotifications = Notification.Name("showNotifications")
    static let deepLinkPerfume = Notification.Name("deepLinkPerfume")
}
