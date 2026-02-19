//
//  DayCell.swift
//  habbit
//

import SwiftUI

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let completionCount: Int
    let onTap: () -> Void

    // MARK: - Computed Properties

    private var dayName: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(dayName)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(textColor)

                Text(dayNumber)
                    .font(.body)
                    .fontWeight(isToday && !isSelected ? .bold : .regular)
                    .foregroundStyle(numberColor)

                // Completion dot indicator
                Circle()
                    .fill(dotColor)
                    .frame(width: 6, height: 6)
                    .opacity(completionCount > 0 ? 1 : 0)
            }
            .frame(width: 44, height: 64)
            .background(backgroundColor)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }

    // MARK: - Styling

    private var backgroundColor: Color {
        isSelected ? Color.accentColor : Color.clear
    }

    private var textColor: Color {
        if isSelected {
            return .white
        }
        return .secondary
    }

    private var numberColor: Color {
        if isSelected {
            return .white
        }
        if isToday {
            return .accentColor
        }
        return .primary
    }

    private var dotColor: Color {
        isSelected ? .white : .accentColor
    }
}

// MARK: - Preview

#Preview("Default State") {
    DayCell(
        date: Date(),
        isSelected: false,
        isToday: false,
        completionCount: 0,
        onTap: {}
    )
}

#Preview("Selected") {
    DayCell(
        date: Date(),
        isSelected: true,
        isToday: false,
        completionCount: 0,
        onTap: {}
    )
}

#Preview("Today (Not Selected)") {
    DayCell(
        date: Date(),
        isSelected: false,
        isToday: true,
        completionCount: 0,
        onTap: {}
    )
}

#Preview("With Completions") {
    DayCell(
        date: Date(),
        isSelected: false,
        isToday: false,
        completionCount: 3,
        onTap: {}
    )
}

#Preview("Selected Today With Completions") {
    DayCell(
        date: Date(),
        isSelected: true,
        isToday: true,
        completionCount: 5,
        onTap: {}
    )
}
