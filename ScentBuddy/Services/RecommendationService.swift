import Foundation

nonisolated struct CandidatePerfume: Sendable {
    let name: String
    let brand: String
    let concentration: String
    let gender: String
    let topNotes: [String]
    let heartNotes: [String]
    let baseNotes: [String]

    var allNotes: [String] { topNotes + heartNotes + baseNotes }
}

struct RecommendationService {

    func generateRecommendations(from perfumes: [Perfume], wearEntries: [WearEntry] = []) -> [RecommendedPerfume] {
        let notePrefs = OnboardingManager.shared.notePreferences.favoriteNotes
        let candidates = Self.candidateDatabase

        if perfumes.isEmpty && notePrefs.isEmpty {
            return rotateResults(fallbackRecommendations(candidates: candidates))
        }

        let idfMap = computeIDF(candidates: candidates)
        let tasteProfile = buildTasteProfile(perfumes: perfumes, wearEntries: wearEntries, notePrefs: notePrefs)

        guard !tasteProfile.isEmpty else {
            return rotateResults(fallbackRecommendations(candidates: candidates))
        }

        let userPrefs = extractUserPreferences(perfumes: perfumes)

        let ownedSet = Set(perfumes.map { "\($0.name.lowercased())|\($0.brand.lowercased())" })

        var scored: [(CandidatePerfume, Double, String)] = []

        for candidate in candidates {
            let key = "\(candidate.name.lowercased())|\(candidate.brand.lowercased())"
            guard !ownedSet.contains(key) else { continue }

            let (score, reason) = scoreCandidate(
                candidate: candidate,
                tasteProfile: tasteProfile,
                idfMap: idfMap,
                userPrefs: userPrefs,
                ownedPerfumes: perfumes
            )

            if score > 0 {
                scored.append((candidate, score, reason))
            }
        }

        scored.sort { $0.1 > $1.1 }

        var results: [RecommendedPerfume] = []
        var brandCount: [String: Int] = [:]

        for (candidate, score, reason) in scored {
            let bc = brandCount[candidate.brand, default: 0]
            if bc >= 2 { continue }
            brandCount[candidate.brand, default: 0] += 1

            let maxScore = scored.first?.1 ?? 1.0
            let normalized = maxScore > 0 ? Int((score / maxScore) * 96.0) + 2 : 50
            let percentage = min(98, max(10, normalized))

            results.append(RecommendedPerfume(
                name: candidate.name,
                brand: candidate.brand,
                imageURL: nil,
                description: buildDescription(candidate: candidate),
                notes: candidate.allNotes,
                matchReason: reason,
                matchPercentage: percentage,
                concentration: candidate.concentration
            ))

            if results.count >= 9 { break }
        }

        if results.count < 5 {
            let fallback = fallbackRecommendations(candidates: candidates)
            for rec in fallback {
                if !results.contains(where: { $0.name == rec.name }) {
                    results.append(rec)
                }
                if results.count >= 9 { break }
            }
        }

        return rotateResults(results)
    }

    private func computeIDF(candidates: [CandidatePerfume]) -> [String: Double] {
        let total = Double(candidates.count)
        var freq: [String: Int] = [:]
        for c in candidates {
            let unique = Set(c.allNotes.map { $0.lowercased() })
            for note in unique {
                freq[note, default: 0] += 1
            }
        }
        var idf: [String: Double] = [:]
        for (note, count) in freq {
            idf[note] = log(total / Double(count))
        }
        return idf
    }

    private func buildTasteProfile(perfumes: [Perfume], wearEntries: [WearEntry], notePrefs: [String]) -> [String: Double] {
        var profile: [String: Double] = [:]

        for note in notePrefs {
            profile[note.lowercased(), default: 0] += 4.0
        }

        for perfume in perfumes {
            let ratingMultiplier: Double = perfume.rating > 0 ? Double(perfume.rating) / 3.0 : 1.0

            for note in perfume.topNotes {
                profile[note.lowercased(), default: 0] += 1.0 * ratingMultiplier
            }
            for note in perfume.heartNotes {
                profile[note.lowercased(), default: 0] += 2.0 * ratingMultiplier
            }
            for note in perfume.baseNotes {
                profile[note.lowercased(), default: 0] += 3.0 * ratingMultiplier
            }
        }

        return profile
    }

    private struct UserPreferences {
        let primaryGender: String
        let topConcentration: String
        let brandCounts: [String: Int]
    }

    private func extractUserPreferences(perfumes: [Perfume]) -> UserPreferences {
        var concCounts: [String: Int] = [:]
        var brandCounts: [String: Int] = [:]

        for p in perfumes {
            concCounts[p.concentration, default: 0] += 1
            brandCounts[p.brand, default: 0] += 1
        }

        let topConc = concCounts.max(by: { $0.value < $1.value })?.key ?? "Eau de Parfum"

        var genderScore: [String: Double] = ["Men": 0, "Women": 0, "Unisex": 0]
        for p in perfumes {
            let key = "\(p.name.lowercased())|\(p.brand.lowercased())"
            if let known = Self.knownGenders[key] {
                genderScore[known, default: 0] += 1
            } else {
                genderScore["Unisex", default: 0] += 0.5
            }
        }
        let primaryGender = genderScore.max(by: { $0.value < $1.value })?.key ?? "Unisex"

        return UserPreferences(primaryGender: primaryGender, topConcentration: topConc, brandCounts: brandCounts)
    }

    private func scoreCandidate(
        candidate: CandidatePerfume,
        tasteProfile: [String: Double],
        idfMap: [String: Double],
        userPrefs: UserPreferences,
        ownedPerfumes: [Perfume]
    ) -> (Double, String) {
        var score: Double = 0
        var topMatchedNotes: [(String, Double)] = []

        func addNoteScore(_ notes: [String], positionWeight: Double) {
            for note in notes {
                let key = note.lowercased()
                guard let taste = tasteProfile[key] else { continue }
                let idf = idfMap[key] ?? 1.0
                let contribution = idf * positionWeight * taste
                score += contribution
                topMatchedNotes.append((note, contribution))
            }
        }

        addNoteScore(candidate.topNotes, positionWeight: 1.0)
        addNoteScore(candidate.heartNotes, positionWeight: 2.0)
        addNoteScore(candidate.baseNotes, positionWeight: 3.0)

        guard score > 0 else { return (0, "") }

        if candidate.gender == userPrefs.primaryGender {
            score *= 1.15
        } else if candidate.gender == "Unisex" {
            score *= 1.05
        } else if (candidate.gender == "Men" && userPrefs.primaryGender == "Women")
                    || (candidate.gender == "Women" && userPrefs.primaryGender == "Men") {
            score *= 0.6
        }

        let brandOwned = userPrefs.brandCounts[candidate.brand] ?? 0
        if brandOwned >= 2 {
            score *= 1.1
        }

        if candidate.concentration == userPrefs.topConcentration {
            score *= 1.05
        }

        let candidateNotes = Set(candidate.allNotes.map { $0.lowercased() })
        for owned in ownedPerfumes {
            let ownedNotes = Set(owned.allNotes.map { $0.lowercased() })
            guard !ownedNotes.isEmpty else { continue }
            let overlap = Double(candidateNotes.intersection(ownedNotes).count) / Double(ownedNotes.count)
            if overlap > 0.8 {
                score *= 0.3
                break
            } else if overlap > 0.6 {
                score *= 0.7
                break
            }
        }

        topMatchedNotes.sort { $0.1 > $1.1 }
        let bestNotes = topMatchedNotes.prefix(2).map { $0.0 }
        let reason: String
        if bestNotes.count >= 2 {
            reason = "Matches your love for \(bestNotes[0]) & \(bestNotes[1])"
        } else if let first = bestNotes.first {
            reason = "Matches your love for \(first)"
        } else {
            reason = "Complements your collection"
        }

        return (score, reason)
    }

    private func buildDescription(candidate: CandidatePerfume) -> String {
        let noteList = candidate.allNotes.prefix(4).joined(separator: ", ")
        return "\(candidate.concentration) by \(candidate.brand) featuring \(noteList)."
    }

    private func fallbackRecommendations(candidates: [CandidatePerfume]) -> [RecommendedPerfume] {
        let popular = ["Bleu de Chanel", "Aventus", "Baccarat Rouge 540", "Sauvage", "La Vie Est Belle"]
        return candidates
            .filter { popular.contains($0.name) }
            .prefix(5)
            .map {
                RecommendedPerfume(
                    name: $0.name, brand: $0.brand, imageURL: nil,
                    description: buildDescription(candidate: $0),
                    notes: $0.allNotes,
                    matchReason: "A universally loved classic",
                    matchPercentage: Int.random(in: 75...85),
                    concentration: $0.concentration
                )
            }
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

    // MARK: - Known Gender Lookup

    private static let knownGenders: [String: String] = {
        var map: [String: String] = [:]
        for c in candidateDatabase {
            map["\(c.name.lowercased())|\(c.brand.lowercased())"] = c.gender
        }
        return map
    }()

    // MARK: - Candidate Perfume Database

    static let candidateDatabase: [CandidatePerfume] = [
        // Woody
        CandidatePerfume(name: "Santal 33", brand: "Le Labo", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Cardamom", "Iris", "Violet"], heartNotes: ["Ambrox", "Australian Sandalwood"], baseNotes: ["Cedar", "Leather", "Musk"]),
        CandidatePerfume(name: "Tam Dao", brand: "Diptyque", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Cypress", "Myrtle"], heartNotes: ["Rosewood", "Sandalwood"], baseNotes: ["Cedar", "Musk", "Amber"]),
        CandidatePerfume(name: "Ombré Leather", brand: "Tom Ford", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Cardamom"], heartNotes: ["Jasmine", "Leather"], baseNotes: ["Patchouli", "Vetiver", "Amber", "Moss"]),
        CandidatePerfume(name: "Wonderwood", brand: "Comme des Garçons", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Pepper"], heartNotes: ["Nutmeg", "Oud"], baseNotes: ["Cedar", "Sandalwood", "Vetiver"]),
        CandidatePerfume(name: "Encre Noire", brand: "Lalique", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Cypress"], heartNotes: ["Vetiver"], baseNotes: ["Cashmere Wood", "Musk"]),
        CandidatePerfume(name: "Terre d'Hermès", brand: "Hermès", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Grapefruit", "Orange"], heartNotes: ["Pepper", "Geranium"], baseNotes: ["Vetiver", "Cedar", "Benzoin"]),
        CandidatePerfume(name: "Cedrat Boisé", brand: "Mancera", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Lemon", "Bergamot", "Black Pepper"], heartNotes: ["Patchouli", "Leather"], baseNotes: ["Sandalwood", "Cedar", "Vanilla", "Musk"]),
        CandidatePerfume(name: "Bois d'Argent", brand: "Dior", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Honey"], heartNotes: ["Iris", "Incense"], baseNotes: ["Sandalwood", "Musk", "Amber"]),

        // Floral
        CandidatePerfume(name: "Portrait of a Lady", brand: "Frederic Malle", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Rose", "Clove", "Raspberry"], heartNotes: ["Patchouli", "Sandalwood"], baseNotes: ["Musk", "Frankincense", "Amber"]),
        CandidatePerfume(name: "Delina", brand: "Parfums de Marly", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Lychee", "Rhubarb", "Bergamot"], heartNotes: ["Rose", "Peony", "Vanilla"], baseNotes: ["Cashmeran", "Musk", "Cedar"]),
        CandidatePerfume(name: "Rose 31", brand: "Le Labo", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Cumin", "Rose"], heartNotes: ["Cedar", "Guaiac Wood"], baseNotes: ["Amber", "Musk", "Oud"]),
        CandidatePerfume(name: "Miss Dior Blooming Bouquet", brand: "Dior", concentration: "Eau de Toilette", gender: "Women",
            topNotes: ["Mandarin", "Apricot"], heartNotes: ["Peony", "Rose"], baseNotes: ["White Musk"]),
        CandidatePerfume(name: "Gucci Bloom", brand: "Gucci", concentration: "Eau de Parfum", gender: "Women",
            topNotes: [], heartNotes: ["Tuberose", "Jasmine"], baseNotes: ["Rangoon Creeper", "Sandalwood"]),
        CandidatePerfume(name: "La Nuit Trésor", brand: "Lancôme", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Bergamot", "Lychee"], heartNotes: ["Rose", "Orchid"], baseNotes: ["Vanilla", "Patchouli", "Chocolate"]),
        CandidatePerfume(name: "Flowerbomb", brand: "Viktor & Rolf", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Bergamot", "Green Tea"], heartNotes: ["Jasmine", "Rose", "Orchid"], baseNotes: ["Patchouli", "Musk", "Vanilla"]),
        CandidatePerfume(name: "No. 5", brand: "Chanel", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Bergamot", "Lemon", "Neroli"], heartNotes: ["Jasmine", "Rose", "Iris"], baseNotes: ["Sandalwood", "Vanilla", "Musk"]),
        CandidatePerfume(name: "Mon Guerlain", brand: "Guerlain", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Lavender", "Bergamot"], heartNotes: ["Iris", "Jasmine"], baseNotes: ["Vanilla", "Sandalwood", "Coumarin"]),

        // Fresh
        CandidatePerfume(name: "Acqua di Gio Profumo", brand: "Giorgio Armani", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Bergamot", "Mandarin", "Aquatic"], heartNotes: ["Geranium", "Rosemary"], baseNotes: ["Amber", "Patchouli", "Incense"]),
        CandidatePerfume(name: "Light Blue", brand: "Dolce & Gabbana", concentration: "Eau de Toilette", gender: "Women",
            topNotes: ["Lemon", "Apple", "Bluebells"], heartNotes: ["Jasmine", "Bamboo", "Rose"], baseNotes: ["Cedar", "Musk", "Amber"]),
        CandidatePerfume(name: "Neroli Portofino", brand: "Tom Ford", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Neroli", "Bergamot", "Lemon", "Mandarin"], heartNotes: ["African Orange Flower", "Jasmine"], baseNotes: ["Amber", "Musk"]),
        CandidatePerfume(name: "Green Irish Tweed", brand: "Creed", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Lemon", "Verbena"], heartNotes: ["Iris", "Violet Leaf"], baseNotes: ["Sandalwood", "Ambroxan", "Musk"]),
        CandidatePerfume(name: "Eau Sauvage", brand: "Dior", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Lemon", "Bergamot"], heartNotes: ["Rosemary", "Basil"], baseNotes: ["Vetiver", "Musk", "Oakmoss"]),
        CandidatePerfume(name: "Bergamote 22", brand: "Le Labo", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Bergamot", "Grapefruit"], heartNotes: ["Petitgrain", "Amber"], baseNotes: ["Cedar", "Vetiver", "Musk"]),
        CandidatePerfume(name: "Virgin Island Water", brand: "Creed", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Lime", "Mandarin", "Ginger"], heartNotes: ["Coconut", "Hibiscus"], baseNotes: ["Musk", "White Wood"]),
        CandidatePerfume(name: "Acqua di Parma Colonia", brand: "Acqua di Parma", concentration: "Eau de Cologne", gender: "Unisex",
            topNotes: ["Lemon", "Orange", "Bergamot"], heartNotes: ["Lavender", "Rosemary"], baseNotes: ["Vetiver", "Sandalwood", "Musk"]),

        // Oriental
        CandidatePerfume(name: "Baccarat Rouge 540", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Saffron", "Jasmine"], heartNotes: ["Ambroxan", "Maison"], baseNotes: ["Fir Resin", "Cedar"]),
        CandidatePerfume(name: "By the Fireplace", brand: "Maison Margiela", concentration: "Eau de Toilette", gender: "Unisex",
            topNotes: ["Clove", "Pink Pepper", "Orange"], heartNotes: ["Chestnut", "Guaiac Wood"], baseNotes: ["Vanilla", "Cashmeran", "Benzoin"]),
        CandidatePerfume(name: "Tobacco Vanille", brand: "Tom Ford", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Tobacco", "Ginger"], heartNotes: ["Tonka Bean", "Vanilla", "Cacao"], baseNotes: ["Dried Fruits", "Wood"]),
        CandidatePerfume(name: "Spicebomb Extreme", brand: "Viktor & Rolf", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Black Pepper", "Grapefruit"], heartNotes: ["Cinnamon", "Tobacco"], baseNotes: ["Vanilla", "Lavender"]),
        CandidatePerfume(name: "Jazz Club", brand: "Maison Margiela", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Pink Pepper", "Lemon", "Neroli"], heartNotes: ["Rum", "Clary Sage"], baseNotes: ["Tobacco", "Vanilla", "Vetiver", "Tonka Bean"]),
        CandidatePerfume(name: "Grand Soir", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: [], heartNotes: ["Amber", "Benzoin"], baseNotes: ["Tonka Bean", "Vanilla"]),
        CandidatePerfume(name: "Interlude Man", brand: "Amouage", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Oregano", "Bergamot", "Pepper"], heartNotes: ["Incense", "Opoponax", "Amber"], baseNotes: ["Oud", "Sandalwood", "Musk"]),
        CandidatePerfume(name: "Black Orchid", brand: "Tom Ford", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Truffle", "Bergamot"], heartNotes: ["Orchid", "Lotus", "Spice"], baseNotes: ["Patchouli", "Vanilla", "Sandalwood", "Chocolate"]),
        CandidatePerfume(name: "Oud Wood", brand: "Tom Ford", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Rosewood", "Cardamom"], heartNotes: ["Oud", "Sandalwood", "Vetiver"], baseNotes: ["Tonka Bean", "Amber"]),
        CandidatePerfume(name: "Nuit d'Issey", brand: "Issey Miyake", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Bergamot", "Grapefruit"], heartNotes: ["Leather"], baseNotes: ["Vetiver", "Patchouli", "Incense", "Tonka Bean"]),

        // Fruity / Gourmand
        CandidatePerfume(name: "Aventus", brand: "Creed", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Apple", "Bergamot", "Pineapple", "Black Currant"], heartNotes: ["Birch", "Jasmine", "Rose"], baseNotes: ["Musk", "Vanilla", "Ambergris"]),
        CandidatePerfume(name: "Lost Cherry", brand: "Tom Ford", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Cherry", "Almond"], heartNotes: ["Turkish Rose", "Jasmine"], baseNotes: ["Tonka Bean", "Vanilla", "Cedar", "Peru Balsam"]),
        CandidatePerfume(name: "Black Opium", brand: "Yves Saint Laurent", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Pear", "Pink Pepper"], heartNotes: ["Coffee", "Orange Blossom", "Jasmine"], baseNotes: ["Vanilla", "Patchouli", "Cedar"]),
        CandidatePerfume(name: "Cloud", brand: "Ariana Grande", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Lavender", "Pear", "Bergamot"], heartNotes: ["Coconut", "Praline", "Vanilla Orchid"], baseNotes: ["Musk", "Blonde Wood", "Cashmere"]),
        CandidatePerfume(name: "Scandal", brand: "Jean Paul Gaultier", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Honey", "Orange Blossom"], heartNotes: ["Gardenia"], baseNotes: ["Caramel", "Patchouli", "Cashmeran"]),
        CandidatePerfume(name: "Good Girl", brand: "Carolina Herrera", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Almond", "Coffee"], heartNotes: ["Tuberose", "Jasmine", "Rose"], baseNotes: ["Tonka Bean", "Cacao", "Vanilla"]),
        CandidatePerfume(name: "Born in Roma", brand: "Valentino", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Jasmine", "Pink Pepper"], heartNotes: ["Vanilla", "Rose"], baseNotes: ["Cashmeran", "Benzoin", "Musk"]),

        // Designer Classics
        CandidatePerfume(name: "Sauvage", brand: "Dior", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Bergamot", "Pepper"], heartNotes: ["Lavender", "Sichuan Pepper", "Star Anise"], baseNotes: ["Ambroxan", "Cedar", "Vanilla"]),
        CandidatePerfume(name: "Bleu de Chanel", brand: "Chanel", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Grapefruit", "Lemon", "Mint"], heartNotes: ["Ginger", "Nutmeg", "Jasmine"], baseNotes: ["Sandalwood", "Incense", "Cedar", "Vetiver"]),
        CandidatePerfume(name: "La Vie Est Belle", brand: "Lancôme", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Black Currant", "Pear"], heartNotes: ["Iris", "Praline", "Orange Blossom"], baseNotes: ["Patchouli", "Vanilla", "Tonka Bean"]),
        CandidatePerfume(name: "1 Million", brand: "Paco Rabanne", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Grapefruit", "Blood Mandarin", "Mint"], heartNotes: ["Rose", "Cinnamon", "Spice"], baseNotes: ["Leather", "Amber", "Patchouli"]),
        CandidatePerfume(name: "Versace Eros", brand: "Versace", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Mint", "Green Apple", "Lemon"], heartNotes: ["Tonka Bean", "Ambroxan", "Geranium"], baseNotes: ["Vanilla", "Vetiver", "Oakmoss", "Cedar"]),
        CandidatePerfume(name: "Dylan Blue", brand: "Versace", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Bergamot", "Grapefruit", "Fig Leaf"], heartNotes: ["Violet Leaf", "Papyrus", "Ambroxan"], baseNotes: ["Musk", "Tonka Bean", "Saffron"]),
        CandidatePerfume(name: "Armani Code", brand: "Giorgio Armani", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Bergamot", "Lemon"], heartNotes: ["Olive Blossom", "Star Anise"], baseNotes: ["Tonka Bean", "Leather", "Guaiac Wood"]),
        CandidatePerfume(name: "The One", brand: "Dolce & Gabbana", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Grapefruit", "Coriander"], heartNotes: ["Ginger", "Cardamom", "Orange Blossom"], baseNotes: ["Amber", "Cedar", "Tobacco"]),

        // Niche Gems
        CandidatePerfume(name: "Initio Oud for Greatness", brand: "Initio", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Saffron", "Nutmeg", "Lavender"], heartNotes: ["Oud", "Orris"], baseNotes: ["Musk", "Patchouli"]),
        CandidatePerfume(name: "Layton", brand: "Parfums de Marly", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Apple", "Bergamot", "Mandarin"], heartNotes: ["Jasmine", "Violet", "Lavender"], baseNotes: ["Vanilla", "Sandalwood", "Cardamom", "Pepper"]),
        CandidatePerfume(name: "Pegasus", brand: "Parfums de Marly", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Bergamot", "Heliotrope"], heartNotes: ["Jasmine", "Almond"], baseNotes: ["Vanilla", "Sandalwood", "Amber"]),
        CandidatePerfume(name: "Hacivat", brand: "Nishane", concentration: "Extrait de Parfum", gender: "Unisex",
            topNotes: ["Pineapple", "Bergamot", "Grapefruit"], heartNotes: ["Jasmine", "Patchouli"], baseNotes: ["Sandalwood", "Cedar", "Oakmoss", "Musk"]),
        CandidatePerfume(name: "BR540 Extrait", brand: "Maison Francis Kurkdjian", concentration: "Extrait de Parfum", gender: "Unisex",
            topNotes: ["Bitter Almond"], heartNotes: ["Saffron", "Ambrette"], baseNotes: ["Fir Resin", "Cedar", "Musk"]),
        CandidatePerfume(name: "Rehab", brand: "Initio", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Lavender", "Musk"], heartNotes: ["Tobacco", "Saffron"], baseNotes: ["Oud", "Vanilla", "Sandalwood"]),
        CandidatePerfume(name: "Tiziana Terenzi Kirke", brand: "Tiziana Terenzi", concentration: "Extrait de Parfum", gender: "Unisex",
            topNotes: ["Peach", "Passion Fruit", "Grape"], heartNotes: ["Rose", "Lily", "Jasmine"], baseNotes: ["Vanilla", "Musk", "Amber"]),
        CandidatePerfume(name: "Erba Pura", brand: "Xerjoff", concentration: "Eau de Parfum", gender: "Unisex",
            topNotes: ["Orange", "Lemon", "Bergamot"], heartNotes: ["Peach", "Raspberry", "Mango"], baseNotes: ["Vanilla", "Musk", "Amber"]),
        CandidatePerfume(name: "Ani", brand: "Nishane", concentration: "Extrait de Parfum", gender: "Unisex",
            topNotes: ["Bergamot", "Cardamom", "Orange Blossom"], heartNotes: ["Orchid", "Rose"], baseNotes: ["Vanilla", "Tonka Bean", "Sandalwood"]),
        CandidatePerfume(name: "Alexandria II", brand: "Xerjoff", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Bergamot", "Pink Pepper", "Mandarin"], heartNotes: ["Oud", "Iris"], baseNotes: ["Vanilla", "Amber", "Sandalwood", "Musk"]),

        // More Designer
        CandidatePerfume(name: "Y Eau de Parfum", brand: "Yves Saint Laurent", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Apple", "Ginger", "Bergamot"], heartNotes: ["Sage", "Juniper Berries"], baseNotes: ["Amberwood", "Cedar", "Tonka Bean"]),
        CandidatePerfume(name: "Libre", brand: "Yves Saint Laurent", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Mandarin", "Lavender", "Black Currant"], heartNotes: ["Orange Blossom", "Jasmine"], baseNotes: ["Vanilla", "Cedar", "Musk"]),
        CandidatePerfume(name: "Coco Mademoiselle", brand: "Chanel", concentration: "Eau de Parfum", gender: "Women",
            topNotes: ["Orange", "Bergamot"], heartNotes: ["Rose", "Jasmine", "Lychee"], baseNotes: ["Patchouli", "Vetiver", "Vanilla", "Musk"]),
        CandidatePerfume(name: "Allure Homme Sport", brand: "Chanel", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Orange", "Mandarin"], heartNotes: ["Neroli", "Cedar"], baseNotes: ["Vetiver", "Amber", "Musk", "Tonka Bean"]),
        CandidatePerfume(name: "Fahrenheit", brand: "Dior", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Lavender", "Mandarin"], heartNotes: ["Nutmeg", "Cedar", "Violet"], baseNotes: ["Leather", "Vetiver", "Musk"]),
        CandidatePerfume(name: "Luna Rossa Carbon", brand: "Prada", concentration: "Eau de Toilette", gender: "Men",
            topNotes: ["Bergamot", "Pepper"], heartNotes: ["Lavender", "Metallic Notes"], baseNotes: ["Ambroxan", "Patchouli"]),
        CandidatePerfume(name: "Explorer", brand: "Montblanc", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Clary Sage", "Leather"], baseNotes: ["Vetiver", "Patchouli", "Ambroxan", "Cacao"]),
        CandidatePerfume(name: "Gucci Guilty", brand: "Gucci", concentration: "Eau de Parfum", gender: "Men",
            topNotes: ["Lavender", "Lemon"], heartNotes: ["Orange Blossom", "Rose"], baseNotes: ["Cedar", "Patchouli", "Vanilla"]),
    ]
}
