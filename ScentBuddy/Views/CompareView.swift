import SwiftUI
import SwiftData

struct CompareView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Perfume.name) private var perfumes: [Perfume]
    @State private var leftPerfume: Perfume?
    @State private var rightPerfume: Perfume?
    @State private var showingLeftPicker: Bool = false
    @State private var showingRightPicker: Bool = false

    var body: some View {
        ScrollView {
            if perfumes.count < 2 {
                needMorePerfumes
            } else if leftPerfume == nil || rightPerfume == nil {
                selectionPrompt
            } else {
                comparisonContent
            }
        }
        .background(AppearanceManager.shared.theme.backgroundColor)
        .navigationTitle("Compare")
        .toolbar {
            if leftPerfume != nil || rightPerfume != nil {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Reset") {
                        withAnimation(.snappy) {
                            leftPerfume = nil
                            rightPerfume = nil
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingLeftPicker) {
            ComparePerfumePicker(
                perfumes: perfumes,
                excludedPerfume: rightPerfume,
                selection: $leftPerfume
            )
        }
        .sheet(isPresented: $showingRightPicker) {
            ComparePerfumePicker(
                perfumes: perfumes,
                excludedPerfume: leftPerfume,
                selection: $rightPerfume
            )
        }
    }

    private var needMorePerfumes: some View {
        ContentUnavailableView {
            Label("Need More Perfumes", systemImage: "arrow.left.arrow.right")
        } description: {
            Text("Add at least 2 perfumes to your collection to start comparing.")
        }
        .frame(maxWidth: .infinity, minHeight: 400)
    }

    private var selectionPrompt: some View {
        VStack(spacing: 24) {
            HStack(spacing: 12) {
                slotButton(perfume: leftPerfume, label: "First") {
                    showingLeftPicker = true
                }
                Image(systemName: "arrow.left.arrow.right")
                    .font(.title3.bold())
                    .foregroundStyle(.secondary)
                slotButton(perfume: rightPerfume, label: "Second") {
                    showingRightPicker = true
                }
            }
            .padding(.horizontal)
            .padding(.top, 40)

            Text("Select two perfumes to compare")
                .font(.subheadline)
                .foregroundStyle(.tertiary)
        }
    }

    private func slotButton(perfume: Perfume?, label: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            VStack(spacing: 10) {
                if let perfume {
                    filledSlot(perfume)
                } else {
                    emptySlot(label)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 180)
            .background(AppearanceManager.shared.theme.cardColor)
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }

    private func emptySlot(_ label: String) -> some View {
        VStack(spacing: 10) {
            Image(systemName: "plus.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(.tint)
            Text("Select \(label)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func filledSlot(_ perfume: Perfume) -> some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 10)
                .fill(colorFor(perfume).gradient)
                .frame(height: 80)
                .overlay {
                    Image(systemName: "drop.fill")
                        .font(.system(size: 28))
                        .foregroundStyle(.white.opacity(0.3))
                }
                .padding(.horizontal, 12)
                .padding(.top, 12)

            Text(perfume.name)
                .font(.subheadline.bold())
                .lineLimit(1)
            Text(perfume.brand)
                .font(.caption)
                .foregroundStyle(.secondary)
                .lineLimit(1)
        }
        .padding(.bottom, 10)
    }

    @ViewBuilder
    private var comparisonContent: some View {
        if let left = leftPerfume, let right = rightPerfume {
            VStack(spacing: 16) {
                headerComparison(left: left, right: right)
                ratingComparison(left: left, right: right)
                attributeComparison(left: left, right: right)
                notesComparison(left: left, right: right)
                sharedNotesSection(left: left, right: right)
            }
            .padding(.horizontal)
            .padding(.bottom, 24)
        }
    }

    private func headerComparison(left: Perfume, right: Perfume) -> some View {
        HStack(spacing: 12) {
            slotButton(perfume: left, label: "First") {
                showingLeftPicker = true
            }
            Image(systemName: "arrow.left.arrow.right")
                .font(.title3.bold())
                .foregroundStyle(.secondary)
            slotButton(perfume: right, label: "Second") {
                showingRightPicker = true
            }
        }
        .padding(.top, 8)
    }

    private func ratingComparison(left: Perfume, right: Perfume) -> some View {
        VStack(spacing: 12) {
            Text("Rating")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack {
                ratingStars(left.rating)
                    .frame(maxWidth: .infinity)
                Divider().frame(height: 20)
                ratingStars(right.rating)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private func ratingStars(_ rating: Int) -> some View {
        HStack(spacing: 3) {
            ForEach(0..<5, id: \.self) { i in
                Image(systemName: i < rating ? "star.fill" : "star")
                    .font(.caption)
                    .foregroundStyle(i < rating ? .orange : .gray.opacity(0.3))
            }
            Text("\(rating)/5")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
    }

    private func attributeComparison(left: Perfume, right: Perfume) -> some View {
        VStack(spacing: 0) {
            CompareRow(label: "Concentration", leftValue: left.concentration, rightValue: right.concentration)
            Divider().padding(.horizontal, 16)
            CompareRow(label: "Season", leftValue: left.season, rightValue: right.season)
            Divider().padding(.horizontal, 16)
            CompareRow(label: "Occasion", leftValue: left.occasion, rightValue: right.occasion)
        }
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private func notesComparison(left: Perfume, right: Perfume) -> some View {
        VStack(spacing: 16) {
            Text("Fragrance Pyramid")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            CompareNotesRow(label: "Top Notes", leftNotes: left.topNotes, rightNotes: right.topNotes, color: .orange)
            CompareNotesRow(label: "Heart Notes", leftNotes: left.heartNotes, rightNotes: right.heartNotes, color: .pink)
            CompareNotesRow(label: "Base Notes", leftNotes: left.baseNotes, rightNotes: right.baseNotes, color: .purple)
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private func sharedNotesSection(left: Perfume, right: Perfume) -> some View {
        let leftAll = Set(left.allNotes)
        let rightAll = Set(right.allNotes)
        let shared = leftAll.intersection(rightAll)
        let uniqueLeft = leftAll.subtracting(rightAll)
        let uniqueRight = rightAll.subtracting(leftAll)

        return VStack(spacing: 14) {
            Text("Notes Breakdown")
                .font(.subheadline.bold())
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            if !shared.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Shared Notes", systemImage: "link")
                        .font(.caption.bold())
                        .foregroundStyle(.green)

                    FlowLayout(spacing: 6) {
                        ForEach(shared.sorted(), id: \.self) { note in
                            Text(note)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.green.opacity(0.12))
                                .foregroundStyle(.green)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            if !uniqueLeft.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Only in \(left.name)", systemImage: "drop.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.blue)

                    FlowLayout(spacing: 6) {
                        ForEach(uniqueLeft.sorted(), id: \.self) { note in
                            Text(note)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.blue.opacity(0.12))
                                .foregroundStyle(.blue)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            if !uniqueRight.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Only in \(right.name)", systemImage: "drop.fill")
                        .font(.caption.bold())
                        .foregroundStyle(.indigo)

                    FlowLayout(spacing: 6) {
                        ForEach(uniqueRight.sorted(), id: \.self) { note in
                            Text(note)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(.indigo.opacity(0.12))
                                .foregroundStyle(.indigo)
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            if shared.isEmpty && uniqueLeft.isEmpty && uniqueRight.isEmpty {
                Text("No notes to compare")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private func colorFor(_ perfume: Perfume) -> Color {
        let hash = abs(perfume.name.hashValue)
        let colors: [Color] = [.purple, .indigo, .blue, .teal, .orange, .pink]
        return colors[hash % colors.count]
    }
}

struct CompareRow: View {
    let label: String
    let leftValue: String
    let rightValue: String

    private var match: Bool { leftValue == rightValue }

    var body: some View {
        HStack {
            Text(leftValue)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)

            VStack(spacing: 2) {
                Image(systemName: match ? "equal.circle.fill" : "circle.dotted")
                    .font(.caption2)
                    .foregroundStyle(match ? .green : .secondary)
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
            .frame(width: 80)

            Text(rightValue)
                .font(.subheadline)
                .frame(maxWidth: .infinity)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}

struct CompareNotesRow: View {
    let label: String
    let leftNotes: [String]
    let rightNotes: [String]
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Text(label)
                .font(.caption.bold())
                .foregroundStyle(color)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 4) {
                    if leftNotes.isEmpty {
                        Text("—")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        ForEach(leftNotes, id: \.self) { note in
                            let isShared = rightNotes.contains(note)
                            Text(note)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(isShared ? .green.opacity(0.12) : color.opacity(0.1))
                                .foregroundStyle(isShared ? .green : color)
                                .clipShape(Capsule())
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                Divider()

                VStack(alignment: .leading, spacing: 4) {
                    if rightNotes.isEmpty {
                        Text("—")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    } else {
                        ForEach(rightNotes, id: \.self) { note in
                            let isShared = leftNotes.contains(note)
                            Text(note)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(isShared ? .green.opacity(0.12) : color.opacity(0.1))
                                .foregroundStyle(isShared ? .green : color)
                                .clipShape(Capsule())
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }
}

struct ComparePerfumePicker: View {
    let perfumes: [Perfume]
    let excludedPerfume: Perfume?
    @Binding var selection: Perfume?
    @Environment(\.dismiss) private var dismiss
    @State private var searchText: String = ""

    private var filtered: [Perfume] {
        let available = perfumes.filter { $0.id != excludedPerfume?.id }
        if searchText.isEmpty { return available }
        return available.filter {
            $0.name.localizedStandardContains(searchText) ||
            $0.brand.localizedStandardContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            List(filtered) { perfume in
                Button {
                    selection = perfume
                    dismiss()
                } label: {
                    HStack(spacing: 12) {
                        Circle()
                            .fill(colorFor(perfume).gradient)
                            .frame(width: 40, height: 40)
                            .overlay {
                                Image(systemName: "drop.fill")
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.5))
                            }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(perfume.name)
                                .font(.subheadline.bold())
                                .foregroundStyle(.primary)
                            Text(perfume.brand)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if perfume.id == selection?.id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.tint)
                        }
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search perfumes...")
            .navigationTitle("Select Perfume")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func colorFor(_ perfume: Perfume) -> Color {
        let hash = abs(perfume.name.hashValue)
        let colors: [Color] = [.purple, .indigo, .blue, .teal, .orange, .pink]
        return colors[hash % colors.count]
    }
}
