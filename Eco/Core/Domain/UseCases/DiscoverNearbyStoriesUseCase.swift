//
//  DiscoverNearbyStoriesUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation

protocol DiscoverNearbyStoriesUseCaseProtocol {
    /// Flujo de historias cercanas. Consumir con `for await stories in useCase.nearbyStories()`.
    func nearbyStories() -> AsyncStream<[Story]>
    func refreshNearbyStories(latitude: Double, longitude: Double) async
}
