import Foundation

nonisolated struct TasteProfile: Codable, Sendable {
    var scentFamily: String
    var topTraits: [String]
    var preferredNotes: [String]
    var quizAnswers: [String: String]
    var profileName: String
    var profileEmoji: String
    var completedAt: Date?

    init(
        scentFamily: String = "",
        topTraits: [String] = [],
        preferredNotes: [String] = [],
        quizAnswers: [String: String] = [:],
        profileName: String = "",
        profileEmoji: String = "",
        completedAt: Date? = nil
    ) {
        self.scentFamily = scentFamily
        self.topTraits = topTraits
        self.preferredNotes = preferredNotes
        self.quizAnswers = quizAnswers
        self.profileName = profileName
        self.profileEmoji = profileEmoji
        self.completedAt = completedAt
    }
}

nonisolated struct QuizQuestion: Sendable {
    let id: String
    let prompt: String
    let subtitle: String
    let options: [QuizOption]
    let icon: String
}

nonisolated struct QuizOption: Identifiable, Sendable {
    let id: String
    let title: String
    let description: String
    let emoji: String
    let associatedNotes: [String]
    let traits: [String]
    let family: String
}

nonisolated enum TasteQuizData: Sendable {
    static let questions: [QuizQuestion] = [
        QuizQuestion(
            id: "morning",
            prompt: "It's a fresh morning. What draws you in?",
            subtitle: "Pick the vibe that speaks to you",
            options: [
                QuizOption(id: "morning_citrus", title: "Citrus Burst", description: "Sparkling lemon zest on a sundrenched terrace", emoji: "🍋", associatedNotes: ["Bergamot", "Lemon", "Grapefruit", "Mandarin", "Orange", "Lime", "Neroli"], traits: ["Fresh", "Energetic"], family: "Fresh"),
                QuizOption(id: "morning_green", title: "Dewy Garden", description: "Wet grass and green leaves after the rain", emoji: "🌿", associatedNotes: ["Green Tea", "Mint", "Violet Leaf", "Galbanum", "Basil"], traits: ["Natural", "Clean"], family: "Fresh"),
                QuizOption(id: "morning_floral", title: "Flower Market", description: "Armfuls of roses and jasmine still with the dew", emoji: "💐", associatedNotes: ["Rose", "Jasmine", "Peony", "Lily", "Magnolia"], traits: ["Romantic", "Elegant"], family: "Floral"),
                QuizOption(id: "morning_ocean", title: "Ocean Breeze", description: "Salt air and cool mist off the waves", emoji: "🌊", associatedNotes: ["Aquatic", "Sea Salt", "Ozonic", "Ambergris"], traits: ["Airy", "Crisp"], family: "Fresh"),
            ],
            icon: "sunrise.fill"
        ),
        QuizQuestion(
            id: "evening",
            prompt: "The evening is yours. What's your mood?",
            subtitle: "Think about how you want to feel",
            options: [
                QuizOption(id: "evening_warm", title: "Warm Embrace", description: "Cashmere sweater by a crackling fireplace", emoji: "🔥", associatedNotes: ["Vanilla", "Amber", "Tonka Bean", "Benzoin", "Caramel"], traits: ["Warm", "Cozy"], family: "Oriental"),
                QuizOption(id: "evening_dark", title: "Midnight Leather", description: "A dimly lit jazz bar, smooth whiskey in hand", emoji: "🎷", associatedNotes: ["Leather", "Tobacco", "Oud", "Whiskey", "Smoke"], traits: ["Bold", "Mysterious"], family: "Woody"),
                QuizOption(id: "evening_sweet", title: "Sweet Indulgence", description: "Rich chocolate and espresso after dinner", emoji: "🍫", associatedNotes: ["Coffee", "Chocolate", "Caramel", "Praline", "Rum"], traits: ["Gourmand", "Seductive"], family: "Gourmand"),
                QuizOption(id: "evening_spice", title: "Spice Bazaar", description: "Saffron threads and cinnamon in a Moroccan souk", emoji: "🌶️", associatedNotes: ["Saffron", "Cardamom", "Cinnamon", "Pepper", "Nutmeg", "Ginger"], traits: ["Spicy", "Exotic"], family: "Oriental"),
            ],
            icon: "moon.stars.fill"
        ),
        QuizQuestion(
            id: "forest",
            prompt: "You're walking through a forest. What captivates you?",
            subtitle: "Close your eyes and imagine",
            options: [
                QuizOption(id: "forest_cedar", title: "Ancient Trees", description: "Towering cedars with sunlight filtering through", emoji: "🌲", associatedNotes: ["Cedar", "Cypress", "Pine", "Fir Balsam"], traits: ["Grounded", "Noble"], family: "Woody"),
                QuizOption(id: "forest_earth", title: "Forest Floor", description: "Damp earth, moss, and wild mushrooms", emoji: "🍄", associatedNotes: ["Vetiver", "Patchouli", "Oakmoss", "Birch", "Earthy"], traits: ["Earthy", "Natural"], family: "Woody"),
                QuizOption(id: "forest_flowers", title: "Wildflower Clearing", description: "A sunlit meadow of iris, lavender, and violets", emoji: "🦋", associatedNotes: ["Iris", "Lavender", "Violet", "Heliotrope", "Lily of the Valley"], traits: ["Soft", "Dreamy"], family: "Floral"),
                QuizOption(id: "forest_fruit", title: "Berry Thicket", description: "Wild raspberries and blackcurrants off the vine", emoji: "🫐", associatedNotes: ["Raspberry", "Blackcurrant", "Fig", "Apple", "Peach", "Plum"], traits: ["Playful", "Fruity"], family: "Fruity"),
            ],
            icon: "tree.fill"
        ),
        QuizQuestion(
            id: "travel",
            prompt: "Dream destination — where are you headed?",
            subtitle: "Where does your nose want to go?",
            options: [
                QuizOption(id: "travel_paris", title: "Parisian Atelier", description: "Powder, suede gloves, and violet pastilles", emoji: "🗼", associatedNotes: ["Iris", "Violet", "Musk", "Powdery", "Suede"], traits: ["Sophisticated", "Chic"], family: "Floral"),
                QuizOption(id: "travel_arabian", title: "Arabian Nights", description: "Oud smoke, rose water, and golden incense", emoji: "🕌", associatedNotes: ["Oud", "Incense", "Rose", "Amber", "Saffron"], traits: ["Opulent", "Rich"], family: "Oriental"),
                QuizOption(id: "travel_tropical", title: "Tropical Island", description: "Coconut, tiare flower, and warm sand", emoji: "🏝️", associatedNotes: ["Coconut", "Tiare", "Frangipani", "Ylang-Ylang", "Mango"], traits: ["Tropical", "Carefree"], family: "Fresh"),
                QuizOption(id: "travel_cabin", title: "Mountain Lodge", description: "Sandalwood fire, aged leather, and pine air", emoji: "🏔️", associatedNotes: ["Sandalwood", "Leather", "Pine", "Smoke", "Guaiac Wood"], traits: ["Rugged", "Authentic"], family: "Woody"),
            ],
            icon: "airplane.departure"
        ),
        QuizQuestion(
            id: "season",
            prompt: "Your favorite season to get dressed up?",
            subtitle: "When do you feel most like yourself?",
            options: [
                QuizOption(id: "season_spring", title: "Spring Awakening", description: "Fresh blooms, light fabrics, first warm breeze", emoji: "🌸", associatedNotes: ["Orange Blossom", "Peony", "Lily", "Green Tea", "Bergamot"], traits: ["Fresh", "Youthful"], family: "Floral"),
                QuizOption(id: "season_summer", title: "Summer Heat", description: "Sun-kissed skin, cold drinks, late sunsets", emoji: "☀️", associatedNotes: ["Coconut", "Neroli", "Aquatic", "Grapefruit", "White Musk"], traits: ["Vibrant", "Radiant"], family: "Fresh"),
                QuizOption(id: "season_fall", title: "Autumn Leaves", description: "Layered knits, warm spices, golden hour", emoji: "🍂", associatedNotes: ["Cinnamon", "Cardamom", "Tonka Bean", "Amber", "Apple"], traits: ["Warm", "Nostalgic"], family: "Oriental"),
                QuizOption(id: "season_winter", title: "Winter Night", description: "Velvet, candlelight, and heavy silk", emoji: "❄️", associatedNotes: ["Oud", "Vanilla", "Incense", "Tobacco", "Benzoin"], traits: ["Dramatic", "Intense"], family: "Oriental"),
            ],
            icon: "calendar"
        ),
    ]

    static let profileMap: [String: (name: String, emoji: String)] = [
        "Fresh": (name: "The Breeze", emoji: "🌬️"),
        "Floral": (name: "The Bloom", emoji: "🌹"),
        "Woody": (name: "The Root", emoji: "🌳"),
        "Oriental": (name: "The Ember", emoji: "✨"),
        "Gourmand": (name: "The Indulger", emoji: "🍯"),
        "Fruity": (name: "The Vibrant", emoji: "🍑"),
    ]
}
