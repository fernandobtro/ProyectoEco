//
//  LoginUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol LoginUseCaseProtocol {
    func execute(email: String, password: String) async throws -> String
}
