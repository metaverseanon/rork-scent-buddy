import Foundation

nonisolated struct PerfumeEntry: Sendable, Identifiable {
    let id: String
    let name: String
    let brand: String
    let concentration: String
    let topNotes: [String]
    let heartNotes: [String]
    let baseNotes: [String]
    let gender: String

    var displayName: String { "\(name) — \(brand)" }
    var allNotes: [String] { topNotes + heartNotes + baseNotes }
}

nonisolated enum PerfumeDatabase: Sendable {
    static let entries: [PerfumeEntry] = [
        // DIOR
        PerfumeEntry(id: "dior-sauvage-edp", name: "Sauvage", brand: "Dior", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pepper"], heartNotes: ["Lavender", "Sichuan Pepper", "Star Anise"], baseNotes: ["Ambroxan", "Cedar", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "dior-sauvage-edt", name: "Sauvage", brand: "Dior", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Pepper"], heartNotes: ["Geranium", "Lavender", "Sichuan Pepper"], baseNotes: ["Ambroxan", "Cedar", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "dior-sauvage-elixir", name: "Sauvage Elixir", brand: "Dior", concentration: "Parfum",
                     topNotes: ["Grapefruit", "Cinnamon"], heartNotes: ["Lavender", "Nutmeg"], baseNotes: ["Sandalwood", "Amber", "Patchouli", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "dior-homme-intense", name: "Dior Homme Intense", brand: "Dior", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Pear"], heartNotes: ["Iris", "Violet"], baseNotes: ["Vetiver", "Cedar", "Musk"], gender: "Men"),
        PerfumeEntry(id: "dior-jadore", name: "J'adore", brand: "Dior", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Ivy Leaves", "Bergamot"], heartNotes: ["Rose", "Jasmine", "Violet"], baseNotes: ["Musk", "Vanilla", "Sandalwood"], gender: "Women"),
        PerfumeEntry(id: "dior-miss-dior", name: "Miss Dior", brand: "Dior", concentration: "Eau de Parfum",
                     topNotes: ["Lily of the Valley", "Peony"], heartNotes: ["Rose", "Iris"], baseNotes: ["Musk", "Sandalwood", "Vanilla"], gender: "Women"),
        PerfumeEntry(id: "dior-poison-girl", name: "Poison Girl", brand: "Dior", concentration: "Eau de Parfum",
                     topNotes: ["Bitter Orange", "Lemon"], heartNotes: ["Rose", "Grasse Rose"], baseNotes: ["Tonka Bean", "Vanilla", "Sandalwood"], gender: "Women"),

        // CHANEL
        PerfumeEntry(id: "chanel-bleu-edp", name: "Bleu de Chanel", brand: "Chanel", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Mint", "Grapefruit"], heartNotes: ["Jasmine", "Melon", "Nutmeg"], baseNotes: ["Cedar", "Sandalwood", "Patchouli", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "chanel-bleu-parfum", name: "Bleu de Chanel Parfum", brand: "Chanel", concentration: "Parfum",
                     topNotes: ["Citrus", "Mint"], heartNotes: ["Cedar", "Nutmeg"], baseNotes: ["Sandalwood", "Tonka Bean", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "chanel-allure-homme-sport", name: "Allure Homme Sport", brand: "Chanel", concentration: "Eau de Toilette",
                     topNotes: ["Orange", "Mandarin", "Aldehydes"], heartNotes: ["Neroli", "Pepper"], baseNotes: ["Cedar", "Tonka Bean", "Musk", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "chanel-no5", name: "N°5", brand: "Chanel", concentration: "Eau de Parfum",
                     topNotes: ["Aldehydes", "Bergamot", "Lemon", "Neroli"], heartNotes: ["Rose", "Jasmine", "Lily of the Valley", "Iris"], baseNotes: ["Sandalwood", "Cedar", "Vanilla", "Musk", "Vetiver"], gender: "Women"),
        PerfumeEntry(id: "chanel-coco-mademoiselle", name: "Coco Mademoiselle", brand: "Chanel", concentration: "Eau de Parfum",
                     topNotes: ["Orange", "Bergamot", "Grapefruit"], heartNotes: ["Rose", "Jasmine", "Lychee"], baseNotes: ["Patchouli", "Vetiver", "Vanilla", "Musk"], gender: "Women"),
        PerfumeEntry(id: "chanel-chance-eau-tendre", name: "Chance Eau Tendre", brand: "Chanel", concentration: "Eau de Parfum",
                     topNotes: ["Grapefruit", "Quince"], heartNotes: ["Hyacinth", "Jasmine", "Rose"], baseNotes: ["Musk", "Iris", "Cedar", "Amber"], gender: "Women"),
        PerfumeEntry(id: "chanel-gabrielle", name: "Gabrielle", brand: "Chanel", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Grapefruit", "Blackcurrant"], heartNotes: ["Jasmine", "Ylang Ylang", "Orange Blossom", "Tuberose"], baseNotes: ["Sandalwood", "Musk", "Cedar"], gender: "Women"),

        // TOM FORD
        PerfumeEntry(id: "tf-tobacco-vanille", name: "Tobacco Vanille", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Tobacco", "Spicy Notes"], heartNotes: ["Vanilla", "Tonka Bean", "Cacao"], baseNotes: ["Dried Fruit", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "tf-oud-wood", name: "Oud Wood", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Rosewood", "Cardamom"], heartNotes: ["Oud", "Sandalwood", "Palisander"], baseNotes: ["Tonka Bean", "Vetiver", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "tf-lost-cherry", name: "Lost Cherry", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Cherry", "Bitter Almond"], heartNotes: ["Cherry Liqueur", "Turkish Rose", "Jasmine"], baseNotes: ["Sandalwood", "Vetiver", "Cedar", "Peru Balsam", "Tonka Bean", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "tf-black-orchid", name: "Black Orchid", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Truffle", "Bergamot", "Black Currant"], heartNotes: ["Orchid", "Lotus", "Fruity Notes"], baseNotes: ["Patchouli", "Sandalwood", "Vanilla", "Incense"], gender: "Unisex"),
        PerfumeEntry(id: "tf-tuscan-leather", name: "Tuscan Leather", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Raspberry", "Saffron", "Thyme"], heartNotes: ["Jasmine", "Olibanum"], baseNotes: ["Leather", "Amber", "Sandalwood", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "tf-bitter-peach", name: "Bitter Peach", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Peach", "Blood Orange"], heartNotes: ["Rum", "Cardamom", "Davana"], baseNotes: ["Patchouli", "Sandalwood", "Vanilla", "Cashmeran", "Tonka Bean"], gender: "Unisex"),
        PerfumeEntry(id: "tf-neroli-portofino", name: "Neroli Portofino", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Lemon", "Lavender"], heartNotes: ["Neroli", "Orange Blossom", "African Orange Flower"], baseNotes: ["Amber", "Musk", "Angelica"], gender: "Unisex"),

        // CREED
        PerfumeEntry(id: "creed-aventus", name: "Aventus", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Pineapple", "Bergamot", "Black Currant", "Apple"], heartNotes: ["Birch", "Jasmine", "Patchouli"], baseNotes: ["Musk", "Oak Moss", "Ambergris", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "creed-green-irish-tweed", name: "Green Irish Tweed", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Lemon Verbena", "Iris"], heartNotes: ["Violet Leaf"], baseNotes: ["Sandalwood", "Ambergris", "Musk"], gender: "Men"),
        PerfumeEntry(id: "creed-silver-mountain-water", name: "Silver Mountain Water", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Green Tea"], heartNotes: ["Black Currant", "Petit Grain"], baseNotes: ["Musk", "Sandalwood", "Gaultheria"], gender: "Men"),
        PerfumeEntry(id: "creed-viking", name: "Viking", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Pink Pepper", "Mandarin"], heartNotes: ["Rose", "Geranium", "Lavender"], baseNotes: ["Sandalwood", "Vetiver", "Patchouli"], gender: "Men"),

        // VERSACE
        PerfumeEntry(id: "versace-eros", name: "Eros", brand: "Versace", concentration: "Eau de Toilette",
                     topNotes: ["Mint", "Green Apple", "Lemon"], heartNotes: ["Tonka Bean", "Geranium", "Ambroxan"], baseNotes: ["Vanilla", "Vetiver", "Oak Moss", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "versace-eros-edp", name: "Eros", brand: "Versace", concentration: "Eau de Parfum",
                     topNotes: ["Mint", "Vanilla", "Green Apple", "Lemon"], heartNotes: ["Tonka Bean", "Geranium", "Ambroxan"], baseNotes: ["Vanilla", "Vetiver", "Cedar", "Leather"], gender: "Men"),
        PerfumeEntry(id: "versace-dylan-blue", name: "Dylan Blue", brand: "Versace", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Grapefruit", "Fig Leaf", "Aquatic Notes"], heartNotes: ["Violet Leaf", "Papyrus", "Patchouli", "Ambroxan"], baseNotes: ["Musk", "Tonka Bean", "Saffron", "Incense"], gender: "Men"),
        PerfumeEntry(id: "versace-bright-crystal", name: "Bright Crystal", brand: "Versace", concentration: "Eau de Toilette",
                     topNotes: ["Pomegranate", "Yuzu", "Iced Accord"], heartNotes: ["Peony", "Magnolia", "Lotus"], baseNotes: ["Musk", "Amber", "Mahogany"], gender: "Women"),

        // YVES SAINT LAURENT
        PerfumeEntry(id: "ysl-y-edp", name: "Y", brand: "Yves Saint Laurent", concentration: "Eau de Parfum",
                     topNotes: ["Apple", "Ginger", "Bergamot"], heartNotes: ["Sage", "Juniper Berries", "Geranium"], baseNotes: ["Amberwood", "Tonka Bean", "Cedar", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "ysl-la-nuit-de-lhomme", name: "La Nuit de L'Homme", brand: "Yves Saint Laurent", concentration: "Eau de Toilette",
                     topNotes: ["Cardamom", "Bergamot"], heartNotes: ["Lavender", "Cedar", "Virginian Cedar"], baseNotes: ["Vetiver", "Caraway", "Coumarin"], gender: "Men"),
        PerfumeEntry(id: "ysl-libre", name: "Libre", brand: "Yves Saint Laurent", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Lavender", "Black Currant"], heartNotes: ["Orange Blossom", "Jasmine", "Lavender"], baseNotes: ["Madagascar Vanilla", "Musk", "Cedar", "Ambergris"], gender: "Women"),
        PerfumeEntry(id: "ysl-black-opium", name: "Black Opium", brand: "Yves Saint Laurent", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Orange Blossom", "Pear"], heartNotes: ["Coffee", "Jasmine", "Bitter Almond"], baseNotes: ["Vanilla", "Patchouli", "Cedar", "Cashmere Wood"], gender: "Women"),
        PerfumeEntry(id: "ysl-mon-paris", name: "Mon Paris", brand: "Yves Saint Laurent", concentration: "Eau de Parfum",
                     topNotes: ["Raspberry", "Strawberry", "Pear"], heartNotes: ["Peony", "Datura", "Jasmine"], baseNotes: ["Patchouli", "Musk", "Ambroxan"], gender: "Women"),

        // JEAN PAUL GAULTIER
        PerfumeEntry(id: "jpg-le-male", name: "Le Male", brand: "Jean Paul Gaultier", concentration: "Eau de Toilette",
                     topNotes: ["Mint", "Lavender", "Bergamot", "Cardamom"], heartNotes: ["Orange Blossom", "Cinnamon", "Cumin"], baseNotes: ["Vanilla", "Tonka Bean", "Amber", "Sandalwood", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "jpg-le-male-elixir", name: "Le Male Elixir", brand: "Jean Paul Gaultier", concentration: "Parfum",
                     topNotes: ["Lavender", "Mint"], heartNotes: ["Vanilla", "Tonka Bean"], baseNotes: ["Benzoin", "Amber", "Honey"], gender: "Men"),
        PerfumeEntry(id: "jpg-scandal", name: "Scandal", brand: "Jean Paul Gaultier", concentration: "Eau de Parfum",
                     topNotes: ["Blood Orange", "Mandarin"], heartNotes: ["Honey", "Gardenia", "Orange Blossom"], baseNotes: ["Tonka Bean", "Beeswax", "Patchouli", "Caramel"], gender: "Women"),

        // GIORGIO ARMANI
        PerfumeEntry(id: "armani-acqua-di-gio", name: "Acqua di Giò", brand: "Giorgio Armani", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Neroli", "Green Tangerine", "Lemon"], heartNotes: ["Jasmine", "Calone", "Peach", "Rosemary"], baseNotes: ["Cedar", "Patchouli", "Musk", "Amber"], gender: "Men"),
        PerfumeEntry(id: "armani-acqua-di-gio-profumo", name: "Acqua di Giò Profumo", brand: "Giorgio Armani", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Aquatic Notes"], heartNotes: ["Geranium", "Sage", "Rosemary"], baseNotes: ["Amber", "Patchouli", "Incense"], gender: "Men"),
        PerfumeEntry(id: "armani-code", name: "Armani Code", brand: "Giorgio Armani", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Lemon"], heartNotes: ["Olive Blossom", "Star Anise"], baseNotes: ["Guaiac Wood", "Tonka Bean", "Leather"], gender: "Men"),
        PerfumeEntry(id: "armani-code-parfum", name: "Armani Code Parfum", brand: "Giorgio Armani", concentration: "Parfum",
                     topNotes: ["Bergamot", "Green Mandarin"], heartNotes: ["Iris", "Lavandin"], baseNotes: ["Tonka Bean", "Vanilla", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "armani-si", name: "Sì", brand: "Giorgio Armani", concentration: "Eau de Parfum",
                     topNotes: ["Black Currant", "Mandarin"], heartNotes: ["Rose", "Freesia", "Osmanthus"], baseNotes: ["Vanilla", "Patchouli", "Ambroxan", "Musk"], gender: "Women"),
        PerfumeEntry(id: "armani-my-way", name: "My Way", brand: "Giorgio Armani", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Orange Blossom"], heartNotes: ["Tuberose", "Jasmine"], baseNotes: ["Cedar", "Vanilla", "Musk", "Sandalwood"], gender: "Women"),

        // PRADA
        PerfumeEntry(id: "prada-luna-rossa-carbon", name: "Luna Rossa Carbon", brand: "Prada", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Pepper"], heartNotes: ["Lavender", "Metallic Notes"], baseNotes: ["Ambroxan", "Patchouli"], gender: "Men"),
        PerfumeEntry(id: "prada-luna-rossa-ocean", name: "Luna Rossa Ocean", brand: "Prada", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Iris", "Pink Pepper"], heartNotes: ["Sage", "Vetiver"], baseNotes: ["Musk", "Cashmere Wood", "Patchouli"], gender: "Men"),
        PerfumeEntry(id: "prada-lhomme", name: "L'Homme", brand: "Prada", concentration: "Eau de Parfum",
                     topNotes: ["Iris", "Neroli", "Amber"], heartNotes: ["Iris", "Violet", "Geranium"], baseNotes: ["Patchouli", "Amberwood", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "prada-candy", name: "Candy", brand: "Prada", concentration: "Eau de Parfum",
                     topNotes: ["Caramel"], heartNotes: ["Musk", "Benzoin", "Powdery Notes"], baseNotes: ["Vanilla", "Honey"], gender: "Women"),
        PerfumeEntry(id: "prada-paradoxe", name: "Paradoxe", brand: "Prada", concentration: "Eau de Parfum",
                     topNotes: ["Neroli", "Bergamot", "Pear"], heartNotes: ["Jasmine", "Orange Blossom"], baseNotes: ["Amberwood", "Musk", "Vanilla"], gender: "Women"),

        // DOLCE & GABBANA
        PerfumeEntry(id: "dg-the-one-edp", name: "The One", brand: "Dolce & Gabbana", concentration: "Eau de Parfum",
                     topNotes: ["Grapefruit", "Coriander"], heartNotes: ["Ginger", "Orange Blossom", "Cardamom"], baseNotes: ["Amber", "Cedar", "Labdanum"], gender: "Men"),
        PerfumeEntry(id: "dg-light-blue", name: "Light Blue", brand: "Dolce & Gabbana", concentration: "Eau de Toilette",
                     topNotes: ["Sicilian Lemon", "Apple", "Cedar", "Bluebell"], heartNotes: ["Bamboo", "Jasmine", "White Rose"], baseNotes: ["Cedar", "Musk", "Amber"], gender: "Women"),
        PerfumeEntry(id: "dg-k", name: "K by Dolce & Gabbana", brand: "Dolce & Gabbana", concentration: "Eau de Parfum",
                     topNotes: ["Blood Orange", "Juniper Berries", "Sicilian Lemon"], heartNotes: ["Pimento", "Clary Sage", "Geranium"], baseNotes: ["Patchouli", "Cedar", "Vetiver"], gender: "Men"),

        // VALENTINO
        PerfumeEntry(id: "valentino-uomo-born-in-roma", name: "Uomo Born in Roma", brand: "Valentino", concentration: "Eau de Toilette",
                     topNotes: ["Ginger", "Green Mandarin", "Sage"], heartNotes: ["Vetiver", "Mineral Accord"], baseNotes: ["Smoked Virginia Tobacco", "Cashmeran", "Guaiac Wood"], gender: "Men"),
        PerfumeEntry(id: "valentino-donna-born-in-roma", name: "Donna Born in Roma", brand: "Valentino", concentration: "Eau de Parfum",
                     topNotes: ["Granny Smith Apple", "Bergamot"], heartNotes: ["Jasmine Grandiflorum", "Turkish Rose"], baseNotes: ["Bourbon Vanilla", "Cashmere Wood", "Benzoin"], gender: "Women"),

        // BURBERRY
        PerfumeEntry(id: "burberry-her", name: "Her", brand: "Burberry", concentration: "Eau de Parfum",
                     topNotes: ["Dark Berries", "Blackcurrant", "Raspberry", "Strawberry", "Blueberry"], heartNotes: ["Violet", "Jasmine"], baseNotes: ["Musk", "Amber", "Sandalwood", "Dry Cocoa"], gender: "Women"),

        // HERMÈS
        PerfumeEntry(id: "hermes-terre", name: "Terre d'Hermès", brand: "Hermès", concentration: "Eau de Toilette",
                     topNotes: ["Orange", "Grapefruit"], heartNotes: ["Pepper", "Pelargonium"], baseNotes: ["Vetiver", "Cedar", "Benzoin", "Patchouli"], gender: "Men"),
        PerfumeEntry(id: "hermes-terre-parfum", name: "Terre d'Hermès", brand: "Hermès", concentration: "Parfum",
                     topNotes: ["Flint", "Orange"], heartNotes: ["Pepper"], baseNotes: ["Benzoin", "Oak Moss", "Vetiver", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "hermes-twilly", name: "Twilly d'Hermès", brand: "Hermès", concentration: "Eau de Parfum",
                     topNotes: ["Ginger"], heartNotes: ["Tuberose"], baseNotes: ["Sandalwood", "Vanilla"], gender: "Women"),

        // GUERLAIN
        PerfumeEntry(id: "guerlain-lhomme-ideal-edp", name: "L'Homme Idéal", brand: "Guerlain", concentration: "Eau de Parfum",
                     topNotes: ["Almond", "Bergamot"], heartNotes: ["Rose", "Cinnamon", "Plum"], baseNotes: ["Leather", "Sandalwood", "Vanilla", "Tonka Bean"], gender: "Men"),
        PerfumeEntry(id: "guerlain-shalimar", name: "Shalimar", brand: "Guerlain", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon"], heartNotes: ["Jasmine", "Rose", "Iris"], baseNotes: ["Vanilla", "Tonka Bean", "Opoponax", "Sandalwood", "Musk"], gender: "Women"),

        // MAISON FRANCIS KURKDJIAN
        PerfumeEntry(id: "mfk-baccarat-rouge-540", name: "Baccarat Rouge 540", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Jasmine"], heartNotes: ["Amberwood", "Ambergris"], baseNotes: ["Fir Resin", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "mfk-baccarat-rouge-540-extrait", name: "Baccarat Rouge 540 Extrait", brand: "Maison Francis Kurkdjian", concentration: "Extrait de Parfum",
                     topNotes: ["Bitter Almond", "Saffron"], heartNotes: ["Egyptian Jasmine", "Cedar"], baseNotes: ["Ambergris", "Fir Balsam", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "mfk-grand-soir", name: "Grand Soir", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum",
                     topNotes: ["Amber", "Benzoin"], heartNotes: ["Vanilla", "Tonka Bean"], baseNotes: ["Sandalwood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "mfk-gentle-fluidity-gold", name: "Gentle Fluidity Gold", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum",
                     topNotes: ["Coriander", "Juniper Berries"], heartNotes: ["Musk", "Vanilla", "Amber"], baseNotes: ["Sandalwood", "Cedar"], gender: "Unisex"),

        // BYREDO
        PerfumeEntry(id: "byredo-gypsy-water", name: "Gypsy Water", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Pepper", "Juniper Berries"], heartNotes: ["Incense", "Pine Needles", "Orris"], baseNotes: ["Sandalwood", "Vanilla", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "byredo-mojave-ghost", name: "Mojave Ghost", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Ambrette", "Sapodilla"], heartNotes: ["Violet", "Sandalwood", "Magnolia"], baseNotes: ["Ambergris", "Cedar", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "byredo-bal-dafrique", name: "Bal d'Afrique", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Neroli", "African Marigold"], heartNotes: ["Violet", "Jasmine", "Cyclamen"], baseNotes: ["Vetiver", "Amber", "Musk", "Cedar"], gender: "Unisex"),

        // LE LABO
        PerfumeEntry(id: "lelabo-santal-33", name: "Santal 33", brand: "Le Labo", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Iris", "Violet"], heartNotes: ["Ambrox", "Sandalwood", "Cedarwood", "Leather"], baseNotes: ["Musk", "Amber", "Papyrus"], gender: "Unisex"),
        PerfumeEntry(id: "lelabo-another-13", name: "AnOther 13", brand: "Le Labo", concentration: "Eau de Parfum",
                     topNotes: ["Ambroxan"], heartNotes: ["Ambrette", "Jasmine Petals"], baseNotes: ["Musk", "Moss"], gender: "Unisex"),
        PerfumeEntry(id: "lelabo-rose-31", name: "Rose 31", brand: "Le Labo", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Cumin"], heartNotes: ["Cedar", "Oud", "Guaiac Wood"], baseNotes: ["Musk", "Amber", "Vetiver"], gender: "Unisex"),

        // PARFUMS DE MARLY
        PerfumeEntry(id: "pdm-layton", name: "Layton", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lavender", "Apple"], heartNotes: ["Jasmine", "Iris", "Violet"], baseNotes: ["Vanilla", "Sandalwood", "Cardamom", "Pepper", "Guaiac Wood"], gender: "Men"),
        PerfumeEntry(id: "pdm-pegasus", name: "Pegasus", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Heliotrope"], heartNotes: ["Bitter Almond", "Jasmine", "Lavender"], baseNotes: ["Vanilla", "Amber", "Sandalwood", "Musk"], gender: "Men"),
        PerfumeEntry(id: "pdm-sedley", name: "Sedley", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Spearmint", "Bergamot", "Black Currant"], heartNotes: ["Geranium", "Lavender", "Sage"], baseNotes: ["Sandalwood", "Vetiver", "Musk"], gender: "Men"),
        PerfumeEntry(id: "pdm-delina", name: "Delina", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Lychee", "Rhubarb", "Nutmeg"], heartNotes: ["Turkish Rose", "Peony", "Vanilla"], baseNotes: ["Musk", "Cashmeran", "Cedar", "Incense"], gender: "Women"),

        // INITIO
        PerfumeEntry(id: "initio-side-effect", name: "Side Effect", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Rum", "Cinnamon"], heartNotes: ["Tobacco", "Vanilla"], baseNotes: ["Benzoin", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "initio-oud-for-greatness", name: "Oud for Greatness", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Nutmeg", "Saffron", "Lavender"], heartNotes: ["Oud", "Agarwood"], baseNotes: ["Musk", "Patchouli"], gender: "Unisex"),

        // XERJOFF
        PerfumeEntry(id: "xerjoff-erba-pura", name: "Erba Pura", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Orange", "Lemon", "Bergamot"], heartNotes: ["Fruits", "White Flowers"], baseNotes: ["Musk", "Vanilla", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "xerjoff-naxos", name: "Naxos", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lavender", "Lemon"], heartNotes: ["Honey", "Cinnamon", "Cashmeran"], baseNotes: ["Tonka Bean", "Vanilla", "Tobacco"], gender: "Unisex"),

        // NISHANE
        PerfumeEntry(id: "nishane-hacivat", name: "Hacivat", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Pineapple", "Bergamot", "Grapefruit"], heartNotes: ["Jasmine", "Patchouli", "Rose"], baseNotes: ["Oak Moss", "Sandalwood", "Cedar", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "nishane-ani", name: "Ani", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Cardamom", "Mandarin"], heartNotes: ["Orchid", "Rose", "Jasmine"], baseNotes: ["Vanilla", "Tonka Bean", "Sandalwood", "Musk"], gender: "Unisex"),

        // AMOUAGE
        PerfumeEntry(id: "amouage-interlude-man", name: "Interlude Man", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Oregano", "Bergamot", "Pimento Berry"], heartNotes: ["Frankincense", "Opoponax", "Amber"], baseNotes: ["Oud", "Sandalwood", "Musk", "Tonka Bean", "Leather"], gender: "Men"),
        PerfumeEntry(id: "amouage-reflection-man", name: "Reflection Man", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Rosemary", "Neroli", "Pink Pepper"], heartNotes: ["Jasmine", "Iris", "Ylang Ylang", "Rose"], baseNotes: ["Cedar", "Sandalwood", "Vetiver", "Musk"], gender: "Men"),

        // GUCCI
        PerfumeEntry(id: "gucci-guilty-pour-homme", name: "Guilty Pour Homme", brand: "Gucci", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Lemon"], heartNotes: ["Orange Blossom", "Rose"], baseNotes: ["Cedar", "Patchouli", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "gucci-bloom", name: "Bloom", brand: "Gucci", concentration: "Eau de Parfum",
                     topNotes: ["Rangoon Creeper"], heartNotes: ["Tuberose", "Jasmine"], baseNotes: ["Orris", "Sandalwood", "Musk"], gender: "Women"),
        PerfumeEntry(id: "gucci-flora-gorgeous-gardenia", name: "Flora Gorgeous Gardenia", brand: "Gucci", concentration: "Eau de Parfum",
                     topNotes: ["Pear Blossom", "Red Berries"], heartNotes: ["Gardenia", "Jasmine", "Frangipani"], baseNotes: ["Patchouli", "Brown Sugar", "Musk"], gender: "Women"),

        // HUGO BOSS
        PerfumeEntry(id: "boss-bottled-edp", name: "Bottled", brand: "Hugo Boss", concentration: "Eau de Parfum",
                     topNotes: ["Apple", "Bergamot"], heartNotes: ["Cinnamon", "Cardamom", "Iris"], baseNotes: ["Vetiver", "Sandalwood", "Vanilla", "Musk", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "boss-the-scent", name: "The Scent", brand: "Hugo Boss", concentration: "Eau de Toilette",
                     topNotes: ["Ginger", "Mandarin", "Bergamot"], heartNotes: ["Lavender", "Maninka"], baseNotes: ["Leather", "Vanilla"], gender: "Men"),

        // RALPH LAUREN
        PerfumeEntry(id: "rl-polo-green", name: "Polo Green", brand: "Ralph Lauren", concentration: "Eau de Toilette",
                     topNotes: ["Artemisia", "Basil", "Pine", "Juniper Berries"], heartNotes: ["Chamomile", "Rose", "Thyme", "Pepper"], baseNotes: ["Leather", "Oak Moss", "Cedar", "Tobacco", "Patchouli"], gender: "Men"),

        // MONTBLANC
        PerfumeEntry(id: "montblanc-explorer", name: "Explorer", brand: "Montblanc", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Clary Sage"], heartNotes: ["Leather", "Vetiver"], baseNotes: ["Indonesian Patchouli", "Amberwood", "Cacao", "Akigalawood"], gender: "Men"),

        // CAROLINA HERRERA
        PerfumeEntry(id: "ch-bad-boy", name: "Bad Boy", brand: "Carolina Herrera", concentration: "Eau de Toilette",
                     topNotes: ["Black Pepper", "Bergamot", "Sage"], heartNotes: ["Cedar", "Vetiver"], baseNotes: ["Tonka Bean", "Cacao", "Amber"], gender: "Men"),
        PerfumeEntry(id: "ch-good-girl", name: "Good Girl", brand: "Carolina Herrera", concentration: "Eau de Parfum",
                     topNotes: ["Almond", "Coffee"], heartNotes: ["Tuberose", "Jasmine"], baseNotes: ["Cacao", "Tonka Bean", "Sandalwood", "Vanilla"], gender: "Women"),

        // VIKTOR & ROLF
        PerfumeEntry(id: "vr-spicebomb-extreme", name: "Spicebomb Extreme", brand: "Viktor & Rolf", concentration: "Eau de Parfum",
                     topNotes: ["Black Pepper", "Grapefruit"], heartNotes: ["Cinnamon", "Cumin", "Saffron"], baseNotes: ["Tobacco", "Vanilla", "Leather", "Amber"], gender: "Men"),
        PerfumeEntry(id: "vr-flowerbomb", name: "Flowerbomb", brand: "Viktor & Rolf", concentration: "Eau de Parfum",
                     topNotes: ["Tea", "Bergamot"], heartNotes: ["Sambac Jasmine", "Rose", "Orchid", "Freesia"], baseNotes: ["Patchouli", "Musk", "Vanilla"], gender: "Women"),

        // THIERRY MUGLER / MUGLER
        PerfumeEntry(id: "mugler-alien", name: "Alien", brand: "Mugler", concentration: "Eau de Parfum",
                     topNotes: ["Jasmine"], heartNotes: ["Cashmeran", "Tiger Wood"], baseNotes: ["Amber", "Musk", "White Amber"], gender: "Women"),
        PerfumeEntry(id: "mugler-angel", name: "Angel", brand: "Mugler", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Coconut", "Cassia"], heartNotes: ["Honey", "Chocolate", "Caramel"], baseNotes: ["Patchouli", "Vanilla", "Musk", "Tonka Bean"], gender: "Women"),

        // AZZARO
        PerfumeEntry(id: "azzaro-most-wanted", name: "The Most Wanted", brand: "Azzaro", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Lemon", "Bergamot"], heartNotes: ["Toffee", "Iris", "Cinnamon"], baseNotes: ["Vanilla", "Amber", "Patchouli", "Benzoin"], gender: "Men"),

        // LANCOME
        PerfumeEntry(id: "lancome-la-vie-est-belle", name: "La Vie Est Belle", brand: "Lancôme", concentration: "Eau de Parfum",
                     topNotes: ["Blackcurrant", "Pear"], heartNotes: ["Iris", "Jasmine", "Orange Blossom"], baseNotes: ["Patchouli", "Vanilla", "Praline", "Tonka Bean"], gender: "Women"),
        PerfumeEntry(id: "lancome-idole", name: "Idôle", brand: "Lancôme", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Pear"], heartNotes: ["Rose", "Jasmine", "Iris"], baseNotes: ["Patchouli", "Vanilla", "Musk", "Sandalwood", "Cedar", "Cashmere Wood"], gender: "Women"),

        // NARCISO RODRIGUEZ
        PerfumeEntry(id: "narciso-for-him-bleu-noir", name: "For Him Bleu Noir", brand: "Narciso Rodriguez", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Nutmeg", "Bergamot"], heartNotes: ["Musk", "Blue Ebony"], baseNotes: ["Cedar", "Black Leather", "Amber"], gender: "Men"),
        PerfumeEntry(id: "narciso-for-her", name: "For Her", brand: "Narciso Rodriguez", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Peach"], heartNotes: ["Musk", "Amber"], baseNotes: ["Sandalwood", "Patchouli", "Vetiver"], gender: "Women"),

        // GIVENCHY
        PerfumeEntry(id: "givenchy-gentleman-edp", name: "Gentleman", brand: "Givenchy", concentration: "Eau de Parfum",
                     topNotes: ["Pepper", "Lavender"], heartNotes: ["Iris", "Orange Blossom"], baseNotes: ["Tonka Bean", "Patchouli", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "givenchy-irresistible", name: "Irrésistible", brand: "Givenchy", concentration: "Eau de Parfum",
                     topNotes: ["Pear", "Ambrette"], heartNotes: ["Rose", "Iris"], baseNotes: ["Musk", "Sandalwood", "Blonde Wood"], gender: "Women"),

        // ISSEY MIYAKE
        PerfumeEntry(id: "issey-leau-dissey", name: "L'Eau d'Issey Pour Homme", brand: "Issey Miyake", concentration: "Eau de Toilette",
                     topNotes: ["Yuzu", "Bergamot", "Lemon", "Tangerine"], heartNotes: ["Lily of the Valley", "Cinnamon", "Nutmeg", "Saffron"], baseNotes: ["Sandalwood", "Cedar", "Musk", "Vetiver", "Amber"], gender: "Men"),

        // MAISON MARGIELA
        PerfumeEntry(id: "mm-jazz-club", name: "Jazz Club", brand: "Maison Margiela", concentration: "Eau de Toilette",
                     topNotes: ["Pink Pepper", "Neroli", "Lemon"], heartNotes: ["Rum", "Clary Sage", "Java Vetiver"], baseNotes: ["Tobacco", "Vanilla", "Tonka Bean", "Styrax"], gender: "Unisex"),
        PerfumeEntry(id: "mm-by-the-fireplace", name: "By the Fireplace", brand: "Maison Margiela", concentration: "Eau de Toilette",
                     topNotes: ["Clove", "Pink Pepper", "Orange"], heartNotes: ["Chestnut", "Guaiac Wood"], baseNotes: ["Vanilla", "Peru Balsam", "Cashmeran", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "mm-bubble-bath", name: "Bubble Bath", brand: "Maison Margiela", concentration: "Eau de Toilette",
                     topNotes: ["Lavender", "Rose", "Lemon"], heartNotes: ["Coconut", "Soap", "Lily of the Valley"], baseNotes: ["Musk", "Sandalwood", "Cedar"], gender: "Unisex"),

        // DIPTYQUE
        PerfumeEntry(id: "diptyque-tam-dao", name: "Tam Dao", brand: "Diptyque", concentration: "Eau de Parfum",
                     topNotes: ["Rosewood", "Myrtle", "Cypress"], heartNotes: ["Italian Cypress", "Rose"], baseNotes: ["Sandalwood", "Spicy Notes", "Amber", "Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "diptyque-philosykos", name: "Philosykos", brand: "Diptyque", concentration: "Eau de Parfum",
                     topNotes: ["Fig Leaf", "Green Notes"], heartNotes: ["Fig", "Coconut"], baseNotes: ["Cedar", "Musk", "Woody Notes"], gender: "Unisex"),

        // ACQUA DI PARMA
        PerfumeEntry(id: "adp-colonia", name: "Colonia", brand: "Acqua di Parma", concentration: "Eau de Cologne",
                     topNotes: ["Lemon", "Bergamot", "Orange", "Lavender"], heartNotes: ["Bulgarian Rose", "Rosemary", "Verbena"], baseNotes: ["Vetiver", "Sandalwood", "Patchouli", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "adp-oud-edp", name: "Oud & Spice", brand: "Acqua di Parma", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Rose", "Cinnamon", "Oud"], baseNotes: ["Amber", "Vanilla", "Musk"], gender: "Men"),

        // PENHALIGON'S
        PerfumeEntry(id: "penhaligons-halfeti", name: "Halfeti", brand: "Penhaligon's", concentration: "Eau de Parfum",
                     topNotes: ["Grapefruit", "Bergamot", "Green Notes"], heartNotes: ["Rose", "Jasmine", "Oud", "Saffron"], baseNotes: ["Sandalwood", "Amber", "Leather", "Vanilla", "Musk"], gender: "Unisex"),

        // TIFFANY & CO
        PerfumeEntry(id: "tiffany-edp", name: "Tiffany & Co.", brand: "Tiffany & Co.", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Lemon", "Green Notes"], heartNotes: ["Iris", "Rose", "Jasmine"], baseNotes: ["Patchouli", "Musk", "Sandalwood", "Cashmeran"], gender: "Women"),

        // JO MALONE
        PerfumeEntry(id: "jm-english-pear", name: "English Pear & Freesia", brand: "Jo Malone", concentration: "Eau de Cologne",
                     topNotes: ["Pear", "Melon"], heartNotes: ["Freesia", "Rose"], baseNotes: ["Musk", "Patchouli", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "jm-wood-sage", name: "Wood Sage & Sea Salt", brand: "Jo Malone", concentration: "Eau de Cologne",
                     topNotes: ["Ambrette", "Sea Salt"], heartNotes: ["Sage", "Sea Kale"], baseNotes: ["Grapefruit", "Driftwood"], gender: "Unisex"),
        PerfumeEntry(id: "jm-peony-blush", name: "Peony & Blush Suede", brand: "Jo Malone", concentration: "Eau de Cologne",
                     topNotes: ["Red Apple", "Nectarine"], heartNotes: ["Peony", "Rose", "Jasmine", "Carnation", "Honey"], baseNotes: ["Suede", "Musk"], gender: "Unisex"),

        // MARC JACOBS
        PerfumeEntry(id: "mj-daisy", name: "Daisy", brand: "Marc Jacobs", concentration: "Eau de Toilette",
                     topNotes: ["Strawberry", "Violet Leaf", "Blood Grapefruit"], heartNotes: ["Gardenia", "Violet", "Jasmine"], baseNotes: ["Musk", "Vanilla", "White Wood"], gender: "Women"),

        // CHLOE
        PerfumeEntry(id: "chloe-edp", name: "Chloé", brand: "Chloé", concentration: "Eau de Parfum",
                     topNotes: ["Peony", "Lychee", "Freesia"], heartNotes: ["Rose", "Lily of the Valley", "Magnolia"], baseNotes: ["Amber", "Cedar", "Musk"], gender: "Women"),

        // BVLGARI
        PerfumeEntry(id: "bvlgari-man-in-black", name: "Man in Black", brand: "Bvlgari", concentration: "Eau de Parfum",
                     topNotes: ["Rum", "Spices", "Tobacco"], heartNotes: ["Iris", "Leather", "Tuberose"], baseNotes: ["Guaiac Wood", "Benzoin", "Tonka Bean", "Musk"], gender: "Men"),
        PerfumeEntry(id: "bvlgari-omnia-crystalline", name: "Omnia Crystalline", brand: "Bvlgari", concentration: "Eau de Toilette",
                     topNotes: ["Bamboo", "Nashi Pear"], heartNotes: ["Lotus", "Balsa Wood"], baseNotes: ["Musk", "Amber"], gender: "Women"),

        // MONTALE
        PerfumeEntry(id: "montale-intense-cafe", name: "Intense Café", brand: "Montale", concentration: "Eau de Parfum",
                     topNotes: ["Coffee", "Floral Notes"], heartNotes: ["Rose", "Amber"], baseNotes: ["Vanilla", "White Musk", "Sandalwood"], gender: "Unisex"),

        // MANCERA
        PerfumeEntry(id: "mancera-cedrat-boise", name: "Cedrat Boisé", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Black Currant", "Sicilian Lemon"], heartNotes: ["Spicy Notes", "Patchouli", "Jasmine"], baseNotes: ["Sandalwood", "Leather", "Vanilla", "Musk", "White Cedar"], gender: "Unisex"),

        // DAVID BECKHAM
        PerfumeEntry(id: "beckham-instinct", name: "Instinct", brand: "David Beckham", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Mandarin", "Green Apple"], heartNotes: ["Cardamom", "Star Anise", "Pimento Leaf"], baseNotes: ["Patchouli", "Sandalwood", "Amber", "Musk"], gender: "Men"),

        // CALVIN KLEIN
        PerfumeEntry(id: "ck-eternity", name: "Eternity", brand: "Calvin Klein", concentration: "Eau de Toilette",
                     topNotes: ["Mandarin", "Lavender", "Green Notes"], heartNotes: ["Sage", "Jasmine", "Basil", "Rose"], baseNotes: ["Sandalwood", "Amber", "Cedar", "Musk"], gender: "Men"),
        PerfumeEntry(id: "ck-one", name: "CK One", brand: "Calvin Klein", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Cardamom", "Pineapple", "Lemon", "Papaya"], heartNotes: ["Jasmine", "Violet", "Rose", "Nutmeg", "Lily of the Valley"], baseNotes: ["Musk", "Sandalwood", "Amber", "Cedar", "Oak Moss"], gender: "Unisex"),

        // CLINIQUE
        PerfumeEntry(id: "clinique-happy", name: "Happy", brand: "Clinique", concentration: "Eau de Parfum",
                     topNotes: ["Indian Mandarin", "Blood Grapefruit", "Bergamot", "Apple"], heartNotes: ["Lily of the Valley", "Freesia", "Morning Dew Orchid", "Rose"], baseNotes: ["Amber", "Musk"], gender: "Women"),

        // DOLCE & GABBANA
        PerfumeEntry(id: "dg-the-one-for-her", name: "The One", brand: "Dolce & Gabbana", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Lychee", "Peach"], heartNotes: ["Jasmine", "Lily", "Plum"], baseNotes: ["Amber", "Vetiver", "Musk", "Vanilla"], gender: "Women"),

        // KILIAN
        PerfumeEntry(id: "kilian-love", name: "Love, Don't Be Shy", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Neroli", "Pink Pepper"], heartNotes: ["Orange Blossom", "Iris", "Rose"], baseNotes: ["Vanilla", "Sugar", "Musk", "Caramel", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "kilian-angels-share", name: "Angels' Share", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Cognac", "Cinnamon"], heartNotes: ["Praline", "Tonka Bean", "Oak"], baseNotes: ["Vanilla", "Sandalwood"], gender: "Unisex"),

        // CLEAN
        PerfumeEntry(id: "clean-reserve-sueded-oud", name: "Sueded Oud", brand: "Clean Reserve", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Bergamot"], heartNotes: ["Oud", "Sandalwood"], baseNotes: ["Musk", "Suede", "Amber"], gender: "Unisex"),

        // LATTAFA
        PerfumeEntry(id: "lattafa-khamrah", name: "Khamrah", brand: "Lattafa", concentration: "Eau de Parfum",
                     topNotes: ["Cinnamon", "Nutmeg", "Bergamot"], heartNotes: ["Dates", "Praline", "Tuberose"], baseNotes: ["Vanilla", "Tonka Bean", "Benzoin", "Amber", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "lattafa-bade-al-oud-amethyst", name: "Bade'e Al Oud Amethyst", brand: "Lattafa", concentration: "Eau de Parfum",
                     topNotes: ["Plum", "Apple", "Saffron"], heartNotes: ["Rose", "Oud", "Amber"], baseNotes: ["Musk", "Vanilla", "Sandalwood"], gender: "Unisex"),

        // ARMAF
        PerfumeEntry(id: "armaf-cdnim", name: "Club de Nuit Intense Man", brand: "Armaf", concentration: "Eau de Toilette",
                     topNotes: ["Lemon", "Pineapple", "Bergamot", "Apple", "Black Currant"], heartNotes: ["Birch", "Jasmine", "Rose"], baseNotes: ["Musk", "Ambergris", "Patchouli", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "armaf-cdniw", name: "Club de Nuit Intense Woman", brand: "Armaf", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Orange", "Bergamot", "Peach"], heartNotes: ["Rose", "Jasmine", "Iris"], baseNotes: ["Patchouli", "Vanilla", "Musk"], gender: "Women"),

        // JULIETTE HAS A GUN
        PerfumeEntry(id: "jhag-not-a-perfume", name: "Not a Perfume", brand: "Juliette Has a Gun", concentration: "Eau de Parfum",
                     topNotes: ["Ambroxan"], heartNotes: ["Ambroxan"], baseNotes: ["Ambroxan"], gender: "Unisex"),
        PerfumeEntry(id: "jhag-mmm", name: "Musc Invisible", brand: "Juliette Has a Gun", concentration: "Eau de Parfum",
                     topNotes: ["Cotton Flower", "Jasmine"], heartNotes: ["Musk", "Iris"], baseNotes: ["Amber", "Sandalwood", "Musk"], gender: "Women"),

        // FERRAGAMO
        PerfumeEntry(id: "ferragamo-uomo", name: "Uomo", brand: "Salvatore Ferragamo", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Cardamom", "Black Pepper"], heartNotes: ["Cypress", "Tiare Flower"], baseNotes: ["Tonka Bean", "Sandalwood", "Cashmeran", "Ambroxan"], gender: "Men"),

        // COACH
        PerfumeEntry(id: "coach-for-men", name: "Coach for Men", brand: "Coach", concentration: "Eau de Toilette",
                     topNotes: ["Nashi Pear", "Kumquat", "Bergamot"], heartNotes: ["Cardamom", "Coriander"], baseNotes: ["Vetiver", "Suede", "Ambroxan"], gender: "Men"),

        // JIMMY CHOO
        PerfumeEntry(id: "jimmy-choo-man", name: "Man", brand: "Jimmy Choo", concentration: "Eau de Toilette",
                     topNotes: ["Lavender", "Mandarin", "Honeydew Melon"], heartNotes: ["Pink Pepper", "Geranium", "Patchouli"], baseNotes: ["Suede", "Amber", "Sandalwood"], gender: "Men"),

        // DIOR (additional)
        PerfumeEntry(id: "dior-sauvage-parfum", name: "Sauvage", brand: "Dior", concentration: "Parfum",
                     topNotes: ["Bergamot"], heartNotes: ["Lavender", "Sichuan Pepper"], baseNotes: ["Sandalwood", "Vanilla", "Ambroxan"], gender: "Men"),
        PerfumeEntry(id: "dior-homme-cologne", name: "Dior Homme Cologne", brand: "Dior", concentration: "Eau de Cologne",
                     topNotes: ["Bergamot", "Grapefruit", "Lemon"], heartNotes: ["White Musk", "Cardamom"], baseNotes: ["Vetiver", "Musk"], gender: "Men"),
        PerfumeEntry(id: "dior-fahrenheit", name: "Fahrenheit", brand: "Dior", concentration: "Eau de Toilette",
                     topNotes: ["Lavender", "Mandarin", "Hawthorn"], heartNotes: ["Nutmeg", "Cedar", "Violet"], baseNotes: ["Leather", "Vetiver", "Tonka Bean", "Amber"], gender: "Men"),
        PerfumeEntry(id: "dior-oud-ispahan", name: "Oud Ispahan", brand: "Dior", concentration: "Eau de Parfum",
                     topNotes: ["Labdanum"], heartNotes: ["Rose", "Oud"], baseNotes: ["Sandalwood", "Vetiver", "Patchouli"], gender: "Unisex"),
        PerfumeEntry(id: "dior-ambre-nuit", name: "Ambre Nuit", brand: "Dior", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Grapefruit"], heartNotes: ["Rose", "Pink Pepper"], baseNotes: ["Amber", "Guaiac Wood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "dior-jadore-infinissime", name: "J'adore Infinissime", brand: "Dior", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Centifolia Rose"], heartNotes: ["Jasmine", "Tuberose"], baseNotes: ["Sandalwood", "Musk", "Vanilla"], gender: "Women"),
        PerfumeEntry(id: "dior-joy", name: "Joy", brand: "Dior", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin"], heartNotes: ["Rose", "Jasmine", "Grasse Rose"], baseNotes: ["Sandalwood", "Musk", "Cedar"], gender: "Women"),

        // CHANEL (additional)
        PerfumeEntry(id: "chanel-allure-homme-edition-blanche", name: "Allure Homme Edition Blanche", brand: "Chanel", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Mandarin"], heartNotes: ["Pepper", "Cedar"], baseNotes: ["Sandalwood", "Vanilla", "Tonka Bean", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "chanel-platinum-egoiste", name: "Platinum Égoïste", brand: "Chanel", concentration: "Eau de Toilette",
                     topNotes: ["Lavender", "Rosemary", "Neroli"], heartNotes: ["Clary Sage", "Geranium", "Jasmine"], baseNotes: ["Sandalwood", "Vetiver", "Cedar", "Oak Moss"], gender: "Men"),
        PerfumeEntry(id: "chanel-coco-noir", name: "Coco Noir", brand: "Chanel", concentration: "Eau de Parfum",
                     topNotes: ["Grapefruit", "Bergamot"], heartNotes: ["Rose", "Narcissus", "Geranium"], baseNotes: ["Sandalwood", "Patchouli", "Vanilla", "Tonka Bean", "Musk"], gender: "Women"),
        PerfumeEntry(id: "chanel-chance-eau-fraiche", name: "Chance Eau Fraîche", brand: "Chanel", concentration: "Eau de Toilette",
                     topNotes: ["Citrus", "Cedar", "Water Hyacinth"], heartNotes: ["Jasmine", "Teak"], baseNotes: ["Amber", "Patchouli", "Vetiver", "Iris", "Musk"], gender: "Women"),
        PerfumeEntry(id: "chanel-no19", name: "N°19", brand: "Chanel", concentration: "Eau de Parfum",
                     topNotes: ["Neroli", "Galbanum", "Green Notes"], heartNotes: ["Iris", "Jasmine", "Rose", "Lily of the Valley"], baseNotes: ["Vetiver", "Musk", "Oak Moss", "Leather"], gender: "Women"),

        // TOM FORD (additional)
        PerfumeEntry(id: "tf-fucking-fabulous", name: "Fucking Fabulous", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Almond"], heartNotes: ["Orris", "Cashmeran", "Leather"], baseNotes: ["Amber", "Tonka Bean", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "tf-soleil-blanc", name: "Soleil Blanc", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Cardamom", "Pink Pepper"], heartNotes: ["Ylang Ylang", "Tuberose", "Jasmine"], baseNotes: ["Coconut", "Amber", "Musk", "Benzoin"], gender: "Unisex"),
        PerfumeEntry(id: "tf-cafe-rose", name: "Café Rose", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Turkish Rose", "Saffron"], heartNotes: ["Coffee", "Incense", "Black Pepper"], baseNotes: ["Sandalwood", "Oud", "Patchouli", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "tf-rose-prick", name: "Rose Prick", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Turkish Rose", "Bulgarian Rose"], heartNotes: ["May Rose", "Sichuan Pepper", "Turmeric"], baseNotes: ["Patchouli", "Tonka Bean", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "tf-ombre-leather", name: "Ombré Leather", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Violet Leaf"], heartNotes: ["Leather", "Jasmine"], baseNotes: ["Patchouli", "Amber", "Moss"], gender: "Unisex"),
        PerfumeEntry(id: "tf-white-suede", name: "White Suede", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Thyme", "Musk Rose"], heartNotes: ["Suede", "Lily", "Rose"], baseNotes: ["Amber", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "tf-tobacco-oud", name: "Tobacco Oud", brand: "Tom Ford", concentration: "Eau de Parfum",
                     topNotes: ["Spicy Notes", "Whiskey"], heartNotes: ["Oud", "Tobacco"], baseNotes: ["Sandalwood", "Patchouli", "Benzoin"], gender: "Unisex"),

        // CREED (additional)
        PerfumeEntry(id: "creed-millesime-imperial", name: "Millésime Impérial", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Sea Salt", "Lemon"], heartNotes: ["Iris", "Melon"], baseNotes: ["Musk", "Ambergris", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "creed-royal-oud", name: "Royal Oud", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Pink Pepper", "Bergamot"], heartNotes: ["Oud", "Cedar", "Galbanum"], baseNotes: ["Sandalwood", "Tonka Bean", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "creed-original-vetiver", name: "Original Vetiver", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Neroli"], heartNotes: ["Iris", "Violet"], baseNotes: ["Vetiver", "Musk", "Ambergris"], gender: "Men"),
        PerfumeEntry(id: "creed-love-in-white", name: "Love in White", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Orange", "Bergamot", "Magnolia", "Pink Pepper"], heartNotes: ["Iris", "Rice", "Daffodil"], baseNotes: ["Sandalwood", "Ambergris", "Musk", "Vanilla"], gender: "Women"),
        PerfumeEntry(id: "creed-aventus-for-her", name: "Aventus for Her", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Apple", "Pink Pepper", "Bergamot", "Lemon"], heartNotes: ["Rose", "Lily of the Valley", "Peach", "Violet"], baseNotes: ["Sandalwood", "Musk", "Patchouli", "Amber", "Moss"], gender: "Women"),
        PerfumeEntry(id: "creed-wind-flowers", name: "Wind Flowers", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Orange Blossom", "Bergamot"], heartNotes: ["Tuberose", "Jasmine", "Iris"], baseNotes: ["Musk", "Sandalwood"], gender: "Women"),

        // VERSACE (additional)
        PerfumeEntry(id: "versace-pour-homme", name: "Pour Homme", brand: "Versace", concentration: "Eau de Toilette",
                     topNotes: ["Lemon", "Neroli", "Bergamot", "Citron"], heartNotes: ["Hyacinth", "Cedar", "Clary Sage"], baseNotes: ["Amber", "Musk", "Saffron"], gender: "Men"),
        PerfumeEntry(id: "versace-eros-flame", name: "Eros Flame", brand: "Versace", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Black Pepper", "Lemon", "Chinotto"], heartNotes: ["Rosemary", "Pepper", "Geranium"], baseNotes: ["Sandalwood", "Vanilla", "Patchouli", "Tonka Bean", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "versace-crystal-noir", name: "Crystal Noir", brand: "Versace", concentration: "Eau de Toilette",
                     topNotes: ["Ginger", "Cardamom", "Pepper"], heartNotes: ["Gardenia", "Coconut", "Peony"], baseNotes: ["Musk", "Sandalwood", "Amber", "Cashmere Wood"], gender: "Women"),
        PerfumeEntry(id: "versace-pour-femme", name: "Pour Femme", brand: "Versace", concentration: "Eau de Parfum",
                     topNotes: ["Raspberry", "Bergamot", "Citrus"], heartNotes: ["Jasmine", "Rose", "Lotus"], baseNotes: ["Musk", "Sandalwood", "Cedar"], gender: "Women"),

        // YSL (additional)
        PerfumeEntry(id: "ysl-y-edt", name: "Y", brand: "Yves Saint Laurent", concentration: "Eau de Toilette",
                     topNotes: ["Apple", "Bergamot", "Ginger"], heartNotes: ["Geranium", "Sage"], baseNotes: ["Cedar", "Vetiver", "Fir Balsam", "Tonka Bean"], gender: "Men"),
        PerfumeEntry(id: "ysl-y-le-parfum", name: "Y Le Parfum", brand: "Yves Saint Laurent", concentration: "Parfum",
                     topNotes: ["Bergamot", "Ginger", "Aldehydes"], heartNotes: ["Sage", "Lavender", "Geranium"], baseNotes: ["Tonka Bean", "Incense", "Musk"], gender: "Men"),
        PerfumeEntry(id: "ysl-lhomme", name: "L'Homme", brand: "Yves Saint Laurent", concentration: "Eau de Toilette",
                     topNotes: ["Ginger", "Bergamot", "Lemon"], heartNotes: ["White Pepper", "Violet Leaf", "Basil"], baseNotes: ["Tonka Bean", "Cedar", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "ysl-opium", name: "Opium", brand: "Yves Saint Laurent", concentration: "Eau de Toilette",
                     topNotes: ["Mandarin", "Bergamot", "Plum", "Clove"], heartNotes: ["Jasmine", "Rose", "Lily of the Valley", "Carnation", "Cinnamon", "Peach"], baseNotes: ["Sandalwood", "Cedar", "Vanilla", "Patchouli", "Amber", "Musk", "Tonka Bean"], gender: "Women"),
        PerfumeEntry(id: "ysl-libre-intense", name: "Libre Intense", brand: "Yves Saint Laurent", concentration: "Eau de Parfum Intense",
                     topNotes: ["Mandarin", "Lavender"], heartNotes: ["Orange Blossom", "Jasmine"], baseNotes: ["Vanilla", "Musk", "Tonka Bean", "Sandalwood"], gender: "Women"),

        // GIORGIO ARMANI (additional)
        PerfumeEntry(id: "armani-acqua-di-gio-profondo", name: "Acqua di Giò Profondo", brand: "Giorgio Armani", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Green Mandarin", "Aquatic Notes"], heartNotes: ["Rosemary", "Cypress", "Lavender"], baseNotes: ["Patchouli", "Musk", "Amber", "Mineral Notes"], gender: "Men"),
        PerfumeEntry(id: "armani-stronger-with-you", name: "Stronger With You", brand: "Giorgio Armani", concentration: "Eau de Toilette",
                     topNotes: ["Cardamom", "Pink Pepper", "Violet Leaf"], heartNotes: ["Sage", "Cinnamon"], baseNotes: ["Vanilla", "Chestnut", "Amber"], gender: "Men"),
        PerfumeEntry(id: "armani-stronger-with-you-intensely", name: "Stronger With You Intensely", brand: "Giorgio Armani", concentration: "Eau de Parfum Intense",
                     topNotes: ["Pink Pepper", "Juniper Berries", "Violet"], heartNotes: ["Cinnamon", "Toffee", "Sage"], baseNotes: ["Vanilla", "Amber", "Suede", "Chestnut"], gender: "Men"),
        PerfumeEntry(id: "armani-si-passione", name: "Sì Passione", brand: "Giorgio Armani", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Pear", "Bergamot", "Blackcurrant"], heartNotes: ["Rose", "Jasmine", "Heliotrope"], baseNotes: ["Vanilla", "Cedar", "Musk", "Ambroxan", "Benzoin", "Sandalwood"], gender: "Women"),

        // PRADA (additional)
        PerfumeEntry(id: "prada-luna-rossa-black", name: "Luna Rossa Black", brand: "Prada", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Angelica"], heartNotes: ["Coumarin", "Patchouli"], baseNotes: ["Amber", "Sandalwood", "Musk"], gender: "Men"),
        PerfumeEntry(id: "prada-lhomme-leau", name: "L'Homme L'Eau", brand: "Prada", concentration: "Eau de Toilette",
                     topNotes: ["Neroli", "Iris", "Ginger"], heartNotes: ["Amber", "Geranium"], baseNotes: ["Sandalwood", "Cedar", "Musk"], gender: "Men"),
        PerfumeEntry(id: "prada-infusion-diris", name: "Infusion d'Iris", brand: "Prada", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Orange", "Neroli", "Galbanum"], heartNotes: ["Iris", "Incense"], baseNotes: ["Vetiver", "Cedar", "Benzoin"], gender: "Women"),

        // DOLCE & GABBANA (additional)
        PerfumeEntry(id: "dg-the-one-edt", name: "The One", brand: "Dolce & Gabbana", concentration: "Eau de Toilette",
                     topNotes: ["Grapefruit", "Coriander", "Basil"], heartNotes: ["Ginger", "Cardamom", "Orange Blossom"], baseNotes: ["Cedar", "Labdanum", "Amber"], gender: "Men"),
        PerfumeEntry(id: "dg-the-one-elixir", name: "The One Elixir", brand: "Dolce & Gabbana", concentration: "Parfum",
                     topNotes: ["Blood Orange", "Ginger"], heartNotes: ["Cardamom", "Violet", "Geranium"], baseNotes: ["Amber", "Guaiac Wood", "Vanilla", "Leather"], gender: "Men"),
        PerfumeEntry(id: "dg-light-blue-forever", name: "Light Blue Forever", brand: "Dolce & Gabbana", concentration: "Eau de Parfum",
                     topNotes: ["Grapefruit", "Lemon", "Green Apple"], heartNotes: ["Ozonic Notes", "Sea Water", "Geranium"], baseNotes: ["Musk", "Oakmoss", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "dg-devotion", name: "Devotion", brand: "Dolce & Gabbana", concentration: "Eau de Parfum",
                     topNotes: ["Candied Lemon", "Rum"], heartNotes: ["Orange Blossom", "Cannoli Cream"], baseNotes: ["Vanilla", "Sandalwood", "Musk"], gender: "Women"),

        // VALENTINO (additional)
        PerfumeEntry(id: "valentino-uomo-born-in-roma-intense", name: "Uomo Born in Roma Intense", brand: "Valentino", concentration: "Eau de Parfum",
                     topNotes: ["Ginger", "Green Mandarin"], heartNotes: ["Vetiver", "Tobacco"], baseNotes: ["Guaiac Wood", "Vanilla", "Cashmeran", "Benzoin"], gender: "Men"),
        PerfumeEntry(id: "valentino-donna-born-in-roma-coral", name: "Donna Born in Roma Coral Fantasy", brand: "Valentino", concentration: "Eau de Parfum",
                     topNotes: ["Muguet", "Orange Blossom", "Grapefruit"], heartNotes: ["Jasmine", "Osmanthus"], baseNotes: ["Musk", "Vanilla", "Cedar"], gender: "Women"),

        // BURBERRY (additional)
        PerfumeEntry(id: "burberry-london-men", name: "London", brand: "Burberry", concentration: "Eau de Toilette",
                     topNotes: ["Lavender", "Bergamot", "Cinnamon"], heartNotes: ["Mimosa", "Leather"], baseNotes: ["Tobacco", "Opoponax", "Oak Moss", "Guaiac Wood"], gender: "Men"),
        PerfumeEntry(id: "burberry-hero", name: "Hero", brand: "Burberry", concentration: "Eau de Toilette",
                     topNotes: ["Black Pepper", "Bergamot", "Lemon"], heartNotes: ["Cedar", "Juniper Berries"], baseNotes: ["Benzoin", "Ebony Wood", "Black Tea"], gender: "Men"),
        PerfumeEntry(id: "burberry-hero-edp", name: "Hero", brand: "Burberry", concentration: "Eau de Parfum",
                     topNotes: ["Cedar", "Bergamot"], heartNotes: ["Cedarwood", "Pine"], baseNotes: ["Musk", "Benzoin", "Leather", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "burberry-her-edt", name: "Her", brand: "Burberry", concentration: "Eau de Toilette",
                     topNotes: ["Pear", "Red Currant", "Mandarin"], heartNotes: ["Peony", "Rose", "Nectarine"], baseNotes: ["Lavender", "Musk"], gender: "Women"),
        PerfumeEntry(id: "burberry-goddess", name: "Goddess", brand: "Burberry", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Ginger"], heartNotes: ["Vanilla Absolute", "Cocoa"], baseNotes: ["Vanilla", "Musk", "Sandalwood"], gender: "Women"),

        // HERMÈS (additional)
        PerfumeEntry(id: "hermes-eau-dorange-verte", name: "Eau d'Orange Verte", brand: "Hermès", concentration: "Eau de Cologne",
                     topNotes: ["Mandarin", "Orange", "Lemon"], heartNotes: ["Blackcurrant", "Mint"], baseNotes: ["Oak Moss", "Patchouli", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "hermes-un-jardin-sur-le-nil", name: "Un Jardin sur le Nil", brand: "Hermès", concentration: "Eau de Toilette",
                     topNotes: ["Green Mango", "Lotus", "Grapefruit"], heartNotes: ["Calamus", "Orange", "Peony"], baseNotes: ["Musk", "Incense", "Sycamore"], gender: "Unisex"),
        PerfumeEntry(id: "hermes-eau-des-merveilles", name: "Eau des Merveilles", brand: "Hermès", concentration: "Eau de Toilette",
                     topNotes: ["Orange", "Lemon", "Elemi"], heartNotes: ["Pink Pepper", "Violet", "Oak"], baseNotes: ["Amber", "Cedar", "Musk", "Vetiver"], gender: "Women"),
        PerfumeEntry(id: "hermes-24-faubourg", name: "24 Faubourg", brand: "Hermès", concentration: "Eau de Parfum",
                     topNotes: ["Orange Blossom", "Peach", "Mandarin"], heartNotes: ["Jasmine", "Iris", "Ylang Ylang", "Tiare Flower"], baseNotes: ["Vanilla", "Sandalwood", "Ambergris", "Patchouli"], gender: "Women"),

        // GUERLAIN (additional)
        PerfumeEntry(id: "guerlain-lhomme-ideal-extreme", name: "L'Homme Idéal Extrême", brand: "Guerlain", concentration: "Eau de Parfum Intense",
                     topNotes: ["Almond", "Bergamot"], heartNotes: ["Bulgarian Rose", "Smoky Notes"], baseNotes: ["Tonka Bean", "Vanilla", "Leather", "Benzoin"], gender: "Men"),
        PerfumeEntry(id: "guerlain-habit-rouge", name: "Habit Rouge", brand: "Guerlain", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Basil", "Rose"], heartNotes: ["Carnation", "Cinnamon", "Patchouli"], baseNotes: ["Vanilla", "Amber", "Leather", "Sandalwood", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "guerlain-vetiver", name: "Vétiver", brand: "Guerlain", concentration: "Eau de Toilette",
                     topNotes: ["Lemon", "Bergamot", "Mandarin", "Neroli"], heartNotes: ["Pepper", "Nutmeg", "Coriander", "Artemisia"], baseNotes: ["Vetiver", "Tobacco", "Tonka Bean"], gender: "Men"),
        PerfumeEntry(id: "guerlain-mon-guerlain", name: "Mon Guerlain", brand: "Guerlain", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Bergamot"], heartNotes: ["Iris", "Jasmine", "Rose"], baseNotes: ["Vanilla", "Sandalwood", "Coumarin", "Benzoin"], gender: "Women"),
        PerfumeEntry(id: "guerlain-la-petite-robe-noire", name: "La Petite Robe Noire", brand: "Guerlain", concentration: "Eau de Parfum",
                     topNotes: ["Cherry", "Bergamot", "Almond"], heartNotes: ["Rose", "Tea", "Peach"], baseNotes: ["Tonka Bean", "Patchouli", "Vanilla", "Anise"], gender: "Women"),

        // MFK (additional)
        PerfumeEntry(id: "mfk-oud-satin-mood", name: "Oud Satin Mood", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum",
                     topNotes: ["Violet"], heartNotes: ["Oud", "Bulgarian Rose", "Turkish Rose"], baseNotes: ["Benzoin", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "mfk-aqua-universalis", name: "Aqua Universalis", brand: "Maison Francis Kurkdjian", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Sicilian Lemon"], heartNotes: ["Lily of the Valley", "White Flowers"], baseNotes: ["Musk", "Wood"], gender: "Unisex"),
        PerfumeEntry(id: "mfk-petit-matin", name: "Petit Matin", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Bergamot", "Litchi"], heartNotes: ["Musk", "Orange Blossom"], baseNotes: ["Musk", "Iris"], gender: "Unisex"),
        PerfumeEntry(id: "mfk-amyris-homme", name: "Amyris Homme", brand: "Maison Francis Kurkdjian", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Rosemary"], heartNotes: ["Iris", "Orange Blossom"], baseNotes: ["Amyris", "Tonka Bean", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "mfk-a-la-rose", name: "À la Rose", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Bergamot"], heartNotes: ["Grasse Rose", "Egyptian Jasmine", "Peony"], baseNotes: ["Musk", "Cedar"], gender: "Women"),

        // BYREDO (additional)
        PerfumeEntry(id: "byredo-blanche", name: "Blanche", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Aldehyde"], heartNotes: ["Violet", "Peony", "Neroli"], baseNotes: ["Blonde Wood", "Sandalwood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "byredo-super-cedar", name: "Super Cedar", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Virginian Cedar"], heartNotes: ["Haitian Vetiver", "Cedar"], baseNotes: ["Musk", "Power Notes"], gender: "Unisex"),
        PerfumeEntry(id: "byredo-biblioteque", name: "Bibliothèque", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Peach", "Plum"], heartNotes: ["Violet", "Peony"], baseNotes: ["Patchouli", "Vanilla", "Leather"], gender: "Unisex"),
        PerfumeEntry(id: "byredo-rose-of-no-mans-land", name: "Rose of No Man's Land", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Turkish Rose Petals"], heartNotes: ["Turkish Rose", "Raspberry Blossom"], baseNotes: ["Papyrus", "White Amber", "Musk"], gender: "Unisex"),

        // LE LABO (additional)
        PerfumeEntry(id: "lelabo-bergamote-22", name: "Bergamote 22", brand: "Le Labo", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Grapefruit", "Petitgrain"], heartNotes: ["Amber", "Vetiver"], baseNotes: ["Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "lelabo-the-noir-29", name: "Thé Noir 29", brand: "Le Labo", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Bay Leaf"], heartNotes: ["Black Tea", "Fig", "Tobacco"], baseNotes: ["Musk", "Cedar", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "lelabo-tonka-25", name: "Tonka 25", brand: "Le Labo", concentration: "Eau de Parfum",
                     topNotes: ["Cedar Wood", "Musk"], heartNotes: ["Tonka Bean", "Styrax"], baseNotes: ["Cedar", "Musk", "Vanilla"], gender: "Unisex"),

        // PARFUMS DE MARLY (additional)
        PerfumeEntry(id: "pdm-herod", name: "Herod", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Cinnamon", "Pepper", "Iso E Super"], heartNotes: ["Tobacco", "Osmanthus", "Incense"], baseNotes: ["Vanilla", "Musk", "Cypriol", "Vetiver", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "pdm-carlisle", name: "Carlisle", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Green Apple", "Bergamot", "Nutmeg"], heartNotes: ["Rose", "Patchouli", "Oud"], baseNotes: ["Vanilla", "Tonka Bean", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "pdm-percival", name: "Percival", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Lavender"], heartNotes: ["Geranium", "Sage", "Cardamom"], baseNotes: ["Musk", "Amberwood", "Cashmeran"], gender: "Men"),
        PerfumeEntry(id: "pdm-greenley", name: "Greenley", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Green Apple", "Bergamot", "Sicilian Lemon"], heartNotes: ["Orange Blossom", "Violet Leaf"], baseNotes: ["Musk", "Sandalwood", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "pdm-delina-exclusif", name: "Delina Exclusif", brand: "Parfums de Marly", concentration: "Parfum",
                     topNotes: ["Pear", "Lychee", "Bergamot"], heartNotes: ["Turkish Rose", "Peony", "Agarwood"], baseNotes: ["Vanilla", "Musk", "Evernyl", "Amber", "Vetiver"], gender: "Women"),
        PerfumeEntry(id: "pdm-cassili", name: "Cassili", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Red Currant"], heartNotes: ["Peach", "Orange Blossom", "Jasmine"], baseNotes: ["Musk", "Sandalwood", "Vanilla", "Cashmeran"], gender: "Women"),

        // INITIO (additional)
        PerfumeEntry(id: "initio-musk-therapy", name: "Musk Therapy", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Musk"], heartNotes: ["Musk", "Sandalwood"], baseNotes: ["Amber", "Vanilla", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "initio-rehab", name: "Rehab", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Bergamot"], heartNotes: ["Clary Sage", "Cannabis"], baseNotes: ["Musk", "Cashmeran", "Iso E Super"], gender: "Unisex"),
        PerfumeEntry(id: "initio-atomic-rose", name: "Atomic Rose", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Lychee"], heartNotes: ["Rose Absolute", "Magnolia"], baseNotes: ["Musk", "Amberwood", "Sandalwood"], gender: "Unisex"),

        // XERJOFF (additional)
        PerfumeEntry(id: "xerjoff-alexandria-ii", name: "Alexandria II", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Aldehydes", "Bergamot", "Green Notes"], heartNotes: ["Oud", "Rose", "Saffron"], baseNotes: ["Amber", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "xerjoff-more-than-words", name: "More Than Words", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Pink Pepper"], heartNotes: ["Rose", "Iris", "Musk"], baseNotes: ["Vanilla", "Amber", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "xerjoff-nio", name: "Nio", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Bergamot", "Petit Grain"], heartNotes: ["Lavender", "Violet", "Ylang Ylang"], baseNotes: ["Musk", "Cedar", "Cashmeran", "Tonka Bean"], gender: "Men"),

        // NISHANE (additional)
        PerfumeEntry(id: "nishane-hundred-silent-ways", name: "Hundred Silent Ways", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Davana", "Orange Blossom", "Raspberry"], heartNotes: ["Iris", "Musk", "Sandalwood"], baseNotes: ["Vanilla", "Tonka Bean", "Benzoin", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "nishane-fan-your-flames", name: "Fan Your Flames", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Saffron", "Rose", "Cinnamon"], heartNotes: ["Oud", "Leather", "Labdanum"], baseNotes: ["Musk", "Vanilla", "Sandalwood", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "nishane-wulong-cha", name: "Wulong Cha", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Grapefruit", "Bergamot", "Lemon"], heartNotes: ["Oolong Tea", "Elemi", "Violet Leaf"], baseNotes: ["Musk", "Amber", "Vetiver"], gender: "Unisex"),

        // AMOUAGE (additional)
        PerfumeEntry(id: "amouage-jubilation-xxv-man", name: "Jubilation XXV Man", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Tarragon", "Olibanum", "Orange", "Blackberry"], heartNotes: ["Rose", "Orchid", "Guaiac Wood", "Labdanum"], baseNotes: ["Oud", "Musk", "Sandalwood", "Honey", "Amber"], gender: "Men"),
        PerfumeEntry(id: "amouage-memoir-man", name: "Memoir Man", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Rum", "Basil", "Absinth"], heartNotes: ["Oud", "Incense", "Iris", "Rose"], baseNotes: ["Vetiver", "Sandalwood", "Tonka Bean", "Musk"], gender: "Men"),
        PerfumeEntry(id: "amouage-dia-woman", name: "Dia Woman", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Black Pepper", "Peach"], heartNotes: ["Rose", "Jasmine", "Lily"], baseNotes: ["Sandalwood", "Musk", "Cedar", "Amber", "Incense"], gender: "Women"),

        // GUCCI (additional)
        PerfumeEntry(id: "gucci-guilty-absolute", name: "Guilty Absolute", brand: "Gucci", concentration: "Eau de Parfum",
                     topNotes: ["Leather", "Nootka Cypress Wood"], heartNotes: ["Goldenwood", "Vetiver"], baseNotes: ["Patchouli", "Woody Notes"], gender: "Men"),
        PerfumeEntry(id: "gucci-pour-homme-ii", name: "Pour Homme II", brand: "Gucci", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Green Tea", "Black Currant", "Violet"], heartNotes: ["Cinnamon", "Jasmine"], baseNotes: ["Tobacco", "Amber", "Musk"], gender: "Men"),
        PerfumeEntry(id: "gucci-memoire-dune-odeur", name: "Mémoire d'une Odeur", brand: "Gucci", concentration: "Eau de Parfum",
                     topNotes: ["Chamomile", "Bitter Almond"], heartNotes: ["Jasmine", "Musk"], baseNotes: ["Sandalwood", "Cedar", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "gucci-flora-gorgeous-jasmine", name: "Flora Gorgeous Jasmine", brand: "Gucci", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Blackberry"], heartNotes: ["Jasmine Grandiflorum", "Rose"], baseNotes: ["Benzoin", "Sandalwood", "Musk"], gender: "Women"),
        PerfumeEntry(id: "gucci-rush", name: "Rush", brand: "Gucci", concentration: "Eau de Toilette",
                     topNotes: ["Freesia", "Gardenia", "Coriander"], heartNotes: ["Rose", "Jasmine", "Patchouli"], baseNotes: ["Vetiver", "Musk", "Vanilla"], gender: "Women"),

        // HUGO BOSS (additional)
        PerfumeEntry(id: "boss-bottled-edt", name: "Bottled", brand: "Hugo Boss", concentration: "Eau de Toilette",
                     topNotes: ["Apple", "Plum", "Lemon", "Bergamot", "Oakmoss"], heartNotes: ["Cinnamon", "Geranium", "Clove"], baseNotes: ["Vanilla", "Sandalwood", "Cedar", "Vetiver", "Olive Tree"], gender: "Men"),
        PerfumeEntry(id: "boss-bottled-infinite", name: "Bottled Infinite", brand: "Hugo Boss", concentration: "Eau de Parfum",
                     topNotes: ["Apple", "Mandarin", "Rosemary"], heartNotes: ["Sage", "Patchouli", "Geranium"], baseNotes: ["Sandalwood", "Olive Tree", "Vetiver", "Musk"], gender: "Men"),
        PerfumeEntry(id: "boss-bottled-night", name: "Bottled Night", brand: "Hugo Boss", concentration: "Eau de Toilette",
                     topNotes: ["Lavender", "Birch Leaf", "Cardamom"], heartNotes: ["Violet", "Teak Wood", "Musk"], baseNotes: ["Sandalwood", "Coumarin", "Woody Notes"], gender: "Men"),
        PerfumeEntry(id: "boss-alive", name: "Alive", brand: "Hugo Boss", concentration: "Eau de Parfum",
                     topNotes: ["Apple", "Plum", "Blackcurrant"], heartNotes: ["Jasmine", "Thyme"], baseNotes: ["Sandalwood", "Cashmere Wood", "Olive Tree", "Amber"], gender: "Women"),

        // RALPH LAUREN (additional)
        PerfumeEntry(id: "rl-polo-blue", name: "Polo Blue", brand: "Ralph Lauren", concentration: "Eau de Toilette",
                     topNotes: ["Melon", "Cucumber", "Mandarin"], heartNotes: ["Basil", "Sage", "Geranium"], baseNotes: ["Suede", "Musk", "Patchouli", "Wood"], gender: "Men"),
        PerfumeEntry(id: "rl-polo-blue-edp", name: "Polo Blue", brand: "Ralph Lauren", concentration: "Eau de Parfum",
                     topNotes: ["Aquatic Notes", "Lemon", "Mandarin"], heartNotes: ["Basil", "Sage", "Clary Sage"], baseNotes: ["Suede", "Patchouli", "Vetiver"], gender: "Men"),
        PerfumeEntry(id: "rl-polo-red", name: "Polo Red", brand: "Ralph Lauren", concentration: "Eau de Toilette",
                     topNotes: ["Grapefruit", "Cranberry", "Lemon"], heartNotes: ["Saffron", "Red Apple"], baseNotes: ["Coffee", "Amber", "Wood"], gender: "Men"),
        PerfumeEntry(id: "rl-ralph", name: "Ralph", brand: "Ralph Lauren", concentration: "Eau de Toilette",
                     topNotes: ["Apple Leaf", "Mandarin", "Yellow Freesia"], heartNotes: ["Boronia", "Osmanthus", "Magnolia"], baseNotes: ["Iris", "Musk", "White Wood"], gender: "Women"),
        PerfumeEntry(id: "rl-woman", name: "Woman", brand: "Ralph Lauren", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Pear"], heartNotes: ["Tuberose", "Rose"], baseNotes: ["Sandalwood", "Musk", "Vetiver"], gender: "Women"),

        // MONTBLANC (additional)
        PerfumeEntry(id: "montblanc-legend", name: "Legend", brand: "Montblanc", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Lavender", "Pineapple Leaf"], heartNotes: ["Geranium", "Coumarin", "Apple"], baseNotes: ["Tonka Bean", "Sandalwood", "Musk"], gender: "Men"),
        PerfumeEntry(id: "montblanc-legend-spirit", name: "Legend Spirit", brand: "Montblanc", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Pink Pepper", "Grapefruit"], heartNotes: ["Cardamom", "Lavender", "Aquatic Notes"], baseNotes: ["Cashmere Wood", "Oak Moss", "Musk"], gender: "Men"),
        PerfumeEntry(id: "montblanc-legend-edp", name: "Legend", brand: "Montblanc", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Verbena", "Magnolia"], heartNotes: ["Rose", "Geranium", "Sage"], baseNotes: ["Patchouli", "Tonka Bean", "Musk", "Vanilla"], gender: "Men"),

        // CAROLINA HERRERA (additional)
        PerfumeEntry(id: "ch-212-vip", name: "212 VIP", brand: "Carolina Herrera", concentration: "Eau de Toilette",
                     topNotes: ["Passion Fruit", "Caviar Lime"], heartNotes: ["Gardenia", "Musk"], baseNotes: ["Benzoin", "Tonka Bean", "Amber"], gender: "Men"),
        PerfumeEntry(id: "ch-bad-boy-edp", name: "Bad Boy", brand: "Carolina Herrera", concentration: "Eau de Parfum",
                     topNotes: ["Green Accord", "Black Pepper", "Bergamot"], heartNotes: ["Sage", "Cedar", "Leather"], baseNotes: ["Tonka Bean", "Cacao", "Amber", "Benzoin"], gender: "Men"),
        PerfumeEntry(id: "ch-good-girl-supreme", name: "Good Girl Suprême", brand: "Carolina Herrera", concentration: "Eau de Parfum",
                     topNotes: ["Berries", "Egyptian Jasmine"], heartNotes: ["Tuberose", "Vetiver"], baseNotes: ["Tonka Bean", "Vanilla", "Brown Sugar", "Cacao", "Sandalwood"], gender: "Women"),

        // VIKTOR & ROLF (additional)
        PerfumeEntry(id: "vr-spicebomb", name: "Spicebomb", brand: "Viktor & Rolf", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Grapefruit", "Pink Pepper", "Elemi"], heartNotes: ["Cinnamon", "Saffron", "Paprika"], baseNotes: ["Tobacco", "Vetiver", "Leather"], gender: "Men"),
        PerfumeEntry(id: "vr-spicebomb-infrared", name: "Spicebomb Infrared", brand: "Viktor & Rolf", concentration: "Eau de Toilette",
                     topNotes: ["Red Pepper", "Black Pepper", "Chili Pepper"], heartNotes: ["Cinnamon", "Paprika"], baseNotes: ["Guaiac Wood", "Benzoin", "Musk"], gender: "Men"),
        PerfumeEntry(id: "vr-flowerbomb-nectar", name: "Flowerbomb Nectar", brand: "Viktor & Rolf", concentration: "Eau de Parfum Intense",
                     topNotes: ["Blackcurrant", "Bergamot", "Lemon"], heartNotes: ["Jasmine", "Rose", "Orange Blossom"], baseNotes: ["Patchouli", "Musk", "Vanilla", "Benzoin"], gender: "Women"),

        // MUGLER (additional)
        PerfumeEntry(id: "mugler-amen", name: "A*Men", brand: "Mugler", concentration: "Eau de Toilette",
                     topNotes: ["Lavender", "Mint", "Bergamot"], heartNotes: ["Coffee", "Tar"], baseNotes: ["Vanilla", "Tonka Bean", "Patchouli", "Caramel"], gender: "Men"),
        PerfumeEntry(id: "mugler-alien-goddess", name: "Alien Goddess", brand: "Mugler", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Coconut"], heartNotes: ["Jasmine", "Cashmere Wood"], baseNotes: ["Vanilla", "Bourbon Vanilla", "Musk"], gender: "Women"),

        // AZZARO (additional)
        PerfumeEntry(id: "azzaro-wanted", name: "Wanted", brand: "Azzaro", concentration: "Eau de Toilette",
                     topNotes: ["Lemon", "Ginger", "Cardamom", "Mint"], heartNotes: ["Juniper Berries", "Apple", "Thyme"], baseNotes: ["Tonka Bean", "Vetiver", "Driftwood"], gender: "Men"),
        PerfumeEntry(id: "azzaro-wanted-by-night", name: "Wanted by Night", brand: "Azzaro", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Lemon", "Cinnamon"], heartNotes: ["Red Cedar", "Cumin", "Incense"], baseNotes: ["Tobacco", "Vanilla", "Benzoin", "Iso E Super"], gender: "Men"),
        PerfumeEntry(id: "azzaro-chrome", name: "Chrome", brand: "Azzaro", concentration: "Eau de Toilette",
                     topNotes: ["Lemon", "Neroli", "Bergamot", "Rosemary"], heartNotes: ["Cyclamen", "Jasmine", "Pineapple"], baseNotes: ["Tonka Bean", "Sandalwood", "Musk", "Cedar", "Oakmoss"], gender: "Men"),

        // LANCÔME (additional)
        PerfumeEntry(id: "lancome-tresor", name: "Trésor", brand: "Lancôme", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Lilac", "Apricot", "Peach Blossom"], heartNotes: ["Iris", "Lily of the Valley", "Heliotrope"], baseNotes: ["Amber", "Sandalwood", "Musk", "Vanilla", "Apricot"], gender: "Women"),
        PerfumeEntry(id: "lancome-la-nuit-tresor", name: "La Nuit Trésor", brand: "Lancôme", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Litchi"], heartNotes: ["Orchid", "Rose", "Praline"], baseNotes: ["Papyrus", "Vanilla", "Chocolate"], gender: "Women"),
        PerfumeEntry(id: "lancome-miracle", name: "Miracle", brand: "Lancôme", concentration: "Eau de Parfum",
                     topNotes: ["Lychee", "Freesia", "Mandarin"], heartNotes: ["Magnolia", "Jasmine", "Ginger", "Pepper"], baseNotes: ["Amber", "Musk", "Sandalwood"], gender: "Women"),

        // NARCISO RODRIGUEZ (additional)
        PerfumeEntry(id: "narciso-for-him-edp", name: "For Him", brand: "Narciso Rodriguez", concentration: "Eau de Parfum",
                     topNotes: ["Neroli", "Cardamom"], heartNotes: ["Musk", "Iris", "Violet"], baseNotes: ["Vetiver", "Cedar", "Amber"], gender: "Men"),
        PerfumeEntry(id: "narciso-narciso-edp", name: "Narciso", brand: "Narciso Rodriguez", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Bulgarian Rose"], heartNotes: ["Musk", "Vetiver"], baseNotes: ["Cedar", "Amber", "Vanilla", "Black Cedar"], gender: "Women"),

        // GIVENCHY (additional)
        PerfumeEntry(id: "givenchy-gentleman-reserve-privee", name: "Gentleman Réserve Privée", brand: "Givenchy", concentration: "Eau de Parfum",
                     topNotes: ["Ginger", "Bergamot"], heartNotes: ["Iris", "Orange Blossom"], baseNotes: ["Benzoin", "Whiskey", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "givenchy-pi", name: "Pi", brand: "Givenchy", concentration: "Eau de Toilette",
                     topNotes: ["Mandarin", "Tarragon", "Basil", "Neroli", "Rosemary"], heartNotes: ["Lily of the Valley", "Mimosa", "Geranium"], baseNotes: ["Vanilla", "Tonka Bean", "Cedar", "Benzoin"], gender: "Men"),
        PerfumeEntry(id: "givenchy-linterdit", name: "L'Interdit", brand: "Givenchy", concentration: "Eau de Parfum",
                     topNotes: ["Pear", "Bergamot"], heartNotes: ["Orange Blossom", "Jasmine", "Tuberose"], baseNotes: ["Patchouli", "Vetiver", "Musk", "Ambroxan"], gender: "Women"),
        PerfumeEntry(id: "givenchy-linterdit-rouge", name: "L'Interdit Rouge", brand: "Givenchy", concentration: "Eau de Parfum",
                     topNotes: ["Ginger", "Saffron"], heartNotes: ["Tuberose", "Orange Blossom"], baseNotes: ["Vetiver", "Sandalwood", "Sesame"], gender: "Women"),

        // ISSEY MIYAKE (additional)
        PerfumeEntry(id: "issey-leau-dissey-pour-homme-intense", name: "L'Eau d'Issey Pour Homme Intense", brand: "Issey Miyake", concentration: "Eau de Toilette Intense",
                     topNotes: ["Mandarin", "Bergamot", "Yuzu"], heartNotes: ["Saffron", "Nutmeg", "Blue Lotus"], baseNotes: ["Amber", "Vetiver", "Sandalwood", "Musk", "Benzoin"], gender: "Men"),
        PerfumeEntry(id: "issey-nuit-dissey", name: "Nuit d'Issey", brand: "Issey Miyake", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Grapefruit"], heartNotes: ["Leather", "Black Pepper"], baseNotes: ["Patchouli", "Vetiver", "Tonka Bean", "Incense"], gender: "Men"),
        PerfumeEntry(id: "issey-leau-dissey-women", name: "L'Eau d'Issey", brand: "Issey Miyake", concentration: "Eau de Toilette",
                     topNotes: ["Lotus", "Freesia", "Cyclamen", "Rose Water"], heartNotes: ["Peony", "Lily of the Valley", "Lily", "Carnation"], baseNotes: ["Amber", "Sandalwood", "Musk", "Cedar", "Osmanthus", "Tuberose"], gender: "Women"),

        // MAISON MARGIELA (additional)
        PerfumeEntry(id: "mm-whispers-in-the-library", name: "Whispers in the Library", brand: "Maison Margiela", concentration: "Eau de Toilette",
                     topNotes: ["Pepper", "Elemi"], heartNotes: ["Benzoin", "Vanilla"], baseNotes: ["Cedar", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "mm-lazy-sunday-morning", name: "Lazy Sunday Morning", brand: "Maison Margiela", concentration: "Eau de Toilette",
                     topNotes: ["Pear", "Lily of the Valley", "Aldehydes"], heartNotes: ["Iris", "Rose", "Orange Blossom"], baseNotes: ["Musk", "Iso E Super"], gender: "Unisex"),
        PerfumeEntry(id: "mm-coffee-break", name: "Coffee Break", brand: "Maison Margiela", concentration: "Eau de Toilette",
                     topNotes: ["Coffee", "Black Pepper"], heartNotes: ["Lavender", "Milk", "Roasted Sesame"], baseNotes: ["Sandalwood", "Vanilla", "Cedar", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "mm-sailing-day", name: "Sailing Day", brand: "Maison Margiela", concentration: "Eau de Toilette",
                     topNotes: ["Aquatic Notes", "Coriander", "Juniper Berries"], heartNotes: ["Red Seaweed", "White Cedar"], baseNotes: ["Musk", "Ambrox"], gender: "Unisex"),

        // DIPTYQUE (additional)
        PerfumeEntry(id: "diptyque-do-son", name: "Do Son", brand: "Diptyque", concentration: "Eau de Parfum",
                     topNotes: ["Orange Leaf", "Pink Pepper", "African Orange Flower"], heartNotes: ["Tuberose", "Jasmine"], baseNotes: ["Musk", "Benzoin", "Iris"], gender: "Unisex"),
        PerfumeEntry(id: "diptyque-eau-duelle", name: "Eau Duelle", brand: "Diptyque", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Elemi"], heartNotes: ["Saffron", "Juniper Berries", "Cypress"], baseNotes: ["Vanilla", "Benzoin", "Frankincense"], gender: "Unisex"),
        PerfumeEntry(id: "diptyque-eau-rose", name: "Eau Rose", brand: "Diptyque", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Litchi", "Blackcurrant"], heartNotes: ["Damascena Rose", "Centifolia Rose"], baseNotes: ["Musk", "White Cedarwood"], gender: "Unisex"),

        // ACQUA DI PARMA (additional)
        PerfumeEntry(id: "adp-colonia-essenza", name: "Colonia Essenza", brand: "Acqua di Parma", concentration: "Eau de Cologne",
                     topNotes: ["Citron", "Orange", "Bergamot", "Petit Grain", "Grapefruit"], heartNotes: ["Rose", "Jasmine", "Clove"], baseNotes: ["Patchouli", "Vetiver", "Musk", "White Musk"], gender: "Men"),
        PerfumeEntry(id: "adp-fico-di-amalfi", name: "Fico di Amalfi", brand: "Acqua di Parma", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Grapefruit", "Lemon", "Citron"], heartNotes: ["Fig", "Pink Pepper", "Jasmine"], baseNotes: ["Cedar", "Benzoin", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "adp-blu-mediterraneo-arancia", name: "Blu Mediterraneo Arancia di Capri", brand: "Acqua di Parma", concentration: "Eau de Toilette",
                     topNotes: ["Orange", "Bergamot", "Mandarin", "Grapefruit", "Lemon"], heartNotes: ["Petit Grain", "Cardamom"], baseNotes: ["Musk", "Amber", "Caramel"], gender: "Unisex"),

        // PENHALIGON'S (additional)
        PerfumeEntry(id: "penhaligons-endymion", name: "Endymion", brand: "Penhaligon's", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Bergamot", "Sage"], heartNotes: ["Geranium", "Coffee", "Incense"], baseNotes: ["Musk", "Suede", "Vanilla", "Cashmere Wood"], gender: "Men"),
        PerfumeEntry(id: "penhaligons-sartorial", name: "Sartorial", brand: "Penhaligon's", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Cyclamen", "Green Honeysuckle"], heartNotes: ["Violet Leaf", "Beeswax", "Leather"], baseNotes: ["Oak Moss", "Musk", "Sandalwood"], gender: "Men"),

        // JO MALONE (additional)
        PerfumeEntry(id: "jm-lime-basil", name: "Lime Basil & Mandarin", brand: "Jo Malone", concentration: "Eau de Cologne",
                     topNotes: ["Lime", "Mandarin", "Bergamot"], heartNotes: ["Basil", "Thyme", "Lilac"], baseNotes: ["Vetiver", "Patchouli"], gender: "Unisex"),
        PerfumeEntry(id: "jm-blackberry-bay", name: "Blackberry & Bay", brand: "Jo Malone", concentration: "Eau de Cologne",
                     topNotes: ["Blackberry", "Bay Leaf", "Grapefruit"], heartNotes: ["Plum", "Rose Hip"], baseNotes: ["Cedar", "Vetiver", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "jm-myrrh-tonka", name: "Myrrh & Tonka", brand: "Jo Malone", concentration: "Eau de Cologne Intense",
                     topNotes: ["Lavender", "Namibian Myrrh"], heartNotes: ["Omumbiri Myrrh", "Almond"], baseNotes: ["Tonka Bean", "Vanilla", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "jm-pomegranate-noir", name: "Pomegranate Noir", brand: "Jo Malone", concentration: "Eau de Cologne",
                     topNotes: ["Pomegranate", "Raspberry", "Plum"], heartNotes: ["Casablanca Lily", "Pink Pepper", "Spicy Notes"], baseNotes: ["Guaiac Wood", "Patchouli", "Frankincense", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "jm-oud-bergamot", name: "Oud & Bergamot", brand: "Jo Malone", concentration: "Eau de Cologne Intense",
                     topNotes: ["Bergamot", "Lemon", "Orange"], heartNotes: ["Oud", "Cedarwood"], baseNotes: ["Amber", "Musk", "Leather"], gender: "Unisex"),

        // MARC JACOBS (additional)
        PerfumeEntry(id: "mj-daisy-dream", name: "Daisy Dream", brand: "Marc Jacobs", concentration: "Eau de Toilette",
                     topNotes: ["Blackberry", "Grapefruit", "Pear"], heartNotes: ["Jasmine", "Wisteria", "Lychee"], baseNotes: ["Musk", "White Wood", "Coconut Water"], gender: "Women"),
        PerfumeEntry(id: "mj-perfect", name: "Perfect", brand: "Marc Jacobs", concentration: "Eau de Parfum",
                     topNotes: ["Rhubarb", "Daffodil"], heartNotes: ["Almond Milk", "Jasmine"], baseNotes: ["Cedar", "Cashmeran", "Musk"], gender: "Women"),
        PerfumeEntry(id: "mj-decadence", name: "Decadence", brand: "Marc Jacobs", concentration: "Eau de Parfum",
                     topNotes: ["Plum", "Iris", "Saffron"], heartNotes: ["Bulgarian Rose", "Jasmine", "Orris"], baseNotes: ["Vetiver", "Papyrus", "Amber", "Liquid Amber"], gender: "Women"),

        // BVLGARI (additional)
        PerfumeEntry(id: "bvlgari-aqva", name: "Aqva Pour Homme", brand: "Bvlgari", concentration: "Eau de Toilette",
                     topNotes: ["Mandarin", "Petit Grain"], heartNotes: ["Seaweed", "Cotton Flower", "Aquatic Notes"], baseNotes: ["Amber", "Musk", "Woody Notes"], gender: "Men"),
        PerfumeEntry(id: "bvlgari-wood-neroli", name: "Man Wood Neroli", brand: "Bvlgari", concentration: "Eau de Parfum",
                     topNotes: ["Neroli", "Bergamot", "Mandarin"], heartNotes: ["Cedar", "Cypress"], baseNotes: ["Musk", "Sandalwood", "Amber", "Solar Notes"], gender: "Men"),
        PerfumeEntry(id: "bvlgari-goldea", name: "Goldea", brand: "Bvlgari", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mulberry"], heartNotes: ["Egyptian Papyrus", "Orange Blossom", "Jasmine", "Ylang Ylang"], baseNotes: ["Patchouli", "Musk", "Amber", "Benzoin"], gender: "Women"),
        PerfumeEntry(id: "bvlgari-splendida-iris-dor", name: "Splendida Iris d'Or", brand: "Bvlgari", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Bergamot"], heartNotes: ["Iris", "Rose", "Mimosa"], baseNotes: ["Musk", "Benzoin", "Amber"], gender: "Women"),

        // MONTALE (additional)
        PerfumeEntry(id: "montale-black-aoud", name: "Black Aoud", brand: "Montale", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Mandarin", "Blackberry"], heartNotes: ["Oud", "Agarwood", "Patchouli"], baseNotes: ["Musk", "Black Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "montale-chocolate-greedy", name: "Chocolate Greedy", brand: "Montale", concentration: "Eau de Parfum",
                     topNotes: ["Bitter Orange", "Cocoa", "Coffee"], heartNotes: ["Dried Fruit", "Tonka Bean"], baseNotes: ["Vanilla", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "montale-roses-musk", name: "Roses Musk", brand: "Montale", concentration: "Eau de Parfum",
                     topNotes: ["Rose"], heartNotes: ["Rose", "Jasmine", "White Musk"], baseNotes: ["Amber", "Sandalwood", "Musk"], gender: "Women"),

        // MANCERA (additional)
        PerfumeEntry(id: "mancera-instant-crush", name: "Instant Crush", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Ginger", "Anise"], heartNotes: ["Rose", "Amber", "Sandalwood"], baseNotes: ["Vanilla", "Musk", "Woody Notes"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-red-tobacco", name: "Red Tobacco", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Cinnamon", "Pink Pepper"], heartNotes: ["Tobacco", "Oud", "Amber"], baseNotes: ["Vanilla", "Sandalwood", "Musk", "Patchouli"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-roses-vanille", name: "Roses Vanille", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Mandarin"], heartNotes: ["Turkish Rose", "Rose"], baseNotes: ["Vanilla", "Plum", "Amber", "Cedar", "Guaiac Wood", "White Musk"], gender: "Women"),

        // KILIAN (additional)
        PerfumeEntry(id: "kilian-good-girl-gone-bad", name: "Good Girl Gone Bad", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Osmanthus", "Jasmine"], heartNotes: ["May Rose", "Tuberose", "Narcissus"], baseNotes: ["Amber", "Cedar", "Musk", "Vanilla"], gender: "Women"),
        PerfumeEntry(id: "kilian-straight-to-heaven", name: "Straight to Heaven", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Rum", "Apple"], heartNotes: ["Davana", "Iris", "Cedar"], baseNotes: ["Patchouli", "Musk", "Vanilla", "Tonka Bean"], gender: "Men"),
        PerfumeEntry(id: "kilian-black-phantom", name: "Black Phantom", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Rum"], heartNotes: ["Dark Chocolate", "Coffee", "Caramel"], baseNotes: ["Sandalwood", "Sugar", "Vetiver", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "kilian-rolling-in-love", name: "Rolling in Love", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Almond", "Pink Pepper"], heartNotes: ["Iris", "Turkish Rose", "Ambrette"], baseNotes: ["Musk", "Amber", "Sandalwood"], gender: "Unisex"),

        // LATTAFA (additional)
        PerfumeEntry(id: "lattafa-raghba", name: "Raghba", brand: "Lattafa", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Saffron"], heartNotes: ["Rose", "Praline", "Honey"], baseNotes: ["Vanilla", "Oud", "Musk", "Benzoin", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "lattafa-asad", name: "Asad", brand: "Lattafa", concentration: "Eau de Parfum",
                     topNotes: ["Black Pepper", "Pineapple", "Bergamot"], heartNotes: ["Iris", "Dry Wood"], baseNotes: ["Amber", "Vanilla", "Benzoin", "Tobacco", "Patchouli"], gender: "Men"),
        PerfumeEntry(id: "lattafa-yara", name: "Yara", brand: "Lattafa", concentration: "Eau de Parfum",
                     topNotes: ["Orchid", "Heliotrope", "Tangerine"], heartNotes: ["Gourmand", "Tropical Fruits", "Peach"], baseNotes: ["Vanilla", "Musk", "Sandalwood"], gender: "Women"),

        // ARMAF (additional)
        PerfumeEntry(id: "armaf-milestone", name: "Milestone", brand: "Armaf", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Sea Salt", "Lemon"], heartNotes: ["Iris", "Melon"], baseNotes: ["Musk", "Sandalwood", "Ambergris"], gender: "Men"),
        PerfumeEntry(id: "armaf-tres-nuit", name: "Tres Nuit", brand: "Armaf", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Lavender", "Apple"], heartNotes: ["Birch", "Jasmine", "Rose"], baseNotes: ["Musk", "Oakmoss", "Patchouli"], gender: "Men"),

        // DAVID BECKHAM (additional)
        PerfumeEntry(id: "beckham-beyond", name: "Beyond", brand: "David Beckham", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Cardamom", "Nutmeg"], heartNotes: ["Pineapple Leaf", "Violet Leaf"], baseNotes: ["Patchouli", "Amber", "Sandalwood"], gender: "Men"),

        // CALVIN KLEIN (additional)
        PerfumeEntry(id: "ck-eternity-aqua", name: "Eternity Aqua", brand: "Calvin Klein", concentration: "Eau de Toilette",
                     topNotes: ["Cucumber", "Citrus", "Green Leaves"], heartNotes: ["Lavender", "Cedar", "White Pepper"], baseNotes: ["Sandalwood", "Musk", "Guaiac Wood", "Patchouli"], gender: "Men"),
        PerfumeEntry(id: "ck-euphoria-men", name: "Euphoria Men", brand: "Calvin Klein", concentration: "Eau de Toilette",
                     topNotes: ["Pepper", "Ginger", "Raindrop Accord"], heartNotes: ["Black Basil", "Sage", "Cedar"], baseNotes: ["Patchouli", "Amber", "Suede", "Brazilian Redwood"], gender: "Men"),
        PerfumeEntry(id: "ck-obsession", name: "Obsession", brand: "Calvin Klein", concentration: "Eau de Toilette",
                     topNotes: ["Mandarin", "Bergamot", "Lime", "Lavender"], heartNotes: ["Nutmeg", "Coriander", "Red Berries", "Sage", "Myrrh"], baseNotes: ["Sandalwood", "Amber", "Musk", "Vanilla", "Vetiver", "Patchouli"], gender: "Men"),
        PerfumeEntry(id: "ck-euphoria-women", name: "Euphoria", brand: "Calvin Klein", concentration: "Eau de Parfum",
                     topNotes: ["Pomegranate", "Persimmon", "Green Notes"], heartNotes: ["Lotus", "Orchid", "Champaca"], baseNotes: ["Mahogany", "Amber", "Musk", "Violet", "Cream"], gender: "Women"),
        PerfumeEntry(id: "ck-eternity-women", name: "Eternity", brand: "Calvin Klein", concentration: "Eau de Parfum",
                     topNotes: ["Freesia", "Mandarin", "Sage"], heartNotes: ["Lily", "Rose", "Narcissus", "White Lily", "Lily of the Valley", "Marigold", "Jasmine"], baseNotes: ["Sandalwood", "Musk", "Amber", "Patchouli", "Heliotrope"], gender: "Women"),

        // ELIZABETH ARDEN
        PerfumeEntry(id: "arden-green-tea", name: "Green Tea", brand: "Elizabeth Arden", concentration: "Eau Parfumée",
                     topNotes: ["Orange Peel", "Bergamot", "Lemon"], heartNotes: ["Green Tea", "Jasmine", "Carnation", "Fennel"], baseNotes: ["Musk", "Amber", "Oakmoss", "Celery Seeds"], gender: "Women"),
        PerfumeEntry(id: "arden-red-door", name: "Red Door", brand: "Elizabeth Arden", concentration: "Eau de Toilette",
                     topNotes: ["Red Rose", "Violet", "Orange Blossom", "Peach", "Plum"], heartNotes: ["Rose", "Jasmine", "Lily of the Valley", "Ylang Ylang", "Orchid", "Tuberose"], baseNotes: ["Honey", "Sandalwood", "Vetiver", "Amber", "Musk"], gender: "Women"),

        // ESCADA
        PerfumeEntry(id: "escada-especially", name: "Especially Escada", brand: "Escada", concentration: "Eau de Parfum",
                     topNotes: ["Pear", "Rose"], heartNotes: ["Rose", "Lily of the Valley", "Magnolia"], baseNotes: ["Musk", "Ambrox", "Sandalwood"], gender: "Women"),

        // ATELIER COLOGNE
        PerfumeEntry(id: "atelier-orange-sanguine", name: "Orange Sanguine", brand: "Atelier Cologne", concentration: "Cologne Absolue",
                     topNotes: ["Blood Orange", "Bitter Orange", "Mandarin"], heartNotes: ["Jasmine", "Geranium"], baseNotes: ["Tonka Bean", "Amber", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "atelier-cedre-atlas", name: "Cèdre Atlas", brand: "Atelier Cologne", concentration: "Cologne Absolue",
                     topNotes: ["Bergamot", "Lemon", "Green Cardamom"], heartNotes: ["Atlas Cedar", "Pink Pepper", "Papyrus"], baseNotes: ["Vetiver", "Ambergris", "Musk"], gender: "Unisex"),

        // ETAT LIBRE D'ORANGE
        PerfumeEntry(id: "elo-remarkable-people", name: "Remarkable People", brand: "Etat Libre d'Orange", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Black Pepper"], heartNotes: ["Turkish Rose", "Geranium", "Carrot Seeds"], baseNotes: ["Musk", "Sandalwood", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "elo-you-or-someone-like-you", name: "You or Someone Like You", brand: "Etat Libre d'Orange", concentration: "Eau de Parfum",
                     topNotes: ["Spearmint", "Basil"], heartNotes: ["Rose", "Lily of the Valley"], baseNotes: ["Musk", "Vetiver"], gender: "Unisex"),

        // SERGE LUTENS
        PerfumeEntry(id: "lutens-ambre-sultan", name: "Ambre Sultan", brand: "Serge Lutens", concentration: "Eau de Parfum",
                     topNotes: ["Oregano", "Bay Leaf", "Coriander", "Myrtle"], heartNotes: ["Amber", "Benzoin", "Labdanum"], baseNotes: ["Sandalwood", "Patchouli", "Vanilla", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "lutens-la-fille-de-berlin", name: "La Fille de Berlin", brand: "Serge Lutens", concentration: "Eau de Parfum",
                     topNotes: ["Rose"], heartNotes: ["Fruity Notes", "Honeyed Rose"], baseNotes: ["Incense", "Wax", "Musk"], gender: "Unisex"),

        // FREDERIC MALLE
        PerfumeEntry(id: "malle-portrait-of-a-lady", name: "Portrait of a Lady", brand: "Frédéric Malle", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Blackcurrant", "Raspberry", "Clove", "Cinnamon"], heartNotes: ["Turkish Rose", "Patchouli", "Sandalwood", "Incense"], baseNotes: ["Amber", "Musk", "Benzoin", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "malle-musc-ravageur", name: "Musc Ravageur", brand: "Frédéric Malle", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lavender"], heartNotes: ["Musk", "Amber", "Vanilla"], baseNotes: ["Sandalwood", "Cedar", "Guaiac Wood", "Tonka Bean"], gender: "Unisex"),

        // DSQUARED2
        PerfumeEntry(id: "dsquared-wood", name: "Wood", brand: "Dsquared2", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Lemon", "Cypress"], heartNotes: ["Violet Leaf", "Cedar", "Cardamom"], baseNotes: ["Vetiver", "Ambroxan", "White Musk"], gender: "Men"),

        // ZADIG & VOLTAIRE
        PerfumeEntry(id: "zv-this-is-him", name: "This is Him!", brand: "Zadig & Voltaire", concentration: "Eau de Toilette",
                     topNotes: ["Grapefruit", "Green Mandarin"], heartNotes: ["Cardamom", "Iris"], baseNotes: ["Tonka Bean", "Sandalwood", "Vanilla", "Musk"], gender: "Men"),
        PerfumeEntry(id: "zv-this-is-her", name: "This is Her!", brand: "Zadig & Voltaire", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Coffee"], heartNotes: ["Jasmine", "Rose"], baseNotes: ["Sandalwood", "Cashmere Wood", "Musk"], gender: "Women"),

        // DIESEL
        PerfumeEntry(id: "diesel-spirit-of-the-brave", name: "Spirit of the Brave", brand: "Diesel", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Grapefruit"], heartNotes: ["Fir Balsam", "Cypress", "Sage"], baseNotes: ["Labdanum", "Woody Notes", "Benzoin"], gender: "Men"),
        PerfumeEntry(id: "diesel-only-the-brave", name: "Only The Brave", brand: "Diesel", concentration: "Eau de Toilette",
                     topNotes: ["Lemon", "Mandarin", "Violet Leaf"], heartNotes: ["Rosemary", "Coriander", "Cedar"], baseNotes: ["Amber", "Leather", "Styrax"], gender: "Men"),

        // DUNHILL
        PerfumeEntry(id: "dunhill-icon", name: "Icon", brand: "Dunhill", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Neroli", "Lavender", "Black Pepper"], heartNotes: ["Cardamom", "Sage", "Rose"], baseNotes: ["Vetiver", "Oud", "Leather", "Agarwood"], gender: "Men"),

        // RASASI
        PerfumeEntry(id: "rasasi-la-yuqawam", name: "La Yuqawam", brand: "Rasasi", concentration: "Eau de Parfum",
                     topNotes: ["Raspberry", "Saffron", "Thyme"], heartNotes: ["Jasmine", "Olibanum"], baseNotes: ["Leather", "Amber", "Sandalwood", "Vanilla"], gender: "Men"),

        // AL HARAMAIN
        PerfumeEntry(id: "alharamain-amber-oud-gold", name: "Amber Oud Gold Edition", brand: "Al Haramain", concentration: "Eau de Parfum",
                     topNotes: ["Pear", "Melon"], heartNotes: ["Rose", "Freesia"], baseNotes: ["Musk", "Patchouli", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "alharamain-lailati", name: "L'Aventure", brand: "Al Haramain", concentration: "Eau de Parfum",
                     topNotes: ["Pineapple", "Bergamot", "Black Currant", "Apple"], heartNotes: ["Birch", "Jasmine", "Rose"], baseNotes: ["Musk", "Oak Moss", "Ambergris", "Patchouli", "Vanilla"], gender: "Men"),

        // SWISS ARABIAN
        PerfumeEntry(id: "swiss-arabian-shaghaf-oud", name: "Shaghaf Oud", brand: "Swiss Arabian", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Cardamom"], heartNotes: ["Rose", "Oud", "Geranium"], baseNotes: ["Musk", "Sandalwood", "Amber", "Vanilla"], gender: "Unisex"),

        // NAUTICA
        PerfumeEntry(id: "nautica-voyage", name: "Voyage", brand: "Nautica", concentration: "Eau de Toilette",
                     topNotes: ["Green Leaf", "Apple"], heartNotes: ["Mimosa", "Lotus", "Aquatic Notes"], baseNotes: ["Cedar", "Musk", "Amber", "Moss"], gender: "Men"),

        // DOLCE & GABBANA (additional women's)
        PerfumeEntry(id: "dg-the-only-one", name: "The Only One", brand: "Dolce & Gabbana", concentration: "Eau de Parfum",
                     topNotes: ["Violet", "Bergamot", "Grapefruit"], heartNotes: ["Coffee", "Iris", "Rose"], baseNotes: ["Patchouli", "Vanilla", "Vetiver", "Cedar"], gender: "Women"),

        // COMMODITY
        PerfumeEntry(id: "commodity-gold", name: "Gold", brand: "Commodity", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Cardamom"], heartNotes: ["Jasmine", "Neroli", "Orris"], baseNotes: ["Amber", "Musk", "Sandalwood", "Cashmeran"], gender: "Unisex"),

        // D.S. & DURGA
        PerfumeEntry(id: "ds-durga-debaser", name: "Debaser", brand: "D.S. & Durga", concentration: "Eau de Parfum",
                     topNotes: ["Fig", "Bergamot", "Lemon"], heartNotes: ["Coconut", "Iris"], baseNotes: ["Blonde Woods", "Musk", "Amber"], gender: "Unisex"),

        // IMAGINARY AUTHORS
        PerfumeEntry(id: "ia-saint-julep", name: "Saint Julep", brand: "Imaginary Authors", concentration: "Eau de Parfum",
                     topNotes: ["Spearmint", "Southern Magnolia"], heartNotes: ["Julep", "Lemon"], baseNotes: ["Virginia Cedar", "Skin Musk", "Vanilla"], gender: "Unisex"),

        // PACO RABANNE
        PerfumeEntry(id: "paco-1million", name: "1 Million", brand: "Paco Rabanne", concentration: "Eau de Toilette",
                     topNotes: ["Grapefruit", "Mint", "Blood Mandarin"], heartNotes: ["Rose", "Cinnamon"], baseNotes: ["Leather", "Amber", "Woody Notes"], gender: "Men"),
        PerfumeEntry(id: "paco-1million-parfum", name: "1 Million Parfum", brand: "Paco Rabanne", concentration: "Parfum",
                     topNotes: ["Mandarin"], heartNotes: ["Tuberose", "Solar Notes"], baseNotes: ["Gold Myrrh", "Amber", "Cashmeran"], gender: "Men"),
        PerfumeEntry(id: "paco-invictus", name: "Invictus", brand: "Paco Rabanne", concentration: "Eau de Toilette",
                     topNotes: ["Grapefruit", "Marine Accord", "Mandarin"], heartNotes: ["Bay Leaf", "Jasmine"], baseNotes: ["Guaiac Wood", "Patchouli", "Oak Moss", "Ambergris"], gender: "Men"),
        PerfumeEntry(id: "paco-invictus-legend", name: "Invictus Legend", brand: "Paco Rabanne", concentration: "Eau de Parfum",
                     topNotes: ["Sea Salt", "Grapefruit", "Laurel Leaf"], heartNotes: ["Geranium", "Red Pepper"], baseNotes: ["Amber", "Guaiac Wood", "Benzoin", "Sandalwood"], gender: "Men"),
        PerfumeEntry(id: "paco-phantom", name: "Phantom", brand: "Paco Rabanne", concentration: "Eau de Toilette",
                     topNotes: ["Lemon", "Lavender"], heartNotes: ["Apple", "Smoke"], baseNotes: ["Vanilla", "Vetiver", "Styrax", "Cashmeran"], gender: "Men"),
        PerfumeEntry(id: "paco-olympea", name: "Olympéa", brand: "Paco Rabanne", concentration: "Eau de Parfum",
                     topNotes: ["Green Mandarin", "Aquatic Accord", "Pink Pepper"], heartNotes: ["Jasmine", "Lily of the Valley"], baseNotes: ["Cashmere Wood", "Amber", "Vanilla", "Salt"], gender: "Women"),
        PerfumeEntry(id: "paco-lady-million", name: "Lady Million", brand: "Paco Rabanne", concentration: "Eau de Parfum",
                     topNotes: ["Amalfi Lemon", "Raspberry"], heartNotes: ["Arabian Jasmine", "African Orange Flower", "Gardenia"], baseNotes: ["Patchouli", "Honey", "Amber"], gender: "Women"),

        // BENTLEY
        PerfumeEntry(id: "bentley-for-men-intense", name: "For Men Intense", brand: "Bentley", concentration: "Eau de Parfum",
                     topNotes: ["Black Pepper", "Bay Leaf", "Bergamot"], heartNotes: ["Rum", "Clary Sage", "Cinnamon", "Leather"], baseNotes: ["Patchouli", "Cedar", "Incense", "Sandalwood", "Musk"], gender: "Men"),

        // JOHN VARVATOS
        PerfumeEntry(id: "varvatos-artisan", name: "Artisan", brand: "John Varvatos", concentration: "Eau de Toilette",
                     topNotes: ["Orange", "Tangerine", "Thyme", "Marjoram"], heartNotes: ["Lavender", "Jasmine", "Orange Blossom", "Ginger"], baseNotes: ["Woody Notes", "Musk", "Amber"], gender: "Men"),
        PerfumeEntry(id: "varvatos-dark-rebel", name: "Dark Rebel", brand: "John Varvatos", concentration: "Eau de Toilette",
                     topNotes: ["Rum", "Clary Sage"], heartNotes: ["Saffron", "Java Vetiver", "Dried Lavender"], baseNotes: ["Mexican Vanilla", "Tonka Bean", "Leather", "Styrax"], gender: "Men"),

        // TIZIANA TERENZI
        PerfumeEntry(id: "tt-kirke", name: "Kirke", brand: "Tiziana Terenzi", concentration: "Extrait de Parfum",
                     topNotes: ["Passion Fruit", "Peach", "Raspberry"], heartNotes: ["Rose", "Jasmine", "Lily of the Valley"], baseNotes: ["Musk", "Vanilla", "Amber", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "tt-andromeda", name: "Andromeda", brand: "Tiziana Terenzi", concentration: "Extrait de Parfum",
                     topNotes: ["Mandarin", "Bergamot", "Lavender"], heartNotes: ["Iris", "Jasmine", "Rose"], baseNotes: ["Vanilla", "Amber", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "tt-cassiopea", name: "Cassiopea", brand: "Tiziana Terenzi", concentration: "Extrait de Parfum",
                     topNotes: ["Blackberry", "Raspberry", "Bergamot"], heartNotes: ["Jasmine", "Heliotrope", "Orange Blossom"], baseNotes: ["Vanilla", "Musk", "Amber", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "tt-orion", name: "Orion", brand: "Tiziana Terenzi", concentration: "Extrait de Parfum",
                     topNotes: ["Artemisia", "Bergamot", "Mandarin"], heartNotes: ["Iris", "Cedar", "Violet"], baseNotes: ["Amber", "Musk", "Vetiver", "Tonka Bean"], gender: "Unisex"),

        // ROJA PARFUMS
        PerfumeEntry(id: "roja-elysium", name: "Elysium", brand: "Roja Parfums", concentration: "Parfum Cologne",
                     topNotes: ["Bergamot", "Grapefruit", "Lemon", "Lime", "Pink Pepper"], heartNotes: ["Jasmine", "Rose", "Lily of the Valley", "Geranium"], baseNotes: ["Vetiver", "Cedar", "Sandalwood", "Musk", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "roja-enigma", name: "Enigma", brand: "Roja Parfums", concentration: "Parfum",
                     topNotes: ["Bergamot", "Lemon", "Mandarin"], heartNotes: ["Jasmine", "Rose", "Orris"], baseNotes: ["Oud", "Sandalwood", "Amber", "Musk", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "roja-scandal", name: "Scandal", brand: "Roja Parfums", concentration: "Parfum",
                     topNotes: ["Bergamot", "Orange", "Lemon"], heartNotes: ["Jasmine", "Rose", "Tuberose"], baseNotes: ["Tonka Bean", "Vanilla", "Musk", "Sandalwood", "Benzoin"], gender: "Women"),
        PerfumeEntry(id: "roja-musk-aoud", name: "Musk Aoud", brand: "Roja Parfums", concentration: "Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Rose", "Oud", "Saffron"], baseNotes: ["Musk", "Sandalwood", "Amber", "Vanilla"], gender: "Unisex"),

        // CLIVE CHRISTIAN
        PerfumeEntry(id: "cc-no1-men", name: "No. 1", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Lime", "Bergamot", "Thyme", "Mandarin"], heartNotes: ["Orris", "Jasmine", "Rose", "Heliotrope", "Carnation"], baseNotes: ["Cedar", "Sandalwood", "Vetiver", "Vanilla", "Musk"], gender: "Men"),
        PerfumeEntry(id: "cc-x-men", name: "X", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Bergamot", "Green Apple", "Cardamom", "Juniper"], heartNotes: ["Orris", "Jasmine", "Rose", "Carnation"], baseNotes: ["Sandalwood", "Vanilla", "Cedar", "Musk", "Amber"], gender: "Men"),
        PerfumeEntry(id: "cc-l-women", name: "L", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Bergamot", "Grapefruit", "Pink Pepper"], heartNotes: ["Rose", "Jasmine", "Orange Blossom"], baseNotes: ["Sandalwood", "Musk", "Amber", "Vanilla"], gender: "Women"),

        // BOND NO. 9
        PerfumeEntry(id: "bond9-scent-of-peace", name: "Scent of Peace", brand: "Bond No. 9", concentration: "Eau de Parfum",
                     topNotes: ["Grapefruit", "Juniper", "Blackcurrant"], heartNotes: ["Cedar", "Lily of the Valley", "Hawthorn"], baseNotes: ["Musk", "Vetiver", "Oak Moss"], gender: "Men"),
        PerfumeEntry(id: "bond9-bleecker-street", name: "Bleecker Street", brand: "Bond No. 9", concentration: "Eau de Parfum",
                     topNotes: ["Violet Leaf", "Cassis"], heartNotes: ["Rose", "Jasmine", "Geranium"], baseNotes: ["Musk", "Amber", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "bond9-governors-island", name: "Governor's Island", brand: "Bond No. 9", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Ginger", "Sea Salt"], heartNotes: ["Jasmine", "Cedar", "Aquatic Notes"], baseNotes: ["Driftwood", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "bond9-nuits-de-noho", name: "Nuits de Noho", brand: "Bond No. 9", concentration: "Eau de Parfum",
                     topNotes: ["Moroccan Rose", "Lily"], heartNotes: ["Jasmine", "Gardenia", "Amber"], baseNotes: ["Musk", "Vanilla", "Sandalwood"], gender: "Women"),

        // NASOMATTO
        PerfumeEntry(id: "nasomatto-black-afgano", name: "Black Afgano", brand: "Nasomatto", concentration: "Extrait de Parfum",
                     topNotes: ["Cannabis", "Coffee"], heartNotes: ["Oud", "Tobacco", "Incense"], baseNotes: ["Resin", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "nasomatto-pardon", name: "Pardon", brand: "Nasomatto", concentration: "Extrait de Parfum",
                     topNotes: ["Chocolate"], heartNotes: ["Oud", "Sandalwood"], baseNotes: ["Amber", "Musk", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "nasomatto-narcotic-venus", name: "Narcotic Venus", brand: "Nasomatto", concentration: "Extrait de Parfum",
                     topNotes: ["Floral Notes"], heartNotes: ["Tuberose", "Woody Notes"], baseNotes: ["Amber", "Musk"], gender: "Women"),
        PerfumeEntry(id: "nasomatto-baraonda", name: "Baraonda", brand: "Nasomatto", concentration: "Extrait de Parfum",
                     topNotes: ["Whiskey"], heartNotes: ["Oud", "Cedar"], baseNotes: ["Vanilla", "Amber", "Musk"], gender: "Unisex"),

        // ORTO PARISI
        PerfumeEntry(id: "ortoparisi-terroni", name: "Terroni", brand: "Orto Parisi", concentration: "Parfum",
                     topNotes: ["Earth", "Beeswax"], heartNotes: ["Orris", "Sandalwood"], baseNotes: ["Vetiver", "Clay", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "ortoparisi-megamare", name: "Megamare", brand: "Orto Parisi", concentration: "Parfum",
                     topNotes: ["Sea Notes", "Aquatic Notes"], heartNotes: ["Seaweed", "Musk"], baseNotes: ["Amber", "Driftwood", "Salt"], gender: "Unisex"),
        PerfumeEntry(id: "ortoparisi-stercus", name: "Stercus", brand: "Orto Parisi", concentration: "Parfum",
                     topNotes: ["Saffron"], heartNotes: ["Oud", "Castoreum"], baseNotes: ["Civet", "Musk", "Vanilla", "Sandalwood"], gender: "Unisex"),

        // ZOOLOGIST
        PerfumeEntry(id: "zoologist-bat", name: "Bat", brand: "Zoologist", concentration: "Eau de Parfum",
                     topNotes: ["Fig", "Green Banana", "Tropical Fruits"], heartNotes: ["Stone Fruit", "Moist Cave", "Minerals"], baseNotes: ["Guano", "Musk", "Vetiver", "Earth"], gender: "Unisex"),
        PerfumeEntry(id: "zoologist-tyrannosaurus-rex", name: "Tyrannosaurus Rex", brand: "Zoologist", concentration: "Eau de Parfum",
                     topNotes: ["Black Pepper", "Saffron", "Ginger"], heartNotes: ["Oud", "Rose", "Osmanthus"], baseNotes: ["Leather", "Amber", "Smoke", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "zoologist-hummingbird", name: "Hummingbird", brand: "Zoologist", concentration: "Eau de Parfum",
                     topNotes: ["Orange Blossom", "Frangipani"], heartNotes: ["Tuberose", "Jasmine", "Ylang Ylang"], baseNotes: ["Vanilla", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "zoologist-elephant", name: "Elephant", brand: "Zoologist", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Pink Pepper", "Elemi"], heartNotes: ["Frangipani", "Champaca", "Cacao"], baseNotes: ["Patchouli", "Myrrh", "Musk", "Amber"], gender: "Unisex"),

        // MEMO PARIS
        PerfumeEntry(id: "memo-african-leather", name: "African Leather", brand: "Memo Paris", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Cardamom", "Geranium"], heartNotes: ["Saffron", "Oud", "Leather"], baseNotes: ["Musk", "Vetiver", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "memo-russian-leather", name: "Russian Leather", brand: "Memo Paris", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Thyme", "Pink Pepper"], heartNotes: ["Birch", "Leather", "Heliotrope"], baseNotes: ["Styrax", "Amber", "Musk", "Tonka Bean"], gender: "Unisex"),
        PerfumeEntry(id: "memo-marfa", name: "Marfa", brand: "Memo Paris", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Sichuan Pepper", "Cassis"], heartNotes: ["Rose", "Peony", "Orris"], baseNotes: ["Leather", "Sandalwood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "memo-sintra", name: "Sintra", brand: "Memo Paris", concentration: "Eau de Parfum",
                     topNotes: ["Fig", "Bergamot"], heartNotes: ["Jasmine", "Rose", "Pine"], baseNotes: ["Cedar", "Musk", "Amber", "Vanilla"], gender: "Unisex"),

        // EX NIHILO
        PerfumeEntry(id: "exnihilo-fleur-narcotique", name: "Fleur Narcotique", brand: "Ex Nihilo", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lychee", "Pink Pepper"], heartNotes: ["Peony", "Orange Blossom", "Jasmine"], baseNotes: ["Musk", "Moss", "Cashmere Wood"], gender: "Unisex"),
        PerfumeEntry(id: "exnihilo-bois-dargent", name: "Bois d'Argent", brand: "Ex Nihilo", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Black Pepper"], heartNotes: ["Iris", "Rose", "Incense"], baseNotes: ["Oud", "Sandalwood", "Amber", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "exnihilo-musc-infini", name: "Musc Infini", brand: "Ex Nihilo", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Cardamom"], heartNotes: ["Iris", "Musk", "Cashmeran"], baseNotes: ["Sandalwood", "Amber", "Cedar"], gender: "Unisex"),

        // BDK PARFUMS
        PerfumeEntry(id: "bdk-gris-charnel", name: "Gris Charnel", brand: "BDK Parfums", concentration: "Eau de Parfum",
                     topNotes: ["Fig", "Cardamom", "Pink Pepper"], heartNotes: ["Iris", "Vetiver", "Jasmine"], baseNotes: ["Sandalwood", "Tonka Bean", "Vanilla", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "bdk-rouge-smoking", name: "Rouge Smoking", brand: "BDK Parfums", concentration: "Eau de Parfum",
                     topNotes: ["Cinnamon", "Saffron", "Pink Pepper"], heartNotes: ["Rose", "Iris"], baseNotes: ["Vanilla", "Benzoin", "Tonka Bean", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "bdk-pas-ce-soir", name: "Pas ce Soir", brand: "BDK Parfums", concentration: "Extrait de Parfum",
                     topNotes: ["Raspberry", "Bergamot"], heartNotes: ["Jasmine", "Tuberose", "Orange Blossom"], baseNotes: ["Vanilla", "Sandalwood", "Musk", "Benzoin"], gender: "Women"),

        // CARNER BARCELONA
        PerfumeEntry(id: "carner-tardes", name: "Tardes", brand: "Carner Barcelona", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Rose", "Violet Leaf"], heartNotes: ["Jasmine", "Plum", "Orris"], baseNotes: ["Vanilla", "Sandalwood", "Musk", "Amber"], gender: "Women"),
        PerfumeEntry(id: "carner-el-born", name: "El Born", brand: "Carner Barcelona", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Orange Blossom", "Lime"], heartNotes: ["Jasmine", "Neroli", "Rose"], baseNotes: ["Sandalwood", "Musk", "Vanilla", "Amber"], gender: "Unisex"),

        // FLORIS LONDON
        PerfumeEntry(id: "floris-honey-oud", name: "Honey Oud", brand: "Floris London", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin"], heartNotes: ["Rose", "Honey", "Oud"], baseNotes: ["Sandalwood", "Musk", "Vanilla", "Benzoin"], gender: "Unisex"),
        PerfumeEntry(id: "floris-no89", name: "No. 89", brand: "Floris London", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Lavender", "Neroli", "Orange"], heartNotes: ["Rose", "Geranium", "Nutmeg"], baseNotes: ["Sandalwood", "Vetiver", "Musk", "Oak Moss"], gender: "Men"),
        PerfumeEntry(id: "floris-cherry-blossom", name: "Cherry Blossom", brand: "Floris London", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Cherry Blossom"], heartNotes: ["Rose", "Mimosa", "Heliotrope"], baseNotes: ["Musk", "Sandalwood", "Vanilla"], gender: "Women"),

        // PROFUMUM ROMA
        PerfumeEntry(id: "profumum-acqua-viva", name: "Acqua Viva", brand: "Profumum Roma", concentration: "Parfum",
                     topNotes: ["Bergamot", "Lemon", "Orange"], heartNotes: ["Rose", "Geranium", "Jasmine"], baseNotes: ["Musk", "Amber", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "profumum-ambra-aurea", name: "Ambra Aurea", brand: "Profumum Roma", concentration: "Parfum",
                     topNotes: ["Amber"], heartNotes: ["Benzoin", "Labdanum"], baseNotes: ["Vanilla", "Musk", "Sandalwood"], gender: "Unisex"),

        // ORMONDE JAYNE
        PerfumeEntry(id: "ormonde-woman", name: "Ormonde Woman", brand: "Ormonde Jayne", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Coriander"], heartNotes: ["Jasmine", "Violet", "Hemlock"], baseNotes: ["Vetiver", "Sandalwood", "Cedar", "Amber"], gender: "Women"),
        PerfumeEntry(id: "ormonde-man", name: "Ormonde Man", brand: "Ormonde Jayne", concentration: "Eau de Parfum",
                     topNotes: ["Juniper Berry", "Bergamot", "Pink Pepper"], heartNotes: ["Hemlock", "Violet Leaf", "Grass"], baseNotes: ["Vetiver", "Cedar", "Amber", "Musk"], gender: "Men"),

        // VILHELM PARFUMERIE
        PerfumeEntry(id: "vilhelm-dear-polly", name: "Dear Polly", brand: "Vilhelm Parfumerie", concentration: "Eau de Parfum",
                     topNotes: ["Green Tea", "Apple", "Bergamot"], heartNotes: ["Bamboo", "Peony", "Jasmine"], baseNotes: ["Musk", "Cedar", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "vilhelm-mango-skin", name: "Mango Skin", brand: "Vilhelm Parfumerie", concentration: "Eau de Parfum",
                     topNotes: ["Mango", "Bergamot"], heartNotes: ["Ylang Ylang", "Jasmine"], baseNotes: ["Sandalwood", "Musk", "Vanilla"], gender: "Unisex"),

        // GOLDFIELD & BANKS
        PerfumeEntry(id: "gfb-pacific-rock-moss", name: "Pacific Rock Moss", brand: "Goldfield & Banks", concentration: "Eau de Parfum",
                     topNotes: ["Lime", "Bergamot", "Mandarin"], heartNotes: ["Rock Moss", "Sage", "Vetiver"], baseNotes: ["Amber", "Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "gfb-bohemian-lime", name: "Bohemian Lime", brand: "Goldfield & Banks", concentration: "Eau de Parfum",
                     topNotes: ["Lime", "Bergamot", "Ginger"], heartNotes: ["Jasmine", "Vetiver"], baseNotes: ["Sandalwood", "Musk", "Amber"], gender: "Unisex"),

        // HOUSE OF OUD
        PerfumeEntry(id: "hoo-just-before", name: "Just Before", brand: "House of Oud", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Saffron"], heartNotes: ["Rose", "Oud", "Jasmine"], baseNotes: ["Sandalwood", "Musk", "Vanilla", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "hoo-breath-of-the-infinite", name: "Breath of the Infinite", brand: "House of Oud", concentration: "Eau de Parfum",
                     topNotes: ["Apple", "Bergamot"], heartNotes: ["Oud", "Cedar", "Violet"], baseNotes: ["Musk", "Vanilla", "Amber", "Leather"], gender: "Unisex"),

        // NICOLAÏ
        PerfumeEntry(id: "nicolai-new-york-intense", name: "New York Intense", brand: "Nicolaï", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Cardamom"], heartNotes: ["Rose", "Oud", "Incense"], baseNotes: ["Amber", "Leather", "Musk", "Patchouli"], gender: "Unisex"),
        PerfumeEntry(id: "nicolai-number-one", name: "Number One", brand: "Nicolaï", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon"], heartNotes: ["Rose", "Jasmine", "Ylang Ylang"], baseNotes: ["Sandalwood", "Vanilla", "Musk", "Amber"], gender: "Unisex"),

        // PARFUM D'EMPIRE
        PerfumeEntry(id: "pde-osmanthus-interdite", name: "Osmanthus Interdite", brand: "Parfum d'Empire", concentration: "Eau de Parfum",
                     topNotes: ["Osmanthus", "Peach", "Apricot"], heartNotes: ["Leather", "Jasmine", "Suede"], baseNotes: ["Musk", "Sandalwood", "Opoponax"], gender: "Unisex"),
        PerfumeEntry(id: "pde-corsica-furiosa", name: "Corsica Furiosa", brand: "Parfum d'Empire", concentration: "Eau de Parfum",
                     topNotes: ["Myrtle", "Lemon", "Bergamot"], heartNotes: ["Immortelle", "Labdanum", "Cistus"], baseNotes: ["Amber", "Musk", "Cedar"], gender: "Unisex"),

        // GALLIVANT
        PerfumeEntry(id: "gallivant-tokyo", name: "Tokyo", brand: "Gallivant", concentration: "Eau de Parfum",
                     topNotes: ["Hinoki", "Bergamot", "Yuzu"], heartNotes: ["Green Tea", "Jasmine", "Lily"], baseNotes: ["Sandalwood", "Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "gallivant-istanbul", name: "Istanbul", brand: "Gallivant", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Rose", "Pink Pepper"], heartNotes: ["Turkish Rose", "Oud", "Incense"], baseNotes: ["Amber", "Musk", "Leather", "Tonka Bean"], gender: "Unisex"),

        // MAISON CRIVELLI
        PerfumeEntry(id: "crivelli-iris-malikhân", name: "Iris Malikhân", brand: "Maison Crivelli", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Iris", "Violet", "Suede"], baseNotes: ["Sandalwood", "Musk", "Amber", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "crivelli-oud-maracuja", name: "Oud Maracujá", brand: "Maison Crivelli", concentration: "Eau de Parfum",
                     topNotes: ["Passion Fruit", "Bergamot"], heartNotes: ["Oud", "Saffron", "Rose"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla"], gender: "Unisex"),

        // TAUER PERFUMES
        PerfumeEntry(id: "tauer-laddm", name: "L'Air du Désert Marocain", brand: "Tauer Perfumes", concentration: "Eau de Toilette",
                     topNotes: ["Petitgrain", "Linen"], heartNotes: ["Incense", "Amber", "Dried Fruit"], baseNotes: ["Vetiver", "Cedar", "Sandalwood", "Musk", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "tauer-phtaloblue", name: "Au Coeur du Désert", brand: "Tauer Perfumes", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Petitgrain"], heartNotes: ["Incense", "Amber", "Ciste"], baseNotes: ["Vanilla", "Teak Wood", "Cedar", "Musk"], gender: "Unisex"),

        // AERIN
        PerfumeEntry(id: "aerin-amber-musk", name: "Amber Musk", brand: "Aerin", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Coconut"], heartNotes: ["Musk", "Amber", "Benzoin"], baseNotes: ["Sandalwood", "Vanilla", "Tonka Bean"], gender: "Women"),
        PerfumeEntry(id: "aerin-cedar-violet", name: "Cedar Violet", brand: "Aerin", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin"], heartNotes: ["Violet", "Iris", "Rose"], baseNotes: ["Cedar", "Musk", "Sandalwood"], gender: "Women"),

        // 19-69
        PerfumeEntry(id: "1969-chinese-tobacco", name: "Chinese Tobacco", brand: "19-69", concentration: "Eau de Parfum",
                     topNotes: ["Coriander", "Black Pepper", "Elemi"], heartNotes: ["Tobacco", "Leather", "Geranium"], baseNotes: ["Patchouli", "Sandalwood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "1969-kasbah", name: "Kasbah", brand: "19-69", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Bergamot", "Cinnamon"], heartNotes: ["Rose", "Saffron", "Oud"], baseNotes: ["Musk", "Amber", "Sandalwood", "Cedar"], gender: "Unisex"),

        // LABORATORIO OLFATTIVO
        PerfumeEntry(id: "labolf-nerotic", name: "Nerotic", brand: "Laboratorio Olfattivo", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Neroli", "Petit Grain"], heartNotes: ["Orange Blossom", "Jasmine"], baseNotes: ["Musk", "Amber", "Cedarwood"], gender: "Unisex"),
        PerfumeEntry(id: "labolf-kashnoir", name: "Kashnoir", brand: "Laboratorio Olfattivo", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Cardamom"], heartNotes: ["Rose", "Oud", "Incense"], baseNotes: ["Musk", "Amber", "Vanilla", "Leather"], gender: "Unisex"),

        // AMOUAGE (additional niche)
        PerfumeEntry(id: "amouage-epic-man", name: "Epic Man", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Cumin", "Pink Pepper", "Nutmeg"], heartNotes: ["Rose", "Myrrh", "Orris", "Geranium"], baseNotes: ["Oud", "Frankincense", "Sandalwood", "Musk", "Leather"], gender: "Men"),
        PerfumeEntry(id: "amouage-lyric-woman", name: "Lyric Woman", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Mandarin"], heartNotes: ["Jasmine", "Lily", "Ylang Ylang", "Orris"], baseNotes: ["Sandalwood", "Musk", "Vanilla", "Amber"], gender: "Women"),
        PerfumeEntry(id: "amouage-journey-man", name: "Journey Man", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Cardamom", "Pink Pepper"], heartNotes: ["Juniper", "Olibanum", "Tobacco"], baseNotes: ["Leather", "Oud", "Sandalwood", "Musk"], gender: "Men"),

        // XERJOFF (additional niche)
        PerfumeEntry(id: "xerjoff-40-knots", name: "40 Knots", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Sea Salt", "Bergamot", "Lemon"], heartNotes: ["Lavender", "Jasmine", "Geranium"], baseNotes: ["Musk", "Amber", "Cedar", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "xerjoff-ivory-route", name: "Ivory Route", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Bergamot"], heartNotes: ["Rose", "Jasmine", "Oud"], baseNotes: ["Vanilla", "Sandalwood", "Musk", "Amber", "Benzoin"], gender: "Unisex"),
        PerfumeEntry(id: "xerjoff-richwood", name: "Richwood", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Orange"], heartNotes: ["Rose", "Sandalwood", "Papyrus"], baseNotes: ["Amber", "Musk", "Cedar", "Vanilla"], gender: "Unisex"),

        // NISHANE (additional niche)
        PerfumeEntry(id: "nishane-sultan-vetiver", name: "Sultan Vetiver", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Lavender", "Mandarin"], heartNotes: ["Vetiver", "Geranium", "Violet Leaf"], baseNotes: ["Amber", "Musk", "Sandalwood", "Tonka Bean"], gender: "Unisex"),
        PerfumeEntry(id: "nishane-ege", name: "Ege / Αιγαίο", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Green Notes"], heartNotes: ["Fig", "Jasmine", "Lentisk"], baseNotes: ["Cedar", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "nishane-hundred-silent-ways-edp", name: "Tempfluo", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Iris", "Bergamot", "Violet"], heartNotes: ["Jasmine", "Ambrette", "Suede"], baseNotes: ["Sandalwood", "Musk", "Vanilla", "Cedar"], gender: "Unisex"),

        // INITIO (additional niche)
        PerfumeEntry(id: "initio-blessed-baraka", name: "Blessed Baraka", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Ginger"], heartNotes: ["Oud", "Orris", "Benzoin"], baseNotes: ["Sandalwood", "Vanilla", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "initio-mystic-experience", name: "Mystic Experience", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Bergamot"], heartNotes: ["Incense", "Frankincense", "Myrrh"], baseNotes: ["Sandalwood", "Vanilla", "Musk", "Amber"], gender: "Unisex"),

        // PARFUMS DE MARLY (additional niche)
        PerfumeEntry(id: "pdm-habdan", name: "Habdan", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Cinnamon", "Apple"], heartNotes: ["Rose", "Jasmine", "Saffron"], baseNotes: ["Vanilla", "Amber", "Oud", "Sandalwood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "pdm-oajan", name: "Oajan", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Cinnamon", "Honey", "Clove"], heartNotes: ["Benzoin", "Rose", "Cardamom"], baseNotes: ["Vanilla", "Amber", "Tonka Bean", "Sandalwood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "pdm-kalan", name: "Kalan", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Orange", "Bergamot", "Grapefruit"], heartNotes: ["Geranium", "Lavender", "Cardamom", "Nutmeg"], baseNotes: ["Vanilla", "Tonka Bean", "Amber", "Sandalwood", "Musk"], gender: "Men"),

        // BYREDO (additional niche)
        PerfumeEntry(id: "byredo-oud-immortel", name: "Oud Immortel", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Limoncello", "Cardamom"], heartNotes: ["Incense", "Papyrus", "Oud"], baseNotes: ["Patchouli", "Rosewood", "Tobacco", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "byredo-mixed-emotions", name: "Mixed Emotions", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Cassis", "Maté"], heartNotes: ["Violet", "Papyrus"], baseNotes: ["Birch", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "byredo-slow-dance", name: "Slow Dance", brand: "Byredo", concentration: "Eau de Parfum",
                     topNotes: ["Opoponax", "Cognac"], heartNotes: ["Geranium", "Violet", "Labdanum"], baseNotes: ["Patchouli", "Vanilla", "Musk"], gender: "Unisex"),

        // LE LABO (additional niche)
        PerfumeEntry(id: "lelabo-jasmin-17", name: "Jasmin 17", brand: "Le Labo", concentration: "Eau de Parfum",
                     topNotes: ["Jasmine", "Bergamot"], heartNotes: ["Tuberose", "Orange Blossom"], baseNotes: ["Musk", "Cashmeran", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "lelabo-lys-41", name: "Lys 41", brand: "Le Labo", concentration: "Eau de Parfum",
                     topNotes: ["Lily", "Bergamot", "Lemon"], heartNotes: ["Tuberose", "Jasmine", "Iris"], baseNotes: ["Amber", "Musk", "Vanilla", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "lelabo-noir-29", name: "Noir 29", brand: "Le Labo", concentration: "Eau de Parfum",
                     topNotes: ["Fig", "Bergamot", "Bay Leaf"], heartNotes: ["Cedar", "Vetiver", "Musk"], baseNotes: ["Patchouli", "Styrax", "Castoreum", "Leather"], gender: "Unisex"),

        // MFK (additional niche)
        PerfumeEntry(id: "mfk-oud-extrait", name: "Oud Extrait", brand: "Maison Francis Kurkdjian", concentration: "Extrait de Parfum",
                     topNotes: ["Saffron"], heartNotes: ["Oud", "Rose", "Cedar"], baseNotes: ["Musk", "Amber", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "mfk-gentle-fluidity-silver", name: "Gentle Fluidity Silver", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum",
                     topNotes: ["Juniper Berries", "Coriander"], heartNotes: ["Nutmeg", "Musk"], baseNotes: ["Amber", "Sandalwood", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "mfk-724", name: "724", brand: "Maison Francis Kurkdjian", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Green Notes"], heartNotes: ["Sandalwood", "Jasmine", "Peony"], baseNotes: ["Musk", "Fir Balsam", "Amber"], gender: "Unisex"),

        // KILIAN (additional niche)
        PerfumeEntry(id: "kilian-intoxicated", name: "Intoxicated", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Nutmeg", "Cinnamon"], heartNotes: ["Turkish Rose", "Coffee", "Mocha"], baseNotes: ["Oud", "Sandalwood", "Vanilla", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "kilian-moonlight-in-heaven", name: "Moonlight in Heaven", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Mango", "Pink Grapefruit", "Bergamot"], heartNotes: ["Rice", "Coconut Milk", "Tiare Flower"], baseNotes: ["Vetiver", "Musk", "Tonka Bean"], gender: "Unisex"),

        // D.S. & DURGA (additional)
        PerfumeEntry(id: "ds-durga-burning-barbershop", name: "Burning Barbershop", brand: "D.S. & Durga", concentration: "Eau de Parfum",
                     topNotes: ["Spearmint", "Lavender", "Hemp"], heartNotes: ["Elemi", "Fir Balsam", "Smoke"], baseNotes: ["Vanilla", "Cedar", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "ds-durga-bowmakers", name: "Bowmakers", brand: "D.S. & Durga", concentration: "Eau de Parfum",
                     topNotes: ["Violin Varnish"], heartNotes: ["Mahogany", "Maple Syrup"], baseNotes: ["Cedar", "Amber", "Musk"], gender: "Unisex"),

        // IMAGINARY AUTHORS (additional)
        PerfumeEntry(id: "ia-every-storm-a-serenade", name: "Every Storm a Serenade", brand: "Imaginary Authors", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Green Notes", "Salt"], heartNotes: ["Seaweed", "Wood", "Orris"], baseNotes: ["White Amber", "Musk", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "ia-telegrama", name: "Telegrama", brand: "Imaginary Authors", concentration: "Eau de Parfum",
                     topNotes: ["Petitgrain", "Black Pepper"], heartNotes: ["Egyptian Violet", "Leather"], baseNotes: ["Saffron", "Amber", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "ia-falling-into-the-sea", name: "Falling Into the Sea", brand: "Imaginary Authors", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Bergamot", "Plum"], heartNotes: ["Orris", "Saffron"], baseNotes: ["Amber", "Cedar", "Musk"], gender: "Unisex"),

        // SERGE LUTENS (additional)
        PerfumeEntry(id: "lutens-chergui", name: "Chergui", brand: "Serge Lutens", concentration: "Eau de Parfum",
                     topNotes: ["Hay", "Tobacco", "Honey"], heartNotes: ["Iris", "Rose", "Incense"], baseNotes: ["Vanilla", "Amber", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "lutens-nuit-de-cellophane", name: "Nuit de Cellophane", brand: "Serge Lutens", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin"], heartNotes: ["Osmanthus", "Jasmine", "White Flowers"], baseNotes: ["Musk", "Cedar", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "lutens-fille-en-aiguilles", name: "Fille en Aiguilles", brand: "Serge Lutens", concentration: "Eau de Parfum",
                     topNotes: ["Pine", "Frankincense"], heartNotes: ["Balsam", "Sandalwood"], baseNotes: ["Musk", "Amber", "Vanilla"], gender: "Unisex"),

        // FRÉDÉRIC MALLE (additional)
        PerfumeEntry(id: "malle-the-night", name: "The Night", brand: "Frédéric Malle", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Rose"], heartNotes: ["Oud", "Incense", "Leather"], baseNotes: ["Amber", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "malle-carnal-flower", name: "Carnal Flower", brand: "Frédéric Malle", concentration: "Eau de Parfum",
                     topNotes: ["Melon", "Eucalyptus"], heartNotes: ["Tuberose", "Jasmine"], baseNotes: ["Musk", "Coconut", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "malle-en-passant", name: "En Passant", brand: "Frédéric Malle", concentration: "Eau de Parfum",
                     topNotes: ["Cucumber", "Wheat"], heartNotes: ["Lilac", "White Musk"], baseNotes: ["Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "malle-superstitious", name: "Superstitious", brand: "Frédéric Malle", concentration: "Eau de Parfum",
                     topNotes: ["Turkish Rose"], heartNotes: ["Iris", "Patchouli"], baseNotes: ["Musk", "Amber", "Incense"], gender: "Women"),

        // ETAT LIBRE D'ORANGE (additional)
        PerfumeEntry(id: "elo-noel-au-balcon", name: "Noel au Balcon", brand: "Etat Libre d'Orange", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Petitgrain"], heartNotes: ["Lily", "Cinnamon", "Iris"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "elo-archives-69", name: "Archives 69", brand: "Etat Libre d'Orange", concentration: "Eau de Parfum",
                     topNotes: ["Blood Orange", "Ylang Ylang"], heartNotes: ["Rose", "Jasmine", "Frankincense"], baseNotes: ["Sandalwood", "Cashmeran", "Musk"], gender: "Unisex"),

        // ATELIER COLOGNE (additional)
        PerfumeEntry(id: "atelier-clementine-california", name: "Clémentine California", brand: "Atelier Cologne", concentration: "Cologne Absolue",
                     topNotes: ["Clementine", "Juniper Berries", "Ginger"], heartNotes: ["Cypress", "Star Anise", "Cardamom"], baseNotes: ["Vetiver", "Sandalwood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "atelier-vanille-insensee", name: "Vanille Insensée", brand: "Atelier Cologne", concentration: "Cologne Absolue",
                     topNotes: ["Lime", "Bergamot", "Coriander"], heartNotes: ["Jasmine", "Vanilla Absolute"], baseNotes: ["Ebony", "Cashmere Wood", "Oak Moss"], gender: "Unisex"),

        // COMMODITY (additional)
        PerfumeEntry(id: "commodity-bergamot", name: "Bergamot", brand: "Commodity", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Grapefruit"], heartNotes: ["Neroli", "Green Tea"], baseNotes: ["Musk", "Cedar", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "commodity-velvet", name: "Velvet", brand: "Commodity", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Black Pepper"], heartNotes: ["Orris", "Suede", "Rose"], baseNotes: ["Musk", "Amber", "Oud", "Vanilla"], gender: "Unisex"),

        // MONTALE (additional niche)
        PerfumeEntry(id: "montale-honey-aoud", name: "Honey Aoud", brand: "Montale", concentration: "Eau de Parfum",
                     topNotes: ["Honey", "Citrus"], heartNotes: ["Oud", "Rose", "Patchouli"], baseNotes: ["Vanilla", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "montale-arabians-tonka", name: "Arabians Tonka", brand: "Montale", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Saffron"], heartNotes: ["Tonka Bean", "Orris", "Amber"], baseNotes: ["Vanilla", "Sandalwood", "Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "montale-aoud-leather", name: "Aoud Leather", brand: "Montale", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Green Apple", "Saffron"], heartNotes: ["Oud", "Leather", "Rose"], baseNotes: ["Musk", "Amber", "Sandalwood", "Patchouli"], gender: "Unisex"),

        // MANCERA (additional niche)
        PerfumeEntry(id: "mancera-aoud-blue-notes", name: "Aoud Blue Notes", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Mint"], heartNotes: ["Rose", "Jasmine", "Patchouli"], baseNotes: ["Oud", "Sandalwood", "Musk", "Vanilla", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-gold-prestigium", name: "Gold Prestigium", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Bergamot", "Pink Pepper"], heartNotes: ["Rose", "Jasmine", "Iris"], baseNotes: ["Vanilla", "Amber", "Sandalwood", "Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-sicily", name: "Sicily", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Mandarin", "Grapefruit"], heartNotes: ["Neroli", "Jasmine", "Orange Blossom"], baseNotes: ["Musk", "Cedar", "Amber"], gender: "Unisex"),

        // JULIETTE HAS A GUN (additional)
        PerfumeEntry(id: "jhag-lady-vengeance", name: "Lady Vengeance", brand: "Juliette Has a Gun", concentration: "Eau de Parfum",
                     topNotes: ["Bulgarian Rose", "Bergamot"], heartNotes: ["Rose", "Jasmine", "Vanilla"], baseNotes: ["Patchouli", "Musk", "Sandalwood"], gender: "Women"),
        PerfumeEntry(id: "jhag-sunny-side-up", name: "Sunny Side Up", brand: "Juliette Has a Gun", concentration: "Eau de Parfum",
                     topNotes: ["Jasmine", "Green Almond", "Iris"], heartNotes: ["Heliotrope", "Sandalwood"], baseNotes: ["Tonka Bean", "Musk", "White Cedarwood"], gender: "Women"),

        // PENHALIGON'S (additional niche)
        PerfumeEntry(id: "penhaligons-juniper-sling", name: "Juniper Sling", brand: "Penhaligon's", concentration: "Eau de Toilette",
                     topNotes: ["Juniper Berries", "Angelica", "Black Pepper"], heartNotes: ["Orange Blossom", "Cardamom", "Gin"], baseNotes: ["Leather", "Birch Tar", "Sugar"], gender: "Unisex"),
        PerfumeEntry(id: "penhaligons-terrible-teddy", name: "Terrible Teddy", brand: "Penhaligon's", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Thyme", "Lavender"], heartNotes: ["Rum", "Rose", "Geranium"], baseNotes: ["Oud", "Cedar", "Musk", "Vanilla"], gender: "Unisex"),

        // DIPTYQUE (additional niche)
        PerfumeEntry(id: "diptyque-orpheon", name: "Orphéon", brand: "Diptyque", concentration: "Eau de Parfum",
                     topNotes: ["Juniper Berries", "Black Pepper"], heartNotes: ["Jasmine", "Tonka Bean"], baseNotes: ["Cedar", "Musk", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "diptyque-fleur-de-peau", name: "Fleur de Peau", brand: "Diptyque", concentration: "Eau de Parfum",
                     topNotes: ["Iris", "Pink Pepper"], heartNotes: ["Musk", "Ambrette"], baseNotes: ["Sandalwood", "Cedar", "Musk"], gender: "Unisex"),

        // ACQUA DI PARMA (additional niche)
        PerfumeEntry(id: "adp-ambra", name: "Ambra", brand: "Acqua di Parma", concentration: "Eau de Parfum",
                     topNotes: ["Myrrh", "Amber"], heartNotes: ["Labdanum", "Vanilla", "Cypriol"], baseNotes: ["Sandalwood", "Benzoin", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "adp-signatures-oud-cashmere", name: "Signatures of the Sun Oud & Cashmere", brand: "Acqua di Parma", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Cardamom"], heartNotes: ["Oud", "Rose", "Cashmere Wood"], baseNotes: ["Sandalwood", "Musk", "Amber", "Vanilla"], gender: "Unisex"),

        // CLEAN RESERVE (additional)
        PerfumeEntry(id: "clean-reserve-skin", name: "Skin", brand: "Clean Reserve", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Apricot"], heartNotes: ["Rose", "Peony", "Musk"], baseNotes: ["Sandalwood", "Amber", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "clean-reserve-radiant-nectar", name: "Radiant Nectar", brand: "Clean Reserve", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Mandarin"], heartNotes: ["Peony", "Magnolia", "Osmanthus"], baseNotes: ["Musk", "Amber", "Sandalwood"], gender: "Unisex"),

        // ESCENTRIC MOLECULES
        PerfumeEntry(id: "em-molecule-01", name: "Molecule 01", brand: "Escentric Molecules", concentration: "Eau de Toilette",
                     topNotes: ["Iso E Super"], heartNotes: ["Iso E Super"], baseNotes: ["Iso E Super"], gender: "Unisex"),
        PerfumeEntry(id: "em-escentric-02", name: "Escentric 02", brand: "Escentric Molecules", concentration: "Eau de Toilette",
                     topNotes: ["Green Notes", "Black Pepper", "Hedione"], heartNotes: ["Iris", "Ambroxan"], baseNotes: ["Musk", "Amber", "Vetiver"], gender: "Unisex"),

        // LIQUIDES IMAGINAIRES
        PerfumeEntry(id: "li-bloody-wood", name: "Bloody Wood", brand: "Liquides Imaginaires", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Saffron"], heartNotes: ["Rose", "Oud", "Incense"], baseNotes: ["Sandalwood", "Amber", "Musk", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "li-peau-de-bete", name: "Peau de Bête", brand: "Liquides Imaginaires", concentration: "Eau de Parfum",
                     topNotes: ["Aldehydes", "Pink Pepper"], heartNotes: ["Leather", "Castoreum", "Jasmine"], baseNotes: ["Musk", "Amber", "Vanilla", "Sandalwood"], gender: "Unisex"),

        // HISTOIRES DE PARFUMS
        PerfumeEntry(id: "hdp-1899", name: "1899 Hemingway", brand: "Histoires de Parfums", concentration: "Eau de Parfum",
                     topNotes: ["Rum", "Pepper"], heartNotes: ["Leather", "Tobacco", "Elemi"], baseNotes: ["Musk", "Amber", "Cedar", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "hdp-1725", name: "1725 Casanova", brand: "Histoires de Parfums", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin"], heartNotes: ["Rose", "Jasmine", "Cedar"], baseNotes: ["Amber", "Musk", "Vanilla", "Sandalwood"], gender: "Men"),

        // HAUTE FRAGRANCE COMPANY (HFC)
        PerfumeEntry(id: "hfc-devil-in-disguise", name: "Devil's Intrigue", brand: "HFC", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Green Apple"], heartNotes: ["Jasmine", "Rose", "Peony"], baseNotes: ["Musk", "Amber", "Sandalwood", "Vanilla"], gender: "Women"),

        // BANANA REPUBLIC
        PerfumeEntry(id: "br-tobacco-tonka", name: "Tobacco & Tonka Bean", brand: "Banana Republic", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Cardamom"], heartNotes: ["Tobacco", "Cinnamon", "Geranium"], baseNotes: ["Tonka Bean", "Vanilla", "Sandalwood", "Musk"], gender: "Unisex"),

        // REPLICA ADDITIONS (more Maison Margiela)
        PerfumeEntry(id: "mm-autumn-vibes", name: "Autumn Vibes", brand: "Maison Margiela", concentration: "Eau de Toilette",
                     topNotes: ["Cardamom", "Pink Pepper", "Nutmeg"], heartNotes: ["Styrax", "Cedar", "Mate"], baseNotes: ["Woody Notes", "Musk", "Moss"], gender: "Unisex"),
        PerfumeEntry(id: "mm-springtime-in-a-park", name: "Springtime in a Park", brand: "Maison Margiela", concentration: "Eau de Toilette",
                     topNotes: ["Pear", "Pink Pepper", "Bergamot"], heartNotes: ["Rose", "Lily of the Valley", "Peony"], baseNotes: ["Musk", "Cedar", "Vetiver"], gender: "Unisex"),

        // SWISS ARABIAN (additional)
        PerfumeEntry(id: "swiss-arabian-casablanca", name: "Casablanca", brand: "Swiss Arabian", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Grapefruit"], heartNotes: ["Rose", "Jasmine", "Iris"], baseNotes: ["Cedar", "Musk", "Amber", "Patchouli"], gender: "Unisex"),

        // RASASI (additional)
        PerfumeEntry(id: "rasasi-hawas", name: "Hawas", brand: "Rasasi", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Apple", "Cinnamon"], heartNotes: ["Marine Notes", "Ambroxan", "Rose"], baseNotes: ["Musk", "Amber", "Patchouli", "Woodsy Notes"], gender: "Men"),

        // AL HARAMAIN (additional)
        PerfumeEntry(id: "alharamain-detour-noir", name: "Détour Noir", brand: "Al Haramain", concentration: "Eau de Parfum",
                     topNotes: ["Lavender", "Lemon", "Mint"], heartNotes: ["Coffee", "Oud", "Tobacco"], baseNotes: ["Vanilla", "Tonka Bean", "Musk", "Patchouli"], gender: "Men"),



        // MATIÈRE PREMIÈRE
        PerfumeEntry(id: "mp-crystal-saffron", name: "Crystal Saffron", brand: "Matière Première", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Bergamot"], heartNotes: ["Incense", "Ambroxan"], baseNotes: ["Musk", "Amber", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "mp-radical-rose", name: "Radical Rose", brand: "Matière Première", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Bergamot", "Pink Pepper"], heartNotes: ["Centifolia Rose", "Geranium"], baseNotes: ["Patchouli", "Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "mp-parisian-musc", name: "Parisian Musc", brand: "Matière Première", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Green Notes"], heartNotes: ["Musk", "Iris", "Violet"], baseNotes: ["Sandalwood", "Cedar", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "mp-santal-austral", name: "Santal Austral", brand: "Matière Première", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Bergamot"], heartNotes: ["Sandalwood", "Iris", "Rose"], baseNotes: ["Vanilla", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "mp-falcon-leather", name: "Falcon Leather", brand: "Matière Première", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Leather", "Birch", "Oud"], baseNotes: ["Vetiver", "Musk", "Amber", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "mp-encens-suave", name: "Encens Suave", brand: "Matière Première", concentration: "Eau de Parfum",
                     topNotes: ["Incense", "Bergamot", "Elemi"], heartNotes: ["Olibanum", "Iris", "Labdanum"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Benzoin"], gender: "Unisex"),
        PerfumeEntry(id: "mp-vanilla-powder", name: "Vanilla Powder", brand: "Matière Première", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Vanilla", "Iris", "Heliotrope"], baseNotes: ["Musk", "Sandalwood", "Tonka Bean"], gender: "Unisex"),

        // KEROSENE
        PerfumeEntry(id: "kerosene-unknown-pleasures", name: "Unknown Pleasures", brand: "Kerosene", concentration: "Eau de Parfum",
                     topNotes: ["Coffee", "Bergamot"], heartNotes: ["Vanilla", "Tonka Bean", "Caramel"], baseNotes: ["Sandalwood", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "kerosene-sweetly-known", name: "Sweetly Known", brand: "Kerosene", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon"], heartNotes: ["Rose", "Vanilla", "Jasmine"], baseNotes: ["Musk", "Sandalwood", "Amber", "Tonka Bean"], gender: "Unisex"),
        PerfumeEntry(id: "kerosene-follow", name: "Follow", brand: "Kerosene", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Blood Orange"], heartNotes: ["Jasmine", "Neroli", "Rose"], baseNotes: ["Musk", "Amber", "Cedar", "Vanilla"], gender: "Unisex"),

        // MAISON LOUIS MARIE
        PerfumeEntry(id: "mlm-no4-bois-de-balincourt", name: "No.04 Bois de Balincourt", brand: "Maison Louis Marie", concentration: "Eau de Parfum",
                     topNotes: ["Nutmeg", "Cinnamon Bark"], heartNotes: ["Sandalwood", "Cedar", "Vetiver"], baseNotes: ["Amber", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "mlm-no13-nouvelle-vague", name: "No.13 Nouvelle Vague", brand: "Maison Louis Marie", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Hinoki"], heartNotes: ["Jasmine", "Green Tea"], baseNotes: ["Sandalwood", "Musk"], gender: "Unisex"),

        // HOUSE OF SILLAGE
        PerfumeEntry(id: "hos-cherry-garden", name: "Cherry Garden", brand: "House of Sillage", concentration: "Eau de Parfum",
                     topNotes: ["Cherry", "Bergamot", "Pink Pepper"], heartNotes: ["Rose", "Jasmine", "Peony"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Amber"], gender: "Women"),
        PerfumeEntry(id: "hos-whispers-of-strength", name: "Whispers of Strength", brand: "House of Sillage", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Saffron"], heartNotes: ["Iris", "Oud", "Rose"], baseNotes: ["Amber", "Musk", "Sandalwood", "Leather"], gender: "Men"),

        // FUGAZZI
        PerfumeEntry(id: "fugazzi-sugar-milk", name: "Sugar Milk", brand: "Fugazzi", concentration: "Extrait de Parfum",
                     topNotes: ["Milk", "Bergamot"], heartNotes: ["Vanilla", "Rice", "Almond"], baseNotes: ["Musk", "Sandalwood", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "fugazzi-workaholic", name: "Workaholic", brand: "Fugazzi", concentration: "Extrait de Parfum",
                     topNotes: ["Coffee", "Black Pepper"], heartNotes: ["Leather", "Tobacco", "Oud"], baseNotes: ["Vanilla", "Amber", "Musk"], gender: "Unisex"),

        // BOADICEA THE VICTORIOUS
        PerfumeEntry(id: "boadicea-blue-sapphire", name: "Blue Sapphire", brand: "Boadicea the Victorious", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Pink Pepper"], heartNotes: ["Jasmine", "Rose", "Violet"], baseNotes: ["Musk", "Amber", "Sandalwood", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "boadicea-complex", name: "Complex", brand: "Boadicea the Victorious", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Saffron"], heartNotes: ["Rose", "Oud", "Incense"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla"], gender: "Unisex"),

        // MALIN+GOETZ
        PerfumeEntry(id: "malingoetz-dark-rum", name: "Dark Rum", brand: "Malin+Goetz", concentration: "Eau de Parfum",
                     topNotes: ["Rum", "Bergamot", "Plum"], heartNotes: ["Leather", "Birch", "Amber"], baseNotes: ["Musk", "Vanilla", "Tonka Bean"], gender: "Unisex"),
        PerfumeEntry(id: "malingoetz-cannabis", name: "Cannabis", brand: "Malin+Goetz", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Black Pepper"], heartNotes: ["Cannabis", "Fig", "Geranium"], baseNotes: ["Patchouli", "Musk", "Cedar", "Amber"], gender: "Unisex"),

        // PHLUR
        PerfumeEntry(id: "phlur-missing-person", name: "Missing Person", brand: "Phlur", concentration: "Eau de Parfum",
                     topNotes: ["Neroli", "Bergamot"], heartNotes: ["Jasmine", "Skin Musk"], baseNotes: ["Sandalwood", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "phlur-father-figure", name: "Father Figure", brand: "Phlur", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Suede", "Orris", "Violet"], baseNotes: ["Sandalwood", "Musk", "Amber", "Cedar"], gender: "Unisex"),

        // BOY SMELLS
        PerfumeEntry(id: "boysmells-hinoki-fantome", name: "Hinoki Fantôme", brand: "Boy Smells", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Hinoki"], heartNotes: ["Incense", "Iris", "Violet"], baseNotes: ["Musk", "Cedar", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "boysmells-suede-pony", name: "Suede Pony", brand: "Boy Smells", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Saffron"], heartNotes: ["Suede", "Leather", "Rose"], baseNotes: ["Musk", "Amber", "Sandalwood", "Tonka Bean"], gender: "Unisex"),

        // DUSITA
        PerfumeEntry(id: "dusita-melodie-de-lamour", name: "Mélodie de l'Amour", brand: "Dusita", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Lychee"], heartNotes: ["Rose", "Jasmine", "Ylang Ylang"], baseNotes: ["Sandalwood", "Musk", "Vanilla", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "dusita-oudh-infini", name: "Oudh Infini", brand: "Dusita", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Saffron"], heartNotes: ["Oud", "Rose", "Incense"], baseNotes: ["Sandalwood", "Amber", "Musk", "Vanilla"], gender: "Unisex"),

        // NEANDERTAL
        PerfumeEntry(id: "neandertal-us", name: "Us", brand: "Neandertal", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Iris", "Violet", "Jasmine"], baseNotes: ["Musk", "Sandalwood", "Amber"], gender: "Unisex"),

        // FLORAIKU
        PerfumeEntry(id: "floraiku-one-umbrella-for-two", name: "One Umbrella for Two", brand: "Floraïku", concentration: "Eau de Parfum",
                     topNotes: ["Pear", "Bergamot"], heartNotes: ["Jasmine", "Osmanthus", "Ylang Ylang"], baseNotes: ["Musk", "Sandalwood", "Vanilla", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "floraiku-secret-tea-ceremony", name: "Secret Tea Ceremony", brand: "Floraïku", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Green Tea"], heartNotes: ["Jasmine", "Hinoki", "Incense"], baseNotes: ["Musk", "Sandalwood", "Amber", "Cedar"], gender: "Unisex"),

        // AFRICAN BOTANICS
        PerfumeEntry(id: "africanbot-marula", name: "Marula", brand: "African Botanics", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Mandarin"], heartNotes: ["Jasmine", "Fynbos", "Marula"], baseNotes: ["Sandalwood", "Musk", "Amber", "Vanilla"], gender: "Unisex"),

        // AMOUAGE (more)
        PerfumeEntry(id: "amouage-boundless", name: "Boundless", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Pink Pepper"], heartNotes: ["Iris", "Jasmine", "Rose"], baseNotes: ["Musk", "Amber", "Sandalwood", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "amouage-guidance", name: "Guidance", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Cardamom", "Elemi"], heartNotes: ["Oud", "Rose", "Saffron"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla", "Incense"], gender: "Unisex"),

        // PARFUMS DE MARLY (more)
        PerfumeEntry(id: "pdm-althair", name: "Althair", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Pink Pepper"], heartNotes: ["Iris", "Rose", "Vanilla"], baseNotes: ["Musk", "Amber", "Sandalwood", "Tonka Bean"], gender: "Men"),
        PerfumeEntry(id: "pdm-valaya", name: "Valaya", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Pear"], heartNotes: ["Rose", "Peony", "Jasmine"], baseNotes: ["Musk", "Vanilla", "Sandalwood", "Cedar"], gender: "Women"),

        // NISHANE (more)
        PerfumeEntry(id: "nishane-safran-colognise", name: "Safran Colognisé", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Saffron", "Bergamot", "Lemon"], heartNotes: ["Rose", "Iris", "Cinnamon"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "nishane-vain-naive", name: "Vain & Naïve", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Mandarin"], heartNotes: ["Rose", "Jasmine", "Peony"], baseNotes: ["Musk", "Cedar", "Amber", "Patchouli"], gender: "Unisex"),

        // XERJOFF (more)
        PerfumeEntry(id: "xerjoff-mefisto", name: "Mefisto", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lavender", "Grapefruit"], heartNotes: ["Rose", "Jasmine", "Violet"], baseNotes: ["Musk", "Cedar", "Sandalwood", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "xerjoff-opera", name: "Opera", brand: "Xerjoff", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Mandarin"], heartNotes: ["Rose", "Oud", "Saffron"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla", "Leather"], gender: "Unisex"),

        // INITIO (more)
        PerfumeEntry(id: "initio-parfums-prives-absolute-aphrodisiac", name: "Absolute Aphrodisiac", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Myrrh"], heartNotes: ["Vanilla", "Musk", "Sandalwood"], baseNotes: ["Amber", "Cashmeran", "Agarwood"], gender: "Unisex"),
        PerfumeEntry(id: "initio-addictive-vibration", name: "Addictive Vibration", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Ginger", "Mandarin"], heartNotes: ["Jasmine", "Magnolia", "Peach"], baseNotes: ["Musk", "Vanilla", "Sandalwood", "Amber"], gender: "Women"),

        // KILIAN (more)
        PerfumeEntry(id: "kilian-apple-brandy", name: "Apple Brandy on the Rocks", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Apple", "Vodka", "Bergamot"], heartNotes: ["Cardamom", "Rose", "Tuberose"], baseNotes: ["Vanilla", "Sandalwood", "Musk", "Oak"], gender: "Unisex"),
        PerfumeEntry(id: "kilian-roses-on-ice", name: "Roses on Ice", brand: "Kilian", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Bergamot", "Mint"], heartNotes: ["Rose", "Geranium"], baseNotes: ["Musk", "Ambroxan", "Cedar"], gender: "Unisex"),

        // TIZIANA TERENZI (more)
        PerfumeEntry(id: "tt-luna-blue-collection-ursa", name: "Ursa", brand: "Tiziana Terenzi", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Grapefruit", "Saffron"], heartNotes: ["Rose", "Oud", "Incense"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla", "Leather"], gender: "Unisex"),
        PerfumeEntry(id: "tt-anniversary-collection-gumin", name: "Gumin", brand: "Tiziana Terenzi", concentration: "Extrait de Parfum",
                     topNotes: ["Saffron", "Bergamot"], heartNotes: ["Oud", "Rose", "Amber"], baseNotes: ["Musk", "Vanilla", "Sandalwood", "Leather"], gender: "Unisex"),

        // ROJA PARFUMS (more)
        PerfumeEntry(id: "roja-danger", name: "Danger", brand: "Roja Parfums", concentration: "Parfum",
                     topNotes: ["Bergamot", "Lemon", "Mint", "Lavender"], heartNotes: ["Rose", "Jasmine", "Iris", "Clove"], baseNotes: ["Oud", "Sandalwood", "Vetiver", "Musk", "Vanilla", "Leather"], gender: "Men"),
        PerfumeEntry(id: "roja-elixir", name: "Elixir", brand: "Roja Parfums", concentration: "Parfum",
                     topNotes: ["Bergamot", "Mandarin"], heartNotes: ["Rose", "Jasmine", "Tuberose", "Orange Blossom"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Amber", "Oud"], gender: "Women"),

        // CLIVE CHRISTIAN (more)
        PerfumeEntry(id: "cc-jump-up-and-kiss-me", name: "Jump Up And Kiss Me Hedonistic", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Mandarin", "Bergamot", "Lychee"], heartNotes: ["Rose", "Jasmine", "Violet"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Amber"], gender: "Women"),

        // BOND NO. 9 (more)
        PerfumeEntry(id: "bond9-new-york-oud", name: "New York Oud", brand: "Bond No. 9", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Black Pepper", "Saffron"], heartNotes: ["Oud", "Rose", "Geranium"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla"], gender: "Unisex"),

        // CREED (more)
        PerfumeEntry(id: "creed-carmina", name: "Carmina", brand: "Creed", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Pink Pepper"], heartNotes: ["Rose", "Jasmine", "Peony"], baseNotes: ["Musk", "Sandalwood", "Vanilla", "Ambergris"], gender: "Women"),
        PerfumeEntry(id: "creed-absolu-aventus", name: "Absolu Aventus", brand: "Creed", concentration: "Parfum",
                     topNotes: ["Pineapple", "Bergamot", "Apple", "Black Currant"], heartNotes: ["Birch", "Jasmine", "Oud"], baseNotes: ["Musk", "Ambergris", "Vanilla", "Sandalwood"], gender: "Men"),

        // TOSKOVAT'
        PerfumeEntry(id: "toskovat-inexcusable-evil", name: "Inexcusable Evil", brand: "Toskovat'", concentration: "Extrait de Parfum",
                     topNotes: ["Gunpowder", "Ozone"], heartNotes: ["Blood Accord", "Iodine", "Burning Flowers", "Guaiac Wood", "Copaiba", "Nagarmotha"], baseNotes: ["Concrete", "Rain", "Incense", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-age-of-innocence", name: "Age of Innocence", brand: "Toskovat'", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Mandarin"], heartNotes: ["Jasmine", "Rose", "Violet"], baseNotes: ["Sandalwood", "Amber", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-curtain-call", name: "Curtain Call", brand: "Toskovat'", concentration: "Extrait de Parfum",
                     topNotes: ["Blood Orange", "Raspberry", "Pear", "Elder", "Icing Sugar"], heartNotes: ["Magnolia", "White Rose", "Jasmine", "Musk"], baseNotes: ["Tobacco", "Gurjun Balsam", "Tonka Bean", "Patchouli", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-things-we-never-shared", name: "Things We Never Shared", brand: "Toskovat'", concentration: "Extrait de Parfum",
                     topNotes: ["Coffee", "Cardamom", "Bergamot"], heartNotes: ["Rose", "Jasmine", "Iris"], baseNotes: ["Vanilla", "Sandalwood", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-born-screaming", name: "Born Screaming", brand: "Toskovat'", concentration: "Eau de Parfum",
                     topNotes: ["Cherry", "Blackberry", "Latex"], heartNotes: ["Smoke", "Datura", "Heliotrope", "Rose", "Boronia"], baseNotes: ["Myrrh", "Styrax", "Freesia", "Patchouli", "Castoreum", "Ambrette"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-last-birthday-cake", name: "Last Birthday Cake", brand: "Toskovat'", concentration: "Eau de Parfum",
                     topNotes: ["Bitter Almond", "Milk", "Malt", "Hazelnut"], heartNotes: ["Vanilla", "Tonka Bean", "Cake", "Brown Sugar", "Custard", "Brandy", "Benzoin"], baseNotes: ["Incense", "Gunpowder", "Tolu Balsam"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-forlorn-embers", name: "Forlorn Embers & Black Reigns", brand: "Toskovat'", concentration: "Extrait de Parfum",
                     topNotes: ["Bourbon", "Mace", "Walnut"], heartNotes: ["Carob", "Truffle", "Pine", "Dried Fruits", "Burnt Ashes"], baseNotes: ["Sycamore", "Mahogany", "Oak", "Leatherwood"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-ichigo-ichie", name: "Ichigo Ichie", brand: "Toskovat'", concentration: "Eau de Parfum",
                     topNotes: ["Hibiscus", "Nashi Pear", "Sakura"], heartNotes: ["Hydrangea", "Tiger Lily", "Orris", "Water Lily", "Black Tea"], baseNotes: ["Hinoki", "Redwood", "Rooibos Tea", "Musk", "Amber", "Incense"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-silent-theme-park", name: "Silent at The Theme Park", brand: "Toskovat'", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Orange Blossom", "Linden Blossom", "Lilac"], heartNotes: ["Lily of the Valley", "Cacao", "Ylang Ylang"], baseNotes: ["Olibanum", "Fir Balsam", "Labdanum", "Patchouli", "Cedar", "Oakmoss", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-empty-wishes-well", name: "Empty Wishes Well", brand: "Toskovat'", concentration: "Eau de Parfum",
                     topNotes: ["Petrichor", "Myrrh"], heartNotes: ["Dry Leaves", "Sage"], baseNotes: ["Soil", "Patchouli", "Vetiver", "Amyris", "Galbanum", "Carrot Seeds"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-generation-godard", name: "Génération Godard", brand: "Toskovat'", concentration: "Eau de Parfum",
                     topNotes: ["Sour Candy", "Popcorn", "Cola"], heartNotes: ["Rose", "Newspaper"], baseNotes: ["Musk", "Labdanum", "Ambrette"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-annacamento", name: "Annacamento", brand: "Toskovat'", concentration: "Eau de Parfum",
                     topNotes: ["Orange", "Blood Orange", "Prickly Pear", "Verbena"], heartNotes: ["Ricotta", "Rum", "Frangipani", "Broom"], baseNotes: ["Cedar", "Oak", "Sea Fennel", "Rock Rose", "Cypress"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-my-past-selves-flowers", name: "My Past Selves' Flowers", brand: "Toskovat'", concentration: "Extrait de Parfum",
                     topNotes: ["Snakefruit", "Mangosteen", "Green Tea"], heartNotes: ["Azalea", "Peony", "Orchid", "Hojicha Tea"], baseNotes: ["Oud", "Nag Champa", "Incense", "Dragon's Blood", "Laka Wood"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-anarchist-a", name: "Anarchist A_", brand: "Toskovat'", concentration: "Extrait de Parfum",
                     topNotes: ["Black Pepper", "Bergamot"], heartNotes: ["Leather", "Smoke", "Rose"], baseNotes: ["Vetiver", "Patchouli", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-pining-dew-2", name: "Pining Dew 2", brand: "Toskovat'", concentration: "Eau de Parfum",
                     topNotes: ["Pine", "Eucalyptus", "Mint"], heartNotes: ["Moss", "Fern", "Green Notes"], baseNotes: ["Cedar", "Musk", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-ya", name: "Я", brand: "Toskovat'", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Cardamom"], heartNotes: ["Rose", "Oud", "Incense"], baseNotes: ["Amber", "Sandalwood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "toskovat-in-the-belly-of-the-beast", name: "In The Belly of The Beast", brand: "Toskovat'", concentration: "Extrait de Parfum",
                     topNotes: ["Black Pepper", "Saffron"], heartNotes: ["Leather", "Oud", "Smoke"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla"], gender: "Unisex"),

        // BORN TO STAND OUT (BTSO)
        PerfumeEntry(id: "btso-indecent-cherry", name: "Indecent Cherry", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Cherry", "Almond", "Saffron"], heartNotes: ["Sour Cherry", "Strawberry", "Bulgarian Rose", "Mimosa"], baseNotes: ["Vanilla", "Amber", "Musk", "Benzoin"], gender: "Unisex"),
        PerfumeEntry(id: "btso-dirty-heaven", name: "Dirty Heaven", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Jasmine", "Neroli", "White Flowers"], heartNotes: ["Tonka Bean", "Saffron", "Ambroxan"], baseNotes: ["Vanilla", "White Musk", "Grey Amber", "Woods"], gender: "Unisex"),
        PerfumeEntry(id: "btso-drunk-saffron", name: "Drunk Saffron", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Plum", "Cognac"], heartNotes: ["Saffron", "Leather", "Coffee"], baseNotes: ["Patchouli", "Vanilla", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "btso-mad-honey", name: "Mad Honey", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Rum"], heartNotes: ["Honey", "Damask Rose"], baseNotes: ["Bourbon Vanilla", "Tonka Bean", "Patchouli", "Benzoin"], gender: "Unisex"),
        PerfumeEntry(id: "btso-dirty-rice", name: "Dirty Rice", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Almond"], heartNotes: ["Basmati Rice", "Peony", "Milk"], baseNotes: ["Sandalwood", "Vetiver", "Cedar", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "btso-fig-porn", name: "Fig Porn", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Fig", "Pear", "Bergamot"], heartNotes: ["Turkish Rose", "Peony", "Cedar"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "btso-filthy-musk", name: "Filthy Musk", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Musk", "Honey", "Pineapple"], heartNotes: ["Musk", "Jasmine", "Nutmeg", "Patchouli"], baseNotes: ["Musk", "Civet", "Vanilla", "Caramel", "Tonka Bean", "Ambergris"], gender: "Unisex"),
        PerfumeEntry(id: "btso-sex-cognac", name: "Sex & Cognac", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Cognac"], heartNotes: ["Papyrus", "Leather"], baseNotes: ["Oud", "Amber", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "btso-smokin-gun", name: "Smokin' Gun", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Campari", "Rum", "Bitter Orange", "Juniper"], heartNotes: ["Whiskey", "Pine", "Incense", "Leather", "Cinnamon"], baseNotes: ["Oak", "Cedar", "Tobacco", "Vanilla", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "btso-drunk-lovers", name: "Drunk Lovers", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Cognac", "Red Berries", "Juniper", "Grapefruit", "Bergamot"], heartNotes: ["Pepper", "Cypress", "Ginger", "Clary Sage"], baseNotes: ["Vanilla", "Sandalwood", "Amber", "Musk", "Cedar", "Benzoin", "Patchouli", "Cinnamon"], gender: "Unisex"),
        PerfumeEntry(id: "btso-naked-laundry", name: "Naked Laundry", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Aldehydes", "Mandarin"], heartNotes: ["Mimosa", "Caramel", "Honey"], baseNotes: ["Milk", "Tonka Bean", "Amber", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "btso-dgaf", name: "DGAF", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Sage", "Citrus", "Violet", "Bergamot"], heartNotes: ["Sandalwood", "Pepper", "Bulgarian Rose", "Incense"], baseNotes: ["Cashmeran", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "btso-hinoki-shower", name: "Hinoki Shower", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Camphor", "Cypress", "Pine"], heartNotes: ["Thyme", "Cedar", "Woods"], baseNotes: ["Tobacco", "Vetiver", "Lichen"], gender: "Unisex"),
        PerfumeEntry(id: "btso-sugar-addict", name: "Sugar Addict", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Sugar", "Cinnamon"], heartNotes: ["Cocoa", "Coffee"], baseNotes: ["Tonka Bean", "Vanilla", "Rum", "Labdanum", "Cashmere Wood"], gender: "Unisex"),
        PerfumeEntry(id: "btso-nanatopia", name: "Nanatopia", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Nutmeg", "Cinnamon", "Rum"], heartNotes: ["Banana Bread", "Melted Caramel"], baseNotes: ["Tonka Bean", "Cypriol"], gender: "Unisex"),
        PerfumeEntry(id: "btso-angels-powder", name: "Angels' Powder", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Icing Sugar"], heartNotes: ["Vanilla", "Raspberry", "Cotton Candy"], baseNotes: ["Heliotrope", "White Musk", "Guaiac Wood"], gender: "Unisex"),
        PerfumeEntry(id: "btso-drunk-maple", name: "Drunk Maple", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Davana", "Rum"], heartNotes: ["Coffee", "Maple Syrup", "Suede"], baseNotes: ["Vanilla", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "btso-mary-jane", name: "Mary Jane", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Hemp", "Cannabis", "Mint", "Rhubarb", "Grapefruit"], heartNotes: ["Sage", "Passion Fruit", "Elemi"], baseNotes: ["Caramel", "Pine", "Cashmere Wood"], gender: "Unisex"),
        PerfumeEntry(id: "btso-l-animal", name: "L'Animal", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Rum", "Almond", "Nutmeg"], heartNotes: ["Leather", "Tobacco", "Saffron"], baseNotes: ["Vanilla", "Amber", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "btso-fugazzi", name: "Fugazzi", brand: "Born to Stand Out", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Geranium"], heartNotes: ["Rose", "Pepper"], baseNotes: ["Akigalawood", "Amber", "Cedar", "Tobacco", "Leather"], gender: "Unisex"),
        PerfumeEntry(id: "btso-dirty-rainbow", name: "Dirty Rainbow", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Pink Pepper"], heartNotes: ["Iris", "Rose", "Violet"], baseNotes: ["Musk", "Sandalwood", "Vanilla", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "btso-burnt-roses", name: "Burnt Roses", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Pink Pepper"], heartNotes: ["Rose", "Oud", "Smoke"], baseNotes: ["Leather", "Amber", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "btso-unholy-oud", name: "Unholy Oud", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Saffron", "Bergamot"], heartNotes: ["Oud", "Rose", "Incense"], baseNotes: ["Sandalwood", "Amber", "Musk", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "btso-sin-pleasure", name: "Sin & Pleasure", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Rose", "Jasmine", "Saffron"], baseNotes: ["Vanilla", "Amber", "Musk", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "btso-mud", name: "Mud", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Earth", "Bergamot"], heartNotes: ["Vetiver", "Patchouli", "Leather"], baseNotes: ["Musk", "Amber", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "btso-naked-neroli", name: "Naked Neroli", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Citron"], heartNotes: ["Neroli", "Orange Blossom", "Jasmine"], baseNotes: ["Musk", "Cedar", "Ambroxan"], gender: "Unisex"),
        PerfumeEntry(id: "btso-not-vanilla", name: "Not Vanilla", brand: "Born to Stand Out", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Vanilla", "Orchid", "Jasmine"], baseNotes: ["Musk", "Sandalwood", "Amber", "Tonka Bean"], gender: "Unisex"),

        // MAISON TAHITÉ
        PerfumeEntry(id: "tahite-vanilla-park", name: "Vanilla Park", brand: "Maison Tahité", concentration: "Eau de Parfum",
                     topNotes: ["Vanilla", "Bergamot", "Pink Pepper"], heartNotes: ["Jasmine", "Iris", "Tonka Bean"], baseNotes: ["Sandalwood", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "tahite-cacao-saltado", name: "Cacao Saltado", brand: "Maison Tahité", concentration: "Eau de Parfum",
                     topNotes: ["Sea Salt", "Bergamot", "Cardamom"], heartNotes: ["Cacao", "Coffee", "Tonka Bean"], baseNotes: ["Vanilla", "Sandalwood", "Musk"], gender: "Unisex"),

        // VERSACE (more)
        PerfumeEntry(id: "versace-man-eau-fraiche", name: "Man Eau Fraîche", brand: "Versace", concentration: "Eau de Toilette",
                     topNotes: ["Lemon", "White Rosebud", "Carambola"], heartNotes: ["Cedar", "Tarragon", "Sage"], baseNotes: ["Musk", "Amber", "Saffron", "Woody Notes"], gender: "Men"),

        // DOLCE & GABBANA (more)
        PerfumeEntry(id: "dg-the-one-gold", name: "The One Gold", brand: "Dolce & Gabbana", concentration: "Eau de Parfum Intense",
                     topNotes: ["Blood Orange", "Ginger", "Coriander"], heartNotes: ["Cardamom", "Geranium", "Orange Blossom"], baseNotes: ["Amber", "Myrrh", "Guaiac Wood", "Vanilla"], gender: "Men"),

        // GIORGIO ARMANI (more)
        PerfumeEntry(id: "armani-prive-oud-royal", name: "Privé Oud Royal", brand: "Giorgio Armani", concentration: "Eau de Parfum Intense",
                     topNotes: ["Saffron", "Rose"], heartNotes: ["Oud", "Incense", "Amber"], baseNotes: ["Sandalwood", "Musk", "Vanilla"], gender: "Unisex"),

        // HERMÈS (more)
        PerfumeEntry(id: "hermes-voyage", name: "Voyage d'Hermès", brand: "Hermès", concentration: "Parfum",
                     topNotes: ["Cardamom", "Lemon"], heartNotes: ["Green Tea", "Leather"], baseNotes: ["Musk", "Amber", "Blonde Wood"], gender: "Unisex"),
        PerfumeEntry(id: "hermes-h24", name: "H24", brand: "Hermès", concentration: "Eau de Toilette",
                     topNotes: ["Clary Sage", "Narcissus"], heartNotes: ["Rosewood", "Sclarene"], baseNotes: ["Musk", "Metallic Notes"], gender: "Men"),

        // JEAN PAUL GAULTIER (more)
        PerfumeEntry(id: "jpg-ultra-male", name: "Ultra Male", brand: "Jean Paul Gaultier", concentration: "Eau de Toilette Intense",
                     topNotes: ["Pear", "Bergamot", "Black Lavender"], heartNotes: ["Cinnamon", "Sage", "Cumin"], baseNotes: ["Vanilla", "Amber", "Cedar", "Benzoin"], gender: "Men"),
        PerfumeEntry(id: "jpg-le-male-le-parfum", name: "Le Male Le Parfum", brand: "Jean Paul Gaultier", concentration: "Eau de Parfum Intense",
                     topNotes: ["Cardamom", "Lavender", "Iris"], heartNotes: ["Lavandin", "Iris Concrete"], baseNotes: ["Vanilla", "Woody Notes", "Amber", "Benzoin"], gender: "Men"),

        // PDM (more)
        PerfumeEntry(id: "pdm-godolphin", name: "Godolphin", brand: "Parfums de Marly", concentration: "Eau de Parfum",
                     topNotes: ["Iris", "Plum", "Bergamot"], heartNotes: ["Rose", "Jasmine", "Leather"], baseNotes: ["Oud", "Vanilla", "Amber", "Sandalwood", "Musk"], gender: "Men"),

        // NISHANE (more)
        PerfumeEntry(id: "nishane-b-612", name: "B-612", brand: "Nishane", concentration: "Extrait de Parfum",
                     topNotes: ["Mandarin", "Bergamot", "Ginger"], heartNotes: ["Rose", "Jasmine", "Geranium"], baseNotes: ["Musk", "Patchouli", "Amber", "Sandalwood"], gender: "Unisex"),

        // AMOUAGE (more)
        PerfumeEntry(id: "amouage-honour-man", name: "Honour Man", brand: "Amouage", concentration: "Eau de Parfum",
                     topNotes: ["Pepper", "Nutmeg", "Elemi"], heartNotes: ["Frankincense", "Geranium", "Oud"], baseNotes: ["Leather", "Vetiver", "Patchouli", "Musk"], gender: "Men"),

        // TIZIANA TERENZI (more)
        PerfumeEntry(id: "tt-spirito-fiorentino", name: "Spirito Fiorentino", brand: "Tiziana Terenzi", concentration: "Extrait de Parfum",
                     topNotes: ["Bergamot", "Pepper", "Pear"], heartNotes: ["Rose", "Jasmine", "Iris"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Amber"], gender: "Unisex"),

        // ROJA PARFUMS (more)
        PerfumeEntry(id: "roja-creation-e", name: "Creation-E", brand: "Roja Parfums", concentration: "Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Peach"], heartNotes: ["Rose", "Jasmine", "Lily of the Valley", "Violet"], baseNotes: ["Sandalwood", "Musk", "Amber", "Vanilla", "Tonka Bean"], gender: "Women"),

        // MEMO PARIS (more)
        PerfumeEntry(id: "memo-winter-palace", name: "Winter Palace", brand: "Memo Paris", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Orange", "Clove"], heartNotes: ["Oud", "Rose", "Saffron"], baseNotes: ["Amber", "Vanilla", "Musk", "Sandalwood"], gender: "Unisex"),

        // PROFUMUM ROMA (more)
        PerfumeEntry(id: "profumum-dulcis-in-fundo", name: "Dulcis in Fundo", brand: "Profumum Roma", concentration: "Parfum",
                     topNotes: ["Hazelnut", "Caramel"], heartNotes: ["Praline", "Almond", "Vanilla"], baseNotes: ["Tonka Bean", "Musk", "Sandalwood"], gender: "Unisex"),

        // NASOMATTO (more)
        PerfumeEntry(id: "nasomatto-duro", name: "Duro", brand: "Nasomatto", concentration: "Extrait de Parfum",
                     topNotes: ["Leather"], heartNotes: ["Cedar", "Cypriol"], baseNotes: ["Musk", "Amber", "Woody Notes"], gender: "Men"),
        PerfumeEntry(id: "nasomatto-fantomas", name: "Fantomas", brand: "Nasomatto", concentration: "Extrait de Parfum",
                     topNotes: ["Aldehydes", "Woody Notes"], heartNotes: ["Musk", "Amber"], baseNotes: ["Sandalwood", "Cedar"], gender: "Unisex"),

        // ESCENTRIC MOLECULES (more)
        PerfumeEntry(id: "em-molecule-02", name: "Molecule 02", brand: "Escentric Molecules", concentration: "Eau de Toilette",
                     topNotes: ["Ambroxan"], heartNotes: ["Ambroxan"], baseNotes: ["Ambroxan"], gender: "Unisex"),

        // GIVENCHY (more)
        PerfumeEntry(id: "givenchy-gentleman-society", name: "Gentleman Society", brand: "Givenchy", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Pink Pepper"], heartNotes: ["Iris", "Orris", "Patchouli"], baseNotes: ["Cedar", "Vanilla", "Musk"], gender: "Men"),

        // VALENTINO (more)
        PerfumeEntry(id: "valentino-uomo-born-in-roma-elixir", name: "Uomo Born in Roma Elixir", brand: "Valentino", concentration: "Parfum",
                     topNotes: ["Ginger", "Pink Pepper"], heartNotes: ["Iris", "Tobacco", "Oud"], baseNotes: ["Vanilla", "Benzoin", "Guaiac Wood", "Musk"], gender: "Men"),

        // CLIVE CHRISTIAN (more)
        PerfumeEntry(id: "cc-1872-men", name: "1872", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Petitgrain"], heartNotes: ["Ylang Ylang", "Rose", "Jasmine", "Carnation"], baseNotes: ["Cedar", "Sandalwood", "Vetiver", "Musk"], gender: "Men"),
        PerfumeEntry(id: "cc-1872-women", name: "1872", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Mandarin", "Bergamot", "Petitgrain"], heartNotes: ["Rose", "Jasmine", "Lily of the Valley", "Ylang Ylang"], baseNotes: ["Cedar", "Musk", "Vanilla", "Sandalwood"], gender: "Women"),
        PerfumeEntry(id: "cc-v-men", name: "V", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Bergamot", "Grapefruit", "Mandarin"], heartNotes: ["Orris", "Rose", "Jasmine", "Violet"], baseNotes: ["Sandalwood", "Musk", "Amber", "Vanilla", "Tonka Bean"], gender: "Men"),
        PerfumeEntry(id: "cc-v-women", name: "V", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Mandarin"], heartNotes: ["Rose", "Jasmine", "Tuberose", "Ylang Ylang"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Amber", "Benzoin"], gender: "Women"),
        PerfumeEntry(id: "cc-no1-women", name: "No. 1", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Mandarin", "Bergamot", "Lime", "Plum"], heartNotes: ["Rose", "Jasmine", "Carnation", "Iris", "Ylang Ylang"], baseNotes: ["Sandalwood", "Vanilla", "Musk", "Cedar", "Tonka Bean"], gender: "Women"),
        PerfumeEntry(id: "cc-x-women", name: "X", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Cardamom"], heartNotes: ["Orris", "Rose", "Jasmine", "Carnation", "Ylang Ylang"], baseNotes: ["Sandalwood", "Vanilla", "Musk", "Amber", "Cedar"], gender: "Women"),
        PerfumeEntry(id: "cc-c-men", name: "C", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Lavender"], heartNotes: ["Rose", "Geranium", "Clary Sage"], baseNotes: ["Cedar", "Vetiver", "Musk", "Sandalwood"], gender: "Men"),
        PerfumeEntry(id: "cc-c-women", name: "C", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Rose"], heartNotes: ["Jasmine", "Lily", "Violet", "Ylang Ylang"], baseNotes: ["Musk", "Sandalwood", "Cedar", "Vanilla"], gender: "Women"),
        PerfumeEntry(id: "cc-e-green-fougere", name: "E Green Fougere", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Bergamot", "Lavender", "Basil"], heartNotes: ["Geranium", "Jasmine", "Sage"], baseNotes: ["Vetiver", "Oak Moss", "Musk", "Tonka Bean"], gender: "Men"),
        PerfumeEntry(id: "cc-noble-viii-rococo-immortelle", name: "Noble VIII Rococo Immortelle", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Saffron", "Cardamom", "Bergamot"], heartNotes: ["Immortelle", "Rose", "Jasmine"], baseNotes: ["Vanilla", "Oud", "Sandalwood", "Amber", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "cc-chasing-the-dragon", name: "Chasing the Dragon Hypnotic", brand: "Clive Christian", concentration: "Parfum",
                     topNotes: ["Saffron", "Bergamot", "Cardamom"], heartNotes: ["Oud", "Rose", "Incense"], baseNotes: ["Amber", "Sandalwood", "Musk", "Vanilla", "Leather"], gender: "Unisex"),

        // BJÖRK & BERRIES
        PerfumeEntry(id: "bb-white-forest", name: "White Forest", brand: "Björk & Berries", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Green Leaves"], heartNotes: ["Lily of the Valley", "Violet", "Birch"], baseNotes: ["Musk", "Sandalwood", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "bb-dark-rain", name: "Dark Rain", brand: "Björk & Berries", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Black Pepper", "Cardamom"], heartNotes: ["Violet", "Iris", "Geranium"], baseNotes: ["Vetiver", "Patchouli", "Musk", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "bb-never-spring", name: "Never Spring", brand: "Björk & Berries", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Rose", "Jasmine", "Peony"], baseNotes: ["Musk", "Cedar", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "bb-solstice", name: "Solstice", brand: "Björk & Berries", concentration: "Eau de Parfum",
                     topNotes: ["Cardamom", "Pink Pepper", "Saffron"], heartNotes: ["Rose", "Oud", "Incense"], baseNotes: ["Sandalwood", "Vanilla", "Amber", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "bb-fält", name: "Fält", brand: "Björk & Berries", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Galbanum"], heartNotes: ["Lily of the Valley", "Jasmine", "Green Notes"], baseNotes: ["Musk", "Cedar", "Vetiver"], gender: "Unisex"),
        PerfumeEntry(id: "bb-la-nuit", name: "La Nuit", brand: "Björk & Berries", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper"], heartNotes: ["Tuberose", "Jasmine", "Ylang Ylang"], baseNotes: ["Sandalwood", "Vanilla", "Musk", "Amber"], gender: "Unisex"),

        // INITIO (more)
        PerfumeEntry(id: "initio-psychedelic-love", name: "Psychedelic Love", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Heliotrope", "Rose"], heartNotes: ["Musk", "Myrrh", "Sandalwood"], baseNotes: ["Vanilla", "Cashmeran", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "initio-magnetic-blend-1", name: "Magnetic Blend 1", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Musk", "Amber"], heartNotes: ["Sandalwood", "Agarwood"], baseNotes: ["Vanilla", "Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "initio-magnetic-blend-7", name: "Magnetic Blend 7", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Cinnamon", "Musk"], heartNotes: ["Amber", "Sandalwood", "Tonka Bean"], baseNotes: ["Vanilla", "Benzoin", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "initio-high-frequency", name: "High Frequency", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Pink Pepper"], heartNotes: ["Neroli", "Jasmine", "Violet"], baseNotes: ["Musk", "Sandalwood", "Cedar", "Amber"], gender: "Unisex"),
        PerfumeEntry(id: "initio-narcotic-delight", name: "Narcotic Delight", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Peach", "Raspberry"], heartNotes: ["Rose", "Jasmine", "Heliotrope"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Cashmeran"], gender: "Unisex"),
        PerfumeEntry(id: "initio-parfums-prives-heeley", name: "Oud for Happiness", brand: "Initio", concentration: "Eau de Parfum",
                     topNotes: ["Nutmeg", "Ginger"], heartNotes: ["Oud", "Rose", "Saffron"], baseNotes: ["Vanilla", "Musk", "Amber", "Sandalwood"], gender: "Unisex"),

        // MANCERA (more)
        PerfumeEntry(id: "mancera-wild-fruits", name: "Wild Fruits", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Plum", "Apple", "Raspberry"], heartNotes: ["Rose", "Jasmine", "Patchouli"], baseNotes: ["Vanilla", "Musk", "Amber", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-jardin-exclusif", name: "Jardin Exclusif", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin", "Pink Pepper"], heartNotes: ["Rose", "Jasmine", "Peony"], baseNotes: ["Musk", "Sandalwood", "Vanilla", "Cedar"], gender: "Women"),
        PerfumeEntry(id: "mancera-hindu-kush", name: "Hindu Kush", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Cannabis", "Bergamot", "Lemon"], heartNotes: ["Amber", "Patchouli", "Sandalwood"], baseNotes: ["Musk", "Vanilla", "Cedar", "Benzoin"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-lemon-line", name: "Lemon Line", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Bergamot", "Mandarin"], heartNotes: ["Ginger", "Jasmine", "Rose"], baseNotes: ["Musk", "Amber", "Cedar", "Sandalwood"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-soleil-dItalie", name: "Soleil d'Italie", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Bergamot", "Neroli"], heartNotes: ["Orange Blossom", "Jasmine", "Marine Notes"], baseNotes: ["Musk", "Amber", "Cedar", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-pearl", name: "Pearl", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pear", "Pink Pepper"], heartNotes: ["Jasmine", "Rose", "Peony"], baseNotes: ["Musk", "Sandalwood", "Vanilla", "Amber"], gender: "Women"),
        PerfumeEntry(id: "mancera-black-gold", name: "Black Gold", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Saffron"], heartNotes: ["Oud", "Rose", "Leather"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "mancera-velvet-vanilla", name: "Velvet Vanilla", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Mandarin"], heartNotes: ["Vanilla", "Jasmine", "Rose"], baseNotes: ["Musk", "Sandalwood", "Amber", "Tonka Bean"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-aoud-vanille", name: "Aoud Vanille", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Oud", "Bergamot", "Saffron"], heartNotes: ["Rose", "Jasmine", "Amber"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Tonka Bean"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-midnight-gold", name: "Midnight Gold", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Saffron", "Cardamom"], heartNotes: ["Rose", "Oud", "Incense"], baseNotes: ["Vanilla", "Amber", "Musk", "Sandalwood", "Leather"], gender: "Unisex"),
        PerfumeEntry(id: "mancera-kumkat-wood", name: "Kumkat Wood", brand: "Mancera", concentration: "Eau de Parfum",
                     topNotes: ["Kumquat", "Bergamot", "Lemon"], heartNotes: ["Cedar", "Jasmine", "Sandalwood"], baseNotes: ["Musk", "Amber", "Vanilla"], gender: "Unisex"),

        // VILHELM PARFUMERIE (more)
        PerfumeEntry(id: "vilhelm-poets-of-berlin", name: "Poets of Berlin", brand: "Vilhelm Parfumerie", concentration: "Eau de Parfum",
                     topNotes: ["Bamboo", "Blackcurrant"], heartNotes: ["Rose", "Jasmine", "Violet"], baseNotes: ["Musk", "Sandalwood", "Cashmeran"], gender: "Unisex"),
        PerfumeEntry(id: "vilhelm-morning-chess", name: "Morning Chess", brand: "Vilhelm Parfumerie", concentration: "Eau de Parfum",
                     topNotes: ["Black Pepper", "Bergamot", "Juniper Berries"], heartNotes: ["Frankincense", "Geranium", "Vetiver"], baseNotes: ["Musk", "Sandalwood", "Tonka Bean"], gender: "Unisex"),

        // ACQUA DI PARMA (more)
        PerfumeEntry(id: "adp-quercia", name: "Colonia Quercia", brand: "Acqua di Parma", concentration: "Eau de Cologne",
                     topNotes: ["Bergamot", "White Pepper", "Petitgrain"], heartNotes: ["Cardamom", "Coffee"], baseNotes: ["Vetiver", "Musk", "Guaiac Wood"], gender: "Men"),

        // PENHALIGON'S (more)
        PerfumeEntry(id: "penhaligons-the-tragedy-of-lord-george", name: "The Tragedy of Lord George", brand: "Penhaligon's", concentration: "Eau de Parfum",
                     topNotes: ["Brandy", "Rum", "Bergamot"], heartNotes: ["Tonka Bean", "Cinnamon", "Lavender"], baseNotes: ["Sandalwood", "Musk", "Vanilla", "Cedar"], gender: "Men"),
        PerfumeEntry(id: "penhaligons-the-revenge-of-lady-blanche", name: "The Revenge of Lady Blanche", brand: "Penhaligon's", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Aldehydes"], heartNotes: ["Rose", "Jasmine", "Ylang Ylang"], baseNotes: ["Musk", "Sandalwood", "Amber", "Cedar"], gender: "Women"),

        // FLORIS LONDON (more)
        PerfumeEntry(id: "floris-vert-fougere", name: "Vert Fougère", brand: "Floris London", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lavender", "Thyme"], heartNotes: ["Clary Sage", "Geranium", "Rose"], baseNotes: ["Vetiver", "Oak Moss", "Musk", "Tonka Bean"], gender: "Men"),

        // DIPTYQUE (more)
        PerfumeEntry(id: "diptyque-lombre-dans-leau", name: "L'Ombre dans l'Eau", brand: "Diptyque", concentration: "Eau de Toilette",
                     topNotes: ["Blackcurrant", "Bulgarian Rose", "Green Notes"], heartNotes: ["Rose", "Lychee"], baseNotes: ["Musk", "Cedar", "Amber"], gender: "Unisex"),

        // ETAT LIBRE D'ORANGE (more)
        PerfumeEntry(id: "elo-yes-i-do", name: "Yes I Do", brand: "Etat Libre d'Orange", concentration: "Eau de Parfum",
                     topNotes: ["Blackcurrant", "Bergamot"], heartNotes: ["Lily of the Valley", "Rose", "Jasmine"], baseNotes: ["Musk", "Ambroxan", "Cedar"], gender: "Unisex"),

        // SERGE LUTENS (more)
        PerfumeEntry(id: "lutens-muscs-koublai-khan", name: "Muscs Koublaï Khän", brand: "Serge Lutens", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Cumin"], heartNotes: ["Musk", "Amber", "Civet"], baseNotes: ["Sandalwood", "Vanilla", "Ambergris"], gender: "Unisex"),
        PerfumeEntry(id: "lutens-santal-majuscule", name: "Santal Majuscule", brand: "Serge Lutens", concentration: "Eau de Parfum",
                     topNotes: ["Rose", "Cacao"], heartNotes: ["Sandalwood", "Incense"], baseNotes: ["Vanilla", "Musk", "Amber"], gender: "Unisex"),

        // FRÉDÉRIC MALLE (more)
        PerfumeEntry(id: "malle-french-lover", name: "French Lover", brand: "Frédéric Malle", concentration: "Eau de Parfum",
                     topNotes: ["Galbanum", "Angelica"], heartNotes: ["Iris", "Vetiver", "Incense"], baseNotes: ["Oak Moss", "Musk", "Amber"], gender: "Men"),

        // PARFUMS DE NICOLAI (more)
        PerfumeEntry(id: "nicolai-fig-tea", name: "Fig Tea", brand: "Nicolaï", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Green Tea", "Fig Leaf"], heartNotes: ["Fig", "Coconut", "Rose"], baseNotes: ["Musk", "Cedar", "Sandalwood"], gender: "Unisex"),

        // GALLIVANT (more)
        PerfumeEntry(id: "gallivant-berlin", name: "Berlin", brand: "Gallivant", concentration: "Eau de Parfum",
                     topNotes: ["Grapefruit", "Cardamom", "Pink Pepper"], heartNotes: ["Violet", "Orris", "Cedar"], baseNotes: ["Musk", "Amber", "Vetiver"], gender: "Unisex"),

        // HISTOIRES DE PARFUMS (more)
        PerfumeEntry(id: "hdp-1826", name: "1826 Eugénie de Montijo", brand: "Histoires de Parfums", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Bergamot", "Red Berries"], heartNotes: ["Rose", "Jasmine", "Peony"], baseNotes: ["Musk", "Patchouli", "Sandalwood", "Vanilla"], gender: "Women"),
        PerfumeEntry(id: "hdp-this-is-not-a-blue-bottle", name: "This is Not a Blue Bottle 1.1", brand: "Histoires de Parfums", concentration: "Eau de Parfum",
                     topNotes: ["Neroli", "Bergamot"], heartNotes: ["Orange Blossom", "Jasmine", "Rose"], baseNotes: ["Musk", "Sandalwood", "Amber"], gender: "Unisex"),

        // COMME DES GARÇONS
        PerfumeEntry(id: "cdg-wonderwood", name: "Wonderwood", brand: "Comme des Garçons", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pepper", "Nutmeg"], heartNotes: ["Cedar", "Sandalwood", "Guaiac Wood"], baseNotes: ["Vetiver", "Musk", "Oud"], gender: "Unisex"),
        PerfumeEntry(id: "cdg-amazingreen", name: "Amazingreen", brand: "Comme des Garçons", concentration: "Eau de Parfum",
                     topNotes: ["Green Pepper", "Ivy", "Gunpowder"], heartNotes: ["Coriander", "Nettle", "Silex"], baseNotes: ["Vetiver", "Musk", "Smoke"], gender: "Unisex"),

        // AESOP
        PerfumeEntry(id: "aesop-hwyl", name: "Hwyl", brand: "Aesop", concentration: "Eau de Parfum",
                     topNotes: ["Thyme", "Elemi", "Vetiver"], heartNotes: ["Cypress", "Frankincense", "Guaiac Wood"], baseNotes: ["Smoke", "Musk", "Cedar"], gender: "Unisex"),
        PerfumeEntry(id: "aesop-tacit", name: "Tacit", brand: "Aesop", concentration: "Eau de Parfum",
                     topNotes: ["Yuzu", "Basil Grand Vert"], heartNotes: ["Jasmine", "Clove"], baseNotes: ["Vetiver", "Musk", "Woody Notes"], gender: "Unisex"),
        PerfumeEntry(id: "aesop-rozu", name: "Rōzu", brand: "Aesop", concentration: "Eau de Parfum",
                     topNotes: ["Shiso", "Pink Pepper", "Bergamot"], heartNotes: ["Rose", "Guaiac Wood", "Iris"], baseNotes: ["Vetiver", "Sandalwood", "Musk"], gender: "Unisex"),
        PerfumeEntry(id: "aesop-marrakech-intense", name: "Marrakech Intense", brand: "Aesop", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Cardamom", "Neroli"], heartNotes: ["Rose", "Jasmine", "Clove"], baseNotes: ["Sandalwood", "Cedar", "Musk"], gender: "Unisex"),

        // MORESQUE
        PerfumeEntry(id: "moresque-regina", name: "Regina", brand: "Moresque", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Pink Pepper", "Saffron"], heartNotes: ["Rose", "Jasmine", "Oud"], baseNotes: ["Amber", "Musk", "Sandalwood", "Vanilla"], gender: "Unisex"),
        PerfumeEntry(id: "moresque-fiamma", name: "Fiamma", brand: "Moresque", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Lemon", "Pink Pepper"], heartNotes: ["Jasmine", "Tuberose", "Saffron"], baseNotes: ["Vanilla", "Amber", "Musk", "Sandalwood"], gender: "Unisex"),

        // MAISON TAHITÉ (more)
        PerfumeEntry(id: "tahite-under-the-lemon-tree", name: "Under the Lemon Tree", brand: "Maison Tahité", concentration: "Eau de Parfum",
                     topNotes: ["Lemon", "Bergamot", "Ginger"], heartNotes: ["Jasmine", "Neroli", "Green Tea"], baseNotes: ["Musk", "Cedar", "Amber"], gender: "Unisex"),

        // HOUSE OF OUD (more)
        PerfumeEntry(id: "hoo-almond-harmony", name: "Almond Harmony", brand: "House of Oud", concentration: "Eau de Parfum",
                     topNotes: ["Almond", "Bergamot", "Saffron"], heartNotes: ["Cherry", "Cinnamon", "Rose"], baseNotes: ["Vanilla", "Tonka Bean", "Musk", "Sandalwood"], gender: "Unisex"),

        // LABORATORIO OLFATTIVO (more)
        PerfumeEntry(id: "labolf-vanagloria", name: "Vanagloria", brand: "Laboratorio Olfattivo", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Black Pepper"], heartNotes: ["Oud", "Saffron", "Rose"], baseNotes: ["Amber", "Musk", "Vanilla", "Leather", "Sandalwood"], gender: "Unisex"),

        // VERSACE (more)
        PerfumeEntry(id: "versace-eros-parfum", name: "Eros Parfum", brand: "Versace", concentration: "Parfum",
                     topNotes: ["Mint", "Green Apple", "Bergamot"], heartNotes: ["Ambroxan", "Geranium", "Vanilla"], baseNotes: ["Vetiver", "Cedar", "Tonka Bean", "Leather"], gender: "Men"),

        // GUERLAIN (more)
        PerfumeEntry(id: "guerlain-lhomme-ideal-cool", name: "L'Homme Idéal Cool", brand: "Guerlain", concentration: "Eau de Toilette",
                     topNotes: ["Bitter Almond", "Bergamot", "Lemon"], heartNotes: ["Almond", "Rosemary", "Sage"], baseNotes: ["Vetiver", "Tonka Bean", "Sandalwood"], gender: "Men"),

        // BJÖRK & BERRIES (additional)
        PerfumeEntry(id: "bb-september", name: "September", brand: "Björk & Berries", concentration: "Eau de Parfum",
                     topNotes: ["Pomelo", "Kumquat", "Lavender"], heartNotes: ["Eucalyptus", "Apple Blossom", "Jasmine"], baseNotes: ["Vetiver", "Papyrus", "Guaiac Wood", "Pink Praline"], gender: "Unisex"),

        // ABERCROMBIE & FITCH
        PerfumeEntry(id: "af-fierce", name: "Fierce", brand: "Abercrombie & Fitch", concentration: "Eau de Cologne",
                     topNotes: ["Petitgrain", "Cardamom", "Lemon", "Orange", "Fir Balsam"], heartNotes: ["Jasmine", "Rosemary", "Lily of the Valley", "Rose"], baseNotes: ["Musk", "Vetiver", "Oak Moss", "Sandalwood", "Amber"], gender: "Men"),
        PerfumeEntry(id: "af-fierce-perfume", name: "Fierce", brand: "Abercrombie & Fitch", concentration: "Eau de Parfum",
                     topNotes: ["Petitgrain", "Cardamom", "Lemon", "Orange"], heartNotes: ["Jasmine", "Rosemary", "Rose"], baseNotes: ["Musk", "Vetiver", "Oak Moss", "Sandalwood", "Amber", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "af-first-instinct", name: "First Instinct", brand: "Abercrombie & Fitch", concentration: "Eau de Toilette",
                     topNotes: ["Gin & Tonic Accord", "Kiwano Melon"], heartNotes: ["Sichuan Pepper", "Violet Leaf", "Citrus"], baseNotes: ["Suede", "Musk", "Amber"], gender: "Men"),
        PerfumeEntry(id: "af-first-instinct-extreme", name: "First Instinct Extreme", brand: "Abercrombie & Fitch", concentration: "Eau de Parfum",
                     topNotes: ["Carambola", "Pepper", "Mandarin"], heartNotes: ["Violet Leaf", "Sichuan Pepper"], baseNotes: ["Tonka Bean", "Vanilla", "Musk", "Amber"], gender: "Men"),
        PerfumeEntry(id: "af-first-instinct-for-her", name: "First Instinct for Her", brand: "Abercrombie & Fitch", concentration: "Eau de Parfum",
                     topNotes: ["Passion Fruit", "Red Currant"], heartNotes: ["Orange Blossom", "Magnolia", "Jasmine"], baseNotes: ["Amber", "Musk", "Sandalwood"], gender: "Women"),
        PerfumeEntry(id: "af-authentic-man", name: "Authentic", brand: "Abercrombie & Fitch", concentration: "Eau de Toilette",
                     topNotes: ["Yellow Mandarin", "Bergamot", "Green Apple"], heartNotes: ["Lavender", "Geranium", "Sage"], baseNotes: ["Vetiver", "Sandalwood", "Musk", "Amber"], gender: "Men"),
        PerfumeEntry(id: "af-authentic-woman", name: "Authentic", brand: "Abercrombie & Fitch", concentration: "Eau de Parfum",
                     topNotes: ["Pink Pepper", "Mandarin", "Pear"], heartNotes: ["Rose", "Jasmine", "Orange Blossom"], baseNotes: ["Sandalwood", "Musk", "Cedar", "Cashmeran"], gender: "Women"),
        PerfumeEntry(id: "af-away-man", name: "Away", brand: "Abercrombie & Fitch", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Lemon", "Pink Pepper"], heartNotes: ["Lavender", "Geranium", "Sage"], baseNotes: ["Cedar", "Musk", "Amber", "Vanilla"], gender: "Men"),
        PerfumeEntry(id: "af-away-woman", name: "Away", brand: "Abercrombie & Fitch", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Red Currant", "Pear"], heartNotes: ["Jasmine", "Freesia", "Lily of the Valley"], baseNotes: ["Praline", "Amber", "Musk"], gender: "Women"),
        PerfumeEntry(id: "af-away-tonight-man", name: "Away Tonight", brand: "Abercrombie & Fitch", concentration: "Eau de Toilette",
                     topNotes: ["Bergamot", "Cardamom", "Ginger"], heartNotes: ["Lavender", "Iris", "Violet"], baseNotes: ["Tonka Bean", "Vanilla", "Musk", "Amber"], gender: "Men"),
        PerfumeEntry(id: "af-away-tonight-woman", name: "Away Tonight", brand: "Abercrombie & Fitch", concentration: "Eau de Parfum",
                     topNotes: ["Bergamot", "Raspberry", "Pink Pepper"], heartNotes: ["Rose", "Jasmine", "Peony"], baseNotes: ["Vanilla", "Musk", "Sandalwood", "Amber"], gender: "Women"),
        PerfumeEntry(id: "af-naturally-fierce", name: "Naturally Fierce", brand: "Abercrombie & Fitch", concentration: "Eau de Parfum",
                     topNotes: ["Mandarin", "Bergamot"], heartNotes: ["Rose", "Jasmine", "Orange Blossom"], baseNotes: ["Sandalwood", "Musk", "Amber", "Vanilla"], gender: "Women"),
    ]

    static var brands: [String] {
        Array(Set(entries.map(\.brand))).sorted()
    }

    static func search(query: String) -> [PerfumeEntry] {
        guard !query.isEmpty else { return [] }
        let q = query.lowercased()
        return entries.filter {
            $0.name.lowercased().contains(q) ||
            $0.brand.lowercased().contains(q) ||
            $0.displayName.lowercased().contains(q)
        }
    }

    static func perfumes(forBrand brand: String) -> [PerfumeEntry] {
        entries.filter { $0.brand == brand }
    }
}
