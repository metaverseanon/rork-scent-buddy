import SwiftUI
import SwiftData

struct DashboardView: View {
    @Query(sort: \Perfume.dateAdded, order: .reverse) private var perfumes: [Perfume]
    @Query(sort: \WearEntry.date, order: .reverse) private var wearEntries: [WearEntry]
    @Query private var wishlist: [WishlistPerfume]
    @State private var scentOfTheDay: ScentOfTheDay?
    @State private var appearAnimated: Bool = false
    private let scentService = ScentOfTheDayService()
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                greetingSection
                    .opacity(appearAnimated ? 1 : 0)
                    .offset(y: appearAnimated ? 0 : 12)

                if let scent = scentOfTheDay {
                    scentOfDayCard(scent)
                        .transition(.asymmetric(
                            insertion: .scale(scale: 0.95).combined(with: .opacity),
                            removal: .opacity
                        ))
                        .opacity(appearAnimated ? 1 : 0)
                        .offset(y: appearAnimated ? 0 : 16)
                }

                quickStatsRow
                    .opacity(appearAnimated ? 1 : 0)
                    .offset(y: appearAnimated ? 0 : 20)

                featuresGrid
                    .opacity(appearAnimated ? 1 : 0)
                    .offset(y: appearAnimated ? 0 : 24)

                if !perfumes.isEmpty {
                    recentCollectionSection
                        .opacity(appearAnimated ? 1 : 0)
                        .offset(y: appearAnimated ? 0 : 28)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
            .animation(.spring(duration: 0.7, bounce: 0.15), value: appearAnimated)
        }
        .background(theme.backgroundColor)
        .navigationTitle("ScentBuddy")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("ScentBuddy")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
            }
        }
        .task {
            scentOfTheDay = scentService.suggest(from: perfumes, wearEntries: wearEntries)
            withAnimation(.spring(duration: 0.7, bounce: 0.15)) {
                appearAnimated = true
            }
            WidgetDataService.updateWidgetData(
                collectionCount: perfumes.count,
                wearCount: wearEntries.count,
                wishlistCount: wishlist.count,
                scentOfTheDay: scentOfTheDay?.perfumeName,
                scentOfTheDayBrand: scentOfTheDay?.perfumeBrand
            )
            syncExistingCollectionToCloud()
        }
    }

    private var greetingSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(greetingText)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if !UserProfileManager.shared.profile.displayName.isEmpty {
                    Text(UserProfileManager.shared.profile.displayName)
                        .font(.title2.bold())
                }
            }
            Spacer()
        }
        .padding(.top, 8)
    }

    private var greetingText: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 5..<12: return "Good morning"
        case 12..<17: return "Good afternoon"
        case 17..<21: return "Good evening"
        default: return "Good night"
        }
    }

    private func scentOfDayCard(_ scent: ScentOfTheDay) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "wand.and.stars")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(.orange.gradient)
                    .clipShape(Circle())
                Text("SCENT OF THE DAY")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
                    .tracking(1)
            }

            HStack(spacing: 14) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [.orange.opacity(0.8), .pink.opacity(0.6)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: "drop.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                VStack(alignment: .leading, spacing: 4) {
                    Text(scent.perfumeName)
                        .font(.headline)
                    Text(scent.perfumeBrand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 4) {
                        Image(systemName: scent.icon)
                            .font(.caption2)
                        Text(scent.reason)
                            .font(.caption)
                    }
                    .foregroundStyle(.orange)
                }
                Spacer()
            }
        }
        .padding(16)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 20))
    }

    private var quickStatsRow: some View {
        HStack(spacing: 12) {
            MiniStatCard(value: "\(perfumes.count)", label: "Collection", icon: "drop.fill", color: .purple)
            MiniStatCard(value: "\(wearEntries.count)", label: "Wears", icon: "calendar", color: .teal)
            MiniStatCard(value: "\(wishlist.count)", label: "Wishlist", icon: "heart.fill", color: .pink)
        }
    }

    private var featuresGrid: some View {
        let columns = [
            GridItem(.flexible(), spacing: 12),
            GridItem(.flexible(), spacing: 12),
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            FeatureTile(
                destination: RecommendationsView(),
                icon: "sparkles",
                title: "Smart Picks",
                subtitle: "For you",
                gradient: [.orange, .pink]
            )
            FeatureTile(
                destination: TrendingView(),
                icon: "flame.fill",
                title: "Trending",
                subtitle: "What's hot",
                gradient: [.red, .orange]
            )
            FeatureTile(
                destination: CompareView(),
                icon: "arrow.left.arrow.right",
                title: "Compare",
                subtitle: "Side by side",
                gradient: [.blue, .indigo]
            )
            FeatureTile(
                destination: CollectionStatsView(),
                icon: "chart.bar.fill",
                title: "Stats",
                subtitle: "Your data",
                gradient: [.teal, .green]
            )
            FeatureTile(
                destination: SocialView(),
                icon: "person.2.fill",
                title: "Community",
                subtitle: "Follow others",
                gradient: [.purple, .pink]
            )
            FeatureTile(
                destination: CollectionCardView(),
                icon: "rectangle.portrait.on.rectangle.portrait.angled.fill",
                title: "Share Card",
                subtitle: "Show off",
                gradient: [.indigo, .purple]
            )
        }
    }

    private func syncExistingCollectionToCloud() {
        guard let userId = SupabaseService.shared.currentUserId,
              SupabaseService.shared.isAuthenticated else { return }

        Task {
            let existing = (try? await SupabaseService.shared.fetchUserCollection(userId: userId)) ?? []
            let existingKeys = Set(existing.map { "\($0.perfume_name)|\($0.perfume_brand)" })

            let unsynced = perfumes.filter { p in
                !existingKeys.contains("\(p.name)|\(p.brand)")
            }

            for perfume in unsynced {
                let item = UserCollectionInsert(
                    user_id: userId,
                    perfume_name: perfume.name,
                    perfume_brand: perfume.brand,
                    image_url: nil,
                    concentration: perfume.concentration,
                    top_notes: perfume.topNotes,
                    heart_notes: perfume.heartNotes,
                    base_notes: perfume.baseNotes,
                    season: perfume.season,
                    occasion: perfume.occasion,
                    rating: perfume.rating,
                    personal_notes: perfume.personalNotes,
                    is_favorite: perfume.isFavorite
                )
                try? await SupabaseService.shared.insertCollectionItem(item)
            }

            let existingWish = (try? await SupabaseService.shared.fetchUserWishlist(userId: userId)) ?? []
            let existingWishKeys = Set(existingWish.map { "\($0.perfume_name)|\($0.perfume_brand)" })

            let unsyncedWish = wishlist.filter { w in
                !existingWishKeys.contains("\(w.name)|\(w.brand)")
            }

            for item in unsyncedWish {
                let insert = UserWishlistInsert(
                    user_id: userId,
                    perfume_name: item.name,
                    perfume_brand: item.brand,
                    image_url: nil,
                    concentration: item.concentration,
                    notes: item.notes,
                    estimated_price: item.estimatedPrice,
                    reason: item.reason,
                    priority: item.priority
                )
                try? await SupabaseService.shared.insertWishlistItem(insert)
            }

            if !unsynced.isEmpty || !unsyncedWish.isEmpty {
                print("Cloud sync: pushed \(unsynced.count) perfumes and \(unsyncedWish.count) wishlist items to Supabase")
            }
        }
    }

    private var recentCollectionSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recently Added")
                .font(.headline)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(perfumes.prefix(6)) { perfume in
                        RecentPerfumeCard(perfume: perfume)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
    }
}

struct MiniStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .symbolEffect(.pulse, options: .repeating.speed(0.5))
            Text(value)
                .font(.title3.bold())
                .contentTransition(.numericText())
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct FeatureTile<Destination: View>: View {
    let destination: Destination
    let icon: String
    let title: String
    let subtitle: String
    let gradient: [Color]
    @State private var isPressed: Bool = false

    var body: some View {
        NavigationLink {
            destination
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(
                        LinearGradient(colors: gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                    .clipShape(.rect(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(16)
            .background(AppearanceManager.shared.theme.cardColor)
            .clipShape(.rect(cornerRadius: 16))
            .scaleEffect(isPressed ? 0.96 : 1.0)
            .animation(.spring(duration: 0.25, bounce: 0.4), value: isPressed)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

struct RecentPerfumeCard: View {
    let perfume: Perfume

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            RoundedRectangle(cornerRadius: 12)
                .fill(perfumeGradient)
                .frame(width: 100, height: 80)
                .overlay {
                    Image(systemName: "drop.fill")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.3))
                }

            Text(perfume.name)
                .font(.caption.bold())
                .lineLimit(1)
            Text(perfume.brand)
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .frame(width: 100)

    }

    private var perfumeGradient: LinearGradient {
        let hash = abs(perfume.name.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple.opacity(0.7), .indigo.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink.opacity(0.6), .orange.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue.opacity(0.6), .teal.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange.opacity(0.7), .red.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}
