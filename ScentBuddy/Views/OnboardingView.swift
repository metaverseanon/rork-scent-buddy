import SwiftUI

struct OnboardingView: View {
    @State private var currentPage: Int = 0
    @State private var showNotesPicker: Bool = false

    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "drop.fill",
            iconColor: .purple,
            title: "Your Fragrance Companion",
            subtitle: "Track your collection, discover new scents, and build your perfect fragrance wardrobe.",
            gradient: [.purple.opacity(0.3), .indigo.opacity(0.15)]
        ),
        OnboardingPage(
            icon: "sparkles",
            iconColor: .orange,
            title: "Smart Recommendations",
            subtitle: "Get personalized picks based on the notes you love and the fragrances in your collection.",
            gradient: [.orange.opacity(0.3), .pink.opacity(0.15)]
        ),
        OnboardingPage(
            icon: "flame.fill",
            iconColor: .red,
            title: "What's Trending",
            subtitle: "Stay on top of viral fragrances, new releases, and community favorites.",
            gradient: [.red.opacity(0.3), .orange.opacity(0.15)]
        ),
        OnboardingPage(
            icon: "arrow.left.arrow.right",
            iconColor: .blue,
            title: "Compare Side by Side",
            subtitle: "Put two fragrances head-to-head — notes, concentration, season, and more.",
            gradient: [.blue.opacity(0.3), .teal.opacity(0.15)]
        ),
        OnboardingPage(
            icon: "book.fill",
            iconColor: .teal,
            title: "Wear Diary",
            subtitle: "Log what you wear daily, track streaks, and get a scent of the day suggestion.",
            gradient: [.teal.opacity(0.3), .green.opacity(0.15)]
        ),
    ]

    var body: some View {
        VStack(spacing: 0) {
            TabView(selection: $currentPage) {
                ForEach(pages.indices, id: \.self) { index in
                    pageView(pages[index])
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: currentPage)

            bottomSection
        }
        .background(Color(.systemBackground))
        .fullScreenCover(isPresented: $showNotesPicker) {
            NotePreferenceView()
        }
    }

    private func pageView(_ page: OnboardingPage) -> some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(
                        RadialGradient(
                            colors: page.gradient + [.clear],
                            center: .center,
                            startRadius: 20,
                            endRadius: 120
                        )
                    )
                    .frame(width: 240, height: 240)

                Image(systemName: page.icon)
                    .font(.system(size: 64))
                    .foregroundStyle(page.iconColor)
                    .symbolEffect(.pulse, options: .repeating)
            }

            VStack(spacing: 14) {
                Text(page.title)
                    .font(.title.bold())
                    .multilineTextAlignment(.center)

                Text(page.subtitle)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            Spacer()
            Spacer()
        }
    }

    private var bottomSection: some View {
        VStack(spacing: 20) {
            HStack(spacing: 8) {
                ForEach(pages.indices, id: \.self) { index in
                    Capsule()
                        .fill(index == currentPage ? Color.primary : Color.secondary.opacity(0.3))
                        .frame(width: index == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(duration: 0.3), value: currentPage)
                }
            }

            if currentPage == pages.count - 1 {
                Button {
                    showNotesPicker = true
                } label: {
                    Text("Get Started")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.tint)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 16))
                }
                .padding(.horizontal, 24)
            } else {
                HStack {
                    Button {
                        showNotesPicker = true
                    } label: {
                        Text("Skip")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    Button {
                        withAnimation { currentPage += 1 }
                    } label: {
                        HStack(spacing: 6) {
                            Text("Next")
                                .font(.subheadline.bold())
                            Image(systemName: "arrow.right")
                                .font(.caption.bold())
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(.tint)
                        .foregroundStyle(.white)
                        .clipShape(Capsule())
                    }
                }
                .padding(.horizontal, 24)
            }
        }
        .padding(.bottom, 40)
    }
}

private struct OnboardingPage {
    let icon: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let gradient: [Color]
}
