//
//  LoginWithAppleUseCase.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 17/03/26.
//

import Foundation

protocol LoginWithAppleUseCaseProtocol {
    func execute(identityToken: Data, nonce: String, fullName: PersonNameComponents?) async throws -> String
}
