//
//  PlantStoryUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 28/02/26.
//

import Foundation

struct PlantStoryUseCase {
    
    private let locationService: LocationServiceProtocol
    private let storyRepository: StoryRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    init(locationService: LocationServiceProtocol, storyRepository: StoryRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.locationService = locationService
        self.storyRepository = storyRepository
        self.userRepository = userRepository
    }
    
    func execute(title: String, content: String, authorId: UUID, latitude: Double, longitude: Double) async throws {
        
        let newStory = Story(
            id: UUID(),
            title: title,
            content: content,
            authorID: authorId,
            latitude: latitude,
            longitude: longitude
        )
        
        try await storyRepository.save(story: newStory)
        
        Task {
            try? await userRepository.syncWithCloud()
        }
    }
}
    
