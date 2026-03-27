import SwiftUI

struct ActivityFeedView: View {
    @State private var socialService = SocialService.shared
    @State private var feedItems: [ActivityFeedItem] = []
    @State private var profileCache: [String: SocialProfile] = [:]
    @State private var isLoading: Bool = true

    private var theme: AppTheme { AppearanceManager.shared.theme }
    private let supabase = SupabaseService.shared

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 300)
            } else if feedItems.isEmpty {
                emptyFeed
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(feedItems) { item in
                        FeedItemCard(item: item, profile: profileCache[item.user_id])
                    }
                }
                .padding(.bottom, 20)
            }
        }
        .task { await loadFeed() }
    }

    private var emptyFeed: some View {
        ContentUnavailableView {
            Label("No Activity Yet", systemImage: "bubble.left.and.bubble.right")
        } description: {
            Text("Follow other fragrance enthusiasts to see their activity here.")
        }
        .frame(maxWidth: .infinity, minHeight: 300)
    }

    private func loadFeed() async {
        isLoading = true
        defer { isLoading = false }

        await supabase.refreshTokenIfNeeded()

        if !socialService.hasLoaded {
            await socialService.loadDiscoveredUsers()
        }

        var userIdsToFetch: [String] = []

        let followingIds = socialService.getFollowingUserIds()
        if !followingIds.isEmpty {
            userIdsToFetch = followingIds
        }

        if let currentId = supabase.currentUserId, !userIdsToFetch.contains(currentId) {
            userIdsToFetch.append(currentId)
        }

        if userIdsToFetch.isEmpty {
            userIdsToFetch = socialService.getAllUserIds()
        }

        for user in socialService.followingUsers {
            profileCache[user.id] = user
        }
        for user in socialService.discoveredUsers {
            profileCache[user.id] = user
        }

        guard !userIdsToFetch.isEmpty else {
            print("[ActivityFeed] No user IDs to fetch feed for")
            return
        }

        print("[ActivityFeed] Fetching feed for \(userIdsToFetch.count) users")

        do {
            feedItems = try await supabase.fetchActivityFeed(userIds: userIdsToFetch)
            print("[ActivityFeed] Got \(feedItems.count) feed items")
        } catch {
            print("[ActivityFeed] Failed to load: \(error)")
            feedItems = []
        }
    }
}

struct FeedItemCard: View {
    let item: ActivityFeedItem
    let profile: SocialProfile?

    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(activityColor.opacity(0.15))
                    .frame(width: 44, height: 44)
                Image(systemName: activityIcon)
                    .font(.body)
                    .foregroundStyle(activityColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    if let profile {
                        Text(profile.displayName)
                            .font(.subheadline.bold())
                    }
                    Text(activityVerb)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let name = item.perfume_name, !name.isEmpty {
                    HStack(spacing: 6) {
                        Text(name)
                            .font(.subheadline.bold())
                        if let brand = item.perfume_brand, !brand.isEmpty {
                            Text("by \(brand)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if let dateStr = item.created_at {
                    Text(formatRelativeDate(dateStr))
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .padding(.top, 2)
                }
            }

            Spacer()
        }
        .padding(14)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var activityIcon: String {
        switch item.activity_type {
        case "added_perfume": return "plus.circle.fill"
        case "added_wishlist": return "heart.circle.fill"
        case "wrote_review": return "text.bubble.fill"
        case "followed_user": return "person.badge.plus"
        case "logged_wear": return "calendar.badge.plus"
        default: return "sparkles"
        }
    }

    private var activityColor: Color {
        switch item.activity_type {
        case "added_perfume": return .purple
        case "added_wishlist": return .pink
        case "wrote_review": return .orange
        case "followed_user": return .blue
        case "logged_wear": return .teal
        default: return .gray
        }
    }

    private var activityVerb: String {
        switch item.activity_type {
        case "added_perfume": return "added to collection"
        case "added_wishlist": return "added to wishlist"
        case "wrote_review": return "reviewed"
        case "followed_user": return "followed someone"
        case "logged_wear": return "wore"
        default: return "did something"
        }
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
