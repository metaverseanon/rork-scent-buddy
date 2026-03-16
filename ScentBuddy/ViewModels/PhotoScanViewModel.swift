import SwiftUI
import Vision

@Observable
class PhotoScanViewModel {
    var recognizedTexts: [String] = []
    var matchedPerfumes: [PerfumeEntry] = []
    var isProcessing: Bool = false
    var isSearching: Bool = false
    var searchStatus: String = ""

    private let fragellaService = FragellaAPIService()

    func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        isProcessing = true
        recognizedTexts = []
        matchedPerfumes = []
        searchStatus = "Analyzing image..."

        Task.detached(priority: .userInitiated) {
            let request = VNRecognizeTextRequest()
            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try? handler.perform([request])

            let observations = request.results ?? []
            let texts = observations.compactMap { $0.topCandidates(1).first?.string }

            await MainActor.run { [weak self] in
                self?.handleRecognizedTexts(texts)
            }
        }
    }

    private func handleRecognizedTexts(_ texts: [String]) {
        let filtered = texts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 1 }

        recognizedTexts = Array(Set(filtered)).sorted()
        isProcessing = false

        guard !recognizedTexts.isEmpty else {
            searchStatus = ""
            return
        }

        Task {
            await searchFragella()
        }
    }

    private func searchFragella() async {
        guard fragellaService.isConfigured else {
            searchStatus = "Search API not configured"
            return
        }

        isSearching = true
        searchStatus = "Searching fragrances..."
        matchedPerfumes = []

        let queries = buildSearchQueries()

        var allResults: [PerfumeEntry] = []
        var seenIds: Set<String> = []

        for query in queries.prefix(4) {
            guard query.count >= 3 else { continue }
            await fragellaService.search(query: query, limit: 5)
            for fragrance in fragellaService.searchResults {
                let entry = PerfumeEntry(
                    id: fragrance.id,
                    name: fragrance.name,
                    brand: fragrance.brand,
                    concentration: fragrance.concentration,
                    topNotes: fragrance.topNotes,
                    heartNotes: fragrance.heartNotes,
                    baseNotes: fragrance.baseNotes,
                    gender: ""
                )
                if !seenIds.contains(entry.id) {
                    seenIds.insert(entry.id)
                    allResults.append(entry)
                }
            }
        }

        matchedPerfumes = Array(allResults.prefix(10))
        isSearching = false

        if matchedPerfumes.isEmpty {
            searchStatus = "No matches found. Try a clearer photo."
        } else {
            searchStatus = "Found \(matchedPerfumes.count) possible match\(matchedPerfumes.count == 1 ? "" : "es")"
        }
    }

    private func buildSearchQueries() -> [String] {
        var queries: [String] = []

        let combined = recognizedTexts.joined(separator: " ")
        if combined.count >= 3 {
            queries.append(combined)
        }

        let longerTexts = recognizedTexts
            .filter { $0.count >= 3 }
            .sorted { $0.count > $1.count }

        for text in longerTexts.prefix(3) {
            if !queries.contains(text) {
                queries.append(text)
            }
        }

        if recognizedTexts.count >= 2 {
            let pair = "\(recognizedTexts[0]) \(recognizedTexts[1])"
            if pair.count >= 3 && !queries.contains(pair) {
                queries.append(pair)
            }
        }

        return queries
    }

    func searchWithText(_ text: String) async {
        guard fragellaService.isConfigured, text.count >= 3 else { return }
        isSearching = true
        searchStatus = "Searching for \"\(text)\"..."

        await fragellaService.search(query: text, limit: 10)

        matchedPerfumes = fragellaService.searchResults.map { fragrance in
            PerfumeEntry(
                id: fragrance.id,
                name: fragrance.name,
                brand: fragrance.brand,
                concentration: fragrance.concentration,
                topNotes: fragrance.topNotes,
                heartNotes: fragrance.heartNotes,
                baseNotes: fragrance.baseNotes,
                gender: ""
            )
        }

        isSearching = false
        if matchedPerfumes.isEmpty {
            searchStatus = "No matches for \"\(text)\""
        } else {
            searchStatus = "Found \(matchedPerfumes.count) match\(matchedPerfumes.count == 1 ? "" : "es")"
        }
    }

    func clearResults() {
        recognizedTexts = []
        matchedPerfumes = []
        searchStatus = ""
    }
}
