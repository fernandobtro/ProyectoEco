//
//  PlantStoryUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 28/02/26.
//

import Foundation

struct PlantStoryUseCase {
    
    // Dependencies
    private let locationService: LocationServiceProtocol
    private let storyRepository: StoryRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    // Dependency Injections
    init(locationService: LocationServiceProtocol, storyRepository: StoryRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.locationService = locationService
        self.storyRepository = storyRepository
        self.userRepository = userRepository
    }
    
    func execute(title: String, content: String, authorId: UUID) async throws {
        // Ubicación mock por ahora
        let lat = 19.4326
        let lon = -99.1332
        
        // Create una historia
        let newStory = Story(id: UUID(), title: title, content: content, authorID: authorId, latitude: lat, longitude: lon)
        
        // Guardado Local
        try await storyRepository.save(story: newStory)
        
        // Intento de Sincronización
        Task {
            try? await userRepository.syncWithCloud()
        }
    }
}
