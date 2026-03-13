import Foundation

struct RecommendationService {
    func generateRecommendations(from perfumes: [Perfume], wearEntries: [WearEntry] = []) -> [RecommendedPerfume] {
        let notePrefs = OnboardingManager.shared.notePreferences.favoriteNotes

        if perfumes.isEmpty && notePrefs.isEmpty {
            return rotateResults(defaultRecommendations)
        }

        let noteProfile = buildNoteProfile(from: perfumes, wearEntries: wearEntries, preferredNotes: notePrefs)

        guard !noteProfile.isEmpty else { return rotateResults(defaultRecommendations) }

        let topNoteNames = noteProfile
            .sorted { $0.value > $1.value }
            .prefix(5)
            .map { $0.key.capitalized }

        var recommendations: [RecommendedPerfume] = []

        let families = categorizeFavorites(noteProfile: noteProfile)
        for family in families.prefix(3) {
            let recs = buildFamilyRecommendations(family: family, noteProfile: noteProfile, topNotes: topNoteNames)
            recommendations.append(contentsOf: recs)
        }

        if recommendations.count < 5 {
            let fallback = buildGenericRecommendations(noteProfile: noteProfile, topNotes: topNoteNames)
            for rec in fallback {
                if !recommendations.contains(where: { $0.name == rec.name }) {
                    recommendations.append(rec)
                }
            }
        }

        return rotateResults(Array(recommendations.prefix(10)))
    }

    private func rotateResults(_ recs: [RecommendedPerfume]) -> [RecommendedPerfume] {
        guard recs.count > 1 else { return recs }
        let hourBlock = Calendar.current.component(.hour, from: Date()) / 3
        let daySeed = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        let seed = daySeed * 7 + hourBlock
        var shuffled = recs
        var s = seed
        for i in stride(from: shuffled.count - 1, through: 1, by: -1) {
            s = (s &* 16807 &+ 0) % 2147483647
            let j = abs(s) % (i + 1)
            shuffled.swapAt(i, j)
        }
        return shuffled
    }

    private func buildNoteProfile(from perfumes: [Perfume], wearEntries: [WearEntry], preferredNotes: [String]) -> [String: Double] {
        var noteScores: [String: Double] = [:]

        for note in preferredNotes {
            noteScores[note.lowercased(), default: 0] += 3.0
        }

        var wearCounts: [String: Int] = [:]
        for entry in wearEntries {
            let key = "\(entry.perfumeName.lowercased())|\(entry.perfumeBrand.lowercased())"
            wearCounts[key, default: 0] += 1
        }

        for perfume in perfumes {
            let key = "\(perfume.name.lowercased())|\(perfume.brand.lowercased())"
            let wearCount = wearCounts[key] ?? 0

            let ratingMultiplier = perfume.rating > 0 ? Double(perfume.rating) / 3.0 : 1.0
            let favoriteBonus: Double = perfume.isFavorite ? 1.5 : 1.0
            let wearBonus: Double = 1.0 + min(Double(wearCount) * 0.15, 1.5)
            let weight = ratingMultiplier * favoriteBonus * wearBonus

            for note in perfume.topNotes {
                noteScores[note.lowercased(), default: 0] += 2.0 * weight
            }
            for note in perfume.heartNotes {
                noteScores[note.lowercased(), default: 0] += 3.0 * weight
            }
            for note in perfume.baseNotes {
                noteScores[note.lowercased(), default: 0] += 4.0 * weight
            }
        }

        return noteScores
    }

    private func categorizeFavorites(noteProfile: [String: Double]) -> [String] {
        let woodyNotes: Set<String> = ["sandalwood", "cedar", "vetiver", "patchouli", "oud", "guaiac wood", "birch", "cypress"]
        let floralNotes: Set<String> = ["rose", "jasmine", "iris", "violet", "peony", "lily", "tuberose", "magnolia", "orange blossom"]
        let freshNotes: Set<String> = ["bergamot", "lemon", "grapefruit", "mandarin", "lime", "neroli", "mint", "aquatic", "green tea"]
        let orientalNotes: Set<String> = ["vanilla", "amber", "tonka bean", "benzoin", "incense", "musk", "saffron", "cinnamon", "cardamom"]
        let fruityNotes: Set<String> = ["apple", "peach", "raspberry", "blackcurrant", "fig", "coconut", "coffee", "chocolate"]

        let families: [(String, Set<String>)] = [
            ("woody", woodyNotes), ("floral", floralNotes), ("fresh", freshNotes),
            ("oriental", orientalNotes), ("fruity", fruityNotes)
        ]

        let scored = families.map { name, notes -> (String, Double) in
            let score = notes.reduce(0.0) { $0 + (noteProfile[$1] ?? 0) }
            return (name, score)
        }
        .sorted { $0.1 > $1.1 }
        .filter { $0.1 > 0 }

        return scored.map(\.0)
    }

    private func buildFamilyRecommendations(family: String, noteProfile: [String: Double], topNotes: [String]) -> [RecommendedPerfume] {
        let familyRecs: [String: [(String, String, String, [String])]] = [
            "woody": [
                ("Santal 33", "Le Labo", "Eau de Parfum", ["Sandalwood", "Cedar", "Cardamom", "Iris", "Violet", "Leather"]),
                ("Tam Dao", "Diptyque", "Eau de Parfum", ["Sandalwood", "Cedar", "Musk", "Rosewood", "Cypress"]),
                ("Ombré Leather", "Tom Ford", "Eau de Parfum", ["Leather", "Patchouli", "Vetiver", "Jasmine", "Cardamom"]),
                ("Wonderwood", "Comme des Garçons", "Eau de Parfum", ["Cedar", "Sandalwood", "Vetiver", "Pepper", "Oud"]),
                ("Woody Mood", "Maison Tahité", "Eau de Parfum", ["Sandalwood", "Patchouli", "Vanilla", "Amber", "Musk"]),
            ],
            "floral": [
                ("Portrait of a Lady", "Frederic Malle", "Eau de Parfum", ["Rose", "Patchouli", "Sandalwood", "Musk", "Frankincense"]),
                ("Delina", "Parfums de Marly", "Eau de Parfum", ["Rose", "Peony", "Lychee", "Vanilla", "Musk"]),
                ("Rose 31", "Le Labo", "Eau de Parfum", ["Rose", "Cedar", "Cumin", "Amber", "Musk"]),
                ("Miss Dior Blooming Bouquet", "Dior", "Eau de Toilette", ["Peony", "Rose", "White Musk", "Apricot"]),
                ("Gucci Bloom", "Gucci", "Eau de Parfum", ["Tuberose", "Jasmine", "Rangoon Creeper"]),
            ],
            "fresh": [
                ("Acqua di Gio Profumo", "Giorgio Armani", "Eau de Parfum", ["Bergamot", "Aquatic", "Amber", "Patchouli", "Incense"]),
                ("Light Blue", "Dolce & Gabbana", "Eau de Toilette", ["Lemon", "Apple", "Cedar", "Musk", "Bamboo"]),
                ("Neroli Portofino", "Tom Ford", "Eau de Parfum", ["Neroli", "Bergamot", "Lemon", "Amber", "Musk"]),
                ("CK One", "Calvin Klein", "Eau de Toilette", ["Bergamot", "Lemon", "Green Tea", "Rose", "Musk"]),
                ("Green Irish Tweed", "Creed", "Eau de Parfum", ["Lemon", "Verbena", "Iris", "Violet Leaf", "Sandalwood"]),
            ],
            "oriental": [
                ("Baccarat Rouge 540", "Maison Francis Kurkdjian", "Eau de Parfum", ["Saffron", "Jasmine", "Amber", "Cedar", "Musk"]),
                ("By the Fireplace", "Maison Margiela", "Eau de Toilette", ["Vanilla", "Cashmeran", "Chestnut", "Guaiac Wood"]),
                ("Tobacco Vanille", "Tom Ford", "Eau de Parfum", ["Tobacco", "Vanilla", "Tonka Bean", "Cacao", "Ginger"]),
                ("Spicebomb Extreme", "Viktor & Rolf", "Eau de Parfum", ["Tobacco", "Vanilla", "Lavender", "Cinnamon"]),
                ("Jazz Club", "Maison Margiela", "Eau de Toilette", ["Rum", "Tobacco", "Vanilla", "Vetiver", "Tonka Bean"]),
            ],
            "fruity": [
                ("Aventus", "Creed", "Eau de Parfum", ["Apple", "Bergamot", "Patchouli", "Musk", "Vanilla"]),
                ("Lost Cherry", "Tom Ford", "Eau de Parfum", ["Cherry", "Almond", "Vanilla", "Tonka Bean", "Cedar"]),
                ("Scandal", "Jean Paul Gaultier", "Eau de Parfum", ["Honey", "Orange Blossom", "Caramel", "Patchouli"]),
                ("Black Opium", "Yves Saint Laurent", "Eau de Parfum", ["Coffee", "Vanilla", "Orange Blossom", "Pear"]),
                ("Cloud", "Ariana Grande", "Eau de Parfum", ["Lavender", "Pear", "Coconut", "Praline", "Musk"]),
            ],
        ]

        guard let recs = familyRecs[family] else { return [] }

        return recs.map { name, brand, concentration, notes in
            let matchingNotes = notes.filter { noteProfile[$0.lowercased()] ?? 0 > 0 }
            let percentage = min(96, max(60, Int(Double(matchingNotes.count) / Double(max(notes.count, 1)) * 100) + 40))
            let reason: String
            if matchingNotes.count >= 2 {
                reason = "Matches your love for \(matchingNotes.prefix(2).joined(separator: " & "))"
            } else if !topNotes.isEmpty {
                reason = "Great for \(family) lovers"
            } else {
                reason = "A standout \(family) fragrance"
            }

            return RecommendedPerfume(
                name: name,
                brand: brand,
                imageURL: nil,
                description: "A \(family) fragrance by \(brand) featuring \(notes.prefix(3).joined(separator: ", ")).",
                notes: notes,
                matchReason: reason,
                matchPercentage: percentage,
                concentration: concentration
            )
        }
    }

    private func buildGenericRecommendations(noteProfile: [String: Double], topNotes: [String]) -> [RecommendedPerfume] {
        defaultRecommendations.map { rec in
            let matchingNotes = rec.notes.filter { noteProfile[$0.lowercased()] ?? 0 > 0 }
            let percentage = min(92, max(55, Int(Double(matchingNotes.count) / Double(max(rec.notes.count, 1)) * 100) + 40))
            let reason = matchingNotes.count >= 2
                ? "Matches your love for \(matchingNotes.prefix(2).joined(separator: " & "))"
                : rec.matchReason

            return RecommendedPerfume(
                name: rec.name, brand: rec.brand, imageURL: rec.imageURL,
                description: rec.description, notes: rec.notes, matchReason: reason,
                matchPercentage: percentage, concentration: rec.concentration
            )
        }
    }

    private let defaultRecommendations: [RecommendedPerfume] = [
        RecommendedPerfume(name: "Bleu de Chanel", brand: "Chanel", imageURL: nil, description: "A woody aromatic fragrance that is both fresh and sensual.", notes: ["Grapefruit", "Mint", "Cedar", "Sandalwood", "Incense"], matchReason: "A universally loved classic", matchPercentage: 85, concentration: "Eau de Parfum"),
        RecommendedPerfume(name: "Aventus", brand: "Creed", imageURL: nil, description: "A fruity-woody masterpiece celebrating strength and success.", notes: ["Apple", "Bergamot", "Patchouli", "Musk", "Vanilla"], matchReason: "One of the most acclaimed fragrances", matchPercentage: 82, concentration: "Eau de Parfum"),
        RecommendedPerfume(name: "Baccarat Rouge 540", brand: "Maison Francis Kurkdjian", imageURL: nil, description: "An alchemy of amber, woody, and floral notes.", notes: ["Saffron", "Jasmine", "Amber", "Cedar", "Musk"], matchReason: "A modern icon that turns heads", matchPercentage: 80, concentration: "Eau de Parfum"),
        RecommendedPerfume(name: "Sauvage", brand: "Dior", imageURL: nil, description: "A fresh and raw masculine fragrance.", notes: ["Bergamot", "Pepper", "Lavender", "Cedar", "Ambroxan"], matchReason: "The world's best-selling fragrance", matchPercentage: 78, concentration: "Eau de Parfum"),
        RecommendedPerfume(name: "La Vie Est Belle", brand: "Lancôme", imageURL: nil, description: "A sweet gourmand floral.", notes: ["Iris", "Patchouli", "Vanilla", "Praline", "Orange Blossom"], matchReason: "A beloved feminine classic", matchPercentage: 76, concentration: "Eau de Parfum"),
    ]
}
