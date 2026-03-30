//
//  UserRepository.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//
//  Purpose: Repository responsible for aggregating user profile data and hydrating story associations.

import Foundation

/// Repository responsible for aggregating user profile data and hydrating story associations.
struct UserRepository: UserRepositoryProtocol {
    
    // MARK: - Dependencies
    private let userLocalDataSource: UserLocalDataSourceProtocol
    private let storyLocalDataSource: StoryLocalDataSourceProtocol
    private let sessionRepository: SessionRepositoryProtocol

    // MARK: - Init
    init(
        userLocalDataSource: UserLocalDataSourceProtocol,
        storyLocalDataSource: StoryLocalDataSourceProtocol,
        sessionRepository: SessionRepositoryProtocol
    ) {
        self.userLocalDataSource = userLocalDataSource
        self.storyLocalDataSource = storyLocalDataSource
        self.sessionRepository = sessionRepository
    }
    
    // MARK: - Public API
    
    /// Retrieves the current user profile, performing an automatic setup if no local record exists.
    ///
    /// This method ensures an Offline-first experience by creating a local `UserEntity` based on the active session if the database is empty. Then "hydrates" the story collections before returning the domain model.
    ///  - Returns: A hydrated ``User``domain model, or `nil` if session data is missing.
    ///  - Throws: Persistence or session-related errors.
    func getCurrentUser() async throws -> User? {
        let userEntity: UserEntity
        if let existing = try await userLocalDataSource.fetchCurrentUser() {
            userEntity = existing
        } else {
            // Bootstrap local user row for offline-first flow
            let currentUserId = try sessionRepository.getCurrentUserId()
            let sessionNick = sessionRepository.getNickname() ?? "Explorador"
            let nickname = EcoAuthorDisplayFormatting.displayNickname(sessionNick, authorFirebaseUid: currentUserId)
                ?? "Explorador"
            let bootstrapped = UserEntity(
                id: currentUserId,
                name: nickname,
                email: "\(currentUserId.lowercased())@eco.local"
            )
            try await userLocalDataSource.save(user: bootstrapped)
            userEntity = bootstrapped
        }

        let plantedStories = try await hydrateStories(ids: userEntity.plantedStoryIDs)
        let foundStories = try await hydrateStories(ids: userEntity.foundStoryIDs)
        return UserPersistenceMapper.toDomain(entity: userEntity, plantedStories: plantedStories, foundStories: foundStories)
    }
    
    /// Updates the list of discovered stories for a specific user.
    func updateUserProgress(userId: String, storyId: UUID) async throws -> Bool {
        try await userLocalDataSource.updateFoundStories(userId: userId, storyId: storyId)
    }

    // Placeholder for future cloud synchronization logic for user profiles.
    func syncWithCloud() async throws {
        print("UserRepository.syncWithCloud: stub — no remote sync yet")
    }

    // MARK: - Private Helpers

    /// Transform a list of IDs into domain Story models.
    ///
    /// Hydrates full ``Story`` models because ``UserEntity`` only stores lightweight id references.
    ///  - Parameter ids: Story ids to load.
    ///  - Returns: Array of mapped domain ``Story`` objects.
    ///
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
