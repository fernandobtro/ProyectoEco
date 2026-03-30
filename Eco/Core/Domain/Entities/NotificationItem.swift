//
//  NotificationItem.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Domain record for in-app notification events, user-facing copy lives in Features (`NotificationPresentation`).
//

import Foundation

/// Domain entity `NotificationItem` (pure model, no framework UI).
struct NotificationItem: Identifiable, Equatable {
    enum NotificationType: String, Codable {
        case proximityGrouped
        case storyUnlocked
    }

    let id: UUID
    let date: Date
    let type: NotificationType

    let storyId: String?
    let storyTitle: String?
    let count: Int?
}
