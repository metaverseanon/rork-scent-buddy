import SwiftUI
import SwiftData
import UserNotifications
import UIKit


@main
struct ScentBuddyApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate

    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithDefaultBackground()
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Perfume.self,
            WishlistPerfume.self,
            WearEntry.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            let fileManager = FileManager.default
            if let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first {
                let contents = (try? fileManager.contentsOfDirectory(at: appSupport, includingPropertiesForKeys: nil)) ?? []
                for file in contents where file.lastPathComponent.contains("store") {
                    try? fileManager.removeItem(at: file)
                }
            }
            do {
                return try ModelContainer(for: schema, configurations: [modelConfiguration])
            } catch {
                let inMemory = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                return try! ModelContainer(for: schema, configurations: [inMemory])
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onOpenURL { url in
                    if url.scheme == "scentbuddy" && url.host == "perfume" {
                        handlePerfumeDeepLink(url)
                    } else if url.scheme == "scentbuddy" && url.host == "profile" {
                        handleProfileDeepLink(url)
                    } else {
                        Task {
                            let handled = await SupabaseService.shared.handleMagicLinkURL(url)
                            if handled {
                                await UserProfileManager.shared.refreshProfile()
                            }
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
    }

    private func handlePerfumeDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        let params = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })
        if let name = params["name"], let brand = params["brand"] {
            NotificationCenter.default.post(
                name: .navigateToTab,
                object: nil,
                userInfo: ["tab": AppTab.collection]
            )
            NotificationCenter.default.post(
                name: .deepLinkPerfume,
                object: nil,
                userInfo: ["name": name, "brand": brand]
            )
        }
    }

    private func handleProfileDeepLink(_ url: URL) {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return }
        let params = Dictionary(uniqueKeysWithValues: (components.queryItems ?? []).compactMap { item in
            item.value.map { (item.name, $0) }
        })
        if params["id"] != nil {
            NotificationCenter.default.post(
                name: .navigateToTab,
                object: nil,
                userInfo: ["tab": AppTab.home]
            )
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        let notifService = NotificationService.shared
        if notifService.dailyReminderEnabled {
            notifService.scheduleDailyReminder()
        }
        if notifService.weeklyPicksEnabled {
            notifService.scheduleWeeklySmartPicks()
        }
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
        return true
    }

    nonisolated func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("[AppDelegate] APNs Device Token: \(token)")
        Task { @MainActor in
            await SupabaseService.shared.saveDeviceToken(token)
        }
    }

    nonisolated func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("[AppDelegate] Failed to register for push: \(error)")
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }

    nonisolated func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        let notificationId = response.notification.request.identifier

        Task { @MainActor in
            if categoryIdentifier == "WEAR_REMINDER" {
                NotificationCenter.default.post(name: .navigateToTab, object: nil, userInfo: ["tab": AppTab.diary])
            } else if categoryIdentifier == "WEEKLY_PICKS" {
                NotificationCenter.default.post(name: .navigateToTab, object: nil, userInfo: ["tab": AppTab.home])
            } else if notificationId.hasPrefix("social_") || categoryIdentifier == "SOCIAL_NOTIFICATION" {
                NotificationCenter.default.post(name: .showNotifications, object: nil)
            }
        }

        completionHandler()
    }
}
