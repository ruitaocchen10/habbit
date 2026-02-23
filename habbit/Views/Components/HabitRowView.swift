//
//  HabitRowView.swift
//  habbit
//
//  Single habit row component with checkbox - uses theme tokens from design system
//

import SwiftUI

struct HabitRowView: View {
    let template: HabitTemplate
    let isCompleted: Bool
    let isFutureDate: Bool
    let onToggle: () -> Void

    @State private var isAnimating = false

    // MARK: - Design Tokens

    private enum Constants {
        static let iconSize: CGFloat = 24
        static let checkboxSize: CGFloat = 24
        static let rowHeight: CGFloat = 64
        static let scaleAnimationAmount: CGFloat = 1.2
        static let animationDuration: CGFloat = 0.15
    }

    // MARK: - Body

    var body: some View {
        Button(action: handleTap) {
            HStack(spacing: .spacing.small) {
                // Habit name
                Text(template.name)
                    .font(.theme.body)
                    .foregroundStyle(.theme.textPrimary)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Checkbox (right side)
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: Constants.checkboxSize))
                    .foregroundStyle(isCompleted ? .theme.primary : .theme.textSecondary)
                    .scaleEffect(isAnimating ? Constants.scaleAnimationAmount : 1.0)
            }
            .padding(.horizontal, .spacing.medium)
            .frame(height: Constants.rowHeight)
            .background(Color.theme.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: .radius.xLarge, style: .continuous))
            .shadowSmall()
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(isFutureDate)
        .opacity(isFutureDate ? 0.5 : 1.0)
    }

    // MARK: - Actions

    private func handleTap() {
        guard !isFutureDate else { return }

        // Trigger scale animation
        withAnimation(.easeInOut(duration: Constants.animationDuration)) {
            isAnimating = true
        }

        // Reset animation after a brief delay
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.animationDuration) {
            withAnimation(.easeInOut(duration: Constants.animationDuration)) {
                isAnimating = false
            }
        }

        onToggle()
    }
}

// MARK: - Color Extension

extension Color {
    init?(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Preview

#Preview("Unchecked") {
    HabitRowView(
        template: HabitTemplate(
            id: UUID(),
            userId: UUID(),
            name: "Morning Run",
            description: nil,
            isActive: true,
            activatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        isCompleted: false,
        isFutureDate: false,
        onToggle: {}
    )
}

#Preview("Checked") {
    HabitRowView(
        template: HabitTemplate(
            id: UUID(),
            userId: UUID(),
            name: "Meditate",
            description: nil,
            isActive: true,
            activatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        isCompleted: true,
        isFutureDate: false,
        onToggle: {}
    )
}

#Preview("Future Date (Disabled)") {
    HabitRowView(
        template: HabitTemplate(
            id: UUID(),
            userId: UUID(),
            name: "Read 20 min",
            description: nil,
            isActive: true,
            activatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        isCompleted: false,
        isFutureDate: true,
        onToggle: {}
    )
}
