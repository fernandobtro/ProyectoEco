//
//  MapViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation
import MapKit
import Observation

@MainActor
@Observable
class MapViewModel {
    var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    var nearbyStories: [Story] = []
    
    private let discoverUseCase: DiscoverNearbyStoriesUseCaseProtocol
    private let discoveryController: LocationDiscoveryControlling

    init(discoverUseCase: DiscoverNearbyStoriesUseCaseProtocol, discoveryController: LocationDiscoveryControlling) {
        self.discoverUseCase = discoverUseCase
        self.discoveryController = discoveryController
    }

    /// Llamar desde la vista en `.task { await viewModel.onAppear() }`.
    func onAppear() async {
        await discoveryController.requestPermission()
        discoveryController.startDiscovery()

        // Consumir el flujo de historias cercanas en segundo plano
        Task {
            for await stories in discoverUseCase.nearbyStories() {
                self.nearbyStories = stories
            }
        }

        // Bootstrap: primera carga con el centro actual del mapa
        await discoverUseCase.refreshNearbyStories(latitude: region.center.latitude, longitude: region.center.longitude)
    }
}
