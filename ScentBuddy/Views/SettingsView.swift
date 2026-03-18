import SwiftUI

struct SettingsView: View {
    private var currentTheme: AppTheme { AppearanceManager.shared.theme }
    @State private var showingNotePreferences: Bool = false
    @State private var showingTasteQuiz: Bool = false
    @State private var showingChangeEmail: Bool = false
    @State private var showingChangePassword: Bool = false
    @State private var notificationService = NotificationService.shared
    @State private var testNotificationSent: Bool = false

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle(isOn: Binding(
                    get: { notificationService.dailyReminderEnabled },
                    set: { newValue in Task { await notificationService.toggleDailyReminder(newValue) } }
                )) {
                    HStack(spacing: 14) {
                        Image(systemName: "bell.badge.fill")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(.blue.gradient, in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Daily Wear Reminder")
                                .foregroundStyle(.primary)
                            Text("Remind me at \(notificationService.dailyReminderHour > 12 ? notificationService.dailyReminderHour - 12 : notificationService.dailyReminderHour) \(notificationService.dailyReminderHour >= 12 ? "PM" : "AM")")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                if notificationService.dailyReminderEnabled {
                    Picker("Reminder Time", selection: $notificationService.dailyReminderHour) {
                        ForEach(6..<23) { hour in
                            Text("\(hour > 12 ? hour - 12 : hour) \(hour >= 12 ? "PM" : "AM")")
                                .tag(hour)
                        }
                    }
                }

                Toggle(isOn: Binding(
                    get: { notificationService.weeklyPicksEnabled },
                    set: { newValue in Task { await notificationService.toggleWeeklyPicks(newValue) } }
                )) {
                    HStack(spacing: 14) {
                        Image(systemName: "sparkles")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(.orange.gradient, in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Weekly Smart Picks")
                                .foregroundStyle(.primary)
                            Text("Saturday suggestions")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }

            Section {
                Button {
                    Task {
                        await notificationService.sendTestNotification()
                        testNotificationSent = true
                        try? await Task.sleep(for: .seconds(3))
                        testNotificationSent = false
                    }
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "paperplane.fill")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(.green.gradient, in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Test Push Notification")
                                .foregroundStyle(.primary)
                            Text(testNotificationSent ? "Notification sent! Check in 3 seconds." : "Send a test notification to this device")
                                .font(.caption)
                                .foregroundStyle(testNotificationSent ? .green : .secondary)
                        }
                    }
                }
            }

            if SupabaseService.shared.isAuthenticated {
                Section("Account") {
                    Button {
                        showingChangeEmail = true
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "envelope.badge.fill")
                                .font(.body)
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(.blue.gradient, in: .rect(cornerRadius: 8))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Change Email")
                                    .foregroundStyle(.primary)
                                Text(UserProfileManager.shared.profile.email)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }

                    Button {
                        showingChangePassword = true
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "lock.rotation")
                                .font(.body)
                                .foregroundStyle(.white)
                                .frame(width: 32, height: 32)
                                .background(.mint.gradient, in: .rect(cornerRadius: 8))
                            VStack(alignment: .leading, spacing: 2) {
                                Text("Change Password")
                                    .foregroundStyle(.primary)
                                Text("Update your account password")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                            Spacer()
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundStyle(.tertiary)
                        }
                    }
                }
            }

            Section("Preferences") {
                Button {
                    showingTasteQuiz = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "wand.and.stars")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(.orange.gradient, in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Taste Profile Quiz")
                                .foregroundStyle(.primary)
                            Text(OnboardingManager.shared.hasTasteProfile ? OnboardingManager.shared.tasteProfile.profileName : "Take the quiz")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }

                Button {
                    showingNotePreferences = true
                } label: {
                    HStack(spacing: 14) {
                        Image(systemName: "slider.horizontal.3")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 32, height: 32)
                            .background(.pink.gradient, in: .rect(cornerRadius: 8))
                        VStack(alignment: .leading, spacing: 2) {
                            Text("Note Preferences")
                                .foregroundStyle(.primary)
                            let count = OnboardingManager.shared.notePreferences.favoriteNotes.count
                            Text(count > 0 ? "\(count) notes selected" : "No preferences set")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundStyle(.tertiary)
                    }
                }
            }

            Section("Theme") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Button {
                                withAnimation(.spring(duration: 0.4, bounce: 0.25)) {
                                    AppearanceManager.shared.theme = theme
                                }
                            } label: {
                                VStack(spacing: 8) {
                                    RoundedRectangle(cornerRadius: 14)
                                        .fill(
                                            LinearGradient(
                                                colors: theme.previewColors,
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .frame(width: 56, height: 56)
                                        .overlay {
                                            Image(systemName: theme.icon)
                                                .font(.body)
                                                .foregroundStyle(.white)
                                        }
                                        .overlay {
                                            RoundedRectangle(cornerRadius: 14)
                                                .strokeBorder(
                                                    currentTheme == theme ? theme.tintColor : .clear,
                                                    lineWidth: 2.5
                                                )
                                                .frame(width: 64, height: 64)
                                        }

                                    Text(theme.rawValue)
                                        .font(.caption2)
                                        .fontWeight(currentTheme == theme ? .semibold : .regular)
                                        .foregroundStyle(currentTheme == theme ? theme.tintColor : .secondary)
                                }
                            }
                            .buttonStyle(.plain)
                            .sensoryFeedback(.selection, trigger: currentTheme)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
            }

            Section("About") {
                HStack {
                    Text("Version")
                    Spacer()
                    Text("1.0.0")
                        .foregroundStyle(.secondary)
                }
            }

            if !notificationService.isAuthorized {
                Section {
                    Button {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    } label: {
                        HStack(spacing: 14) {
                            Image(systemName: "bell.slash.fill")
                                .foregroundStyle(.orange)
                            Text("Enable Notifications in Settings")
                                .font(.subheadline)
                        }
                    }
                } footer: {
                    Text("Notifications are disabled. Enable them in Settings to receive reminders.")
                }
            }
        }
        .navigationTitle("Settings")
        .sheet(isPresented: $showingNotePreferences) {
            NotePreferenceView()
        }
        .fullScreenCover(isPresented: $showingTasteQuiz) {
            TasteQuizView(isOnboarding: false) { _ in
                showingTasteQuiz = false
            }
        }
        .sheet(isPresented: $showingChangeEmail) {
            ChangeEmailView(currentEmail: UserProfileManager.shared.profile.email)
        }
        .sheet(isPresented: $showingChangePassword) {
            ChangePasswordView()
        }
    }
}
