//
//  UserPersistenceMapperTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 26/03/26.
//
//  Purpose: Unit tests for `UserPersistenceMapper` (SwiftData row - domain `User`).
//
//  Responsibilities:
//  - Verify domain hydration attaches caller-provided story lists.
//  - Verify persistence encodes planted and found stories as UUID arrays.
//

import Foundation
import XCTest
@testable import Eco

final class UserPersistenceMapperTests: XCTestCase {

    func testToDomain_passesThroughProfileAndAttachedStories() {
        let planted = StoryBuilder.make(title: "P1")
        let found = StoryBuilder.make(title: "F1")
        let entity = UserEntity(
            id: "uid",
            name: "N",
            email: "e@mail.com",
            plantedStoryIDs: [planted.id],
            foundStoryIDs: [found.id]
        )

        let user = UserPersistenceMapper.toDomain(
            entity: entity,
            plantedStories: [planted],
            foundStories: [found]
        )

        XCTAssertEqual(user.id, "uid")
        XCTAssertEqual(user.name, "N")
        XCTAssertEqual(user.email, "e@mail.com")
        XCTAssertEqual(user.plantedStories, [planted])
        XCTAssertEqual(user.foundStories, [found])
    }

    func testToEntity_mapsStoryIdsInOrder() {
        let firstPlantedStory = StoryBuilder.make()
        let secondPlantedStory = StoryBuilder.make()
        let foundStory = StoryBuilder.make()
        let user = UserBuilder.make(
            plantedStories: [firstPlantedStory, secondPlantedStory],
            foundStories: [foundStory]
        )

        let entity = UserPersistenceMapper.toEntity(user)

        XCTAssertEqual(entity.id, user.id)
        XCTAssertEqual(entity.plantedStoryIDs, [firstPlantedStory.id, secondPlantedStory.id])
        XCTAssertEqual(entity.foundStoryIDs, [foundStory.id])
    }
}
