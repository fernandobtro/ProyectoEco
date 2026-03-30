//
//  FirebaseAuthRepository.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Implementation of the AuthRepositoryProtocol using Firebase as the identity provider.
//

import Foundation

/// Implementation of the AuthRepositoryProtocol using Firebase as the identity provider.
final class FirebaseAuthRepository: AuthRepositoryProtocol {
    // MARK: - Dependencies
    private let dataSource: FirebaseAuthDataSource
    
    // MARK: - Init
    init(dataSource: FirebaseAuthDataSource) {
        self.dataSource = dataSource
    }
    
    // MARK: - Email Authentication
    
    /// Creates a new user account and returns their unique identifier.
    /// - Returns: The new user's id.
    func register(email: String, password: String) async throws -> String {
        try await dataSource.register(email: email, password: password)
    }
    
    /// Authenticates an existing user and retrieves their UID.
    /// - Returns: The authenticated user's UID.
    func login(email: String, password: String) async throws -> String {
        try await dataSource.login(email: email, password: password)
    }
    
    // MARK: - Session Management
    
    func logout() throws {
        try dataSource.logout()
    }
    
    func currentUserId() -> String? {
        dataSource.currentUserId()
    }
    
    func changePassword(newPassword: String) async throws {
        try await dataSource.changePassword(newPassword: newPassword)
    }

    // MARK: - Social Authentication
    
    /// Authenticates the user using Apple ID credentials.
    /// - Parameters:
    ///   - identityToken: The encoded identity token from Apple.
    ///   - nonce: The secure random string.
    ///   - fullName: Optional user name components provided by Apple.
    /// - Returns: The mapped Firebase UID
    func loginWithApple(identityToken: Data, nonce: String, fullName: PersonNameComponents?) async throws -> String {
        try await dataSource.signInWithApple(identityToken: identityToken, rawNonce: nonce, fullName: fullName)
    }

    /// Authenticates the user using Google ID and Access tokens.
    /// - Returns: The mapped firebase UID.
    func loginWithGoogle(idToken: String, accessToken: String) async throws -> String {
        try await dataSource.signInWithGoogle(idToken: idToken, accessToken: accessToken)
    }
}
