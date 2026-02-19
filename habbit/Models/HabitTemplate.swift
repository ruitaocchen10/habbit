//
//  HabitTemplate.swift
//  habbit
//
//  Model representing a habit template from the habit_templates table
//

import Foundation

struct HabitTemplate: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let description: String?
    let icon: String?
    let color: String?
    let isActive: Bool
    let activatedAt: Date?
    let createdAt: Date
    let updatedAt: Date

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case description
        case icon
        case color
        case isActive = "is_active"
        case activatedAt = "activated_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
