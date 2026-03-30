//
//  SwiftDataUserDataSource.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//
//  Purpose: Local SwiftData access for user profile persistence and discovery progress tracking.
//  Responsabilites:
//  - Persist and retrieve the primary authenticated user entity.
//  - Atomically update user progress by appending newly discoverd story identifiers.
//  - Ensure thread safe database interactions via MainActor isolation.

import Foundation
import SwiftData

/// Local SwiftData access for user profile persistence and discovery progress tracking.
@MainActor
class SwiftDataUserDataSource: UserLocalDataSourceProtocol {
    // MARK: - Dependencies
    private let modelContext: ModelContext
    
    // MARK: - Init
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Public API
    
    /// Saves a new user entity or updates an existing one in the model context.
    /// - Parameter user: The ``UserEntity``instance to persist.
    func save(user: UserEntity) async throws {
        modelContext.insert(user)
        try modelContext.save()
    }
    
    /// Retrives the user record currently stored in the device.
    /// - Returns: The first ``UserEntity`` found.
    func fetchCurrentUser() async throws -> UserEntity? {
        let descriptor = FetchDescriptor<UserEntity>()
        return try modelContext.fetch(descriptor).first
    }
    
    /// Records a story as "discovered" by the user.
    ///
    /// Checks for duplicates before appending the new ID to ensure the user's collection remains consistent
    /// - Parameters:
    ///  - userId: The unique identifier of the user to update
    ///  - storyId: The UUID of the discoverd story.
    ///  - Returns: `true` if a new discovery was recorded, `false` if the story was already there.
    func updateFoundStories(userId: String, storyId: UUID) async throws -> Bool {
        let predicate = #Predicate<UserEntity> { user in
            user.id == userId
        }
        
        let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
        
        if let user = try modelContext.fetch(descriptor).first {
            if !user.foundStoryIDs.contains(storyId) {
                user.foundStoryIDs.append(storyId)
                try modelContext.save()
                return true
            }
            return false
        }
        return false
    }
}
