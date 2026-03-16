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
                    Task {
                        let handled = await SupabaseService.shared.handleMagicLinkURL(url)
                        if handled {
                            await UserProfileManager.shared.refreshProfile()
                        }
                    }
                }
        }
        .modelContainer(sharedModelContainer)
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
        return true
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
