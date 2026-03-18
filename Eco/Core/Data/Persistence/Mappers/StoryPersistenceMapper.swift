//
//  StoryPersistenceMapper.swift
//  Eco
//

import Foundation

enum StoryPersistenceMapper {

    static func toDomain(_ entity: StoryEntity) -> Story {
        Story(
            id: entity.id,
            title: entity.title,
            content: entity.content,
            authorID: entity.authorID,
            latitude: entity.latitude,
            longitude: entity.longitude,
            isSynced: entity.syncStatus == "synced" && entity.deletedAt == nil
        )
    }

    /// Crea o actualiza una `StoryEntity` a partir de un `Story` de dominio.
    /// - Nota: La lógica de sync (create/update) se resuelve aquí en función de si existe o no la entidad previa.
    static func toEntity(_ story: Story, existing: StoryEntity?) -> StoryEntity {
        if let existing {
            // UPDATE sobre una entidad que ya existe en la base local.
            existing.title = story.title
            existing.content = story.content
            existing.latitude = story.latitude
            existing.longitude = story.longitude
            existing.updatedAt = Date()

            // Si ya estaba sincronizada, marcamos que requiere actualización remota.
            if existing.syncStatus == "synced" {
                existing.syncStatus = "pendingUpdate"
            }

            return existing
        } else {
            // CREATE de una nueva historia local pendiente de subir.
            return StoryEntity(
                id: story.id,
                title: story.title,
                content: story.content,
                authorID: story.authorID,
                latitude: story.latitude,
                longitude: story.longitude,
                remoteId: nil,
                syncStatus: "pendingCreate",
                updatedAt: Date(),
                deletedAt: nil
            )
        }
    }
}
