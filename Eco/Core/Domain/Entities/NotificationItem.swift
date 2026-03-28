//
//  NotificationItem.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Modelo de dominio para eventos de notificación in-app.
//  Solo datos: el copy visible lo resuelve la capa Features (`NotificationPresentation`).
//

import Foundation

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
