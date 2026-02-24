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
                icon: "list.bullet",
                title: "Templates",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            // Profile Tab
            TabBarButton(
                icon: "person",
                title: "Profile",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }
        }
        .padding(.vertical, 12)
        .background(Color.theme.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadowSmall()
        .padding(.horizontal, 24)
        .padding(.bottom, 4)
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
