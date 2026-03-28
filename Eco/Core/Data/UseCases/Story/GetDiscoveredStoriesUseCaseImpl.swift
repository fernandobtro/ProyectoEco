//
//  GetDiscoveredStoriesUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class GetDiscoveredStoriesUseCaseImpl: GetDiscoveredStoriesUseCaseProtocol {
    private let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    func execute() async throws -> [Story] {
        // TODO: Paginate discovered stories via a relational model (e.g. UserStoryDiscovery). Current path uses `user.foundStories` in memory without paging.
        // En esta primera versión, devolvemos todas las historias encontradas del usuario actual.
        guard let user = try await userRepository.getCurrentUser() else {
            return []
        }
        return user.foundStories
    }
}
