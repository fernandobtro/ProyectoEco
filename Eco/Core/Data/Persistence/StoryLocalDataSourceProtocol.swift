//
//  StoryLocalDataSourceProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//
//  Purpose: Local SwiftData access for story entities and sync-related queries.
//
//  Responsibilities:
//  - Persist inserts and saves, fetch active rows or by local id, delete when a row exists.
//  - Surface pending sync rows and resolve rows by remote id.
//

import Foundation

protocol StoryLocalDataSourceProtocol {
    func saveNew(story: StoryEntity) async throws
    func saveChanges() async throws
    /// Non-deleted stories only (`deletedAt == nil`). Prefer over scanning the full table including soft-deleted rows.
    func fetchActiveStories() async throws -> [StoryEntity]
    /// Active stories with `updatedAt` descending (newest first), tie-broken by `id` for stable pagination.
    func fetchActiveStoriesSortedByUpdatedAtDescending() async throws -> [StoryEntity]
    /// Active stories for one author, same stable sort as above; supports `limit` / `offset` paging.
    func fetchPlantedStories(authorID: String, limit: Int, offset: Int) async throws -> [StoryEntity]
    func fetch(by id: UUID) async throws -> StoryEntity?
    func delete(id: UUID) async throws
    /// Fetches rows not yet `synced`, ordered by `updatedAt` ascending for sequential sync processing.
    func fetchPending() async throws -> [StoryEntity]
    /// Finds a row by `StoryEntity.remoteId`, matching the backend document id (such as Firestore).
    func findByRemoteId(_ id: String) async throws -> StoryEntity?

    /// Fetches rows whose `remoteId` is in `ids`. Empty strings are ignored; implementation may query in chunks.
    /// Rows with `remoteId == nil` never match.
    func fetchByRemoteIds(_ ids: [String]) async throws -> [StoryEntity]

    /// Active stories (`deletedAt == nil`) inside the inclusive geographic rectangle.
    func fetchActiveStoriesInBoundingBox(
        minLatitude: Double,
        maxLatitude: Double,
        minLongitude: Double,
        maxLongitude: Double
    ) async throws -> [StoryEntity]
}
