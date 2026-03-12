import SwiftUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss
    private var authService: SupabaseAuthService { SupabaseAuthService.shared }

    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var favoriteNote: String = ""
    @State private var selectedEmoji: String = "🧴"
    @State private var showPassword: Bool = false
    @State private var emailError: String = ""
    @State private var passwordError: String = ""
    private var usernameService: UsernameService { UsernameService.shared }
    @State private var isCreating: Bool = false

    @FocusState private var focusedField: Field?

    private let emojiOptions = ["🧴", "💐", "🌸", "🌿", "🔥", "✨", "🖤", "💎", "🌙", "🍊", "🫧", "🪻"]

    nonisolated private enum Field: Hashable {
        case displayName, email, password, confirmPassword, username, bio, favoriteNote
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    avatarSection
                    formSection

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
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .background(AppearanceManager.shared.theme.backgroundColor)
            .navigationTitle("Create Account")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") { createAccount() }
                        .fontWeight(.semibold)
                        .disabled(!isFormValid || isCreating)
                }
            }
        }
    }

    private var avatarSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.25), .pink.opacity(0.15)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Text(selectedEmoji)
                    .font(.system(size: 48))
            }

            Text("Choose Your Avatar")
                .font(.caption)
                .foregroundStyle(.secondary)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
                ForEach(emojiOptions, id: \.self) { emoji in
                    Button {
                        withAnimation(.snappy) { selectedEmoji = emoji }
                    } label: {
                        Text(emoji)
                            .font(.title2)
                            .frame(width: 44, height: 44)
                            .background(
                                selectedEmoji == emoji
                                    ? AnyShapeStyle(.tint.opacity(0.15))
                                    : AnyShapeStyle(AppearanceManager.shared.theme.chipColor)
                            )
                            .clipShape(.rect(cornerRadius: 12))
                            .overlay {
                                if selectedEmoji == emoji {
                                    RoundedRectangle(cornerRadius: 12)
                                        .strokeBorder(.tint, lineWidth: 2)
                                }
                            }
                    }
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private var formSection: some View {
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
                        .submitLabel(.next)
                        .onSubmit { focusedField = .password }
                }
                .padding(12)
                .background(AppearanceManager.shared.theme.cardColor)
                .clipShape(.rect(cornerRadius: 12))

                if !emailError.isEmpty {
                    Text(emailError)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }
            .onChange(of: email) { _, _ in emailError = "" }

            VStack(alignment: .leading, spacing: 6) {
                Text("Password")
                    .font(.subheadline.bold())
                HStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    if showPassword {
                        TextField("Min. 6 characters", text: $password)
                            .textContentType(.newPassword)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .confirmPassword }
                    } else {
                        SecureField("Min. 6 characters", text: $password)
                            .textContentType(.newPassword)
                            .focused($focusedField, equals: .password)
                            .submitLabel(.next)
                            .onSubmit { focusedField = .confirmPassword }
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

            VStack(alignment: .leading, spacing: 6) {
                Text("Confirm Password")
                    .font(.subheadline.bold())
                HStack(spacing: 10) {
                    Image(systemName: "lock.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                    SecureField("Re-enter password", text: $confirmPassword)
                        .textContentType(.newPassword)
                        .focused($focusedField, equals: .confirmPassword)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .username }
                }
                .padding(12)
                .background(AppearanceManager.shared.theme.cardColor)
                .clipShape(.rect(cornerRadius: 12))

                if !passwordError.isEmpty {
                    Text(passwordError)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                }
            }
            .onChange(of: confirmPassword) { _, _ in passwordError = "" }

            Divider()
                .padding(.vertical, 4)

            VStack(alignment: .leading, spacing: 6) {
                Text("Username")
                    .font(.subheadline.bold())
                HStack(spacing: 0) {
                    Text("@")
                        .foregroundStyle(.secondary)
                    TextField("username", text: $username)
                        .textContentType(.username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .username)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .bio }
                    Spacer()
                    if usernameService.isChecking {
                        ProgressView()
                            .controlSize(.small)
                    } else if let available = usernameService.isAvailable {
                        Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(available ? .green : .red)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(12)
                .background(AppearanceManager.shared.theme.cardColor)
                .clipShape(.rect(cornerRadius: 12))
                .overlay {
                    if let available = usernameService.isAvailable, !username.trimmingCharacters(in: .whitespaces).isEmpty {
                        RoundedRectangle(cornerRadius: 12)
                            .strokeBorder(available ? .green.opacity(0.5) : .red.opacity(0.5), lineWidth: 1.5)
                    }
                }

                if let error = usernameService.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .transition(.opacity)
                } else if usernameService.isAvailable == true {
                    Text("Username is available!")
                        .font(.caption)
                        .foregroundStyle(.green)
                        .transition(.opacity)
                }
            }
            .onChange(of: username) { _, newValue in
                withAnimation(.easeInOut(duration: 0.2)) {
                    usernameService.checkUsername(newValue)
                }
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Bio")
                    .font(.subheadline.bold())
                TextField("Tell us about your scent journey...", text: $bio, axis: .vertical)
                    .lineLimit(2...4)
                    .focused($focusedField, equals: .bio)
                    .submitLabel(.next)
                    .padding(12)
                    .background(AppearanceManager.shared.theme.cardColor)
                    .clipShape(.rect(cornerRadius: 12))
            }

            VStack(alignment: .leading, spacing: 6) {
                Text("Favorite Note")
                    .font(.subheadline.bold())
                TextField("e.g. Oud, Vanilla, Bergamot", text: $favoriteNote)
                    .focused($focusedField, equals: .favoriteNote)
                    .submitLabel(.done)
                    .onSubmit { focusedField = nil }
                    .padding(12)
                    .background(AppearanceManager.shared.theme.cardColor)
                    .clipShape(.rect(cornerRadius: 12))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(["Oud", "Vanilla", "Bergamot", "Rose", "Sandalwood", "Amber", "Musk"], id: \.self) { note in
                            Button {
                                favoriteNote = note
                            } label: {
                                Text(note)
                                    .font(.caption)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 6)
                                    .background(favoriteNote == note ? AnyShapeStyle(.tint) : AnyShapeStyle(AppearanceManager.shared.theme.chipColor))
                                    .foregroundStyle(favoriteNote == note ? .white : .primary)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                }
                .contentMargins(.horizontal, 0)
            }
        }
    }

    private var isFormValid: Bool {
        let trimmedName = displayName.trimmingCharacters(in: .whitespaces)
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let usernameOk = trimmedUsername.isEmpty || usernameService.isAvailable == true
        return !trimmedName.isEmpty && !trimmedEmail.isEmpty && password.count >= 6 && password == confirmPassword && usernameOk
    }

    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }

    private func createAccount() {
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()

        guard isValidEmail(trimmedEmail) else {
            withAnimation { emailError = "Please enter a valid email address" }
            return
        }

        guard password.count >= 6 else {
            withAnimation { passwordError = "Password must be at least 6 characters" }
            return
        }

        guard password == confirmPassword else {
            withAnimation { passwordError = "Passwords do not match" }
            return
        }

        let trimmedUsername = username.trimmingCharacters(in: .whitespaces).lowercased()
        isCreating = true
        focusedField = nil

        Task {
            if !trimmedUsername.isEmpty {
                _ = await usernameService.registerUsername(trimmedUsername)
            }

            let success = await authService.signUp(
                email: trimmedEmail,
                password: password,
                displayName: displayName.trimmingCharacters(in: .whitespaces),
                username: trimmedUsername,
                bio: bio.trimmingCharacters(in: .whitespaces),
                favoriteNote: favoriteNote.trimmingCharacters(in: .whitespaces),
                avatarEmoji: selectedEmoji
            )

            if success {
                UserProfileManager.shared.profile = UserProfile(
                    displayName: displayName.trimmingCharacters(in: .whitespaces),
                    username: trimmedUsername,
                    email: trimmedEmail,
                    bio: bio.trimmingCharacters(in: .whitespaces),
                    favoriteNote: favoriteNote.trimmingCharacters(in: .whitespaces),
                    memberSince: Date(),
                    avatarEmoji: selectedEmoji
                )
                dismiss()
            }

            isCreating = false
        }
    }
}
