//
//  ProfileView.swift
//  habbit
//
//  User profile with stats, streaks, and settings
//

import SwiftUI
import Auth

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Binding var selectedTab: Int

    // MARK: - Design Tokens

    private enum Constants {
        static let avatarSize: CGFloat = 80
        static let sectionSpacing: CGFloat = 24
    }

    // MARK: - Computed Properties

    private var displayName: String {
        if let metadata = authManager.session?.user.userMetadata,
           case let .string(name) = metadata["full_name"] {
            return name
        }
        return authManager.session?.user.email ?? "User"
    }

    private var email: String {
        authManager.session?.user.email ?? ""
    }

    private var avatarURL: URL? {
        if let metadata = authManager.session?.user.userMetadata,
           case let .string(urlString) = metadata["avatar_url"] {
            return URL(string: urlString)
        }
        return nil
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: Constants.sectionSpacing) {
                        // User Info Section
                        VStack(spacing: .spacing.medium) {
                            // Avatar
                            Group {
                                if let url = avatarURL {
                                    AsyncImage(url: url) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .foregroundStyle(Color.theme.textSecondary)
                                    }
                                    .frame(width: Constants.avatarSize, height: Constants.avatarSize)
                                    .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .foregroundStyle(Color.theme.textSecondary)
                                        .frame(width: Constants.avatarSize, height: Constants.avatarSize)
                                }
                            }
                            .padding(.top, .spacing.large)

                            // Name and Email
                            VStack(spacing: .spacing.xxSmall) {
                                Text(displayName)
                                    .font(.theme.title2)
                                    .fontWeight(.bold)
                                    .foregroundStyle(Color.theme.textPrimary)

                                Text(email)
                                    .font(.theme.body)
                                    .foregroundStyle(Color.theme.textSecondary)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal)

                        // Stats Section (Placeholder)
                        VStack(alignment: .leading, spacing: .spacing.small) {
                            Text("Stats")
                                .font(.theme.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.theme.textPrimary)
                                .padding(.horizontal)

                            VStack(spacing: .spacing.small) {
                                StatPlaceholder(title: "Current Streak", value: "Coming Soon")
                                StatPlaceholder(title: "Total Completions", value: "Coming Soon")
                                StatPlaceholder(title: "Active Habits", value: "Coming Soon")
                            }
                        }

                        // Heatmap Section (Placeholder)
                        VStack(alignment: .leading, spacing: .spacing.small) {
                            Text("Activity")
                                .font(.theme.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.theme.textPrimary)
                                .padding(.horizontal)

                            VStack(spacing: .spacing.small) {
                                Text("Heatmap calendar coming soon")
                                    .font(.theme.body)
                                    .foregroundStyle(Color.theme.textSecondary)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color.theme.backgroundSecondary)
                                    .cornerRadius(.radius.medium)
                            }
                            .padding(.horizontal)
                        }

                        // Sign Out Button
                        Button {
                            Task { await authManager.signOut() }
                        } label: {
                            Text("Sign Out")
                                .font(.theme.body)
                                .fontWeight(.medium)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .cornerRadius(.radius.medium)
                        }
                        .padding(.horizontal)
                        .padding(.top, .spacing.medium)

                        Spacer()
                    }
                }

                // Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
            .background(Color.theme.background)
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Stat Placeholder

private struct StatPlaceholder: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.theme.body)
                .foregroundStyle(Color.theme.textPrimary)

            Spacer()

            Text(value)
                .font(.theme.body)
                .foregroundStyle(Color.theme.textSecondary)
        }
        .padding()
        .background(Color.theme.backgroundSecondary)
        .cornerRadius(.radius.medium)
        .padding(.horizontal)
    }
}

// MARK: - Preview

#Preview {
    ProfileView(selectedTab: .constant(2))
        .environment(AuthManager())
}
