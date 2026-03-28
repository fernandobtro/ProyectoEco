//
//  StoryPersistenceMapper.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//
//  Purpose: Convert between SwiftData StoryEntity rows and domain "Story" values for repositories.
//
//  Responsibilities:
//  - Map fields and derive isSynced from sync status and soft-delete state.
//  - Create new pending rows or update existing ones, adjusting syncStatus for the sync pipeline.
//

import Foundation

enum StoryPersistenceMapper {

    // MARK: - Domain

    /// Maps a stored row to domain. `isSynced` is true only when sync status is `.synced` and `deletedAt` is nil.
    static func toDomain(_ entity: StoryEntity) -> Story {
        Story(
            id: entity.id,
            title: entity.title,
            content: entity.content,
            authorID: entity.authorID,
            latitude: entity.latitude,
            longitude: entity.longitude,
            isSynced: SyncStatus(rawValue: entity.syncStatus) == .synced && entity.deletedAt == nil,
            updatedAt: entity.updatedAt
        )
    }

    // MARK: - Persistence
    /// Inserts a new pending-create entity or updates an existing row. When the row was previously `.synced`, sets `pendingUpdate` so the worker pushes changes.
    ///
    /// - Parameter existing: Pass the fetched entity for an update, or `nil` to create a new local row.
    /// - Returns: The same `existing` instance when updating, or a new `StoryEntity` for creates.
    @discardableResult
    static func toEntity(_ story: Story, existing: StoryEntity?) -> StoryEntity {
        if let existing {
            existing.title = story.title
            existing.content = story.content
            existing.latitude = story.latitude
            existing.longitude = story.longitude
            existing.updatedAt = story.updatedAt

            if SyncStatus(rawValue: existing.syncStatus) == .synced {
                existing.syncStatus = SyncStatus.pendingUpdate.rawValue
            }

            return existing
        } else {
                return StoryEntity(
                id: story.id,
                title: story.title,
                content: story.content,
                authorID: story.authorID,
                latitude: story.latitude,
                longitude: story.longitude,
                remoteId: nil,
                syncStatus: SyncStatus.pendingCreate.rawValue,
                updatedAt: story.updatedAt,
                deletedAt: nil
            )
        }
    }
}
