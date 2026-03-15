import SwiftUI

struct UserProfileDetailView: View {
    let user: SocialProfile
    @State private var socialService = SocialService.shared
    @State private var collection: [UserCollectionItem] = []
    @State private var wishlist: [UserWishlistItem] = []
    @State private var reviews: [PerfumeReview] = []
    @State private var followerCount: Int = 0
    @State private var followingCount: Int = 0
    @State private var totalBumps: Int = 0
    @State private var selectedTab: ProfileTab = .collection
    @State private var isLoading: Bool = true
    @State private var bumpedItems: Set<String> = []
    @State private var bumpCounts: [String: Int] = [:]
    @State private var bumpAnimatingItem: String?

    private var theme: AppTheme { AppearanceManager.shared.theme }
    private let supabase = SupabaseService.shared

    nonisolated private enum ProfileTab: String, CaseIterable {
        case collection = "Collection"
        case wishlist = "Wishlist"
        case reviews = "Reviews"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                statsRow
                tabPicker
                tabContent
            }
        }
        .background(theme.backgroundColor)
        .navigationTitle(user.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadData() }
    }

    private var headerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(avatarGradient)
                    .frame(width: 80, height: 80)
                Image(systemName: user.avatarEmoji)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
            }

            VStack(spacing: 4) {
                Text(user.displayName)
                    .font(.title2.bold())
                Text("@\(user.username)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if !user.bio.isEmpty {
                Text(user.bio)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            HStack(spacing: 12) {
                Button {
                    Task { await socialService.toggleFollow(user.id) }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: socialService.isFollowing(user.id) ? "checkmark" : "plus")
                            .font(.caption.bold())
                        Text(socialService.isFollowing(user.id) ? "Following" : "Follow")
                            .font(.subheadline.bold())
                    }
                    .frame(width: 130)
                    .padding(.vertical, 10)
                    .background(socialService.isFollowing(user.id) ? theme.chipColor : Color.accentColor)
                    .foregroundStyle(socialService.isFollowing(user.id) ? Color.primary : Color.white)
                    .clipShape(Capsule())
                }
                .sensoryFeedback(.impact(weight: .medium), trigger: socialService.isFollowing(user.id))
            }
        }
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity)
    }

    private var statsRow: some View {
        HStack(spacing: 0) {
            statItem(value: "\(collection.count)", label: "Fragrances")
            Divider().frame(height: 32)
            statItem(value: "\(followerCount)", label: "Followers")
            Divider().frame(height: 32)
            statItem(value: "\(followingCount)", label: "Following")
            Divider().frame(height: 32)
            statItem(value: "\(totalBumps)", label: "👃 Bumps", highlight: true)
        }
        .padding(.vertical, 14)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal)
    }

    private func statItem(value: String, label: String, highlight: Bool = false) -> some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.headline)
                .foregroundStyle(highlight ? .orange : .primary)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var tabPicker: some View {
        HStack(spacing: 0) {
            ForEach(ProfileTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.snappy) { selectedTab = tab }
                } label: {
                    VStack(spacing: 8) {
                        Text(tab.rawValue)
                            .font(.subheadline.bold())
                            .foregroundStyle(selectedTab == tab ? .primary : .secondary)
                        Rectangle()
                            .fill(selectedTab == tab ? Color.accentColor : .clear)
                            .frame(height: 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 20)
        .padding(.horizontal)
    }

    @ViewBuilder
    private var tabContent: some View {
        if isLoading {
            ProgressView()
                .frame(maxWidth: .infinity, minHeight: 200)
        } else {
            switch selectedTab {
            case .collection:
                collectionContent
            case .wishlist:
                wishlistContent
            case .reviews:
                reviewsContent
            }
        }
    }

    private var collectionContent: some View {
        LazyVStack(spacing: 12) {
            if collection.isEmpty {
                emptyState(icon: "drop", title: "No Fragrances", subtitle: "This user hasn't added any fragrances yet.")
            } else {
                ForEach(collection) { item in
                    BumpableCollectionCard(
                        item: item,
                        isBumped: bumpedItems.contains(item.id),
                        bumpCount: bumpCounts[item.id] ?? 0,
                        isAnimating: bumpAnimatingItem == item.id
                    ) {
                        Task { await toggleBump(item: item) }
                    }
                }
            }
        }
        .padding()
    }

    private var wishlistContent: some View {
        LazyVStack(spacing: 12) {
            if wishlist.isEmpty {
                emptyState(icon: "heart", title: "Empty Wishlist", subtitle: "This user hasn't added any wishlist items yet.")
            } else {
                ForEach(wishlist) { item in
                    WishlistItemCard(item: item)
                }
            }
        }
        .padding()
    }

    private var reviewsContent: some View {
        LazyVStack(spacing: 12) {
            if reviews.isEmpty {
                emptyState(icon: "text.bubble", title: "No Reviews", subtitle: "This user hasn't written any reviews yet.")
            } else {
                ForEach(reviews) { review in
                    ReviewCard(review: review, reviewerName: user.displayName, reviewerIcon: user.avatarEmoji)
                }
            }
        }
        .padding()
    }

    private func emptyState(icon: String, title: String, subtitle: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(title)
                .font(.headline)
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, minHeight: 200)
    }

    private func toggleBump(item: UserCollectionItem) async {
        guard let currentUserId = supabase.currentUserId, currentUserId != user.id else { return }

        let wasBumped = bumpedItems.contains(item.id)

        withAnimation(.spring(duration: 0.4, bounce: 0.5)) {
            if wasBumped {
                bumpedItems.remove(item.id)
                bumpCounts[item.id] = max(0, (bumpCounts[item.id] ?? 1) - 1)
                totalBumps = max(0, totalBumps - 1)
            } else {
                bumpedItems.insert(item.id)
                bumpCounts[item.id] = (bumpCounts[item.id] ?? 0) + 1
                totalBumps += 1
                bumpAnimatingItem = item.id
            }
        }

        if !wasBumped {
            try? await Task.sleep(for: .seconds(0.6))
            withAnimation { bumpAnimatingItem = nil }
        }

        do {
            if wasBumped {
                try await supabase.removeNoseBump(userId: currentUserId, collectionItemId: item.id)
            } else {
                let bump = NoseBumpInsert(
                    user_id: currentUserId,
                    target_user_id: user.id,
                    collection_item_id: item.id,
                    perfume_name: item.perfume_name,
                    perfume_brand: item.perfume_brand
                )
                try await supabase.sendNoseBump(bump)

                let notification = AppNotificationInsert(
                    user_id: user.id,
                    from_user_id: currentUserId,
                    notification_type: "nose_bump",
                    perfume_name: item.perfume_name,
                    perfume_brand: item.perfume_brand
                )
                try await supabase.insertNotification(notification)
            }
        } catch {
            withAnimation {
                if wasBumped {
                    bumpedItems.insert(item.id)
                    bumpCounts[item.id] = (bumpCounts[item.id] ?? 0) + 1
                    totalBumps += 1
                } else {
                    bumpedItems.remove(item.id)
                    bumpCounts[item.id] = max(0, (bumpCounts[item.id] ?? 1) - 1)
                    totalBumps = max(0, totalBumps - 1)
                }
            }
        }
    }

    private func loadData() async {
        isLoading = true
        defer { isLoading = false }

        async let col = supabase.fetchUserCollection(userId: user.id)
        async let wish = supabase.fetchUserWishlist(userId: user.id)
        async let rev = supabase.fetchUserReviews(userId: user.id)
        async let followers = supabase.fetchFollowers(userId: user.id)
        async let following = supabase.fetchFollowing(userId: user.id)
        async let bumps = supabase.fetchNoseBumpsForUser(targetUserId: user.id)

        collection = (try? await col) ?? []
        wishlist = (try? await wish) ?? []
        reviews = (try? await rev) ?? []
        followerCount = (try? await followers.count) ?? 0
        followingCount = (try? await following.count) ?? 0

        let allBumps = (try? await bumps) ?? []
        totalBumps = allBumps.count

        var counts: [String: Int] = [:]
        for bump in allBumps {
            if let itemId = bump.collection_item_id {
                counts[itemId, default: 0] += 1
            }
        }
        bumpCounts = counts

        if let currentUserId = supabase.currentUserId {
            let myBumps = allBumps.filter { $0.user_id == currentUserId }
            bumpedItems = Set(myBumps.compactMap { $0.collection_item_id })
        }
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

struct BumpableCollectionCard: View {
    let item: UserCollectionItem
    let isBumped: Bool
    let bumpCount: Int
    let isAnimating: Bool
    let onBump: () -> Void

    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(cardGradient)
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "drop.fill")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.4))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.perfume_name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                HStack(spacing: 6) {
                    Text(item.perfume_brand)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                    if bumpCount > 0 {
                        HStack(spacing: 3) {
                            Text("👃")
                                .font(.caption2)
                            Text("\(bumpCount)")
                                .font(.caption2.bold())
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }

            Spacer()

            if let rating = item.rating, rating > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(rating)")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }

            if item.is_favorite == true {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.pink)
            }

            Button {
                onBump()
            } label: {
                Image(systemName: "nose")
                    .font(.title3)
                    .foregroundStyle(isBumped ? .orange : .secondary)
                    .scaleEffect(isAnimating ? 1.4 : 1.0)
                    .rotationEffect(.degrees(isAnimating ? -15 : 0))
                    .animation(.spring(duration: 0.4, bounce: 0.6), value: isAnimating)
            }
            .sensoryFeedback(.impact(weight: .medium, intensity: 0.8), trigger: isBumped) { _, newValue in newValue }
        }
        .padding(14)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var cardGradient: LinearGradient {
        let hash = abs(item.perfume_name.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple.opacity(0.7), .indigo.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink.opacity(0.6), .orange.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue.opacity(0.6), .teal.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange.opacity(0.7), .red.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}

struct CollectionItemCard: View {
    let item: UserCollectionItem
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(cardGradient)
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "drop.fill")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.4))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.perfume_name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(item.perfume_brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }

            Spacer()

            if let rating = item.rating, rating > 0 {
                HStack(spacing: 2) {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text("\(rating)")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }

            if item.is_favorite == true {
                Image(systemName: "heart.fill")
                    .font(.caption)
                    .foregroundStyle(.pink)
            }
        }
        .padding(14)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var cardGradient: LinearGradient {
        let hash = abs(item.perfume_name.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple.opacity(0.7), .indigo.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink.opacity(0.6), .orange.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue.opacity(0.6), .teal.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange.opacity(0.7), .red.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}

struct WishlistItemCard: View {
    let item: UserWishlistItem
    private var theme: AppTheme { AppearanceManager.shared.theme }

    private let priorityLabels = ["Must Have", "Want", "Interested"]

    var body: some View {
        HStack(spacing: 14) {
            RoundedRectangle(cornerRadius: 12)
                .fill(LinearGradient(colors: [.pink.opacity(0.5), .purple.opacity(0.3)], startPoint: .topLeading, endPoint: .bottomTrailing))
                .frame(width: 52, height: 52)
                .overlay {
                    Image(systemName: "heart.fill")
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.4))
                }

            VStack(alignment: .leading, spacing: 4) {
                Text(item.perfume_name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(item.perfume_brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                if let priority = item.priority, priority < priorityLabels.count {
                    Text(priorityLabels[priority])
                        .font(.caption2.bold())
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(.pink.opacity(0.12))
                        .foregroundStyle(.pink)
                        .clipShape(Capsule())
                }
            }

            Spacer()

            if let price = item.estimated_price, !price.isEmpty {
                Text(price)
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)
            }
        }
        .padding(14)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct ReviewCard: View {
    let review: PerfumeReview
    var reviewerName: String = ""
    var reviewerIcon: String = ""
    var showPerfumeInfo: Bool = true
    var onLike: (() -> Void)?
    var isLiked: Bool = false
    var likeCount: Int = 0

    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showPerfumeInfo {
                HStack(spacing: 10) {
                    if !reviewerIcon.isEmpty {
                        Image(systemName: reviewerIcon)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        if !reviewerName.isEmpty {
                            Text(reviewerName)
                                .font(.caption.bold())
                        }
                        Text("\(review.perfume_name) — \(review.perfume_brand)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                    Spacer()
                    if let dateStr = review.created_at {
                        Text(formatRelativeDate(dateStr))
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            HStack(spacing: 4) {
                ForEach(1...5, id: \.self) { star in
                    Image(systemName: star <= review.rating ? "star.fill" : "star")
                        .font(.caption)
                        .foregroundStyle(star <= review.rating ? .orange : .gray.opacity(0.3))
                }
            }

            if let text = review.review_text, !text.isEmpty {
                Text(text)
                    .font(.subheadline)
                    .lineLimit(4)
            }

            HStack(spacing: 16) {
                if let longevity = review.longevity, longevity > 0 {
                    Label("\(longevity)/10", systemImage: "clock")
                }
                if let sillage = review.sillage, sillage > 0 {
                    Label("\(sillage)/10", systemImage: "wind")
                }
                if let value = review.value_for_money, value > 0 {
                    Label("\(value)/10", systemImage: "dollarsign.circle")
                }
            }
            .font(.caption2)
            .foregroundStyle(.secondary)

            if let onLike {
                HStack {
                    Button {
                        onLike()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: isLiked ? "heart.fill" : "heart")
                                .foregroundStyle(isLiked ? .pink : .secondary)
                            if likeCount > 0 {
                                Text("\(likeCount)")
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .font(.caption)
                    }
                    Spacer()
                }
            }
        }
        .padding(16)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
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
