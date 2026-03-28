//
//  StoryRepositoryProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/02/26.
//

import Combine
import Foundation

protocol StoryRepositoryProtocol {
    var storiesUpdatePublisher: AnyPublisher<Void, Never> { get }
    func notifyStoriesUpdated()
    func fetchAllStories() async throws -> [Story]
    func fetchAllStoriesSortedByUpdatedAtDesc() async throws -> [Story]
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
    /// Si no hay fila local para esa id, no hace nada y no lanza error.
    func delete(storyID: UUID) async throws
}
