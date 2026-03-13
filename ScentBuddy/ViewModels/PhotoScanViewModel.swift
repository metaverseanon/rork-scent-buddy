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
        matchedPerfumes = []
        isProcessing = false
    }

    func clearResults() {
        recognizedTexts = []
        matchedPerfumes = []
    }
}
