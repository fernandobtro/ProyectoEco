//
//  NotificationLogServiceProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Persist and read the in-app notification history (Domain boundary).
//

import Foundation

/// Append-only log of ``NotificationItem`` rows for the notifications screen.
protocol NotificationLogServiceProtocol {
    func log(_ item: NotificationItem)
    func fetchAll() -> [NotificationItem]
}
