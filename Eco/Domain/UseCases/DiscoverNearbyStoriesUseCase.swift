//
//  DiscoverNearbyStoriesUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation

class DiscoverNearbyStoriesUseCase: NSObject, LocationServiceDelegate {
    
    // Dependencies
    private var locationService: LocationServiceProtocol
    private let storyRepository: StoryRepositoryProtocol
    private let userRepository: UserRepositoryProtocol
    
    // DI
    init(locationService: LocationServiceProtocol, storyRepository: StoryRepositoryProtocol, userRepository: UserRepositoryProtocol) {
        self.locationService = locationService
        self.storyRepository = storyRepository
        self.userRepository = userRepository
        
        super.init()
        
        self.locationService.delegate = self
    }
    
    func startDiscovery() {
        locationService.startMonitoring(stories: [])
    }
    
    func didEnterStoryRegion(id: UUID) {
        Task {
            do {
                let user = try await userRepository.getCurrentUser()
                guard let user = user else { return }
                let story = try await storyRepository.fetchStory(by: id)
                if story != nil {
                    try await userRepository.updateUserProgress(userId: user.id, storyId: id)
                }
            } catch {
                didFailWithError(error)
            }
        }
    }
    
    func didUpdateLocation(latitude: Double, longitude: Double) {
        // TODO: Notificar a la UI para actualizar la posición en el mapa.
    }
    
    func didFailWithError(_ error: any Error) {
        
    }
}
