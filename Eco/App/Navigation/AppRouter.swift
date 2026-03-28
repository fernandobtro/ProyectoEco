//
//  AppRouter.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Global routing for deep links and notification handoff before or after `RootView` is ready.
//
//  Responsibilities:
//  - Hold the active story id, one-shot pending ids, and open-map flags for cold launch and runtime.
//  - Map `DeepLink` cases into observable state and expose consume-once helpers for startup.
//

import Foundation
import Observation

// MARK: - Router
@MainActor
@Observable
final class AppRouter {
    // MARK: - Shared access
    static let shared = AppRouter()

    // MARK: - Navigation state
    var activeStoryID: String?
    private(set) var pendingStoryID: String?
    var openMapRequested = false
    private(set) var pendingOpenMap = false

    // MARK: - Init
    private init() {}

    // MARK: - Public navigation methods
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
