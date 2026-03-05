//
//  TemplateRow.swift
//  viably
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
        static let rowHeight: CGFloat = 48
        static let toggleWidth: CGFloat = 51
    }

    // MARK: - Body

    var body: some View {
        Button(action: onEdit) {
            HStack(spacing: .spacing.small) {
                // Habit name and description
                VStack(alignment: .leading, spacing: .spacing.xxSmall) {
                    HStack(spacing: .spacing.xxSmall) {
                        Text(template.name)
                            .font(.theme.body)
                            .fontWeight(.medium)
                            .foregroundStyle(.theme.textPrimary)

                        if template.isMvd {
                            Image(systemName: "star.fill")
                                .font(.system(size: 11))
                                .foregroundStyle(.theme.primary)
                        }

                        Spacer()
                    }

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
            .padding(.horizontal, .spacing.xSmall)
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
