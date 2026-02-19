//
//  CalendarViewModel.swift
//  habbit
//

import Foundation
import Observation
import Supabase

@Observable
@MainActor
class CalendarViewModel {
    // MARK: - Properties

    var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    var weekOffset: Int = 0
    var completionCountsForWeek: [Date: Int] = [:]

    // MARK: - Computed Properties

    var visibleWeek: [Date] {
        let calendar = Calendar.current
        let today = Date()

        // Get the start of the week for today (Monday)
        guard let weekStart = calendar.dateInterval(of: .weekOfYear, for: today)?.start else {
            return []
        }

        // Adjust Monday to be first day of week
        var components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today)
        components.weekday = 2 // Monday
        guard let thisMonday = calendar.date(from: components) else {
            return []
        }

        // Apply week offset
        guard let offsetMonday = calendar.date(byAdding: .weekOfYear, value: weekOffset, to: thisMonday) else {
            return []
        }

        // Generate 7 consecutive days (Mon-Sun)
        return (0..<7).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: offsetMonday)
        }
    }

    // MARK: - Methods

    func selectDay(_ date: Date) {
        selectedDate = Calendar.current.startOfDay(for: date)
    }

    func goToPreviousWeek() {
        weekOffset -= 1
        selectedDate = correspondingDay(in: visibleWeek, for: selectedDate)
        Task {
            await loadWeekCompletionCounts()
        }
    }

    func goToNextWeek() {
        weekOffset += 1
        selectedDate = correspondingDay(in: visibleWeek, for: selectedDate)
        Task {
            await loadWeekCompletionCounts()
        }
    }

    func loadWeekCompletionCounts() async {
        guard let userId = try? await SupabaseService.client.auth.session.user.id else {
            return
        }

        guard let weekStart = visibleWeek.first,
              let weekEnd = visibleWeek.last else {
            return
        }

        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withFullDate]

        let weekStartString = dateFormatter.string(from: weekStart)
        let weekEndString = dateFormatter.string(from: weekEnd)

        do {
            // Fetch completion counts for the visible week
            let response: [CompletionCount] = try await SupabaseService.client
                .from("habit_completions")
                .select("completed_date")
                .eq("user_id", value: userId.uuidString)
                .gte("completed_date", value: weekStartString)
                .lte("completed_date", value: weekEndString)
                .execute()
                .value

            // Group by date and count
            var counts: [Date: Int] = [:]
            for completion in response {
                if let date = dateFormatter.date(from: completion.completedDate) {
                    let normalizedDate = Calendar.current.startOfDay(for: date)
                    counts[normalizedDate, default: 0] += 1
                }
            }

            completionCountsForWeek = counts
        } catch {
            // Silently fail - dots will be omitted (non-critical per spec)
            completionCountsForWeek = [:]
        }
    }

    // MARK: - Helper Methods

    private func correspondingDay(in week: [Date], for date: Date) -> Date {
        let calendar = Calendar.current
        let targetWeekday = calendar.component(.weekday, from: date)

        // Find the date in the new week with the same weekday
        if let matchingDay = week.first(where: { calendar.component(.weekday, from: $0) == targetWeekday }) {
            return calendar.startOfDay(for: matchingDay)
        }

        // Fallback to first day of week if something goes wrong
        return week.first ?? date
    }
}

// MARK: - Supporting Types

private struct CompletionCount: Decodable {
    let completedDate: String

    enum CodingKeys: String, CodingKey {
        case completedDate = "completed_date"
    }
}
