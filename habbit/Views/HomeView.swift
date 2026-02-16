//
//  HomeView.swift
//  habbit
//

import Supabase
import SwiftUI

struct HomeView: View {
    @Environment(AuthManager.self) private var authManager

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)

                Text("Welcome to Habbit")
                    .font(.title2)
                    .fontWeight(.semibold)

                if let email = authManager.session?.user.email {
                    Text(email)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("Home")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Sign Out") {
                        Task { await authManager.signOut() }
                    }
                }
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AuthManager())
}
