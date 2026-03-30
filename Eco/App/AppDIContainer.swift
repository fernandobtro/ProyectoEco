//
//  AppDIContainer.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Composition root: SwiftData, remote/local data, use cases, and `make*` screen factories.
//

import CoreLocation
import Foundation
import SwiftData

/// App composition root: SwiftData, data sources, repositories, use cases, and screen factories.
final class AppDIContainer {
    // MARK: - Persistence

    /// Shared SwiftData store for every data source in this container.
    let modelContainer: ModelContainer

    // MARK: - Data Sources
    private lazy var storyDataSource: StoryLocalDataSourceProtocol = {
        SwiftDataStoryDataSource(modelContext: modelContainer.mainContext)
    }()
    private lazy var userDataSource: UserLocalDataSourceProtocol = {
        SwiftDataUserDataSource(modelContext: modelContainer.mainContext)
    }()
    private lazy var authDataSource = FirebaseAuthDataSource()
    
    private lazy var authorProfileDataSource = FirebaseAuthorProfileDataSource()

    private lazy var firestoreStoryDataSource: FirestoreStoryDataSourceProtocol = FirestoreStoryDataSource()
    private lazy var syncPullStoriesUseCase: SyncPullStoriesUseCaseProtocol = {
        SyncPullStoriesUseCaseImpl(
            remoteDataSource: firestoreStoryDataSource,
            localDataSource: storyDataSource
        )
    }()
    private lazy var syncStateService: SyncStateService = {
        SyncStateService()
    }()
    private lazy var syncWorker: SyncWorkerProtocol = {
        SyncWorker(
            localDataSource: storyDataSource,
            remoteDataSource: firestoreStoryDataSource,
            syncPullUseCase: syncPullStoriesUseCase,
            syncStateService: syncStateService
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
    private lazy var authRepository: AuthRepositoryProtocol = {
        FirebaseAuthRepository(dataSource: authDataSource)
    }()
    private lazy var sessionRepository: SessionRepositoryProtocol = {
        LocalSessionRepository(authRepository: authRepository)
    }()

    // MARK: - Core Services
    private lazy var locationService: LocationServiceProtocol = {
        LocationService()
    }()
    private lazy var notificationLogService: NotificationLogServiceProtocol = {
        NotificationLogService()
    }()
    private lazy var localNotificationService: LocalNotificationServiceProtocol = {
        UserNotificationService(logService: notificationLogService)
    }()
    private lazy var locationEventsAdapter: LocationEventsAdapter = {
        LocationEventsAdapter(
            locationService: locationService,
            discoverNearbyStoriesUseCase: discoverNearbyStoriesUseCase,
            trackProgressOnStoryEntryUseCase: trackUserProgressOnStoryEntryUseCase
        )
    }()
    private lazy var geofencingService: GeofencingService = {
        GeofencingService(localNotificationService: localNotificationService)
    }()
    private lazy var getStoriesForGeofencingUseCase: GetStoriesForGeofencingUseCaseProtocol = {
        GetStoriesForGeofencingUseCaseImpl(storyRepository: storyRepository)
    }()

    // MARK: - Use Cases
    
    private let mapDiscoveryConfig = MapDiscoveryConfig.default

    private lazy var discoverNearbyStoriesUseCase: DiscoverNearbyStoriesUseCaseProtocol = {
        DiscoverNearbyStoriesUseCaseImpl(
            storyRepository: storyRepository,
            config: mapDiscoveryConfig
        )
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
        DeleteStoryUseCaseImpl(storyRepository: storyRepository, sessionRepository: sessionRepository)
    }()

    private lazy var updateStoryUseCase: UpdateStoryUseCaseProtocol = {
        UpdateStoryUseCaseImpl(storyRepository: storyRepository, sessionRepository: sessionRepository)
    }()

    private lazy var mapViewModel: MapViewModel = {
        MapViewModel(
            discoverUseCase: discoverNearbyStoriesUseCase,
            discoveryController: locationEventsAdapter,
            locationService: locationService,
            mapDiscoveryConfig: mapDiscoveryConfig,
            syncStoriesUseCase: syncStoriesUseCase,
            getStoriesForGeofencingUseCase: getStoriesForGeofencingUseCase,
            geofencingService: geofencingService
        )
    }()
    private lazy var getAuthorProfileByIdUseCase: GetAuthorProfileByIdUseCaseProtocol = {
        GetAuthorProfileByIdUseCaseImpl(repository: authorProfileRepository)
    }()

    private lazy var mapRouter: MapRouter = {
        MapRouter(
            storyCreationViewFactory: { [weak self] onPlantingSuccess in
                self?.makeStoryCreationView(onPlantingSuccess: onPlantingSuccess)
            },
            makeStoryDetailViewModel: { [weak self] id in
                guard let self else {
                    preconditionFailure("AppDIContainer deallocated before map reader")
                }
                return self.makeStoryDetailViewModel(storyId: id)
            },
            authorProfileByIdUseCase: getAuthorProfileByIdUseCase
        )
    }()
    
    private lazy var getPlantedStoriesUseCase: GetPlantedStoriesUseCaseProtocol = {
        GetPlantedStoriesUseCaseImpl(storyRepository: storyRepository, sessionRepository: sessionRepository)
    }()
    
    private lazy var getDiscoveredStoriesUseCase: GetDiscoveredStoriesUseCaseProtocol = {
        GetDiscoveredStoriesUseCaseImpl(userRepository: userRepository)
    }()

    // MARK: - Remote and Sync
    
    private lazy var syncStoriesUseCase: SyncStoriesUseCase = {
        SyncStoriesUseCaseImpl(worker: syncWorker, storyRepository: storyRepository)
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
        GetCurrentSessionUseCaseImpl(
            repository: authRepository,
            sessionRepository: sessionRepository
        )
    }()

    private lazy var saveSessionNicknameUseCase: SaveSessionNicknameUseCaseProtocol = {
        SaveSessionNicknameUseCaseImpl(
            sessionRepository: sessionRepository,
            authorProfileRepository: authorProfileRepository
        )
    }()

    private lazy var loginWithAppleUseCase: LoginWithAppleUseCaseProtocol = {
        LoginWithAppleUseCaseImpl(repository: authRepository)
    }()

    private lazy var loginWithGoogleUseCase: LoginWithGoogleUseCaseProtocol = {
        LoginWithGoogleUseCaseImpl(repository: authRepository)
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
    
    /// Keeps `triggerSync()` from running twice at the same time.
    private var isSyncing = false

    // MARK: - Init

    init() {
        do {
            modelContainer = try ModelContainer(for: StoryEntity.self, UserEntity.self)
        } catch {
            #if DEBUG
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            modelContainer = try! ModelContainer(
                for: StoryEntity.self,
                UserEntity.self,
                configurations: config
            )
            #else
            fatalError("No se pudo inicializar la base de datos: \(error)")
            #endif
        }
    }
}

// MARK: - View Model Factories

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
    func makeStoryCreationView(
        onPlantingSuccess: ((CLLocationCoordinate2D, UUID) -> Void)? = nil
    ) -> StoryCreationView {
        StoryCreationView(
            viewModel: makeStoryCreationViewModel(),
            onPlantingSuccess: onPlantingSuccess
        )
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
            deleteStoryUseCase: deleteStoryUseCase,
            syncStoriesUseCase: syncStoriesUseCase
        )
    }

    @MainActor
    func makeStoryDetailViewModel(storyId: UUID) -> StoryDetailViewModel {
        StoryDetailViewModel(
            storyId: storyId,
            getStoryDetailUseCase: getStoryDetailUseCase,
            getLocationUseCase: getLocationForPlantingUseCase,
            updateStoryUseCase: updateStoryUseCase,
            deleteStoryUseCase: deleteStoryUseCase,
            syncStoriesUseCase: syncStoriesUseCase,
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
        AuthGateViewModel(
            getCurrentSessionUseCase: getCurrentSessionUseCase,
            getAuthorProfileUseCase: getAuthorProfileUseCase,
            saveSessionNicknameUseCase: saveSessionNicknameUseCase,
            logoutUseCase: logoutUseCase
        )
    }

    @MainActor
    func makeSocialAuthViewModel() -> SocialAuthViewModel {
        SocialAuthViewModel(
            loginWithAppleUseCase: loginWithAppleUseCase,
            loginWithGoogleUseCase: loginWithGoogleUseCase
        )
    }

    @MainActor
    func makeProfileViewModel() -> ProfileViewModel {
        ProfileViewModel(
            logoutUseCase: logoutUseCase,
            getAuthorProfileUseCase: getAuthorProfileUseCase,
            saveAuthorProfileUseCase: saveAuthorProfileUseCase,
            getCurrentSessionUseCase: getCurrentSessionUseCase
        )
    }

    @MainActor
    func makeProfileView(onClose: (() -> Void)? = nil) -> ProfileView {
        ProfileView(viewModel: makeProfileViewModel(), onClose: onClose)
    }

    @MainActor
    func makeNotificationsViewModel() -> NotificationsViewModel {
        NotificationsViewModel(logService: notificationLogService)
    }

    func makeLocationService() -> LocationServiceProtocol {
        locationService
    }

    /// Syncs stories with the server, waits if a sync is already running.
    func triggerSync() async {
        guard !isSyncing else { return }
        isSyncing = true
        defer { isSyncing = false }
        await syncStoriesUseCase.execute()
    }

    @MainActor
    func makeSyncStateService() -> SyncStateService {
        syncStateService
    }

    /// For deep links: turns a string id into a `UUID` if the story exists, syncs once if it isn’t on disk yet.
    func resolveStoryIdForDeepLink(_ storyId: String) async -> UUID? {
        guard let uuid = UUID(uuidString: storyId) else { return nil }
        if (try? await storyRepository.fetchStory(by: uuid)) != nil {
            return uuid
        }
        await syncStoriesUseCase.execute()
        return (try? await storyRepository.fetchStory(by: uuid)) != nil ? uuid : nil
    }
}
