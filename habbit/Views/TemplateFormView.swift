//
//  TemplateFormView.swift
//  habbit
//
//  Form for creating or editing a habit template
//

import SwiftUI

struct TemplateFormView: View {
    let viewModel: TemplateViewModel
    let template: HabitTemplate?

    @State private var formViewModel: TemplateFormViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showingDeleteAlert = false

    // MARK: - Initialization

    init(viewModel: TemplateViewModel, template: HabitTemplate?) {
        self.viewModel = viewModel
        self.template = template
        _formViewModel = State(initialValue: TemplateFormViewModel(templateViewModel: viewModel))
    }

    // MARK: - Body

    var body: some View {
        NavigationStack {
            Form {
                // Name Section
                Section {
                    TextField("Habit Name", text: $formViewModel.name,
                              prompt: Text("Habit Name").foregroundStyle(.theme.textSecondary))
                        .autocorrectionDisabled()
                        .font(.theme.body)
                        .foregroundStyle(.theme.textPrimary)
                } header: {
                    Text("NAME *")
                        .font(.theme.caption)
                        .foregroundStyle(.theme.textSecondary)
                } footer: {
                    if !formViewModel.isValid && !formViewModel.name.isEmpty {
                        Text("Name is required")
                            .font(.theme.caption)
                            .foregroundStyle(.theme.error)
                    }
                }
                .listRowBackground(Color.theme.cardBackground)

                // Description Section
                Section {
                    TextField("Description (optional)", text: $formViewModel.description,
                              prompt: Text("Description (optional)").foregroundStyle(.theme.textSecondary),
                              axis: .vertical)
                        .lineLimit(3...6)
                        .font(.theme.body)
                        .foregroundStyle(.theme.textPrimary)
                } header: {
                    Text("DESCRIPTION")
                        .font(.theme.caption)
                        .foregroundStyle(.theme.textSecondary)
                }
                .listRowBackground(Color.theme.cardBackground)

                // Active Toggle Section
                Section {
                    Toggle(isOn: $formViewModel.isActive) {
                        VStack(alignment: .leading, spacing: .spacing.xxSmall) {
                            Text("Active")
                                .font(.theme.body)
                                .foregroundStyle(.theme.textPrimary)
                            Text("When active, this habit appears in your daily list")
                                .font(.theme.caption)
                                .foregroundStyle(.theme.textSecondary)
                        }
                    }
                    .tint(.theme.primary)
                }
                .listRowBackground(Color.theme.cardBackground)

                // Delete Button Section (Edit Mode Only)
                if formViewModel.isEditMode {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Template")
                                    .font(.theme.body)
                                Spacer()
                            }
                        }
                    }
                    .listRowBackground(Color.theme.cardBackground)
                }
            }
            .scrollContentBackground(.hidden)
            .background(.theme.background)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(formViewModel.isEditMode ? "Edit Habit" : "New Habit")
                        .font(.theme.headline)
                        .foregroundStyle(.theme.textPrimary)
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .font(.theme.body)
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        Task {
                            await formViewModel.save()
                            if formViewModel.errorMessage == nil {
                                dismiss()
                            }
                        }
                    }
                    .disabled(!formViewModel.canSave)
                    .font(.theme.button)
                }
            }
            .alert("Delete Template", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    Task {
                        await formViewModel.delete()
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this template? This will also delete all completion history.")
            }
            .alert("Error", isPresented: .constant(formViewModel.errorMessage != nil)) {
                Button("OK") {
                    formViewModel.errorMessage = nil
                }
            } message: {
                if let error = formViewModel.errorMessage {
                    Text(error)
                }
            }
            .task {
                if let existingTemplate = template {
                    formViewModel.load(from: existingTemplate)
                } else {
                    formViewModel.reset()
                }
            }
        }
    }
}

// MARK: - Preview

#Preview("Create Mode") {
    TemplateFormView(viewModel: TemplateViewModel(), template: nil)
}

#Preview("Edit Mode") {
    TemplateFormView(
        viewModel: TemplateViewModel(),
        template: HabitTemplate(
            id: UUID(),
            userId: UUID(),
            name: "Morning Run",
            description: "30 min cardio around the park",
            isActive: true,
            activatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}
