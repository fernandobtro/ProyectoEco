//
//  DiscoverNearbyStoriesUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Combine
import Foundation

class DiscoverNearbyStoriesUseCase: NSObject, LocationServiceDelegate {
    var nearbyStoriesPublisher = PassthroughSubject<[Story], Never>()
    
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
        Task {
            do {
                let stories = try await storyRepository.fetchAllStories()
                
                let nearby = stories.filter { story in
                    abs(story.latitude - latitude) < 0.005 && abs(story.longitude - longitude) < 0.005
                }
                nearbyStoriesPublisher.send(nearby)
            } catch {
                didFailWithError(error)
            }
        }
    }
    
    func requestPermission() async {
        try? await locationService.requestPermission()
    }
    
    func didFailWithError(_ error: any Error) {
        
    }
    
    func execute(latitude: Double, longitude: Double) async throws -> [Story] {
        let allStories = try await storyRepository.fetchAllStories()
        return allStories
    }
}
