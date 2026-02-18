//
//  HomeView.swift
//  habbit
//

import Supabase
import SwiftUI

struct HomeView: View {
    @Environment(AuthManager.self) private var authManager

    private var displayName: String {
        if case let .string(name) = authManager.session?.user.userMetadata["full_name"] {
            return name
        }
        return authManager.session?.user.email ?? "there"
    }

    private var avatarURL: URL? {
        if case let .string(urlString) = authManager.session?.user.userMetadata["avatar_url"] {
            return URL(string: urlString)
        }
        return nil
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Hello")
                        .font(.title3)
                        .fontWeight(.regular)
                        .foregroundStyle(.secondary)
                    Text(displayName)
                        .font(.title)
                        .fontWeight(.bold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 64))
                    .foregroundStyle(.tint)

                Text("Welcome to Habbit")
                    .font(.title2)
                    .fontWeight(.semibold)

                Spacer()
                
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Group {
                        if let url = avatarURL {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                            }
                            .frame(width: 32, height: 32)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                    }
                }

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
