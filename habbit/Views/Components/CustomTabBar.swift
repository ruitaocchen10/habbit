//
//  CustomTabBar.swift
//  habbit
//
//  Custom tab bar component for navigation between main sections
//

import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int

    // MARK: - Design Tokens

    private enum Constants {
        static let height: CGFloat = 60
        static let iconSize: CGFloat = 24
    }

    // MARK: - Body

    var body: some View {
        HStack(spacing: 0) {
            // Home Tab
            TabBarButton(
                icon: "house.fill",
                title: "Home",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            // Templates Tab
            TabBarButton(
                icon: "checklist",
                title: "Templates",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            // Profile Tab
            TabBarButton(
                icon: "person.circle.fill",
                title: "Profile",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
        }
        .frame(height: Constants.height)
        .background(Color.theme.background)
        .overlay(
            Divider()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .background(Color.secondary.opacity(0.2)),
            alignment: .top
        )
    }
}

// MARK: - Tab Bar Button

private struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: .spacing.xxSmall) {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundStyle(isSelected ? Color.theme.primary : Color.theme.textSecondary)

                Text(title)
                    .font(.theme.caption)
                    .foregroundStyle(isSelected ? Color.theme.primary : Color.theme.textSecondary)
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        CustomTabBar(selectedTab: .constant(0))
    }
    .background(Color.theme.background)
}
