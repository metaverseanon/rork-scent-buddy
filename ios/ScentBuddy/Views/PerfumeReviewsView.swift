import SwiftUI

struct PerfumeReviewsView: View {
    let perfumeName: String
    let perfumeBrand: String
    @State private var reviews: [PerfumeReview] = []
    @State private var profileCache: [String: SupabaseProfile] = [:]
    @State private var likedReviewIds: Set<String> = []
    @State private var likeCounts: [String: Int] = [:]
    @State private var isLoading: Bool = true
    @State private var showingWriteReview: Bool = false

    private var theme: AppTheme { AppearanceManager.shared.theme }
    private let supabase = SupabaseService.shared

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                summarySection

                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 200)
                } else if reviews.isEmpty {
                    ContentUnavailableView {
                        Label("No Reviews", systemImage: "text.bubble")
                    } description: {
                        Text("Be the first to review this fragrance.")
                    }
                    .frame(maxWidth: .infinity, minHeight: 200)
                } else {
                    ForEach(reviews) { review in
                        let profile = profileCache[review.user_id]
                        ReviewCard(
                            review: review,
                            reviewerName: profile?.display_name ?? "User",
                            reviewerIcon: profile?.avatar_emoji ?? "drop.fill",
                            showPerfumeInfo: false,
                            onLike: { Task { await toggleLike(review) } },
                            isLiked: likedReviewIds.contains(review.id),
                            likeCount: likeCounts[review.id] ?? 0
                        )
                    }
                }
            }
            .padding()
        }
        .background(theme.backgroundColor)
        .navigationTitle("Reviews")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if supabase.currentUserId != nil {
                    Button {
                        showingWriteReview = true
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
            }
        }
        .sheet(isPresented: $showingWriteReview) {
            WriteReviewView(perfumeName: perfumeName, perfumeBrand: perfumeBrand)
        }
        .onChange(of: showingWriteReview) { _, newValue in
            if !newValue {
                Task { await loadReviews() }
            }
        }
        .task { await loadReviews() }
    }

    private var summarySection: some View {
        VStack(spacing: 8) {
            if !reviews.isEmpty {
                let avg = Double(reviews.reduce(0) { $0 + $1.rating }) / Double(reviews.count)
                Text(String(format: "%.1f", avg))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Image(systemName: Double(star) <= avg ? "star.fill" : (Double(star) - 0.5 <= avg ? "star.leadinghalf.filled" : "star"))
                            .font(.body)
                            .foregroundStyle(.orange)
                    }
                }
                Text("\(reviews.count) review\(reviews.count == 1 ? "" : "s")")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
    }

    private func loadReviews() async {
        isLoading = true
        defer { isLoading = false }

        reviews = (try? await supabase.fetchReviews(perfumeName: perfumeName, perfumeBrand: perfumeBrand)) ?? []

        let userIds = Set(reviews.map { $0.user_id })
        for userId in userIds {
            if profileCache[userId] == nil {
                profileCache[userId] = try? await supabase.fetchProfile(userId: userId)
            }
        }

        let reviewIds = reviews.map { $0.id }
        let allLikes = (try? await supabase.fetchReviewLikes(reviewIds: reviewIds)) ?? []

        var counts: [String: Int] = [:]
        for like in allLikes {
            counts[like.review_id, default: 0] += 1
        }
        likeCounts = counts

        if let currentUserId = supabase.currentUserId {
            likedReviewIds = Set(allLikes.filter { $0.user_id == currentUserId }.map { $0.review_id })
        }
    }

    private func toggleLike(_ review: PerfumeReview) async {
        guard let userId = supabase.currentUserId else { return }
        let wasLiked = likedReviewIds.contains(review.id)

        if wasLiked {
            likedReviewIds.remove(review.id)
            likeCounts[review.id] = max(0, (likeCounts[review.id] ?? 1) - 1)
        } else {
            likedReviewIds.insert(review.id)
            likeCounts[review.id] = (likeCounts[review.id] ?? 0) + 1
        }

        do {
            try await supabase.toggleReviewLike(userId: userId, reviewId: review.id, isLiked: wasLiked)
        } catch {
            if wasLiked {
                likedReviewIds.insert(review.id)
                likeCounts[review.id] = (likeCounts[review.id] ?? 0) + 1
            } else {
                likedReviewIds.remove(review.id)
                likeCounts[review.id] = max(0, (likeCounts[review.id] ?? 1) - 1)
            }
        }
    }
}
