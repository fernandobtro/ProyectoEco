//
//  UserEntity.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 02/03/26.
//  Purpose: SwiftData model representing the authenticated user's local profile and story associations.
//

import Foundation
import SwiftData

/// SwiftData model representing the authenticated user's local profile and story associations.
@Model
class UserEntity {
    @Attribute(.unique) var id: String
    var name: String
    var email: String
    var plantedStoryIDs: [UUID]
    var foundStoryIDs: [UUID]

    init(id: String, name: String, email: String, plantedStoryIDs: [UUID] = [], foundStoryIDs: [UUID] = []) {
        self.id = id
        self.name = name
        self.email = email
        self.plantedStoryIDs = plantedStoryIDs
        self.foundStoryIDs = foundStoryIDs
    }
}
