//
//  UserRepository.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation

struct UserRepository: UserRepositoryProtocol {
    
    private let userLocalDataSource: UserLocalDataSourceProtocol
    private let storyLocalDataSource: StoryLocalDataSourceProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    init(
        userLocalDataSource: UserLocalDataSourceProtocol,
        storyLocalDataSource: StoryLocalDataSourceProtocol,
        sessionRepository: SessionRepositoryProtocol
    ) {
        self.userLocalDataSource = userLocalDataSource
        self.storyLocalDataSource = storyLocalDataSource
        self.sessionRepository = sessionRepository
    }
    
    func getCurrentUser() async throws -> User? {
        let userEntity: UserEntity
        if let existing = try await userLocalDataSource.fetchCurrentUser() {
            userEntity = existing
        } else {
            // Bootstrap del usuario local para flujo offline-first.
            let currentUserId = sessionRepository.getCurrentUserId()
            let bootstrapped = UserEntity(
                id: currentUserId,
                name: "Explorador",
                email: "\(currentUserId.uuidString.lowercased())@eco.local"
            )
            try await userLocalDataSource.save(user: bootstrapped)
            userEntity = bootstrapped
        }

        let plantedStories = try await hydrateStories(ids: userEntity.plantedStoryIDs)
        let foundStories = try await hydrateStories(ids: userEntity.foundStoryIDs)
        return UserPersistenceMapper.toDomain(entity: userEntity, plantedStories: plantedStories, foundStories: foundStories)
    }
    
    func updateUserProgress(userId: UUID, storyId: UUID) async throws -> Bool {
        try await userLocalDataSource.updateFoundStories(userId: userId, storyId: storyId)
    }
    
    func syncWithCloud() async throws {
        print("Simulando sincronización")
    }
    
    // MARK: - Private Helpers
    
    private func hydrateStories(ids: [UUID]) async throws -> [Story] {
        var stories: [Story] = []
        for id in ids {
            if let entity = try await storyLocalDataSource.fetch(by: id) {
                stories.append(StoryPersistenceMapper.toDomain(entity))
            }
        }
        return stories
    }
}
