//
//  DebugViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Development-only email/password probe against ``AuthRepositoryProtocol`` (prints UID or error to console).
//

import Foundation
import Observation

/// Internal tooling, not part of the shipping UX, mirrors the credential path described in `docs/EcoCorePipelines.md` — **Email Login Pipeline** without UI feedback.
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
