import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var profileManager = UserProfileManager.shared

    @FocusState private var focusedField: Field?

    nonisolated private enum Field: Hashable {
        case email, password
    }

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
                                        colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)

                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 48))
                                .foregroundStyle(.purple)
                        }

                        Text("Welcome Back")
                            .font(.title2.bold())
                        Text("Sign in with your email and password")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 20) {
                        if let error = profileManager.errorMessage {
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
                                    .focused($focusedField, equals: .email)
                                    .submitLabel(.next)
                                    .onSubmit { focusedField = .password }
                            }
                            .padding(12)
                            .background(AppearanceManager.shared.theme.cardColor)
                            .clipShape(.rect(cornerRadius: 12))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.subheadline.bold())
                            HStack(spacing: 10) {
                                Image(systemName: "lock.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                SecureField("Your password", text: $password)
                                    .textContentType(.password)
                                    .focused($focusedField, equals: .password)
                                    .submitLabel(.go)
                                    .onSubmit { signIn() }
                            }
                            .padding(12)
                            .background(AppearanceManager.shared.theme.cardColor)
                            .clipShape(.rect(cornerRadius: 12))
                        }

                        Button {
                            signIn()
                        } label: {
                            HStack(spacing: 8) {
                                if profileManager.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                }
                                Text(profileManager.isLoading ? "Signing In..." : "Sign In")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.tint)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .disabled(!isFormValid || profileManager.isLoading)
                        .opacity(isFormValid && !profileManager.isLoading ? 1 : 0.6)
                    }
                    .padding(.horizontal)
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .background(AppearanceManager.shared.theme.backgroundColor)
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(profileManager.isLoading)
                }
            }
            .interactiveDismissDisabled(profileManager.isLoading)
        }
    }

    private var isFormValid: Bool {
        email.contains("@") && email.contains(".") && password.count >= 6
    }

    private func signIn() {
        guard isFormValid else { return }
        focusedField = nil

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        Task {
            let success = await profileManager.signIn(email: trimmedEmail, password: password)
            if success {
                dismiss()
            }
        }
    }
}
