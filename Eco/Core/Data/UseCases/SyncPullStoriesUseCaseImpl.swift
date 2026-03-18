//
//  SyncPullStoriesUseCaseImpl.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

final class SyncPullStoriesUseCaseImpl: SyncPullStoriesUseCaseProtocol {
    private let remoteDataSource: FirestoreStoryDataSource
    private let localDataSource: StoryLocalDataSourceProtocol
    private let lastSyncKey = "SyncPullStoriesUseCase.lastUpdatedAt"
    
    init(remoteDataSource: FirestoreStoryDataSource, localDataSource: StoryLocalDataSourceProtocol) {
        self.remoteDataSource = remoteDataSource
        self.localDataSource = localDataSource
    }
    
    func execute(since: Date?) async {
        do {
            let effectiveSince = since ?? loadLastSyncDate()
            let dtos = try await remoteDataSource.fetchStoriesUpdated(since: effectiveSince)
            
            var maxUpdatedAt = effectiveSince
            
            for dto in dtos {
                let existing = try await localDataSource.findByRemoteId(dto.remoteId)
                let entity = StoryRemoteMapper.toEntity(dto, existing: existing)
                
                if existing == nil {
                    try await localDataSource.save(story: entity)
                } else {
                    try await localDataSource.saveChanges()
                }
                
                if let currentMax = maxUpdatedAt {
                    maxUpdatedAt = max(currentMax, dto.updatedAt)
                } else {
                    maxUpdatedAt = dto.updatedAt
                }
            }
            
            if let maxUpdatedAt {
                saveLastSyncDate(maxUpdatedAt)
            }
        } catch {
            print("SyncPullStoriesUseCase error: \(error.localizedDescription)")
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
