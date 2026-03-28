//
//  FakeStoryLocalDataSource.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: In-memory `StoryLocalDataSourceProtocol` for sync and persistence tests.
//
//  Responsibilities:
//  - Back `SyncPullStoriesUseCaseImpl` tests and record `fetchByRemoteIds` invocations.
//

import Foundation
@testable import Eco

final class FakeStoryLocalDataSource: StoryLocalDataSourceProtocol {
    var entities: [StoryEntity] = []
    private(set) var fetchByRemoteIdsInvocations: [[String]] = []

    func saveNew(story: StoryEntity) async throws {
        entities.append(story)
    }

    func saveChanges() async throws {}

    func fetchActiveStories() async throws -> [StoryEntity] {
        entities.filter { $0.deletedAt == nil }
    }

    func fetchActiveStoriesSortedByUpdatedAtDescending() async throws -> [StoryEntity] {
        entities
            .filter { $0.deletedAt == nil }
            .sorted { lhs, rhs in
                if lhs.updatedAt != rhs.updatedAt { return lhs.updatedAt > rhs.updatedAt }
                return lhs.id.uuidString > rhs.id.uuidString
            }
    }

    func fetchPlantedStories(authorID: String, limit: Int, offset: Int) async throws -> [StoryEntity] {
        let sorted = entities
            .filter { $0.deletedAt == nil && $0.authorID == authorID }
            .sorted { lhs, rhs in
                if lhs.updatedAt != rhs.updatedAt { return lhs.updatedAt > rhs.updatedAt }
                return lhs.id.uuidString > rhs.id.uuidString
            }
        guard offset < sorted.count else { return [] }
        return Array(sorted.dropFirst(offset).prefix(max(0, limit)))
    }

    func fetch(by id: UUID) async throws -> StoryEntity? {
        entities.first { $0.id == id }
    }

    func delete(id: UUID) async throws {
        entities.removeAll { $0.id == id }
    }

    func fetchPending() async throws -> [StoryEntity] {
        []
    }

    func findByRemoteId(_ id: String) async throws -> StoryEntity? {
        entities.first { $0.remoteId == id }
    }

    func fetchByRemoteIds(_ ids: [String]) async throws -> [StoryEntity] {
        fetchByRemoteIdsInvocations.append(ids)
        let idSet = Set(ids)
        return entities.filter { entity in
            guard let remoteId = entity.remoteId else { return false }
            return idSet.contains(remoteId)
        }
    }

    func fetchActiveStoriesInBoundingBox(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async throws -> [StoryEntity] {
        entities.filter { story in
            guard story.deletedAt == nil else { return false }
            return story.latitude >= minLatitude && story.latitude <= maxLatitude
                && story.longitude >= minLongitude && story.longitude <= maxLongitude
        }
    }
}
