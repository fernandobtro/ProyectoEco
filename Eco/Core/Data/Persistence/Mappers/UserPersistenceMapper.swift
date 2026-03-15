//
//  UserPersistenceMapper.swift
//  Eco
//

import Foundation

enum UserPersistenceMapper {

    static func toDomain(entity: UserEntity, plantedStories: [Story], foundStories: [Story]) -> User {
        User(
            id: entity.id,
            name: entity.name,
            email: entity.email,
            plantedStories: plantedStories,
            foundStories: foundStories
        )
    }

    static func toEntity(_ user: User) -> UserEntity {
        UserEntity(
            id: user.id,
            name: user.name,
            email: user.email,
            plantedStoryIDs: user.plantedStories.map(\.id),
            foundStoryIDs: user.foundStories.map(\.id)
        )
    }
}
