//
//  DiscoverNearbyStoriesUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Map discovery use case contract (near user vs explore).
//

import Foundation

/// Contract for map-side discovery, implementation pushes updates through ``nearbyStories()``.
///
/// Narrative: `docs/EcoCorePipelines.md` — **Map Story Discovery Pipeline**.
protocol DiscoverNearbyStoriesUseCaseProtocol {
    // MARK: - Stream
    /// Stories over time. Each call installs a new stream connection, the latest one wins.
    func nearbyStories() -> AsyncStream<[Story]>

    // MARK: - Mode and Refresh
    /// Switches near-user versus explore behavior for later refreshes and repository replays.
    func setDiscoveryMode(_ mode: MapDiscoveryMode)

    /// Refetches within the near-user radius around this point and forgets any explore viewport snapshot.
    func refreshNearUser(latitude: Double, longitude: Double) async

    /// Refetches stories inside the bounds, capped by config. If the span is too wide, yields an empty list.
    func refreshForVisibleBounds(_ bounds: MapVisibleBounds) async

    /// Clears remembered coordinates and yields an empty list.
    func clearDisplayedStories() async

    /// For location adapters. Refreshes only while discovery mode is near-user, otherwise no-op.
    func onUserLocationUpdated(latitude: Double, longitude: Double) async

    /// Story IDs from the last successful yield, for follow-up features such as geofencing.
    func currentNearbyStoryIDs() -> [UUID]
}
