import SwiftUI
import SwiftData

struct CollectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Perfume.dateAdded, order: .reverse) private var perfumes: [Perfume]
    @State private var viewModel = CollectionViewModel()
    private let theme = AppearanceManager.shared.theme

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            if perfumes.isEmpty {
                emptyState
            } else {
                VStack(spacing: 20) {
                    actionBar
                    statsBar
                    filterBar
                    perfumeGrid
                }
                .padding(.horizontal)
            }
        }
        .background(AppearanceManager.shared.theme.backgroundColor)
        .navigationTitle("My Collection")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("My Collection")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
            }
        }
        .searchable(text: $viewModel.searchText, prompt: "Search perfumes...")
        .sheet(isPresented: $viewModel.showingAddPerfume) {
            AddPerfumeView()
        }
        .navigationDestination(for: Perfume.self) { perfume in
            PerfumeDetailView(perfume: perfume)
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                viewModel.showingAddPerfume = true
            } label: {
                Label("Add Perfume", systemImage: "plus.circle.fill")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(.tint)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }

            Menu {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Button {
                        withAnimation { viewModel.selectedSortOption = option }
                    } label: {
                        Label(option.rawValue, systemImage: option.icon)
                    }
                }
            } label: {
                Label("Sort", systemImage: "arrow.up.arrow.down")
                    .font(.subheadline.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(AppearanceManager.shared.theme.chipColor)
                    .foregroundStyle(.primary)
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(.top, 8)
    }

    private var statsBar: some View {
        HStack(spacing: 12) {
            StatCard(value: "\(perfumes.count)", label: "Perfumes", icon: "drop.fill", color: .purple)
            StatCard(value: "\(Set(perfumes.map(\.brand)).count)", label: "Brands", icon: "tag.fill", color: .orange)
            StatCard(value: "\(perfumes.filter(\.isFavorite).count)", label: "Favorites", icon: "heart.fill", color: .pink)
        }
        .padding(.top, 8)
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(viewModel.filterOptions, id: \.self) { filter in
                    Button {
                        withAnimation(.snappy) { viewModel.selectedFilter = filter }
                    } label: {
                        Text(filter)
                            .font(.subheadline)
                            .fontWeight(viewModel.selectedFilter == filter ? .semibold : .regular)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(
                                viewModel.selectedFilter == filter
                                    ? AnyShapeStyle(.tint)
                                    : AnyShapeStyle(AppearanceManager.shared.theme.chipColor)
                            )
                            .foregroundStyle(viewModel.selectedFilter == filter ? .white : .primary)
                            .clipShape(Capsule())
                    }
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private var perfumeGrid: some View {
        LazyVGrid(columns: columns, spacing: 16) {
            ForEach(viewModel.filteredPerfumes(perfumes)) { perfume in
                NavigationLink(value: perfume) {
                    PerfumeCard(perfume: perfume)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.bottom, 20)
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Perfumes Yet", systemImage: "drop")
        } description: {
            Text("Start building your collection by adding your first fragrance.")
        } actions: {
            Button {
                viewModel.showingAddPerfume = true
            } label: {
                Text("Add Perfume")
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }
}

struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct PerfumeCard: View {
    let perfume: Perfume

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ZStack(alignment: .topTrailing) {
                RoundedRectangle(cornerRadius: 14)
                    .fill(perfumeGradient)
                    .frame(height: 140)
                    .overlay {
                        Image(systemName: "drop.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(.white.opacity(0.3))
                    }

                if perfume.isFavorite {
                    Image(systemName: "heart.fill")
                        .font(.caption)
                        .foregroundStyle(.pink)
                        .padding(6)
                        .background(.ultraThinMaterial)
                        .clipShape(Circle())
                        .padding(8)
                }
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(perfume.name)
                    .font(.subheadline.bold())
                    .lineLimit(1)
                Text(perfume.brand)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .padding(.horizontal, 4)
            .padding(.bottom, 8)
        }
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var perfumeGradient: LinearGradient {
        let hash = abs(perfume.name.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple.opacity(0.7), .indigo.opacity(0.5)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink.opacity(0.6), .orange.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue.opacity(0.6), .teal.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange.opacity(0.7), .red.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.mint.opacity(0.6), .green.opacity(0.4)], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}
