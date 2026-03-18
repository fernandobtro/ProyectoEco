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
    private lazy var authDataSource = FirebaseAuthDataSource()
    
    private lazy var authorProfileDataSource = FirebaseAuthorProfileDataSource()

    // Remote / Sync
    private lazy var firestoreStoryDataSource = FirestoreStoryDataSource()
    private lazy var syncWorker: SyncWorkerProtocol = {
        SyncWorker(
            localDataSource: storyDataSource,
            remoteDataSource: firestoreStoryDataSource
        )
    }()

    // MARK: - Repositories
    private lazy var storyRepository: StoryRepositoryProtocol = {
        StoryRepository(storyLocalDataSource: storyDataSource)
    }()
    private lazy var userRepository: UserRepositoryProtocol = {
        UserRepository(
            userLocalDataSource: userDataSource,
            storyLocalDataSource: storyDataSource,
            sessionRepository: sessionRepository
        )
    }()
    private lazy var authorProfileRepository: AuthorProfileRepositoryProtocol = {
        AuthorProfileRepository(dataSource: authorProfileDataSource)
    }()
    private lazy var sessionRepository: SessionRepositoryProtocol = {
        LocalSessionRepository()
    }()
    
    private lazy var authRepository: AuthRepositoryProtocol = {
        FirebaseAuthRepository(dataSource: authDataSource)
    }()

    // MARK: - Core services
    private lazy var locationService: LocationServiceProtocol = {
        LocationService()
    }()
    private lazy var localNotificationService: LocalNotificationServiceProtocol = {
        UserNotificationService()
    }()
    private lazy var locationEventsAdapter: LocationEventsAdapter = {
        LocationEventsAdapter(
            locationService: locationService,
            discoverNearbyStoriesUseCase: discoverNearbyStoriesUseCase,
            trackProgressOnStoryEntryUseCase: trackUserProgressOnStoryEntryUseCase
        )
    }()

    // MARK: - Use cases
    private lazy var discoverNearbyStoriesUseCase: DiscoverNearbyStoriesUseCaseProtocol = {
        DiscoverNearbyStoriesUseCaseImpl(storyRepository: storyRepository)
    }()
    private lazy var trackUserProgressOnStoryEntryUseCase: TrackUserProgressOnStoryEntryUseCaseProtocol = {
        TrackUserProgressOnStoryEntryUseCaseImpl(
            userRepository: userRepository,
            storyRepository: storyRepository,
            localNotificationService: localNotificationService
        )
    }()
    private lazy var plantStoryUseCase: PlantStoryUseCaseProtocol = {
        PlantStoryUseCaseImpl(
            storyRepository: storyRepository,
            userRepository: userRepository,
            sessionRepository: sessionRepository
        )
    }()
    private lazy var getLocationForPlantingUseCase: GetCurrentLocationForPlantingUseCaseProtocol = {
        GetCurrentLocationForPlantingUseCaseImpl(locationService: locationService)
    }()
    private lazy var getStoryDetailUseCase: GetStoryDetailUseCaseProtocol = {
        GetStoryDetailUseCaseImpl(storyRepository: storyRepository)
    }()
    private lazy var deleteStoryUseCase: DeleteStoryUseCaseProtocol = {
        DeleteStoryUseCaseImpl(storyRepository: storyRepository)
    }()

    /// Misma instancia para la pantalla raíz (mapa) para no perder estado.
    private lazy var mapViewModel: MapViewModel = {
        MapViewModel(
            discoverUseCase: discoverNearbyStoriesUseCase,
            discoveryController: locationEventsAdapter,
            syncPullStoriesUseCase: syncPullStoriesUseCase
        )
    }()
    private lazy var mapRouter: MapRouter = {
        MapRouter(storyCreationViewFactory: { [weak self] in self?.makeStoryCreationView() })
    }()
    
    // GetStories
    
    private lazy var getPlantedStoriesUseCase: GetPlantedStoriesUseCaseProtocol = {
        GetPlantedStoriesUseCaseImpl(storyRepository: storyRepository, sessionRepository: sessionRepository)
    }()
    
    private lazy var getDiscoveredStoriesUseCase: GetDiscoveredStoriesUseCaseProtocol = {
        GetDiscoveredStoriesUseCaseImpl(userRepository: userRepository)
    }()
    
    // Firebase / Sync
    private lazy var syncStoriesUseCase: SyncStoriesUseCase = {
        SyncStoriesUseCaseImpl(worker: syncWorker)
    }()
    
    private lazy var syncPullStoriesUseCase: SyncPullStoriesUseCaseProtocol = {
        SyncPullStoriesUseCaseImpl(
            remoteDataSource: firestoreStoryDataSource,
            localDataSource: storyDataSource
        )
    }()
    private lazy var loginUsecase: LoginUseCaseProtocol = {
        LoginUseCaseImpl(repository: authRepository)
    }()
    
    private lazy var registerUseCase: RegisterUseCaseProtocol = {
        RegisterUseCaseImpl(repository: authRepository)
    }()
    
    private lazy var logoutUseCase: LogoutUseCaseProtocol = {
        LogoutUseCaseImpl(repository: authRepository)
    }()
    
    private lazy var changePasswordUseCase: ChangePasswordUseCaseProtocol = {
        ChangePasswordUseCaseImpl(repository: authRepository)
    }()
    
    private lazy var getCurrentSessionUseCase: GetCurrentSessionUseCaseProtocol = {
        GetCurrentSessionUseCaseImpl(repository: authRepository)
    }()

    private lazy var createAuthorProfileUseCase: CreateAuthorProfileUseCase = {
        CreateAuthorProfileUseCaseImpl(repository: authorProfileRepository)
    }()

    private lazy var getAuthorProfileUseCase: GetAuthorProfileUseCase = {
        GetAuthorProfileUseCaseImpl(repository: authorProfileRepository)
    }()

    private lazy var saveAuthorProfileUseCase: SaveAuthorProfileUseCase = {
        SaveAuthorProfileUseCaseImpl(repository: authorProfileRepository)
    }()

    init() {
        do {
            modelContainer = try ModelContainer(for: StoryEntity.self, UserEntity.self)
        } catch {
            fatalError("No se pudo inicializar la base de datos: \(error)")
        }
    }
}

// MARK: - ViewModel Factories

@MainActor
extension AppDIContainer {

    @MainActor
    func makeMapViewModel() -> MapViewModel {
        mapViewModel
    }
    
    @MainActor
    func makeMapRouter() -> MapRouter {
        mapRouter
    }

    @MainActor
    func makeStoryCreationView() -> StoryCreationView {
        StoryCreationView(viewModel: makeStoryCreationViewModel())
    }

    @MainActor
    func makeStoryCreationViewModel() -> StoryCreationViewModel {
        StoryCreationViewModel(
            plantUseCase: plantStoryUseCase,
            getLocationUseCase: getLocationForPlantingUseCase,
            syncStoriesUseCase: syncStoriesUseCase
        )
    }
    
    @MainActor
    func makeCollectionViewModel() -> CollectionViewModel {
        CollectionViewModel(
            getPlantedStoriesUseCase: getPlantedStoriesUseCase,
            getDiscoveredStoriesUseCase: getDiscoveredStoriesUseCase,
            deleteStoryUseCase: deleteStoryUseCase
        )
    }

    @MainActor
    func makeStoryDetailViewModel(storyId: UUID) -> StoryDetailViewModel {
        StoryDetailViewModel(
            storyId: storyId,
            getStoryDetailUseCase: getStoryDetailUseCase,
            getLocationUseCase: getLocationForPlantingUseCase,
            sessionRepository: sessionRepository
        )
    }
    
    @MainActor
    func makeLoginViewModel() -> LoginViewModel {
        LoginViewModel(loginUseCase: loginUsecase)
    }
    
    @MainActor
    func makeRegisterViewModel() -> RegisterViewModel {
        RegisterViewModel(
            registerUseCase: registerUseCase,
            createAuthorProfileUseCase: createAuthorProfileUseCase
        )
    }
    
    @MainActor
    func makeAuthGateViewModel() -> AuthGateViewModel {
        AuthGateViewModel(getCurrentSessionUseCase: getCurrentSessionUseCase)
    }

    @MainActor
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            logoutUseCase: logoutUseCase,
            getAuthorProfileUseCase: getAuthorProfileUseCase,
            saveAuthorProfileUseCase: saveAuthorProfileUseCase
        )
    }

    @MainActor
    func makeProfileView() -> ProfileView {
        ProfileView(viewModel: makeProfileViewModel())
    }
}
