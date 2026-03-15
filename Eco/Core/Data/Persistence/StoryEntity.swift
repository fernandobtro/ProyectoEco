//
//  StoryEntity.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation
import SwiftData

@Model
class StoryEntity {
    @Attribute(.unique) var id: UUID
    
    var title: String
    var content: String
    var authorID: UUID
    var latitude: Double
    var longitude: Double
    
    init(id: UUID, title: String, content: String, authorID: UUID, latitude: Double, longitude: Double) {
        self.id = id
        self.title = title
        self.content = content
        self.authorID = authorID
        self.latitude = latitude
        self.longitude = longitude
    }
}
