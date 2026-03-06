import SwiftUI
import SwiftData

struct ProfileView: View {
    @State private var showingCreateAccount: Bool = false
    @State private var showingLogin: Bool = false
    @State private var showingEditProfile: Bool = false
    @Query private var perfumes: [Perfume]
    @Query private var wearEntries: [WearEntry]
    @Query private var wishlist: [WishlistPerfume]

    private var profileManager: UserProfileManager { UserProfileManager.shared }
    private var authService: SupabaseAuthService { SupabaseAuthService.shared }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if profileManager.isLoggedIn {
                    loggedInContent
                } else {
                    signedOutContent
                }

                toolsSection
            }
        }
        .background(AppearanceManager.shared.theme.backgroundColor)
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
            NavigationLink {
                RecommendationsView()
            } label: {
                ProfileMenuRow(icon: "sparkles", title: "For You", subtitle: "Personalized recommendations", color: .orange)
            }

            Divider().padding(.leading, 56)

            NavigationLink {
                PhotoScanView()
            } label: {
                ProfileMenuRow(icon: "camera.viewfinder", title: "Scan Perfume", subtitle: "Identify bottles with your camera", color: .blue)
            }

            Divider().padding(.leading, 56)

            NavigationLink {
                CollectionStatsView()
            } label: {
                ProfileMenuRow(icon: "chart.bar.fill", title: "Stats", subtitle: "Collection analytics & insights", color: .purple)
            }

            Divider().padding(.leading, 56)

            NavigationLink {
                CompareView()
            } label: {
                ProfileMenuRow(icon: "arrow.left.arrow.right", title: "Compare", subtitle: "Side-by-side fragrance comparison", color: .teal)
            }

            Divider().padding(.leading, 56)

            NavigationLink {
                SettingsView()
            } label: {
                ProfileMenuRow(icon: "gearshape.fill", title: "Settings", subtitle: "Theme & preferences", color: .gray)
            }
        }
        .background(AppearanceManager.shared.theme.cardColor)
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
                    .background(AppearanceManager.shared.theme.cardColor)
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
            quickStats
            activitySummary
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
                            colors: [AppearanceManager.shared.theme.tintColor.opacity(0.3), .purple.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)

                Text(profileManager.profile.avatarEmoji)
                    .font(.system(size: 48))
            }

            VStack(spacing: 4) {
                Text(profileManager.profile.displayName)
                    .font(.title2.bold())

                if !profileManager.profile.username.isEmpty {
                    Text("@\(profileManager.profile.username)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if !profileManager.profile.email.isEmpty {
                    HStack(spacing: 4) {
                        Image(systemName: "envelope.fill")
                            .font(.caption2)
                        Text(profileManager.profile.email)
                            .font(.caption)
                    }
                    .foregroundStyle(.tertiary)
                }

                if !profileManager.profile.bio.isEmpty {
                    Text(profileManager.profile.bio)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.top, 2)
                }
            }

            HStack(spacing: 6) {
                Image(systemName: "calendar")
                    .font(.caption)
                Text("Member since \(profileManager.profile.memberSince, format: .dateTime.month(.wide).year())")
                    .font(.caption)
            }
            .foregroundStyle(.tertiary)

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

    private var quickStats: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
            ProfileStatTile(value: "\(perfumes.count)", label: "Collection", icon: "drop.fill", color: .purple)
            ProfileStatTile(value: "\(wearEntries.count)", label: "Wears", icon: "calendar.badge.clock", color: .orange)
            ProfileStatTile(value: "\(wishlist.count)", label: "Wishlist", icon: "heart.fill", color: .pink)
        }
    }

    private var activitySummary: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Your Scent Identity")
                .font(.headline)

            if !profileManager.profile.favoriteNote.isEmpty {
                HStack(spacing: 12) {
                    Image(systemName: "leaf.fill")
                        .font(.title3)
                        .foregroundStyle(.green)
                        .frame(width: 40, height: 40)
                        .background(.green.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Signature Note")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(profileManager.profile.favoriteNote)
                            .font(.subheadline.bold())
                    }

                    Spacer()
                }
            }

            if let topBrand = mostWornBrand {
                HStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundStyle(.orange)
                        .frame(width: 40, height: 40)
                        .background(.orange.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Most Worn Brand")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(topBrand)
                            .font(.subheadline.bold())
                    }

                    Spacer()
                }
            }

            if let avgRating = averageRating {
                HStack(spacing: 12) {
                    Image(systemName: "star.fill")
                        .font(.title3)
                        .foregroundStyle(.yellow)
                        .frame(width: 40, height: 40)
                        .background(.yellow.opacity(0.12))
                        .clipShape(.rect(cornerRadius: 10))

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Average Rating")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(String(format: "%.1f", avgRating))
                            .font(.subheadline.bold())
                    }

                    Spacer()
                }
            }
        }
        .padding(16)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 16))
    }

    private var accountActions: some View {
        VStack(spacing: 0) {
            Button(role: .destructive) {
                Task {
                    await authService.signOut()
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
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }

    private var mostWornBrand: String? {
        guard !wearEntries.isEmpty else { return nil }
        let brands = wearEntries.map(\.perfumeBrand)
        let counts = Dictionary(grouping: brands, by: { $0 }).mapValues(\.count)
        return counts.max(by: { $0.value < $1.value })?.key
    }

    private var averageRating: Double? {
        let rated = perfumes.filter { $0.rating > 0 }
        guard !rated.isEmpty else { return nil }
        let total = rated.reduce(0) { $0 + $1.rating }
        return Double(total) / Double(rated.count)
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

struct ProfileStatTile: View {
    let value: String
    let label: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
            Text(value)
                .font(.title2.bold())
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(AppearanceManager.shared.theme.cardColor)
        .clipShape(.rect(cornerRadius: 14))
    }
}
