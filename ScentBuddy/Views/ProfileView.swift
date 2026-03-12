import SwiftUI

struct ProfileView: View {
    @State private var showingCreateAccount: Bool = false
    @State private var showingLogin: Bool = false
    @State private var showingEditProfile: Bool = false

    private var isLoggedIn: Bool {
        !UserProfileManager.shared.profile.displayName.isEmpty
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if isLoggedIn {
                    loggedInContent
                } else {
                    signedOutContent
                }

                toolsSection
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Profile")
        .sheet(isPresented: $showingCreateAccount) {
            CreateAccountView()
        }
        .sheet(isPresented: $showingLogin) {
            LoginView()
        }
        .sheet(isPresented: $showingEditProfile) {
            EditProfileView()
        }
    }

    private var toolsSection: some View {
        VStack(spacing: 0) {
            NavigationLink(destination: RecommendationsView()) {
                ProfileMenuRow(icon: "sparkles", title: "For You", subtitle: "Personalized recommendations", color: .orange)
            }

            Divider().padding(.leading, 56)

            NavigationLink(destination: PhotoScanView()) {
                ProfileMenuRow(icon: "camera.viewfinder", title: "Scan Perfume", subtitle: "Identify bottles with your camera", color: .blue)
            }

            Divider().padding(.leading, 56)

            NavigationLink(destination: CollectionStatsView()) {
                ProfileMenuRow(icon: "chart.bar.fill", title: "Stats", subtitle: "Collection analytics & insights", color: .purple)
            }

            Divider().padding(.leading, 56)

            NavigationLink(destination: CompareView()) {
                ProfileMenuRow(icon: "arrow.left.arrow.right", title: "Compare", subtitle: "Side-by-side fragrance comparison", color: .teal)
            }

            Divider().padding(.leading, 56)

            NavigationLink(destination: SettingsView()) {
                ProfileMenuRow(icon: "gearshape.fill", title: "Settings", subtitle: "Theme & preferences", color: .gray)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 16))
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    private var signedOutContent: some View {
        VStack(spacing: 28) {
            Spacer().frame(height: 40)

            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple.opacity(0.3), .pink.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)

                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.secondary)
            }

            VStack(spacing: 8) {
                Text("Your Scent Profile")
                    .font(.title2.bold())
                Text("Create an account or sign in to track your fragrance journey.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }

            VStack(spacing: 12) {
                Button {
                    showingCreateAccount = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "person.badge.plus")
                        Text("Create Account")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(.tint)
                    .foregroundStyle(.white)
                    .clipShape(.rect(cornerRadius: 14))
                }

                Button {
                    showingLogin = true
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.right.circle")
                        Text("Sign In")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(.secondarySystemGroupedBackground))
                    .foregroundStyle(.tint)
                    .clipShape(.rect(cornerRadius: 14))
                    .overlay {
                        RoundedRectangle(cornerRadius: 14)
                            .strokeBorder(.tint.opacity(0.3), lineWidth: 1)
                    }
                }
            }
            .padding(.horizontal, 40)

            Spacer()
        }
    }

    private var loggedInContent: some View {
        VStack(spacing: 20) {
            profileHeader
            accountActions
        }
        .padding(.horizontal)
    }

    private var profileHeader: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.blue.opacity(0.3), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Text(UserProfileManager.shared.profile.avatarEmoji)
                    .font(.system(size: 48))
            }

            VStack(spacing: 4) {
                Text(UserProfileManager.shared.profile.displayName)
                    .font(.title2.bold())

                let username = UserProfileManager.shared.profile.username
                if !username.isEmpty {
                    Text("@\(username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Button {
                showingEditProfile = true
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "pencil")
                    Text("Edit Profile")
                        .fontWeight(.medium)
                }
                .font(.subheadline)
                .padding(.horizontal, 20)
                .padding(.vertical, 8)
                .background(.tint.opacity(0.12))
                .foregroundStyle(.tint)
                .clipShape(Capsule())
            }
        }
        .padding(.vertical, 20)
    }

    private var accountActions: some View {
        VStack(spacing: 0) {
            Button(role: .destructive) {
                Task {
                    await SupabaseAuthService.shared.signOut()
                }
            } label: {
                HStack {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("Sign Out")
                    Spacer()
                }
                .padding(16)
            }
        }
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 14))
    }
}

struct ProfileMenuRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.12))
                .clipShape(.rect(cornerRadius: 8))

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(subtitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
}
