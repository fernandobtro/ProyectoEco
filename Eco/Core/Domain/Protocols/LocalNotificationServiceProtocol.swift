//
//  LocalNotificationServiceProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain/service protocol `LocalNotificationServiceProtocol`.
//

import Foundation

/// Domain/service protocol `LocalNotificationServiceProtocol`.
protocol LocalNotificationServiceProtocol {
    func scheduleStoryUnlockedNotification(storyTitle: String) async
    /// Single eligible story: tap opens reader (`storyId` in `userInfo`).
    func scheduleProximityNotification(storyId: String, storyTitle: String) async
    /// Multiple stories at once: tap opens map (avoids picking an arbitrary story).
    func scheduleGroupedProximityNotification(count: Int) async
}
