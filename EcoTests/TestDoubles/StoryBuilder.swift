//
//  StoryBuilder.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 26/03/26.
//
//  Purpose: Construct domain `Story` values for unit tests with stable defaults.
//
//  Responsibilities:
//  - Offer a single factory with overridable fields to avoid repetitive literals in tests.
//

import Foundation
@testable import Eco

enum StoryBuilder {

    /// Builds a `Story` with deterministic defaults, override only what the test cares about.
    static func make(
        id: UUID = UUID(),
        title: String = "Test story",
        content: String = "Test content",
        authorID: String = "author-test",
        latitude: Double = 0,
        longitude: Double = 0,
        isSynced: Bool = true,
        updatedAt: Date = Date(timeIntervalSince1970: 1_700_000_000)
    ) -> Story {
        Story(
            id: id,
            title: title,
            content: content,
            authorID: authorID,
            latitude: latitude,
            longitude: longitude,
            isSynced: isSynced,
            updatedAt: updatedAt
        )
    }
}
