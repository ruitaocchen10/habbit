//
//  WeekStripView.swift
//  habbit
//
//  Week navigation strip component - uses theme tokens from design system
//

import SwiftUI

struct WeekStripView: View {
    @Bindable var viewModel: CalendarViewModel

    @State private var selectedPage: Int = 1

    // MARK: - Design Tokens

    private enum Constants {
        // day-names (~16) + xxSmall spacing (4) + cell height (48) + xSmall padding * 2 (16)
        static let stripHeight: CGFloat = 84
    }

    // MARK: - Body

    var body: some View {
        TabView(selection: $selectedPage) {
            weekPage(forOffset: viewModel.weekOffset - 1)
                .tag(0)
            weekPage(forOffset: viewModel.weekOffset)
                .tag(1)
            weekPage(forOffset: viewModel.weekOffset + 1)
                .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: Constants.stripHeight)
        .sensoryFeedback(.selection, trigger: viewModel.weekOffset)
        .onChange(of: selectedPage) { _, newPage in
            guard newPage != 1 else { return }
            if newPage == 0 {
                viewModel.goToPreviousWeek()
            } else {
                viewModel.goToNextWeek()
            }
            // Snap back to the middle page with no animation.
            // By the time this runs, weekOffset has already updated, so
            // page 1 now displays the same week the user swiped to —
            // making the reset invisible.
            withAnimation(.none) {
                selectedPage = 1
            }
        }
    }

    // MARK: - Week Page

    @ViewBuilder
    private func weekPage(forOffset offset: Int) -> some View {
        let days = viewModel.week(atOffset: offset)
        VStack(spacing: .spacing.xxSmall) {
            // Day names row (M, T, W, etc.)
            HStack(spacing: 0) {
                ForEach(days, id: \.self) { date in
                    Text(dayName(for: date))
                        .font(.theme.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day numbers row
            HStack(spacing: .spacing.xxSmall) {
                ForEach(days, id: \.self) { date in
                    DayCell(
                        date: date,
                        isSelected: isSelected(date),
                        isToday: isToday(date),
                        completionCount: completionCount(for: date),
                        onTap: {
                            viewModel.selectDay(date)
                        }
                    )
                }
            }
        }
        .padding(.spacing.xSmall)
    }

    // MARK: - Helper Methods

    private func dayName(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEEE" // Single letter day name
        return formatter.string(from: date)
    }

    private func isSelected(_ date: Date) -> Bool {
        Calendar.current.isDate(date, inSameDayAs: viewModel.selectedDate)
    }

    private func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }

    private func completionCount(for date: Date) -> Int {
        let normalizedDate = Calendar.current.startOfDay(for: date)
        return viewModel.completionCountsForWeek[normalizedDate] ?? 0
    }
}

// MARK: - Preview

#Preview {
    WeekStripView(viewModel: CalendarViewModel())
        .padding()
}
