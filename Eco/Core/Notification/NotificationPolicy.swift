//
//  NotificationPolicy.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Anti-spam for proximity alerts: persistent dedupe keys and daily / inter-notification rate limits.
//

import Foundation

/// Decides which story IDs may notify and when (dedupe + rate caps).
enum NotificationPolicy {
    private static let notifiedStoriesKey = "eco.notifiedStories"
    private static let lastNotificationDateKey = "eco.lastNotificationDate"
    private static let dailyCountKey = "eco.proximityDailyCount"
    private static let dailyCountDateKey = "eco.proximityDailyCountDate"

    /// Max proximity notifications per calendar day (keep UX low-noise).
    static let maxPerDay = 8
    /// Minimum gap between distinct notifications (reduces buzz when hugging a geofence edge, still allows several stories on a walk).
    static let minIntervalSeconds: TimeInterval = 60 * 4
    static let dedupeHours = 24

    /// Story IDs that pass the rolling dedupe window.
    static func filterEligible(storyIds: [String]) -> [String] {
        let notified = loadNotifiedStories()
        let cutoff = Date().addingTimeInterval(-TimeInterval(dedupeHours * 3600))
        return storyIds.filter { id in
            guard let date = notified[id] else { return true }
            return date < cutoff
        }
    }

    /// Whether daily count and minimum interval allow another notification now.
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

    /// Persists dedupe timestamps and bumps daily / last-sent counters.
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
