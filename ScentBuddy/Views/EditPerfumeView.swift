import SwiftUI

struct EditPerfumeView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var perfume: Perfume

    @State private var showingTopNotePicker: Bool = false
    @State private var showingHeartNotePicker: Bool = false
    @State private var showingBaseNotePicker: Bool = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Basic Info") {
                    TextField("Perfume Name", text: $perfume.name)
                    TextField("Brand", text: $perfume.brand)
                    Picker("Concentration", selection: $perfume.concentration) {
                        ForEach(PerfumeConstants.concentrations, id: \.self) { Text($0) }
                    }
                }

                Section("Fragrance Notes") {
                    editNoteRow(title: "Top Notes", notes: $perfume.topNotes, showing: $showingTopNotePicker)
                    editNoteRow(title: "Heart Notes", notes: $perfume.heartNotes, showing: $showingHeartNotePicker)
                    editNoteRow(title: "Base Notes", notes: $perfume.baseNotes, showing: $showingBaseNotePicker)
                }

                Section("Details") {
                    Picker("Season", selection: $perfume.season) {
                        ForEach(PerfumeConstants.seasons, id: \.self) { Text($0) }
                    }
                    Picker("Occasion", selection: $perfume.occasion) {
                        ForEach(PerfumeConstants.occasions, id: \.self) { Text($0) }
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Rating")
                        HStack(spacing: 8) {
                            ForEach(1...5, id: \.self) { star in
                                Button {
                                    withAnimation(.snappy) { perfume.rating = star }
                                } label: {
                                    Image(systemName: star <= perfume.rating ? "star.fill" : "star")
                                        .font(.title2)
                                        .foregroundStyle(star <= perfume.rating ? Color.orange : Color.gray.opacity(0.3))
                                }
                            }
                        }
                    }

                    Toggle("Favorite", isOn: $perfume.isFavorite)
                }

                Section("Personal Notes") {
                    TextField("Your thoughts...", text: $perfume.personalNotes, axis: .vertical)
                        .lineLimit(3...6)
                }
            }
            .navigationTitle("Edit Perfume")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showingTopNotePicker) {
                NotePickerView(selectedNotes: $perfume.topNotes, title: "Top Notes")
            }
            .sheet(isPresented: $showingHeartNotePicker) {
                NotePickerView(selectedNotes: $perfume.heartNotes, title: "Heart Notes")
            }
            .sheet(isPresented: $showingBaseNotePicker) {
                NotePickerView(selectedNotes: $perfume.baseNotes, title: "Base Notes")
            }
        }
    }

    private func editNoteRow(title: String, notes: Binding<[String]>, showing: Binding<Bool>) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Button {
                showing.wrappedValue = true
            } label: {
                HStack {
                    Text(title)
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("\(notes.wrappedValue.count) selected")
                        .foregroundStyle(.secondary)
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
}
