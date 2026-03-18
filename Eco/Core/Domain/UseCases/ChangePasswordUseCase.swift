//
//  ChangePasswordUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol ChangePasswordUseCaseProtocol {
    func execute(newPassword: String) async throws
}
