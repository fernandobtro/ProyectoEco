//
//  User.swift
//  Eco
//
//  Created by Fernando Buenrostro on 27/02/26.
//

import Foundation

struct User {
    let id: UUID
    let name: String
    let plantedStories: [Story]
    let foundStories: [Story]
}
