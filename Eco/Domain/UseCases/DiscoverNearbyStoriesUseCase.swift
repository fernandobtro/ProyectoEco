//
//  DiscoverNearbyStoriesUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Combine
import Foundation

protocol DiscoverNearbyStoriesUseCaseProtocol {
    var nearbyStoriesPublisher: AnyPublisher<[Story], Never> { get }
    func refreshNearbyStories(latitude: Double, longitude: Double) async
}
