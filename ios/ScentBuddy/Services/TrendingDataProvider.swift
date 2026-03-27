import Foundation

nonisolated struct TrendingDataProvider: Sendable {

    static func generateTrendingList() -> [TrendingPerfume] {
        let currentMonth = Calendar.current.component(.month, from: Date())
        let season = getSeason(month: currentMonth)
        let dayOfYear = getDayOfYear()

        let viralPicks = shuffleWithSeed(viralPool(), seed: dayOfYear * 7).prefix(4)
        let newReleasePicks = shuffleWithSeed(newReleasePool(), seed: dayOfYear * 13).prefix(3)
        let nichePicks = shuffleWithSeed(nichePool(), seed: dayOfYear * 19).prefix(3)
        let classicPicks = shuffleWithSeed(classicPool(), seed: dayOfYear * 23).prefix(2)
        let seasonalPicks = shuffleWithSeed(seasonalPool(season: season), seed: dayOfYear * 31).prefix(3)

        return Array(viralPicks) + Array(newReleasePicks) + Array(nichePicks) + Array(classicPicks) + Array(seasonalPicks)
    }

    private static func getDayOfYear() -> Int {
        Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
    }

    private static func getSeason(month: Int) -> String {
        switch month {
        case 3...5: return "spring"
        case 6...8: return "summer"
        case 9...11: return "fall"
        default: return "winter"
        }
    }

    private static func shuffleWithSeed(_ arr: [TrendingPerfume], seed: Int) -> [TrendingPerfume] {
        var result = arr
        var s = seed
        for i in stride(from: result.count - 1, through: 1, by: -1) {
            s = (s &* 16807) % 2147483647
            let j = abs(s) % (i + 1)
            result.swapAt(i, j)
        }
        return result
    }

    private static let today: String = {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: Date())
    }()

    private static func viralPool() -> [TrendingPerfume] {
        [
            TrendingPerfume(name: "Lattafa Khamrah", brand: "Lattafa", imageURL: nil, description: "A rich gourmand with cinnamon, vanilla, and oud that rivals niche fragrances costing 10x more.", notes: ["Cinnamon", "Nutmeg", "Dates", "Praline", "Vanilla", "Tonka Bean", "Benzoin"], trendReason: "#1 on PerfumeTok — dubbed 'rich people smell for $30'", releaseYear: 2022, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "5,200,000+", socialSource: "TikTok #PerfumeTok, Instagram", hashtagCount: "#khamrah — 2.1M views", lastSeenTrending: today),
            TrendingPerfume(name: "Baccarat Rouge 540", brand: "Maison Francis Kurkdjian", imageURL: nil, description: "The cultural phenomenon — a saffron-jasmine-amberwood blend that defined a generation of fragrance lovers.", notes: ["Saffron", "Jasmine", "Amberwood", "Ambergris", "Fir Resin", "Cedar"], trendReason: "8.7M+ social mentions — the scent that started #PerfumeTok", releaseYear: 2015, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "8,700,000+", socialSource: "TikTok, Instagram, YouTube", hashtagCount: "#baccaratrouge540 — 530M views", lastSeenTrending: today),
            TrendingPerfume(name: "Ariana Grande Cloud", brand: "Ariana Grande", imageURL: nil, description: "A dreamy lavender-coconut-musk cloud that TikTok crowned the best affordable BR540 alternative.", notes: ["Lavender Blossom", "Pear", "Coconut", "Praline", "Musk", "Cashmere Wood"], trendReason: "#1 celebrity fragrance on TikTok — the affordable BR540 dupe", releaseYear: 2018, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "4,100,000+", socialSource: "TikTok #PerfumeTok", hashtagCount: "#arianacloud — 180M views", lastSeenTrending: today),
            TrendingPerfume(name: "Bianco Latte", brand: "Giardini di Toscana", imageURL: nil, description: "An irresistible milky vanilla that smells like Italian dessert — the 'you smell expensive' scent.", notes: ["Milk", "Vanilla", "Caramel", "White Musk", "Sandalwood"], trendReason: "Blew up on TikTok as the 'you smell expensive' scent of 2025", releaseYear: 2019, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "3,800,000+", socialSource: "TikTok, YouTube", hashtagCount: "#biancolatte — 95M views", lastSeenTrending: today),
            TrendingPerfume(name: "Sol de Janeiro Brazilian Bum Bum", brand: "Sol de Janeiro", imageURL: nil, description: "A warm, addictive caramel-vanilla-sandalwood inspired by Brazilian beach culture.", notes: ["Caramel", "Vanilla", "Sandalwood", "Coconut", "Pistachio"], trendReason: "Mega-viral for its addictive sweet warmth — 'compliment magnet'", releaseYear: 2023, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "2,900,000+", socialSource: "TikTok, Instagram Reels", hashtagCount: "#brazilianbumbum — 62M views", lastSeenTrending: today),
            TrendingPerfume(name: "Kayali Vanilla 28", brand: "Kayali", imageURL: nil, description: "Huda Beauty's warm vanilla with brown sugar and tonka bean — the layering queen.", notes: ["Vanilla", "Brown Sugar", "Tonka Bean", "Amber", "Musk"], trendReason: "Huda Beauty fragrance going viral for layering combos on TikTok", releaseYear: 2018, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "2,400,000+", socialSource: "TikTok #PerfumeTok, YouTube", hashtagCount: "#kayalivanilla — 45M views", lastSeenTrending: today),
            TrendingPerfume(name: "Parfums de Marly Delina", brand: "Parfums de Marly", imageURL: nil, description: "A sophisticated Turkish rose and lychee floral with vanilla base — the 'it girl' perfume.", notes: ["Rose", "Lychee", "Peony", "Vanilla", "Musk", "Cashmeran"], trendReason: "The 'it girl' perfume dominating fragrance TikTok", releaseYear: 2017, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "3,500,000+", socialSource: "TikTok, Instagram", hashtagCount: "#delina — 120M views", lastSeenTrending: today),
            TrendingPerfume(name: "Lattafa Yara", brand: "Lattafa", imageURL: nil, description: "A sweet tropical orchid scent — the $20 dupe that broke TikTok.", notes: ["Orchid", "Tangerine", "Vanilla", "Musk", "Sandalwood", "Amber"], trendReason: "The $20 dupe that broke TikTok — compared to $300 Delina", releaseYear: 2021, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "2,100,000+", socialSource: "TikTok #dupetok", hashtagCount: "#lattafayara — 78M views", lastSeenTrending: today),
            TrendingPerfume(name: "Maison Margiela Lazy Sunday Morning", brand: "Maison Margiela", imageURL: nil, description: "Fresh linens and lily of the valley — the 'clean girl aesthetic' signature scent.", notes: ["Lily of the Valley", "Rose", "White Musk", "Iris", "Pear"], trendReason: "Clean girl aesthetic favorite — 'sheets fresh from the dryer'", releaseYear: 2012, concentration: "Eau de Toilette", category: .viral, tiktokMentions: "1,800,000+", socialSource: "TikTok #cleangirl", hashtagCount: "#lazysundaymorning — 34M views", lastSeenTrending: today),
            TrendingPerfume(name: "Miu Miu Fleur de Lait", brand: "Miu Miu", imageURL: nil, description: "The 'mango milkshake dream' — a soft lactonic scent that went viral for its unique freshness.", notes: ["Mango Sorbet", "Coconut Milk", "Osmanthus", "Sandalwood", "Musk"], trendReason: "2026's breakout viral scent — the 'mango milkshake' perfume", releaseYear: 2025, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "1,500,000+", socialSource: "TikTok #PerfumeTok", hashtagCount: "#fleurdelait — 28M views", lastSeenTrending: today),
            TrendingPerfume(name: "Le Labo Another 13", brand: "Le Labo", imageURL: nil, description: "A synthetic skin scent that smells like you, but better — created with AnOther Magazine.", notes: ["Ambroxan", "Jasmine Petals", "Moss", "Musk"], trendReason: "The ultimate 'your skin but better' scent on TikTok", releaseYear: 2010, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "1,600,000+", socialSource: "TikTok, Instagram", hashtagCount: "#another13 — 42M views", lastSeenTrending: today),
            TrendingPerfume(name: "Narciso Rodriguez For Her", brand: "Narciso Rodriguez", imageURL: nil, description: "A musk-forward masterpiece — TikTok's favorite 'quiet luxury' scent.", notes: ["Musk", "Amber", "Rose", "Peach", "Sandalwood"], trendReason: "Trending as the 'quiet luxury' scent on PerfumeTok", releaseYear: 2003, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "1,200,000+", socialSource: "TikTok #quietluxury", hashtagCount: "#narcisorodriguez — 55M views", lastSeenTrending: today),
            TrendingPerfume(name: "French Avenue Liquid Brun", brand: "French Avenue", imageURL: nil, description: "The perfect Althair alternative — orange blossom, cinnamon, and bourbon vanilla with a nutty finish.", notes: ["Orange Blossom", "Cinnamon", "Bourbon Vanilla", "Almond", "Tonka Bean"], trendReason: "Viral as the '$30 Althair dupe' — niche quality at designer price", releaseYear: 2024, concentration: "Eau de Parfum", category: .viral, tiktokMentions: "980,000+", socialSource: "TikTok #dupetok", hashtagCount: "#liquidbrun — 15M views", lastSeenTrending: today),
        ]
    }

    private static func newReleasePool() -> [TrendingPerfume] {
        let year = Calendar.current.component(.year, from: Date())
        return [
            TrendingPerfume(name: "Dior Privée Oud Rosewood", brand: "Dior", imageURL: nil, description: "An exquisite blend of rare oud and delicate rosewood from Dior's exclusive Privée line.", notes: ["Oud", "Rosewood", "Sandalwood", "Rose", "Amber"], trendReason: "Latest drop from Dior's prestigious Privée collection", releaseYear: year, concentration: "Eau de Parfum", category: .newRelease, tiktokMentions: "450,000+", socialSource: "YouTube, Instagram", hashtagCount: "#diorprivee — 12M views", lastSeenTrending: today),
            TrendingPerfume(name: "Maison Francis Kurkdjian Gentle Fluidity Gold", brand: "MFK", imageURL: nil, description: "A warm, enveloping amber with vanilla and musk — MFK's latest crowd-pleaser.", notes: ["Amber", "Vanilla", "Musk", "Sandalwood", "Coriander"], trendReason: "\(year) flanker generating massive hype in fragrance communities", releaseYear: year, concentration: "Eau de Parfum", category: .newRelease, tiktokMentions: "680,000+", socialSource: "TikTok, Fragrantica", hashtagCount: "#gentlefluidity — 8M views", lastSeenTrending: today),
            TrendingPerfume(name: "Valentino Donna Born In Roma Green Stravaganza", brand: "Valentino", imageURL: nil, description: "A fresh green floral twist on the beloved Born in Roma line.", notes: ["Green Tea", "Jasmine", "Vetiver", "Vanilla", "Cashmeran"], trendReason: "New drop creating buzz — the freshest Born in Roma yet", releaseYear: year, concentration: "Eau de Parfum", category: .newRelease, tiktokMentions: "520,000+", socialSource: "TikTok, Instagram", hashtagCount: "#borninroma — 35M views", lastSeenTrending: today),
            TrendingPerfume(name: "YSL Libre Le Parfum", brand: "Yves Saint Laurent", imageURL: nil, description: "The most intense Libre yet — lavender and orange blossom amped up with vanilla.", notes: ["Lavender", "Orange Blossom", "Vanilla", "Tonka Bean", "Cedar"], trendReason: "YSL's most intense Libre flanker yet — instant bestseller", releaseYear: year, concentration: "Le Parfum", category: .newRelease, tiktokMentions: "890,000+", socialSource: "TikTok, YouTube", hashtagCount: "#yslibre — 48M views", lastSeenTrending: today),
            TrendingPerfume(name: "Byredo Sundazed", brand: "Byredo", imageURL: nil, description: "A joyful burst of mandarin and cotton candy sweetness — limited edition.", notes: ["Mandarin", "Lemon", "Cotton Candy", "Vanilla", "Jasmine"], trendReason: "Limited edition generating collector frenzy", releaseYear: year, concentration: "Eau de Parfum", category: .newRelease, tiktokMentions: "340,000+", socialSource: "TikTok, Instagram", hashtagCount: "#byredo — 22M views", lastSeenTrending: today),
            TrendingPerfume(name: "Prada Paradoxe Intense", brand: "Prada", imageURL: nil, description: "A deeper, richer take on the original Paradoxe with amber and vanilla.", notes: ["Amber", "Vanilla", "Jasmine", "Musk", "Neroli"], trendReason: "Prada's Paradoxe franchise keeps growing — the best flanker yet", releaseYear: year, concentration: "Eau de Parfum Intense", category: .newRelease, tiktokMentions: "720,000+", socialSource: "TikTok, YouTube", hashtagCount: "#pradaparadoxe — 18M views", lastSeenTrending: today),
        ]
    }

    private static func classicPool() -> [TrendingPerfume] {
        [
            TrendingPerfume(name: "Chanel No. 5", brand: "Chanel", imageURL: nil, description: "The world's most iconic fragrance — a complex floral aldehyde masterpiece.", notes: ["Aldehydes", "Rose", "Jasmine", "Vanilla", "Sandalwood", "Vetiver"], trendReason: "100+ years and still the most recognized perfume on Earth", releaseYear: 1921, concentration: "Eau de Parfum", category: .classic, tiktokMentions: "2,100,000+", socialSource: "TikTok, YouTube, Instagram", hashtagCount: "#chanelno5 — 89M views", lastSeenTrending: today),
            TrendingPerfume(name: "Tom Ford Tuscan Leather", brand: "Tom Ford", imageURL: nil, description: "A bold, animalic leather with raspberry and saffron — the leather benchmark.", notes: ["Leather", "Raspberry", "Saffron", "Jasmine", "Thyme"], trendReason: "The benchmark for leather fragrances — still unmatched", releaseYear: 2007, concentration: "Eau de Parfum", category: .classic, tiktokMentions: "1,400,000+", socialSource: "TikTok, YouTube", hashtagCount: "#tuscanleather — 38M views", lastSeenTrending: today),
            TrendingPerfume(name: "Dior Homme Intense", brand: "Dior", imageURL: nil, description: "An elegant iris-cocoa masterpiece — widely regarded as one of the greatest designers ever.", notes: ["Iris", "Lavender", "Vanilla", "Cedar", "Amber", "Cocoa"], trendReason: "Considered one of the greatest designer fragrances ever created", releaseYear: 2011, concentration: "Eau de Parfum", category: .classic, tiktokMentions: "980,000+", socialSource: "TikTok, Fragrantica", hashtagCount: "#diorhomme — 25M views", lastSeenTrending: today),
            TrendingPerfume(name: "Creed Aventus", brand: "Creed", imageURL: nil, description: "The king of niche masculine fragrances — pineapple, birch, and musk.", notes: ["Pineapple", "Birch", "Musk", "Oakmoss", "Vanilla", "Bergamot"], trendReason: "Still the most discussed men's fragrance of all time", releaseYear: 2010, concentration: "Eau de Parfum", category: .classic, tiktokMentions: "3,200,000+", socialSource: "TikTok, YouTube, Reddit", hashtagCount: "#creedaventus — 150M views", lastSeenTrending: today),
            TrendingPerfume(name: "Tom Ford Lost Cherry", brand: "Tom Ford", imageURL: nil, description: "A decadent cherry-almond liqueur with Turkish rose and Peru balsam.", notes: ["Cherry", "Almond", "Turkish Rose", "Peru Balsam", "Tonka Bean"], trendReason: "The cherry fragrance that launched a thousand dupes", releaseYear: 2018, concentration: "Eau de Parfum", category: .classic, tiktokMentions: "2,800,000+", socialSource: "TikTok #dupetok", hashtagCount: "#lostcherry — 95M views", lastSeenTrending: today),
            TrendingPerfume(name: "Chanel Bleu de Chanel", brand: "Chanel", imageURL: nil, description: "The effortlessly sophisticated everyday scent — citrus, cedar, and sandalwood.", notes: ["Citrus", "Mint", "Cedar", "Sandalwood", "Incense"], trendReason: "The #1 'safe blind buy' recommended by every fragrance creator", releaseYear: 2010, concentration: "Eau de Parfum", category: .classic, tiktokMentions: "2,500,000+", socialSource: "TikTok, YouTube", hashtagCount: "#bleudechanel — 110M views", lastSeenTrending: today),
        ]
    }

    private static func nichePool() -> [TrendingPerfume] {
        [
            TrendingPerfume(name: "Xerjoff Naxos", brand: "Xerjoff", imageURL: nil, description: "A tobacco-honey masterpiece inspired by the ancient city — widely considered the GOAT.", notes: ["Tobacco", "Honey", "Lavender", "Vanilla", "Tonka Bean", "Cashmeran"], trendReason: "Widely considered the best tobacco fragrance ever made", releaseYear: 2015, concentration: "Eau de Parfum", category: .niche, tiktokMentions: "1,100,000+", socialSource: "TikTok, YouTube, Fragrantica", hashtagCount: "#xerjoffnaxos — 28M views", lastSeenTrending: today),
            TrendingPerfume(name: "Nishane Hacivat", brand: "Nishane", imageURL: nil, description: "A fresh fruity-woody scent — the niche Aventus alternative everyone recommends.", notes: ["Pineapple", "Grapefruit", "Patchouli", "Cedar", "Oakmoss", "Bergamot"], trendReason: "The niche Aventus alternative that fragrance reviewers love", releaseYear: 2017, concentration: "Extrait de Parfum", category: .niche, tiktokMentions: "780,000+", socialSource: "TikTok, YouTube", hashtagCount: "#hacivat — 18M views", lastSeenTrending: today),
            TrendingPerfume(name: "Initio Oud for Greatness", brand: "Initio", imageURL: nil, description: "A powerful oud-saffron combination with lavender freshness — the power scent.", notes: ["Oud", "Saffron", "Lavender", "Musk", "Nutmeg"], trendReason: "The ultimate power fragrance — boardroom to black tie", releaseYear: 2018, concentration: "Eau de Parfum", category: .niche, tiktokMentions: "920,000+", socialSource: "TikTok, YouTube", hashtagCount: "#oudforgreatness — 22M views", lastSeenTrending: today),
            TrendingPerfume(name: "Amouage Interlude Man", brand: "Amouage", imageURL: nil, description: "A smoky, resinous masterpiece of controlled chaos — incense and oud like no other.", notes: ["Incense", "Oud", "Amber", "Oregano", "Bergamot", "Myrrh"], trendReason: "The ultimate 'power scent' with cult status in niche circles", releaseYear: 2012, concentration: "Eau de Parfum", category: .niche, tiktokMentions: "650,000+", socialSource: "YouTube, Fragrantica", hashtagCount: "#amouage — 15M views", lastSeenTrending: today),
            TrendingPerfume(name: "Thameen Peregrina", brand: "Thameen", imageURL: nil, description: "A luminous white floral built around the world's most famous pearl.", notes: ["Rose", "Jasmine", "Oud", "Musk", "Amber", "Sandalwood"], trendReason: "Rising star in luxury niche — the 'hidden gem' everyone whispers about", releaseYear: 2016, concentration: "Extrait de Parfum", category: .niche, tiktokMentions: "340,000+", socialSource: "YouTube, Fragrantica", hashtagCount: "#thameen — 5M views", lastSeenTrending: today),
            TrendingPerfume(name: "Memo Paris Sintra", brand: "Memo Paris", imageURL: nil, description: "An enchanting floral-gourmand inspired by Portuguese gardens.", notes: ["Rose", "Vanilla", "Sandalwood", "Tonka Bean", "Plum"], trendReason: "Fragrance community darling with cult following", releaseYear: 2023, concentration: "Eau de Parfum", category: .niche, tiktokMentions: "280,000+", socialSource: "YouTube, Instagram", hashtagCount: "#memoparis — 4M views", lastSeenTrending: today),
            TrendingPerfume(name: "Kilian Angels' Share", brand: "Kilian", imageURL: nil, description: "A boozy cognac-soaked vanilla with cinnamon warmth — heaven in a bottle.", notes: ["Cognac", "Cinnamon", "Vanilla", "Oak", "Tonka Bean", "Praline"], trendReason: "The boozy fragrance that TikTok can't stop talking about", releaseYear: 2020, concentration: "Eau de Parfum", category: .niche, tiktokMentions: "1,800,000+", socialSource: "TikTok, YouTube", hashtagCount: "#angelsshare — 65M views", lastSeenTrending: today),
            TrendingPerfume(name: "BDK Parfums Gris Charnel", brand: "BDK Parfums", imageURL: nil, description: "A sophisticated fig-sandalwood-cardamom that's become the internet's favorite niche discovery.", notes: ["Fig", "Sandalwood", "Cardamom", "Vetiver", "Musk"], trendReason: "The 'hidden niche gem' that fragrance TikTok discovered", releaseYear: 2019, concentration: "Eau de Parfum", category: .niche, tiktokMentions: "420,000+", socialSource: "TikTok, YouTube", hashtagCount: "#grischarnel — 8M views", lastSeenTrending: today),
        ]
    }

    private static func seasonalPool(season: String) -> [TrendingPerfume] {
        switch season {
        case "spring": return springPool()
        case "summer": return summerPool()
        case "fall": return fallPool()
        default: return winterPool()
        }
    }

    private static func springPool() -> [TrendingPerfume] {
        [
            TrendingPerfume(name: "Chanel Chance Eau Tendre", brand: "Chanel", imageURL: nil, description: "A delicate fruity-floral with grapefruit and jasmine — spring in a bottle.", notes: ["Grapefruit", "Jasmine", "White Musk", "Cedar", "Rose"], trendReason: "The perfect spring awakening scent — trending every March", releaseYear: 2010, concentration: "Eau de Parfum", category: .seasonal, tiktokMentions: "1,400,000+", socialSource: "TikTok #springscents", hashtagCount: "#chanceeau — 42M views", lastSeenTrending: today),
            TrendingPerfume(name: "Jo Malone English Pear & Freesia", brand: "Jo Malone", imageURL: nil, description: "Lush pears wrapped in white freesias — a quintessential spring garden.", notes: ["Pear", "Freesia", "Patchouli", "Amber", "Rose Hip"], trendReason: "A quintessential spring garden in a bottle", releaseYear: 2010, concentration: "Cologne", category: .seasonal, tiktokMentions: "890,000+", socialSource: "TikTok, Instagram", hashtagCount: "#jomalone — 55M views", lastSeenTrending: today),
            TrendingPerfume(name: "Acqua di Parma Blu Mediterraneo", brand: "Acqua di Parma", imageURL: nil, description: "Fresh Italian citrus and aromatic herbs — the Mediterranean coast in a bottle.", notes: ["Bergamot", "Lemon", "Rosemary", "Cedar", "Myrtle"], trendReason: "The ultimate fresh start for the new season", releaseYear: 1999, concentration: "Eau de Toilette", category: .seasonal, tiktokMentions: "560,000+", socialSource: "YouTube, Instagram", hashtagCount: "#acquadiparma — 18M views", lastSeenTrending: today),
            TrendingPerfume(name: "Clean Reserve Skin", brand: "Clean Reserve", imageURL: nil, description: "A soft, warm skin scent with a clean finish — the minimalist spring choice.", notes: ["Musk", "Vanilla", "Sandalwood", "Orange Blossom"], trendReason: "The 'clean girl spring' essential on TikTok", releaseYear: 2016, concentration: "Eau de Parfum", category: .seasonal, tiktokMentions: "720,000+", socialSource: "TikTok #cleangirl", hashtagCount: "#cleanreserve — 12M views", lastSeenTrending: today),
        ]
    }

    private static func summerPool() -> [TrendingPerfume] {
        [
            TrendingPerfume(name: "Dolce & Gabbana Light Blue", brand: "Dolce & Gabbana", imageURL: nil, description: "The essence of a Mediterranean summer — fresh, crisp, and iconic.", notes: ["Lemon", "Apple", "Cedar", "Musk", "Amber", "Bamboo"], trendReason: "Perennial summer favorite that never goes out of style", releaseYear: 2001, concentration: "Eau de Toilette", category: .seasonal, tiktokMentions: "2,800,000+", socialSource: "TikTok, Instagram", hashtagCount: "#lightblue — 85M views", lastSeenTrending: today),
            TrendingPerfume(name: "Versace Pour Homme", brand: "Versace", imageURL: nil, description: "A fresh, aquatic Mediterranean fragrance — the ultimate summer beach day.", notes: ["Lemon", "Neroli", "Amber", "Cedar", "Musk", "Sage"], trendReason: "The ultimate summer beach day fragrance", releaseYear: 2008, concentration: "Eau de Toilette", category: .seasonal, tiktokMentions: "1,500,000+", socialSource: "TikTok, YouTube", hashtagCount: "#versacepourhomme — 32M views", lastSeenTrending: today),
            TrendingPerfume(name: "Tom Ford Neroli Portofino", brand: "Tom Ford", imageURL: nil, description: "A vibrant citrus floral capturing the Italian Riviera.", notes: ["Neroli", "Bergamot", "Lemon", "Amber", "Musk"], trendReason: "The luxury summer scent celebrities wear on vacation", releaseYear: 2011, concentration: "Eau de Parfum", category: .seasonal, tiktokMentions: "780,000+", socialSource: "YouTube, Instagram", hashtagCount: "#neroliportofino — 12M views", lastSeenTrending: today),
            TrendingPerfume(name: "Le Labo Santal 33", brand: "Le Labo", imageURL: nil, description: "The iconic unisex sandalwood that defines NYC cool — leather, cedar, and musk.", notes: ["Sandalwood", "Cedar", "Leather", "Cardamom", "Iris", "Musk"], trendReason: "The 'I just got back from NYC' summer scent", releaseYear: 2011, concentration: "Eau de Parfum", category: .seasonal, tiktokMentions: "2,200,000+", socialSource: "TikTok, Instagram", hashtagCount: "#santal33 — 75M views", lastSeenTrending: today),
        ]
    }

    private static func fallPool() -> [TrendingPerfume] {
        [
            TrendingPerfume(name: "Maison Margiela By The Fireplace", brand: "Maison Margiela", imageURL: nil, description: "Chestnuts roasting by a crackling fire — the quintessential fall comfort scent.", notes: ["Pepper", "Vanilla", "Tobacco", "Sandalwood", "Incense", "Chestnut"], trendReason: "The #1 fall fragrance on TikTok every single year", releaseYear: 2015, concentration: "Eau de Toilette", category: .seasonal, tiktokMentions: "3,200,000+", socialSource: "TikTok #fallscents", hashtagCount: "#bythefireplace — 92M views", lastSeenTrending: today),
            TrendingPerfume(name: "Tom Ford Tobacco Vanille", brand: "Tom Ford", imageURL: nil, description: "Opulent tobacco leaf and aromatic spices infused with vanilla — warm and unforgettable.", notes: ["Tobacco", "Vanilla", "Cocoa", "Dried Fruits", "Tonka Bean", "Ginger"], trendReason: "The king of fall fragrances — warm, rich, unforgettable", releaseYear: 2007, concentration: "Eau de Parfum", category: .seasonal, tiktokMentions: "2,600,000+", socialSource: "TikTok, YouTube", hashtagCount: "#tobaccovanille — 68M views", lastSeenTrending: today),
            TrendingPerfume(name: "Replica Autumn Vibes", brand: "Maison Margiela", imageURL: nil, description: "A walk through fallen leaves on a crisp autumn morning.", notes: ["Cardamom", "Ginger", "Cedar", "Musk", "Amber", "Pink Pepper"], trendReason: "The perfect transition scent from summer to fall", releaseYear: 2021, concentration: "Eau de Toilette", category: .seasonal, tiktokMentions: "890,000+", socialSource: "TikTok, Instagram", hashtagCount: "#autumnvibes — 22M views", lastSeenTrending: today),
            TrendingPerfume(name: "Guerlain L'Homme Ideal EDP", brand: "Guerlain", imageURL: nil, description: "Cherry, almond, and vanilla wrapped in smoky leather — sophisticated autumn warmth.", notes: ["Cherry", "Almond", "Vanilla", "Leather", "Sandalwood"], trendReason: "Trending as the sophisticated autumn date-night choice", releaseYear: 2016, concentration: "Eau de Parfum", category: .seasonal, tiktokMentions: "720,000+", socialSource: "YouTube, TikTok", hashtagCount: "#lhommeideal — 15M views", lastSeenTrending: today),
        ]
    }

    private static func winterPool() -> [TrendingPerfume] {
        [
            TrendingPerfume(name: "Parfums de Marly Layton", brand: "Parfums de Marly", imageURL: nil, description: "Apple, vanilla, and cardamom — the #1 cold-weather crowd pleaser year after year.", notes: ["Apple", "Cardamom", "Vanilla", "Sandalwood", "Amber", "Pepper"], trendReason: "The #1 cold-weather crowd pleaser — every winter without fail", releaseYear: 2016, concentration: "Eau de Parfum", category: .seasonal, tiktokMentions: "2,900,000+", socialSource: "TikTok, YouTube", hashtagCount: "#pdmlayton — 85M views", lastSeenTrending: today),
            TrendingPerfume(name: "Kilian Angels' Share", brand: "Kilian", imageURL: nil, description: "A boozy cognac-soaked vanilla with cinnamon — cozy winter in a bottle.", notes: ["Cognac", "Cinnamon", "Vanilla", "Oak", "Tonka Bean"], trendReason: "The cozy winter evening scent everyone craves", releaseYear: 2020, concentration: "Eau de Parfum", category: .seasonal, tiktokMentions: "1,800,000+", socialSource: "TikTok, YouTube", hashtagCount: "#angelsshare — 65M views", lastSeenTrending: today),
            TrendingPerfume(name: "Initio Oud for Greatness", brand: "Initio", imageURL: nil, description: "A powerful oud-saffron with lavender freshness — the winter power fragrance.", notes: ["Oud", "Saffron", "Lavender", "Musk", "Nutmeg"], trendReason: "The ultimate winter power fragrance for special occasions", releaseYear: 2018, concentration: "Eau de Parfum", category: .seasonal, tiktokMentions: "920,000+", socialSource: "TikTok, YouTube", hashtagCount: "#oudforgreatness — 22M views", lastSeenTrending: today),
            TrendingPerfume(name: "Jean Paul Gaultier Le Male Elixir", brand: "Jean Paul Gaultier", imageURL: nil, description: "A rich honey-lavender-vanilla powerhouse — the cold-weather compliment beast.", notes: ["Honey", "Lavender", "Vanilla", "Tonka Bean", "Benzoin"], trendReason: "TikTok's #1 'compliment getter' for winter — beast mode projection", releaseYear: 2023, concentration: "Parfum", category: .seasonal, tiktokMentions: "1,500,000+", socialSource: "TikTok, YouTube", hashtagCount: "#lemaleelixir — 42M views", lastSeenTrending: today),
        ]
    }
}
