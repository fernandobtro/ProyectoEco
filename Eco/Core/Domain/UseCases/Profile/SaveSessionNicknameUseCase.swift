//
//  SaveSessionNicknameUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//
//  Purpose: Persist the user’s session nickname and mirror it to the author profile when possible.
//
//  Responsibilities:
//  - Trim input, reject empty or uid-like values, save locally, then upsert the remote author profile.
//

import Foundation

protocol SaveSessionNicknameUseCaseProtocol {
    // MARK: - Public API

    /// Trims whitespace, ignores empty strings and nicknames equal to the Firebase uid (case-insensitive), saves locally, then updates or creates the remote author profile. Remote failures are logged and do not surface to the user so onboarding is not blocked.
    func execute(nickname: String) async
}
