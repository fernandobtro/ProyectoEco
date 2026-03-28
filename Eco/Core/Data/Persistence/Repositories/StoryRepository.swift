//
//  StoryRepository.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//
//  Purpose: Domain-focused repository managing story persistence, mapping and change notifications.
//  Responsabilities:
//  - Bridge between SwiftData entities and clean Domain Story models.
//  - Handle logical deleiton (soft delete) filtering for fetches.
//  - Broadcast data changes via Combine to keep the Map and Lists(Collection) reactive

import Combine
import Foundation

struct StoryRepository: StoryRepositoryProtocol {

    private let storyLocalDataSource: StoryLocalDataSourceProtocol
    
    // MARK: - Reactive State
    /// Internal subject to broadcast changes to any active listeners.
    private let updatesSubject = PassthroughSubject<Void, Never>()

    /// Public publisher to observe story db changes.
    var storiesUpdatePublisher: AnyPublisher<Void, Never> {
        updatesSubject.eraseToAnyPublisher()
    }
    
    // MARK: - Init
    init(storyLocalDataSource: StoryLocalDataSourceProtocol) {
        self.storyLocalDataSource = storyLocalDataSource
    }

    // MARK: - Public API
    /// Manually triggers the update publiser to refresh observers.
    func notifyStoriesUpdated() {
        updatesSubject.send(())
    }
    
    /// Fetches all stories that haven't been marked as deleted.
    /// - Returns: An array of domain ``Story`` models.
    func fetchAllStories() async throws -> [Story] {
        let entities = try await storyLocalDataSource.fetchActiveStories()
        return entities.map(StoryPersistenceMapper.toDomain)
    }
    
    /// Fetches all active stories ordered by their last update date (newest first), excluding logically deleted.
    /// - Returns: Sorted array of domain ``Story`` models.
    func fetchAllStoriesSortedByUpdatedAtDesc() async throws -> [Story] {
        let entities = try await storyLocalDataSource.fetchActiveStoriesSortedByUpdatedAtDescending()
        return entities.map(StoryPersistenceMapper.toDomain)
    }

    func fetchPlantedStories(authorID: String, limit: Int, offset: Int) async throws -> [Story] {
        let entities = try await storyLocalDataSource.fetchPlantedStories(
            authorID: authorID,
            limit: limit,
            offset: offset
        )
        return entities.map(StoryPersistenceMapper.toDomain)
    }

    func fetchActiveStoriesInBoundingBox(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async throws -> [Story] {
        let entities = try await storyLocalDataSource.fetchActiveStoriesInBoundingBox(
            minLatitude: minLatitude,
            maxLatitude: maxLatitude,
            minLongitude: minLongitude,
            maxLongitude: maxLongitude
        )
        return entities.map(StoryPersistenceMapper.toDomain)
    }

    /// Fetches a single story by its identifier, if it's not logically deleted
    /// - Parameter id: The UUID of the story.
    /// - Returns: A domain ``Story``if found, otherwise `nil`
    func fetchStory(by id: UUID) async throws -> Story? {
        #if DEBUG
        print("🗄️ [StoryRepository] fetchStory by id=\(id.uuidString)")
        #endif
        guard let entity = try await storyLocalDataSource.fetch(by: id),
              entity.deletedAt == nil else { return nil }
        #if DEBUG
        print("🗄️ [StoryRepository] fetchStory found remoteId=\(entity.remoteId ?? "nil") deletedAt=nil")
        #endif
        return StoryPersistenceMapper.toDomain(entity)
    }

    /// Creates a new story locally and triggers a reactive update.
    /// - Parameter story: The domain model to persist.
    func createStory(_ story: Story) async throws {
        let entity = StoryPersistenceMapper.toEntity(story, existing: nil)
        try await storyLocalDataSource.saveNew(story: entity)
        updatesSubject.send(())
    }

    /// Updates an existing story and broadcasts the change.
    /// - Parameter story: The updated domain model.
    /// - Throws: `EcoError.storyNotFound`if the ID doesn't exist in local storage.
    func updateStory(_ story: Story) async throws {
        guard let existing = try await storyLocalDataSource.fetch(by: story.id) else {
            throw EcoError.storyNotFound
        }
        StoryPersistenceMapper.toEntity(story, existing: existing)
        try await storyLocalDataSource.saveChanges()
        updatesSubject.send(())
    }

    /// Performs a soft delete and updates sync status for the SyncWorker
    ///
    /// Instead of removing the row, it sets `deletedAt`and marks the status as `pendingDelete` to ensure the change can be synchronized with the remote server.
    /// - Parameter storyId: The unique identifier of the story to delete.
    func delete(storyID: UUID) async throws {
        guard let entity = try await storyLocalDataSource.fetch(by: storyID) else { return }
        let now = Date()
        entity.deletedAt = now
        entity.updatedAt = now
        entity.syncStatus = .pendingDelete
        try await storyLocalDataSource.saveChanges()
        updatesSubject.send(())
    }
}
