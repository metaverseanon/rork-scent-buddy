import SwiftUI

@Observable
final class TasteQuizViewModel {
    var currentQuestionIndex: Int = 0
    var answers: [String: QuizOption] = [:]
    var isComplete: Bool = false
    var generatedProfile: TasteProfile?

    let questions = TasteQuizData.questions

    var currentQuestion: QuizQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        Double(currentQuestionIndex) / Double(questions.count)
    }

    var canGoBack: Bool {
        currentQuestionIndex > 0
    }

    func selectOption(_ option: QuizOption, for question: QuizQuestion) {
        answers[question.id] = option

        if currentQuestionIndex < questions.count - 1 {
            currentQuestionIndex += 1
        } else {
            generatedProfile = buildProfile()
            isComplete = true
        }
    }

    func goBack() {
        guard canGoBack else { return }
        currentQuestionIndex -= 1
    }

    func reset() {
        currentQuestionIndex = 0
        answers = [:]
        isComplete = false
        generatedProfile = nil
    }

    private func buildProfile() -> TasteProfile {
        var noteCounts: [String: Int] = [:]
        var familyCounts: [String: Int] = [:]
        var allTraits: [String] = []
        var quizAnswerMap: [String: String] = [:]

        for (questionId, option) in answers {
            quizAnswerMap[questionId] = option.id
            familyCounts[option.family, default: 0] += 1
            allTraits.append(contentsOf: option.traits)
            for note in option.associatedNotes {
                noteCounts[note, default: 0] += 1
            }
        }

        let topFamily = familyCounts.max(by: { $0.value < $1.value })?.key ?? "Fresh"

        var traitCounts: [String: Int] = [:]
        for trait in allTraits {
            traitCounts[trait, default: 0] += 1
        }
        let topTraits = traitCounts.sorted { $0.value > $1.value }.prefix(4).map { $0.key }

        let topNotes = noteCounts.sorted { $0.value > $1.value }.prefix(12).map { $0.key }

        let profileInfo = TasteQuizData.profileMap[topFamily] ?? (name: "The Explorer", emoji: "🧭")

        return TasteProfile(
            scentFamily: topFamily,
            topTraits: topTraits,
            preferredNotes: topNotes,
            quizAnswers: quizAnswerMap,
            profileName: profileInfo.name,
            profileEmoji: profileInfo.emoji,
            completedAt: Date()
        )
    }
}
