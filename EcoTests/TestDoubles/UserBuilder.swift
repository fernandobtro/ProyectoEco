//
//  UserBuilder.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 26/03/26.
//
//  Purpose: Construct domain `User` values for unit tests with stable defaults.
//
//  Responsibilities:
//  - Offer a single factory with overridable fields and optional related stories.
//

import Foundation
@testable import Eco

enum UserBuilder {

    /// Builds a `User` with deterministic defaults, override only what the test cares about.
    static func make(
        id: String = "user-test",
        name: String = "Test User",
        email: String = "test@example.com",
        plantedStories: [Story] = [],
        foundStories: [Story] = []
    ) -> User {
        User(
            id: id,
            name: name,
            email: email,
            plantedStories: plantedStories,
            foundStories: foundStories
        )
    }
}
