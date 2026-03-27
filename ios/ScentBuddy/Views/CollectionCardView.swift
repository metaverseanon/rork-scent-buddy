import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct CollectionCardView: View {
    @Query(sort: \Perfume.dateAdded, order: .reverse) private var perfumes: [Perfume]
    @Query(sort: \WearEntry.date, order: .reverse) private var wearEntries: [WearEntry]
    @Query private var wishlist: [WishlistPerfume]
    @State private var renderedImage: Image?
    @State private var shareImage: UIImage?

    private let profile = UserProfileManager.shared.profile
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                cardPreview
                    .padding(.top, 12)

                if let shareImage, let pngData = shareImage.pngData() {
                    ShareLink(
                        item: ShareableImageItem(pngData: pngData),
                        preview: SharePreview("My ScentBuddy Collection", image: Image(uiImage: shareImage))
                    ) {
                        Label("Share Collection Card", systemImage: "square.and.arrow.up")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.tint)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 14))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.bottom, 30)
        }
        .background(theme.backgroundColor)
        .navigationTitle("Collection Card")
        .task {
            renderCard()
        }
    }

    private var cardPreview: some View {
        ShareCardContent(
            perfumes: perfumes,
            wearEntries: wearEntries,
            wishlistCount: wishlist.count,
            profile: profile
        )
        .padding(.horizontal, 20)
    }

    private func renderCard() {
        let content = ShareCardContent(
            perfumes: perfumes,
            wearEntries: wearEntries,
            wishlistCount: wishlist.count,
            profile: profile
        )
        .frame(width: 360)

        let renderer = ImageRenderer(content: content)
        renderer.scale = 3
        if let uiImage = renderer.uiImage {
            shareImage = uiImage
            renderedImage = Image(uiImage: uiImage)
        }
    }
}

struct ShareCardContent: View {
    let perfumes: [Perfume]
    let wearEntries: [WearEntry]
    let wishlistCount: Int
    let profile: UserProfile

    var body: some View {
        VStack(spacing: 0) {
            headerSection
            statsSection
            if !topPerfumes.isEmpty {
                topPerfumesSection
            }
            if !topNotes.isEmpty {
                topNotesSection
            }
            footerSection
        }
        .background(
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.10, blue: 0.18), Color(red: 0.08, green: 0.06, blue: 0.14)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(.rect(cornerRadius: 24))
        .shadow(color: .black.opacity(0.3), radius: 20, y: 10)
    }

    private var headerSection: some View {
        VStack(spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    if !profile.displayName.isEmpty {
                        Text(profile.displayName)
                            .font(.title2.bold())
                            .foregroundStyle(.white)
                    }
                    if !profile.username.isEmpty {
                        Text("@\(profile.username)")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                Spacer()
                Image(systemName: profile.avatarEmoji)
                    .font(.system(size: 28))
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [.purple.opacity(0.4), .indigo.opacity(0.3)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
    }

    private var statsSection: some View {
        HStack(spacing: 0) {
            cardStat(value: "\(perfumes.count)", label: "Fragrances", icon: "drop.fill")
            divider
            cardStat(value: "\(Set(perfumes.map(\.brand)).count)", label: "Brands", icon: "tag.fill")
            divider
            cardStat(value: "\(wearEntries.count)", label: "Wears", icon: "calendar")
        }
        .padding(.vertical, 16)
        .background(.white.opacity(0.04))
    }

    private var divider: some View {
        Rectangle()
            .fill(.white.opacity(0.08))
            .frame(width: 1, height: 36)
    }

    private func cardStat(value: String, label: String, icon: String) -> some View {
        VStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(.purple.opacity(0.8))
            Text(value)
                .font(.title3.bold())
                .foregroundStyle(.white)
            Text(label)
                .font(.system(size: 9))
                .foregroundStyle(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }

    private var topPerfumesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("TOP FRAGRANCES")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1.5)

            ForEach(Array(topPerfumes.prefix(3).enumerated()), id: \.offset) { index, perfume in
                HStack(spacing: 12) {
                    Text("\(index + 1)")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.4))
                        .frame(width: 16)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(perfumeGradient(for: perfume.name))
                        .frame(width: 32, height: 32)
                        .overlay {
                            Image(systemName: "drop.fill")
                                .font(.system(size: 12))
                                .foregroundStyle(.white.opacity(0.4))
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(perfume.name)
                            .font(.subheadline.bold())
                            .foregroundStyle(.white)
                            .lineLimit(1)
                        Text(perfume.brand)
                            .font(.caption2)
                            .foregroundStyle(.white.opacity(0.5))
                            .lineLimit(1)
                    }

                    Spacer()

                    if perfume.rating > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "star.fill")
                                .font(.system(size: 9))
                                .foregroundStyle(.orange)
                            Text("\(perfume.rating)")
                                .font(.caption2.bold())
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
        }
        .padding(20)
    }

    private var topNotesSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("FAVORITE NOTES")
                .font(.system(size: 10, weight: .bold))
                .foregroundStyle(.white.opacity(0.4))
                .tracking(1.5)

            HStack(spacing: 6) {
                ForEach(topNotes.prefix(5), id: \.self) { note in
                    Text(note)
                        .font(.system(size: 10, weight: .semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(.purple.opacity(0.25))
                        .foregroundStyle(.purple.opacity(0.9))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 16)
    }

    private var footerSection: some View {
        HStack {
            HStack(spacing: 6) {
                Image(systemName: "drop.fill")
                    .font(.caption2)
                    .foregroundStyle(.purple)
                Text("ScentBuddy")
                    .font(.caption.bold())
                    .foregroundStyle(.white.opacity(0.5))
            }
            Spacer()
            Text(Date.now.formatted(.dateTime.month(.abbreviated).year()))
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.white.opacity(0.03))
    }

    private var topPerfumes: [Perfume] {
        perfumes.sorted { a, b in
            if a.isFavorite != b.isFavorite { return a.isFavorite }
            if a.rating != b.rating { return a.rating > b.rating }
            return a.dateAdded > b.dateAdded
        }
    }

    private var topNotes: [String] {
        var counts: [String: Int] = [:]
        for p in perfumes {
            for note in p.allNotes { counts[note, default: 0] += 1 }
        }
        return counts.sorted { $0.value > $1.value }.prefix(5).map(\.key)
    }

    private func perfumeGradient(for name: String) -> LinearGradient {
        let hash = abs(name.hashValue)
        let gradients: [LinearGradient] = [
            LinearGradient(colors: [.purple, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.pink, .orange], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.blue, .teal], startPoint: .topLeading, endPoint: .bottomTrailing),
            LinearGradient(colors: [.orange, .red], startPoint: .topLeading, endPoint: .bottomTrailing),
        ]
        return gradients[hash % gradients.count]
    }
}

struct ShareableImageItem: Transferable {
    let pngData: Data

    nonisolated static var transferRepresentation: some TransferRepresentation {
        DataRepresentation(exportedContentType: .png) { item in
            item.pngData
        }
    }
}
