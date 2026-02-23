//
//  ActivityHeatmapView.swift
//  habbit
//
//  GitHub-style activity heatmap showing the past year of habit completions.
//  Columns = weeks (oldest left → newest right), rows = days (Sun–Sat).
//

import SwiftUI

struct ActivityHeatmapView: View {

    /// Date strings ("yyyy-MM-dd") mapped to completion count for that day
    let completionsByDate: [String: Int]

    // MARK: - Layout Constants

    private let cellSize: CGFloat = 11
    private let cellSpacing: CGFloat = 2
    private let monthLabelHeight: CGFloat = 16
    private let dayLabelWidth: CGFloat = 20

    // Only show labels for Su, Tu, Th, Sa (every other row) to avoid crowding
    private let dayLabels = ["Su", "", "Tu", "", "Th", "", "Sa"]

    // MARK: - Grid Data

    /// Returns an array of week columns, each containing 7 optional Dates (nil = future).
    /// Starts 52 weeks ago (Sunday) and ends with the current week.
    private var weeks: [[Date?]] {
        let calendar = Calendar.current
        let today = Date()

        // Find the Sunday that starts the current week
        let weekdayOrdinal = calendar.component(.weekday, from: today) // 1 = Sun
        let daysFromSunday = weekdayOrdinal - 1
        guard let currentWeekSunday = calendar.date(byAdding: .day, value: -daysFromSunday, to: today) else {
            return []
        }

        // Start 52 weeks before the current week's Sunday (53 total columns)
        guard let startSunday = calendar.date(byAdding: .weekOfYear, value: -52, to: currentWeekSunday) else {
            return []
        }

        var result: [[Date?]] = []
        var weekStart = startSunday

        while weekStart <= currentWeekSunday {
            var week: [Date?] = []
            for dayOffset in 0..<7 {
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                    week.append(date <= today ? date : nil)
                } else {
                    week.append(nil)
                }
            }
            result.append(week)
            guard let next = calendar.date(byAdding: .weekOfYear, value: 1, to: weekStart) else { break }
            weekStart = next
        }

        return result
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(alignment: .top, spacing: 4) {
                dayLabelsColumn
                scrollableGrid
            }

            heatmapLegend
                .padding(.top, .spacing.xSmall)
        }
        .padding(.spacing.medium)
        .background(Color.theme.backgroundSecondary)
        .cornerRadius(.radius.medium)
    }

    // MARK: - Subviews

    /// Fixed left column showing abbreviated day-of-week labels
    private var dayLabelsColumn: some View {
        VStack(alignment: .trailing, spacing: cellSpacing) {
            // Spacer matching the month-label row height
            Color.clear
                .frame(width: dayLabelWidth, height: monthLabelHeight)

            ForEach(Array(dayLabels.enumerated()), id: \.offset) { _, label in
                Text(label)
                    .font(.theme.caption)
                    .foregroundStyle(Color.theme.textTertiary)
                    .frame(width: dayLabelWidth, height: cellSize)
            }
        }
    }

    /// Horizontally scrollable week columns, scrolled to the trailing edge on appear
    private var scrollableGrid: some View {
        let allWeeks = weeks
        return ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: cellSpacing) {
                    ForEach(Array(allWeeks.enumerated()), id: \.offset) { weekIndex, week in
                        weekColumn(week: week, weekIndex: weekIndex, totalWeeks: allWeeks.count)
                            .id(weekIndex)
                    }
                }
            }
            .onAppear {
                // Jump to the rightmost (most recent) week
                proxy.scrollTo(allWeeks.count - 1, anchor: .trailing)
            }
        }
    }

    /// A single week column: month label on top, 7 day cells below
    private func weekColumn(week: [Date?], weekIndex: Int, totalWeeks: Int) -> some View {
        VStack(spacing: cellSpacing) {
            // Month label — only shown when this week contains the 1st of a month
            Text(monthLabel(for: week, weekIndex: weekIndex))
                .font(.theme.caption)
                .foregroundStyle(Color.theme.textTertiary)
                .frame(height: monthLabelHeight)
                .fixedSize()

            // Day cells
            ForEach(0..<7, id: \.self) { dayIndex in
                if let date = week[dayIndex] {
                    let count = completionsByDate[date.isoDateString] ?? 0
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(Color.theme.heatmapColor(for: count))
                        .frame(width: cellSize, height: cellSize)
                } else {
                    // Future date — render empty placeholder
                    RoundedRectangle(cornerRadius: 2, style: .continuous)
                        .fill(Color.clear)
                        .frame(width: cellSize, height: cellSize)
                }
            }
        }
    }

    /// Small legend row: empty → full intensity with label
    private var heatmapLegend: some View {
        HStack(spacing: .spacing.xSmall) {
            Text("Less")
                .font(.theme.caption)
                .foregroundStyle(Color.theme.textTertiary)

            ForEach(0..<5, id: \.self) { level in
                RoundedRectangle(cornerRadius: 2, style: .continuous)
                    .fill(Color.theme.heatmapColor(for: [0, 1, 3, 5, 7][level]))
                    .frame(width: cellSize, height: cellSize)
            }

            Text("More")
                .font(.theme.caption)
                .foregroundStyle(Color.theme.textTertiary)
        }
    }

    // MARK: - Helpers

    /// Returns the 3-letter month abbreviation if this week's column contains the 1st of a month.
    private func monthLabel(for week: [Date?], weekIndex: Int) -> String {
        let calendar = Calendar.current

        for date in week.compactMap({ $0 }) {
            if calendar.component(.day, from: date) == 1 {
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM"
                return formatter.string(from: date)
            }
        }

        // Always label the very first column so context is clear
        if weekIndex == 0, let firstDate = week.compactMap({ $0 }).first {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM"
            return formatter.string(from: firstDate)
        }

        return ""
    }
}

// MARK: - Preview

#Preview {
    ActivityHeatmapView(completionsByDate: {
        var dict: [String: Int] = [:]
        let calendar = Calendar.current
        let today = Date()
        // Seed with some random data for the preview
        for offset in 0..<200 {
            if Bool.random() {
                if let date = calendar.date(byAdding: .day, value: -offset, to: today) {
                    dict[date.isoDateString] = Int.random(in: 1...7)
                }
            }
        }
        return dict
    }())
    .padding()
    .background(Color.theme.background)
}
