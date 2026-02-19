//
//  HabitViewModel.swift
//  habbit
//
//  Manages habit data for a specific date
//

import Foundation
import Observation
import Supabase

@Observable
@MainActor
class HabitViewModel {
    // MARK: - Properties

    var activeTemplates: [HabitTemplate] = []
    var completionsForDate: Set<UUID> = []
    var isLoading: Bool = false
    var errorMessage: String?
    var onToggleComplete: (() -> Void)?

    // MARK: - Data Loading

    func loadData(for date: Date) async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            async let templates = fetchActiveTemplates(for: date)
            async let completions = fetchCompletions(for: date)
            (activeTemplates, completionsForDate) = try await (templates, completions)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Completion Toggle

    func toggleCompletion(for template: HabitTemplate, on date: Date) async {
        let alreadyCompleted = completionsForDate.contains(template.id)

        // Optimistic update
        if alreadyCompleted {
            completionsForDate.remove(template.id)
        } else {
            completionsForDate.insert(template.id)
        }

        do {
            let userId = try await SupabaseService.client.auth.session.user.id
            let dateString = date.isoDateString

            if alreadyCompleted {
                // Delete completion
                try await SupabaseService.client
                    .from("habit_completions")
                    .delete()
                    .eq("user_id", value: userId.uuidString)
                    .eq("template_id", value: template.id.uuidString)
                    .eq("completed_date", value: dateString)
                    .execute()
            } else {
                // Insert completion
                let completion: [String: String] = [
                    "user_id": userId.uuidString,
                    "template_id": template.id.uuidString,
                    "completed_date": dateString
                ]
                try await SupabaseService.client
                    .from("habit_completions")
                    .insert(completion)
                    .execute()
            }

            // Notify that toggle completed successfully
            onToggleComplete?()
        } catch {
            // Revert optimistic update on error
            if alreadyCompleted {
                completionsForDate.insert(template.id)
            } else {
                completionsForDate.remove(template.id)
            }
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private Helpers

    private func fetchActiveTemplates(for date: Date) async throws -> [HabitTemplate] {
        let userId = try await SupabaseService.client.auth.session.user.id
        let dateString = date.isoDateString

        let templates: [HabitTemplate] = try await SupabaseService.client
            .from("habit_templates")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("is_active", value: true)
            .lte("activated_at", value: dateString)
            .execute()
            .value

        return templates
    }

    private func fetchCompletions(for date: Date) async throws -> Set<UUID> {
        let userId = try await SupabaseService.client.auth.session.user.id
        let dateString = date.isoDateString

        let completions: [HabitCompletion] = try await SupabaseService.client
            .from("habit_completions")
            .select()
            .eq("user_id", value: userId.uuidString)
            .eq("completed_date", value: dateString)
            .execute()
            .value

        return Set(completions.map { $0.templateId })
    }
}

// MARK: - Date Extensions

extension Date {
    var isoDateString: String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return formatter.string(from: self)
    }
}

