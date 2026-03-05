//
//  MapViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Combine
import Foundation
import MapKit

@MainActor
class MapViewModel: ObservableObject {
    @Published var region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
    
    @Published var nearbyStories: [Story] = []
    
    private var cancellables = Set<AnyCancellable>()
    private let discoverUseCase: DiscoverNearbyStoriesUseCaseProtocol
    private let discoveryController: LocationDiscoveryControlling

    init(discoverUseCase: DiscoverNearbyStoriesUseCaseProtocol, discoveryController: LocationDiscoveryControlling) {
        self.discoverUseCase = discoverUseCase
        self.discoveryController = discoveryController
        setupSubscriptions()
        Task { await discoveryController.requestPermission() }
        discoveryController.startDiscovery()
    }

    private func setupSubscriptions() {
        discoverUseCase.nearbyStoriesPublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] stories in
                self?.nearbyStories = stories
                print("MapViewModel: Recibidas \(stories.count) historias cercanas")
            }
            .store(in: &cancellables)
    }
}
