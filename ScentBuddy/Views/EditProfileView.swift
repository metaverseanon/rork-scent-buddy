import SwiftUI

struct EditProfileView: View {
    @Environment(\.dismiss) private var dismiss
    private var profileManager: UserProfileManager { UserProfileManager.shared }

    @State private var displayName: String = ""
    @State private var email: String = ""
    @State private var username: String = ""
    @State private var bio: String = ""
    @State private var favoriteNote: String = ""
    @State private var selectedEmoji: String = "🌸"

    private let emojiOptions = ["🌸", "🔥", "💎", "🌙", "🍊", "🖤", "💜", "🌹", "⭐", "🌊", "🍃", "☁️"]

    var body: some View {
        NavigationStack {
            Form {
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

                                Text(selectedEmoji)
                                    .font(.system(size: 40))
                            }

                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 8) {
                                    ForEach(emojiOptions, id: \.self) { emoji in
                                        Button {
                                            withAnimation(.snappy) { selectedEmoji = emoji }
                                        } label: {
                                            Text(emoji)
                                                .font(.title3)
                                                .frame(width: 36, height: 36)
                                                .background(
                                                    selectedEmoji == emoji
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
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)

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

                Section("Preferences") {
                    TextField("Favorite Note", text: $favoriteNote)
                }
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
