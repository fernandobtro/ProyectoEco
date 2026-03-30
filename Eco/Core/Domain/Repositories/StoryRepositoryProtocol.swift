//
//  StoryRepositoryProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/02/26.
//
//  Purpose: Repository boundary for Story (Domain defines, Data implements).
//

import Combine
import Foundation

/// Repository boundary for Story (Domain defines, Data implements).
protocol StoryRepositoryProtocol {
    var storiesUpdatePublisher: AnyPublisher<Void, Never> { get }
    func notifyStoriesUpdated()
    func fetchAllStories() async throws -> [Story]
    func fetchAllStoriesSortedByUpdatedAtDesc() async throws -> [Story]
    /// Active non-deleted stories by `authorID`, stable sort (`updatedAt` desc, then `id` desc), for pagination.
    func fetchPlantedStories(authorID: String, limit: Int, offset: Int) async throws -> [Story]
    /// Active stories (`deletedAt == nil`) inside the inclusive geographic rectangle (pre-filter before distance logic).
    func fetchActiveStoriesInBoundingBox(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async throws -> [Story]
    func fetchStory(by id: UUID) async throws -> Story?
    func createStory(_ story: Story) async throws
    func updateStory(_ story: Story) async throws
    /// No-op when no local row exists (doesn't throw).
    func delete(storyID: UUID) async throws
}
