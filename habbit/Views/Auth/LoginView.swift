//
//  LoginView.swift
//  habbit
//
//  Authentication screen - uses theme tokens from design system
//

import Supabase
import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    // MARK: - Design Tokens

    private enum Constants {
        static let brandIconSize: CGFloat = 72
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .spacing.xLarge) {
            Spacer()

            // App branding
            VStack(spacing: .spacing.small) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: Constants.brandIconSize))
                    .foregroundStyle(Color.theme.primary)

                Text("Habbit")
                    .font(.theme.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.theme.textPrimary)

                Text("Build habits together")
                    .font(.theme.subheadline)
                    .foregroundStyle(Color.theme.textSecondary)
            }

            Spacer()

            // OAuth sign-in buttons
            VStack(spacing: .spacing.small) {
                OAuthButton(label: "Continue with Google", systemImage: "globe") {
                    await authManager.signIn(provider: .google)
                }

                OAuthButton(label: "Continue with Apple", systemImage: "apple.logo") {
                    await authManager.signIn(provider: .apple)
                }
            }
            .padding(.horizontal, .spacing.large)

            if let error = authManager.errorMessage {
                Text(error)
                    .font(.theme.footnote)
                    .foregroundStyle(Color.theme.error)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, .spacing.large)
            }

            Spacer()
                .frame(height: .spacing.xLarge)
        }
        .background(.theme.background)
    }
}

// MARK: - OAuth Button

private struct OAuthButton: View {
    let label: String
    let systemImage: String
    let action: () async -> Void

    var body: some View {
        Button {
            Task { await action() }
        } label: {
            HStack(spacing: .spacing.xSmall) {
                Image(systemName: systemImage)
                    .font(.theme.body)
                Text(label)
                    .font(.theme.button)
            }
            .foregroundStyle(Color.theme.textPrimary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, .spacing.small)
            .padding(.horizontal, .spacing.medium)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: .radius.medium))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
