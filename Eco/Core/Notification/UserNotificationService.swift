//
//  UserNotificationService.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import UserNotifications

final class UserNotificationService: LocalNotificationServiceProtocol {
    private let center: UNUserNotificationCenter
    private let logService: NotificationLogServiceProtocol

    init(
        center: UNUserNotificationCenter = .current(),
        logService: NotificationLogServiceProtocol
    ) {
        self.center = center
        self.logService = logService
    }

    func scheduleProximityNotification(storyId: String, storyTitle: String) async {
        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        let trimmed = storyTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        let title = trimmed.isEmpty ? "Eco aquí" : Self.truncateForNotification(trimmed, maxChars: 60)
        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "Eco"
        content.body = "Estás en el lugar. Toca para leer."
        content.sound = .default
        content.userInfo = ["storyId": storyId]
        content.threadIdentifier = "eco.proximity"

        let request = UNNotificationRequest(
            identifier: "eco.proximity.\(storyId)",
            content: content,
            trigger: nil
        )

        try? await center.add(request)

        let item = NotificationItem(
            id: UUID(),
            date: Date(),
            type: .proximityGrouped,
            storyId: storyId,
            storyTitle: title,
            count: 1
        )
        logService.log(item)
    }

    func scheduleGroupedProximityNotification(count: Int) async {
        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        let title = "Varios Ecos aquí"
        let body = "Hay \(count) ecos cerca. Abre el mapa para verlos."

        let content = UNMutableNotificationContent()
        content.title = title
        content.subtitle = "Eco"
        content.body = body
        content.sound = .default
        content.userInfo = ["deepLink": "map"]
        content.threadIdentifier = "eco.proximity"

        // Un solo aviso agrupado: el nuevo reemplaza al anterior sin llenar el centro de notificaciones.
        let request = UNNotificationRequest(
            identifier: "eco.proximity.grouped.pending",
            content: content,
            trigger: nil
        )

        try? await center.add(request)

        let item = NotificationItem(
            id: UUID(),
            date: Date(),
            type: .proximityGrouped,
            storyId: nil,
            storyTitle: nil,
            count: count
        )
        logService.log(item)
    }

    func scheduleStoryUnlockedNotification(storyTitle: String) async {
        let granted = await requestAuthorizationIfNeeded()
        guard granted else { return }

        let content = UNMutableNotificationContent()
        content.title = "Eco desbloqueado"
        content.body = "Encontraste \"\(storyTitle)\". Ya puedes leer su historia."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "eco.unlocked.\(UUID().uuidString)",
            content: content,
            trigger: nil
        )

        try? await center.add(request)

        let item = NotificationItem(
            id: UUID(),
            date: Date(),
            type: .storyUnlocked,
            storyId: nil,
            storyTitle: storyTitle,
            count: nil
        )
        logService.log(item)
    }

    private static func truncateForNotification(_ text: String, maxChars: Int) -> String {
        guard text.count > maxChars else { return text }
        let end = text.index(text.startIndex, offsetBy: maxChars - 1)
        return String(text[..<end]) + "…"
    }

    private func requestAuthorizationIfNeeded() async -> Bool {
        if let settings = await currentSettings(), settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
            return true
        }
        return (try? await center.requestAuthorization(options: [.alert, .badge, .sound])) ?? false
    }

    private func currentSettings() async -> UNNotificationSettings? {
        await withCheckedContinuation { continuation in
            center.getNotificationSettings { settings in
                continuation.resume(returning: settings)
            }
        }
    }
}
