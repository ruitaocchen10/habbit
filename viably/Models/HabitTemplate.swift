//
//  HabitTemplate.swift
//  viably
//
//  Model representing a habit template from the habit_templates table
//

import Foundation

struct HabitTemplate: Codable, Identifiable {
    let id: UUID
    let userId: UUID
    let name: String
    let description: String?
    let isActive: Bool
    let isMvd: Bool
    let activatedAt: Date?
    let createdAt: Date
    let updatedAt: Date

    init(id: UUID, userId: UUID, name: String, description: String?, isActive: Bool, isMvd: Bool = false, activatedAt: Date?, createdAt: Date, updatedAt: Date) {
        self.id = id
        self.userId = userId
        self.name = name
        self.description = description
        self.isActive = isActive
        self.isMvd = isMvd
        self.activatedAt = activatedAt
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case userId = "user_id"
        case name
        case description
        case isActive = "is_active"
        case isMvd = "is_mvd"
        case activatedAt = "activated_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
