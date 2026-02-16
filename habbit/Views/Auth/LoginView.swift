//
//  LoginView.swift
//  habbit
//

import Supabase
import SwiftUI

struct LoginView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            // App branding
            VStack(spacing: 12) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 72))
                    .foregroundStyle(.tint)

                Text("Habbit")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Build habits together")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // OAuth sign-in buttons
            VStack(spacing: 12) {
                OAuthButton(label: "Continue with Google", systemImage: "globe") {
                    await authManager.signIn(provider: .google)
                }

                OAuthButton(label: "Continue with Apple", systemImage: "apple.logo") {
                    await authManager.signIn(provider: .apple)
                }
            }
            .padding(.horizontal, 24)

            if let error = authManager.errorMessage {
                Text(error)
                    .font(.footnote)
                    .foregroundStyle(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }

            Spacer()
                .frame(height: 32)
        }
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
            HStack {
                Image(systemName: systemImage)
                Text(label)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LoginView()
        .environment(AuthManager())
}
