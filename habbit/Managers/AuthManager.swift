//
//  AuthManager.swift
//  habbit
//

import Supabase
import SwiftUI

@Observable
final class AuthManager {
    var session: Session? = nil
    var isLoading: Bool = true
    var errorMessage: String? = nil

    var isAuthenticated: Bool {
        session != nil
    }

    init() {
        Task {
            await loadCurrentSession()
            await listenToAuthChanges()
        }
    }

    // MARK: - Session

    private func loadCurrentSession() async {
        do {
            session = try await SupabaseService.client.auth.session
        } catch {
            // No active session — user needs to sign in
            session = nil
        }
        isLoading = false
    }

    private func listenToAuthChanges() async {
        for await (event, newSession) in SupabaseService.client.auth.authStateChanges {
            switch event {
            case .initialSession, .signedIn, .tokenRefreshed, .userUpdated:
                session = newSession
            case .signedOut, .passwordRecovery:
                session = nil
            default:
                break
            }
        }
    }

    // MARK: - OAuth Sign In

    func signIn(provider: Provider) async {
        errorMessage = nil
        do {
            try await SupabaseService.client.auth.signInWithOAuth(
                provider: provider,
                redirectTo: URL(string: Config.oauthRedirectURL)
            )
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Sign Out

    func signOut() async {
        errorMessage = nil
        do {
            try await SupabaseService.client.auth.signOut()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Deep Link Handling

    func handle(url: URL) {
        Task {
            do {
                try await SupabaseService.client.auth.session(from: url)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
}
