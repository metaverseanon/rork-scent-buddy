import SwiftUI

struct ChangeEmailView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var newEmail: String = ""
    @State private var isLoading: Bool = false
    @State private var isSent: Bool = false
    @State private var errorMessage: String?

    @FocusState private var emailFocused: Bool

    let currentEmail: String

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 10)

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.blue.opacity(0.3), .cyan.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: isSent ? "checkmark.circle.fill" : "envelope.badge.fill")
                                .font(.system(size: 32))
                                .foregroundStyle(isSent ? .green : .blue)
                                .contentTransition(.symbolEffect(.replace))
                        }

                        Text(isSent ? "Confirmation Sent" : "Change Email")
                            .font(.title3.bold())

                        Text(isSent
                             ? "Check both **\(currentEmail)** and **\(newEmail)** for confirmation links."
                             : "Current email: **\(currentEmail)**")
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
                                Text("New Email Address")
                                    .font(.subheadline.bold())
                                HStack(spacing: 10) {
                                    Image(systemName: "envelope.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                    TextField("New email address", text: $newEmail)
                                        .textContentType(.emailAddress)
                                        .keyboardType(.emailAddress)
                                        .textInputAutocapitalization(.never)
                                        .autocorrectionDisabled()
                                        .focused($emailFocused)
                                        .submitLabel(.go)
                                        .onSubmit { changeEmail() }
                                }
                                .padding(12)
                                .background(AppearanceManager.shared.theme.cardColor)
                                .clipShape(.rect(cornerRadius: 12))
                            }

                            Button {
                                changeEmail()
                            } label: {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "arrow.right.circle.fill")
                                    }
                                    Text(isLoading ? "Updating..." : "Update Email")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.tint)
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 14))
                            }
                            .disabled(!isEmailValid || isLoading)
                            .opacity(isEmailValid && !isLoading ? 1 : 0.6)
                        }
                        .padding(.horizontal)
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.tint)
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 14))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .background(AppearanceManager.shared.theme.backgroundColor)
            .navigationTitle("Change Email")
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
        newEmail.contains("@") && newEmail.contains(".") && newEmail.lowercased() != currentEmail.lowercased()
    }

    private func changeEmail() {
        guard isEmailValid else { return }
        emailFocused = false
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await SupabaseService.shared.updateEmail(newEmail: newEmail.trimmingCharacters(in: .whitespaces).lowercased())
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
