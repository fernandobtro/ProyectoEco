//
//  LoginWithGoogleUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

protocol LoginWithGoogleUseCaseProtocol {
    func execute(idToken: String, accessToken: String) async throws -> String
}
