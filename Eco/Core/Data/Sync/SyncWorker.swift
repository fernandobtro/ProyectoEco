//
//  SyncWorker.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Orchestrate local-to-remote story sync (push pending rows, pull remote changes) and surface sync UI state.
//
//  Responsibilities:
//  - Push creates, updates, and deletes for pending SwiftData rows via Firestore.
//  - Pull remote deltas or a full snapshot, with optional retry and sync status callbacks.
//

import Foundation
import os

private let syncWorkerLogger = Logger(
    subsystem: Bundle.main.bundleIdentifier ?? "Eco",
    category: "SyncWorker"
)

// MARK: - SyncWorkerProtocol
protocol SyncWorkerProtocol {
    /// Runs push-then-pull. When `forceFullPull` is true, the pull resets incremental sync and re-downloads remote stories.
    func sync(forceFullPull: Bool) async
}

// MARK: - SyncWorker
final class SyncWorker: SyncWorkerProtocol {

    // MARK: - Dependencies
    private let localDataSource: StoryLocalDataSourceProtocol
    private let remoteDataSource: FirestoreStoryDataSourceProtocol
    private let syncPullUseCase: SyncPullStoriesUseCaseProtocol
    private let syncStateService: SyncStateService?
    private let retryPolicy: SyncRetryPolicy

    // MARK: - Init
    init(
        localDataSource: StoryLocalDataSourceProtocol,
        remoteDataSource: FirestoreStoryDataSourceProtocol,
        syncPullUseCase: SyncPullStoriesUseCaseProtocol,
        syncStateService: SyncStateService? = nil,
        retryPolicy: SyncRetryPolicy = .default
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
        self.syncPullUseCase = syncPullUseCase
        self.syncStateService = syncStateService
        self.retryPolicy = retryPolicy
    }

    // MARK: - Public API
    /// Pushes pending local changes, then pulls remote updates. Updates `SyncStateService` on success or failure.
    func sync(forceFullPull: Bool = false) async {
        await MainActor.run { syncStateService?.setSyncing() }
        var hadError = false

        do {
            try await pushPendingChanges()
            try await pullRemoteChanges(forceFullPull: forceFullPull)
        } catch {
            hadError = true
            syncWorkerLogger.error(
                "Sync failed: \(error.localizedDescription, privacy: .public)"
            )
            await MainActor.run { syncStateService?.setError(error.localizedDescription) }
        }

        if !hadError {
            await MainActor.run { syncStateService?.setSuccess() }
        }
    }

    // MARK: - Private helpers
    /// Uploads pending create, update, and delete rows from local storage in order.
    private func pushPendingChanges() async throws {
        let pendingStories = try await localDataSource.fetchPending()

        for story in pendingStories {
            switch SyncStatus(rawValue: story.syncStatus) {
            case .pendingCreate:
                try await handlePendingCreate(story)
            case .pendingUpdate:
                try await handlePendingUpdate(story)
            case .pendingDelete:
                try await handlePendingDelete(story)
            default:
                break
            }
        }
    }

    /// Downloads remote story changes, either incremental or full when `forceFullPull` is true.
    private func pullRemoteChanges(forceFullPull: Bool) async throws {
        if forceFullPull {
            try await syncPullUseCase.executeFullPullFromRemote()
        } else {
            try await syncPullUseCase.execute(since: nil)
        }
    }

    /// Creates the document in Firestore, assigns `remoteId`, marks the row synced, and persists locally.
    private func handlePendingCreate(_ story: StoryEntity) async throws {
        guard SyncStatus(rawValue: story.syncStatus) == .pendingCreate else { return }

        do {
            let remoteId = try await retryWithBackoff(policy: retryPolicy, operation: "CREATE id:\(story.id)") {
                try await self.remoteDataSource.create(payload: FirestoreStoryPayload(
                    title: story.title,
                    content: story.content,
                    authorID: story.authorID,
                    latitude: story.latitude,
                    longitude: story.longitude,
                    updatedAt: story.updatedAt,
                    remoteId: nil
                ))
            }

            story.remoteId = remoteId
            story.syncStatus = SyncStatus.synced.rawValue

            try await localDataSource.saveChanges()

            syncWorkerLogger.info(
                "CREATE success storyId=\(story.id.uuidString, privacy: .public) remoteId=\(remoteId, privacy: .public)"
            )
        } catch {
            syncWorkerLogger.error(
                "CREATE failed storyId=\(story.id.uuidString, privacy: .public): \(error.localizedDescription, privacy: .public)"
            )
            throw error
        }
    }

    /// Merges the story into its remote document when `remoteId` is set, then marks synced and saves locally.
    private func handlePendingUpdate(_ story: StoryEntity) async throws {
        guard SyncStatus(rawValue: story.syncStatus) == .pendingUpdate else { return }

        do {
            try await retryWithBackoff(policy: retryPolicy, operation: "UPDATE id:\(story.id)") {
                try await self.remoteDataSource.update(payload: FirestoreStoryPayload(
                    title: story.title,
                    content: story.content,
                    authorID: story.authorID,
                    latitude: story.latitude,
                    longitude: story.longitude,
                    updatedAt: story.updatedAt,
                    remoteId: story.remoteId
                ))
            }

            story.syncStatus = SyncStatus.synced.rawValue
            try await localDataSource.saveChanges()
            syncWorkerLogger.info("UPDATE success storyId=\(story.id.uuidString, privacy: .public)")
        } catch {
            syncWorkerLogger.error(
                "UPDATE failed storyId=\(story.id.uuidString, privacy: .public): \(error.localizedDescription, privacy: .public)"
            )
            throw error
        }
    }

    /// Soft-deletes on Firestore when `remoteId` exists, then always removes the local row (hard delete).
    private func handlePendingDelete(_ story: StoryEntity) async throws {
        guard SyncStatus(rawValue: story.syncStatus) == .pendingDelete else { return }

        do {
            if let remoteId = story.remoteId {
                try await retryWithBackoff(policy: retryPolicy, operation: "DELETE id:\(story.id)") {
                    try await self.remoteDataSource.softDelete(remoteId: remoteId)
                }
                syncWorkerLogger.info(
                    "DELETE remote success storyId=\(story.id.uuidString, privacy: .public) remoteId=\(remoteId, privacy: .public)"
                )
            } else {
                syncWorkerLogger.debug(
                    "DELETE skipping Firestore (never synced) storyId=\(story.id.uuidString, privacy: .public)"
                )
            }
            try await localDataSource.delete(id: story.id)
            syncWorkerLogger.info("DELETE local success storyId=\(story.id.uuidString, privacy: .public)")
        } catch {
            syncWorkerLogger.error(
                "DELETE failed storyId=\(story.id.uuidString, privacy: .public): \(error.localizedDescription, privacy: .public)"
            )
            throw error
        }
    }
}
