//
//  MapViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation
import MapKit
import Observation
import SwiftUI

@MainActor
@Observable
class MapViewModel {

    struct StoryAnnotation: Identifiable {
        let id: UUID
        let coordinate: CLLocationCoordinate2D
        let isSynced: Bool
    }

    private let defaultRegion = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
        span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
    )

    var cameraPosition: MapKit.MapCameraPosition = .userLocation(
        fallback: .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332),
                span: MKCoordinateSpan(latitudeDelta: 0.002, longitudeDelta: 0.002)
            )
        )
    )

    var nearbyStories: [Story] = []

    var annotations: [StoryAnnotation] {
        nearbyStories.map {
            StoryAnnotation(
                id: $0.id,
                coordinate: CLLocationCoordinate2D(
                    latitude: $0.latitude,
                    longitude: $0.longitude
                ),
                isSynced: $0.isSynced
            )
        }
    }

    private let discoverUseCase: DiscoverNearbyStoriesUseCaseProtocol
    private let discoveryController: LocationDiscoveryControlling
    private let syncPullStoriesUseCase: SyncPullStoriesUseCaseProtocol
    private var hasStartedDiscovery = false
    private var storiesTask: Task<Void, Never>?
    private var lastKnownCoordinate: CLLocationCoordinate2D?
    private var hasPerformedInitialPull = false

    init(
        discoverUseCase: DiscoverNearbyStoriesUseCaseProtocol,
        discoveryController: LocationDiscoveryControlling,
        syncPullStoriesUseCase: SyncPullStoriesUseCaseProtocol
    ) {
        self.discoverUseCase = discoverUseCase
        self.discoveryController = discoveryController
        self.syncPullStoriesUseCase = syncPullStoriesUseCase
    }

    func onAppear() async {
        if !hasPerformedInitialPull {
            hasPerformedInitialPull = true
            await syncPullStoriesUseCase.execute(since: nil)
        }

        if !hasStartedDiscovery {
            await discoveryController.requestPermission()
            discoveryController.startDiscovery()
            hasStartedDiscovery = true

            // Escuchar historias cercanas una sola vez.
            storiesTask = Task { [weak self] in
                guard let self else { return }
                for await stories in discoverUseCase.nearbyStories() {
                    withAnimation(.easeInOut(duration: 0.25)) {
                        self.nearbyStories = stories
                    }
                }
            }
        }

        await refreshStories()
    }

    // 🔁 Útil si quieres refrescar manualmente
    func refreshStories() async {
        if let region = cameraPosition.region {
            let center = region.center
            lastKnownCoordinate = center
            await discoverUseCase.refreshNearbyStories(
                latitude: center.latitude,
                longitude: center.longitude
            )
            return
        }

        if let last = lastKnownCoordinate {
            await discoverUseCase.refreshNearbyStories(
                latitude: last.latitude,
                longitude: last.longitude
            )
            return
        }

        // Fallback sólo si nunca hemos tenido una coordenada real
        let fallbackCenter = defaultRegion.center
        lastKnownCoordinate = fallbackCenter
        await discoverUseCase.refreshNearbyStories(
            latitude: fallbackCenter.latitude,
            longitude: fallbackCenter.longitude
        )
    }
}
