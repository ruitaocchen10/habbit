//
//  DayCell.swift
//  habbit
//
//  Calendar day cell component - uses theme tokens from design system
//

import SwiftUI

struct DayCell: View {
    let date: Date
    let isSelected: Bool
    let isToday: Bool
    let completionCount: Int
    let onTap: () -> Void

    // MARK: - Design Tokens

    private enum Constants {
        static let cellHeight: CGFloat = 48
        static let circleSize: CGFloat = 40
        static let dotSize: CGFloat = 6
        static let animationDuration: CGFloat = 0.2
    }

    // MARK: - Computed Properties

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: date)
    }

    // MARK: - Body

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: .spacing.xxSmall) {
                // Number with circular background
                ZStack {
                    Circle()
                        .fill(backgroundColor)
                        .frame(width: Constants.circleSize, height: Constants.circleSize)

                    Text(dayNumber)
                        .font(.theme.body)
                        .fontWeight(isToday && !isSelected ? .bold : .semibold)
                        .foregroundStyle(numberColor)
                }

                // Completion dot indicator
                Circle()
                    .fill(dotColor)
                    .frame(width: Constants.dotSize, height: Constants.dotSize)
                    .opacity(completionCount > 0 ? 1 : 0)
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.cellHeight)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: Constants.animationDuration), value: isSelected)
    }

    // MARK: - Styling

    private var backgroundColor: Color {
        isSelected ? .theme.primary : .clear
    }

    private var numberColor: Color {
        if isSelected {
            return .white
        }
        if isToday {
            return .theme.primary
        }
        return .theme.textPrimary
    }

    private var dotColor: Color {
        isSelected ? .white : .theme.primary
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
