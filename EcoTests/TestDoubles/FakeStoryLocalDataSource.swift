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

    func fetchAll() async throws -> [StoryEntity] {
        entities
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
