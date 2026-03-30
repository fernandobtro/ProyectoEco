//
//  AppRouter.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Observable story-id and open-map flags for cold launch, notifications, and `DeepLink` handling.
//

import Foundation
import Observation

// MARK: - Router
/// Singleton router, `RootView` and `AppDelegate` consume pending ids once the UI is ready.
@MainActor
@Observable
final class AppRouter {
    // MARK: - Shared Access
    static let shared = AppRouter()

    // MARK: - Navigation State
    var activeStoryID: String?
    private(set) var pendingStoryID: String?
    var openMapRequested = false
    private(set) var pendingOpenMap = false

    // MARK: - Init
    private init() {}

    // MARK: - Public Navigation
    func handle(_ deepLink: DeepLink) {
        switch deepLink {
        case .storyDetail(let id):
            activeStoryID = id
        case .openMap:
            openMapRequested = true
        }
    }

    func setPendingOpenMap(_ value: Bool) {
        pendingOpenMap = value
    }

    func consumePendingOpenMap() -> Bool {
        defer { pendingOpenMap = false }
        return pendingOpenMap
    }

    func clearOpenMapRequest() {
        openMapRequested = false
    }

    func setPendingStoryID(_ id: String?) {
        pendingStoryID = id
    }

    func consumePendingStoryID() -> String? {
        defer { pendingStoryID = nil }
        return pendingStoryID
    }

    func dismissStoryDetail() {
        activeStoryID = nil
    }
}
