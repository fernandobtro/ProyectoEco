//
//  PreviewRootViewDependencyContainer.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: DEBUG-only ``RootViewDependencyProviding`` with stubs for canvas previews (no Firebase).
//

#if DEBUG
import Combine
import CoreLocation
import Foundation
import SwiftUI

/// Debug-only `RootViewDependencyProviding` implementation using lazy preview singletons and stub use cases.
@MainActor
final class PreviewRootViewDependencyContainer: RootViewDependencyProviding {

    // MARK: - Singleton

    static let shared = PreviewRootViewDependencyContainer()

    private init() {}

    // MARK: - Cached Dependencies

    private lazy var mapViewModel: MapViewModel = {
        MapViewModel(
            discoverUseCase: PreviewDiscoverNearbyStoriesUseCase(),
            discoveryController: PreviewDiscoveryController(),
            locationService: PreviewLocationService(),
            mapDiscoveryConfig: .default,
            syncStoriesUseCase: PreviewSyncStoriesUseCase(),
            getStoriesForGeofencingUseCase: PreviewGetStoriesForGeofencingUseCase(),
            geofencingService: GeofencingService(localNotificationService: PreviewLocalNotificationService())
        )
    }()

    private lazy var mapRouter: MapRouter = MapRouter(
        storyCreationViewFactory: { _ in nil },
        makeStoryDetailViewModel: { [weak self] id in
            guard let self else {
                preconditionFailure("PreviewRootViewDependencyContainer deallocated before resolving story detail")
            }
            return self.makeStoryDetailViewModel(storyId: id)
        },
        authorProfileByIdUseCase: PreviewGetAuthorProfileByIdUseCase()
    )

    private lazy var collectionViewModel: CollectionViewModel = CollectionViewModel(
        getPlantedStoriesUseCase: PreviewGetPlantedStoriesUseCase(),
        getDiscoveredStoriesUseCase: PreviewGetDiscoveredStoriesUseCase(),
        deleteStoryUseCase: PreviewDeleteStoryUseCase(),
        syncStoriesUseCase: PreviewSyncStoriesUseCase()
    )

    private let syncState = SyncStateService()

    // MARK: - RootViewDependencyProviding

    /// Shared `MapViewModel` backed by preview discovery and location mocks.
    func makeMapViewModel() -> MapViewModel { mapViewModel }

    /// Shared `MapRouter` with nil story creation and preview detail VM factory.
    func makeMapRouter() -> MapRouter { mapRouter }

    /// Shared `CollectionViewModel` with empty plant/discover lists and no-op sync.
    func makeCollectionViewModel() -> CollectionViewModel { collectionViewModel }

    /// Shared sync state service for preview indicators.
    func makeSyncStateService() -> SyncStateService { syncState }

    /// Profile tab with stub session and author profile use cases.
    func makeProfileView(onClose: (() -> Void)?) -> ProfileView {
        ProfileView(
            viewModel: ProfileViewModel(
                logoutUseCase: PreviewLogoutUseCase(),
                getAuthorProfileUseCase: PreviewGetAuthorProfileUseCase(),
                saveAuthorProfileUseCase: PreviewSaveAuthorProfileUseCase(),
                getCurrentSessionUseCase: PreviewGetCurrentSessionUseCase()
            ),
            onClose: onClose
        )
    }

    /// Notifications view model with an in-memory log service.
    func makeNotificationsViewModel() -> NotificationsViewModel {
        NotificationsViewModel(logService: PreviewNotificationLogService())
    }

    /// Fixed-coordinate preview location service.
    func makeLocationService() -> LocationServiceProtocol {
        PreviewLocationService()
    }

    /// Story detail VM for a given id, using preview repositories and sync stubs.
    func makeStoryDetailViewModel(storyId: UUID) -> StoryDetailViewModel {
        StoryDetailViewModel(
            storyId: storyId,
            getStoryDetailUseCase: PreviewGetStoryDetailUseCase(),
            getLocationUseCase: PreviewGetLocationForPlantingUseCase(),
            updateStoryUseCase: PreviewUpdateStoryUseCase(),
            deleteStoryUseCase: PreviewDeleteStoryUseCase(),
            syncStoriesUseCase: PreviewSyncStoriesUseCase(),
            sessionRepository: PreviewSessionRepository()
        )
    }

    /// Parses a UUID string for preview deep links, returns nil when the string is invalid.
    func resolveStoryIdForDeepLink(_ storyId: String) async -> UUID? {
        UUID(uuidString: storyId)
    }
}

// MARK: - Preview Mocks

private final class PreviewDiscoverNearbyStoriesUseCase: DiscoverNearbyStoriesUseCaseProtocol {
    func nearbyStories() -> AsyncStream<[Story]> {
        AsyncStream { continuation in
            continuation.yield([])
            continuation.finish()
        }
    }

    func setDiscoveryMode(_ mode: MapDiscoveryMode) {}

    func refreshNearUser(latitude: Double, longitude: Double) async {}

    func refreshForVisibleBounds(_ bounds: MapVisibleBounds) async {}

    func clearDisplayedStories() async {}

    func onUserLocationUpdated(latitude: Double, longitude: Double) async {}

    func currentNearbyStoryIDs() -> [UUID] { [] }
}

private final class PreviewDiscoveryController: LocationDiscoveryControlling {
    func startDiscovery() {}

    func requestPermission() async {}
}

private final class PreviewLocationService: LocationServiceProtocol {
    var delegate: LocationServiceDelegate?
    private let subject = CurrentValueSubject<CLLocationCoordinate2D?, Never>(nil)

    var locationPublisher: AnyPublisher<CLLocationCoordinate2D?, Never> {
        subject.eraseToAnyPublisher()
    }

    var lastKnownCoordinate: CLLocationCoordinate2D? { nil }

    var storiesUpdatePublisher: AnyPublisher<Void, Never> {
        Empty().eraseToAnyPublisher()
    }

    var isMonitoringEnabled: Bool { true }

    func requestWhenInUse() async throws {}

    func requestAlways() async throws {}

    func startMonitoring(stories: [Story]) {}

    func stopMonitoring() {}

    func requestSingleLocation() {}
}

private struct PreviewSyncStoriesUseCase: SyncStoriesUseCase {
    func execute() async {}

    func executeWithFullRemotePull() async {}
}

private struct PreviewGetStoriesForGeofencingUseCase: GetStoriesForGeofencingUseCaseProtocol {
    func execute(near coordinate: CLLocationCoordinate2D, limit: Int) async throws -> [Story] { [] }
}

private struct PreviewLocalNotificationService: LocalNotificationServiceProtocol {
    func scheduleStoryUnlockedNotification(storyTitle: String) async {}

    func scheduleProximityNotification(storyId: String, storyTitle: String) async {}

    func scheduleGroupedProximityNotification(count: Int) async {}
}

private struct PreviewGetPlantedStoriesUseCase: GetPlantedStoriesUseCaseProtocol {
    func execute(page: Int, pageSize: Int) async throws -> StoriesPage {
        StoriesPage(items: [], hasMore: false)
    }
}

private struct PreviewGetDiscoveredStoriesUseCase: GetDiscoveredStoriesUseCaseProtocol {
    func execute() async throws -> [Story] { [] }
}

private struct PreviewDeleteStoryUseCase: DeleteStoryUseCaseProtocol {
    func execute(storyId: UUID) async throws {}
}

private struct PreviewLogoutUseCase: LogoutUseCaseProtocol {
    func execute() throws {}
}

private struct PreviewGetAuthorProfileUseCase: GetAuthorProfileUseCase {
    func execute() async throws -> AuthorProfile? {
        AuthorProfile(
            id: "preview",
            email: "preview@example.com",
            nickname: "Preview",
            createdAt: Date()
        )
    }
}

private struct PreviewSaveAuthorProfileUseCase: SaveAuthorProfileUseCase {
    func execute(_ profile: AuthorProfile) async throws {}
}

private struct PreviewGetAuthorProfileByIdUseCase: GetAuthorProfileByIdUseCaseProtocol {
    func execute(authorId: String) async throws -> AuthorProfile? { nil }
}

private struct PreviewGetCurrentSessionUseCase: GetCurrentSessionUseCaseProtocol {
    func execute() -> String? { "preview" }

    func getNickname() -> String? { "Preview" }
}

private struct PreviewNotificationLogService: NotificationLogServiceProtocol {
    func log(_ item: NotificationItem) {}

    func fetchAll() -> [NotificationItem] { [] }
}

private struct PreviewGetStoryDetailUseCase: GetStoryDetailUseCaseProtocol {
    func execute(id: UUID) async throws -> Story? {
        Story(
            id: id,
            title: "Eco (preview)",
            content: "Contenido de ejemplo para Xcode Previews.",
            authorID: "preview",
            latitude: 19.4326,
            longitude: -99.1332,
            isSynced: true,
            updatedAt: Date()
        )
    }
}

private struct PreviewGetLocationForPlantingUseCase: GetCurrentLocationForPlantingUseCaseProtocol {
    func requestLocation() async -> CLLocationCoordinate2D? {
        CLLocationCoordinate2D(latitude: 19.4326, longitude: -99.1332)
    }
}

private struct PreviewUpdateStoryUseCase: UpdateStoryUseCaseProtocol {
    func execute(_ story: Story) async throws {}
}

private struct PreviewSessionRepository: SessionRepositoryProtocol {
    func getCurrentUserId() throws -> String { "preview" }

    func getNickname() -> String? { "Preview" }

    func saveNickname(_ name: String) {}
}

#endif
