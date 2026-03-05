//
//  DiscoverNearbyStoriesUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Combine
import Foundation

final class DiscoverNearbyStoriesUseCaseImpl: DiscoverNearbyStoriesUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol
    private let subject = PassthroughSubject<[Story], Never>()
    private var cancellables = Set<AnyCancellable>()
    private var lastLatitude: Double?
    private var lastLongitude: Double?

    var nearbyStoriesPublisher: AnyPublisher<[Story], Never> {
        subject.eraseToAnyPublisher()
    }

    init(storyRepository: StoryRepositoryProtocol) {
        self.storyRepository = storyRepository
        setupRepositorySubscription()
    }

    private func setupRepositorySubscription() {
        storyRepository.storiesUpdatePublisher
            .sink { [weak self] _ in
                guard let self,
                      let lat = self.lastLatitude,
                      let lon = self.lastLongitude else { return }
                Task { await self.refreshNearbyStories(latitude: lat, longitude: lon) }
            }
            .store(in: &cancellables)
    }

    func refreshNearbyStories(latitude: Double, longitude: Double) async {
        lastLatitude = latitude
        lastLongitude = longitude
        do {
            let stories = try await storyRepository.fetchAllStories()
            let nearby = stories.filter {
                abs($0.latitude - latitude) < 0.005 && abs($0.longitude - longitude) < 0.005
            }
            subject.send(nearby)
        } catch {
            // Política de errores: por ahora silencioso
        }
    }
}
