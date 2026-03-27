import Foundation

nonisolated enum PerfumeConstants: Sendable {
    static let concentrations = [
        "Eau de Cologne",
        "Eau de Toilette",
        "Eau de Parfum",
        "Parfum",
        "Extrait de Parfum"
    ]

    static let seasons = [
        "All Seasons",
        "Spring",
        "Summer",
        "Fall",
        "Winter"
    ]

    static let occasions = [
        "Everyday",
        "Office",
        "Date Night",
        "Formal Event",
        "Casual",
        "Sport",
        "Evening Out",
        "Special Occasion"
    ]

    static let commonNotes = [
        "Bergamot", "Lemon", "Orange", "Grapefruit", "Lime", "Mandarin",
        "Rose", "Jasmine", "Lavender", "Iris", "Violet", "Peony", "Lily",
        "Sandalwood", "Cedar", "Vetiver", "Patchouli", "Oud", "Musk",
        "Vanilla", "Amber", "Tonka Bean", "Benzoin", "Caramel",
        "Pepper", "Cardamom", "Cinnamon", "Ginger", "Saffron",
        "Apple", "Peach", "Raspberry", "Blackcurrant", "Fig", "Coconut",
        "Tobacco", "Leather", "Incense", "Coffee", "Chocolate",
        "Sea Salt", "Aquatic", "Ozonic", "Green Tea", "Mint"
    ]

    static let priorities = ["Low", "Medium", "High"]
}
