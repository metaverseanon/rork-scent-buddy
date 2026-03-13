import SwiftUI
import PhotosUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var favoriteNote: String = ""
    @State private var selectedEmoji: String = "drop.fill"
    @State private var avatarMode: AvatarMode = .emoji
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var avatarImageData: Data?
    @State private var showingImageSourcePicker: Bool = false
    @State private var showPassword: Bool = false
    @State private var showConfirmPassword: Bool = false
    @State private var usernameService = UsernameService.shared
    @State private var profileManager = UserProfileManager.shared

    @FocusState private var focusedField: Field?

    private let iconOptions = ["drop.fill", "flame.fill", "star.fill", "moon.fill", "leaf.fill", "heart.fill", "sparkles", "crown.fill", "bolt.fill", "cloud.fill", "wind", "eye.fill"]

    nonisolated private enum Field: Hashable {
        case displayName, email, password, confirmPassword, username, bio, favoriteNote
    }

    nonisolated private enum AvatarMode {
        case emoji, photo
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    avatarSection
                    formSection
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .background(AppearanceManager.shared.theme.backgroundColor)
            .navigationTitle("Create Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(profileManager.isLoading)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if profileManager.isLoading {
                        ProgressView()
                    } else {
                        Button("Save") { createProfile() }
                            .fontWeight(.semibold)
                            .disabled(!canSave)
                    }
                }
            }
            .interactiveDismissDisabled(profileManager.isLoading)
        }
    }

    private var canSave: Bool {
        let nameValid = !displayName.trimmingCharacters(in: .whitespaces).isEmpty
        let emailValid = email.contains("@") && email.contains(".")
        let passwordValid = password.count >= 6
        let passwordsMatch = password == confirmPassword
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces)
        let usernameValid = trimmedUsername.count < 3 || (usernameService.isAvailable != false && !usernameService.isChecking)
        return nameValid && emailValid && passwordValid && passwordsMatch && usernameValid && !profileManager.isLoading
    }

    private var avatarCircle: some View {
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

            if avatarMode == .photo, let data = avatarImageData, let uiImage = UIImage(data: data) {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            } else {
                Image(systemName: selectedEmoji)
                    .font(.system(size: 32))
                    .foregroundStyle(.white)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            Button {
                showingImageSourcePicker = true
            } label: {
                Image(systemName: "camera.fill")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(6)
                    .background(.tint)
                    .clipShape(Circle())
            }
        }
    }

    private var avatarModePicker: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation(.snappy) { avatarMode = .emoji }
            } label: {
                Text("Emoji")
                    .font(.caption.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(avatarMode == .emoji ? AnyShapeStyle(.tint) : AnyShapeStyle(AppearanceManager.shared.theme.chipColor))
                    .foregroundStyle(avatarMode == .emoji ? .white : .primary)
                    .clipShape(Capsule())
            }

            PhotosPicker(selection: $selectedPhotoItem, matching: .images) {
                Text("Choose Photo")
                    .font(.caption.bold())
                    .padding(.horizontal, 14)
                    .padding(.vertical, 6)
                    .background(avatarMode == .photo ? AnyShapeStyle(.tint) : AnyShapeStyle(AppearanceManager.shared.theme.chipColor))
                    .foregroundStyle(avatarMode == .photo ? .white : .primary)
                    .clipShape(Capsule())
            }
        }
    }

    private var emojiGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 6), spacing: 10) {
            ForEach(iconOptions, id: \.self) { icon in
                Button {
                    withAnimation(.snappy) { selectedEmoji = icon }
                } label: {
                    Image(systemName: icon)
                        .font(.body)
                        .foregroundStyle(selectedEmoji == icon ? AnyShapeStyle(.tint) : AnyShapeStyle(.secondary))
                        .frame(width: 44, height: 44)
                        .background(
                            selectedEmoji == icon
                                ? AnyShapeStyle(.tint.opacity(0.15))
                                : AnyShapeStyle(AppearanceManager.shared.theme.chipColor)
                        )
                        .clipShape(.rect(cornerRadius: 12))
                        .overlay {
                            if selectedEmoji == icon {
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(.tint, lineWidth: 2)
                            }
                        }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 20)
    }

    private var avatarSection: some View {
        VStack(spacing: 16) {
            avatarCircle

            Text("Choose Your Avatar")
                .font(.caption)
                .foregroundStyle(.secondary)

            avatarModePicker

            if avatarMode == .emoji {
                emojiGrid
            }
        }
        .onChange(of: selectedPhotoItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self) {
                    avatarImageData = data
                    avatarMode = .photo
                }
            }
        }
        .photosPicker(isPresented: $showingImageSourcePicker, selection: $selectedPhotoItem, matching: .images)
    }

    private var errorBanner: some View {
        Group {
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
        }
    }

    private var displayNameField: some View {
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
    }

    private var emailField: some View {
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
    }

    private var passwordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Password")
                .font(.subheadline.bold())
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Group {
                    if showPassword {
                        TextField("At least 6 characters", text: $password)
                            .textContentType(.newPassword)
                    } else {
                        SecureField("At least 6 characters", text: $password)
                            .textContentType(.newPassword)
                    }
                }
                .focused($focusedField, equals: .password)
                .submitLabel(.next)
                .onSubmit { focusedField = .confirmPassword }
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(AppearanceManager.shared.theme.cardColor)
            .clipShape(.rect(cornerRadius: 12))

            if !password.isEmpty && password.count < 6 {
                Text("Password must be at least 6 characters")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
            }
        }
    }

    private var confirmPasswordField: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("Confirm Password")
                .font(.subheadline.bold())
            HStack(spacing: 10) {
                Image(systemName: "lock.fill")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                Group {
                    if showConfirmPassword {
                        TextField("Repeat password", text: $confirmPassword)
                            .textContentType(.newPassword)
                    } else {
                        SecureField("Repeat password", text: $confirmPassword)
                            .textContentType(.newPassword)
                    }
                }
                .focused($focusedField, equals: .confirmPassword)
                .submitLabel(.next)
                .onSubmit { focusedField = .username }
                Button {
                    showConfirmPassword.toggle()
                } label: {
                    Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .buttonStyle(.plain)
            }
            .padding(12)
            .background(AppearanceManager.shared.theme.cardColor)
            .clipShape(.rect(cornerRadius: 12))

            if !confirmPassword.isEmpty && password != confirmPassword {
                Text("Passwords don't match")
                    .font(.caption)
                    .foregroundStyle(.red)
                    .padding(.leading, 4)
            }
        }
    }

    private var usernameField: some View {
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
            }
            .padding(12)
            .background(AppearanceManager.shared.theme.cardColor)
            .clipShape(.rect(cornerRadius: 12))

            usernameStatus
        }
        .onChange(of: username) { _, newValue in
            usernameService.checkUsername(newValue)
        }
    }

    private var usernameStatus: some View {
        HStack(spacing: 6) {
            if usernameService.isChecking {
                ProgressView()
                    .controlSize(.mini)
                Text("Checking availability...")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } else if let available = usernameService.isAvailable {
                Image(systemName: available ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .foregroundStyle(available ? .green : .red)
                    .font(.caption)
                Text(available ? "Username available" : (usernameService.errorMessage ?? "Username taken"))
                    .font(.caption)
                    .foregroundStyle(available ? .green : .red)
            } else if let error = usernameService.errorMessage {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.caption)
                Text(error)
                    .font(.caption)
                    .foregroundStyle(.orange)
            }
        }
        .padding(.leading, 4)
    }

    private var bioField: some View {
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
    }

    private var favoriteNoteField: some View {
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

    private var formSection: some View {
        VStack(spacing: 20) {
            errorBanner
            displayNameField
            emailField
            passwordField
            confirmPasswordField
            Divider().padding(.vertical, 4)
            usernameField
            bioField
            favoriteNoteField
        }
    }

    private func createProfile() {
        focusedField = nil
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces).lowercased()
        let trimmedEmail = email.trimmingCharacters(in: .whitespaces).lowercased()
        let trimmedName = displayName.trimmingCharacters(in: .whitespaces)
        let trimmedBio = bio.trimmingCharacters(in: .whitespaces)
        let trimmedNote = favoriteNote.trimmingCharacters(in: .whitespaces)

        if let data = avatarImageData {
            UserDefaults.standard.set(data, forKey: "user_avatar_image")
        }

        Task {
            let success = await profileManager.signUp(
                email: trimmedEmail,
                password: password,
                displayName: trimmedName,
                username: trimmedUsername,
                bio: trimmedBio,
                favoriteNote: trimmedNote,
                avatarEmoji: selectedEmoji
            )

            if success {
                if trimmedUsername.count >= 3 {
                    _ = await usernameService.registerUsername(trimmedUsername)
                }
                dismiss()
            }
        }
    }
}
