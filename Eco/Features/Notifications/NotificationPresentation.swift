//
//  NotificationPresentation.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Maps ``NotificationItem`` to user-facing strings, icons, and ``NotificationViewData`` / ``NotificationTapContext``.
//

import Foundation

enum NotificationPresentation {

    static func title(for item: NotificationItem) -> String {
        switch item.type {
        case .proximityGrouped:
            let ecoCount = item.count ?? 1
            if ecoCount <= 1 {
                return "¡Estás cerca de un nuevo Eco!"
            }
            return "¡Hay \(ecoCount) Ecos cerca de ti!"
        case .storyUnlocked:
            if let title = item.storyTitle, !title.isEmpty {
                return "Eco desbloqueado: \(title)"
            }
            return "Eco desbloqueado"
        }
    }

    static func iconSystemName(for item: NotificationItem) -> String {
        switch item.type {
        case .proximityGrouped:
            "mappin.and.ellipse"
        case .storyUnlocked:
            "lock.open"
        }
    }

    static func tapContext(for item: NotificationItem) -> NotificationTapContext {
        switch item.type {
        case .proximityGrouped:
            .proximityGrouped
        case .storyUnlocked:
            .storyUnlocked(storyId: item.storyId, storyTitle: item.storyTitle)
        }
    }

    static func viewData(for item: NotificationItem, dateText: String) -> NotificationViewData {
        NotificationViewData(
            id: item.id,
            title: title(for: item),
            dateText: dateText,
            iconSystemName: iconSystemName(for: item),
            tapContext: tapContext(for: item)
        )
    }
}
