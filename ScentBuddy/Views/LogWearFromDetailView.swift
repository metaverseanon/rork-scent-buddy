import SwiftUI
import SwiftData

struct LogWearFromDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    let perfume: Perfume

    @State private var date: Date = Date()
    @State private var occasion: String = "Everyday"
    @State private var mood: String = "Confident"
    @State private var notes: String = ""
    @State private var rating: Int = 4
    @State private var sprays: Int = 3

    private let moods = ["Confident", "Romantic", "Fresh", "Cozy", "Energetic", "Relaxed", "Bold", "Elegant"]

    var body: some View {
        NavigationStack {
            Form {
                Section {
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
                            Text(perfume.name)
                                .font(.subheadline.bold())
                            Text(perfume.brand)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                } header: {
                    Text("Perfume")
                }

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

                Section {
                    TextField("How did it perform today?", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
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
                }
            }
        }
    }

    private func save() {
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
