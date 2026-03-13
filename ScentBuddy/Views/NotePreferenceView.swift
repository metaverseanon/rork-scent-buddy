import SwiftUI

struct NotePreferenceView: View {
    @State private var selectedNotes: Set<String> = []
    @Environment(\.dismiss) private var dismiss

    private let noteCategories: [(String, String, Color, [String])] = [
        ("Citrus & Fresh", "sun.max.fill", .yellow, [
            "Bergamot", "Lemon", "Orange", "Grapefruit", "Lime", "Mandarin", "Neroli", "Green Tea", "Mint", "Aquatic"
        ]),
        ("Floral", "leaf.fill", .pink, [
            "Rose", "Jasmine", "Lavender", "Iris", "Violet", "Peony", "Lily", "Tuberose", "Magnolia", "Orange Blossom"
        ]),
        ("Woody", "tree.fill", .brown, [
            "Sandalwood", "Cedar", "Vetiver", "Patchouli", "Oud", "Birch", "Cypress", "Guaiac Wood"
        ]),
        ("Oriental & Warm", "flame.fill", .orange, [
            "Vanilla", "Amber", "Tonka Bean", "Benzoin", "Caramel", "Incense", "Musk", "Tobacco", "Leather"
        ]),
        ("Spicy", "sparkle", .red, [
            "Pepper", "Cardamom", "Cinnamon", "Ginger", "Saffron", "Nutmeg"
        ]),
        ("Fruity & Gourmand", "fork.knife", .purple, [
            "Apple", "Peach", "Raspberry", "Blackcurrant", "Fig", "Coconut", "Coffee", "Chocolate"
        ]),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection

                    ForEach(noteCategories, id: \.0) { category, icon, color, notes in
                        categorySection(title: category, icon: icon, color: color, notes: notes)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .background(AppearanceManager.shared.theme.backgroundColor)
            .safeAreaInset(edge: .bottom) {
                continueButton
            }
            .navigationTitle("Your Scent Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Skip") {
                        OnboardingManager.shared.completeOnboarding(with: [])
                        dismiss()
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(spacing: 12) {
            Image(systemName: "wand.and.stars")
                .font(.system(size: 36))
                .foregroundStyle(.orange)

            Text("Pick notes you love")
                .font(.title2.bold())

            Text("This helps us recommend fragrances even before you build your collection.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)

            if !selectedNotes.isEmpty {
                Text("\(selectedNotes.count) selected")
                    .font(.caption.bold())
                    .foregroundStyle(.tint)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(.tint.opacity(0.1))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 16)
    }

    private func categorySection(title: String, icon: String, color: Color, notes: [String]) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.subheadline)
                    .foregroundStyle(color)
                Text(title)
                    .font(.subheadline.bold())
            }

            FlowLayout(spacing: 8) {
                ForEach(notes, id: \.self) { note in
                    let isSelected = selectedNotes.contains(note)
                    Button {
                        withAnimation(.snappy) {
                            if isSelected {
                                selectedNotes.remove(note)
                            } else {
                                selectedNotes.insert(note)
                            }
                        }
                    } label: {
                        Text(note)
                            .font(.subheadline)
                            .padding(.horizontal, 14)
                            .padding(.vertical, 8)
                            .background(isSelected ? color.opacity(0.15) : Color(.tertiarySystemFill))
                            .foregroundStyle(isSelected ? color : .primary)
                            .clipShape(Capsule())
                            .overlay {
                                if isSelected {
                                    Capsule()
                                        .strokeBorder(color.opacity(0.4), lineWidth: 1)
                                }
                            }
                    }
                    .sensoryFeedback(.selection, trigger: isSelected)
                }
            }
        }
        .padding(16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
    }

    private var continueButton: some View {
        Button {
            OnboardingManager.shared.completeOnboarding(with: Array(selectedNotes))
            dismiss()
        } label: {
            Text(selectedNotes.isEmpty ? "Continue without preferences" : "Continue with \(selectedNotes.count) notes")
                .font(.headline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(selectedNotes.isEmpty ? Color(.tertiarySystemFill) : Color.accentColor)
                .foregroundStyle(selectedNotes.isEmpty ? Color.primary : Color.white)
                .clipShape(.rect(cornerRadius: 16))
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .background(.ultraThinMaterial)
    }
}
