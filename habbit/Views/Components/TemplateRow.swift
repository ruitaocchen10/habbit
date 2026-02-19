//
//  TemplateRow.swift
//  habbit
//
//  Single template row component with toggle and swipe actions - uses theme tokens from design system
//

import SwiftUI

struct TemplateRow: View {
    let template: HabitTemplate
    let onToggle: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    // MARK: - Design Tokens

    private enum Constants {
        static let iconSize: CGFloat = 24
        static let rowHeight: CGFloat = 64
        static let toggleWidth: CGFloat = 51
    }

    // MARK: - Computed Properties

    private var iconColor: Color {
        if let colorHex = template.color {
            return Color(hex: colorHex) ?? .theme.primary
        }
        return .theme.primary
    }

    // MARK: - Body

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: .spacing.small) {
                // Habit icon
                if let iconName = template.icon, !iconName.isEmpty {
                    Image(systemName: iconName)
                        .font(.system(size: Constants.iconSize))
                        .foregroundStyle(iconColor)
                } else {
                    Image(systemName: "circle.fill")
                        .font(.system(size: Constants.iconSize))
                        .foregroundStyle(.theme.textTertiary)
                }

                // Habit name and description
                VStack(alignment: .leading, spacing: .spacing.xxSmall) {
                    Text(template.name)
                        .font(.theme.body)
                        .fontWeight(.medium)
                        .foregroundStyle(.theme.textPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if let desc = template.description, !desc.isEmpty {
                        Text(desc)
                            .font(.theme.caption)
                            .foregroundStyle(.theme.textSecondary)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }

                // Active toggle
                Toggle("", isOn: Binding(
                    get: { template.isActive },
                    set: { _ in onToggle() }
                ))
                .labelsHidden()
                .tint(.theme.primary)
                .frame(width: Constants.toggleWidth)
            }
            .padding(.horizontal, .spacing.medium)
            .frame(height: Constants.rowHeight)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }

            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.theme.info)
        }
    }
}

// MARK: - Preview

#Preview("Active Template") {
    TemplateRow(
        template: HabitTemplate(
            id: UUID(),
            userId: UUID(),
            name: "Morning Run",
            description: "30 min cardio around the park",
            icon: "figure.run",
            color: "#FF5733",
            isActive: true,
            activatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        onToggle: {},
        onEdit: {},
        onDelete: {}
    )
}

#Preview("Inactive Template") {
    TemplateRow(
        template: HabitTemplate(
            id: UUID(),
            userId: UUID(),
            name: "Meditation",
            description: "10 min mindfulness",
            icon: "heart.circle",
            color: "#9B59B6",
            isActive: false,
            activatedAt: nil,
            createdAt: Date(),
            updatedAt: Date()
        ),
        onToggle: {},
        onEdit: {},
        onDelete: {}
    )
}

#Preview("No Description") {
    TemplateRow(
        template: HabitTemplate(
            id: UUID(),
            userId: UUID(),
            name: "Read",
            description: nil,
            icon: "book",
            color: "#4CAF50",
            isActive: true,
            activatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        ),
        onToggle: {},
        onEdit: {},
        onDelete: {}
    )
}
