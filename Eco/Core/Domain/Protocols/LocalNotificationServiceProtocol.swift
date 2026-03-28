//
//  LocalNotificationServiceProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol LocalNotificationServiceProtocol {
    func scheduleStoryUnlockedNotification(storyTitle: String) async
    /// Proximidad con un solo Eco elegible: tap → lector (`storyId` en `userInfo`).
    func scheduleProximityNotification(storyId: String, storyTitle: String) async
    /// Varios Ecos a la vez: tap → mapa (evita elegir historia arbitraria).
    func scheduleGroupedProximityNotification(count: Int) async
}
