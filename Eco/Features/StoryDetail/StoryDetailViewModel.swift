//
//  StoryDetailViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Load one story for the detail screen, distance-based unlock, and author edit/delete.
//
//  Responsibilities:
//  - Fetch story with timeout, compute author vs viewer, distance, and unlock within radius.
//  - Update or delete the story and trigger sync, surfacing errors on failure.
//

import CoreLocation
import Foundation
import Observation

// MARK: - Private loading types

private enum StoryDetailLoadingError: LocalizedError {
    case timeout

    var errorDescription: String? {
        switch self {
        case .timeout:
            return "No pudimos cargar este Eco a tiempo. Inténtalo de nuevo."
        }
    }
}

// MARK: - UI state

enum StoryDetailState: Equatable {
    case idle
    case loading
    case loaded(Story)
    case error(String)
}

@MainActor
@Observable
final class StoryDetailViewModel {

    // MARK: - Dependencies
    private let getStoryDetailUseCase: GetStoryDetailUseCaseProtocol
    private let getLocationUseCase: GetCurrentLocationForPlantingUseCaseProtocol
    private let updateStoryUseCase: UpdateStoryUseCaseProtocol
    private let deleteStoryUseCase: DeleteStoryUseCaseProtocol
    private let syncStoriesUseCase: SyncStoriesUseCase
    private let sessionRepository: SessionRepositoryProtocol

    // MARK: - Configuration
    private let unlockRadius: Double = 50.0
    private let loadTimeoutNanoseconds: UInt64 = 6_000_000_000

    // MARK: - Inputs & published state
    let storyId: UUID
    var state: StoryDetailState = .idle

    /// Whether the signed-in user is the story author.
    var isAuthor: Bool = false
    /// Full content visible (author always, or reader within `unlockRadius` meters).
    var isUnlocked: Bool = false
    /// Distance from the user to the story in meters, when location is available.
    var distanceToStory: Double?
    var isUpdating: Bool = false
    var isDeleting: Bool = false
    var updateError: String?

    // MARK: - Init

    init(
        storyId: UUID,
        getStoryDetailUseCase: GetStoryDetailUseCaseProtocol,
        getLocationUseCase: GetCurrentLocationForPlantingUseCaseProtocol,
        updateStoryUseCase: UpdateStoryUseCaseProtocol,
        deleteStoryUseCase: DeleteStoryUseCaseProtocol,
        syncStoriesUseCase: SyncStoriesUseCase,
        sessionRepository: SessionRepositoryProtocol
    ) {
        self.storyId = storyId
        self.getStoryDetailUseCase = getStoryDetailUseCase
        self.getLocationUseCase = getLocationUseCase
        self.updateStoryUseCase = updateStoryUseCase
        self.deleteStoryUseCase = deleteStoryUseCase
        self.syncStoriesUseCase = syncStoriesUseCase
        self.sessionRepository = sessionRepository
    }

    // MARK: - Derived state
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

    // MARK: - Lifecycle

    /// Loads the story for `storyId`, then resolves author versus viewer and optional distance-based unlock.
    ///
    /// - Important: Sets `.loaded` as soon as the story exists, then requests location in a second step so the UI is not blocked on GPS.
    /// - Note: Authors see full content immediately. Readers unlock when within `unlockRadius` meters if location is available.
    /// - Note: On failure or missing story, sets `state` to `.error` with a user-facing message.
    func loadDetail() async {
        #if DEBUG
        print("[StoryDetailVM] loadDetail start storyId=\(storyId.uuidString)")
        #endif
        state = .loading
        isAuthor = false
        isUnlocked = false
        distanceToStory = nil

        do {
            let result = try await fetchStoryWithTimeout()

            guard let story = result else {
                #if DEBUG
                print("[StoryDetailVM] story not found id=\(storyId.uuidString)")
                #endif
                state = .error("No encontramos este Eco.")
                return
            }
            #if DEBUG
            print("[StoryDetailVM] loaded story title='\(story.title)' authorID=\(story.authorID)")
            #endif

            state = .loaded(story)

            let currentUserId = try? sessionRepository.getCurrentUserId()
            let isAuthorNow = currentUserId.map { story.authorID == $0 } ?? false
            self.isAuthor = isAuthorNow
            self.isUnlocked = isAuthorNow
            
            guard !isAuthorNow else { return }
            if let userCoords = await getLocationUseCase.requestLocation() {
                let userLoc = CLLocation(latitude: userCoords.latitude, longitude: userCoords.longitude)
                let storyLoc = CLLocation(latitude: story.latitude, longitude: story.longitude)
                let distance = userLoc.distance(from: storyLoc)
                self.distanceToStory = distance
                self.isUnlocked = (distance <= unlockRadius)
                #if DEBUG
                print("[StoryDetailVM] distance=\(Int(distance.rounded()))m unlocked=\(self.isUnlocked)")
                #endif
            } else {
                #if DEBUG
                print("[StoryDetailVM] location unavailable for unlock check")
                #endif
            }
        } catch {
            #if DEBUG
            print("[StoryDetailVM] loadDetail error=\(error.localizedDescription)")
            #endif
            state = .error(error.localizedDescription)
        }
    }

    // MARK: - Editing

    /// Saves edited title and body, triggers background sync, then reloads detail state.
    ///
    /// - Parameters:
    ///   - title: New headline after trimming leading and trailing whitespace.
    ///   - content: New body after trimming leading and trailing whitespace.
    /// - Note: No-op when `story` is nil. On failure, sets `updateError` and does not change `state` beyond the reload attempt.
    func updateStory(title: String, content: String) async {
        guard let story = story else { return }
        isUpdating = true
        updateError = nil
        defer { isUpdating = false }

        do {
            let updated = Story(
                id: story.id,
                title: title.trimmingCharacters(in: .whitespacesAndNewlines),
                content: content.trimmingCharacters(in: .whitespacesAndNewlines),
                authorID: story.authorID,
                latitude: story.latitude,
                longitude: story.longitude,
                isSynced: false,
                updatedAt: Date()
            )
            try await updateStoryUseCase.execute(updated)
            Task { await syncStoriesUseCase.execute() }
            await loadDetail()
        } catch {
            updateError = error.localizedDescription
        }
    }

    /// Deletes the story remotely/locally via the use case, then triggers sync. Returns whether deletion succeeded or not.
    @discardableResult
    func deleteStory() async -> Bool {
        guard !isDeleting else { return false }
        isDeleting = true
        updateError = nil
        defer { isDeleting = false }

        do {
            try await deleteStoryUseCase.execute(storyId: storyId)
            Task { await syncStoriesUseCase.execute() }
            return true
        } catch {
            updateError = error.localizedDescription
            return false
        }
    }

    // MARK: - Private helpers

    /// Races `getStoryDetailUseCase` against a fixed timeout using a throwing task group.
    ///
    /// - Returns: The story from the use case, or `nil` when the row is missing or soft-deleted.
    /// - Throws: Errors from the detail use case, or `StoryDetailLoadingError.timeout` when the timeout task completes first.
    private func fetchStoryWithTimeout() async throws -> Story? {
        try await withThrowingTaskGroup(of: Story?.self) { group in
            group.addTask {
                try await self.getStoryDetailUseCase.execute(id: self.storyId)
            }
            group.addTask {
                try await Task.sleep(nanoseconds: self.loadTimeoutNanoseconds)
                throw StoryDetailLoadingError.timeout
            }

            let first = try await group.next()
            group.cancelAll()
            return first ?? nil
        }
    }
}
