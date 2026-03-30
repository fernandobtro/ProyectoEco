//
//  LoginViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Binds the login form to ``LoginUseCaseProtocol`` with loading and error surface.
//

import Foundation
import Observation

/// View state for email/password sign-in.
@Observable
final class LoginViewModel {
    
    private let loginUseCase: LoginUseCaseProtocol
    
    var email: String = ""
    var password: String = ""
    
    var isLoading = false
    var errorMessage: String?
    
    init(loginUseCase: LoginUseCaseProtocol) {
        self.loginUseCase = loginUseCase
    }
    
    func login() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                _ = try await loginUseCase.execute(email: email, password: password)
            } catch {
                errorMessage = "Error al iniciar sesión"
            }
            
            isLoading = false
        }
    }
}
