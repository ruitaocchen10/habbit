//
//  ProfileView.swift
//  viably
//
//  User profile with stats, streaks, and activity heatmap
//

import SwiftUI
import Auth

struct ProfileView: View {
    @Environment(AuthManager.self) private var authManager
    @Binding var selectedTab: Int

    @State private var profileVM = ProfileViewModel()
    @State private var showSignOutAlert = false

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

                        // Stats Section
                        VStack(alignment: .leading, spacing: .spacing.small) {
                            Text("Stats")
                                .font(.theme.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.theme.textPrimary)
                                .padding(.horizontal)

                            HStack(spacing: .spacing.small) {
                                StatCard(
                                    value: profileVM.isLoading ? "-" : "\(profileVM.currentStreak)",
                                    label: "Current Streak",
                                    icon: "flame.fill",
                                    iconColor: Color.orange
                                )
                                StatCard(
                                    value: profileVM.isLoading ? "-" : "\(profileVM.totalCompletions)",
                                    label: "Total Completions",
                                    icon: "checkmark.seal.fill",
                                    iconColor: Color.theme.primary
                                )
                            }
                            .padding(.horizontal)
                        }

                        // Activity Heatmap Section
                        VStack(alignment: .leading, spacing: .spacing.small) {
                            Text("Activity")
                                .font(.theme.title3)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.theme.textPrimary)
                                .padding(.horizontal)

                            ActivityHeatmapView(completionsByDate: profileVM.completionsByDate)
                                .padding(.horizontal)
                        }

                        // Sign Out Button
                        Button {
                            showSignOutAlert = true
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
                        .alert("Sign Out", isPresented: $showSignOutAlert) {
                            Button("Sign Out", role: .destructive) {
                                Task { await authManager.signOut() }
                            }
                            Button("Cancel", role: .cancel) {}
                        } message: {
                            Text("Are you sure you want to sign out?")
                        }

                        Spacer()
                    }
                }

                // Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
            .background(Color.theme.background)
            .task {
                await profileVM.loadStats()
            }
        }
    }
}

// MARK: - Stat Card

private struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let iconColor: Color

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Decorative background icon
            Image(systemName: icon)
                .font(.system(size: 56, weight: .bold))
                .foregroundStyle(iconColor.opacity(0.12))
                .padding(.spacing.small)

            // Content
            VStack(alignment: .leading, spacing: .spacing.xxSmall) {
                Text(value)
                    .font(.theme.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(Color.theme.textPrimary)
                    .contentTransition(.numericText())

                Text(label)
                    .font(.theme.subheadline)
                    .foregroundStyle(Color.theme.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.spacing.medium)
        }
        .frame(maxWidth: .infinity)
        .background(Color.theme.cardBackground)
        .cornerRadius(.radius.large)
    }
}

// MARK: - Preview

#Preview {
    ProfileView(selectedTab: .constant(2))
        .environment(AuthManager())
}
