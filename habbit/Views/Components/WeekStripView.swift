//
//  WeekStripView.swift
//  habbit
//

import SwiftUI

struct WeekStripView: View {
    @Bindable var viewModel: CalendarViewModel

    @State private var dragOffset: CGFloat = 0

    // MARK: - Body

    var body: some View {
        HStack(spacing: 8) {
            // Left arrow button
            Button(action: {
                viewModel.goToPreviousWeek()
            }) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)

            // Week strip with 7 day cells
            HStack(spacing: 4) {
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
                DragGesture(minimumDistance: 20)
                    .onChanged { gesture in
                        dragOffset = gesture.translation.width * 0.3
                    }
                    .onEnded { gesture in
                        let threshold: CGFloat = 50
                        if gesture.translation.width < -threshold {
                            // Swipe left -> next week
                            viewModel.goToNextWeek()
                        } else if gesture.translation.width > threshold {
                            // Swipe right -> previous week
                            viewModel.goToPreviousWeek()
                        }
                        withAnimation(.easeInOut(duration: 0.2)) {
                            dragOffset = 0
                        }
                    }
            )
            .animation(.easeInOut, value: viewModel.weekOffset)

            // Right arrow button
            Button(action: {
                viewModel.goToNextWeek()
            }) {
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .frame(width: 32, height: 32)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Helper Methods

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
