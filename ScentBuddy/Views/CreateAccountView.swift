import SwiftUI
import PhotosUI

struct CreateAccountView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var favoriteNote: String = ""
    @State private var selectedEmoji: String = "🧴"
    @State private var avatarMode: AvatarMode = .emoji
    @State private var selectedPhotoItem: PhotosPickerItem?
    @State private var avatarImageData: Data?
    @State private var showingImageSourcePicker: Bool = false
    @State private var usernameService = UsernameService.shared

    @FocusState private var focusedField: Field?

    private let emojiOptions = ["🧴", "💐", "🌸", "🌿", "🔥", "✨", "🖤", "💎", "🌙", "🍊", "🫧", "🪻"]

    nonisolated private enum Field: Hashable {
        case displayName, email, username, bio, favoriteNote
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
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { createProfile() }
                        .fontWeight(.semibold)
                        .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        let nameValid = !displayName.trimmingCharacters(in: .whitespaces).isEmpty
        let usernameValid = username.trimmingCharacters(in: .whitespaces).count < 3 || usernameService.isAvailable == true
        return nameValid && usernameValid
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

                if avatarMode == .photo, let data = avatarImageData, let uiImage = UIImage(data: data) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                } else {
                    Text(selectedEmoji)
                        .font(.system(size: 48))
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

            Text("Choose Your Avatar")
                .font(.caption)
                .foregroundStyle(.secondary)

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

            if avatarMode == .emoji {
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
                    TextField("Email address", text: $email)
                        .textContentType(.emailAddress)
                        .keyboardType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .focused($focusedField, equals: .email)
                        .submitLabel(.next)
                        .onSubmit { focusedField = .username }
                }
                .padding(12)
                .background(AppearanceManager.shared.theme.cardColor)
                .clipShape(.rect(cornerRadius: 12))
            }

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
                }
                .padding(12)
                .background(AppearanceManager.shared.theme.cardColor)
                .clipShape(.rect(cornerRadius: 12))

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
            .onChange(of: username) { _, newValue in
                usernameService.checkUsername(newValue)
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

    private func createProfile() {
        let trimmedUsername = username.trimmingCharacters(in: .whitespaces).lowercased()
        if trimmedUsername.count >= 3 {
            Task {
                _ = await usernameService.registerUsername(trimmedUsername)
            }
        }

        if let data = avatarImageData {
            UserDefaults.standard.set(data, forKey: "user_avatar_image")
        }

        UserProfileManager.shared.profile = UserProfile(
            displayName: displayName.trimmingCharacters(in: .whitespaces),
            username: trimmedUsername,
            email: email.trimmingCharacters(in: .whitespaces).lowercased(),
            bio: bio.trimmingCharacters(in: .whitespaces),
            favoriteNote: favoriteNote.trimmingCharacters(in: .whitespaces),
            memberSince: Date(),
            avatarEmoji: selectedEmoji
        )
        dismiss()
    }
}
