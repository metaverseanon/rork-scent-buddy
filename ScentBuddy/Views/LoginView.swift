import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    private var authService: SupabaseAuthService { SupabaseAuthService.shared }

    @State private var email: String = ""
    @State private var password: String = ""
    @State private var showPassword: Bool = false

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
                        Text("Sign in to your ScentBuddy account")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email Address")
                                .font(.subheadline.bold())
                            HStack(spacing: 10) {
                                Image(systemName: "envelope.fill")
                                    .foregroundStyle(.secondary)
                                    .font(.subheadline)
                                TextField("you@example.com", text: $email)
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
                                if showPassword {
                                    TextField("Enter password", text: $password)
                                        .textContentType(.password)
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.go)
                                        .onSubmit { signIn() }
                                } else {
                                    SecureField("Enter password", text: $password)
                                        .textContentType(.password)
                                        .focused($focusedField, equals: .password)
                                        .submitLabel(.go)
                                        .onSubmit { signIn() }
                                }
                                Button {
                                    showPassword.toggle()
                                } label: {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundStyle(.tertiary)
                                        .font(.subheadline)
                                }
                            }
                            .padding(12)
                            .background(AppearanceManager.shared.theme.cardColor)
                            .clipShape(.rect(cornerRadius: 12))
                        }

                        if let error = authService.errorMessage {
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption)
                                Text(error)
                                    .font(.caption)
                            }
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }

                        Button {
                            signIn()
                        } label: {
                            HStack(spacing: 8) {
                                if authService.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                        .controlSize(.small)
                                } else {
                                    Image(systemName: "arrow.right.circle.fill")
                                    Text("Sign In")
                                        .fontWeight(.semibold)
                                }
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.tint)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .disabled(!isFormValid || authService.isLoading)
                        .opacity(isFormValid ? 1 : 0.6)
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
                }
            }
        }
    }

    private var isFormValid: Bool {
        !email.trimmingCharacters(in: .whitespaces).isEmpty && password.count >= 6
    }

    private func signIn() {
        guard isFormValid else { return }
        focusedField = nil

        Task {
            let success = await authService.signIn(
                email: email.trimmingCharacters(in: .whitespaces).lowercased(),
                password: password
            )
            if success {
                dismiss()
            }
        }
    }
}
