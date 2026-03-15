import SwiftUI

struct UserProfileLoaderView: View {
    let userId: String
    let socialService: SocialService
    @State private var loadedProfile: SocialProfile?
    @State private var isLoading: Bool = true
    @State private var loadFailed: Bool = false

    private var theme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        Group {
            if let profile = resolvedProfile {
                UserProfileDetailView(user: profile)
            } else if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(theme.backgroundColor)
            } else if loadFailed {
                ContentUnavailableView {
                    Label("Profile Unavailable", systemImage: "person.slash")
                } description: {
                    Text("Could not load this user's profile.")
                }
                .background(theme.backgroundColor)
            }
        }
        .task {
            if resolvedProfile == nil {
                await loadProfile()
            }
        }
    }

    private var resolvedProfile: SocialProfile? {
        if let cached = socialService.discoveredUsers.first(where: { $0.id == userId }) ??
            socialService.followingUsers.first(where: { $0.id == userId }) {
            return cached
        }
        return loadedProfile
    }

    private func loadProfile() async {
        isLoading = true
        defer { isLoading = false }
        do {
            if let profile = try await SupabaseService.shared.fetchProfile(userId: userId) {
                loadedProfile = SocialProfile(from: profile)
            } else {
                loadFailed = true
            }
        } catch {
            loadFailed = true
        }
    }
}
