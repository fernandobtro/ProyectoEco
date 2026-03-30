//
//  SyncConflictResolver.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 18/03/26.
//
//  Purpose: Resolves timestamp conflicts during pull merge.
//

import Foundation

/// Outcome of comparing a local row with a remote story during pull.
enum StorySyncAction {
    case insert(StoryEntity)
    case updateLocal(StoryEntity)
    case keepLocal
    case deleteLocal
}

/// Last-write-wins merge for story rows (with explicit pending-delete precedence).
enum SyncConflictResolver {

    /// Merges optional local `StoryEntity` with remote DTO, `pendingDelete` always wins, else latest `updatedAt`.
    static func resolve(
        local: StoryEntity?,
        remote: RemoteStoryDTO
    ) -> StorySyncAction {
        // Remote deleted
        if remote.deletedAt != nil {
            guard let local else { return .keepLocal }
            // pendingCreate: never reached server, keep local as source of truth
            if local.syncStatus == .pendingCreate {
                return .keepLocal
            }
            return .deleteLocal
        }

        guard let local else {
            return .insert(StoryRemoteMapper.toEntity(remote, existing: nil))
        }

        // User-initiated delete always wins
        if local.syncStatus == .pendingDelete {
            return .keepLocal
        }

        // Remote wins
        if remote.updatedAt > local.updatedAt {
            let entity = StoryRemoteMapper.toEntity(remote, existing: local)
            return .updateLocal(entity)
        }

        // Local wins
        return .keepLocal
    }
}
