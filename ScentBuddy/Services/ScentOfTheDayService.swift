import Foundation

struct ScentOfTheDay {
    let perfumeName: String
    let perfumeBrand: String
    let reason: String
    let icon: String
}

struct ScentOfTheDayService {
    private let calendar = Calendar.current

    func suggest(from perfumes: [Perfume], wearEntries: [WearEntry]) -> ScentOfTheDay? {
        guard !perfumes.isEmpty else { return nil }

        let today = Date()
        let month = calendar.component(.month, from: today)
        let dayOfYear = calendar.ordinality(of: .day, in: .year, for: today) ?? 1

        let currentSeason: String
        switch month {
        case 3...5: currentSeason = "Spring"
        case 6...8: currentSeason = "Summer"
        case 9...11: currentSeason = "Fall"
        default: currentSeason = "Winter"
        }

        let recentlyWorn = Set(
            wearEntries
                .filter { calendar.isDate($0.date, equalTo: today, toGranularity: .weekOfYear) }
                .map { $0.perfumeName }
        )

        var candidates = perfumes.filter { !recentlyWorn.contains($0.name) }
        if candidates.isEmpty { candidates = perfumes }

        let seasonalMatches = candidates.filter {
            $0.season == currentSeason || $0.season == "All Seasons"
        }

        let pool = seasonalMatches.isEmpty ? candidates : seasonalMatches

        let favorites = pool.filter { $0.isFavorite }
        let finalPool = favorites.isEmpty ? pool : (Bool.random() ? favorites : pool)

        let index = dayOfYear % finalPool.count
        let pick = finalPool[index]

        let reasons: [(String, String)]
        if pick.season == currentSeason {
            reasons = [
                ("Perfect for \(currentSeason.lowercased()) days", "sun.max.fill"),
                ("A \(currentSeason.lowercased()) signature", "leaf.fill"),
            ]
        } else if pick.isFavorite {
            reasons = [
                ("One of your all-time favorites", "heart.fill"),
                ("A crowd-pleaser from your collection", "star.fill"),
            ]
        } else {
            reasons = [
                ("Give this gem some wrist time", "sparkles"),
                ("Rediscover a hidden treasure", "wand.and.stars"),
            ]
        }

        let reasonPick = reasons[dayOfYear % reasons.count]

        return ScentOfTheDay(
            perfumeName: pick.name,
            perfumeBrand: pick.brand,
            reason: reasonPick.0,
            icon: reasonPick.1
        )
    }
}
