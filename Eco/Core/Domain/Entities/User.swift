//
//  User.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/02/26.
//

import Foundation

struct User: Equatable {
    let id: String
    let name: String
    let email: String
    let plantedStories: [Story]
    let foundStories: [Story]
}
