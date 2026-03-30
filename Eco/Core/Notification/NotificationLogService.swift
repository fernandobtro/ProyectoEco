//
//  NotificationLogService.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Persists in-app notification history in `UserDefaults` (bounded list).
//

import Foundation

/// ``NotificationLogServiceProtocol`` backed by `UserDefaults`.
final class NotificationLogService: NotificationLogServiceProtocol {
    private let storageKey = "eco.notificationLog"
    private let maxItems = 50

    func log(_ item: NotificationItem) {
        var items = fetchAll()
        if let last = items.first,
           last.type == item.type,
           last.storyId == item.storyId,
           last.storyTitle == item.storyTitle,
           last.count == item.count {
            return
        }
        items.insert(item, at: 0)
        if items.count > maxItems {
            items = Array(items.prefix(maxItems))
        }
        save(items)
    }

    func fetchAll() -> [NotificationItem] {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else {
            return []
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return (try? decoder.decode([CodableNotificationItem].self, from: data))?
            .map { $0.toDomain() } ?? []
    }

    private func save(_ items: [NotificationItem]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let codable = items.map { CodableNotificationItem(domain: $0) }
        if let data = try? encoder.encode(codable) {
            UserDefaults.standard.set(data, forKey: storageKey)
        }
    }
}

// MARK: - Codable Wrapper

private struct CodableNotificationItem: Codable {
    let id: UUID
    let date: Date
    let type: NotificationItem.NotificationType
    let storyId: String?
    let storyTitle: String?
    let count: Int?

    init(domain: NotificationItem) {
        self.id = domain.id
        self.date = domain.date
        self.type = domain.type
        self.storyId = domain.storyId
        self.storyTitle = domain.storyTitle
        self.count = domain.count
    }

    func toDomain() -> NotificationItem {
        NotificationItem(
            id: id,
            date: date,
            type: type,
            storyId: storyId,
            storyTitle: storyTitle,
            count: count
        )
    }
}
