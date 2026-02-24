//
//  WeekCalendarView.swift
//  habbit
//
//  Week calendar component - uses theme tokens from design system
//

import SwiftUI

struct WeekCalendarView: View {
    @Bindable var viewModel: CalendarViewModel

    // MARK: - Computed Properties

    private var selectedDateLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: viewModel.selectedDate)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: .spacing.small) {
            // Week strip with navigation
            WeekStripView(viewModel: viewModel)
        }
    }
}

// MARK: - Preview

#Preview {
    WeekCalendarView(viewModel: CalendarViewModel())
}
