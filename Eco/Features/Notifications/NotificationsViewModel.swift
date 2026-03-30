//
//  NotificationsViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Loads persisted ``NotificationItem`` rows and maps them to ``NotificationViewData`` for the UI.
//

import Foundation
import Observation

/// Reads from ``NotificationLogServiceProtocol`` on `load()`, relative dates use `es_MX`.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Cross-Cutting: Sync, Geofencing, Notifications**.
@MainActor
@Observable
final class NotificationsViewModel {
    private let logService: NotificationLogServiceProtocol

    private let relativeDateFormatter: RelativeDateTimeFormatter = {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "es_MX")
        formatter.unitsStyle = .short
        return formatter
    }()

    /// Rows ready for the list (copy and formatting owned in Features).
    private(set) var rows: [NotificationViewData] = []

    init(logService: NotificationLogServiceProtocol) {
        self.logService = logService
    }

    func load() {
        let items = logService.fetchAll()
            .sorted(by: { $0.date > $1.date })
        let now = Date()

        rows = items.map { item in
            NotificationPresentation.viewData(
                for: item,
                dateText: relativeDateFormatter.localizedString(for: item.date, relativeTo: now)
            )
        }
    }
}
