import SwiftUI

struct TasteProfileView: View {
    @State private var onboardingManager = OnboardingManager.shared
    @State private var showQuiz: Bool = false
    @State private var appearAnimated: Bool = false
    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        ScrollView {
            if onboardingManager.hasTasteProfile {
                profileContent
            } else {
                emptyState
            }
        }
        .background(theme.backgroundColor.ignoresSafeArea())
        .navigationTitle("Taste Profile")
        .toolbar {
            if onboardingManager.hasTasteProfile {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showQuiz = true
                    } label: {
                        Label("Retake", systemImage: "arrow.counterclockwise")
                            .font(.subheadline)
                    }
                }
            }
        }
        .fullScreenCover(isPresented: $showQuiz) {
            TasteQuizView(isOnboarding: false) { _ in
                showQuiz = false
            }
        }
        .task {
            withAnimation(.spring(duration: 0.6)) {
                appearAnimated = true
            }
        }
    }

    private var profileContent: some View {
        let profile = onboardingManager.tasteProfile
        return VStack(spacing: 20) {
            heroCard(profile)
            traitsCard(profile)
            notesCard(profile)
            dnaCard(profile)

            if let date = profile.completedAt {
                Text("Completed \(date.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.top, 4)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 32)
    }

    private func heroCard(_ profile: TasteProfile) -> some View {
        VStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.35), .pink.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 15,
                            endRadius: 80
                        )
                    )
                    .frame(width: 160, height: 160)

                Text(profile.profileEmoji)
                    .font(.system(size: 64))
            }
            .scaleEffect(appearAnimated ? 1 : 0.7)
            .opacity(appearAnimated ? 1 : 0)

            Text(profile.profileName)
                .font(.title.bold())

            Text(familyDescription(for: profile.scentFamily))
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.caption)
                Text(profile.scentFamily)
                    .font(.subheadline.bold())
            }
            .foregroundStyle(.orange)
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(.orange.opacity(0.1))
            .clipShape(Capsule())
        }
        .padding(.vertical, 20)
        .frame(maxWidth: .infinity)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 24))
        .padding(.top, 8)
    }

    private func traitsCard(_ profile: TasteProfile) -> some View {
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
    }

    private func notesCard(_ profile: TasteProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "nose")
                    .foregroundStyle(.pink)
                Text("Notes You Love")
                    .font(.headline)
            }

            FlowLayout(spacing: 8) {
                ForEach(profile.preferredNotes, id: \.self) { note in
                    Text(note)
                        .font(.subheadline)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 8)
                        .background(noteColor(for: note).opacity(0.12))
                        .foregroundStyle(noteColor(for: note))
                        .clipShape(Capsule())
                }
            }
        }
        .padding(16)
        .background(theme.cardColor)
        .clipShape(.rect(cornerRadius: 20))
    }

    private func dnaCard(_ profile: TasteProfile) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                Image(systemName: "chart.pie.fill")
                    .foregroundStyle(.purple)
                Text("Scent DNA")
                    .font(.headline)
            }

            let families = computeFamilyBreakdown(profile)
            VStack(spacing: 8) {
                ForEach(families, id: \.0) { family, percentage in
                    HStack(spacing: 12) {
                        Text(TasteQuizData.profileMap[family]?.emoji ?? "🧭")
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
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.3), .pink.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 100
                        )
                    )
                    .frame(width: 200, height: 200)

                Image(systemName: "wand.and.stars")
                    .font(.system(size: 56))
                    .foregroundStyle(.orange)
                    .symbolEffect(.pulse, options: .repeating)
            }

            VStack(spacing: 10) {
                Text("Discover Your Scent Style")
                    .font(.title2.bold())

                Text("Take a quick 5-question quiz to find out what fragrance families and notes match your personality.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                showQuiz = true
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "play.fill")
                        .font(.subheadline)
                    Text("Start the Quiz")
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
            .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }

    private func familyDescription(for family: String) -> String {
        switch family {
        case "Fresh": return "You're drawn to clean, invigorating scents that feel like a breath of fresh air."
        case "Floral": return "You gravitate toward romantic, elegant florals that feel timeless and refined."
        case "Woody": return "You love grounded, earthy scents that feel authentic and deeply satisfying."
        case "Oriental": return "You're captivated by rich, warm scents with depth and mystery."
        case "Gourmand": return "You crave sweet, indulgent scents that wrap around you like a treat."
        case "Fruity": return "You light up around vibrant, playful scents bursting with energy."
        default: return "Your taste is unique and eclectic."
        }
    }

    private func computeFamilyBreakdown(_ profile: TasteProfile) -> [(String, Int)] {
        var counts: [String: Int] = [:]
        for question in TasteQuizData.questions {
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
        default: return [.orange, .pink]
        }
    }

    private func noteColor(for note: String) -> Color {
        let citrus = ["Bergamot", "Lemon", "Orange", "Grapefruit", "Lime", "Mandarin", "Neroli"]
        let floral = ["Rose", "Jasmine", "Iris", "Violet", "Peony", "Lily", "Magnolia", "Orange Blossom", "Lavender"]
        let woody = ["Sandalwood", "Cedar", "Vetiver", "Patchouli", "Oud", "Birch", "Cypress", "Pine", "Guaiac Wood"]
        let warm = ["Vanilla", "Amber", "Tonka Bean", "Benzoin", "Caramel", "Incense", "Musk"]
        let spicy = ["Pepper", "Cardamom", "Cinnamon", "Ginger", "Saffron", "Nutmeg"]

        if citrus.contains(note) { return .yellow }
        if floral.contains(note) { return .pink }
        if woody.contains(note) { return .brown }
        if warm.contains(note) { return .orange }
        if spicy.contains(note) { return .red }
        return .purple
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
