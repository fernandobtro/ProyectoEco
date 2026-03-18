//
//  StoryDetailViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import CoreLocation
import Foundation
import Observation

enum StoryDetailState: Equatable {
    case idle
    case loading
    case loaded(Story)
    case error(String)
}

@MainActor
@Observable
final class StoryDetailViewModel {
    let storyId: UUID
    var state: StoryDetailState = .idle

    /// Si el usuario actual es el autor del Eco.
    var isAuthor: Bool = false
    /// Indica si el contenido completo del Eco está desbloqueado para el usuario actual.
    var isUnlocked: Bool = false
    /// Distancia en metros desde la ubicación actual hasta el Eco (si se pudo calcular).
    var distanceToStory: Double?
    
    private let getStoryDetailUseCase: GetStoryDetailUseCaseProtocol
    private let getLocationUseCase: GetCurrentLocationForPlantingUseCaseProtocol
    private let sessionRepository: SessionRepositoryProtocol
    
    private let unlockRadius: Double = 50.0

    init(
        storyId: UUID,
        getStoryDetailUseCase: GetStoryDetailUseCaseProtocol,
        getLocationUseCase: GetCurrentLocationForPlantingUseCaseProtocol,
        sessionRepository: SessionRepositoryProtocol
    ) {
        self.storyId = storyId
        self.getStoryDetailUseCase = getStoryDetailUseCase
        self.getLocationUseCase = getLocationUseCase
        self.sessionRepository = sessionRepository
    }

    var story: Story? {
        if case let .loaded(story) = state {
            return story
        }
        return nil
    }

    var distanceText: String {
        guard let distanceToStory else {
            return "No pudimos obtener tu ubicación actual."
        }
        return "Estás a \(Int(distanceToStory.rounded())) m de este Eco."
    }

    func loadDetail() async {
        state = .loading
        isAuthor = false
        isUnlocked = false
        distanceToStory = nil
        
        do {
            let result = try await getStoryDetailUseCase.execute(id: storyId)
            
            guard let story = result else {
                state = .error("No encontramos este Eco.")
                return
            }
            
            // 1. Autor actual (el autor siempre puede leer su Eco)
            let currentUserId = sessionRepository.getCurrentUserId()
            let isAuthor = story.authorID == currentUserId
            self.isAuthor = isAuthor
            
            // 2. Distancia al Eco (si hay ubicación disponible)
            if let userCoords = await getLocationUseCase.requestLocation() {
                let userLoc = CLLocation(latitude: userCoords.latitude, longitude: userCoords.longitude)
                let storyLoc = CLLocation(latitude: story.latitude, longitude: story.longitude)
                let distance = userLoc.distance(from: storyLoc)
                self.distanceToStory = distance
                
                // 3. Regla: desbloqueado si eres autor O estás dentro del radio
                self.isUnlocked = isAuthor || (distance <= unlockRadius)
            } else {
                // Sin ubicación, solo el autor puede leer
                self.isUnlocked = isAuthor
            }
            
            state = .loaded(story)
        } catch {
            state = .error(error.localizedDescription)
        }
    }
}

