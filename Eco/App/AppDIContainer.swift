//
//  AppDIContainer.swift
//  Eco
//
//  Created by Fernando Buenrostro on 03/03/26.
//

import Foundation
import SwiftData

final class AppDIContainer {
    /// Contenedor de SwiftData para toda la app (se expone para .modelContainer en SwiftUI).
    let modelContainer: ModelContainer

    // MARK: - Data sources
    private lazy var storyDataSource: StoryLocalDataSourceProtocol = {
        SwiftDataStoryDataSource(modelContext: modelContainer.mainContext)
    }()
    private lazy var userDataSource: UserLocalDataSourceProtocol = {
        SwiftDataUserDataSource(modelContext: modelContainer.mainContext)
    }()

    // MARK: - Repositories
    private lazy var storyRepository: StoryRepositoryProtocol = {
        StoryRepository(storyLocalDataSource: storyDataSource)
    }()
    private lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(userLocalDataSource: userDataSource, storyLocalDataSource: storyDataSource)
    }()

    // MARK: - Core services
    private lazy var locationService: LocationServiceProtocol = {
        LocationService()
    }()

    // MARK: - Use cases
    private lazy var discoverNearbyStoriesUseCase: DiscoverNearbyStoriesUseCase = {
        let useCase = DiscoverNearbyStoriesUseCase(
            locationService: locationService,
            storyRepository: storyRepository,
            userRepository: userRepository
        )
        return useCase
    }()
    private lazy var plantStoryUseCase: PlantStoryUseCaseProtocol = {
        PlantStoryUseCaseImpl(storyRepository: storyRepository, userRepository: userRepository)
    }()

    // MARK: - Presentation (misma instancia para no recrear en cada render)
    private lazy var mapViewModel: MapViewModel = {
        MapViewModel(discoverUseCase: discoverNearbyStoriesUseCase)
    }()
    private lazy var mapRouter: MapRouter = {
        MapRouter(plantStoryUseCase: plantStoryUseCase, locationService: locationService)
    }()

    func makeMapViewModel() -> MapViewModel { mapViewModel }
    func makeMapRouter() -> MapRouter { mapRouter }

    init() {
        do {
            modelContainer = try ModelContainer(for: StoryEntity.self, UserEntity.self)
        } catch {
            fatalError("No se pudo inicializar la base de datos: \(error)")
        }
    }
}
