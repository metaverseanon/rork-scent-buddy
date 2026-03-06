import SwiftUI
import SwiftData

struct CollectionStatsView: View {
    @Query private var perfumes: [Perfume]
    @Query private var wearEntries: [WearEntry]
    @Query private var wishlist: [WishlistPerfume]

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                overviewCards
                if !perfumes.isEmpty {
                    noteBreakdown
                    brandDistribution
                    concentrationBreakdown
                    seasonBreakdown
                    topRated
                    wearInsights
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 20)
        }
        .background(AppearanceManager.shared.theme.backgroundColor)
        .navigationTitle("Stats")
    }

    private var overviewCards: some View {
        VStack(spacing: 12) {
            HStack(spacing: 12) {
                BigStatCard(value: "\(perfumes.count)", label: "Total Fragrances", icon: "drop.fill", color: .purple)
                BigStatCard(value: "\(Set(perfumes.map(\.brand)).count)", label: "Brands", icon: "tag.fill", color: .blue)
            }
            HStack(spacing: 12) {
                BigStatCard(value: "\(perfumes.filter(\.isFavorite).count)", label: "Favorites", icon: "heart.fill", color: .pink)
                BigStatCard(value: "\(wearEntries.count)", label: "Total Wears", icon: "calendar.badge.clock", color: .orange)
            }
            HStack(spacing: 12) {
                BigStatCard(value: "\(wishlist.count)", label: "Wishlist", icon: "heart.text.clipboard", color: .teal)
                BigStatCard(value: averageRatingText, label: "Avg Rating", icon: "star.fill", color: .yellow)
            }
        }
        .padding(.top, 8)
    }

    private var noteBreakdown: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "leaf.fill")
                    .foregroundStyle(.green)
                Text("Top Notes in Collection")
                    .font(.headline)
            }

            let topNotes = mostCommonNotes(limit: 8)
            let maxCount = topNotes.first?.count ?? 1

            ForEach(topNotes, id: \.note) { item in
                HStack(spacing: 12) {
                    Text(item.note)
                        .font(.subheadline)
                        .frame(width: 90, alignment: .leading)

                    GeometryReader { geo in
                        let width = geo.size.width * CGFloat(item.count) / CGFloat(maxCount)
                        RoundedRectangle(cornerRadius: 4)
                            .fill(.green.gradient)
                            .frame(width: max(width, 4), height: 20)
                    }
                    .frame(height: 20)

                    Text("\(item.count)")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)
                        .frame(width: 30, alignment: .trailing)
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var brandDistribution: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "building.2.fill")
                    .foregroundStyle(.indigo)
                Text("Top Brands")
                    .font(.headline)
            }

            let brands = topBrands(limit: 6)
            ForEach(brands, id: \.brand) { item in
                HStack {
                    Text(item.brand)
                        .font(.subheadline)
                    Spacer()
                    Text("\(item.count) fragrance\(item.count == 1 ? "" : "s")")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    CircleProgress(value: Double(item.count) / Double(perfumes.count))
                        .frame(width: 28, height: 28)
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var concentrationBreakdown: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "flask.fill")
                    .foregroundStyle(.purple)
                Text("Concentration Mix")
                    .font(.headline)
            }

            let concentrations = concentrationCounts
            let total = max(perfumes.count, 1)

            ForEach(concentrations, id: \.name) { item in
                HStack(spacing: 12) {
                    Text(item.name)
                        .font(.subheadline)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Spacer()

                    Text("\(Int(Double(item.count) / Double(total) * 100))%")
                        .font(.caption.bold())
                        .foregroundStyle(.purple)
                        .frame(width: 36, alignment: .trailing)

                    RoundedRectangle(cornerRadius: 3)
                        .fill(.purple.opacity(0.2))
                        .frame(width: 80, height: 16)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 3)
                                .fill(.purple.gradient)
                                .frame(width: 80 * CGFloat(item.count) / CGFloat(total))
                        }
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var seasonBreakdown: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "cloud.sun.fill")
                    .foregroundStyle(.orange)
                Text("Season Preferences")
                    .font(.headline)
            }

            let seasons = seasonCounts
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                ForEach(seasons, id: \.name) { item in
                    HStack(spacing: 8) {
                        Image(systemName: seasonIcon(item.name))
                            .font(.body)
                            .foregroundStyle(seasonColor(item.name))
                            .frame(width: 28)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(item.name)
                                .font(.caption.bold())
                            Text("\(item.count)")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .padding(10)
                    .background(AppearanceManager.shared.theme.chipColor)
                    .clipShape(.rect(cornerRadius: 10))
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var topRated: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "trophy.fill")
                    .foregroundStyle(.yellow)
                Text("Top Rated")
                    .font(.headline)
            }

            let top = perfumes.filter { $0.rating > 0 }.sorted { $0.rating > $1.rating }.prefix(5)
            ForEach(Array(top)) { perfume in
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ratingGradient(perfume.rating))
                        .frame(width: 36, height: 36)
                        .overlay {
                            Text("\(perfume.rating)")
                                .font(.subheadline.bold())
                                .foregroundStyle(.white)
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(perfume.name)
                            .font(.subheadline.bold())
                            .lineLimit(1)
                        Text(perfume.brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    HStack(spacing: 2) {
                        ForEach(1...5, id: \.self) { star in
                            Image(systemName: star <= perfume.rating ? "star.fill" : "star")
                                .font(.system(size: 10))
                                .foregroundStyle(star <= perfume.rating ? .orange : .gray.opacity(0.3))
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var wearInsights: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(.teal)
                Text("Wear Insights")
                    .font(.headline)
            }

            if wearEntries.isEmpty {
                Text("Start logging wears to see insights here.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .padding(.vertical, 8)
            } else {
                let mostWorn = topWornPerfumes(limit: 5)
                ForEach(mostWorn, id: \.name) { item in
                    HStack {
                        Text(item.name)
                            .font(.subheadline)
                        Spacer()
                        Text("\(item.count) wear\(item.count == 1 ? "" : "s")")
                            .font(.caption.bold())
                            .foregroundStyle(.teal)
                    }
                }

                Divider()

                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Unique Scents Worn")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text("\(Set(wearEntries.map(\.perfumeName)).count)")
                            .font(.title3.bold())
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Avg Wears / Scent")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        let unique = max(Set(wearEntries.map(\.perfumeName)).count, 1)
                        Text(String(format: "%.1f", Double(wearEntries.count) / Double(unique)))
                            .font(.title3.bold())
                    }
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    // MARK: - Data Helpers

    private var averageRatingText: String {
        let rated = perfumes.filter { $0.rating > 0 }
        guard !rated.isEmpty else { return "—" }
        let avg = Double(rated.reduce(0) { $0 + $1.rating }) / Double(rated.count)
        return String(format: "%.1f", avg)
    }

    private struct NoteCount {
        let note: String
        let count: Int
    }

    private func mostCommonNotes(limit: Int) -> [NoteCount] {
        var counts: [String: Int] = [:]
        for perfume in perfumes {
            for note in perfume.allNotes {
                counts[note, default: 0] += 1
            }
        }
        return counts
            .map { NoteCount(note: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0 }
    }

    private struct BrandCount {
        let brand: String
        let count: Int
    }

    private func topBrands(limit: Int) -> [BrandCount] {
        let grouped = Dictionary(grouping: perfumes, by: \.brand)
        return grouped
            .map { BrandCount(brand: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0 }
    }

    private struct NameCount {
        let name: String
        let count: Int
    }

    private var concentrationCounts: [NameCount] {
        let grouped = Dictionary(grouping: perfumes, by: \.concentration)
        return grouped
            .map { NameCount(name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private var seasonCounts: [NameCount] {
        let grouped = Dictionary(grouping: perfumes, by: \.season)
        return grouped
            .map { NameCount(name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }

    private struct WornCount {
        let name: String
        let count: Int
    }

    private func topWornPerfumes(limit: Int) -> [WornCount] {
        let grouped = Dictionary(grouping: wearEntries, by: \.perfumeName)
        return grouped
            .map { WornCount(name: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
            .map { $0 }
    }

    private func seasonIcon(_ season: String) -> String {
        switch season {
        case "Spring": return "leaf.fill"
        case "Summer": return "sun.max.fill"
        case "Fall": return "wind"
        case "Winter": return "snowflake"
        default: return "cloud.sun.fill"
        }
    }

    private func seasonColor(_ season: String) -> Color {
        switch season {
        case "Spring": return .green
        case "Summer": return .orange
        case "Fall": return .brown
        case "Winter": return .blue
        default: return .teal
        }
    }

    private func ratingGradient(_ rating: Int) -> LinearGradient {
        switch rating {
        case 5: return LinearGradient(colors: [.yellow, .orange], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 4: return LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing)
        case 3: return LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
        default: return LinearGradient(colors: [.gray, .gray.opacity(0.6)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

struct BigStatCard: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.12))
                .clipShape(.rect(cornerRadius: 10))

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3.bold())
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }

            Spacer()
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct CircleProgress: View {
    let value: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(.indigo.opacity(0.15), lineWidth: 3)
            Circle()
                .trim(from: 0, to: value)
                .stroke(.indigo, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
    }
}
