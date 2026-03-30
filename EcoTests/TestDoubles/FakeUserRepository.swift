//
//  FakeUserRepository.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/03/26.
//
//  Purpose: In-memory `UserRepositoryProtocol` for unit tests.
//
//  Responsibilities:
//  - Optional hooks for `syncWithCloud` so tests can await background work without XCTest in this type.
//

import Foundation
@testable import Eco

final class FakeUserRepository: UserRepositoryProtocol {
    var currentUser: User?
    var updateProgressResult: Bool = false
    /// Incremented every time `syncWithCloud` runs.
    private(set) var syncWithCloudCallCount = 0
    /// Invoked after incrementing the counter, use to fulfill expectations.
    var onSyncWithCloud: (() -> Void)?

    func getCurrentUser() async throws -> User? {
        currentUser
    }

    func updateUserProgress(userId: String, storyId: UUID) async throws -> Bool {
        updateProgressResult
    }

    func syncWithCloud() async throws {
        syncWithCloudCallCount += 1
        onSyncWithCloud?()
    }
}
