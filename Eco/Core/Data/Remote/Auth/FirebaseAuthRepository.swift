//
//  FirebaseAuthRepository.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

final class FirebaseAuthRepository: AuthRepositoryProtocol {
    
    private let dataSource: FirebaseAuthDataSource
    
    init(dataSource: FirebaseAuthDataSource) {
        self.dataSource = dataSource
    }
    
    func register(email: String, password: String) async throws -> String {
        try await dataSource.register(email: email, password: password)
    }
    
    func login(email: String, password: String) async throws -> String {
        try await dataSource.login(email: email, password: password)
    }
    
    func logout() throws {
        try dataSource.logout()
    }
    
    func currentUserId() -> String? {
        dataSource.currentUserId()
    }
    
    func changePassword(newPassword: String) async throws {
        try await dataSource.changePassword(newPassword: newPassword)
    }
}

