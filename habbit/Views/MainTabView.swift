//
//  MainTabView.swift
//  habbit
//
//  Main container view that manages tab navigation
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0

    var body: some View {
        Group {
            switch selectedTab {
            case 0:
                HomeView(selectedTab: $selectedTab)
            case 1:
                TemplateLibraryView(selectedTab: $selectedTab)
            case 2:
                ProfileView(selectedTab: $selectedTab)
            default:
                HomeView(selectedTab: $selectedTab)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    MainTabView()
        .environment(AuthManager())
}
