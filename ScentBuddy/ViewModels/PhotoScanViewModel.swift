import SwiftUI
import Vision

@Observable
class PhotoScanViewModel {
    var recognizedTexts: [String] = []
    var matchedPerfumes: [PerfumeEntry] = []
    var isProcessing: Bool = false

    func processImage(_ image: UIImage) {
        guard let cgImage = image.cgImage else { return }
        isProcessing = true
        recognizedTexts = []
        matchedPerfumes = []

        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
            let texts = observations.compactMap { $0.topCandidates(1).first?.string }
            Task { @MainActor in
                self?.handleRecognizedTexts(texts)
            }
        }
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            try? handler.perform([request])
        }
    }

    private func handleRecognizedTexts(_ texts: [String]) {
        let filtered = texts
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && $0.count > 1 }

        recognizedTexts = Array(Set(filtered)).sorted()

        let combined = filtered.joined(separator: " ").lowercased()

        var matches: [PerfumeEntry] = []
        for entry in PerfumeDatabase.entries {
            let nameMatch = combined.contains(entry.name.lowercased())
            let brandMatch = combined.contains(entry.brand.lowercased())

            if nameMatch && brandMatch {
                matches.append(entry)
            } else if nameMatch {
                let nameWords = entry.name.lowercased().split(separator: " ")
                if nameWords.count >= 2 || brandMatch {
                    matches.append(entry)
                }
            }
        }

        if matches.isEmpty {
            for text in filtered {
                let results = PerfumeDatabase.search(query: text)
                for result in results.prefix(3) {
                    if !matches.contains(where: { $0.id == result.id }) {
                        matches.append(result)
                    }
                }
            }
        }

        matchedPerfumes = Array(matches.prefix(8))
        isProcessing = false
    }

    func clearResults() {
        recognizedTexts = []
        matchedPerfumes = []
    }
}
