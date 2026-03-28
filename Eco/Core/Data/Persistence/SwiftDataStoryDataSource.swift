//
//  SwiftDataStoryDataSource.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//
//  Purpose: Local SwiftData access for story entities and optimized spatial/batch queries.
//
//  - Persist and manage the lifecycle of StoryEntity objects.
//  - Execute batch fetches to support sync reconciliation.
//  - Perform spatial filtering via bounding boxes for map and geofencing discovery.
//

import Foundation
import SwiftData

@MainActor
class SwiftDataStoryDataSource: StoryLocalDataSourceProtocol {

    /// SwiftData `#Predicate` translation to SQL has overhead with large `IN` clauses.
    /// We chunk remote ID batches to stay within SQLite argument limits and maintain performance.
    private static let remoteIdFetchChunkSize = 200

    // MARK: - Dependencies
    private let modelContext: ModelContext
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Public API (CRUD)
    
    /// Inserts a new story entity to the context to persist it.
    /// - Parameter story: The ``StoryEntity`` instance to save.
    func saveNew(story: StoryEntity) async throws {
        modelContext.insert(story)
        try modelContext.save()
    }

    /// Persists any pending changes in the current model context.
    func saveChanges() async throws {
        try modelContext.save()
    }
    
    /// Fetches every story currently stored in the local database.
    /// - Returns: An array of ``StoryEntity`` objects.
    func fetchAll() async throws -> [StoryEntity] {
        let descriptor = FetchDescriptor<StoryEntity>()
        return try modelContext.fetch(descriptor)
    }

    /// Fetch an specific story by its local unque identifier.
    /// - Parameter id: The UUID of the story
    /// - Returns: The matching ``StoryEntity`` or nil if not found.
    func fetch(by id: UUID) async throws -> StoryEntity? {
        let predicate = #Predicate<StoryEntity> { story in
            story.id == id
        }

        let descriptor = FetchDescriptor<StoryEntity>(predicate: predicate)

        return try modelContext.fetch(descriptor).first
    }

    /// Removes a story from the database if it exists.
    /// - Parameter id: The UUID of the story to be deleted.
    func delete(id: UUID) async throws {
        if let storyToDelete = try await fetch(by: id) {
            modelContext.delete(storyToDelete)
            try modelContext.save()
        }
    }

    // MARK: - Sync Support
    
    /// Retrives stories that requiere synchronization with the remote server.
    /// Results are filtered by `syncStatus` and ordered chronologically (oldest first) to ensure logical consistentcy during the push process.
    /// - Returns: An array of pending ``StoryEntity``objects.
    func fetchPending() async throws -> [StoryEntity] {
        let descriptor = FetchDescriptor<StoryEntity>(
            predicate: #Predicate {
                $0.syncStatus != "synced"
            },
            sortBy: [SortDescriptor(\.updatedAt, order: .forward)]
        )
        return try modelContext.fetch(descriptor)
    }

    /// Resolves a local entity using its corresponding Firebase document ID.
    /// - Parameter id: The remote document identifier String.
    /// - Returns: The matching ``StoryEntity`` or nil if no local record matches.
    func findByRemoteId(_ id: String) async throws -> StoryEntity? {
        let predicate = #Predicate<StoryEntity> { story in
            story.remoteId == id
        }
        let descriptor = FetchDescriptor<StoryEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }

    func fetchByRemoteIds(_ ids: [String]) async throws -> [StoryEntity] {
        let unique = Array(Set(ids.filter { !$0.isEmpty }))
        guard !unique.isEmpty else { return [] }

        var combined: [StoryEntity] = []
        var index = 0
        while index < unique.count {
            let upper = min(index + Self.remoteIdFetchChunkSize, unique.count)
            let chunk = Array(unique[index..<upper])
            let chunkPredicate = #Predicate<StoryEntity> { entity in
                chunk.contains(entity.remoteId ?? "")
            }
            let descriptor = FetchDescriptor<StoryEntity>(predicate: chunkPredicate)
            combined.append(contentsOf: try modelContext.fetch(descriptor))
            index = upper
        }
        return combined
    }

    func fetchActiveStoriesInBoundingBox(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async throws -> [StoryEntity] {
        let minLat = minLatitude
        let maxLat = maxLatitude
        let minLon = minLongitude
        let maxLon = maxLongitude
        let predicate = #Predicate<StoryEntity> { story in
            story.deletedAt == nil
                && story.latitude >= minLat && story.latitude <= maxLat
                && story.longitude >= minLon && story.longitude <= maxLon
        }
        let descriptor = FetchDescriptor<StoryEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor)
    }
}
