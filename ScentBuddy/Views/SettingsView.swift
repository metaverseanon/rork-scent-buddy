import SwiftUI

struct SettingsView: View {
    private var currentTheme: AppTheme { AppearanceManager.shared.theme }

    var body: some View {
        Form {
            Section("Theme") {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(AppTheme.allCases, id: \.self) { theme in
                            Button {
                                withAnimation(.snappy) {
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
        }
        .navigationTitle("Settings")
    }
}
