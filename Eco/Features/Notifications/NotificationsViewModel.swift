//
//  NotificationsViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//

import Foundation
import Observation

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

    /// Filas listas para la vista (copy y formato en Features).
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
