import SwiftUI

struct PerfumeSearchView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (PerfumeEntry) -> Void

    @State private var searchText: String = ""
    @State private var selectedBrand: String? = nil
    @State private var fragellaService = FragellaAPIService()
    @State private var searchTask: Task<Void, Never>?

    private var localResults: [PerfumeEntry] {
        if !searchText.isEmpty {
            return PerfumeDatabase.search(query: searchText)
        } else if let brand = selectedBrand {
            return PerfumeDatabase.perfumes(forBrand: brand)
        }
        return []
    }

    private var useFragella: Bool {
        fragellaService.isConfigured && !searchText.isEmpty && searchText.count >= 3
    }

    var body: some View {
        NavigationStack {
            Group {
                if searchText.isEmpty && selectedBrand == nil {
                    brandListView
                } else {
                    resultsListView
                }
            }
            .navigationTitle("Find Perfume")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search by name or brand...")
            .onChange(of: searchText) { _, newValue in
                if !newValue.isEmpty {
                    selectedBrand = nil
                }
                searchTask?.cancel()
                if newValue.count >= 3 && fragellaService.isConfigured {
                    searchTask = Task {
                        try? await Task.sleep(for: .milliseconds(400))
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

    private var brandListView: some View {
        List {
            if fragellaService.isConfigured {
                Section {
                    HStack(spacing: 10) {
                        Image(systemName: "globe")
                            .font(.caption)
                            .foregroundStyle(.green)
                        Text("Connected to Fragella — 74k+ fragrances")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Section {
                ForEach(PerfumeDatabase.brands, id: \.self) { brand in
                    Button {
                        withAnimation { selectedBrand = brand }
                    } label: {
                        HStack {
                            Text(brand)
                                .foregroundStyle(.primary)
                            Spacer()
                            Text("\(PerfumeDatabase.perfumes(forBrand: brand).count)")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            } header: {
                Text("Browse by Brand")
            } footer: {
                Text("\(PerfumeDatabase.entries.count) perfumes in local database")
            }
        }
    }

    private var resultsListView: some View {
        List {
            if let brand = selectedBrand, searchText.isEmpty {
                Section {
                    Button {
                        withAnimation { selectedBrand = nil }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "chevron.left")
                                .font(.caption)
                            Text("All Brands")
                        }
                        .foregroundStyle(.tint)
                    }
                }
                Section(brand) {
                    localPerfumeRows(localResults)
                }
            } else if useFragella {
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

                if !localResults.isEmpty {
                    Section("Local Database") {
                        localPerfumeRows(localResults)
                    }
                }

                if fragellaService.searchResults.isEmpty && localResults.isEmpty && !fragellaService.isSearching {
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
            } else if localResults.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                Section("Results") {
                    localPerfumeRows(localResults)
                }
            }
        }
    }

    private func localPerfumeRows(_ perfumes: [PerfumeEntry]) -> some View {
        ForEach(perfumes) { entry in
            Button {
                onSelect(entry)
                dismiss()
            } label: {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.name)
                            .font(.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.primary)
                        Spacer()
                        Text(entry.concentration)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .background(Color(.tertiarySystemFill))
                            .clipShape(Capsule())
                    }
                    Text(entry.brand)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    if !entry.allNotes.isEmpty {
                        Text(entry.allNotes.prefix(5).joined(separator: " · "))
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
