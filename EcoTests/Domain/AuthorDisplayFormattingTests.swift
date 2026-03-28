//
//  AuthorDisplayFormattingTests.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/03/26.
//
//  Purpose: Unit tests for `EcoAuthorDisplayFormatting.displayNickname` (pure string rules).
//
//  Responsibilities:
//  - Document when nicknames are hidden vs shown relative to Firebase UID.
//

import XCTest
@testable import Eco

final class AuthorDisplayFormattingTests: XCTestCase {

    private let uid = "abc123firebase"

    func testDisplayNickname_nilInput_returnsNil() {
        XCTAssertNil(EcoAuthorDisplayFormatting.displayNickname(nil, authorFirebaseUid: uid))
    }

    func testDisplayNickname_emptyAfterTrim_returnsNil() {
        XCTAssertNil(EcoAuthorDisplayFormatting.displayNickname("   ", authorFirebaseUid: uid))
    }

    func testDisplayNickname_equalsUid_returnsNil() {
        XCTAssertNil(EcoAuthorDisplayFormatting.displayNickname(uid, authorFirebaseUid: uid))
    }

    func testDisplayNickname_caseInsensitiveUidMatch_returnsNil() {
        XCTAssertNil(EcoAuthorDisplayFormatting.displayNickname("AbC123Firebase", authorFirebaseUid: uid))
    }

    func testDisplayNickname_distinctNickname_returnsTrimmedValue() {
        XCTAssertEqual(
            EcoAuthorDisplayFormatting.displayNickname("  Pepe  ", authorFirebaseUid: uid),
            "Pepe"
        )
    }
}
