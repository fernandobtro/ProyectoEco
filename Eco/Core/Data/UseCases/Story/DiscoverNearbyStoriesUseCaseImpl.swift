//
//  DiscoverNearbyStoriesUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Keeps the map stream of stories aligned with the local repository and discovery mode.
//
//  Responsibilities:
//  - Filter by near user radius, visible bounds, span limits, and fetch or pin caps from config.
//  - Serialize refreshes, replay after repository updates, and push results into nearbyStories().
//

import Combine
import CoreLocation
import Foundation
import os

private let discoverNearbyStoriesLog = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "Eco",
    category: "DiscoverNearbyStories"
)

@MainActor
final class DiscoverNearbyStoriesUseCaseImpl: DiscoverNearbyStoriesUseCaseProtocol {
    // MARK: - State
    private let storyRepository: StoryRepositoryProtocol
    private let config: MapDiscoveryConfig
    private var continuation: AsyncStream<[Story]>.Continuation?
    private var cancellables = Set<AnyCancellable>()
    private var discoveryMode: MapDiscoveryMode = .nearUser
    private var lastNearLat: Double?
    private var lastNearLon: Double?
    private var lastBounds: MapVisibleBounds?
    private var lastNearbyStoryIDs: [UUID] = []
    private var isRefreshing = false
    private var pendingRefreshAfterCurrent = false

    // MARK: - Init
    init(storyRepository: StoryRepositoryProtocol, config: MapDiscoveryConfig) {
        self.storyRepository = storyRepository
        self.config = config
        setupRepositorySubscription()
    }

    // MARK: - Public API
    func nearbyStories() -> AsyncStream<[Story]> {
        AsyncStream { [weak self] continuation in
            self?.continuation = continuation
        }
    }

    func setDiscoveryMode(_ mode: MapDiscoveryMode) {
        discoveryMode = mode
    }

    func currentNearbyStoryIDs() -> [UUID] {
        lastNearbyStoryIDs
    }

    func clearDisplayedStories() async {
        lastNearLat = nil
        lastNearLon = nil
        lastBounds = nil
        lastNearbyStoryIDs = []
        continuation?.yield([])
    }

    func onUserLocationUpdated(latitude: Double, longitude: Double) async {
        guard discoveryMode == .nearUser else { return }
        await refreshNearUser(latitude: latitude, longitude: longitude)
    }

    func refreshNearUser(latitude: Double, longitude: Double) async {
        lastNearLat = latitude
        lastNearLon = longitude
        lastBounds = nil
        await runRefresh {
            let paddedRadius = self.config.nearUserRadiusMeters * 1.1
            let box = GeographicBounds.boundingBox(
                centerLatitude: latitude,
                centerLongitude: longitude,
                radiusMeters: paddedRadius
            )
            let candidates = try await self.storyRepository.fetchActiveStoriesInBoundingBox(
                minLatitude: box.minLatitude,
                maxLatitude: box.maxLatitude,
                minLongitude: box.minLongitude,
                maxLongitude: box.maxLongitude
            )
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            let nearby = candidates.filter { story in
                let storyLocation = CLLocation(latitude: story.latitude, longitude: story.longitude)
                return userLocation.distance(from: storyLocation) <= self.config.nearUserRadiusMeters
            }
            self.lastNearbyStoryIDs = nearby.map(\.id)
            self.continuation?.yield(nearby)
        }
    }

    func refreshForVisibleBounds(_ bounds: MapVisibleBounds) async {
        lastBounds = bounds
        await runRefresh {
            let latSpan = bounds.maxLatitude - bounds.minLatitude
            let lonSpan = bounds.maxLongitude - bounds.minLongitude
            let maxSpan = max(latSpan, lonSpan)
            guard maxSpan <= self.config.maxExplorationSpanDegrees else {
                self.lastNearbyStoryIDs = []
                self.continuation?.yield([])
                return
            }
            let inBounds = try await self.storyRepository.fetchActiveStoriesInBoundingBox(
                minLatitude: bounds.minLatitude,
                maxLatitude: bounds.maxLatitude,
                minLongitude: bounds.minLongitude,
                maxLongitude: bounds.maxLongitude
            )
            let capped = Array(inBounds.prefix(self.config.maxExploreStoryFetch))
            self.lastNearbyStoryIDs = capped.map(\.id)
            self.continuation?.yield(capped)
        }
    }

    // MARK: - Private helpers
    /// Replays the last near-user or explore inputs after local story data changes.
    private func replayAfterRepositoryUpdate() async {
        switch discoveryMode {
        case .nearUser:
            if let lat = lastNearLat, let lon = lastNearLon {
                await refreshNearUser(latitude: lat, longitude: lon)
            }
        case .exploring:
            if let visibleBounds = lastBounds {
                await refreshForVisibleBounds(visibleBounds)
            }
        }
    }

    /// Runs one refresh at a time. If another refresh is requested while work runs, it runs once afterward.
    /// On failure, the last successful stream value stays visible and the error is logged for diagnosis.
    private func runRefresh(_ work: @escaping () async throws -> Void) async {
        if isRefreshing {
            pendingRefreshAfterCurrent = true
            return
        }
        isRefreshing = true
        defer {
            isRefreshing = false
            if pendingRefreshAfterCurrent {
                pendingRefreshAfterCurrent = false
                Task { [weak self] in
                    guard let self else { return }
                    await self.replayAfterRepositoryUpdate()
                }
            }
        }
        do {
            try await work()
        } catch {
            discoverNearbyStoriesLog.error("Refresh failed: \(error.localizedDescription, privacy: .public)")
        }
    }

    private func setupRepositorySubscription() {
        storyRepository.storiesUpdatePublisher
            .debounce(for: .milliseconds(150), scheduler: RunLoop.main)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                Task { await self.replayAfterRepositoryUpdate() }
            }
            .store(in: &cancellables)
    }
}
