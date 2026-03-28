//
//  StoryDistanceTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 26/03/26.
//
//  Purpose: Unit tests for `Story` distance calculations (domain + CoreLocation).
//
//  Responsibilities:
//  - Verify `Story.distance(to:)` for same point and approximate known separation.
//

import CoreLocation
import XCTest
@testable import Eco

final class StoryDistanceTests: XCTestCase {

    func testDistanceToSameCoordinateIsZero() {
        let lat = 40.416_775
        let lon = -3.703_790
        let story = StoryBuilder.make(latitude: lat, longitude: lon)
        let location = CLLocation(latitude: lat, longitude: lon)

        let meters = story.distance(to: location)

        XCTAssertEqual(meters, 0, accuracy: 0.5)
    }

    func testDistanceToOneDegreeNorthIsRoughlyOneHundredElevenKilometers() {
        // ~111 km per degree of latitude (equator-independent); good sanity check for haversine path.
        let story = StoryBuilder.make(latitude: 0, longitude: 0)
        let location = CLLocation(latitude: 1, longitude: 0)

        let meters = story.distance(to: location)

        XCTAssertEqual(meters, 111_000, accuracy: 2_000)
    }
}
