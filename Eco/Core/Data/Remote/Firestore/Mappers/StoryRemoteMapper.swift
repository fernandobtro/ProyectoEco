//
//  StoryRemoteMapper.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Maps Firestore payloads - domain `Story` (`StoryRemoteMapper`).
//

import Foundation

/// Maps Firestore payloads domain `Story` (`StoryRemoteMapper`).
enum StoryRemoteMapper {
    static func toEntity(_ dto: RemoteStoryDTO, existing: StoryEntity?) -> StoryEntity {
        if let existing {
            existing.title = dto.title
            existing.content = dto.content
            existing.authorID = dto.authorId
            existing.latitude = dto.latitude
            existing.longitude = dto.longitude
            existing.remoteId = dto.remoteId
            existing.updatedAt = dto.updatedAt
            existing.deletedAt = dto.deletedAt
            existing.syncStatus = .synced
            return existing
        } else {
            // Simple path: allocate a fresh local UUID when the row is new from remote, refine merge/mapping later if needed.
            return StoryEntity(id: UUID(), title: dto.title, content: dto.content, authorID: dto.authorId, latitude: dto.latitude, longitude: dto.longitude, remoteId: dto.remoteId, syncStatus: .synced, updatedAt: dto.updatedAt, deletedAt: dto.deletedAt)
        }
    }
}
