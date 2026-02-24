//
//  WeekStripView.swift
//  habbit
//
//  Week navigation strip component - uses theme tokens from design system
//

import SwiftUI

struct WeekStripView: View {
    @Bindable var viewModel: CalendarViewModel

    @State private var dragOffset: CGFloat = 0

    // MARK: - Design Tokens

    private enum Constants {
        static let dragMultiplier: CGFloat = 0.3
        static let swipeThreshold: CGFloat = 50
        static let animationDuration: CGFloat = 0.2
        static let minimumDragDistance: CGFloat = 20
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .spacing.xxSmall) {
            // Day names row (M, T, W, etc.)
            HStack(spacing: 0) {
                ForEach(viewModel.visibleWeek, id: \.self) { date in
                    Text(dayName(for: date))
                        .font(.theme.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.theme.textSecondary)
                        .frame(maxWidth: .infinity)
                }
            }

            // Day numbers row
            HStack(spacing: .spacing.xxSmall) {
                ForEach(viewModel.visibleWeek, id: \.self) { date in
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
            .offset(x: dragOffset)
            .gesture(
                DragGesture(minimumDistance: Constants.minimumDragDistance)
                    .onChanged { gesture in
                        dragOffset = gesture.translation.width * Constants.dragMultiplier
                    }
                    .onEnded { gesture in
                        if gesture.translation.width < -Constants.swipeThreshold {
                            // Swipe left -> next week
                            viewModel.goToNextWeek()
                        } else if gesture.translation.width > Constants.swipeThreshold {
                            // Swipe right -> previous week
                            viewModel.goToPreviousWeek()
                        }
                        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                            dragOffset = 0
                        }
                    }
            )
            .animation(.easeInOut, value: viewModel.weekOffset)
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
