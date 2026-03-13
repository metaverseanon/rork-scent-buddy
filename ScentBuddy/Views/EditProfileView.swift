import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    private var profileManager: UserProfileManager { UserProfileManager.shared }

    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var favoriteNote: String = ""
    @State private var selectedEmoji: String = "drop.fill"

    private let iconOptions = ["drop.fill", "flame.fill", "star.fill", "moon.fill", "leaf.fill", "heart.fill", "sparkles", "crown.fill", "bolt.fill", "cloud.fill", "wind", "eye.fill"]

    var body: some View {
        NavigationStack {
            Form {
                avatarSection
                infoSection
                preferencesSection
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveProfile() }
                        .fontWeight(.semibold)
                        .disabled(displayName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .onAppear {
                displayName = profileManager.profile.displayName
                email = profileManager.profile.email
                username = profileManager.profile.username
                bio = profileManager.profile.bio
                favoriteNote = profileManager.profile.favoriteNote
                selectedEmoji = profileManager.profile.avatarEmoji
            }
        }
    }

    private var avatarSection: some View {
        Section {
            HStack {
                Spacer()
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [.purple.opacity(0.25), .pink.opacity(0.15)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 80, height: 80)

                        Image(systemName: selectedEmoji)
                            .font(.system(size: 28))
                            .foregroundStyle(.white)
                    }

                    emojiPicker
                }
                Spacer()
            }
        }
        .listRowBackground(Color.clear)
    }

    private var emojiPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(iconOptions, id: \.self) { icon in
                    Button {
                        withAnimation(.snappy) { selectedEmoji = icon }
                    } label: {
                        Image(systemName: icon)
                            .font(.callout)
                            .foregroundStyle(selectedEmoji == icon ? .tint : .secondary)
                            .frame(width: 36, height: 36)
                            .background(
                                selectedEmoji == icon
                                    ? AnyShapeStyle(.tint.opacity(0.15))
                                    : AnyShapeStyle(Color.clear)
                            )
                            .clipShape(.rect(cornerRadius: 10))
                    }
                }
            }
        }
        .contentMargins(.horizontal, 0)
    }

    private var infoSection: some View {
        Section("Info") {
            TextField("Display Name", text: $displayName)
                .textContentType(.name)
            HStack(spacing: 8) {
                Image(systemName: "envelope.fill")
                    .foregroundStyle(.secondary)
                    .font(.subheadline)
                TextField("Email", text: $email)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            HStack(spacing: 0) {
                Text("@")
                    .foregroundStyle(.secondary)
                TextField("username", text: $username)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
            }
            TextField("Bio", text: $bio, axis: .vertical)
                .lineLimit(2...4)
        }
    }

    private var preferencesSection: some View {
        Section("Preferences") {
            TextField("Favorite Note", text: $favoriteNote)
        }
    }

    private func saveProfile() {
        profileManager.profile.displayName = displayName.trimmingCharacters(in: .whitespaces)
        profileManager.profile.email = email.trimmingCharacters(in: .whitespaces).lowercased()
        profileManager.profile.username = username.trimmingCharacters(in: .whitespaces).lowercased()
        profileManager.profile.bio = bio.trimmingCharacters(in: .whitespaces)
        profileManager.profile.favoriteNote = favoriteNote.trimmingCharacters(in: .whitespaces)
        profileManager.profile.avatarEmoji = selectedEmoji
        dismiss()
    }
}
