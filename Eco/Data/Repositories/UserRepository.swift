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
    
    init(userLocalDataSource: UserLocalDataSourceProtocol, storyLocalDataSource: StoryLocalDataSourceProtocol) {
        self.userLocalDataSource = userLocalDataSource
        self.storyLocalDataSource = storyLocalDataSource
    }
    
    func getCurrentUser() async throws -> User? {
        guard let userEntity = try await userLocalDataSource.fetchCurrentUser() else { return nil }
        
        let plantedStories = try await hydrateStories(ids: userEntity.plantedStoryIDs)
        let foundStories = try await hydrateStories(ids: userEntity.foundStoryIDs)
        
        return User(id: userEntity.id, name: userEntity.name, email: userEntity.email, plantedStories: plantedStories, foundStories: foundStories)

    }
    
    func updateUserProgress(userId: UUID, storyId: UUID) async throws {
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
                let story = Story(id: entity.id, title: entity.title, content: entity.content, authorID: entity.authorID, latitude: entity.latitude, longitude: entity.longitude
                )
                stories.append(story)
            }
        }
        return stories
    }

    
}
