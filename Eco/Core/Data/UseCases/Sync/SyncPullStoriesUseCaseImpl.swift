//
//  SyncPullStoriesUseCaseImpl.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

final class SyncPullStoriesUseCaseImpl: SyncPullStoriesUseCaseProtocol {
    private let remoteDataSource: FirestoreStoryDataSourceProtocol
    private let localDataSource: StoryLocalDataSourceProtocol
    private let lastSyncKey = "SyncPullStoriesUseCase.lastUpdatedAt"

    init(remoteDataSource: FirestoreStoryDataSourceProtocol, localDataSource: StoryLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }

    func executeFullPullFromRemote() async throws {
        UserDefaults.standard.removeObject(forKey: lastSyncKey)
        try await execute(since: nil)
    }

    func execute(since: Date?) async throws {
        do {
            let effectiveSince = since ?? loadLastSyncDate()
            let dtos = try await remoteDataSource.fetchStoriesUpdated(since: effectiveSince)
            let sorted = dtos.sorted { $0.updatedAt < $1.updatedAt }

            var maxUpdatedAt = effectiveSince

            let uniqueRemoteIds = Array(Set(sorted.map(\.remoteId)))
            let prefetched = try await localDataSource.fetchByRemoteIds(uniqueRemoteIds)
            var localsByRemoteId: [String: StoryEntity] = [:]
            for entity in prefetched {
                guard let rid = entity.remoteId else { continue }
                if localsByRemoteId[rid] == nil {
                    localsByRemoteId[rid] = entity
                }
            }

            // Procesar en orden; lastSyncDate solo al final (evita pérdida si falla a mitad)
            for dto in sorted {
                let existing = localsByRemoteId[dto.remoteId]
                let action = SyncConflictResolver.resolve(local: existing, remote: dto)

                switch action {
                case .insert(let entity):
                    try await localDataSource.saveNew(story: entity)
                    if let rid = entity.remoteId {
                        localsByRemoteId[rid] = entity
                    }
                    print("☁️ [SYNC PULL] insert id:\(dto.remoteId) (new from remote)")
                case .updateLocal:
                    try await localDataSource.saveChanges()
                    print("☁️ [SYNC PULL] updateLocal id:\(dto.remoteId) (remote newer)")
                case .keepLocal:
                    if existing != nil {
                        print("☁️ [SYNC PULL] keepLocal id:\(dto.remoteId) (local newer or pendingDelete)")
                    }
                case .deleteLocal:
                    if let existing {
                        try await localDataSource.delete(id: existing.id)
                        localsByRemoteId[dto.remoteId] = nil
                        print("☁️ [SYNC PULL] deleteLocal id:\(dto.remoteId) (remote deleted)")
                    }
                }

                if let currentMax = maxUpdatedAt {
                    maxUpdatedAt = max(currentMax, dto.updatedAt)
                } else {
                    maxUpdatedAt = dto.updatedAt
                }
            }

            // Solo guardar tras pull completo; si falla antes, no perdemos progreso
            if let maxUpdatedAt {
                saveLastSyncDate(maxUpdatedAt)
            }
        } catch {
            print("❌ [SYNC PULL] error: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - Last sync helpers
    private func loadLastSyncDate() -> Date? {
        let timeInterval = UserDefaults.standard.double(forKey: lastSyncKey)
        return timeInterval > 0 ? Date(timeIntervalSince1970: timeInterval) : nil
    }

    private func saveLastSyncDate(_ date: Date) {
        UserDefaults.standard.set(date.timeIntervalSince1970, forKey: lastSyncKey)
    }
}
