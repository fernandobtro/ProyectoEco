//
//  MapViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Map UI state, pins, discovery mode, and subscription to the nearby-stories stream.
//

import CoreLocation
import Foundation
import MapKit
import Observation
import SwiftUI

// MARK: - Pin Tap Outcome

/// Result of interpreting a pin tap (select vs open reader on second tap).
enum MapPinTapOutcome {
    case selected
    case shouldOpenReader
}

// MARK: - Map View Model

/// Owns the map camera, pins, discovery mode, and the nearby-stories flow.
///
/// - Important: Call ``onAppear()`` when the map appears, and ``onMapCameraChanged(region:)`` when SwiftUI reports camera updates.
/// - SeeAlso: `docs/EcoCorePipelines.md` — **Map Story Discovery Pipeline**.
@MainActor
@Observable
class MapViewModel {

    // MARK: - Nested Types

    /// One map pin: story id, coordinate, sync flag, and horizontal label offset.
    struct StoryAnnotation: Identifiable {
        let id: UUID
        let coordinate: CLLocationCoordinate2D
        let isSynced: Bool
        let horizontalScreenOffset: CGFloat
    }
    private static let cameraFallbackRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        span: MKCoordinateSpan(latitudeDelta: 0.08, longitudeDelta: 0.08)
    )

    // MARK: - State
    var cameraPosition: MapKit.MapCameraPosition = .userLocation(
        fallback: .region(cameraFallbackRegion)
    )

    var nearbyStories: [Story] = []

    private(set) var selectedStoryId: UUID?
    private var lastPinSurfaceInteractionAt: Date?
    private static let mapBackgroundTapIgnoresPinWithinSeconds: TimeInterval = 0.12

    private var lastOpenReaderEmittedAt: Date = .distantPast
    private static let openReaderDebounceSeconds: TimeInterval = 0.15
    private var lastMapReaderDismissedAt: Date?
    private static let suppressOpenReaderAfterDismissSeconds: TimeInterval = 0.2

    var pendingPlanting: (coordinate: CLLocationCoordinate2D, storyId: UUID)?

    private(set) var mapDiscoveryMode: MapDiscoveryMode = .nearUser

    private var hasStartedDiscovery = false
    private var storiesTask: Task<Void, Never>?
    private var hasPerformedInitialPull = false

    private var isProgrammaticCameraChange = false

    private var pendingInitialCameraSuppression = true

    private var lastCameraRegionForComparison: MKCoordinateRegion?

    private var exploreDebounceTask: Task<Void, Never>?
    private var latestExplorationRegion: MKCoordinateRegion?

    private var lastRegionUsedForExploreFetch: MKCoordinateRegion?

    private var lastExploreFetchAt: Date?

    // MARK: - Dependencies
    private let mapDiscoveryConfig: MapDiscoveryConfig
    private let discoverUseCase: DiscoverNearbyStoriesUseCaseProtocol
    private let discoveryController: LocationDiscoveryControlling
    private let locationService: LocationServiceProtocol
    private let syncStoriesUseCase: SyncStoriesUseCase
    private let getStoriesForGeofencingUseCase: GetStoriesForGeofencingUseCaseProtocol
    private let geofencingService: GeofencingService

    // MARK: - Derived UI
    var showExploreTheMapHint: Bool {
        guard mapDiscoveryMode == .exploring else { return false }
        guard locationService.lastKnownCoordinate != nil else { return false }
        guard resolvedExplorationRegionForRefresh() == nil else { return false }
        return nearbyStories.isEmpty
    }

    var annotations: [StoryAnnotation] {
        Self.spreadCollocatedAnnotations(storiesOrderedForMapDisplay())
    }

    var selectedStory: Story? {
        guard let selectedStoryId else { return nil }
        return nearbyStories.first { $0.id == selectedStoryId }
    }

    var selectedStoryDistanceMeters: CLLocationDistance? {
        guard let story = selectedStory,
              let coord = locationService.lastKnownCoordinate else { return nil }
        let userLoc = CLLocation(latitude: coord.latitude, longitude: coord.longitude)
        let storyLoc = CLLocation(latitude: story.latitude, longitude: story.longitude)
        return userLoc.distance(from: storyLoc)
    }

    // MARK: - Init
    init(
        discoverUseCase: DiscoverNearbyStoriesUseCaseProtocol,
        discoveryController: LocationDiscoveryControlling,
        locationService: LocationServiceProtocol,
        mapDiscoveryConfig: MapDiscoveryConfig,
        syncStoriesUseCase: SyncStoriesUseCase,
        getStoriesForGeofencingUseCase: GetStoriesForGeofencingUseCaseProtocol,
        geofencingService: GeofencingService
    ) {
        self.discoverUseCase = discoverUseCase
        self.discoveryController = discoveryController
        self.locationService = locationService
        self.mapDiscoveryConfig = mapDiscoveryConfig
        self.syncStoriesUseCase = syncStoriesUseCase
        self.getStoriesForGeofencingUseCase = getStoriesForGeofencingUseCase
        self.geofencingService = geofencingService
    }

    // MARK: - Lifecycle
    /// First load: pull from the server, ask for location, subscribe to the story stream. When you come back to the tab, fixes camera/mode if needed.
    func onAppear() async {
        clearStorySelection()
        let isReturn = hasStartedDiscovery

        if !hasPerformedInitialPull {
            hasPerformedInitialPull = true
            await syncStoriesUseCase.executeWithFullRemotePull()
        }

        if !hasStartedDiscovery {
            await discoveryController.requestPermission()
            discoveryController.startDiscovery()
            hasStartedDiscovery = true

            storiesTask = Task { [weak self] in
                guard let self else { return }
                for await stories in discoverUseCase.nearbyStories() {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self.nearbyStories = stories
                    }
                    #if DEBUG
                    self.logDiscoveryDebug(pinsShown: stories.count)
                    #endif
                }
            }
        }

        pendingInitialCameraSuppression = true
        lastCameraRegionForComparison = nil

        if isReturn {
            if mapDiscoveryMode == .exploring {
                applyMapDiscoveryMode(.nearUser)
                latestExplorationRegion = nil
                cameraPosition = .userLocation(fallback: .region(Self.cameraFallbackRegion))
                isProgrammaticCameraChange = true
                #if DEBUG
                print("[MapViewModel] return from exploring - reset to nearUser")
                #endif
            } else if let region = cameraPosition.region,
                      max(region.span.latitudeDelta, region.span.longitudeDelta) > 5 {
                cameraPosition = .userLocation(fallback: .region(Self.cameraFallbackRegion))
                isProgrammaticCameraChange = true
                #if DEBUG
                print("[MapViewModel] recenter: huge span corrected on return")
                #endif
            }
        }
        await refreshDiscovery()

        if nearbyStories.isEmpty,
           mapDiscoveryMode == .exploring,
           resolvedExplorationRegionForRefresh() == nil,
           locationService.lastKnownCoordinate != nil {
            applyMapDiscoveryMode(.nearUser)
            await refreshDiscovery()
        }

        await updateGeofencingRegions()

        Task { [weak self] in
            try? await Task.sleep(nanoseconds: 600_000_000)
            await MainActor.run {
                self?.pendingInitialCameraSuppression = false
            }
        }
    }

    /// Location control: switch to near-me mode and center on the user (with a fallback region if needed).
    func userRequestedRecenter() async {
        pendingInitialCameraSuppression = false
        lastCameraRegionForComparison = nil
        lastRegionUsedForExploreFetch = nil
        lastExploreFetchAt = nil
        clearStorySelection()
        isProgrammaticCameraChange = true
        applyMapDiscoveryMode(.nearUser)
        cameraPosition = .userLocation(fallback: .region(Self.cameraFallbackRegion))
        await refreshDiscovery()
        await updateGeofencingRegions()
    }

    /// Called after camera moves, may switch to explore mode and refresh pins after a short delay.
    func onMapCameraChanged(region: MKCoordinateRegion) {
        let span = max(region.span.latitudeDelta, region.span.longitudeDelta)
        guard span <= 5 else {
            #if DEBUG
            print("[MapViewModel] ignore camera change huge span=\(span)")
            #endif
            return
        }

        if isProgrammaticCameraChange {
            isProgrammaticCameraChange = false
            lastCameraRegionForComparison = region
            return
        }
        if pendingInitialCameraSuppression {
            pendingInitialCameraSuppression = false
            lastCameraRegionForComparison = region
            return
        }

        guard hasMeaningfulCameraChange(from: lastCameraRegionForComparison, to: region) else { return }

        clearStorySelection()

        guard locationService.lastKnownCoordinate != nil else {
            lastCameraRegionForComparison = region
            return
        }

        lastCameraRegionForComparison = region
        applyMapDiscoveryMode(.exploring)

        latestExplorationRegion = region
        exploreDebounceTask?.cancel()
        let debounceMs = mapDiscoveryConfig.exploreCameraDebounceMilliseconds
        exploreDebounceTask = Task(priority: .userInitiated) { @MainActor [weak self] in
            guard let self else { return }
            try? await Task.sleep(nanoseconds: debounceMs * 1_000_000)
            guard !Task.isCancelled else { return }
            guard let region = self.latestExplorationRegion else { return }
            await self.discoverUseCase.refreshForVisibleBounds(region.toVisibleBounds())
            self.lastRegionUsedForExploreFetch = region
            self.lastExploreFetchAt = Date()
            #if DEBUG
            let span = max(region.span.latitudeDelta, region.span.longitudeDelta)
            print("[MapDiscovery] explore refresh span=\(String(format: "%.4f", span))°")
            #endif
        }
    }

    // MARK: - Public API
    /// Reloads pins for the current mode (GPS or visible area), cancels any pending explore refresh.
    func refreshDiscovery() async {
        exploreDebounceTask?.cancel()
        await runRefreshDiscoveryWithPriority()
    }

    /// Reloads map stories and geofencing regions in one call (used by pull-to-refresh style flows).
    func refreshStories() async {
        await refreshDiscovery()
        await updateGeofencingRegions()
    }

    /// First tap selects the pin, a second tap on the same pin may open the reader, with short debounce windows.
    func handlePinTap(storyId: UUID) -> MapPinTapOutcome? {
        let now = Date()
        lastPinSurfaceInteractionAt = now

        if selectedStoryId == storyId {
            if let dismissedAt = lastMapReaderDismissedAt,
               now.timeIntervalSince(dismissedAt) < Self.suppressOpenReaderAfterDismissSeconds {
                return nil
            }
            guard now.timeIntervalSince(lastOpenReaderEmittedAt) > Self.openReaderDebounceSeconds else {
                return nil
            }
            lastOpenReaderEmittedAt = now
            return .shouldOpenReader
        }
        selectedStoryId = storyId
        return .selected
    }

    /// Clears the selected pin (e.g. tap on the map background).
    func clearStorySelection() {
        selectedStoryId = nil
    }

    /// Call from the map reader’s `onDismiss` so a leftover tap doesn’t reopen it right away.
    func recordMapReaderDismissed() {
        lastMapReaderDismissedAt = Date()
    }

    /// Starts the planting animation after creating a story from the sheet.
    func queuePlantingAnimation(coordinate: CLLocationCoordinate2D, storyId: UUID) {
        pendingPlanting = (coordinate: coordinate, storyId: storyId)
    }

    /// Call when the animation ends to clear pending state.
    func completePlantingAnimation() {
        pendingPlanting = nil
    }

    /// `true` briefly after a pin tap so the same touch isn’t read as a background tap.
    func shouldIgnoreMapBackgroundTap() -> Bool {
        guard let lastPinInteractionAt = lastPinSurfaceInteractionAt else { return false }
        return Date().timeIntervalSince(lastPinInteractionAt) < Self.mapBackgroundTapIgnoresPinWithinSeconds
    }

    // MARK: - Private Helpers

    /// Executes discovery refresh at `.userInitiated` priority and keeps mode-specific rules centralized.
    ///
    /// Near-user mode uses current GPS (or clears when no GPS and no data yet). Explore mode only fetches when
    /// bounds exist and either the region changed meaningfully or the previous fetch is considered stale.
    private func runRefreshDiscoveryWithPriority() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            Task(priority: .userInitiated) { @MainActor [weak self] in
                defer { continuation.resume() }
                guard let self else { return }
                self.discoverUseCase.setDiscoveryMode(self.mapDiscoveryMode)
                switch self.mapDiscoveryMode {
                case .nearUser:
                    if let gps = self.locationService.lastKnownCoordinate {
                        await self.discoverUseCase.refreshNearUser(latitude: gps.latitude, longitude: gps.longitude)
                    } else if self.nearbyStories.isEmpty {
                        await self.discoverUseCase.clearDisplayedStories()
                    }
                case .exploring:
                    if let region = self.resolvedExplorationRegionForRefresh() {
                        let stale = self.isExploreFetchConsideredStale()
                        let regionChanged = self.hasMeaningfulCameraChange(from: self.lastRegionUsedForExploreFetch, to: region)
                        guard stale || regionChanged else {
                            break
                        }
                        await self.discoverUseCase.refreshForVisibleBounds(region.toVisibleBounds())
                        self.lastRegionUsedForExploreFetch = region
                        self.lastExploreFetchAt = Date()
                    }
                }
                #if DEBUG
                let debugRegion = self.resolvedExplorationRegionForRefresh()
                let span = debugRegion.map { max($0.span.latitudeDelta, $0.span.longitudeDelta) }
                print(
                    "[MapDiscovery] refresh mode=\(self.mapDiscoveryMode.rawValue) span=\(span.map { String(format: "%.4f", $0) } ?? "nil")°"
                )
                #endif
            }
        }
    }

    /// Best-effort region source for explore refreshes, preferring live camera, then latest observed regions.
    private func resolvedExplorationRegionForRefresh() -> MKCoordinateRegion? {
        cameraPosition.region ?? latestExplorationRegion ?? lastCameraRegionForComparison
    }

    /// Switches discovery mode and resets explore-specific cache/cursor state.
    private func applyMapDiscoveryMode(_ newMode: MapDiscoveryMode) {
        guard mapDiscoveryMode != newMode else { return }
        mapDiscoveryMode = newMode
        discoverUseCase.setDiscoveryMode(newMode)
        lastRegionUsedForExploreFetch = nil
        lastExploreFetchAt = nil
        clearStorySelection()
    }

    /// `true` when the last explore fetch is old enough to force a refresh even without camera movement.
    private func isExploreFetchConsideredStale() -> Bool {
        guard let lastExploreFetchTime = lastExploreFetchAt else { return true }
        return Date().timeIntervalSince(lastExploreFetchTime) > mapDiscoveryConfig.exploreStaleRefetchIntervalSeconds
    }

    /// Epsilon-based camera-change guard to ignore micro-movements from map rendering noise.
    private func hasMeaningfulCameraChange(from previous: MKCoordinateRegion?, to new: MKCoordinateRegion) -> Bool {
        guard let previous else { return true }
        let eps = mapDiscoveryConfig.cameraMeaningfulChangeEpsilonDegrees
        let dLat = abs(previous.center.latitude - new.center.latitude)
        let dLon = abs(previous.center.longitude - new.center.longitude)
        let dSpanLat = abs(previous.span.latitudeDelta - new.span.latitudeDelta)
        let dSpanLon = abs(previous.span.longitudeDelta - new.span.longitudeDelta)
        let dSpan = max(dSpanLat, dSpanLon)
        return max(dLat, dLon, dSpan) > eps
    }

    /// Returns stories sorted for pin rendering and capped to `maxVisiblePins`.
    ///
    /// Uses distance ordering when a reference coordinate exists (near-user or explore center),
    /// and a stable UUID fallback ordering otherwise.
    private func storiesOrderedForMapDisplay() -> [Story] {
        let limit = mapDiscoveryConfig.maxVisiblePins
        guard let ref = sortReferenceCoordinate() else {
            return nearbyStories
                .sorted { $0.id.uuidString < $1.id.uuidString }
                .prefix(limit)
                .map { $0 }
        }
        let refLoc = CLLocation(latitude: ref.latitude, longitude: ref.longitude)
        return nearbyStories
            .sorted { first, second in
                let distanceFirst = CLLocation(latitude: first.latitude, longitude: first.longitude).distance(from: refLoc)
                let distanceSecond = CLLocation(latitude: second.latitude, longitude: second.longitude).distance(from: refLoc)
                if distanceFirst != distanceSecond { return distanceFirst < distanceSecond }
                return first.id.uuidString < second.id.uuidString
            }
            .prefix(limit)
            .map { $0 }
    }

    /// Coordinate used for distance-based ordering depending on discovery mode.
    private func sortReferenceCoordinate() -> CLLocationCoordinate2D? {
        switch mapDiscoveryMode {
        case .nearUser:
            return locationService.lastKnownCoordinate
        case .exploring:
            return latestExplorationRegion?.center ?? cameraPosition.region?.center
        }
    }

    /// Spreads pins sharing the same rounded coordinate bucket to avoid full overlap on screen.
    private static func spreadCollocatedAnnotations(_ stories: [Story]) -> [StoryAnnotation] {
        let spacing: CGFloat = 20
        var nextSlot: [String: Int] = [:]
        var counts: [String: Int] = [:]
        for story in stories {
            let key = coordinateBucketKey(latitude: story.latitude, longitude: story.longitude)
            counts[key, default: 0] += 1
        }
        return stories.map { story in
            let key = coordinateBucketKey(latitude: story.latitude, longitude: story.longitude)
            let idx = nextSlot[key, default: 0]
            nextSlot[key] = idx + 1
            let total = counts[key] ?? 1
            let offset: CGFloat
            if total > 1 {
                offset = CGFloat(idx) * spacing - (CGFloat(total - 1) * spacing / 2)
            } else {
                offset = 0
            }
            return StoryAnnotation(
                id: story.id,
                coordinate: CLLocationCoordinate2D(latitude: story.latitude, longitude: story.longitude),
                isSynced: story.isSynced,
                horizontalScreenOffset: offset
            )
        }
    }

    /// Buckets coordinates using fixed precision so near-identical points collocate consistently.
    private static func coordinateBucketKey(latitude: Double, longitude: Double) -> String {
        String(format: "%.5f,%.5f", latitude, longitude)
    }

    #if DEBUG
    private func logDiscoveryDebug(pinsShown: Int) {
        let span = cameraPosition.region.map { max($0.span.latitudeDelta, $0.span.longitudeDelta) }
        print(
            "[MapDiscovery] stream mode=\(mapDiscoveryMode.rawValue) pins=\(pinsShown) span=\(span.map { String(format: "%.4f", $0) } ?? "nil")°"
        )
    }
    #endif

    /// Rebuilds geofencing regions from nearest stories to current location (best effort on failure).
    private func updateGeofencingRegions() async {
        guard let coordinate = locationService.lastKnownCoordinate else { return }
        do {
            let stories = try await getStoriesForGeofencingUseCase.execute(
                near: coordinate,
                limit: 20
            )
            geofencingService.startMonitoring(stories: stories)
        } catch {
            #if DEBUG
            print("[MapViewModel] updateGeofencingRegions error: \(error.localizedDescription)")
            #endif
        }
    }
}
