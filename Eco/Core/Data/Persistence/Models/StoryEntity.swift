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
//  Responsibilities:
//  - Store spatial (coordinates) and textual data for stories planted or discovered.
//  - Maintain sync metadata (remoteId, syncStatus, updatedAt) to coordinate with Firestore.
//  - Support logical deletion (soft delete) via 'deletedAt' to ensure cleanup across devices.
//

import Foundation
import SwiftData

@Model
class StoryEntity {
    @Attribute(.unique) var id: UUID
    
    var title: String
    var content: String
    var authorID: String
    var latitude: Double
    var longitude: Double
    
    var remoteId: String?
    var syncStatus: String
    var updatedAt: Date
    var deletedAt: Date?
    
    init(id: UUID, title: String, content: String, authorID: String, latitude: Double, longitude: Double, remoteId: String? = nil, syncStatus: String = "pendingCreate", updatedAt: Date = Date(), deletedAt: Date? = nil) {
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
