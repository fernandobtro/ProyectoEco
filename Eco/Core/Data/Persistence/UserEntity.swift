//
//  UserEntity.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation
import SwiftData

@Model
class UserEntity {
    @Attribute(.unique) var id: UUID
    var name: String
    var email: String
    var plantedStoryIDs: [UUID]
    var foundStoryIDs: [UUID]
    
    init(id: UUID, name: String, email: String, plantedStoryIDs: [UUID] = [], foundStoryIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.plantedStoryIDs = plantedStoryIDs
        self.foundStoryIDs = foundStoryIDs
    }
}
