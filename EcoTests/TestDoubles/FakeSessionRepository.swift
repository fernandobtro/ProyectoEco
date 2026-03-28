//
//  FakeSessionRepository.swift
//  EcoTests
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 27/03/26.
//
//  Purpose: In-memory `SessionRepositoryProtocol` for unit tests.
//
//  Responsibilities:
//  - Provide a configurable current user id and optional nickname.
//

import Foundation
@testable import Eco

final class FakeSessionRepository: SessionRepositoryProtocol {
    var currentUserId: String = "user-test"
    var nickname: String?

    func getCurrentUserId() throws -> String {
        currentUserId
    }

    func getNickname() -> String? {
        nickname
    }

    func saveNickname(_ name: String) {
        nickname = name
    }
}
