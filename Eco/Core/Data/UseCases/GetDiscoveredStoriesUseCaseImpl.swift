//
//  GetDiscoveredStoriesUseCaseImpl.swift
//  Eco
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
        // En esta primera versión, devolvemos todas las historias encontradas del usuario actual.
        guard let user = try await userRepository.getCurrentUser() else {
            return []
        }
        return user.foundStories
    }
}
