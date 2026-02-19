//
//  HabitCompletion.swift
//  habbit
//
//  Model representing a habit completion from the habit_completions table
//

import Foundation

struct HabitCompletion: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let templateId: UUID
    let completedDate: Date
    let createdAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case templateId = "template_id"
        case completedDate = "completed_date"
        case createdAt = "created_at"
    }
}
