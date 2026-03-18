//
//  UserNotificationService.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import UserNotifications

final class UserNotificationService: LocalNotificationServiceProtocol {
    private let center: UNUserNotificationCenter

    init(center: UNUserNotificationCenter = .current()) {
        self.center = center
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
