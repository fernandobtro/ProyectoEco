//
//  SyncWorker.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

protocol SyncWorkerProtocol {
    func sync() async
}

final class SyncWorker: SyncWorkerProtocol {
    private let localDataSource: StoryLocalDataSourceProtocol
    private let remoteDataSource: FirestoreStoryDataSource
    
    init(
        localDataSource: StoryLocalDataSourceProtocol,
        remoteDataSource: FirestoreStoryDataSource
    ) {
        self.localDataSource = localDataSource
        self.remoteDataSource = remoteDataSource
    }
    
    func sync() async {
        do {
            let pendingStories = try await localDataSource.fetchPending()
            
            for story in pendingStories {
                switch story.syncStatus {
                case "pendingCreate":
                    await handlePendingCreate(story)
                case "pendingUpdate":
                    await handlePendingUpdate(story)
                case "pendingDelete":
                    await handlePendingDelete(story)
                default:
                    break
                }
            }
        } catch {
            print("Sync error: \(error.localizedDescription)")
        }
    }
    
    private func handlePendingCreate(_ story: StoryEntity) async {
        guard story.syncStatus == "pendingCreate" else { return }
        
        do {
            let remoteId = try await remoteDataSource.create(story: story)
            
            story.remoteId = remoteId
            story.syncStatus = "synced"
            
            try await localDataSource.saveChanges()
            
            print("Story Synced: \(story.id)")
        } catch {
            print("Create failed: \(error.localizedDescription)")
        }
    }

    private func handlePendingUpdate(_ story: StoryEntity) async {
        guard story.syncStatus == "pendingUpdate" else { return }

        do {
            try await remoteDataSource.update(story: story)
            story.syncStatus = "synced"
            try await localDataSource.saveChanges()
            print("Story Updated: \(story.id)")
        } catch {
            print("Update failed: \(error.localizedDescription)")
        }
    }

    private func handlePendingDelete(_ story: StoryEntity) async {
        guard story.syncStatus == "pendingDelete" else { return }

        do {
            if let remoteId = story.remoteId {
                try await remoteDataSource.softDelete(remoteId: remoteId)
            }
            story.syncStatus = "synced"
            try await localDataSource.saveChanges()
            print("Story Soft-Deleted: \(story.id)")
        } catch {
            print("Delete failed: \(error.localizedDescription)")
        }
    }
}
