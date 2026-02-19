//
//  TemplateViewModel.swift
//  habbit
//
//  Manages all habit templates (active and inactive) with full CRUD operations
//

import Foundation
import Observation
import Supabase

@Observable
@MainActor
class TemplateViewModel {
    // MARK: - Properties

    var templates: [HabitTemplate] = []
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Computed Properties

    var activeTemplates: [HabitTemplate] {
        templates.filter { $0.isActive }
    }

    var inactiveTemplates: [HabitTemplate] {
        templates.filter { !$0.isActive }
    }

    // MARK: - Data Loading

    func loadTemplates() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let userId = try await SupabaseService.client.auth.session.user.id

            templates = try await SupabaseService.client
                .from("habit_templates")
                .select()
                .eq("user_id", value: userId.uuidString)
                .order("is_active", ascending: false)
                .order("name", ascending: true)
                .execute()
                .value
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Create Template

    private struct HabitTemplateInsertPayload: Encodable {
        let user_id: String
        let name: String
        let description: String?
        let icon: String?
        let color: String?
        let is_active: Bool
        let activated_at: String?
    }

    func createTemplate(_ template: HabitTemplate) async {
        errorMessage = nil

        do {
            let userId = try await SupabaseService.client.auth.session.user.id

            let payload = HabitTemplateInsertPayload(
                user_id: userId.uuidString,
                name: template.name,
                description: template.description,
                icon: template.icon,
                color: template.color,
                is_active: template.isActive,
                activated_at: template.isActive ? Date().isoDateString : nil
            )

            let _: [HabitTemplate] = try await SupabaseService.client
                .from("habit_templates")
                .insert(payload)
                .select()
                .execute()
                .value

            // Refresh the templates list
            await loadTemplates()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Update Template

    private struct HabitTemplateUpdatePayload: Encodable {
        let name: String
        let description: String?
        let icon: String?
        let color: String?
        let is_active: Bool
        let updated_at: String
        let activated_at: String?
    }

    func updateTemplate(_ template: HabitTemplate) async {
        errorMessage = nil

        do {
            let userId = try await SupabaseService.client.auth.session.user.id

            let payload = HabitTemplateUpdatePayload(
                name: template.name,
                description: template.description,
                icon: template.icon,
                color: template.color,
                is_active: template.isActive,
                updated_at: Date().isoDateString,
                activated_at: (template.isActive && template.activatedAt == nil) ? Date().isoDateString : nil
            )

            let _: [HabitTemplate] = try await SupabaseService.client
                .from("habit_templates")
                .update(payload)
                .eq("id", value: template.id.uuidString)
                .eq("user_id", value: userId.uuidString)
                .select()
                .execute()
                .value

            // Refresh the templates list
            await loadTemplates()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Toggle Active Status

    func toggleActive(for template: HabitTemplate) async {
        // Create a mutable copy of the template
        var updatedTemplate = template
        updatedTemplate = HabitTemplate(
            id: template.id,
            userId: template.userId,
            name: template.name,
            description: template.description,
            icon: template.icon,
            color: template.color,
            isActive: !template.isActive,
            activatedAt: !template.isActive ? Date() : template.activatedAt,
            createdAt: template.createdAt,
            updatedAt: Date()
        )

        await updateTemplate(updatedTemplate)
    }

    // MARK: - Delete Template

    func deleteTemplate(_ template: HabitTemplate) async {
        errorMessage = nil

        do {
            let userId = try await SupabaseService.client.auth.session.user.id

            // Delete associated completions first (if not handled by CASCADE in database)
            try await SupabaseService.client
                .from("habit_completions")
                .delete()
                .eq("template_id", value: template.id.uuidString)
                .execute()

            // Delete the template
            try await SupabaseService.client
                .from("habit_templates")
                .delete()
                .eq("id", value: template.id.uuidString)
                .eq("user_id", value: userId.uuidString)
                .execute()

            // Refresh the templates list
            await loadTemplates()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}

