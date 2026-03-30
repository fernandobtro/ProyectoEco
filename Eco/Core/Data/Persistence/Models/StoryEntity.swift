//
//  StoryEntity.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//
//  Purpose: SwiftData entity for local story persistence with full synchronization state tracking.
//

import Foundation
import SwiftData

/// SwiftData entity for local story persistence with full synchronization state tracking.
@Model
class StoryEntity {
    @Attribute(.unique) var id: UUID
    
    var title: String
    var content: String
    var authorID: String
    var latitude: Double
    var longitude: Double
    
    var remoteId: String?
    var syncStatus: SyncStatus
    var updatedAt: Date
    var deletedAt: Date?
    
    init(
        id: UUID,
        title: String,
        content: String,
        authorID: String,
        latitude: Double,
        longitude: Double,
        remoteId: String? = nil,
        syncStatus: SyncStatus = .pendingCreate,
        updatedAt: Date = Date(),
        deletedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.authorID = authorID
        self.latitude = latitude
        self.longitude = longitude
        
        self.remoteId = remoteId
        self.syncStatus = syncStatus
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }
}
