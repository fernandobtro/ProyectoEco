//
//  RemoteStoryDTO.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation
import FirebaseFirestore

struct RemoteStoryDTO {
    let remoteId: String
    let title: String
    let content: String
    let authorId: String
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
            let latitude = Self.double(from: data["latitude"]),
            let longitude = Self.double(from: data["longitude"]),
            let updatedAtTimestamp = data["updatedAt"] as? Timestamp
        else {
            return nil
        }
        
        self.remoteId = document.documentID
        self.title = title
        self.content = content
        self.authorId = authorIdString
        self.latitude = latitude
        self.longitude = longitude
        self.updatedAt = updatedAtTimestamp.dateValue()
        
        if let deletedAtTimestamp = data["deletedAt"] as? Timestamp {
            self.deletedAt = deletedAtTimestamp.dateValue()
        } else {
            self.deletedAt = nil
        }
    }

    /// Test and tooling initializer (avoids `DocumentSnapshot`).
    internal init(
        remoteId: String,
        title: String,
        content: String,
        authorId: String,
        latitude: Double,
        longitude: Double,
        updatedAt: Date,
        deletedAt: Date? = nil
    ) {
        self.remoteId = remoteId
        self.title = title
        self.content = content
        self.authorId = authorId
        self.latitude = latitude
        self.longitude = longitude
        self.updatedAt = updatedAt
        self.deletedAt = deletedAt
    }

    private static func double(from value: Any?) -> Double? {
        switch value {
        case let doubleValue as Double: return doubleValue
        case let floatValue as Float: return Double(floatValue)
        case let intValue as Int: return Double(intValue)
        case let number as NSNumber: return number.doubleValue
        default: return nil
        }
    }
}
