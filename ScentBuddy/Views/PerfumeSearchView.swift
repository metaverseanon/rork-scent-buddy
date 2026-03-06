import SwiftUI

struct PerfumeSearchView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelect: (PerfumeEntry) -> Void

    @State private var searchText: String = ""
    @State private var selectedBrand: String? = nil

    private var searchResults: [PerfumeEntry] {
        if !searchText.isEmpty {
            return PerfumeDatabase.search(query: searchText)
        } else if let brand = selectedBrand {
            return PerfumeDatabase.perfumes(forBrand: brand)
        }
        return []
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
                Text("\(PerfumeDatabase.entries.count) perfumes in database")
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
                    perfumeRows(searchResults)
                }
            } else if searchResults.isEmpty {
                ContentUnavailableView.search(text: searchText)
            } else {
                Section("Results") {
                    perfumeRows(searchResults)
                }
            }
        }
    }

    private func perfumeRows(_ perfumes: [PerfumeEntry]) -> some View {
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
