import SwiftUI

struct ProfileView: View {
    @State private var showingCreateAccount: Bool = false
    @State private var showingLogin: Bool = false
    @State private var showingSettings: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                profileSection
                settingsButton
            }
            .padding(.horizontal)
            .padding(.vertical, 20)
        }
        .background(AppearanceManager.shared.theme.backgroundColor)
        .navigationTitle("Profile")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Profile")
                    .font(.system(size: 18, weight: .heavy, design: .rounded))
            }
        }
        .sheet(isPresented: $showingCreateAccount) {
            CreateAccountView()
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
        .navigationDestination(isPresented: $showingSettings) {
            SettingsView()
        }
    }

    @ViewBuilder
    private var profileSection: some View {
        let profile = UserProfileManager.shared.profile
        if profile.displayName.isEmpty {
            signedOutContent
        } else {
            loggedInContent(profile: profile)
        }
    }

    private var signedOutContent: some View {
        VStack(spacing: 28) {
            Spacer().frame(height: 20)

            Image(systemName: "person.crop.circle.fill")
                .font(.system(size: 64))
                .foregroundStyle(.secondary)

            VStack(spacing: 8) {
                Text("Your Scent Profile")
                    .font(.title2.bold())
                Text("Create an account or sign in to track your fragrance journey.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
            }

            VStack(spacing: 12) {
                Button {
                    showingCreateAccount = true
                } label: {
                    Text("Create Account")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(.tint)
                        .foregroundStyle(.white)
                        .clipShape(.rect(cornerRadius: 14))
                }

                Button {
                    showingLogin = true
                } label: {
                    Text("Sign In")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color(.secondarySystemGroupedBackground))
                        .foregroundStyle(.tint)
                        .clipShape(.rect(cornerRadius: 14))
                }
            }
            .padding(.horizontal, 20)
        }
    }

    private func loggedInContent(profile: UserProfile) -> some View {
        VStack(spacing: 20) {
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
                Image(systemName: profile.avatarEmoji)
                    .font(.system(size: 32))
                    .foregroundStyle(.primary)
            }

            VStack(spacing: 4) {
                Text(profile.displayName)
                    .font(.title2.bold())

                if !profile.username.isEmpty {
                    Text("@\(profile.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Button(role: .destructive) {
                UserProfileManager.shared.signOut()
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                }
                .frame(maxWidth: .infinity)
                .padding(14)
                .background(Color(.secondarySystemGroupedBackground))
                .clipShape(.rect(cornerRadius: 14))
            }
        }
        .padding(.top, 20)
    }

    private var settingsButton: some View {
        Button {
            showingSettings = true
        } label: {
            HStack(spacing: 14) {
                Image(systemName: "gearshape.fill")
                    .font(.body)
                    .foregroundStyle(.gray)
                    .frame(width: 32, height: 32)
                    .background(.gray.opacity(0.12))
                    .clipShape(.rect(cornerRadius: 8))

                Text("Settings")
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(.rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
