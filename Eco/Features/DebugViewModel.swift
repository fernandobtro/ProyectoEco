//
//  DebugViewModel.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import Observation

@Observable
final class DebugViewModel {

    private let authRepository: AuthRepositoryProtocol
    
    var email = ""
    var password = ""
    
    init(authRepository: AuthRepositoryProtocol) {
        self.authRepository = authRepository
    }

    func login() {
        Task {
            do {
                let uid = try await authRepository.login(
                    email: email,
                    password: password
                )
                print(uid)
            } catch {
                print(error)
            }
        }
    }
}
