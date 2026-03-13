import SwiftUI
import SwiftData

struct AddPerfumeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var concentration: String = "Eau de Parfum"
    @State private var season: String = "All Seasons"
    @State private var occasion: String = "Everyday"
    @State private var rating: Int = 0
    @State private var personalNotes: String = ""
    @State private var isFavorite: Bool = false

    @State private var topNotes: [String] = []
    @State private var heartNotes: [String] = []
    @State private var baseNotes: [String] = []

    @State private var showingTopNotePicker: Bool = false
    @State private var showingHeartNotePicker: Bool = false
    @State private var showingBaseNotePicker: Bool = false
    @State private var showingPerfumeSearch: Bool = false
    @State private var autoFilled: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showingPerfumeSearch = true
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.body)
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(.tint, in: .rect(cornerRadius: 8))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Search Fragella Database")
                                    .font(.subheadline)
                                    .fontWeight(.medium)
                                    .foregroundStyle(.primary)
                                Text("74k+ fragrances with auto-fill")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }

                if autoFilled {
                    Section {
                        HStack(spacing: 8) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                            Text("Auto-filled from Fragella")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Button("Clear") {
                                clearForm()
                            }
                            .font(.subheadline)
                        }
                    }
                }

                Section("Basic Info") {
                    TextField("Perfume Name", text: $name)
                        .textContentType(.name)
                    TextField("Brand", text: $brand)
                    Picker("Concentration", selection: $concentration) {
                        ForEach(PerfumeConstants.concentrations, id: \.self) { Text($0) }
                    }
                }

                Section("Fragrance Notes") {
                    noteRow(title: "Top Notes", notes: $topNotes, showing: $showingTopNotePicker)
                    noteRow(title: "Heart Notes", notes: $heartNotes, showing: $showingHeartNotePicker)
                    noteRow(title: "Base Notes", notes: $baseNotes, showing: $showingBaseNotePicker)
                }

                Section("Details") {
                    Picker("Season", selection: $season) {
                        ForEach(PerfumeConstants.seasons, id: \.self) { Text($0) }
                    }
                    Picker("Occasion", selection: $occasion) {
                        ForEach(PerfumeConstants.occasions, id: \.self) { Text($0) }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating")
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    withAnimation(.snappy) { rating = star }
                                } label: {
                                    Image(systemName: star <= rating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundStyle(star <= rating ? Color.orange : Color.gray.opacity(0.3))
                                }
                            }
                        }
                    }

                    Toggle("Favorite", isOn: $isFavorite)
                }

                Section("Personal Notes") {
                    TextField("Your thoughts...", text: $personalNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Add Perfume")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { savePerfume() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty || brand.isEmpty)
                }
            }
            .sheet(isPresented: $showingTopNotePicker) {
                NotePickerView(selectedNotes: $topNotes, title: "Top Notes")
            }
            .sheet(isPresented: $showingHeartNotePicker) {
                NotePickerView(selectedNotes: $heartNotes, title: "Heart Notes")
            }
            .sheet(isPresented: $showingBaseNotePicker) {
                NotePickerView(selectedNotes: $baseNotes, title: "Base Notes")
            }
            .sheet(isPresented: $showingPerfumeSearch) {
                PerfumeSearchView { entry in
                    fillFromEntry(entry)
                }
            }
        }
    }

    private func fillFromEntry(_ entry: PerfumeEntry) {
        name = entry.name
        brand = entry.brand
        concentration = PerfumeConstants.concentrations.contains(entry.concentration)
            ? entry.concentration : "Eau de Parfum"
        topNotes = entry.topNotes
        heartNotes = entry.heartNotes
        baseNotes = entry.baseNotes
        autoFilled = true
    }

    private func clearForm() {
        name = ""
        brand = ""
        concentration = "Eau de Parfum"
        topNotes = []
        heartNotes = []
        baseNotes = []
        autoFilled = false
    }

    private func noteRow(title: String, notes: Binding<[String]>, showing: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                showing.wrappedValue = true
            } label: {
                HStack {
                    Text(title)
                        .foregroundStyle(.primary)
                    Spacer()
                    if notes.wrappedValue.isEmpty {
                        Text("Add")
                            .foregroundStyle(.secondary)
                    } else {
                        Text("\(notes.wrappedValue.count) selected")
                            .foregroundStyle(.secondary)
                    }
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            if !notes.wrappedValue.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        ForEach(notes.wrappedValue, id: \.self) { note in
                            Text(note)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(.tint.opacity(0.12))
                                .foregroundStyle(.tint)
                                .clipShape(Capsule())
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
            }
        }
    }

    private func savePerfume() {
        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        let trimmedBrand = brand.trimmingCharacters(in: .whitespaces)
        let trimmedNotes = personalNotes.trimmingCharacters(in: .whitespaces)
        let perfume = Perfume(
            name: trimmedName,
            brand: trimmedBrand,
            concentration: concentration,
            topNotes: topNotes,
            heartNotes: heartNotes,
            baseNotes: baseNotes,
            season: season,
            occasion: occasion,
            rating: rating,
            personalNotes: trimmedNotes,
            isFavorite: isFavorite
        )
        modelContext.insert(perfume)
        syncToSupabase(name: trimmedName, brand: trimmedBrand, notes: trimmedNotes)
        dismiss()
    }

    private func syncToSupabase(name: String, brand: String, notes: String) {
        guard let userId = SupabaseService.shared.currentUserId else { return }
        Task {
            let item = UserCollectionInsert(
                user_id: userId,
                perfume_name: name,
                perfume_brand: brand,
                image_url: nil,
                concentration: concentration,
                top_notes: topNotes,
                heart_notes: heartNotes,
                base_notes: baseNotes,
                season: season,
                occasion: occasion,
                rating: rating,
                personal_notes: notes,
                is_favorite: isFavorite
            )
            try? await SupabaseService.shared.insertCollectionItem(item)
            try? await SupabaseService.shared.insertActivity(ActivityFeedInsert(
                user_id: userId,
                activity_type: "added_perfume",
                perfume_name: name,
                perfume_brand: brand,
                target_user_id: nil
            ))
        }
    }
}

struct NotePickerView: View {
    @Binding var selectedNotes: [String]
    let title: String
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    private var filteredNotes: [String] {
        if searchText.isEmpty { return PerfumeConstants.commonNotes }
        return PerfumeConstants.commonNotes.filter { $0.localizedStandardContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                if !selectedNotes.isEmpty {
                    Section("Selected") {
                        ForEach(selectedNotes, id: \.self) { note in
                            Button {
                                toggleNote(note)
                            } label: {
                                HStack {
                                    Text(note)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                }

                Section("All Notes") {
                    ForEach(filteredNotes, id: \.self) { note in
                        Button {
                            toggleNote(note)
                        } label: {
                            HStack {
                                Text(note)
                                    .foregroundStyle(.primary)
                                Spacer()
                                if selectedNotes.contains(note) {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(.tint)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search notes...")
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private func toggleNote(_ note: String) {
        withAnimation(.snappy) {
            if let index = selectedNotes.firstIndex(of: note) {
                selectedNotes.remove(at: index)
            } else {
                selectedNotes.append(note)
            }
        }
    }
}
