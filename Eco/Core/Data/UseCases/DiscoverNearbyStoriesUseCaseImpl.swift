//
//  DiscoverNearbyStoriesUseCaseImpl.swift
//  Eco
//

import Combine
import CoreLocation
import Foundation

@MainActor
final class DiscoverNearbyStoriesUseCaseImpl: DiscoverNearbyStoriesUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol
    private var continuation: AsyncStream<[Story]>.Continuation?
    private var cancellables = Set<AnyCancellable>()
    private var lastLatitude: Double?
    private var lastLongitude: Double?
    private var lastNearbyStoryIDs: [UUID] = []

    init(storyRepository: StoryRepositoryProtocol) {
        self.storyRepository = storyRepository
        setupRepositorySubscription()
    }

    func nearbyStories() -> AsyncStream<[Story]> {
        AsyncStream<[Story]> { [weak self] continuation in
            self?.continuation = continuation
        }
    }

    func currentNearbyStoryIDs() -> [UUID] {
        lastNearbyStoryIDs
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
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            let maxDistance: CLLocationDistance = 50 // metros

            let nearby = stories.filter { story in
                let storyLocation = CLLocation(latitude: story.latitude, longitude: story.longitude)
                let distance = userLocation.distance(from: storyLocation)
                return distance <= maxDistance
            }
            lastNearbyStoryIDs = nearby.map(\.id)
            continuation?.yield(nearby)
        } catch {
            // Política de errores: por ahora silencioso
        }
    }
}
