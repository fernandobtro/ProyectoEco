//
//  UserLocalDataSourceProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//
//  Purpose: Interface for local user data operations, decoupling the repository from SwiftData.
//  Responsabilites:
//  - Define the contract for persisting and retrieving user entities.
//  - Specify the mechanism for updating discovery progress (found stories).

import Foundation

protocol UserLocalDataSourceProtocol {
    /// Persists a user entity to the local storage.
    func save(user: UserEntity) async throws
    /// Retrieves the currently stored user profile from the database.
    func fetchCurrentUser() async throws -> UserEntity?
    /// Records a new story discovery in the user's progress file.
    func updateFoundStories(userId: String, storyId: UUID) async throws -> Bool
}
