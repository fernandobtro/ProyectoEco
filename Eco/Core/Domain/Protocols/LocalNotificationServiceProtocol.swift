//
//  LocalNotificationServiceProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol LocalNotificationServiceProtocol {
    func scheduleStoryUnlockedNotification(storyTitle: String) async
}

