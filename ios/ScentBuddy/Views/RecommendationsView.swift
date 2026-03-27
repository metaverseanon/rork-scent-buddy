import SwiftUI
import SwiftData

struct RecommendationsView: View {
    @Query private var perfumes: [Perfume]
    @Query private var wearEntries: [WearEntry]
    @State private var recommendations: [RecommendedPerfume] = []
    @State private var isLoading: Bool = true

    @State private var service = RecommendationService()

    var body: some View {
        ScrollView {
            if isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                    Text("Finding fragrances for you...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
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
        let allRecs = await service.generateRecommendations(from: perfumes, wearEntries: wearEntries)
        recommendations = allRecs.filter { rec in
            !perfumes.contains { perfume in
                let recName = rec.name.lowercased().trimmingCharacters(in: .whitespaces)
                let recBrand = rec.brand.lowercased().trimmingCharacters(in: .whitespaces)
                let pName = perfume.name.lowercased().trimmingCharacters(in: .whitespaces)
                let pBrand = perfume.brand.lowercased().trimmingCharacters(in: .whitespaces)
                return pName == recName
                    || (pName.contains(recName) || recName.contains(pName))
                    && (pBrand == recBrand || pBrand.contains(recBrand) || recBrand.contains(pBrand))
            }
        }
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
                PerfumeThumb(url: recommendation.imageURL, size: 64)

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
                .sensoryFeedback(.selection, trigger: isExpanded)

                Spacer()

                if isInWishlist || justAdded {
                    Label("In Wishlist", systemImage: "heart.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.pink)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Button {
                        addToWishlist()
                    } label: {
                        Label("Wishlist", systemImage: "heart")
                            .font(.caption.bold())
                            .foregroundStyle(.pink)
                    }
                    .sensoryFeedback(.success, trigger: justAdded)
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
}
