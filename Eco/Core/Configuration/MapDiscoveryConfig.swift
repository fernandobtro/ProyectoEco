//
//  MapDiscoveryConfig.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Tunable map discovery limits (radii, caps, debounce) shared by `MapViewModel` and discover use cases.
//

import Foundation

/// Near-user and explore-mode thresholds, adjust here instead of scattering numbers.
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
