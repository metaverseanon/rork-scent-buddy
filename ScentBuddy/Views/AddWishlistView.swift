import SwiftUI
import SwiftData

struct AddWishlistView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var brand: String = ""
    @State private var concentration: String = "Eau de Parfum"
    @State private var notes: [String] = []
    @State private var estimatedPrice: String = ""
    @State private var reason: String = ""
    @State private var priority: Int = 1
    @State private var showingNotePicker: Bool = false
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
                                Text("Search Perfume Database")
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

                Section("Perfume") {
                    TextField("Perfume Name", text: $name)
                    TextField("Brand", text: $brand)
                    Picker("Concentration", selection: $concentration) {
                        ForEach(PerfumeConstants.concentrations, id: \.self) { Text($0) }
                    }
                }

                Section("Notes") {
                    Button {
                        showingNotePicker = true
                    } label: {
                        HStack {
                            Text("Fragrance Notes")
                                .foregroundStyle(.primary)
                            Spacer()
                            if notes.isEmpty {
                                Text("Add")
                                    .foregroundStyle(.secondary)
                            } else {
                                Text("\(notes.count) selected")
                                    .foregroundStyle(.secondary)
                            }
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    if !notes.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 6) {
                                ForEach(notes, id: \.self) { note in
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

                Section("Details") {
                    TextField("Estimated Price (e.g. $120)", text: $estimatedPrice)
                        .keyboardType(.default)

                    Picker("Priority", selection: $priority) {
                        ForEach(Array(PerfumeConstants.priorities.enumerated()), id: \.offset) { index, label in
                            Text(label).tag(index)
                        }
                    }
                }

                Section("Why do you want it?") {
                    TextField("What drew you to this fragrance...", text: $reason, axis: .vertical)
                        .lineLimit(2...4)
                }
            }
            .navigationTitle("Add to Wishlist")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveItem() }
                        .fontWeight(.semibold)
                        .disabled(name.isEmpty || brand.isEmpty)
                }
            }
            .sheet(isPresented: $showingNotePicker) {
                NotePickerView(selectedNotes: $notes, title: "Fragrance Notes")
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
        notes = entry.allNotes
        autoFilled = true
    }

    private func clearForm() {
        name = ""
        brand = ""
        concentration = "Eau de Parfum"
        notes = []
        autoFilled = false
    }

    private func saveItem() {
        let item = WishlistPerfume(
            name: name.trimmingCharacters(in: .whitespaces),
            brand: brand.trimmingCharacters(in: .whitespaces),
            concentration: concentration,
            notes: notes,
            estimatedPrice: estimatedPrice.trimmingCharacters(in: .whitespaces),
            reason: reason.trimmingCharacters(in: .whitespaces),
            priority: priority
        )
        modelContext.insert(item)
        dismiss()
    }
}
