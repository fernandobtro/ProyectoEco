//
//  GetDiscoveredStoriesUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Implements `GetDiscoveredStoriesUseCase` using repositories and async side effects.
//

import Foundation

/// Implements `GetDiscoveredStoriesUseCase` using repositories and async side effects.
final class GetDiscoveredStoriesUseCaseImpl: GetDiscoveredStoriesUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func execute() async throws -> [Story] {
        // TODO: Paginate discovered stories via a relational model (UserStoryDiscovery). Current path uses `user.foundStories` in memory without paging.
        // v1: return every discovered story for the current user (no pagination yet).
        guard let user = try await userRepository.getCurrentUser() else {
            return []
        }
        return user.foundStories
    }
}
