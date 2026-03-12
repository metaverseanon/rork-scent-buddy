import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var email: String = ""

    @FocusState private var focusedField: Field?

    nonisolated private enum Field: Hashable {
        case displayName, email
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
                        Text("Enter your name to restore your profile")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    VStack(spacing: 20) {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Display Name")
                                .font(.subheadline.bold())
                            TextField("Your name", text: $displayName)
                                .textContentType(.name)
                                .focused($focusedField, equals: .displayName)
                                .submitLabel(.next)
                                .onSubmit { focusedField = .email }
                                .padding(12)
                                .background(AppearanceManager.shared.theme.cardColor)
                                .clipShape(.rect(cornerRadius: 12))
                        }

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
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(.tint)
                            .foregroundStyle(.white)
                            .clipShape(.rect(cornerRadius: 14))
                        }
                        .disabled(!isFormValid)
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
        !displayName.trimmingCharacters(in: .whitespaces).isEmpty
    }

    private func signIn() {
        guard isFormValid else { return }
        focusedField = nil

        UserProfileManager.shared.profile = UserProfile(
            displayName: displayName.trimmingCharacters(in: .whitespaces),
            username: "",
            email: email.trimmingCharacters(in: .whitespaces).lowercased(),
            bio: "",
            favoriteNote: "",
            memberSince: Date(),
            avatarEmoji: "🧴"
        )
        dismiss()
    }
}
