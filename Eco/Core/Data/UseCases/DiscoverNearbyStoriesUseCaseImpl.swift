//
//  DiscoverNearbyStoriesUseCaseImpl.swift
//  Eco
//

import Combine
import Foundation

@MainActor
final class DiscoverNearbyStoriesUseCaseImpl: DiscoverNearbyStoriesUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol
    private var continuation: AsyncStream<[Story]>.Continuation?
    private var cancellables = Set<AnyCancellable>()
    private var lastLatitude: Double?
    private var lastLongitude: Double?

    init(storyRepository: StoryRepositoryProtocol) {
        self.storyRepository = storyRepository
        setupRepositorySubscription()
    }

    func nearbyStories() -> AsyncStream<[Story]> {
        AsyncStream<[Story]> { [weak self] continuation in
            self?.continuation = continuation
        }
    }

    private func setupRepositorySubscription() {
        storyRepository.storiesUpdatePublisher
            .receive(on: DispatchQueue.main)
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
            continuation?.yield(nearby)
        } catch {
            // Política de errores: por ahora silencioso
        }
    }
}
