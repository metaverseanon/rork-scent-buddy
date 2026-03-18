import SwiftUI

struct TasteProfileResultView: View {
    let profile: TasteProfile
    let isOnboarding: Bool
    let onDone: () -> Void

    @State private var appearAnimated: Bool = false
    @State private var showNotes: Bool = false
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileHero
                traitsSection
                notesSection
                familyBreakdown
                doneButton
            }
            .padding(.horizontal)
            .padding(.bottom, 40)
        }
        .background(theme.backgroundColor.ignoresSafeArea())
        .navigationBarBackButtonHidden()
        .task {
            withAnimation(.spring(duration: 0.8, bounce: 0.2)) {
                appearAnimated = true
            }
            try? await Task.sleep(for: .seconds(0.5))
            withAnimation(.spring(duration: 0.6)) {
                showNotes = true
            }
        }
    }

    private var profileHero: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.4), .pink.opacity(0.2), .clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)
                    .scaleEffect(appearAnimated ? 1.0 : 0.5)
                    .opacity(appearAnimated ? 1 : 0)

                Text(profile.profileEmoji)
                    .font(.system(size: 72))
                    .scaleEffect(appearAnimated ? 1.0 : 0.3)
                    .opacity(appearAnimated ? 1 : 0)
            }

            VStack(spacing: 6) {
                Text("You are")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .opacity(appearAnimated ? 1 : 0)

                Text(profile.profileName)
                    .font(.largeTitle.bold())
                    .opacity(appearAnimated ? 1 : 0)
                    .offset(y: appearAnimated ? 0 : 10)

                Text(familyDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                    .opacity(appearAnimated ? 1 : 0)
                    .offset(y: appearAnimated ? 0 : 8)
            }
        }
        .padding(.top, 24)
    }

    private var traitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .foregroundStyle(.orange)
                Text("Your Traits")
                    .font(.headline)
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(profile.topTraits, id: \.self) { trait in
                        Text(trait)
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(
                                LinearGradient(
                                    colors: traitGradient(for: trait),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
        .padding(16)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 20))
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 16)
    }

    private var notesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "nose")
                    .foregroundStyle(.pink)
                Text("Notes You'll Love")
                    .font(.headline)
            }

            FlowLayout(spacing: 8) {
                ForEach(Array(profile.preferredNotes.enumerated()), id: \.offset) { index, note in
                    Text(note)
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(noteColor(for: note).opacity(0.12))
                        .foregroundStyle(noteColor(for: note))
                        .clipShape(Capsule())
                        .opacity(showNotes ? 1 : 0)
                        .scaleEffect(showNotes ? 1 : 0.8)
                        .animation(
                            .spring(duration: 0.4, bounce: 0.3).delay(Double(index) * 0.05),
                            value: showNotes
                        )
                }
            }
        }
        .padding(16)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 20))
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 20)
    }

    private var familyBreakdown: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.purple)
                Text("Your Scent DNA")
                    .font(.headline)
            }

            VStack(spacing: 8) {
                let families = computeFamilyBreakdown()
                ForEach(families, id: \.0) { family, percentage in
                    HStack(spacing: 12) {
                        Text(familyEmoji(for: family))
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text(family)
                                    .font(.subheadline.bold())
                                Spacer()
                                Text("\(percentage)%")
                                    .font(.caption.bold())
                                    .foregroundStyle(.secondary)
                            }

                            GeometryReader { geo in
                                ZStack(alignment: .leading) {
                                    Capsule()
                                        .fill(Color(.tertiarySystemFill))
                                    Capsule()
                                        .fill(familyBarColor(for: family))
                                        .frame(width: geo.size.width * Double(percentage) / 100.0)
                                }
                            }
                            .frame(height: 8)
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 20))
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 24)
    }

    private var doneButton: some View {
        Button {
            onDone()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: isOnboarding ? "arrow.right" : "checkmark")
                    .font(.subheadline.bold())
                Text(isOnboarding ? "Start Exploring" : "Done")
                    .font(.headline)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
            )
            .foregroundStyle(.white)
            .clipShape(.rect(cornerRadius: 16))
        }
        .sensoryFeedback(.success, trigger: true)
        .opacity(appearAnimated ? 1 : 0)
        .offset(y: appearAnimated ? 0 : 16)
    }

    private var familyDescription: String {
        switch profile.scentFamily {
        case "Fresh": return "You're drawn to clean, invigorating scents that feel like a breath of fresh air."
        case "Floral": return "You gravitate toward romantic, elegant florals that feel timeless and refined."
        case "Woody": return "You love grounded, earthy scents that feel authentic and deeply satisfying."
        case "Oriental": return "You're captivated by rich, warm scents with depth and mystery."
        case "Gourmand": return "You crave sweet, indulgent scents that wrap around you like a treat."
        case "Fruity": return "You light up around vibrant, playful scents bursting with energy."
        default: return "Your taste is unique and eclectic — you love exploring across all scent families."
        }
    }

    private func computeFamilyBreakdown() -> [(String, Int)] {
        var counts: [String: Int] = [:]
        let questions = TasteQuizData.questions
        for question in questions {
            if let answerId = profile.quizAnswers[question.id],
               let option = question.options.first(where: { $0.id == answerId }) {
                counts[option.family, default: 0] += 1
            }
        }
        let total = max(counts.values.reduce(0, +), 1)
        return counts
            .map { ($0.key, Int(Double($0.value) / Double(total) * 100)) }
            .sorted { $0.1 > $1.1 }
    }

    private func traitGradient(for trait: String) -> [Color] {
        switch trait.lowercased() {
        case "fresh", "clean", "airy", "crisp": return [.cyan, .blue]
        case "warm", "cozy", "nostalgic": return [.orange, .red]
        case "romantic", "elegant", "soft", "dreamy", "chic", "sophisticated": return [.pink, .purple]
        case "bold", "mysterious", "dramatic", "intense": return [Color(white: 0.25), .indigo]
        case "natural", "earthy", "grounded", "authentic", "rugged", "noble": return [.green, .brown]
        case "exotic", "opulent", "rich", "spicy": return [.orange, .purple]
        case "playful", "fruity", "vibrant", "youthful", "radiant": return [.pink, .orange]
        case "gourmand", "seductive", "tropical", "carefree": return [.brown, .orange]
        default: return [.orange, .pink]
        }
    }

    private func noteColor(for note: String) -> Color {
        let citrus = ["Bergamot", "Lemon", "Orange", "Grapefruit", "Lime", "Mandarin", "Neroli"]
        let floral = ["Rose", "Jasmine", "Iris", "Violet", "Peony", "Lily", "Magnolia", "Orange Blossom", "Lavender", "Lily of the Valley", "Heliotrope", "Tuberose", "Frangipani", "Ylang-Ylang", "Tiare"]
        let woody = ["Sandalwood", "Cedar", "Vetiver", "Patchouli", "Oud", "Birch", "Cypress", "Pine", "Guaiac Wood", "Oakmoss", "Fir Balsam"]
        let warm = ["Vanilla", "Amber", "Tonka Bean", "Benzoin", "Caramel", "Incense", "Musk"]
        let spicy = ["Pepper", "Cardamom", "Cinnamon", "Ginger", "Saffron", "Nutmeg"]

        if citrus.contains(note) { return .yellow }
        if floral.contains(note) { return .pink }
        if woody.contains(note) { return .brown }
        if warm.contains(note) { return .orange }
        if spicy.contains(note) { return .red }
        return .purple
    }

    private func familyEmoji(for family: String) -> String {
        TasteQuizData.profileMap[family]?.emoji ?? "🧭"
    }

    private func familyBarColor(for family: String) -> LinearGradient {
        switch family {
        case "Fresh": return LinearGradient(colors: [.cyan, .blue], startPoint: .leading, endPoint: .trailing)
        case "Floral": return LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing)
        case "Woody": return LinearGradient(colors: [.brown, .green], startPoint: .leading, endPoint: .trailing)
        case "Oriental": return LinearGradient(colors: [.orange, .red], startPoint: .leading, endPoint: .trailing)
        case "Gourmand": return LinearGradient(colors: [.brown, .orange], startPoint: .leading, endPoint: .trailing)
        case "Fruity": return LinearGradient(colors: [.pink, .orange], startPoint: .leading, endPoint: .trailing)
        default: return LinearGradient(colors: [.gray, .secondary], startPoint: .leading, endPoint: .trailing)
        }
    }
}
