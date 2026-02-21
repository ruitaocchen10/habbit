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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: .spacing.medium) {
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
                .task {
                    await calendarViewModel.loadWeekCompletionCounts()
                }
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.large)

                // Tab Bar
                CustomTabBar(selectedTab: $selectedTab)
            }
        }
    }
}

#Preview {
    HomeView(selectedTab: .constant(0))
        .environment(AuthManager())
}
