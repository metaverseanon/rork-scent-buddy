import SwiftUI
import SwiftData

struct LogWearView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query(sort: \Perfume.name) private var perfumes: [Perfume]

    @State private var selectedPerfume: Perfume?
    @State private var date: Date = Date()
    @State private var occasion: String = "Everyday"
    @State private var mood: String = "Confident"
    @State private var notes: String = ""
    @State private var rating: Int = 4
    @State private var sprays: Int = 3
    @State private var searchText: String = ""

    private let moods = ["Confident", "Romantic", "Fresh", "Cozy", "Energetic", "Relaxed", "Bold", "Elegant"]

    var body: some View {
        NavigationStack {
            Form {
                perfumeSection
                detailsSection
                moodSection
                spraySection
                notesSection
            }
            .navigationTitle("Log Wear")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                        .disabled(selectedPerfume == nil)
                }
            }
        }
    }

    private var perfumeSection: some View {
        Section {
            if let selected = selectedPerfume {
                HStack(spacing: 12) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [.purple.opacity(0.7), .indigo.opacity(0.5)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                        .overlay {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(.white.opacity(0.5))
                        }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(selected.name)
                            .font(.subheadline.bold())
                        Text(selected.brand)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        withAnimation { selectedPerfume = nil }
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            } else {
                VStack(alignment: .leading, spacing: 10) {
                    Label("Select a Perfume", systemImage: "magnifyingglass")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    let filtered = searchText.isEmpty ? perfumes : perfumes.filter {
                        $0.name.localizedStandardContains(searchText) ||
                        $0.brand.localizedStandardContains(searchText)
                    }

                    TextField("Search your collection...", text: $searchText)
                        .textFieldStyle(.roundedBorder)

                    if perfumes.isEmpty {
                        Text("Add perfumes to your collection first")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 4) {
                                ForEach(filtered) { perfume in
                                    Button {
                                        withAnimation(.snappy) {
                                            selectedPerfume = perfume
                                            searchText = ""
                                        }
                                    } label: {
                                        HStack(spacing: 10) {
                                            Image(systemName: "drop.fill")
                                                .font(.caption)
                                                .foregroundStyle(.tint)
                                                .frame(width: 28, height: 28)
                                                .background(.tint.opacity(0.1))
                                                .clipShape(Circle())

                                            VStack(alignment: .leading, spacing: 1) {
                                                Text(perfume.name)
                                                    .font(.subheadline)
                                                Text(perfume.brand)
                                                    .font(.caption)
                                                    .foregroundStyle(.secondary)
                                            }
                                            Spacer()
                                        }
                                        .padding(.vertical, 6)
                                        .contentShape(Rectangle())
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .frame(maxHeight: 200)
                    }
                }
            }
        } header: {
            Text("Perfume")
        }
    }

    private var detailsSection: some View {
        Section {
            DatePicker("Date", selection: $date, displayedComponents: .date)

            Picker("Occasion", selection: $occasion) {
                ForEach(PerfumeConstants.occasions, id: \.self) { occ in
                    Text(occ).tag(occ)
                }
            }

            HStack {
                Text("Rating")
                Spacer()
                HStack(spacing: 4) {
                    ForEach(1...5, id: \.self) { star in
                        Button {
                            withAnimation(.snappy) { rating = star }
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.body)
                                .foregroundStyle(star <= rating ? .orange : .gray.opacity(0.3))
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        } header: {
            Text("Details")
        }
    }

    private var moodSection: some View {
        Section {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 90), spacing: 8)], spacing: 8) {
                ForEach(moods, id: \.self) { m in
                    Button {
                        withAnimation(.snappy) { mood = m }
                    } label: {
                        Text(m)
                            .font(.caption)
                            .fontWeight(mood == m ? .semibold : .regular)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(mood == m ? AnyShapeStyle(.tint) : AnyShapeStyle(Color(.tertiarySystemFill)))
                            .foregroundStyle(mood == m ? .white : .primary)
                            .clipShape(Capsule())
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            Text("Mood")
        }
    }

    private var spraySection: some View {
        Section {
            HStack {
                Text("Sprays")
                Spacer()
                HStack(spacing: 16) {
                    Button {
                        if sprays > 1 { withAnimation { sprays -= 1 } }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)

                    Text("\(sprays)")
                        .font(.title3.bold().monospacedDigit())
                        .frame(minWidth: 30)

                    Button {
                        if sprays < 20 { withAnimation { sprays += 1 } }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.tint)
                    }
                    .buttonStyle(.plain)
                }
            }
        } header: {
            Text("Application")
        }
    }

    private var notesSection: some View {
        Section {
            TextField("How did it perform today?", text: $notes, axis: .vertical)
                .lineLimit(3...6)
        } header: {
            Text("Notes")
        }
    }

    private func save() {
        guard let perfume = selectedPerfume else { return }
        let entry = WearEntry(
            perfumeName: perfume.name,
            perfumeBrand: perfume.brand,
            date: date,
            occasion: occasion,
            mood: mood,
            notes: notes,
            rating: rating,
            sprays: sprays
        )
        modelContext.insert(entry)
        dismiss()
    }
}
