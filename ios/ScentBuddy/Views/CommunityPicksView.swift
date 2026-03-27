import SwiftUI

struct CommunityPicksView: View {
    @State private var service = CommunityPicksService()
    @State private var appearAnimated: Bool = false
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                headerSection

                if service.isLoading && service.picks.isEmpty {
                    loadingView
                } else if service.picks.isEmpty {
                    emptyView
                } else {
                    if service.picks.count >= 3 {
                        podiumSection
                    }

                    fullListSection
                }
            }
            .padding(.bottom, 24)
        }
        .background(theme.backgroundColor)
        .navigationTitle("Community Picks")
        .navigationBarTitleDisplayMode(.large)
        .refreshable {
            await service.fetchCommunityPicks(forceRefresh: true)
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if service.isLoading && !service.picks.isEmpty {
                    ProgressView()
                }
            }
        }
        .task {
            await service.fetchCommunityPicks()
            withAnimation(.spring(duration: 0.6, bounce: 0.2)) {
                appearAnimated = true
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: "chart.bar.fill")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(.orange.gradient)
                    .clipShape(Circle())
                Text("TRENDING THIS WEEK")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                    .tracking(1)
            }

            Text("What the community is adding to their collections right now")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let lastFetched = service.lastFetched {
                Text("Updated \(lastFetched, style: .relative) ago")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 12)
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Crunching the numbers...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "person.3.fill")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
                .symbolEffect(.pulse, options: .repeating.speed(0.5))
            Text("No Community Data Yet")
                .font(.headline)
            Text("As people add fragrances to their collections, the most popular picks will show up here.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button("Refresh") {
                Task { await service.fetchCommunityPicks(forceRefresh: true) }
            }
            .buttonStyle(.borderedProminent)
            .tint(.orange)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 60)
    }

    private var podiumSection: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 8) {
                if service.picks.count > 1 {
                    podiumSlot(pick: service.picks[1], height: 100, medal: "🥈", delay: 0.15)
                }
                podiumSlot(pick: service.picks[0], height: 130, medal: "🥇", delay: 0.0)
                if service.picks.count > 2 {
                    podiumSlot(pick: service.picks[2], height: 80, medal: "🥉", delay: 0.3)
                }
            }
            .padding(.horizontal)
        }
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 20)
    }

    private func podiumSlot(pick: CommunityPick, height: CGFloat, medal: String, delay: Double) -> some View {
        VStack(spacing: 8) {
            Text(medal)
                .font(.title)

            Color(.secondarySystemBackground)
                .frame(width: 64, height: 64)
                .overlay {
                    if let urlStr = pick.imageURL, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                podiumGradient(for: pick)
                            }
                        }
                        .allowsHitTesting(false)
                    } else {
                        podiumGradient(for: pick)
                    }
                }
                .clipShape(.rect(cornerRadius: 14))

            Text(pick.perfumeName)
                .font(.caption.bold())
                .lineLimit(2)
                .multilineTextAlignment(.center)
            Text(pick.perfumeBrand)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            HStack(spacing: 3) {
                Image(systemName: "person.2.fill")
                    .font(.system(size: 8))
                Text("\(pick.addCount)")
                    .font(.caption2.bold())
            }
            .foregroundStyle(.orange)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(.orange.opacity(0.12))
            .clipShape(Capsule())
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .padding(.horizontal, 4)
        .frame(minHeight: height, alignment: .bottom)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private func podiumGradient(for pick: CommunityPick) -> some View {
        let hash = abs(pick.perfumeName.hashValue)
        let gradients: [[Color]] = [
            [.purple.opacity(0.7), .indigo.opacity(0.5)],
            [.pink.opacity(0.6), .orange.opacity(0.4)],
            [.blue.opacity(0.6), .teal.opacity(0.4)],
            [.orange.opacity(0.7), .red.opacity(0.4)],
        ]
        let colors = gradients[hash % gradients.count]
        return Rectangle()
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Image(systemName: "drop.fill")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.3))
            }
    }

    private var fullListSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Full Rankings")
                    .font(.headline)
                Spacer()
                Text("\(service.picks.count) fragrances")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)

            LazyVStack(spacing: 10) {
                ForEach(service.picks) { pick in
                    CommunityPickRow(pick: pick)
                }
            }
            .padding(.horizontal)
        }
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 16)
    }
}

struct CommunityPickRow: View {
    let pick: CommunityPick
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        HStack(spacing: 14) {
            rankBadge

            Color(.secondarySystemBackground)
                .frame(width: 52, height: 52)
                .overlay {
                    if let urlStr = pick.imageURL, let url = URL(string: urlStr) {
                        AsyncImage(url: url) { phase in
                            if let image = phase.image {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                            } else {
                                fallbackGradient
                            }
                        }
                        .allowsHitTesting(false)
                    } else {
                        fallbackGradient
                    }
                }
                .clipShape(.rect(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(pick.perfumeName)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(pick.perfumeBrand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 3) {
                HStack(spacing: 3) {
                    Image(systemName: "plus.circle.fill")
                        .font(.caption2)
                    Text("\(pick.addCount)")
                        .font(.subheadline.bold())
                }
                .foregroundStyle(.orange)

                Text("\(pick.uniqueUsers) \(pick.uniqueUsers == 1 ? "person" : "people")")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(12)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var rankBadge: some View {
        ZStack {
            if pick.rank <= 3 {
                Circle()
                    .fill(rankColor.gradient)
                    .frame(width: 30, height: 30)
                Text("\(pick.rank)")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            } else {
                Circle()
                    .fill(theme.chipColor)
                    .frame(width: 30, height: 30)
                Text("\(pick.rank)")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
    }

    private var rankColor: Color {
        switch pick.rank {
        case 1: return .orange
        case 2: return .gray
        case 3: return Color(red: 0.72, green: 0.45, blue: 0.2)
        default: return .secondary
        }
    }

    private var fallbackGradient: some View {
        let hash = abs(pick.perfumeName.hashValue)
        let gradients: [[Color]] = [
            [.purple.opacity(0.7), .indigo.opacity(0.5)],
            [.pink.opacity(0.6), .orange.opacity(0.4)],
            [.blue.opacity(0.6), .teal.opacity(0.4)],
            [.orange.opacity(0.7), .red.opacity(0.4)],
        ]
        let colors = gradients[hash % gradients.count]
        return Rectangle()
            .fill(LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing))
            .overlay {
                Image(systemName: "drop.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }
    }
}
