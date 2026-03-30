//
//  SyncPullStoriesUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Implements `SyncPullStoriesUseCase` using repositories and async side effects.
//

import Foundation

/// Implements `SyncPullStoriesUseCase` using repositories and async side effects.
final class SyncPullStoriesUseCaseImpl: SyncPullStoriesUseCaseProtocol {
    private let remoteDataSource: FirestoreStoryDataSourceProtocol
    private let localDataSource: StoryLocalDataSourceProtocol
    private let lastSyncKey = "SyncPullStoriesUseCase.lastUpdatedAt"

    init(remoteDataSource: FirestoreStoryDataSourceProtocol, localDataSource: StoryLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    /// Clears the incremental cursor and replays a full remote pull.
    func executeFullPullFromRemote() async throws {
        UserDefaults.standard.removeObject(forKey: lastSyncKey)
        try await execute(since: nil)
    }

    /// Pulls remote updates since the effective cursor, resolves conflicts, and persists the new cursor on success.
    func execute(since: Date?) async throws {
        do {
            let effectiveSince = since ?? loadLastSyncDate()
            let dtos = try await remoteDataSource.fetchStoriesUpdated(since: effectiveSince)
            let sorted = dtos.sorted { $0.updatedAt < $1.updatedAt }
            var localsByRemoteId = try await fetchLocalsByRemoteId(from: sorted)
            let maxUpdatedAt = try await applyRemoteUpdates(
                sorted,
                startingFrom: effectiveSince,
                localsByRemoteId: &localsByRemoteId
            )

            // Persist cursor only after a complete pull
            if let maxUpdatedAt {
                saveLastSyncDate(maxUpdatedAt)
            }
        } catch {
            print("[SYNC PULL] error: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Last Sync Helpers

    /// Reads the persisted pull cursor (`updatedAt`) from `UserDefaults`.
    private func loadLastSyncDate() -> Date? {
        let timeInterval = UserDefaults.standard.double(forKey: lastSyncKey)
        return timeInterval > 0 ? Date(timeIntervalSince1970: timeInterval) : nil
    }

    /// Persists the latest applied remote `updatedAt` value as pull cursor.
    private func saveLastSyncDate(_ date: Date) {
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastSyncKey)
    }

    // MARK: - Pull Apply Helpers

    /// Prefetches local rows indexed by `remoteId` to avoid per-item local fetches during apply.
    private func fetchLocalsByRemoteId(from sorted: [RemoteStoryDTO]) async throws -> [String: StoryEntity] {
        let uniqueRemoteIds = Array(Set(sorted.map(\.remoteId)))
        let prefetched = try await localDataSource.fetchByRemoteIds(uniqueRemoteIds)
        var localsByRemoteId: [String: StoryEntity] = [:]
        for entity in prefetched {
            guard let remoteID = entity.remoteId, localsByRemoteId[remoteID] == nil else { continue }
            localsByRemoteId[remoteID] = entity
        }
        return localsByRemoteId
    }

    /// Applies the ordered remote batch and returns the max `updatedAt` reached.
    private func applyRemoteUpdates(
        _ sorted: [RemoteStoryDTO],
        startingFrom since: Date?,
        localsByRemoteId: inout [String: StoryEntity]
    ) async throws -> Date? {
        var maxUpdatedAt = since

        for dto in sorted {
            let existing = localsByRemoteId[dto.remoteId]
            try await applyOne(dto, existing: existing, localsByRemoteId: &localsByRemoteId)
            maxUpdatedAt = maxTimestamp(maxUpdatedAt, dto.updatedAt)
        }
        return maxUpdatedAt
    }

    /// Resolves and applies one remote DTO (`insert`, `updateLocal`, `keepLocal`, `deleteLocal`).
    private func applyOne(
        _ dto: RemoteStoryDTO,
        existing: StoryEntity?,
        localsByRemoteId: inout [String: StoryEntity]
    ) async throws {
        let action = SyncConflictResolver.resolve(local: existing, remote: dto)
        switch action {
        case .insert(let entity):
            try await localDataSource.saveNew(story: entity)
            if let remoteID = entity.remoteId {
                localsByRemoteId[remoteID] = entity
            }
            print("[SYNC PULL] insert id:\(dto.remoteId) (new from remote)")
        case .updateLocal:
            try await localDataSource.saveChanges()
            print("[SYNC PULL] updateLocal id:\(dto.remoteId) (remote newer)")
        case .keepLocal:
            if existing != nil {
                print("[SYNC PULL] keepLocal id:\(dto.remoteId) (local newer or pendingDelete)")
            }
        case .deleteLocal:
            if let existing {
                try await localDataSource.delete(id: existing.id)
                localsByRemoteId[dto.remoteId] = nil
                print("[SYNC PULL] deleteLocal id:\(dto.remoteId) (remote deleted)")
            }
        }
    }

    /// Returns the greater timestamp, treating `nil` as “no previous max”.
    private func maxTimestamp(_ lhs: Date?, _ rhs: Date) -> Date {
        guard let lhs else { return rhs }
        return max(lhs, rhs)
    }
}
