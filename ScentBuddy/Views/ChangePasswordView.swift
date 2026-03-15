import SwiftUI

struct ChangePasswordView: View {
    @Environment(\.dismiss) private var dismiss

    @State private var newPassword: String = ""
    @State private var confirmPassword: String = ""
    @State private var showPassword: Bool = false
    @State private var isLoading: Bool = false
    @State private var isSuccess: Bool = false
    @State private var errorMessage: String?

    @FocusState private var focusedField: Field?

    nonisolated private enum Field: Hashable {
        case newPassword, confirmPassword
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 28) {
                    Spacer().frame(height: 10)

                    VStack(spacing: 12) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [.green.opacity(0.3), .mint.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 80, height: 80)

                            Image(systemName: isSuccess ? "checkmark.circle.fill" : "lock.rotation")
                                .font(.system(size: 32))
                                .foregroundStyle(isSuccess ? .green : .mint)
                                .contentTransition(.symbolEffect(.replace))
                        }

                        Text(isSuccess ? "Password Updated" : "Change Password")
                            .font(.title3.bold())

                        Text(isSuccess
                             ? "Your password has been changed successfully."
                             : "Enter a new password for your account.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    if !isSuccess {
                        VStack(spacing: 20) {
                            if let error = errorMessage {
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

                            VStack(alignment: .leading, spacing: 6) {
                                Text("New Password")
                                    .font(.subheadline.bold())
                                HStack(spacing: 10) {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                    Group {
                                        if showPassword {
                                            TextField("At least 6 characters", text: $newPassword)
                                                .textContentType(.newPassword)
                                        } else {
                                            SecureField("At least 6 characters", text: $newPassword)
                                                .textContentType(.newPassword)
                                        }
                                    }
                                    .focused($focusedField, equals: .newPassword)
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

                                if !newPassword.isEmpty && newPassword.count < 6 {
                                    Text("Password must be at least 6 characters")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                        .padding(.leading, 4)
                                }
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("Confirm Password")
                                    .font(.subheadline.bold())
                                HStack(spacing: 10) {
                                    Image(systemName: "lock.fill")
                                        .foregroundStyle(.secondary)
                                        .font(.subheadline)
                                    SecureField("Repeat new password", text: $confirmPassword)
                                        .textContentType(.newPassword)
                                        .focused($focusedField, equals: .confirmPassword)
                                        .submitLabel(.go)
                                        .onSubmit { changePassword() }
                                }
                                .padding(12)
                                .background(AppearanceManager.shared.theme.cardColor)
                                .clipShape(.rect(cornerRadius: 12))

                                if !confirmPassword.isEmpty && newPassword != confirmPassword {
                                    Text("Passwords don't match")
                                        .font(.caption)
                                        .foregroundStyle(.red)
                                        .padding(.leading, 4)
                                }
                            }

                            Button {
                                changePassword()
                            } label: {
                                HStack(spacing: 8) {
                                    if isLoading {
                                        ProgressView()
                                            .tint(.white)
                                    } else {
                                        Image(systemName: "checkmark.shield.fill")
                                    }
                                    Text(isLoading ? "Updating..." : "Update Password")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.mint)
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 14))
                            }
                            .disabled(!isFormValid || isLoading)
                            .opacity(isFormValid && !isLoading ? 1 : 0.6)
                        }
                        .padding(.horizontal)
                    } else {
                        Button {
                            dismiss()
                        } label: {
                            Text("Done")
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(.tint)
                                .foregroundStyle(.white)
                                .clipShape(.rect(cornerRadius: 14))
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .background(AppearanceManager.shared.theme.backgroundColor)
            .navigationTitle("Change Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .disabled(isLoading)
                }
            }
        }
    }

    private var isFormValid: Bool {
        newPassword.count >= 6 && newPassword == confirmPassword
    }

    private func changePassword() {
        guard isFormValid else { return }
        focusedField = nil
        isLoading = true
        errorMessage = nil

        Task {
            do {
                try await SupabaseService.shared.updatePassword(newPassword: newPassword)
                withAnimation(.spring(duration: 0.5)) {
                    isSuccess = true
                }
            } catch {
                errorMessage = error.localizedDescription
            }
            isLoading = false
        }
    }
}
