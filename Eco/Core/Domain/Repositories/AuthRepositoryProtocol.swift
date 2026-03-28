//
//  AuthRepositoryProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol AuthRepositoryProtocol {
    func register(email: String, password: String) async throws -> String
    func login(email: String, password: String) async throws -> String
    func logout() throws
    func currentUserId() -> String?
    func changePassword(newPassword: String) async throws
    func loginWithApple(identityToken: Data, nonce: String, fullName: PersonNameComponents?) async throws -> String
    func loginWithGoogle(idToken: String, accessToken: String) async throws -> String
}
