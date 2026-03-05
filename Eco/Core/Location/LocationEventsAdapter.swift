//
//  LocationEventsAdapter.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Foundation

/// Conecta eventos del LocationService (infraestructura) con los casos de uso de dominio.
final class LocationEventsAdapter: NSObject, LocationServiceDelegate, LocationDiscoveryControlling {
    private let locationService: LocationServiceProtocol
    private let discoverNearbyStoriesUseCase: DiscoverNearbyStoriesUseCaseProtocol
    private let trackProgressOnStoryEntryUseCase: TrackUserProgressOnStoryEntryUseCaseProtocol

    init(
        locationService: LocationServiceProtocol,
        discoverNearbyStoriesUseCase: DiscoverNearbyStoriesUseCaseProtocol,
        trackProgressOnStoryEntryUseCase: TrackUserProgressOnStoryEntryUseCaseProtocol
    ) {
        self.locationService = locationService
        self.discoverNearbyStoriesUseCase = discoverNearbyStoriesUseCase
        self.trackProgressOnStoryEntryUseCase = trackProgressOnStoryEntryUseCase
        super.init()
        self.locationService.delegate = self
    }

    func startDiscovery() {
        locationService.startMonitoring(stories: [])
    }

    func requestPermission() async {
        try? await locationService.requestPermission()
    }

    func didEnterStoryRegion(id: UUID) {
        Task { await trackProgressOnStoryEntryUseCase.execute(storyId: id) }
    }

    func didUpdateLocation(latitude: Double, longitude: Double) {
        Task { await discoverNearbyStoriesUseCase.refreshNearbyStories(latitude: latitude, longitude: longitude) }
    }

    func didFailWithError(_ error: Error) {
        // Política de errores: por ahora silencioso
    }
}
