import SwiftUI

struct TasteQuizView: View {
    @State private var viewModel = TasteQuizViewModel()
    @State private var selectedOption: QuizOption?
    @State private var animateIn: Bool = false
    @Environment(\.dismiss) private var dismiss
    private var theme: AppTheme { AppearanceManager.shared.theme }

    let isOnboarding: Bool
    var onComplete: ((TasteProfile) -> Void)?

    init(isOnboarding: Bool = false, onComplete: ((TasteProfile) -> Void)? = nil) {
        self.isOnboarding = isOnboarding
        self.onComplete = onComplete
    }

    var body: some View {
        NavigationStack {
            ZStack {
                theme.backgroundColor.ignoresSafeArea()

                if viewModel.isComplete, let profile = viewModel.generatedProfile {
                    TasteProfileResultView(profile: profile, isOnboarding: isOnboarding) {
                        OnboardingManager.shared.saveTasteProfile(profile)
                        onComplete?(profile)
                        if !isOnboarding {
                            dismiss()
                        }
                    }
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .opacity
                    ))
                } else if let question = viewModel.currentQuestion {
                    questionView(question)
                        .id(question.id)
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))
                }
            }
            .animation(.spring(duration: 0.5, bounce: 0.2), value: viewModel.currentQuestionIndex)
            .animation(.spring(duration: 0.5, bounce: 0.2), value: viewModel.isComplete)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if !viewModel.isComplete {
                    ToolbarItem(placement: .topBarLeading) {
                        if viewModel.canGoBack {
                            Button {
                                withAnimation(.spring(duration: 0.4)) {
                                    viewModel.goBack()
                                }
                            } label: {
                                HStack(spacing: 4) {
                                    Image(systemName: "chevron.left")
                                        .font(.caption.bold())
                                    Text("Back")
                                        .font(.subheadline)
                                }
                            }
                        }
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            if isOnboarding {
                                OnboardingManager.shared.completeOnboarding(with: [])
                            }
                            dismiss()
                        } label: {
                            Text("Skip")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
    }

    private func questionView(_ question: QuizQuestion) -> some View {
        VStack(spacing: 0) {
            progressBar

            ScrollView {
                VStack(spacing: 28) {
                    questionHeader(question)
                    optionsGrid(question)
                }
                .padding(.horizontal)
                .padding(.bottom, 40)
            }
        }
    }

    private var progressBar: some View {
        VStack(spacing: 8) {
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color(.tertiarySystemFill))
                        .frame(height: 6)

                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * viewModel.progress, height: 6)
                        .animation(.spring(duration: 0.5), value: viewModel.progress)
                }
            }
            .frame(height: 6)

            HStack {
                Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.questions.count)")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(Int(viewModel.progress * 100))%")
                    .font(.caption.bold())
                    .foregroundStyle(.orange)
            }
        }
        .padding(.horizontal)
        .padding(.top, 8)
        .padding(.bottom, 4)
    }

    private func questionHeader(_ question: QuizQuestion) -> some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [.orange.opacity(0.3), .pink.opacity(0.15), .clear],
                            center: .center,
                            startRadius: 10,
                            endRadius: 80
                        )
                    )
                    .frame(width: 140, height: 140)

                Image(systemName: question.icon)
                    .font(.system(size: 44))
                    .foregroundStyle(.orange)
                    .symbolEffect(.pulse, options: .repeating.speed(0.6))
            }

            VStack(spacing: 8) {
                Text(question.prompt)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)

                Text(question.subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(.top, 16)
    }

    private func optionsGrid(_ question: QuizQuestion) -> some View {
        VStack(spacing: 12) {
            ForEach(question.options) { option in
                quizOptionCard(option, question: question)
            }
        }
    }

    private func quizOptionCard(_ option: QuizOption, question: QuizQuestion) -> some View {
        let isSelected = viewModel.answers[question.id]?.id == option.id

        return Button {
            withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                selectedOption = option
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                withAnimation(.spring(duration: 0.5, bounce: 0.2)) {
                    viewModel.selectOption(option, for: question)
                    selectedOption = nil
                }
            }
        } label: {
            HStack(spacing: 14) {
                Text(option.emoji)
                    .font(.system(size: 36))
                    .frame(width: 56, height: 56)
                    .background(
                        isSelected || selectedOption?.id == option.id
                            ? Color.orange.opacity(0.15)
                            : theme.chipColor
                    )
                    .clipShape(.rect(cornerRadius: 14))

                VStack(alignment: .leading, spacing: 4) {
                    Text(option.title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)

                    Text(option.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }

                Spacer()

                if isSelected || selectedOption?.id == option.id {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(14)
            .background(
                isSelected || selectedOption?.id == option.id
                    ? Color.orange.opacity(0.08)
                    : theme.cardColor
            )
            .clipShape(.rect(cornerRadius: 18))
            .overlay {
                if isSelected || selectedOption?.id == option.id {
                    RoundedRectangle(cornerRadius: 18)
                        .strokeBorder(.orange.opacity(0.4), lineWidth: 1.5)
                }
            }
        }
        .buttonStyle(QuizOptionButtonStyle())
        .sensoryFeedback(.impact(weight: .medium), trigger: selectedOption?.id)
    }
}

private struct QuizOptionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(duration: 0.25, bounce: 0.4), value: configuration.isPressed)
    }
}
