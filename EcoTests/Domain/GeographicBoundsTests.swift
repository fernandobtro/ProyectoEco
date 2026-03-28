//
//  GeographicBoundsTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Purpose: Sanity checks for `GeographicBounds.boundingBox`.
//

import XCTest
@testable import Eco

final class GeographicBoundsTests: XCTestCase {

    func testBoundingBox_containsCenter() {
        let centerLat = 19.43
        let centerLon = -99.13
        let box = GeographicBounds.boundingBox(
            centerLatitude: centerLat,
            centerLongitude: centerLon,
            radiusMeters: 1000
        )
        XCTAssertGreaterThanOrEqual(centerLat, box.minLatitude)
        XCTAssertLessThanOrEqual(centerLat, box.maxLatitude)
        XCTAssertGreaterThanOrEqual(centerLon, box.minLongitude)
        XCTAssertLessThanOrEqual(centerLon, box.maxLongitude)
        XCTAssertLessThan(box.maxLatitude - box.minLatitude, 1.0)
    }
}
