import SwiftUI

struct MagicLinkView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var isLoading: Bool = false
    @State private var isSent: Bool = false
    @State private var errorMessage: String?

    @FocusState private var emailFocused: Bool

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 32) {
                    Spacer().frame(height: 20)

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple.opacity(0.3), .blue.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Image(systemName: isSent ? "checkmark.circle.fill" : "link.circle.fill")
                                .font(.system(size: 40))
                                .foregroundStyle(isSent ? .green : .purple)
                                .contentTransition(.symbolEffect(.replace))
                        }

                        Text(isSent ? "Check Your Email" : "Magic Link")
                            .font(.title2.bold())

                        Text(isSent
                             ? "We've sent a sign-in link to **\(email)**. Tap the link in your email to sign in instantly."
                             : "Enter your email and we'll send you a one-time link to sign in — no password needed.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    if !isSent {
                        VStack(spacing: 20) {
                            if let error = errorMessage {
                                HStack(spacing: 8) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundStyle(.red)
                                    Text(error)
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                }
                                .padding(12)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.red.opacity(0.08))
                                .clipShape(.rect(cornerRadius: 10))
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Email Address")
                                    .font(.subheadline.bold())
                                HStack(spacing: 10) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                    TextField("Email address", text: $email)
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .focused($emailFocused)
                                        .submitLabel(.go)
                                        .onSubmit { sendMagicLink() }
                                }
                                .padding(12)
                                .background(AppearanceManager.shared.theme.cardColor)
                                .clipShape(.rect(cornerRadius: 12))
                            }

                            Button {
                                sendMagicLink()
                            } label: {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "wand.and.stars")
                                    }
                                    Text(isLoading ? "Sending..." : "Send Magic Link")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.purple)
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 14))
                            }
                            .disabled(!isEmailValid || isLoading)
                            .opacity(isEmailValid && !isLoading ? 1 : 0.6)
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 12) {
                            Button {
                                withAnimation(.spring(duration: 0.3)) {
                                    isSent = false
                                }
                            } label: {
                                Text("Resend Link")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(.purple)
                                    .foregroundStyle(.white)
                                    .clipShape(.rect(cornerRadius: 14))
                            }

                            Button {
                                dismiss()
                            } label: {
                                Text("Back to Sign In")
                                    .fontWeight(.semibold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(Color(.secondarySystemGroupedBackground))
                                    .foregroundStyle(.primary)
                                    .clipShape(.rect(cornerRadius: 14))
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .background(AppearanceManager.shared.theme.backgroundColor)
            .navigationTitle("Magic Link")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isLoading)
                }
            }
        }
    }

    private var isEmailValid: Bool {
        email.contains("@") && email.contains(".")
    }

    private func sendMagicLink() {
        guard isEmailValid else { return }
        emailFocused = false
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await SupabaseService.shared.sendMagicLink(email: email.trimmingCharacters(in: .whitespaces).lowercased())
                withAnimation(.spring(duration: 0.5)) {
                    isSent = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
