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
    @State private var isLayering: Bool = false
    @State private var layeredPerfumes: [Perfume] = []
    @State private var layerSearchText: String = ""

    private let moods = ["Confident", "Romantic", "Fresh", "Cozy", "Energetic", "Relaxed", "Bold", "Elegant"]

    var body: some View {
        NavigationStack {
            Form {
                perfumeSection
                layeringSection
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
                            withAnimation(.spring(duration: 0.35, bounce: 0.4)) { rating = star }
                        } label: {
                            Image(systemName: star <= rating ? "star.fill" : "star")
                                .font(.body)
                                .foregroundStyle(star <= rating ? .orange : .gray.opacity(0.3))
                                .scaleEffect(star <= rating ? 1.0 : 0.85)
                                .animation(.spring(duration: 0.3, bounce: 0.5), value: rating)
                        }
                        .buttonStyle(.plain)
                        .sensoryFeedback(.impact(weight: .light), trigger: rating)
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
                        withAnimation(.spring(duration: 0.3, bounce: 0.3)) { mood = m }
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
                    .sensoryFeedback(.selection, trigger: mood)
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
                        if sprays > 1 { withAnimation(.snappy) { sprays -= 1 } }
                    } label: {
                        Image(systemName: "minus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: sprays)

                    Text("\(sprays)")
                        .font(.title3.bold().monospacedDigit())
                        .frame(minWidth: 30)
                        .contentTransition(.numericText())

                    Button {
                        if sprays < 20 { withAnimation(.snappy) { sprays += 1 } }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title3)
                            .foregroundStyle(.tint)
                    }
                    .buttonStyle(.plain)
                    .sensoryFeedback(.impact(weight: .light), trigger: sprays)
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

    private var layeringSection: some View {
        Section {
            Toggle(isOn: $isLayering.animation(.snappy)) {
                Label("Layering", systemImage: "square.stack.3d.up.fill")
                    .font(.subheadline)
            }
            .sensoryFeedback(.selection, trigger: isLayering)

            if isLayering {
                if !layeredPerfumes.isEmpty {
                    ForEach(layeredPerfumes) { lp in
                        HStack(spacing: 10) {
                            Image(systemName: "drop.fill")
                                .font(.caption)
                                .foregroundStyle(.orange)
                                .frame(width: 28, height: 28)
                                .background(.orange.opacity(0.1))
                                .clipShape(Circle())

                            VStack(alignment: .leading, spacing: 1) {
                                Text(lp.name)
                                    .font(.subheadline)
                                Text(lp.brand)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button {
                                withAnimation(.snappy) {
                                    layeredPerfumes.removeAll { $0.id == lp.id }
                                }
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                let availablePerfumes = perfumes.filter { p in
                    p.id != selectedPerfume?.id && !layeredPerfumes.contains(where: { $0.id == p.id })
                }
                let filteredLayer = layerSearchText.isEmpty ? availablePerfumes : availablePerfumes.filter {
                    $0.name.localizedStandardContains(layerSearchText) ||
                    $0.brand.localizedStandardContains(layerSearchText)
                }

                if !availablePerfumes.isEmpty {
                    TextField("Search to add layer...", text: $layerSearchText)
                        .textFieldStyle(.roundedBorder)

                    ScrollView {
                        LazyVStack(spacing: 4) {
                            ForEach(filteredLayer) { perfume in
                                Button {
                                    withAnimation(.snappy) {
                                        layeredPerfumes.append(perfume)
                                        layerSearchText = ""
                                    }
                                    HapticManager.shared.lightTap()
                                } label: {
                                    HStack(spacing: 10) {
                                        Image(systemName: "plus.circle.fill")
                                            .font(.caption)
                                            .foregroundStyle(.orange)
                                            .frame(width: 28, height: 28)
                                            .background(.orange.opacity(0.1))
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
                    .frame(maxHeight: 150)
                }
            }
        } header: {
            Text("Layering")
        } footer: {
            if isLayering {
                Text("Add perfumes you're layering with your main scent")
            }
        }
    }

    private func save() {
        guard let perfume = selectedPerfume else { return }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        let entry = WearEntry(
            perfumeName: perfume.name,
            perfumeBrand: perfume.brand,
            date: date,
            occasion: occasion,
            mood: mood,
            notes: notes,
            rating: rating,
            sprays: sprays,
            layeredPerfumeNames: isLayering ? layeredPerfumes.map { $0.name } : [],
            layeredPerfumeBrands: isLayering ? layeredPerfumes.map { $0.brand } : []
        )
        modelContext.insert(entry)
        dismiss()
    }
}
