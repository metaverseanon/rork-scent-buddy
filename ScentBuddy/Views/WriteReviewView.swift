import SwiftUI

struct WriteReviewView: View {
    let perfumeName: String
    let perfumeBrand: String
    @Environment(\.dismiss) private var dismiss
    @State private var rating: Int = 0
    @State private var reviewText: String = ""
    @State private var longevity: Int = 5
    @State private var sillage: Int = 5
    @State private var valueForMoney: Int = 5
    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?

    private let supabase = SupabaseService.shared

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(perfumeName)
                            .font(.headline)
                        Text(perfumeBrand)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("Overall Rating") {
                    HStack(spacing: 12) {
                        Spacer()
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                withAnimation(.snappy) { rating = star }
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title)
                                    .foregroundStyle(star <= rating ? .orange : .gray.opacity(0.3))
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                    }
                }

                Section("Your Review") {
                    TextField("What do you think about this fragrance?", text: $reviewText, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section("Performance") {
                    sliderRow(title: "Longevity", value: $longevity, icon: "clock")
                    sliderRow(title: "Sillage", value: $sillage, icon: "wind")
                    sliderRow(title: "Value for Money", value: $valueForMoney, icon: "dollarsign.circle")
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle("Write Review")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Post") { Task { await submitReview() } }
                        .fontWeight(.semibold)
                        .disabled(rating == 0 || isSubmitting)
                }
            }
        }
    }

    private func sliderRow(title: String, value: Binding<Int>, icon: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.subheadline)
                Spacer()
                Text("\(value.wrappedValue)/10")
                    .font(.subheadline.bold())
                    .foregroundStyle(.tint)
                    .monospacedDigit()
            }
            Slider(value: Binding(
                get: { Double(value.wrappedValue) },
                set: { value.wrappedValue = Int($0) }
            ), in: 1...10, step: 1)
            .tint(.accentColor)
        }
    }

    private func submitReview() async {
        guard let userId = supabase.currentUserId else {
            errorMessage = "You must be signed in to write a review."
            return
        }
        isSubmitting = true
        errorMessage = nil

        await supabase.refreshTokenIfNeeded()

        let review = PerfumeReviewInsert(
            user_id: userId,
            perfume_name: perfumeName,
            perfume_brand: perfumeBrand,
            rating: rating,
            review_text: reviewText.trimmingCharacters(in: .whitespaces),
            longevity: longevity,
            sillage: sillage,
            value_for_money: valueForMoney
        )

        do {
            try await supabase.insertReview(review)
            try? await supabase.insertActivity(ActivityFeedInsert(
                user_id: userId,
                activity_type: "wrote_review",
                perfume_name: perfumeName,
                perfume_brand: perfumeBrand,
                target_user_id: nil
            ))
            dismiss()
        } catch {
            errorMessage = error.localizedDescription
            isSubmitting = false
        }
    }
}
