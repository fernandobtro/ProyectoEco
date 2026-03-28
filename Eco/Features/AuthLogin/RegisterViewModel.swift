//
//  RegisterViewModel.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import Observation

@Observable
final class RegisterViewModel {
    
    private let registerUseCase: RegisterUseCaseProtocol
    private let createAuthorProfileUseCase: CreateAuthorProfileUseCase
    
    var email: String = ""
    var password: String = ""
    
    var isLoading = false
    var errorMessage: String?
    
    init(
        registerUseCase: RegisterUseCaseProtocol,
        createAuthorProfileUseCase: CreateAuthorProfileUseCase
    ) {
        self.registerUseCase = registerUseCase
        self.createAuthorProfileUseCase = createAuthorProfileUseCase
    }
    
    func register() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let uid = try await registerUseCase.execute(email: email, password: password)
                
                let profile = AuthorProfile(
                    id: uid,
                    email: email,
                    nickname: email,
                    createdAt: Date()
                )
                
                try await createAuthorProfileUseCase.execute(profile: profile)
            } catch {
                errorMessage = "Error al registrarse"
            }
            
            isLoading = false
        }
    }
}
