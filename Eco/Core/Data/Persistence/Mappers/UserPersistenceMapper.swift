//
//  UserPersistenceMapper.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//
//  Purpose: Convert between SwiftData `UserEntity` and domain `User`, including related story collections.
//

import Foundation

/// Stateless mapper for user persistence, hydration of `Story` values happens outside this type.
enum UserPersistenceMapper {

    // MARK: - Domain

    /// Maps a stored user row to domain, attaching the already-resolved planted and discovered story lists.
    ///
    /// - Parameters:
    ///   - entity: SwiftData user row.
    ///   - plantedStories: Stories whose ids match `entity.plantedStoryIDs` (order preserved by the caller).
    ///   - foundStories: Stories whose ids match `entity.foundStoryIDs`.
    static func toDomain(entity: UserEntity, plantedStories: [Story], foundStories: [Story]) -> User {
        User(
            id: entity.id,
            name: entity.name,
            email: entity.email,
            plantedStories: plantedStories,
            foundStories: foundStories
        )
    }

    // MARK: - Persistence

    /// Persists core user fields and encodes planted and found stories as id lists on the entity.
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
