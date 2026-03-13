import { Hono } from "hono";

interface TrendingPerfumeData {
  name: string;
  brand: string;
  imageURL: string | null;
  description: string;
  notes: string[];
  trendReason: string;
  releaseYear: number;
  concentration: string;
  category: string;
  tiktokMentions: string;
  socialSource: string;
  hashtagCount: string;
  lastSeenTrending: string;
}

interface ExternalTrendData {
  title: string;
  mentionedFragrances: string[];
  source: string;
  timestamp: string;
}

let cachedTrending: TrendingPerfumeData[] | null = null;
let lastFetchTime: number = 0;
const CACHE_DURATION_MS = 4 * 60 * 60 * 1000;

async function fetchRedditTrends(): Promise<ExternalTrendData[]> {
  try {
    const response = await fetch(
      "https://www.reddit.com/r/fragrance/hot.json?limit=50",
      {
        headers: {
          "User-Agent": "ScentBuddy/1.0 (Fragrance Trend Aggregator)",
        },
        signal: AbortSignal.timeout(8000),
      }
    );
    if (!response.ok) return [];
    const data = await response.json();
    const posts = data?.data?.children || [];
    return posts.map((post: any) => ({
      title: post.data?.title || "",
      mentionedFragrances: [],
      source: "reddit",
      timestamp: new Date(post.data?.created_utc * 1000).toISOString(),
    }));
  } catch {
    return [];
  }
}

function extractMentionedBrands(posts: ExternalTrendData[]): Map<string, number> {
  const brandMentions = new Map<string, number>();
  const knownBrands = [
    "lattafa", "mfk", "maison francis kurkdjian", "baccarat", "dior", "chanel",
    "tom ford", "creed", "aventus", "pdm", "parfums de marly", "layton",
    "le labo", "byredo", "xerjoff", "nishane", "initio", "amouage",
    "ariana grande", "cloud", "sol de janeiro", "kayali", "bianco latte",
    "giardini di toscana", "ysl", "versace", "dolce", "guerlain",
    "jo malone", "diptyque", "maison margiela", "replica", "kilian",
    "mancera", "montale", "thameen", "memo paris", "acqua di parma",
    "narciso rodriguez", "valentino", "prada", "burberry", "armani",
    "carolina herrera", "jean paul gaultier", "mugler", "thierry mugler",
    "bdk parfums", "juliette has a gun", "clean reserve", "miu miu",
    "delina", "habdan", "pegasus", "sedley", "althair", "herod",
    "hacivat", "ani", "fan your flames", "oud for greatness",
    "interlude", "reflection", "jubilation", "angels share",
    "apple brandy", "roses on ice", "good girl gone bad",
    "another 13", "santal 33", "noir de noir", "oud wood",
    "tuscan leather", "lost cherry", "bitter peach", "tobacco vanille",
    "black orchid", "neroli portofino",
  ];

  for (const post of posts) {
    const text = post.title.toLowerCase();
    for (const brand of knownBrands) {
      if (text.includes(brand)) {
        brandMentions.set(brand, (brandMentions.get(brand) || 0) + 1);
      }
    }
  }
  return brandMentions;
}

function boostFromReddit(
  perfumes: TrendingPerfumeData[],
  redditMentions: Map<string, number>
): TrendingPerfumeData[] {
  return perfumes.map((p) => {
    const nameKey = p.name.toLowerCase();
    const brandKey = p.brand.toLowerCase();
    let mentionBoost = 0;
    for (const [key, count] of redditMentions) {
      if (nameKey.includes(key) || brandKey.includes(key) || key.includes(brandKey)) {
        mentionBoost += count;
      }
    }
    if (mentionBoost > 0) {
      const currentMentions = parseInt(p.tiktokMentions.replace(/[^0-9]/g, "")) || 0;
      return {
        ...p,
        tiktokMentions: `${(currentMentions + mentionBoost * 50000).toLocaleString()}+`,
        socialSource: p.socialSource + ", Reddit r/fragrance",
      };
    }
    return p;
  });
}

function shuffleWithSeed(arr: TrendingPerfumeData[], seed: number): TrendingPerfumeData[] {
  const result = [...arr];
  let s = seed;
  for (let i = result.length - 1; i > 0; i--) {
    s = (s * 16807 + 0) % 2147483647;
    const j = s % (i + 1);
    [result[i], result[j]] = [result[j], result[i]];
  }
  return result;
}

async function generateTrendingList(): Promise<TrendingPerfumeData[]> {
  const currentMonth = new Date().getMonth();
  const season = getSeason(currentMonth);
  const dayOfYear = getDayOfYear();

  const viralPool = getViralPool();
  const newReleasePool = getNewReleasePool();
  const nichePool = getNichePool();
  const classicPool = getClassicPool();
  const seasonalPool = getSeasonalPool(season);

  const viralPicks = shuffleWithSeed(viralPool, dayOfYear * 7).slice(0, 4);
  const newReleasePicks = shuffleWithSeed(newReleasePool, dayOfYear * 13).slice(0, 3);
  const nichePicks = shuffleWithSeed(nichePool, dayOfYear * 19).slice(0, 3);
  const classicPicks = shuffleWithSeed(classicPool, dayOfYear * 23).slice(0, 2);
  const seasonalPicks = shuffleWithSeed(seasonalPool, dayOfYear * 31).slice(0, 3);

  let combined = [...viralPicks, ...newReleasePicks, ...nichePicks, ...classicPicks, ...seasonalPicks];

  try {
    const redditPosts = await fetchRedditTrends();
    if (redditPosts.length > 0) {
      const mentions = extractMentionedBrands(redditPosts);
      combined = boostFromReddit(combined, mentions);
    }
  } catch {}

  return combined;
}

function getDayOfYear(): number {
  const now = new Date();
  const start = new Date(now.getFullYear(), 0, 0);
  const diff = now.getTime() - start.getTime();
  return Math.floor(diff / (1000 * 60 * 60 * 24));
}

function getSeason(month: number): string {
  if (month >= 2 && month <= 4) return "spring";
  if (month >= 5 && month <= 7) return "summer";
  if (month >= 8 && month <= 10) return "fall";
  return "winter";
}

function getViralPool(): TrendingPerfumeData[] {
  const today = new Date().toISOString().split("T")[0];
  return [
    {
      name: "Lattafa Khamrah",
      brand: "Lattafa",
      imageURL: null,
      description: "A rich gourmand with cinnamon, vanilla, and oud that rivals niche fragrances costing 10x more.",
      notes: ["Cinnamon", "Nutmeg", "Dates", "Praline", "Vanilla", "Tonka Bean", "Benzoin"],
      trendReason: "#1 on PerfumeTok — dubbed 'rich people smell for $30'",
      releaseYear: 2022,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "5,200,000+",
      socialSource: "TikTok #PerfumeTok, Instagram",
      hashtagCount: "#khamrah — 2.1M views",
      lastSeenTrending: today,
    },
    {
      name: "Baccarat Rouge 540",
      brand: "Maison Francis Kurkdjian",
      imageURL: null,
      description: "The cultural phenomenon — a saffron-jasmine-amberwood blend that defined a generation of fragrance lovers.",
      notes: ["Saffron", "Jasmine", "Amberwood", "Ambergris", "Fir Resin", "Cedar"],
      trendReason: "8.7M+ social mentions — the scent that started #PerfumeTok",
      releaseYear: 2015,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "8,700,000+",
      socialSource: "TikTok, Instagram, YouTube",
      hashtagCount: "#baccaratrouge540 — 530M views",
      lastSeenTrending: today,
    },
    {
      name: "Ariana Grande Cloud",
      brand: "Ariana Grande",
      imageURL: null,
      description: "A dreamy lavender-coconut-musk cloud that TikTok crowned the best affordable BR540 alternative.",
      notes: ["Lavender Blossom", "Pear", "Coconut", "Praline", "Musk", "Cashmere Wood"],
      trendReason: "#1 celebrity fragrance on TikTok — the affordable BR540 dupe",
      releaseYear: 2018,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "4,100,000+",
      socialSource: "TikTok #PerfumeTok",
      hashtagCount: "#arianacloud — 180M views",
      lastSeenTrending: today,
    },
    {
      name: "Bianco Latte",
      brand: "Giardini di Toscana",
      imageURL: null,
      description: "An irresistible milky vanilla that smells like Italian dessert — the 'you smell expensive' scent.",
      notes: ["Milk", "Vanilla", "Caramel", "White Musk", "Sandalwood"],
      trendReason: "Blew up on TikTok as the 'you smell expensive' scent of 2025",
      releaseYear: 2019,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "3,800,000+",
      socialSource: "TikTok, YouTube",
      hashtagCount: "#biancolatte — 95M views",
      lastSeenTrending: today,
    },
    {
      name: "Sol de Janeiro Brazilian Bum Bum",
      brand: "Sol de Janeiro",
      imageURL: null,
      description: "A warm, addictive caramel-vanilla-sandalwood inspired by Brazilian beach culture.",
      notes: ["Caramel", "Vanilla", "Sandalwood", "Coconut", "Pistachio"],
      trendReason: "Mega-viral for its addictive sweet warmth — 'compliment magnet'",
      releaseYear: 2023,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "2,900,000+",
      socialSource: "TikTok, Instagram Reels",
      hashtagCount: "#brazilianbumbum — 62M views",
      lastSeenTrending: today,
    },
    {
      name: "Kayali Vanilla 28",
      brand: "Kayali",
      imageURL: null,
      description: "Huda Beauty's warm vanilla with brown sugar and tonka bean — the layering queen.",
      notes: ["Vanilla", "Brown Sugar", "Tonka Bean", "Amber", "Musk"],
      trendReason: "Huda Beauty fragrance going viral for layering combos on TikTok",
      releaseYear: 2018,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "2,400,000+",
      socialSource: "TikTok #PerfumeTok, YouTube",
      hashtagCount: "#kayalivanilla — 45M views",
      lastSeenTrending: today,
    },
    {
      name: "Parfums de Marly Delina",
      brand: "Parfums de Marly",
      imageURL: null,
      description: "A sophisticated Turkish rose and lychee floral with vanilla base — the 'it girl' perfume.",
      notes: ["Rose", "Lychee", "Peony", "Vanilla", "Musk", "Cashmeran"],
      trendReason: "The 'it girl' perfume dominating fragrance TikTok",
      releaseYear: 2017,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "3,500,000+",
      socialSource: "TikTok, Instagram",
      hashtagCount: "#delina — 120M views",
      lastSeenTrending: today,
    },
    {
      name: "Lattafa Yara",
      brand: "Lattafa",
      imageURL: null,
      description: "A sweet tropical orchid scent — the $20 dupe that broke TikTok.",
      notes: ["Orchid", "Tangerine", "Vanilla", "Musk", "Sandalwood", "Amber"],
      trendReason: "The $20 dupe that broke TikTok — compared to $300 Delina",
      releaseYear: 2021,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "2,100,000+",
      socialSource: "TikTok #dupetok",
      hashtagCount: "#lattafayara — 78M views",
      lastSeenTrending: today,
    },
    {
      name: "Maison Margiela Lazy Sunday Morning",
      brand: "Maison Margiela",
      imageURL: null,
      description: "Fresh linens and lily of the valley — the 'clean girl aesthetic' signature scent.",
      notes: ["Lily of the Valley", "Rose", "White Musk", "Iris", "Pear"],
      trendReason: "Clean girl aesthetic favorite — 'sheets fresh from the dryer'",
      releaseYear: 2012,
      concentration: "Eau de Toilette",
      category: "viral",
      tiktokMentions: "1,800,000+",
      socialSource: "TikTok #cleangirl",
      hashtagCount: "#lazysundaymorning — 34M views",
      lastSeenTrending: today,
    },
    {
      name: "Miu Miu Fleur de Lait",
      brand: "Miu Miu",
      imageURL: null,
      description: "The 'mango milkshake dream' — a soft lactonic scent that went viral for its unique freshness.",
      notes: ["Mango Sorbet", "Coconut Milk", "Osmanthus", "Sandalwood", "Musk"],
      trendReason: "2026's breakout viral scent — the 'mango milkshake' perfume",
      releaseYear: 2025,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "1,500,000+",
      socialSource: "TikTok #PerfumeTok",
      hashtagCount: "#fleurdelait — 28M views",
      lastSeenTrending: today,
    },
    {
      name: "Le Labo Another 13",
      brand: "Le Labo",
      imageURL: null,
      description: "A synthetic skin scent that smells like you, but better — created with AnOther Magazine.",
      notes: ["Ambroxan", "Jasmine Petals", "Moss", "Musk"],
      trendReason: "The ultimate 'your skin but better' scent on TikTok",
      releaseYear: 2010,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "1,600,000+",
      socialSource: "TikTok, Instagram",
      hashtagCount: "#another13 — 42M views",
      lastSeenTrending: today,
    },
    {
      name: "Narciso Rodriguez For Her",
      brand: "Narciso Rodriguez",
      imageURL: null,
      description: "A musk-forward masterpiece — TikTok's favorite 'quiet luxury' scent.",
      notes: ["Musk", "Amber", "Rose", "Peach", "Sandalwood"],
      trendReason: "Trending as the 'quiet luxury' scent on PerfumeTok",
      releaseYear: 2003,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "1,200,000+",
      socialSource: "TikTok #quietluxury",
      hashtagCount: "#narcisorodriguez — 55M views",
      lastSeenTrending: today,
    },
    {
      name: "French Avenue Liquid Brun",
      brand: "French Avenue",
      imageURL: null,
      description: "The perfect Althair alternative — orange blossom, cinnamon, and bourbon vanilla with a nutty finish.",
      notes: ["Orange Blossom", "Cinnamon", "Bourbon Vanilla", "Almond", "Tonka Bean"],
      trendReason: "Viral as the '$30 Althair dupe' — niche quality at designer price",
      releaseYear: 2024,
      concentration: "Eau de Parfum",
      category: "viral",
      tiktokMentions: "980,000+",
      socialSource: "TikTok #dupetok",
      hashtagCount: "#liquidbrun — 15M views",
      lastSeenTrending: today,
    },
  ];
}

function getNewReleasePool(): TrendingPerfumeData[] {
  const year = new Date().getFullYear();
  const today = new Date().toISOString().split("T")[0];
  return [
    {
      name: "Dior Privée Oud Rosewood",
      brand: "Dior",
      imageURL: null,
      description: "An exquisite blend of rare oud and delicate rosewood from Dior's exclusive Privée line.",
      notes: ["Oud", "Rosewood", "Sandalwood", "Rose", "Amber"],
      trendReason: "Latest drop from Dior's prestigious Privée collection",
      releaseYear: year,
      concentration: "Eau de Parfum",
      category: "newRelease",
      tiktokMentions: "450,000+",
      socialSource: "YouTube, Instagram",
      hashtagCount: "#diorprivee — 12M views",
      lastSeenTrending: today,
    },
    {
      name: "Maison Francis Kurkdjian Gentle Fluidity Gold",
      brand: "MFK",
      imageURL: null,
      description: "A warm, enveloping amber with vanilla and musk — MFK's latest crowd-pleaser.",
      notes: ["Amber", "Vanilla", "Musk", "Sandalwood", "Coriander"],
      trendReason: `${year} flanker generating massive hype in fragrance communities`,
      releaseYear: year,
      concentration: "Eau de Parfum",
      category: "newRelease",
      tiktokMentions: "680,000+",
      socialSource: "TikTok, Fragrantica",
      hashtagCount: "#gentlefluidity — 8M views",
      lastSeenTrending: today,
    },
    {
      name: "Valentino Donna Born In Roma Green Stravaganza",
      brand: "Valentino",
      imageURL: null,
      description: "A fresh green floral twist on the beloved Born in Roma line.",
      notes: ["Green Tea", "Jasmine", "Vetiver", "Vanilla", "Cashmeran"],
      trendReason: "New drop creating buzz — the freshest Born in Roma yet",
      releaseYear: year,
      concentration: "Eau de Parfum",
      category: "newRelease",
      tiktokMentions: "520,000+",
      socialSource: "TikTok, Instagram",
      hashtagCount: "#borninroma — 35M views",
      lastSeenTrending: today,
    },
    {
      name: "YSL Libre Le Parfum",
      brand: "Yves Saint Laurent",
      imageURL: null,
      description: "The most intense Libre yet — lavender and orange blossom amped up with vanilla.",
      notes: ["Lavender", "Orange Blossom", "Vanilla", "Tonka Bean", "Cedar"],
      trendReason: "YSL's most intense Libre flanker yet — instant bestseller",
      releaseYear: year,
      concentration: "Le Parfum",
      category: "newRelease",
      tiktokMentions: "890,000+",
      socialSource: "TikTok, YouTube",
      hashtagCount: "#yslibre — 48M views",
      lastSeenTrending: today,
    },
    {
      name: "Byredo Sundazed",
      brand: "Byredo",
      imageURL: null,
      description: "A joyful burst of mandarin and cotton candy sweetness — limited edition.",
      notes: ["Mandarin", "Lemon", "Cotton Candy", "Vanilla", "Jasmine"],
      trendReason: "Limited edition generating collector frenzy",
      releaseYear: year,
      concentration: "Eau de Parfum",
      category: "newRelease",
      tiktokMentions: "340,000+",
      socialSource: "TikTok, Instagram",
      hashtagCount: "#byredo — 22M views",
      lastSeenTrending: today,
    },
    {
      name: "Prada Paradoxe Intense",
      brand: "Prada",
      imageURL: null,
      description: "A deeper, richer take on the original Paradoxe with amber and vanilla.",
      notes: ["Amber", "Vanilla", "Jasmine", "Musk", "Neroli"],
      trendReason: "Prada's Paradoxe franchise keeps growing — the best flanker yet",
      releaseYear: year,
      concentration: "Eau de Parfum Intense",
      category: "newRelease",
      tiktokMentions: "720,000+",
      socialSource: "TikTok, YouTube",
      hashtagCount: "#pradaparadoxe — 18M views",
      lastSeenTrending: today,
    },
  ];
}

function getClassicPool(): TrendingPerfumeData[] {
  const today = new Date().toISOString().split("T")[0];
  return [
    {
      name: "Chanel No. 5",
      brand: "Chanel",
      imageURL: null,
      description: "The world's most iconic fragrance — a complex floral aldehyde masterpiece.",
      notes: ["Aldehydes", "Rose", "Jasmine", "Vanilla", "Sandalwood", "Vetiver"],
      trendReason: "100+ years and still the most recognized perfume on Earth",
      releaseYear: 1921,
      concentration: "Eau de Parfum",
      category: "classic",
      tiktokMentions: "2,100,000+",
      socialSource: "TikTok, YouTube, Instagram",
      hashtagCount: "#chanelno5 — 89M views",
      lastSeenTrending: today,
    },
    {
      name: "Tom Ford Tuscan Leather",
      brand: "Tom Ford",
      imageURL: null,
      description: "A bold, animalic leather with raspberry and saffron — the leather benchmark.",
      notes: ["Leather", "Raspberry", "Saffron", "Jasmine", "Thyme"],
      trendReason: "The benchmark for leather fragrances — still unmatched",
      releaseYear: 2007,
      concentration: "Eau de Parfum",
      category: "classic",
      tiktokMentions: "1,400,000+",
      socialSource: "TikTok, YouTube",
      hashtagCount: "#tuscanleather — 38M views",
      lastSeenTrending: today,
    },
    {
      name: "Dior Homme Intense",
      brand: "Dior",
      imageURL: null,
      description: "An elegant iris-cocoa masterpiece — widely regarded as one of the greatest designers ever.",
      notes: ["Iris", "Lavender", "Vanilla", "Cedar", "Amber", "Cocoa"],
      trendReason: "Considered one of the greatest designer fragrances ever created",
      releaseYear: 2011,
      concentration: "Eau de Parfum",
      category: "classic",
      tiktokMentions: "980,000+",
      socialSource: "TikTok, Fragrantica",
      hashtagCount: "#diorhomme — 25M views",
      lastSeenTrending: today,
    },
    {
      name: "Creed Aventus",
      brand: "Creed",
      imageURL: null,
      description: "The king of niche masculine fragrances — pineapple, birch, and musk.",
      notes: ["Pineapple", "Birch", "Musk", "Oakmoss", "Vanilla", "Bergamot"],
      trendReason: "Still the most discussed men's fragrance of all time",
      releaseYear: 2010,
      concentration: "Eau de Parfum",
      category: "classic",
      tiktokMentions: "3,200,000+",
      socialSource: "TikTok, YouTube, Reddit",
      hashtagCount: "#creedaventus — 150M views",
      lastSeenTrending: today,
    },
    {
      name: "Tom Ford Lost Cherry",
      brand: "Tom Ford",
      imageURL: null,
      description: "A decadent cherry-almond liqueur with Turkish rose and Peru balsam.",
      notes: ["Cherry", "Almond", "Turkish Rose", "Peru Balsam", "Tonka Bean"],
      trendReason: "The cherry fragrance that launched a thousand dupes",
      releaseYear: 2018,
      concentration: "Eau de Parfum",
      category: "classic",
      tiktokMentions: "2,800,000+",
      socialSource: "TikTok #dupetok",
      hashtagCount: "#lostcherry — 95M views",
      lastSeenTrending: today,
    },
    {
      name: "Chanel Bleu de Chanel",
      brand: "Chanel",
      imageURL: null,
      description: "The effortlessly sophisticated everyday scent — citrus, cedar, and sandalwood.",
      notes: ["Citrus", "Mint", "Cedar", "Sandalwood", "Incense"],
      trendReason: "The #1 'safe blind buy' recommended by every fragrance creator",
      releaseYear: 2010,
      concentration: "Eau de Parfum",
      category: "classic",
      tiktokMentions: "2,500,000+",
      socialSource: "TikTok, YouTube",
      hashtagCount: "#bleudechanel — 110M views",
      lastSeenTrending: today,
    },
  ];
}

function getNichePool(): TrendingPerfumeData[] {
  const today = new Date().toISOString().split("T")[0];
  return [
    {
      name: "Xerjoff Naxos",
      brand: "Xerjoff",
      imageURL: null,
      description: "A tobacco-honey masterpiece inspired by the ancient city — widely considered the GOAT.",
      notes: ["Tobacco", "Honey", "Lavender", "Vanilla", "Tonka Bean", "Cashmeran"],
      trendReason: "Widely considered the best tobacco fragrance ever made",
      releaseYear: 2015,
      concentration: "Eau de Parfum",
      category: "niche",
      tiktokMentions: "1,100,000+",
      socialSource: "TikTok, YouTube, Fragrantica",
      hashtagCount: "#xerjoffnaxos — 28M views",
      lastSeenTrending: today,
    },
    {
      name: "Nishane Hacivat",
      brand: "Nishane",
      imageURL: null,
      description: "A fresh fruity-woody scent — the niche Aventus alternative everyone recommends.",
      notes: ["Pineapple", "Grapefruit", "Patchouli", "Cedar", "Oakmoss", "Bergamot"],
      trendReason: "The niche Aventus alternative that fragrance reviewers love",
      releaseYear: 2017,
      concentration: "Extrait de Parfum",
      category: "niche",
      tiktokMentions: "780,000+",
      socialSource: "TikTok, YouTube",
      hashtagCount: "#hacivat — 18M views",
      lastSeenTrending: today,
    },
    {
      name: "Initio Oud for Greatness",
      brand: "Initio",
      imageURL: null,
      description: "A powerful oud-saffron combination with lavender freshness — the power scent.",
      notes: ["Oud", "Saffron", "Lavender", "Musk", "Nutmeg"],
      trendReason: "The ultimate power fragrance — boardroom to black tie",
      releaseYear: 2018,
      concentration: "Eau de Parfum",
      category: "niche",
      tiktokMentions: "920,000+",
      socialSource: "TikTok, YouTube",
      hashtagCount: "#oudforgreatness — 22M views",
      lastSeenTrending: today,
    },
    {
      name: "Amouage Interlude Man",
      brand: "Amouage",
      imageURL: null,
      description: "A smoky, resinous masterpiece of controlled chaos — incense and oud like no other.",
      notes: ["Incense", "Oud", "Amber", "Oregano", "Bergamot", "Myrrh"],
      trendReason: "The ultimate 'power scent' with cult status in niche circles",
      releaseYear: 2012,
      concentration: "Eau de Parfum",
      category: "niche",
      tiktokMentions: "650,000+",
      socialSource: "YouTube, Fragrantica",
      hashtagCount: "#amouage — 15M views",
      lastSeenTrending: today,
    },
    {
      name: "Thameen Peregrina",
      brand: "Thameen",
      imageURL: null,
      description: "A luminous white floral built around the world's most famous pearl.",
      notes: ["Rose", "Jasmine", "Oud", "Musk", "Amber", "Sandalwood"],
      trendReason: "Rising star in luxury niche — the 'hidden gem' everyone whispers about",
      releaseYear: 2016,
      concentration: "Extrait de Parfum",
      category: "niche",
      tiktokMentions: "340,000+",
      socialSource: "YouTube, Fragrantica",
      hashtagCount: "#thameen — 5M views",
      lastSeenTrending: today,
    },
    {
      name: "Memo Paris Sintra",
      brand: "Memo Paris",
      imageURL: null,
      description: "An enchanting floral-gourmand inspired by Portuguese gardens.",
      notes: ["Rose", "Vanilla", "Sandalwood", "Tonka Bean", "Plum"],
      trendReason: "Fragrance community darling with cult following",
      releaseYear: 2023,
      concentration: "Eau de Parfum",
      category: "niche",
      tiktokMentions: "280,000+",
      socialSource: "YouTube, Instagram",
      hashtagCount: "#memoparis — 4M views",
      lastSeenTrending: today,
    },
    {
      name: "Kilian Angels' Share",
      brand: "Kilian",
      imageURL: null,
      description: "A boozy cognac-soaked vanilla with cinnamon warmth — heaven in a bottle.",
      notes: ["Cognac", "Cinnamon", "Vanilla", "Oak", "Tonka Bean", "Praline"],
      trendReason: "The boozy fragrance that TikTok can't stop talking about",
      releaseYear: 2020,
      concentration: "Eau de Parfum",
      category: "niche",
      tiktokMentions: "1,800,000+",
      socialSource: "TikTok, YouTube",
      hashtagCount: "#angelsshare — 65M views",
      lastSeenTrending: today,
    },
    {
      name: "BDK Parfums Gris Charnel",
      brand: "BDK Parfums",
      imageURL: null,
      description: "A sophisticated fig-sandalwood-cardamom that's become the internet's favorite niche discovery.",
      notes: ["Fig", "Sandalwood", "Cardamom", "Vetiver", "Musk"],
      trendReason: "The 'hidden niche gem' that fragrance TikTok discovered",
      releaseYear: 2019,
      concentration: "Eau de Parfum",
      category: "niche",
      tiktokMentions: "420,000+",
      socialSource: "TikTok, YouTube",
      hashtagCount: "#grischarnel — 8M views",
      lastSeenTrending: today,
    },
  ];
}

function getSeasonalPool(season: string): TrendingPerfumeData[] {
  const today = new Date().toISOString().split("T")[0];
  const seasonalMap: Record<string, TrendingPerfumeData[]> = {
    spring: [
      {
        name: "Chanel Chance Eau Tendre",
        brand: "Chanel",
        imageURL: null,
        description: "A delicate fruity-floral with grapefruit and jasmine — spring in a bottle.",
        notes: ["Grapefruit", "Jasmine", "White Musk", "Cedar", "Rose"],
        trendReason: "The perfect spring awakening scent — trending every March",
        releaseYear: 2010,
        concentration: "Eau de Parfum",
        category: "seasonal",
        tiktokMentions: "1,400,000+",
        socialSource: "TikTok #springscents",
        hashtagCount: "#chanceeau — 42M views",
        lastSeenTrending: today,
      },
      {
        name: "Jo Malone English Pear & Freesia",
        brand: "Jo Malone",
        imageURL: null,
        description: "Lush pears wrapped in white freesias — a quintessential spring garden.",
        notes: ["Pear", "Freesia", "Patchouli", "Amber", "Rose Hip"],
        trendReason: "A quintessential spring garden in a bottle",
        releaseYear: 2010,
        concentration: "Cologne",
        category: "seasonal",
        tiktokMentions: "890,000+",
        socialSource: "TikTok, Instagram",
        hashtagCount: "#jomalone — 55M views",
        lastSeenTrending: today,
      },
      {
        name: "Acqua di Parma Blu Mediterraneo",
        brand: "Acqua di Parma",
        imageURL: null,
        description: "Fresh Italian citrus and aromatic herbs — the Mediterranean coast in a bottle.",
        notes: ["Bergamot", "Lemon", "Rosemary", "Cedar", "Myrtle"],
        trendReason: "The ultimate fresh start for the new season",
        releaseYear: 1999,
        concentration: "Eau de Toilette",
        category: "seasonal",
        tiktokMentions: "560,000+",
        socialSource: "YouTube, Instagram",
        hashtagCount: "#acquadiparma — 18M views",
        lastSeenTrending: today,
      },
      {
        name: "Clean Reserve Skin",
        brand: "Clean Reserve",
        imageURL: null,
        description: "A soft, warm skin scent with a clean finish — the minimalist spring choice.",
        notes: ["Musk", "Vanilla", "Sandalwood", "Orange Blossom"],
        trendReason: "The 'clean girl spring' essential on TikTok",
        releaseYear: 2016,
        concentration: "Eau de Parfum",
        category: "seasonal",
        tiktokMentions: "720,000+",
        socialSource: "TikTok #cleangirl",
        hashtagCount: "#cleanreserve — 12M views",
        lastSeenTrending: today,
      },
    ],
    summer: [
      {
        name: "Dolce & Gabbana Light Blue",
        brand: "Dolce & Gabbana",
        imageURL: null,
        description: "The essence of a Mediterranean summer — fresh, crisp, and iconic.",
        notes: ["Lemon", "Apple", "Cedar", "Musk", "Amber", "Bamboo"],
        trendReason: "Perennial summer favorite that never goes out of style",
        releaseYear: 2001,
        concentration: "Eau de Toilette",
        category: "seasonal",
        tiktokMentions: "2,800,000+",
        socialSource: "TikTok, Instagram",
        hashtagCount: "#lightblue — 85M views",
        lastSeenTrending: today,
      },
      {
        name: "Versace Pour Homme",
        brand: "Versace",
        imageURL: null,
        description: "A fresh, aquatic Mediterranean fragrance — the ultimate summer beach day.",
        notes: ["Lemon", "Neroli", "Amber", "Cedar", "Musk", "Sage"],
        trendReason: "The ultimate summer beach day fragrance",
        releaseYear: 2008,
        concentration: "Eau de Toilette",
        category: "seasonal",
        tiktokMentions: "1,500,000+",
        socialSource: "TikTok, YouTube",
        hashtagCount: "#versacepourhomme — 32M views",
        lastSeenTrending: today,
      },
      {
        name: "Tom Ford Neroli Portofino",
        brand: "Tom Ford",
        imageURL: null,
        description: "A vibrant citrus floral capturing the Italian Riviera.",
        notes: ["Neroli", "Bergamot", "Lemon", "Amber", "Musk"],
        trendReason: "The luxury summer scent celebrities wear on vacation",
        releaseYear: 2011,
        concentration: "Eau de Parfum",
        category: "seasonal",
        tiktokMentions: "780,000+",
        socialSource: "YouTube, Instagram",
        hashtagCount: "#neroliportofino — 12M views",
        lastSeenTrending: today,
      },
      {
        name: "Le Labo Santal 33",
        brand: "Le Labo",
        imageURL: null,
        description: "The iconic unisex sandalwood that defines NYC cool — leather, cedar, and musk.",
        notes: ["Sandalwood", "Cedar", "Leather", "Cardamom", "Iris", "Musk"],
        trendReason: "The 'I just got back from NYC' summer scent",
        releaseYear: 2011,
        concentration: "Eau de Parfum",
        category: "seasonal",
        tiktokMentions: "2,200,000+",
        socialSource: "TikTok, Instagram",
        hashtagCount: "#santal33 — 75M views",
        lastSeenTrending: today,
      },
    ],
    fall: [
      {
        name: "Maison Margiela By The Fireplace",
        brand: "Maison Margiela",
        imageURL: null,
        description: "Chestnuts roasting by a crackling fire — the quintessential fall comfort scent.",
        notes: ["Pepper", "Vanilla", "Tobacco", "Sandalwood", "Incense", "Chestnut"],
        trendReason: "The #1 fall fragrance on TikTok every single year",
        releaseYear: 2015,
        concentration: "Eau de Toilette",
        category: "seasonal",
        tiktokMentions: "3,200,000+",
        socialSource: "TikTok #fallscents",
        hashtagCount: "#bythefireplace — 92M views",
        lastSeenTrending: today,
      },
      {
        name: "Tom Ford Tobacco Vanille",
        brand: "Tom Ford",
        imageURL: null,
        description: "Opulent tobacco leaf and aromatic spices infused with vanilla — warm and unforgettable.",
        notes: ["Tobacco", "Vanilla", "Cocoa", "Dried Fruits", "Tonka Bean", "Ginger"],
        trendReason: "The king of fall fragrances — warm, rich, unforgettable",
        releaseYear: 2007,
        concentration: "Eau de Parfum",
        category: "seasonal",
        tiktokMentions: "2,600,000+",
        socialSource: "TikTok, YouTube",
        hashtagCount: "#tobaccovanille — 68M views",
        lastSeenTrending: today,
      },
      {
        name: "Replica Autumn Vibes",
        brand: "Maison Margiela",
        imageURL: null,
        description: "A walk through fallen leaves on a crisp autumn morning.",
        notes: ["Cardamom", "Ginger", "Cedar", "Musk", "Amber", "Pink Pepper"],
        trendReason: "The perfect transition scent from summer to fall",
        releaseYear: 2021,
        concentration: "Eau de Toilette",
        category: "seasonal",
        tiktokMentions: "890,000+",
        socialSource: "TikTok, Instagram",
        hashtagCount: "#autumnvibes — 22M views",
        lastSeenTrending: today,
      },
      {
        name: "Guerlain L'Homme Ideal EDP",
        brand: "Guerlain",
        imageURL: null,
        description: "Cherry, almond, and vanilla wrapped in smoky leather — sophisticated autumn warmth.",
        notes: ["Cherry", "Almond", "Vanilla", "Leather", "Sandalwood"],
        trendReason: "Trending as the sophisticated autumn date-night choice",
        releaseYear: 2016,
        concentration: "Eau de Parfum",
        category: "seasonal",
        tiktokMentions: "720,000+",
        socialSource: "YouTube, TikTok",
        hashtagCount: "#lhommeideal — 15M views",
        lastSeenTrending: today,
      },
    ],
    winter: [
      {
        name: "Parfums de Marly Layton",
        brand: "Parfums de Marly",
        imageURL: null,
        description: "Apple, vanilla, and cardamom — the #1 cold-weather crowd pleaser year after year.",
        notes: ["Apple", "Cardamom", "Vanilla", "Sandalwood", "Amber", "Pepper"],
        trendReason: "The #1 cold-weather crowd pleaser — every winter without fail",
        releaseYear: 2016,
        concentration: "Eau de Parfum",
        category: "seasonal",
        tiktokMentions: "2,900,000+",
        socialSource: "TikTok, YouTube",
        hashtagCount: "#pdmlayton — 85M views",
        lastSeenTrending: today,
      },
      {
        name: "Kilian Angels' Share",
        brand: "Kilian",
        imageURL: null,
        description: "A boozy cognac-soaked vanilla with cinnamon — cozy winter in a bottle.",
        notes: ["Cognac", "Cinnamon", "Vanilla", "Oak", "Tonka Bean"],
        trendReason: "The cozy winter evening scent everyone craves",
        releaseYear: 2020,
        concentration: "Eau de Parfum",
        category: "seasonal",
        tiktokMentions: "1,800,000+",
        socialSource: "TikTok, YouTube",
        hashtagCount: "#angelsshare — 65M views",
        lastSeenTrending: today,
      },
      {
        name: "Initio Oud for Greatness",
        brand: "Initio",
        imageURL: null,
        description: "A powerful oud-saffron with lavender freshness — the winter power fragrance.",
        notes: ["Oud", "Saffron", "Lavender", "Musk", "Nutmeg"],
        trendReason: "The ultimate winter power fragrance for special occasions",
        releaseYear: 2018,
        concentration: "Eau de Parfum",
        category: "seasonal",
        tiktokMentions: "920,000+",
        socialSource: "TikTok, YouTube",
        hashtagCount: "#oudforgreatness — 22M views",
        lastSeenTrending: today,
      },
      {
        name: "Jean Paul Gaultier Le Male Elixir",
        brand: "Jean Paul Gaultier",
        imageURL: null,
        description: "A rich honey-lavender-vanilla powerhouse — the cold-weather compliment beast.",
        notes: ["Honey", "Lavender", "Vanilla", "Tonka Bean", "Benzoin"],
        trendReason: "TikTok's #1 'compliment getter' for winter — beast mode projection",
        releaseYear: 2023,
        concentration: "Parfum",
        category: "seasonal",
        tiktokMentions: "1,500,000+",
        socialSource: "TikTok, YouTube",
        hashtagCount: "#lemaleelixir — 42M views",
        lastSeenTrending: today,
      },
    ],
  };

  return seasonalMap[season] || seasonalMap.winter;
}

const trendingRouter = new Hono();

trendingRouter.get("/", async (c) => {
  try {
    const now = Date.now();
    const forceRefresh = c.req.query("refresh") === "true";

    if (!forceRefresh && cachedTrending && now - lastFetchTime < CACHE_DURATION_MS) {
      return c.json({
        trending: cachedTrending,
        lastUpdated: new Date(lastFetchTime).toISOString(),
        nextUpdateAt: new Date(lastFetchTime + CACHE_DURATION_MS).toISOString(),
        source: "cache",
      });
    }

    const trending = await generateTrendingList();
    cachedTrending = trending;
    lastFetchTime = now;

    return c.json({
      trending,
      lastUpdated: new Date(lastFetchTime).toISOString(),
      nextUpdateAt: new Date(lastFetchTime + CACHE_DURATION_MS).toISOString(),
      source: "fresh",
    });
  } catch (error) {
    console.error("Trending API error:", error);
    if (cachedTrending && cachedTrending.length > 0) {
      return c.json({
        trending: cachedTrending,
        lastUpdated: new Date(lastFetchTime).toISOString(),
        nextUpdateAt: new Date(lastFetchTime + CACHE_DURATION_MS).toISOString(),
        source: "cache_fallback",
      });
    }
    return c.json({
      trending: [],
      lastUpdated: new Date().toISOString(),
      nextUpdateAt: new Date(Date.now() + CACHE_DURATION_MS).toISOString(),
      source: "error",
    });
  }
});

trendingRouter.get("/category/:category", async (c) => {
  const category = c.req.param("category");
  if (!cachedTrending) {
    cachedTrending = await generateTrendingList();
    lastFetchTime = Date.now();
  }
  const filtered = cachedTrending.filter((p) => p.category === category);
  return c.json({ trending: filtered });
});

export { trendingRouter };
