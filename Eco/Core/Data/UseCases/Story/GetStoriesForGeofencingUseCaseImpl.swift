//
//  GetStoriesForGeofencingUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Implements `GetStoriesForGeofencingUseCase` using repositories and async side effects.
//

import CoreLocation
import Foundation

/// Implements `GetStoriesForGeofencingUseCase` using repositories and async side effects.
final class GetStoriesForGeofencingUseCaseImpl: GetStoriesForGeofencingUseCaseProtocol {
    private let storyRepository: StoryRepositoryProtocol

    /// Prefetch radius around the user before sorting, must cover monitored regions (see `GeofencingService`).
    private static let prefetchRadiusMeters: Double = 5000

    init(storyRepository: StoryRepositoryProtocol) {
        self.storyRepository = storyRepository
    }

    func execute(near coordinate: CLLocationCoordinate2D, limit: Int) async throws -> [Story] {
        let box = GeographicBounds.boundingBox(
            centerLatitude: coordinate.latitude,
            centerLongitude: coordinate.longitude,
            radiusMeters: Self.prefetchRadiusMeters
        )
        let candidates = try await storyRepository.fetchActiveStoriesInBoundingBox(
            minLatitude: box.minLatitude,
            maxLatitude: box.maxLatitude,
            minLongitude: box.minLongitude,
            maxLongitude: box.maxLongitude
        )
        let userLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return candidates
            .sorted { $0.distance(to: userLocation) < $1.distance(to: userLocation) }
            .prefix(limit)
            .map { $0 }
    }
}
