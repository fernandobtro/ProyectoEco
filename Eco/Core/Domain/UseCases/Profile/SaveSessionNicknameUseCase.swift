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

import Foundation

/// Persist the user’s session nickname and mirror it to the author profile when possible.
protocol SaveSessionNicknameUseCaseProtocol {
    
    func execute(nickname: String) async
}
