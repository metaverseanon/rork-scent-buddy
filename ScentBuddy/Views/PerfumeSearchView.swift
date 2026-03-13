import SwiftUI

struct PerfumeSearchView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (PerfumeEntry) -> Void

    @State private var searchText: String = ""
    @State private var fragellaService = FragellaAPIService()
    @State private var searchTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty {
                    promptView
                } else {
                    resultsListView
                }
            }
            .navigationTitle("Find Perfume")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name or brand...")
            .onChange(of: searchText) { _, newValue in
                searchTask?.cancel()
                if newValue.count >= 3 && fragellaService.isConfigured {
                    searchTask = Task {
                        try? await Task.sleep(for: .milliseconds(800))
                        guard !Task.isCancelled else { return }
                        await fragellaService.search(query: newValue)
                    }
                } else {
                    fragellaService.searchResults = []
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var promptView: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            VStack(spacing: 8) {
                Text("Search Fragrances")
                    .font(.title3.bold())
                Text("Search over 74,000 fragrances from the Fragella database.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            if fragellaService.isConfigured {
                HStack(spacing: 6) {
                    Image(systemName: "globe")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Text("Connected to Fragella")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.tertiarySystemFill))
                .clipShape(Capsule())
            }

            Spacer()
            Spacer()
        }
    }

    private var resultsListView: some View {
        List {
            if fragellaService.isSearching {
                Section {
                    HStack {
                        ProgressView()
                            .controlSize(.small)
                        Text("Searching Fragella...")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            if !fragellaService.searchResults.isEmpty {
                Section {
                    ForEach(fragellaService.searchResults) { fragrance in
                        Button {
                            let entry = PerfumeEntry(
                                id: fragrance.id,
                                name: fragrance.name,
                                brand: fragrance.brand,
                                concentration: fragrance.concentration,
                                topNotes: fragrance.topNotes,
                                heartNotes: fragrance.heartNotes,
                                baseNotes: fragrance.baseNotes,
                                gender: ""
                            )
                            onSelect(entry)
                            dismiss()
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(fragrance.name)
                                        .font(.body)
                                        .fontWeight(.medium)
                                        .foregroundStyle(.primary)
                                    Spacer()
                                    Text(fragrance.concentration)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 2)
                                        .background(Color(.tertiarySystemFill))
                                        .clipShape(Capsule())
                                }
                                Text(fragrance.brand)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                if !fragrance.allNotes.isEmpty {
                                    Text(fragrance.allNotes.prefix(5).joined(separator: " · "))
                                        .font(.caption)
                                        .foregroundStyle(.tertiary)
                                        .lineLimit(1)
                                }
                            }
                            .padding(.vertical, 2)
                        }
                    }
                } header: {
                    HStack(spacing: 6) {
                        Image(systemName: "globe")
                            .font(.caption2)
                        Text("Fragella Results")
                    }
                }
            }

            if fragellaService.searchResults.isEmpty && !fragellaService.isSearching && searchText.count >= 3 {
                ContentUnavailableView.search(text: searchText)
            }

            if let error = fragellaService.errorMessage {
                Section {
                    HStack(spacing: 8) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
    }
}
