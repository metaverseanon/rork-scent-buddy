import SwiftUI
import SwiftData

struct PerfumeDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let perfume: Perfume
    @State private var showingDeleteConfirmation: Bool = false
    @State private var showingEditSheet: Bool = false
    @State private var showingLogWear: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                headerSection
                detailContent
            }
        }
        .background(AppearanceManager.shared.theme.backgroundColor)
        .navigationTitle(perfume.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        withAnimation { perfume.isFavorite.toggle() }
                    } label: {
                        Label(
                            perfume.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                            systemImage: perfume.isFavorite ? "heart.slash" : "heart"
                        )
                    }
                    Button {
                        showingLogWear = true
                    } label: {
                        Label("Log Wear", systemImage: "calendar.badge.plus")
                    }
                    Button {
                        showingEditSheet = true
                    } label: {
                        Label("Edit", systemImage: "pencil")
                    }
                    Button(role: .destructive) {
                        showingDeleteConfirmation = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .confirmationDialog("Delete Perfume?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                modelContext.delete(perfume)
                dismiss()
            }
        } message: {
            Text("This will permanently remove \(perfume.name) from your collection.")
        }
        .sheet(isPresented: $showingEditSheet) {
            EditPerfumeView(perfume: perfume)
        }
        .sheet(isPresented: $showingLogWear) {
            LogWearFromDetailView(perfume: perfume)
        }
    }

    private var headerSection: some View {
        ZStack(alignment: .bottomLeading) {
            LinearGradient(
                colors: [headerColor.opacity(0.8), headerColor.opacity(0.4)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 220)
            .overlay {
                Image(systemName: "drop.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.white.opacity(0.15))
            }

            VStack(alignment: .leading, spacing: 4) {
                if perfume.isFavorite {
                    Label("Favorite", systemImage: "heart.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(.pink.opacity(0.8))
                        .clipShape(Capsule())
                }
                Text(perfume.brand)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.8))
                Text(perfume.name)
                    .font(.title.bold())
                    .foregroundStyle(.white)
            }
            .padding(20)
        }
    }

    private var detailContent: some View {
        VStack(spacing: 16) {
            infoRow
            ratingSection

            if !perfume.topNotes.isEmpty || !perfume.heartNotes.isEmpty || !perfume.baseNotes.isEmpty {
                notesSection
            }

            if !perfume.personalNotes.isEmpty {
                personalNotesSection
            }
        }
        .padding(16)
    }

    private var ratingSection: some View {
        VStack(spacing: 10) {
            Text(perfume.rating == 0 ? "Rate this fragrance" : "Your Rating")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            HStack(spacing: 12) {
                ForEach(1...5, id: \.self) { star in
                    Button {
                        withAnimation(.snappy) {
                            perfume.rating = perfume.rating == star ? 0 : star
                        }
                    } label: {
                        Image(systemName: star <= perfume.rating ? "star.fill" : "star")
                            .font(.title2)
                            .foregroundStyle(star <= perfume.rating ? .orange : .gray.opacity(0.3))
                    }
                    .sensoryFeedback(.selection, trigger: perfume.rating)
                }
            }
            if perfume.rating > 0 {
                Text("\(perfume.rating)/5")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var infoRow: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            InfoTile(icon: "flask", title: "Concentration", value: perfume.concentration)
            InfoTile(icon: "leaf", title: "Season", value: perfume.season)
            InfoTile(icon: "calendar", title: "Occasion", value: perfume.occasion)
        }
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Fragrance Pyramid")
                .font(.headline)

            if !perfume.topNotes.isEmpty {
                NoteGroup(title: "Top Notes", notes: perfume.topNotes, color: .orange)
            }
            if !perfume.heartNotes.isEmpty {
                NoteGroup(title: "Heart Notes", notes: perfume.heartNotes, color: .pink)
            }
            if !perfume.baseNotes.isEmpty {
                NoteGroup(title: "Base Notes", notes: perfume.baseNotes, color: .purple)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var personalNotesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Personal Notes", systemImage: "note.text")
                .font(.headline)
            Text(perfume.personalNotes)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var headerColor: Color {
        let hash = abs(perfume.name.hashValue)
        let colors: [Color] = [.purple, .indigo, .blue, .teal, .orange, .pink]
        return colors[hash % colors.count]
    }
}

struct InfoTile: View {
    let icon: String
    let title: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.tint)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.subheadline.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 12))
    }
}

struct NoteGroup: View {
    let title: String
    let notes: [String]
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.subheadline.bold())
                .foregroundStyle(color)

            FlowLayout(spacing: 6) {
                ForEach(notes, id: \.self) { note in
                    Text(note)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(color.opacity(0.12))
                        .foregroundStyle(color)
                        .clipShape(Capsule())
                }
            }
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 6

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (positions: [CGPoint], size: CGSize) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth, x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
        }

        return (positions, CGSize(width: maxWidth, height: y + rowHeight))
    }
}
