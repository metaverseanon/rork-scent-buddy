import SwiftUI

struct SocialView: View {
    @State private var socialService = SocialService.shared
    @State private var selectedTab: SocialTab = .feed
    @State private var searchText: String = ""

    private var theme: AppTheme { AppearanceManager.shared.theme }

    nonisolated private enum SocialTab: String, CaseIterable {
        case feed = "Feed"
        case discover = "Discover"
        case following = "Following"
    }

    var body: some View {
        VStack(spacing: 0) {
            tabPicker
            content
        }
        .background(theme.backgroundColor)
        .navigationTitle("Community")
        .searchable(text: $searchText, prompt: "Search users...")
        .task {
            await socialService.loadDiscoveredUsers()
        }
    }

    private var tabPicker: some View {
        HStack(spacing: 8) {
            ForEach(SocialTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.snappy) { selectedTab = tab }
                } label: {
                    HStack(spacing: 6) {
                        Text(tab.rawValue)
                            .font(.subheadline.bold())
                        if tab == .following {
                            Text("\(socialService.followingCount)")
                                .font(.caption2.bold())
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(selectedTab == tab ? .white.opacity(0.2) : theme.chipColor)
                                .clipShape(Capsule())
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 9)
                    .background(selectedTab == tab ? AnyShapeStyle(.tint) : AnyShapeStyle(theme.chipColor))
                    .foregroundStyle(selectedTab == tab ? .white : .primary)
                    .clipShape(Capsule())
                }
            }
            Spacer()
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
    }

    private var content: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                switch selectedTab {
                case .feed:
                    ActivityFeedView()
                case .discover:
                    if socialService.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity, minHeight: 200)
                    } else {
                        ForEach(filteredDiscoverUsers) { user in
                            NavigationLink(value: user.id) {
                                UserCard(user: user, isFollowing: socialService.isFollowing(user.id)) {
                                    Task {
                                        await socialService.toggleFollow(user.id)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                case .following:
                    if socialService.followingUsers.isEmpty {
                        ContentUnavailableView {
                            Label("No Following", systemImage: "person.2")
                        } description: {
                            Text("Follow fragrance enthusiasts to see their collections and picks.")
                        }
                        .frame(maxWidth: .infinity, minHeight: 300)
                    } else {
                        ForEach(filteredFollowingUsers) { user in
                            NavigationLink(value: user.id) {
                                UserCard(user: user, isFollowing: true) {
                                    Task {
                                        await socialService.toggleFollow(user.id)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .navigationDestination(for: String.self) { userId in
            if let user = socialService.discoveredUsers.first(where: { $0.id == userId }) ??
               socialService.followingUsers.first(where: { $0.id == userId }) {
                UserProfileDetailView(user: user)
            }
        }
    }

    private var filteredDiscoverUsers: [SocialProfile] {
        guard !searchText.isEmpty else { return socialService.discoveredUsers }
        let q = searchText.lowercased()
        return socialService.discoveredUsers.filter {
            $0.displayName.localizedStandardContains(q) ||
            $0.username.localizedStandardContains(q) ||
            $0.favoriteNote.localizedStandardContains(q)
        }
    }

    private var filteredFollowingUsers: [SocialProfile] {
        guard !searchText.isEmpty else { return socialService.followingUsers }
        let q = searchText.lowercased()
        return socialService.followingUsers.filter {
            $0.displayName.localizedStandardContains(q) ||
            $0.username.localizedStandardContains(q)
        }
    }
}

struct UserCard: View {
    let user: SocialProfile
    let isFollowing: Bool
    let onToggleFollow: () -> Void

    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top, spacing: 14) {
                ZStack {
                    Circle()
                        .fill(avatarGradient)
                        .frame(width: 52, height: 52)
                    Text(user.avatarEmoji)
                        .font(.title2)
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(user.displayName)
                            .font(.subheadline.bold())
                        Spacer()
                        Button {
                            onToggleFollow()
                        } label: {
                            Text(isFollowing ? "Following" : "Follow")
                                .font(.caption.bold())
                                .padding(.horizontal, 14)
                                .padding(.vertical, 6)
                                .background(isFollowing ? theme.chipColor : Color.accentColor)
                                .foregroundStyle(isFollowing ? Color.primary : Color.white)
                                .clipShape(Capsule())
                        }
                    }

                    Text("@\(user.username)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if !user.bio.isEmpty {
                        Text(user.bio)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(2)
                            .padding(.top, 2)
                    }
                }
            }

            HStack(spacing: 16) {
                Label("\(user.collectionCount) fragrances", systemImage: "drop.fill")
                if !user.favoriteNote.isEmpty {
                    Label(user.favoriteNote, systemImage: "heart.fill")
                }
                Spacer()
            }
            .font(.caption2)
            .foregroundStyle(.secondary)
            .padding(.top, 10)
        }
        .padding(16)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var avatarGradient: LinearGradient {
        let hash = abs(user.id.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple.opacity(0.3), .indigo.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink.opacity(0.3), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue.opacity(0.3), .teal.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange.opacity(0.3), .red.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}
