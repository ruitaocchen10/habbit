//
//  TemplateFormViewModel.swift
//  habbit
//
//  Manages form state and validation for creating/editing habit templates
//

import Foundation
import Observation

@Observable
@MainActor
class TemplateFormViewModel {
    // MARK: - Properties

    var name: String = ""
    var description: String = ""
    var icon: String = ""
    var color: String = ""
    var isActive: Bool = false
    var isSaving: Bool = false
    var errorMessage: String?

    // Reference to parent view model for persistence
    private var templateViewModel: TemplateViewModel?
    private var editingTemplate: HabitTemplate?

    // MARK: - Computed Properties

    var isValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canSave: Bool {
        isValid && !isSaving
    }

    // MARK: - Initialization

    init(templateViewModel: TemplateViewModel? = nil) {
        self.templateViewModel = templateViewModel
    }

    // MARK: - Form Actions

    func save() async {
        guard canSave, let viewModel = templateViewModel else { return }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        do {
            if let existingTemplate = editingTemplate {
                // Update existing template
                let updatedTemplate = HabitTemplate(
                    id: existingTemplate.id,
                    userId: existingTemplate.userId,
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.isEmpty ? nil : description,
                    icon: icon.isEmpty ? nil : icon,
                    color: color.isEmpty ? nil : color,
                    isActive: isActive,
                    activatedAt: isActive ? (existingTemplate.activatedAt ?? Date()) : existingTemplate.activatedAt,
                    createdAt: existingTemplate.createdAt,
                    updatedAt: Date()
                )
                await viewModel.updateTemplate(updatedTemplate)
            } else {
                // Create new template
                let newTemplate = HabitTemplate(
                    id: UUID(),
                    userId: UUID(), // Will be overridden by backend
                    name: name.trimmingCharacters(in: .whitespacesAndNewlines),
                    description: description.isEmpty ? nil : description,
                    icon: icon.isEmpty ? nil : icon,
                    color: color.isEmpty ? nil : color,
                    isActive: isActive,
                    activatedAt: isActive ? Date() : nil,
                    createdAt: Date(),
                    updatedAt: Date()
                )
                await viewModel.createTemplate(newTemplate)
            }

            // Check if there was an error during save
            if viewModel.errorMessage != nil {
                errorMessage = viewModel.errorMessage
            }
        }
    }

    func delete() async {
        guard let template = editingTemplate, let viewModel = templateViewModel else { return }

        isSaving = true
        errorMessage = nil
        defer { isSaving = false }

        await viewModel.deleteTemplate(template)

        if viewModel.errorMessage != nil {
            errorMessage = viewModel.errorMessage
        }
    }

    func reset() {
        name = ""
        description = ""
        icon = ""
        color = ""
        isActive = false
        errorMessage = nil
        editingTemplate = nil
    }

    func load(from template: HabitTemplate) {
        editingTemplate = template
        name = template.name
        description = template.description ?? ""
        icon = template.icon ?? ""
        color = template.color ?? ""
        isActive = template.isActive
        errorMessage = nil
    }

    // MARK: - Helper

    var isEditMode: Bool {
        editingTemplate != nil
    }
}
