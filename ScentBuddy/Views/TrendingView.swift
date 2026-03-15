import SwiftUI

struct TrendingView: View {
    @State private var selectedCategory: TrendingCategory? = nil
    @State private var service = TrendingAPIService()

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if service.isLoading && service.trendingPerfumes.isEmpty {
                    loadingView
                } else if service.trendingPerfumes.isEmpty {
                    emptyView
                } else {
                    categoryFilter
                    trendingContent
                }
            }
            .padding(.bottom, 20)
        }
        .background(AppearanceManager.shared.theme.backgroundColor)
        .navigationTitle("Trending")
        .refreshable {
            await service.fetchTrending(forceRefresh: true)
        }
        .overlay {
            if let error = service.errorMessage, service.trendingPerfumes.isEmpty {
                ContentUnavailableView {
                    Label("Couldn't Load", systemImage: "wifi.slash")
                } description: {
                    Text(error)
                } actions: {
                    Button("Try Again") {
                        Task { await service.fetchTrending(forceRefresh: true) }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
        }
        .task {
            await service.fetchTrending()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if service.isLoading && !service.trendingPerfumes.isEmpty {
                    ProgressView()
                } else if let lastUpdated = service.lastUpdated {
                    Text(lastUpdated, style: .relative)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .controlSize(.large)
            Text("Fetching trending scents...")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 44))
                .foregroundStyle(.secondary)
            Text("No Trending Data")
                .font(.headline)
            Text("Pull down to refresh")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 80)
    }

    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 10) {
                categoryChip(title: "All", category: nil)
                ForEach(TrendingCategory.allCases, id: \.self) { category in
                    categoryChip(title: category.displayName, category: category)
                }
            }
        }
        .contentMargins(.horizontal, 16)
        .padding(.top, 8)
    }

    private func categoryChip(title: String, category: TrendingCategory?) -> some View {
        let isSelected = selectedCategory == category
        return Button {
            withAnimation(.snappy) { selectedCategory = category }
        } label: {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? AnyShapeStyle(.tint) : AnyShapeStyle(AppearanceManager.shared.theme.chipColor))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
        .sensoryFeedback(.selection, trigger: selectedCategory)
    }

    private var filteredPerfumes: [TrendingPerfume] {
        if let category = selectedCategory {
            return service.trendingPerfumes.filter { $0.category == category }
        }
        return service.trendingPerfumes
    }

    private var trendingContent: some View {
        VStack(spacing: 20) {
            if selectedCategory == nil {
                featuredSection
            }

            LazyVStack(spacing: 12) {
                ForEach(filteredPerfumes) { perfume in
                    TrendingCard(perfume: perfume)
                }
            }
            .padding(.horizontal)
        }
    }

    private var featuredSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.red)
                Text("Hot Right Now")
                    .font(.title3.bold())
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 14) {
                    ForEach(service.trendingPerfumes.filter { $0.category == .viral }.prefix(4)) { perfume in
                        FeaturedTrendingCard(perfume: perfume)
                    }
                }
            }
            .contentMargins(.horizontal, 16)
        }
    }
}

struct FeaturedTrendingCard: View {
    let perfume: TrendingPerfume

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack(alignment: .topLeading) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(
                        LinearGradient(
                            colors: [.red.opacity(0.7), .orange.opacity(0.5)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(height: 120)
                    .overlay {
                        VStack(spacing: 4) {
                            Image(systemName: "flame.fill")
                                .font(.system(size: 28))
                                .foregroundStyle(.white.opacity(0.3))
                            if let mentions = perfume.tiktokMentions {
                                Text(mentions)
                                    .font(.caption2.bold())
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                        }
                    }

                Label("Viral", systemImage: "bolt.fill")
                    .font(.caption2.bold())
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(.ultraThinMaterial)
                    .clipShape(Capsule())
                    .padding(10)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(perfume.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(perfume.brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                if let hashtag = perfume.hashtagCount {
                    Text(hashtag)
                        .font(.caption2)
                        .foregroundStyle(.orange)
                        .lineLimit(1)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .frame(width: 200)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }
}

struct TrendingCard: View {
    let perfume: TrendingPerfume
    @State private var isExpanded: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 14) {
                RoundedRectangle(cornerRadius: 12)
                    .fill(categoryGradient)
                    .frame(width: 56, height: 56)
                    .overlay {
                        Image(systemName: categoryIcon)
                            .font(.title3)
                            .foregroundStyle(.white.opacity(0.6))
                    }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(perfume.name)
                            .font(.headline)
                        Spacer()
                        Text(perfume.category.displayName)
                            .font(.caption2.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(categoryColor.opacity(0.15))
                            .foregroundStyle(categoryColor)
                            .clipShape(Capsule())
                    }
                    Text(perfume.brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(perfume.trendReason)
                        .font(.caption)
                        .foregroundStyle(.orange)
                        .lineLimit(isExpanded ? nil : 1)
                }
            }

            if let mentions = perfume.tiktokMentions {
                HStack(spacing: 12) {
                    Label(mentions, systemImage: "person.2.fill")
                    if let source = perfume.socialSource {
                        Text("·")
                        Text(source)
                            .lineLimit(1)
                    }
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    Text(perfume.description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    HStack(spacing: 12) {
                        Label(perfume.concentration, systemImage: "flask")
                        Label("\(perfume.releaseYear)", systemImage: "calendar")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)

                    if let hashtag = perfume.hashtagCount {
                        Label(hashtag, systemImage: "number")
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    FlowLayout(spacing: 6) {
                        ForEach(perfume.notes, id: \.self) { note in
                            Text(note)
                                .font(.caption2)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(categoryColor.opacity(0.1))
                                .foregroundStyle(categoryColor)
                                .clipShape(Capsule())
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

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
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var categoryColor: Color {
        switch perfume.category {
        case .newRelease: return .blue
        case .viral: return .red
        case .classic: return .purple
        case .niche: return .orange
        case .seasonal: return .green
        }
    }

    private var categoryGradient: LinearGradient {
        LinearGradient(
            colors: [categoryColor.opacity(0.7), categoryColor.opacity(0.4)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private var categoryIcon: String {
        switch perfume.category {
        case .newRelease: return "sparkle"
        case .viral: return "flame.fill"
        case .classic: return "crown.fill"
        case .niche: return "diamond.fill"
        case .seasonal: return "leaf.fill"
        }
    }
}
