//
//  SwiftDataStoryDataSource.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation
import SwiftData

@MainActor
class SwiftDataStoryDataSource: StoryLocalDataSourceProtocol {
        
    // Dependencies
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func save(story: StoryEntity) async throws {
        modelContext.insert(story)
        try modelContext.save()
    }
    
    func fetchAll() async throws -> [StoryEntity] {
        let descriptor = FetchDescriptor<StoryEntity>()
        return try modelContext.fetch(descriptor)
    }
    
    func fetch(by id: UUID) async throws -> StoryEntity? {
        let predicate = #Predicate<StoryEntity> { story in
            story.id == id
        }
        
        let descriptor = FetchDescriptor<StoryEntity>(predicate: predicate)
        
        return try modelContext.fetch(descriptor).first
    }
    
    func delete(id: UUID) async throws {
        if let storyToDelete = try await fetch(by: id) {
            modelContext.delete(storyToDelete)
            try modelContext.save()
        }
    }
    
    func fetchPending() async throws -> [StoryEntity] {
        // Historias que aún no están sincronizadas (create/update/delete pendientes).
        let descriptor = FetchDescriptor<StoryEntity>(
            predicate: #Predicate {
                $0.syncStatus != "synced"
            }
        )
        return try modelContext.fetch(descriptor)
    }

    func saveChanges() async throws {
        try modelContext.save()
    }

    func findByRemoteId(_ id: String) async throws -> StoryEntity? {
        let predicate = #Predicate<StoryEntity> { story in
            story.remoteId == id
        }
        let descriptor = FetchDescriptor<StoryEntity>(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
}
