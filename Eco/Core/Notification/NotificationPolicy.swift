//
//  NotificationPolicy.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Filtro anti-spam: dedupe persistente, rate limiting.
//

import Foundation

enum NotificationPolicy {
    private static let notifiedStoriesKey = "eco.notifiedStories"
    private static let lastNotificationDateKey = "eco.lastNotificationDate"
    private static let dailyCountKey = "eco.proximityDailyCount"
    private static let dailyCountDateKey = "eco.proximityDailyCountDate"

    /// Límite diario: evita saturar; subir con cuidado (producto “poco ruido”).
    static let maxPerDay = 8
    /// Entre avisos distintos: suficiente para no vibrar en bucle al límite de una geocerca, pero permite varios Ecos en una caminata.
    static let minIntervalSeconds: TimeInterval = 60 * 4
    static let dedupeHours = 24

    /// Devuelve los storyIds que pueden notificarse (filtrados por dedupe).
    static func filterEligible(storyIds: [String]) -> [String] {
        let notified = loadNotifiedStories()
        let cutoff = Date().addingTimeInterval(-TimeInterval(dedupeHours * 3600))
        return storyIds.filter { id in
            guard let date = notified[id] else { return true }
            return date < cutoff
        }
    }

    /// ¿Podemos enviar una notificación ahora? (rate limit)
    static func canSendNow() -> Bool {
        let (count, date) = loadDailyState()
        let now = Date()
        if !Calendar.current.isDate(date, inSameDayAs: now) {
            return true
        }
        if count >= maxPerDay { return false }
        guard let last = UserDefaults.standard.object(forKey: lastNotificationDateKey) as? Date else {
            return true
        }
        return now.timeIntervalSince(last) >= minIntervalSeconds
    }

    /// Registra que notificamos estos storyIds y actualiza rate limit.
    static func recordNotification(storyIds: [String]) {
        let now = Date()
        var notified = loadNotifiedStories()
        for id in storyIds {
            notified[id] = now
        }
        saveNotifiedStories(notified)

        UserDefaults.standard.set(now, forKey: lastNotificationDateKey)
        let (count, date) = loadDailyState()
        if Calendar.current.isDate(date, inSameDayAs: now) {
            UserDefaults.standard.set(count + 1, forKey: dailyCountKey)
        } else {
            UserDefaults.standard.set(1, forKey: dailyCountKey)
            UserDefaults.standard.set(now, forKey: dailyCountDateKey)
        }
    }

    private static func loadNotifiedStories() -> [String: Date] {
        guard let data = UserDefaults.standard.data(forKey: notifiedStoriesKey) else { return [:] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        guard let decoded = try? decoder.decode([String: Date].self, from: data) else { return [:] }
        return decoded
    }

    private static func saveNotifiedStories(_ dict: [String: Date]) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        let data = (try? encoder.encode(dict)) ?? Data()
        UserDefaults.standard.set(data, forKey: notifiedStoriesKey)
    }

    private static func loadDailyState() -> (count: Int, date: Date) {
        let count = UserDefaults.standard.integer(forKey: dailyCountKey)
        let date = UserDefaults.standard.object(forKey: dailyCountDateKey) as? Date ?? Date.distantPast
        return (count, date)
    }
}
