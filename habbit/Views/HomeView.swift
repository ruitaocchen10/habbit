//
//  HomeView.swift
//  habbit
//
//  Main home screen - uses theme tokens from design system
//

import Supabase
import SwiftUI

struct HomeView: View {
    @Environment(AuthManager.self) private var authManager
    @State private var calendarViewModel = CalendarViewModel()
    @State private var habitViewModel = HabitViewModel()
    @Binding var selectedTab: Int

    // MARK: - Computed Properties

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 0..<12: return "Good Morning"
        case 12..<17: return "Good Afternoon"
        default: return "Good Evening"
        }
    }

    private var avatarURL: URL? {
        if let metadata = authManager.session?.user.userMetadata,
           case let .string(urlString) = metadata["avatar_url"] {
            return URL(string: urlString)
        }
        return nil
    }

    private var displayName: String {
        if let metadata = authManager.session?.user.userMetadata,
           let nameValue = metadata["full_name"],
           case let .string(name) = nameValue {
            return name.components(separatedBy: " ").first ?? name
        }
        if let email = authManager.session?.user.email {
            return email.components(separatedBy: "@").first?.capitalized ?? "there"
        }
        return "there"
    }

    // MARK: - Body

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: .spacing.medium) {
                // Custom greeting header
                HStack(alignment: .center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(greeting)
                            .font(.theme.body)
                            .foregroundStyle(.theme.textSecondary)
                        Text(displayName)
                            .font(.theme.title)
                            .foregroundStyle(.theme.textPrimary)
                    }

                    Spacer()

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
                            .frame(width: 44, height: 44)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .foregroundStyle(Color.theme.textSecondary)
                                .frame(width: 44, height: 44)
                        }
                    }
                }
                .padding(.horizontal, .spacing.medium)
                .padding(.top, .spacing.medium)

                // Week calendar component
                WeekCalendarView(viewModel: calendarViewModel)

                // Daily habit list component
                DailyHabitView(
                    viewModel: habitViewModel,
                    selectedDate: calendarViewModel.selectedDate
                )
                .task(id: calendarViewModel.selectedDate) {
                    habitViewModel.onToggleComplete = {
                        Task {
                            await calendarViewModel.loadWeekCompletionCounts()
                        }
                    }
                    await habitViewModel.loadData(for: calendarViewModel.selectedDate)
                }
            }
        }
        .background(.theme.background)
        .safeAreaInset(edge: .bottom) {
            CustomTabBar(selectedTab: $selectedTab)
        }
        .task {
            await calendarViewModel.loadWeekCompletionCounts()
        }
        .background(.theme.background)
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environment(AuthManager())
}
