//
//  EcoApp.swift
//  Eco
//
//  Created by Fernando Buenrostro on 26/02/26.
//

import SwiftUI
import SwiftData

@main
struct EcoApp: App {
    var container: ModelContainer
    
    init() {
        do {
            container = try ModelContainer(for: StoryEntity.self, UserEntity.self)
        } catch {
            fatalError("No se pudo inicializar la base de datos: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            let context = container.mainContext
            
            // Data Layer
            let storyDS = SwiftDataStoryDataSource(modelContext: context)
            let userDS = SwiftDataUserDataSource(modelContext: context)
            
            let storyRepo = StoryRepository(storyLocalDataSource: storyDS)
            let userRepo = UserRepository(userLocalDataSource: userDS, storyLocalDataSource: storyDS)
            
            // Domain Layer
            let locationService: LocationServiceProtocol = LocationService()
            let discoverUseCase = DiscoverNearbyStoriesUseCase(locationService: locationService, storyRepository: storyRepo, userRepository: userRepo)
            let plantUseCase = PlantStoryUseCase(locationService: locationService, storyRepository: storyRepo, userRepository: userRepo)
            
            // Navigation
            let router = MapRouter(plantStoryUseCase: plantUseCase, locationService: locationService)
            
            // Presentation layer
            let mapViewModel = MapViewModel(discoverUseCase: discoverUseCase)
            
            MapView(viewModel: mapViewModel, router: router)
        }
        .modelContainer(container)
    }
}
