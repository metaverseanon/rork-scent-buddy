import SwiftUI

struct NotificationsView: View {
    @State private var notificationManager = NotificationManager.shared
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        ScrollView {
            if notificationManager.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if notificationManager.notifications.isEmpty {
                emptyState
            } else {
                LazyVStack(spacing: 1) {
                    ForEach(notificationManager.notifications) { notification in
                        NotificationRow(notification: notification)
                    }
                }
                .clipShape(.rect(cornerRadius: 16))
                .padding(.horizontal)
                .padding(.top, 8)
            }
        }
        .background(theme.backgroundColor)
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await notificationManager.loadNotifications()
            await notificationManager.markAllRead()
        }
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "bell.slash")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No Notifications Yet")
                .font(.title3.bold())
            Text("When someone follows you or gives your fragrances a nose bump, you'll see it here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}

struct NotificationRow: View {
    let notification: AppNotification
    @State private var notificationManager = NotificationManager.shared

    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(iconBackground)
                    .frame(width: 44, height: 44)
                Image(systemName: iconName)
                    .font(.body)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(titleText)
                    .font(.subheadline)
                    .lineLimit(2)
                if let dateStr = notification.created_at {
                    Text(formatRelativeDate(dateStr))
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            if notification.is_read != true {
                Circle()
                    .fill(.blue)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(notification.is_read != true ? theme.cardColor.opacity(0.8) : theme.cardColor.opacity(0.5))
    }

    private var iconName: String {
        switch notification.notification_type {
        case "follow": return "person.fill.badge.plus"
        case "nose_bump": return "nose"
        default: return "bell.fill"
        }
    }

    private var iconBackground: LinearGradient {
        switch notification.notification_type {
        case "follow":
            return LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
        case "nose_bump":
            return LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.blue, .cyan], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private var titleText: AttributedString {
        let name = notificationManager.displayName(for: notification.from_user_id)
        var result: AttributedString

        switch notification.notification_type {
        case "follow":
            var boldName = AttributedString(name)
            boldName.font = .subheadline.bold()
            result = boldName + AttributedString(" started following you")
        case "nose_bump":
            var boldName = AttributedString(name)
            boldName.font = .subheadline.bold()
            let perfume = notification.perfume_name ?? "a fragrance"
            var boldPerfume = AttributedString(perfume)
            boldPerfume.font = .subheadline.bold()
            result = boldName + AttributedString(" gave ") + boldPerfume + AttributedString(" a nose bump 👃")
        default:
            result = AttributedString("New notification")
        }
        return result
    }

    private func formatRelativeDate(_ dateStr: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        guard let date = formatter.date(from: dateStr) else { return "" }
        let rel = RelativeDateTimeFormatter()
        rel.unitsStyle = .abbreviated
        return rel.localizedString(for: date, relativeTo: Date())
    }
}
