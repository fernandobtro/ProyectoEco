//
//  EcoTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 26/03/26.
//
//  Purpose: Smoke test that the Eco test bundle links against the app module.
//
//  Responsibilities:
//  - Fail fast if `@testable import Eco` or target wiring breaks.
//

import XCTest
@testable import Eco

final class EcoTests: XCTestCase {

    func testEcoModuleLinks() {
        _ = StoryBuilder.make()
        XCTAssertTrue(true)
    }
}
