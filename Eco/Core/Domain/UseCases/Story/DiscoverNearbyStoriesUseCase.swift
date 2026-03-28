//
//  DiscoverNearbyStoriesUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Contract for which stories the map shows in near-user versus explore mode.
//
//  Responsibilities:
//  - Expose a stream of story arrays, switch discovery mode, and refresh by GPS or visible bounds.
//  - Support clearing pins and location-driven updates when the mode is near-user.
//

import Foundation

protocol DiscoverNearbyStoriesUseCaseProtocol {
    // MARK: - Stream
    /// Stories over time. Each call installs a new stream connection, the latest one wins.
    func nearbyStories() -> AsyncStream<[Story]>

    // MARK: - Mode and refresh
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
