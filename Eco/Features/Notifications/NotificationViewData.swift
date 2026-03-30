//
//  NotificationViewData.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: View models and rows for the notifications panel without exposing domain `NotificationItem` in SwiftUI.
//

import Foundation

/// Minimal routing payload when the user taps a row (keeps `NotificationItem` out of the view layer).
enum NotificationTapContext: Equatable {
    case proximityGrouped
    case storyUnlocked(storyId: String?, storyTitle: String?)
}

/// One row: title, relative date string, SF Symbol name, and tap context.
struct NotificationViewData: Identifiable, Equatable {
    let id: UUID
    let title: String
    let dateText: String
    let iconSystemName: String
    let tapContext: NotificationTapContext
}
