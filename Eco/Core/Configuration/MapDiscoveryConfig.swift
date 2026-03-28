//
//  MapDiscoveryConfig.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Central place for map discovery numbers so you can tune behavior without touching use case code.
//
//  Responsibilities:
//  - Near user radius and how many stories or pins to load or draw.
//  - Camera debounce, minimum meaningful move, and how often explore mode refetches when the view stays put.
//

import Foundation

struct MapDiscoveryConfig: Sendable {
    // MARK: - Tuning
    var nearUserRadiusMeters: Double
    var maxExplorationSpanDegrees: Double
    var maxExploreStoryFetch: Int
    var maxVisiblePins: Int
    var exploreCameraDebounceMilliseconds: UInt64
    var cameraMeaningfulChangeEpsilonDegrees: Double
    var exploreStaleRefetchIntervalSeconds: TimeInterval

    // MARK: - Default
    static let `default` = MapDiscoveryConfig(
        nearUserRadiusMeters: 220,
        maxExplorationSpanDegrees: 22,
        maxExploreStoryFetch: 100,
        maxVisiblePins: 100,
        exploreCameraDebounceMilliseconds: 120,
        cameraMeaningfulChangeEpsilonDegrees: 0.0005,
        exploreStaleRefetchIntervalSeconds: 120
    )
}
