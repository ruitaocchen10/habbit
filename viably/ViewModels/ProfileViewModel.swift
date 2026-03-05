//
//  ProfileViewModel.swift
//  viably
//
//  Fetches and computes profile stats: streak, total completions, and heatmap data
//

import Foundation
import Observation
import Supabase

@Observable
@MainActor
class ProfileViewModel {

    // MARK: - Published State

    var currentStreak: Int = 0
    var totalCompletions: Int = 0
    /// Date string ("yyyy-MM-dd") → number of habit completions that day
    var completionsByDate: [String: Int] = [:]
    var isLoading: Bool = false
    var errorMessage: String?

    // MARK: - Load

    func loadStats() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        do {
            let userId = try await SupabaseService.client.auth.session.user.id

            // Fetch the past year of completions
            let calendar = Calendar.current
            let today = Date()
            guard let oneYearAgo = calendar.date(byAdding: .year, value: -1, to: today) else { return }

            let completions: [HabitCompletion] = try await SupabaseService.client
                .from("habit_completions")
                .select()
                .eq("user_id", value: userId.uuidString)
                .gte("completed_date", value: oneYearAgo.isoDateString)
                .execute()
                .value

            // Aggregate by date
            var byDate: [String: Int] = [:]
            for completion in completions {
                let key = completion.completedDate.isoDateString
                byDate[key, default: 0] += 1
            }

            completionsByDate = byDate
            totalCompletions = completions.count
            currentStreak = calculateStreak(byDate: byDate, today: today, calendar: calendar)

        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Private Helpers

    /// Counts consecutive days with ≥1 completion going backwards from today.
    /// If today has no completions, starts the count from yesterday (streak still alive).
    private func calculateStreak(byDate: [String: Int], today: Date, calendar: Calendar) -> Int {
        var streak = 0
        var current = today

        // If today is empty, see if yesterday keeps the streak alive
        if byDate[today.isoDateString, default: 0] == 0 {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: today) else { return 0 }
            current = yesterday
        }

        // Walk backwards while each day has at least one completion
        while byDate[current.isoDateString, default: 0] > 0 {
            streak += 1
            guard let prev = calendar.date(byAdding: .day, value: -1, to: current) else { break }
            current = prev
        }

        return streak
    }
}
