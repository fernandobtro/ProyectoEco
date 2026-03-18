//
//  SwiftDataUserDataSource.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation
import SwiftData

@MainActor
class SwiftDataUserDataSource: UserLocalDataSourceProtocol {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func save(user: UserEntity) async throws {
        modelContext.insert(user)
        try modelContext.save()
    }
    
    func fetchCurrentUser() async throws -> UserEntity? {
        let descriptor = FetchDescriptor<UserEntity>()
        return try modelContext.fetch(descriptor).first
    }
    
    func updateFoundStories(userId: UUID, storyId: UUID) async throws -> Bool {
        let predicate = #Predicate<UserEntity> { user in
            user.id == userId
        }
        
        let descriptor = FetchDescriptor<UserEntity>(predicate: predicate)
        
        if let user = try modelContext.fetch(descriptor).first {
            if !user.foundStoryIDs.contains(storyId) {
                user.foundStoryIDs.append(storyId)
                try modelContext.save()
                return true
            }
            return false
        }
        return false
    }
}
