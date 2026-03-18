//
//  RemoteStoryDTO.swift
//  Eco
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation
import FirebaseFirestore

struct RemoteStoryDTO {
    let remoteId: String
    let title: String
    let content: String
    let authorId: UUID
    let latitude: Double
    let longitude: Double
    let updatedAt: Date
    let deletedAt: Date?
    
    init?(document: DocumentSnapshot) {
        guard
            let data = document.data(),
            let title = data["title"] as? String,
            let content = data["content"] as? String,
            let authorIdString = data["authorId"] as? String,
            let latitude = data["latitude"] as? Double,
            let longitude = data["longitude"] as? Double,
            let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        else {
            return nil
        }
        
        self.remoteId = document.documentID
        self.title = title
        self.content = content
        self.authorId = UUID(uuidString: authorIdString) ?? UUID()
        self.latitude = latitude
        self.longitude = longitude
        self.updatedAt = updatedAtTimestamp.dateValue()
        
        if let deletedAtTimestamp = data["deletedAt"] as? Timestamp {
            self.deletedAt = deletedAtTimestamp.dateValue()
        } else {
            self.deletedAt = nil
        }
    }
}
