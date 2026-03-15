import SwiftUI

struct SniffLeaderboardView: View {
    @State private var leaderboardEntries: [LeaderboardEntry] = []
    @State private var isLoading: Bool = true

    private var theme: AppTheme { AppearanceManager.shared.theme }
    private let supabase = SupabaseService.shared

    var body: some View {
        Group {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, minHeight: 200)
            } else if leaderboardEntries.isEmpty {
                ContentUnavailableView {
                    Label("No Sniffs Yet", systemImage: "nose")
                } description: {
                    Text("Be the first to sniff a fragrance in someone's collection!")
                }
                .frame(maxWidth: .infinity, minHeight: 300)
            } else {
                VStack(spacing: 12) {
                    if leaderboardEntries.count >= 3 {
                        topThreeSection
                    }

                    ForEach(Array(leaderboardEntries.enumerated()), id: \.element.id) { index, entry in
                        if leaderboardEntries.count >= 3 && index < 3 { EmptyView() } else {
                            leaderboardRow(entry: entry, rank: index + 1)
                        }
                    }
                }
            }
        }
        .task { await loadLeaderboard() }
    }

    private var topThreeSection: some View {
        HStack(alignment: .bottom, spacing: 12) {
            if leaderboardEntries.count > 1 {
                podiumItem(entry: leaderboardEntries[1], rank: 2, height: 100)
            }
            podiumItem(entry: leaderboardEntries[0], rank: 1, height: 130)
            if leaderboardEntries.count > 2 {
                podiumItem(entry: leaderboardEntries[2], rank: 3, height: 80)
            }
        }
        .padding(.top, 16)
        .padding(.bottom, 8)
    }

    private func podiumItem(entry: LeaderboardEntry, rank: Int, height: CGFloat) -> some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(rankGradient(rank: rank))
                    .frame(width: rank == 1 ? 64 : 52, height: rank == 1 ? 64 : 52)
                Image(systemName: entry.avatarEmoji)
                    .font(rank == 1 ? .title2 : .body)
                    .foregroundStyle(.white)
            }
            .overlay(alignment: .bottom) {
                Text(rankMedal(rank: rank))
                    .font(.caption)
                    .offset(y: 10)
            }

            Text(entry.displayName)
                .font(.caption.bold())
                .lineLimit(1)

            Text("\(entry.sniffCount)")
                .font(.title3.bold())
                .foregroundStyle(.orange)
            Text("sniffs")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .frame(height: height)
    }

    private func leaderboardRow(entry: LeaderboardEntry, rank: Int) -> some View {
        HStack(spacing: 14) {
            Text("#\(rank)")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .frame(width: 36)

            ZStack {
                Circle()
                    .fill(avatarGradient(for: entry.userId))
                    .frame(width: 40, height: 40)
                Image(systemName: entry.avatarEmoji)
                    .font(.caption)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(entry.displayName)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text("@\(entry.username)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            HStack(spacing: 4) {
                Text("👃")
                    .font(.caption)
                Text("\(entry.sniffCount)")
                    .font(.subheadline.bold())
                    .foregroundStyle(.orange)
            }
        }
        .padding(14)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private func rankGradient(rank: Int) -> LinearGradient {
        switch rank {
        case 1:
            return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 2:
            return LinearGradient(colors: [Color(white: 0.75), Color(white: 0.55)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 3:
            return LinearGradient(colors: [Color(red: 0.8, green: 0.5, blue: 0.2), Color(red: 0.6, green: 0.35, blue: 0.15)], startPoint: .topLeading, endPoint: .bottomTrailing)
        default:
            return LinearGradient(colors: [.gray.opacity(0.3), .gray.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    private func rankMedal(rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return ""
        }
    }

    private func avatarGradient(for userId: String) -> LinearGradient {
        let hash = abs(userId.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple.opacity(0.3), .indigo.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink.opacity(0.3), .orange.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue.opacity(0.3), .teal.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange.opacity(0.3), .red.opacity(0.2)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }

    private func loadLeaderboard() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let allSniffs = try await supabase.fetchAllSniffs()

            var sniffsByUser: [String: Int] = [:]
            for sniff in allSniffs {
                sniffsByUser[sniff.target_user_id, default: 0] += 1
            }

            let sortedUserIds = sniffsByUser.sorted { $0.value > $1.value }.map { $0.key }
            let profiles = try await supabase.fetchAllProfiles()
            let profileMap = Dictionary(uniqueKeysWithValues: profiles.map { ($0.id, $0) })

            var entries: [LeaderboardEntry] = []
            for userId in sortedUserIds {
                guard let profile = profileMap[userId] else { continue }
                let rawUsername = profile.username ?? ""
                entries.append(LeaderboardEntry(
                    userId: userId,
                    displayName: profile.display_name ?? "User",
                    username: rawUsername.isEmpty ? (profile.display_name ?? "user") : rawUsername,
                    avatarEmoji: profile.avatar_emoji ?? "drop.fill",
                    sniffCount: sniffsByUser[userId] ?? 0
                ))
            }
            leaderboardEntries = entries
        } catch {
            leaderboardEntries = []
        }
    }
}

nonisolated struct LeaderboardEntry: Identifiable, Sendable {
    let userId: String
    let displayName: String
    let username: String
    let avatarEmoji: String
    let sniffCount: Int

    var id: String { userId }
}
