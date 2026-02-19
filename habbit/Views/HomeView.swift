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
    @State private var showingTemplateLibrary = false

    // MARK: - Design Tokens

    private enum Constants {
        static let avatarSize: CGFloat = 32
    }

    // MARK: - Computed Properties

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

    // MARK: - Body

    var body: some View {
        NavigationStack {
            VStack(spacing: .spacing.medium) {
                VStack(alignment: .leading, spacing: .spacing.xxSmall) {
                    Text("Hello")
                        .font(.theme.title3)
                        .fontWeight(.regular)
                        .foregroundStyle(Color.theme.textSecondary)
                    Text(displayName)
                        .font(.theme.title)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.theme.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)

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

                Spacer()
            }
            .background(.theme.background)
            .task {
                await calendarViewModel.loadWeekCompletionCounts()
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
                }

                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: .spacing.small) {
                        Button {
                            showingTemplateLibrary = true
                        } label: {
                            Image(systemName: "checklist")
                                .foregroundStyle(.theme.primary)
                        }

                        Button("Sign Out") {
                            Task { await authManager.signOut() }
                        }
                    }
                }
            }
            .sheet(isPresented: $showingTemplateLibrary) {
                TemplateLibraryView()
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(AuthManager())
}
