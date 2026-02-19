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

    // Preset color options
    private let colorOptions = [
        "#FF5733", // Red-Orange
        "#FFC107", // Amber
        "#4CAF50", // Green
        "#42A5F5", // Blue
        "#9B59B6", // Purple
        "#E91E63", // Pink
        "#FF9800", // Orange
        "#009688"  // Teal
    ]

    // Common habit icons
    private let iconOptions = [
        "figure.run", "heart.circle", "book", "bed.double",
        "cup.and.saucer", "dumbbell", "leaf", "brain.head.profile",
        "pencil", "music.note", "paintbrush", "camera",
        "fork.knife", "drop", "pills", "bicycle"
    ]

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
                    TextField("Habit Name", text: $formViewModel.name)
                        .autocorrectionDisabled()
                } header: {
                    Text("NAME *")
                } footer: {
                    if !formViewModel.isValid && !formViewModel.name.isEmpty {
                        Text("Name is required")
                            .foregroundStyle(.theme.error)
                    }
                }

                // Description Section
                Section {
                    TextField("Description (optional)", text: $formViewModel.description, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("DESCRIPTION")
                }

                // Icon Section
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: .spacing.small) {
                        ForEach(iconOptions, id: \.self) { icon in
                            Button {
                                formViewModel.icon = icon
                            } label: {
                                Image(systemName: icon)
                                    .font(.system(size: 28))
                                    .foregroundStyle(formViewModel.icon == icon ? .theme.primary : .theme.textSecondary)
                                    .frame(width: 50, height: 50)
                                    .background(
                                        formViewModel.icon == icon ? Color.theme.primary.opacity(0.1) : Color.clear
                                    )
                                    .clipShape(RoundedRectangle(cornerRadius: 8))
                            }
                        }
                    }
                    .padding(.vertical, .spacing.xSmall)
                } header: {
                    Text("ICON")
                }

                // Color Section
                Section {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 50))], spacing: .spacing.small) {
                        ForEach(colorOptions, id: \.self) { colorHex in
                            Button {
                                formViewModel.color = colorHex
                            } label: {
                                Circle()
                                    .fill(Color(hex: colorHex) ?? .theme.primary)
                                    .frame(width: 40, height: 40)
                                    .overlay {
                                        if formViewModel.color == colorHex {
                                            Image(systemName: "checkmark")
                                                .foregroundStyle(.white)
                                                .fontWeight(.bold)
                                        }
                                    }
                            }
                        }
                    }
                    .padding(.vertical, .spacing.xSmall)
                } header: {
                    Text("COLOR")
                }

                // Active Toggle Section
                Section {
                    Toggle(isOn: $formViewModel.isActive) {
                        VStack(alignment: .leading, spacing: .spacing.xxSmall) {
                            Text("Active")
                                .font(.theme.body)
                            Text("When active, this habit appears in your daily list")
                                .font(.theme.caption)
                                .foregroundStyle(.theme.textSecondary)
                        }
                    }
                    .tint(.theme.primary)
                }

                // Delete Button Section (Edit Mode Only)
                if formViewModel.isEditMode {
                    Section {
                        Button(role: .destructive) {
                            showingDeleteAlert = true
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Template")
                                    .fontWeight(.medium)
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(formViewModel.isEditMode ? "Edit Habit" : "New Habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
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
                    .fontWeight(.semibold)
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
            icon: "figure.run",
            color: "#FF5733",
            isActive: true,
            activatedAt: Date(),
            createdAt: Date(),
            updatedAt: Date()
        )
    )
}
