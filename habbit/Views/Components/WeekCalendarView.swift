//
//  WeekCalendarView.swift
//  habbit
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
        VStack(spacing: 12) {
            // Week strip with navigation
            WeekStripView(viewModel: viewModel)

            // Selected date label
            Text(selectedDateLabel)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
        }
        .padding(.top, 8)
    }
}

// MARK: - Preview

#Preview {
    WeekCalendarView(viewModel: CalendarViewModel())
}
