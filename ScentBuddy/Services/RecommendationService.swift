import Foundation

@Observable
final class RecommendationService {
    private(set) var isLoading: Bool = false
    private(set) var recommendations: [RecommendedPerfume] = []

    private static let apiKey: String = Config.EXPO_PUBLIC_FRAGELLA_API_KEY
    private static let baseURL = "https://api.fragella.com/api/v1"

    func generateRecommendations(from perfumes: [Perfume], wearEntries: [WearEntry] = []) async -> [RecommendedPerfume] {
        isLoading = true
        defer { isLoading = false }

        let notePrefs = OnboardingManager.shared.notePreferences.favoriteNotes
        let tasteProfile = buildTasteProfile(perfumes: perfumes, wearEntries: wearEntries, notePrefs: notePrefs)
        let userPrefs = extractUserPreferences(perfumes: perfumes)

        let searchTerms = buildSearchTerms(perfumes: perfumes, notePrefs: notePrefs, tasteProfile: tasteProfile)

        var allCandidates: [FragellaCandidate] = []
        var seenKeys: Set<String> = []

        await withTaskGroup(of: [FragellaCandidate].self) { group in
            for term in searchTerms {
                group.addTask {
                    await self.searchFragella(query: term)
                }
            }
            for await results in group {
                for candidate in results {
                    let key = "\(candidate.name.lowercased())|\(candidate.brand.lowercased())"
                    if seenKeys.insert(key).inserted {
                        allCandidates.append(candidate)
                    }
                }
            }
        }

        if allCandidates.isEmpty {
            let fallbackTerms = ["sauvage", "baccarat rouge", "aventus", "bleu de chanel", "tobacco vanille", "black opium", "good girl", "light blue"]
            for term in fallbackTerms {
                let results = await searchFragella(query: term)
                for candidate in results {
                    let key = "\(candidate.name.lowercased())|\(candidate.brand.lowercased())"
                    if seenKeys.insert(key).inserted {
                        allCandidates.append(candidate)
                    }
                }
            }
        }

        let ownedSet = Set(perfumes.map { "\($0.name.lowercased())|\($0.brand.lowercased())" })

        let idfMap = computeIDF(candidates: allCandidates)

        var scored: [(FragellaCandidate, Double, String)] = []

        for candidate in allCandidates {
            let key = "\(candidate.name.lowercased())|\(candidate.brand.lowercased())"
            guard !ownedSet.contains(key) else { continue }

            let nameMatch = perfumes.contains { p in
                let pName = p.name.lowercased().trimmingCharacters(in: .whitespaces)
                let cName = candidate.name.lowercased().trimmingCharacters(in: .whitespaces)
                return pName == cName || (pName.contains(cName) && cName.count > 3) || (cName.contains(pName) && pName.count > 3)
            }
            guard !nameMatch else { continue }

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

            let noteList = candidate.allNotes.prefix(4).joined(separator: ", ")
            let description = "\(candidate.concentration) by \(candidate.brand) featuring \(noteList)."

            results.append(RecommendedPerfume(
                name: candidate.name,
                brand: candidate.brand,
                imageURL: candidate.imageURL,
                description: description,
                notes: candidate.allNotes,
                matchReason: reason,
                matchPercentage: percentage,
                concentration: candidate.concentration
            ))

            if results.count >= 9 { break }
        }

        return rotateResults(results)
    }

    private func buildSearchTerms(perfumes: [Perfume], notePrefs: [String], tasteProfile: [String: Double]) -> [String] {
        var terms: Set<String> = []

        let topNotes = tasteProfile.sorted { $0.value > $1.value }.prefix(5).map { $0.key }
        for note in topNotes {
            terms.insert(note)
        }

        for note in notePrefs.prefix(3) {
            terms.insert(note.lowercased())
        }

        var brandCounts: [String: Int] = [:]
        for p in perfumes {
            brandCounts[p.brand, default: 0] += 1
        }
        let topBrands = brandCounts.sorted { $0.value > $1.value }.prefix(3).map { $0.key }
        for brand in topBrands {
            terms.insert(brand)
        }

        let popularSearches = ["oud", "vanilla", "rose", "musk", "amber", "sandalwood", "bergamot", "vetiver"]
        for search in popularSearches.prefix(3) {
            if !terms.contains(search) {
                terms.insert(search)
                if terms.count >= 12 { break }
            }
        }

        if terms.isEmpty {
            terms = ["sauvage", "aventus", "baccarat rouge", "tobacco vanille", "bleu de chanel", "la vie est belle"]
        }

        return Array(terms.prefix(12))
    }

    private func searchFragella(query: String) async -> [FragellaCandidate] {
        guard !Self.apiKey.isEmpty else { return [] }

        var components = URLComponents(string: "\(Self.baseURL)/fragrances")
        components?.queryItems = [
            URLQueryItem(name: "search", value: query),
            URLQueryItem(name: "limit", value: "10")
        ]

        guard let url = components?.url else { return [] }

        var request = URLRequest(url: url)
        request.setValue(Self.apiKey, forHTTPHeaderField: "x-api-key")
        request.timeoutInterval = 10

        do {
            let (data, response) = try await URLSession.shared.data(for: request)
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            guard statusCode == 200 else { return [] }
            return parseCandidates(from: data)
        } catch {
            return []
        }
    }

    private func parseCandidates(from data: Data) -> [FragellaCandidate] {
        guard let jsonArray = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] else {
            return []
        }

        return jsonArray.compactMap { dict -> FragellaCandidate? in
            guard let name = dict["Name"] as? String,
                  let brand = dict["Brand"] as? String else { return nil }

            let concentration = (dict["OilType"] as? String) ?? "Eau de Parfum"
            let rawImageURL = dict["Image URL"] as? String
                ?? dict["ImageURL"] as? String
                ?? dict["image_url"] as? String
                ?? dict["imageUrl"] as? String
                ?? dict["Image"] as? String
                ?? dict["image"] as? String
            let imageURL = Self.sanitizeImageURL(rawImageURL)

            var topNotes: [String] = []
            var heartNotes: [String] = []
            var baseNotes: [String] = []

            if let notes = dict["Notes"] as? [String: Any] {
                topNotes = extractNoteNames(from: notes["TopNotes"] ?? notes["Top Notes"])
                heartNotes = extractNoteNames(from: notes["HeartNotes"] ?? notes["Heart Notes"] ?? notes["MiddleNotes"] ?? notes["Middle Notes"])
                baseNotes = extractNoteNames(from: notes["BaseNotes"] ?? notes["Base Notes"])
            }

            let gender = (dict["Gender"] as? String) ?? "Unisex"

            return FragellaCandidate(
                name: name,
                brand: brand,
                concentration: concentration,
                gender: gender,
                topNotes: topNotes,
                heartNotes: heartNotes,
                baseNotes: baseNotes,
                imageURL: imageURL
            )
        }
    }

    private static func sanitizeImageURL(_ raw: String?) -> String? {
        guard var urlString = raw, !urlString.isEmpty else { return nil }
        urlString = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if urlString.hasPrefix("//") {
            urlString = "https:" + urlString
        }
        if !urlString.hasPrefix("http://") && !urlString.hasPrefix("https://") {
            urlString = "https://" + urlString
        }
        guard URL(string: urlString) != nil else { return nil }
        return urlString
    }

    private func extractNoteNames(from value: Any?) -> [String] {
        guard let value else { return [] }
        if let stringArray = value as? [String] {
            return stringArray
        }
        if let dictArray = value as? [[String: Any]] {
            return dictArray.compactMap { $0["Name"] as? String ?? $0["name"] as? String }
        }
        return []
    }

    private func computeIDF(candidates: [FragellaCandidate]) -> [String: Double] {
        let total = Double(max(candidates.count, 1))
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
        let primaryGender = "Unisex"

        return UserPreferences(primaryGender: primaryGender, topConcentration: topConc, brandCounts: brandCounts)
    }

    private func scoreCandidate(
        candidate: FragellaCandidate,
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
}

nonisolated struct FragellaCandidate: Sendable {
    let name: String
    let brand: String
    let concentration: String
    let gender: String
    let topNotes: [String]
    let heartNotes: [String]
    let baseNotes: [String]
    let imageURL: String?

    var allNotes: [String] { topNotes + heartNotes + baseNotes }
}
