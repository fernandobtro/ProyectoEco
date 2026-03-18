//
//  StoryRemoteMapper.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

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
            existing.syncStatus = "synced"
            return existing
        } else {
            // para mantenerlo simple, usamos un `UUID()` local para `id` cuando viene de remoto y no existe aún. Más adelante podemos definir una estrategia más fina de “merge” si quieres (por ejemplo, guardar un mapping remoto→local).
            return StoryEntity(id: UUID(), title: dto.title, content: dto.content, authorID: dto.authorId, latitude: dto.latitude, longitude: dto.longitude, remoteId: dto.remoteId, syncStatus: "synced", updatedAt: dto.updatedAt, deletedAt: dto.deletedAt)
        }
    }
}
