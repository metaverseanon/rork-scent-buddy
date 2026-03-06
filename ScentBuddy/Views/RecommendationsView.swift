import SwiftUI
import SwiftData

struct RecommendationsView: View {
    @Query private var perfumes: [Perfume]
    @Query private var wearEntries: [WearEntry]
    @State private var recommendations: [RecommendedPerfume] = []
    @State private var isLoading: Bool = true

    private let service = RecommendationService()

    var body: some View {
        NavigationStack {
            ScrollView {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, minHeight: 300)
                } else if recommendations.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 20) {
                        headerCard
                        recommendationsList
                    }
                    .padding(.horizontal)
                }
            }
            .background(AppearanceManager.shared.theme.backgroundColor)
            .navigationTitle("For You")
            .refreshable {
                await loadRecommendations()
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await loadRecommendations() }
                    } label: {
                        Image(systemName: "arrow.trianglehead.2.clockwise")
                    }
                }
            }
            .task(id: perfumes.count) {
                await loadRecommendations()
            }
        }
    }

    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "sparkles")
                    .font(.title2)
                    .foregroundStyle(.orange)
                Text("Smart Picks")
                    .font(.title3.bold())
            }
            Text("Based on your collection of \(perfumes.count) fragrance\(perfumes.count == 1 ? "" : "s") and the notes you love.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(colors: [.orange.opacity(0.15), .pink.opacity(0.08)], startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .clipShape(.rect(cornerRadius: 16))
        .padding(.top, 8)
    }

    private var recommendationsList: some View {
        LazyVStack(spacing: 12) {
            ForEach(recommendations) { rec in
                RecommendationCard(recommendation: rec)
            }
        }
        .padding(.bottom, 20)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Recommendations", systemImage: "sparkles")
        } description: {
            Text("Add perfumes to your collection and we'll suggest fragrances you might love.")
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    private func loadRecommendations() async {
        isLoading = true
        try? await Task.sleep(for: .milliseconds(500))
        recommendations = service.generateRecommendations(from: perfumes, wearEntries: wearEntries)
        isLoading = false
    }
}

struct RecommendationCard: View {
    let recommendation: RecommendedPerfume
    @Environment(\.modelContext) private var modelContext
    @Query private var wishlist: [WishlistPerfume]
    @State private var isExpanded: Bool = false
    @State private var justAdded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(cardGradient)
                    .frame(width: 60, height: 60)
                    .overlay {
                        Image(systemName: "drop.fill")
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.5))
                    }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(recommendation.name)
                            .font(.headline)
                        Spacer()
                        Text("\(recommendation.matchPercentage)%")
                            .font(.subheadline.bold())
                            .foregroundStyle(.orange)
                    }

                    Text(recommendation.brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(recommendation.matchReason)
                        .font(.caption)
                        .foregroundStyle(.tint)
                }
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(recommendation.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 4) {
                        Image(systemName: "flask")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(recommendation.concentration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    FlowLayout(spacing: 6) {
                        ForEach(recommendation.notes, id: \.self) { note in
                            Text(note)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.tint.opacity(0.1))
                                .foregroundStyle(.tint)
                                .clipShape(Capsule())
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            HStack {
                Button {
                    withAnimation(.snappy) { isExpanded.toggle() }
                } label: {
                    HStack {
                        Text(isExpanded ? "Show Less" : "Show More")
                            .font(.caption.bold())
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .font(.caption2)
                    }
                    .foregroundStyle(.tint)
                }

                Spacer()

                if isInWishlist || justAdded {
                    Label("In Wishlist", systemImage: "heart.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.pink)
                } else {
                    Button {
                        addToWishlist()
                    } label: {
                        Label("Wishlist", systemImage: "heart")
                            .font(.caption.bold())
                            .foregroundStyle(.pink)
                    }
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var isInWishlist: Bool {
        wishlist.contains { $0.name == recommendation.name && $0.brand == recommendation.brand }
    }

    private func addToWishlist() {
        let item = WishlistPerfume(
            name: recommendation.name,
            brand: recommendation.brand,
            concentration: recommendation.concentration,
            notes: recommendation.notes,
            reason: recommendation.matchReason
        )
        modelContext.insert(item)
        withAnimation(.snappy) { justAdded = true }
    }

    private var cardGradient: LinearGradient {
        let hash = abs(recommendation.name.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}
