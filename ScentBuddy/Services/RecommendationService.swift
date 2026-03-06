import Foundation

struct RecommendationService {
    func generateRecommendations(from perfumes: [Perfume], wearEntries: [WearEntry] = []) -> [RecommendedPerfume] {
        guard !perfumes.isEmpty else { return defaultRecommendations.shuffled().prefix(3).map { $0 } }

        let noteProfile = buildNoteProfile(from: perfumes, wearEntries: wearEntries)
        let concentrationProfile = buildConcentrationProfile(from: perfumes)
        let ownedIdentifiers = buildOwnedIdentifiers(from: perfumes)

        let candidates = PerfumeDatabase.entries.filter { entry in
            !ownedIdentifiers.contains(normalizedIdentifier(name: entry.name, brand: entry.brand))
        }

        let scored: [(PerfumeEntry, Double)] = candidates.map { entry in
            let score = calculateScore(for: entry, noteProfile: noteProfile, concentrationProfile: concentrationProfile)
            return (entry, score)
        }

        let sorted = scored.sorted { $0.1 > $1.1 }.filter { $0.1 > 0 }

        guard !sorted.isEmpty else { return defaultRecommendations.shuffled().prefix(3).map { $0 } }

        let poolSize = min(sorted.count, 30)
        let pool = Array(sorted.prefix(poolSize))
        let shuffledPool = addVariety(pool)
        let diversified = diversifyResults(shuffledPool, maxPerBrand: 2, total: 10)
        let maxScore = pool.first?.1 ?? 1.0

        return diversified.map { entry, score in
            let percentage = min(98, max(55, Int((score / maxScore) * 98.0)))
            let reason = buildMatchReason(for: entry, noteProfile: noteProfile)
            return RecommendedPerfume(
                name: entry.name,
                brand: entry.brand,
                imageURL: nil,
                description: buildDescription(for: entry),
                notes: entry.allNotes,
                matchReason: reason,
                matchPercentage: percentage,
                concentration: entry.concentration
            )
        }
    }

    private func buildNoteProfile(from perfumes: [Perfume], wearEntries: [WearEntry]) -> [String: Double] {
        var wearCounts: [String: Int] = [:]
        for entry in wearEntries {
            let key = "\(entry.perfumeName.lowercased())|\(entry.perfumeBrand.lowercased())"
            wearCounts[key, default: 0] += 1
        }

        var noteScores: [String: Double] = [:]

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

    private func buildConcentrationProfile(from perfumes: [Perfume]) -> [String: Int] {
        var counts: [String: Int] = [:]
        for perfume in perfumes {
            counts[perfume.concentration, default: 0] += 1
        }
        return counts
    }

    private func buildOwnedIdentifiers(from perfumes: [Perfume]) -> Set<String> {
        Set(perfumes.map { normalizedIdentifier(name: $0.name, brand: $0.brand) })
    }

    private func normalizedIdentifier(name: String, brand: String) -> String {
        "\(name.lowercased().trimmingCharacters(in: .whitespaces))|\(brand.lowercased().trimmingCharacters(in: .whitespaces))"
    }

    private func calculateScore(for entry: PerfumeEntry, noteProfile: [String: Double], concentrationProfile: [String: Int]) -> Double {
        var score: Double = 0

        for note in entry.topNotes {
            score += noteProfile[note.lowercased()] ?? 0
        }
        for note in entry.heartNotes {
            score += (noteProfile[note.lowercased()] ?? 0) * 1.2
        }
        for note in entry.baseNotes {
            score += (noteProfile[note.lowercased()] ?? 0) * 1.4
        }

        let totalOwned = concentrationProfile.values.reduce(0, +)
        if totalOwned > 0 {
            let concCount = concentrationProfile[entry.concentration] ?? 0
            let concRatio = Double(concCount) / Double(totalOwned)
            score *= (1.0 + concRatio * 0.15)
        }

        let noteCount = entry.allNotes.count
        let matchingCount = entry.allNotes.filter { noteProfile[$0.lowercased()] != nil }.count
        if noteCount > 0 {
            let matchRatio = Double(matchingCount) / Double(noteCount)
            score *= (0.7 + matchRatio * 0.6)
        }

        return score
    }

    private func addVariety(_ scored: [(PerfumeEntry, Double)]) -> [(PerfumeEntry, Double)] {
        guard scored.count > 3 else { return scored }
        let topThree = Array(scored.prefix(3))
        var rest = Array(scored.dropFirst(3))
        rest.shuffle()
        return topThree + rest
    }

    private func diversifyResults(_ scored: [(PerfumeEntry, Double)], maxPerBrand: Int, total: Int) -> [(PerfumeEntry, Double)] {
        var results: [(PerfumeEntry, Double)] = []
        var brandCounts: [String: Int] = [:]
        var usedFamilies = Set<String>()

        for item in scored {
            let brand = item.0.brand
            let family = categorizeDominantFamily(item.0)
            let count = brandCounts[brand] ?? 0
            let familyPenalty = usedFamilies.contains(family) && results.count > 3

            if count < maxPerBrand && !familyPenalty {
                results.append(item)
                brandCounts[brand] = count + 1
                usedFamilies.insert(family)
                if results.count >= total { break }
            }
        }

        if results.count < total {
            for item in scored where !results.contains(where: { $0.0.name == item.0.name && $0.0.brand == item.0.brand }) {
                let brand = item.0.brand
                let count = brandCounts[brand] ?? 0
                if count < maxPerBrand {
                    results.append(item)
                    brandCounts[brand] = count + 1
                    if results.count >= total { break }
                }
            }
        }

        return results
    }

    private func buildMatchReason(for entry: PerfumeEntry, noteProfile: [String: Double]) -> String {
        let allNotes = entry.allNotes
        let matchingNotes = allNotes
            .map { (note: $0, score: noteProfile[$0.lowercased()] ?? 0) }
            .filter { $0.score > 0 }
            .sorted { $0.score > $1.score }

        if matchingNotes.count >= 3 {
            let topThree = matchingNotes.prefix(3).map(\.note)
            return "Matches your love for \(topThree[0]), \(topThree[1]) & \(topThree[2])"
        } else if matchingNotes.count >= 1 {
            let top = matchingNotes.prefix(2).map(\.note)
            return "Matches your love for \(top.joined(separator: " & "))"
        }
        return "A great addition to your collection"
    }

    private func buildDescription(for entry: PerfumeEntry) -> String {
        let noteCategories = categorizeDominantFamily(entry)
        return "A \(noteCategories) fragrance by \(entry.brand) with \(entry.allNotes.prefix(3).joined(separator: ", ")) and more."
    }

    private func categorizeDominantFamily(_ entry: PerfumeEntry) -> String {
        let allNotes = Set(entry.allNotes.map { $0.lowercased() })

        let woodyNotes: Set<String> = ["sandalwood", "cedar", "vetiver", "patchouli", "oud", "guaiac wood", "birch", "cypress", "teak"]
        let floralNotes: Set<String> = ["rose", "jasmine", "iris", "violet", "peony", "lily", "tuberose", "magnolia", "orange blossom", "ylang ylang"]
        let freshNotes: Set<String> = ["bergamot", "lemon", "grapefruit", "mandarin", "lime", "neroli", "mint", "aquatic", "green tea"]
        let orientalNotes: Set<String> = ["vanilla", "amber", "tonka bean", "benzoin", "incense", "musk", "saffron", "cinnamon", "cardamom"]

        let woodyCount = allNotes.intersection(woodyNotes).count
        let floralCount = allNotes.intersection(floralNotes).count
        let freshCount = allNotes.intersection(freshNotes).count
        let orientalCount = allNotes.intersection(orientalNotes).count

        let families = [
            ("woody", woodyCount),
            ("floral", floralCount),
            ("fresh", freshCount),
            ("oriental", orientalCount)
        ].sorted { $0.1 > $1.1 }

        if families[0].1 > 0 && families[1].1 > 0 {
            return "\(families[0].0)-\(families[1].0)"
        } else if families[0].1 > 0 {
            return families[0].0
        }
        return "sophisticated"
    }

    private let defaultRecommendations: [RecommendedPerfume] = [
        RecommendedPerfume(name: "Bleu de Chanel", brand: "Chanel", imageURL: nil, description: "A woody aromatic fragrance that is both fresh and sensual.", notes: ["Grapefruit", "Mint", "Cedar", "Sandalwood", "Incense"], matchReason: "A universally loved classic to start your journey", matchPercentage: 85, concentration: "Eau de Parfum"),
        RecommendedPerfume(name: "Aventus", brand: "Creed", imageURL: nil, description: "A fruity-woody masterpiece celebrating strength and success.", notes: ["Apple", "Bergamot", "Patchouli", "Musk", "Vanilla"], matchReason: "One of the most acclaimed fragrances of all time", matchPercentage: 82, concentration: "Eau de Parfum"),
        RecommendedPerfume(name: "Baccarat Rouge 540", brand: "Maison Francis Kurkdjian", imageURL: nil, description: "An alchemy of amber, woody, and floral notes.", notes: ["Saffron", "Jasmine", "Amber", "Cedar", "Musk"], matchReason: "A modern icon that turns heads", matchPercentage: 80, concentration: "Eau de Parfum"),
    ]
}
