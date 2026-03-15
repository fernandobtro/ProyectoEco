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
            longitude: entity.longitude
        )
    }

    static func toEntity(_ story: Story) -> StoryEntity {
        StoryEntity(
            id: story.id,
            title: story.title,
            content: story.content,
            authorID: story.authorID,
            latitude: story.latitude,
            longitude: story.longitude
        )
    }
}
