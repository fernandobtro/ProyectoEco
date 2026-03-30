//
//  UserRepositoryProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/02/26.
//
//  Purpose: Repository boundary for User (Domain defines, Data implements).
//

import Foundation

/// Repository boundary for User (Domain defines, Data implements).
protocol UserRepositoryProtocol {
    func getCurrentUser() async throws -> User?
    /// `true` when the story is newly marked discovered for this user.
    func updateUserProgress(userId: String, storyId: UUID) async throws -> Bool
    func syncWithCloud() async throws
}
