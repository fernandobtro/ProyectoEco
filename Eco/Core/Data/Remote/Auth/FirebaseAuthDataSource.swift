//
//  FirebaseAuthDataSource.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Implementatios of authentication services using the Firebase Auth SDK.
//
//  Responsabilities:
//  - Execute indentity provider operations (Email, Google, Apple).
//  - Map SDK specific errors to domain friendly AuthError cases.
//  - Provide synchronous and asynchronous access to the current Firebase user session.

import Foundation
import FirebaseAuth

final class FirebaseAuthDataSource {

    // MARK: - Email and Password Operations
    
    /// Registers a new user with Firebase using an email and password.
    /// - Returns: The unique Firebase UID assigned to the new user.
    func register(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }

    /// Authenticates a user and maps any Firebase errors to the domain's ``AuthError``.
    func login(email: String, password: String) async throws -> String {
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
        } catch {
            throw AuthError.map(error)
        }
    }
    
    // MARK: - Session Management

    /// Signs the user out of the current Firebase session.
    func logout() throws {
        try Auth.auth().signOut()
    }

    /// Retrieves the current user's unique identifier without initiating an async call.
    /// - Returns: The UID string if a session exists, otherwise `nil`
    func currentUserId() -> String? {
        Auth.auth().currentUser?.uid
    }

    /// Updates the password for the currently authenticated user.
    /// - Throws: `AuthError.noAuthenticatedUser` if no user is found in the current context.
    func changePassword(newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noAuthenticatedUser
        }
        try await user.updatePassword(to: newPassword)
    }
    
    // MARK: - Third-Party Sign-In Providers
    
    /// Executes Sign-in with Apple by creating an OAuth credential.
    ///
    /// - Note: Requieres an identity token string from the ASAuthorizationController.
    func signInWithApple(identityToken: Data, rawNonce: String, fullName: PersonNameComponents?) async throws -> String {
        guard let idTokenString = String(data: identityToken, encoding: .utf8) else {
            throw AuthError.invalidCredentials
        }
        let credential = OAuthProvider.appleCredential(
            withIDToken: idTokenString,
            rawNonce: rawNonce,
            fullName: fullName
        )
        let result = try await Auth.auth().signIn(with: credential)
        return result.user.uid
    }

    /// Executes Sign-in with Google using ID and Access tokens.
    func signInWithGoogle(idToken: String, accessToken: String) async throws -> String {
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        do {
            let result = try await Auth.auth().signIn(with: credential)
            return result.user.uid
        } catch {
            throw AuthError.map(error)
        }
    }
}
