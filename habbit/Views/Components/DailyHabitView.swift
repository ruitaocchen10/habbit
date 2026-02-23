//
//  DailyHabitView.swift
//  habbit
//
//  Daily habit list component - uses theme tokens from design system
//

import SwiftUI

struct DailyHabitView: View {
    @Bindable var viewModel: HabitViewModel
    let selectedDate: Date

    // MARK: - Design Tokens

    private enum Constants {
        static let animationDuration: CGFloat = 0.3
    }

    // MARK: - Computed Properties

    private var isFutureDate: Bool {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let selected = calendar.startOfDay(for: selectedDate)
        return selected > today
    }

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: .spacing.small) {
            // Section header
            Text("Today's Habits")
                .font(.theme.headline)
                .foregroundStyle(.theme.textPrimary)
                .padding(.horizontal, .spacing.medium)

            if viewModel.isLoading {
                loadingView
            } else if let errorMessage = viewModel.errorMessage {
                errorView(message: errorMessage)
            } else if viewModel.activeTemplates.isEmpty {
                emptyStateView
            } else {
                habitList
            }
        }
    }

    // MARK: - Subviews

    private var habitList: some View {
        LazyVStack(spacing: .spacing.xSmall) {
            ForEach(viewModel.activeTemplates) { template in
                HabitRowView(
                    template: template,
                    isCompleted: viewModel.completionsForDate.contains(template.id),
                    isFutureDate: isFutureDate,
                    onToggle: {
                        Task {
                            await viewModel.toggleCompletion(for: template, on: selectedDate)
                        }
                    }
                )
            }
        }
        .padding(.horizontal, .spacing.medium)
        .animation(.easeInOut(duration: Constants.animationDuration), value: viewModel.activeTemplates.map { $0.id })
    }

    private var loadingView: some View {
        VStack(spacing: 8) {
            ProgressView()
                .tint(.accentColor)
            Text("Loading habits...")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }

    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "checkmark.circle")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)

            Text("No habits for this day")
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.primary)

            Text("Tap the checklist icon to manage your habit templates.")
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundStyle(.theme.error)

            Text("Something went wrong")
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.primary)

            Text(message)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button("Retry") {
                Task {
                    await viewModel.loadData(for: selectedDate)
                }
            }
            .buttonStyle(.bordered)
            .tint(.accentColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(20)
    }

}

// MARK: - Preview

#Preview("With Habits") {
    @Previewable @State var viewModel = HabitViewModel()
    DailyHabitView(viewModel: viewModel, selectedDate: Date())
        .task {
            let templates = [
                HabitTemplate(id: UUID(), userId: UUID(), name: "Morning Run", description: nil, isActive: true, activatedAt: Date(), createdAt: Date(), updatedAt: Date()),
                HabitTemplate(id: UUID(), userId: UUID(), name: "Meditate", description: nil, isActive: true, activatedAt: Date(), createdAt: Date(), updatedAt: Date()),
                HabitTemplate(id: UUID(), userId: UUID(), name: "Read 20 min", description: nil, isActive: true, activatedAt: Date(), createdAt: Date(), updatedAt: Date())
            ]
            viewModel.activeTemplates = templates
            viewModel.completionsForDate = [templates[1].id]
        }
}

#Preview("Empty State") {
    @Previewable @State var viewModel = HabitViewModel()
    DailyHabitView(viewModel: viewModel, selectedDate: Date())
}

#Preview("Loading") {
    @Previewable @State var viewModel = HabitViewModel()
    DailyHabitView(viewModel: viewModel, selectedDate: Date())
        .task {
            viewModel.isLoading = true
        }
}

#Preview("Error State") {
    @Previewable @State var viewModel = HabitViewModel()
    DailyHabitView(viewModel: viewModel, selectedDate: Date())
        .task {
            viewModel.errorMessage = "Failed to load habits. Please check your connection."
        }
}

#Preview("Future Date") {
    @Previewable @State var viewModel = HabitViewModel()
    let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    DailyHabitView(viewModel: viewModel, selectedDate: tomorrow)
        .task {
            viewModel.activeTemplates = [
                HabitTemplate(id: UUID(), userId: UUID(), name: "Morning Run", description: nil, isActive: true, activatedAt: Date(), createdAt: Date(), updatedAt: Date())
            ]
        }
}
