//
//  AuthError.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//
//  Purpose: Domain-specific authentication errors and Firebase to Domain error mapping.
//

import Foundation
import FirebaseAuth

/// Domain-specific authentication errors and Firebase to Domain error mapping.
enum AuthError: Error {
    case noAuthenticatedUser
    case invalidCredentials
    case emailAlreadyInUse
    /// A generic fallback for unhandled or unexpected system errors.
    case unknown
}
// MARK: - Firebase Error Mapping
extension AuthError {
    
    /// Translates raw errors from Firebase into domain-specific ``AuthError`` cases.
    /// This prevents the leaking of Firebase specific types into the upper layers, keeping the UseCases and ViewModels decoupled.
    /// - Parameter error: The raw error received from Firebase.
    /// - Returns: A simplified and mapped ``AuthError``
    static func map(_ error: Error) -> AuthError {
        let nsError = error as NSError
        
        switch nsError.code {
        case AuthErrorCode.wrongPassword.rawValue,
            AuthErrorCode.userNotFound.rawValue:
            return .invalidCredentials
            
        case AuthErrorCode.emailAlreadyInUse.rawValue:
            return .emailAlreadyInUse
            
        default: return .unknown
        }
    }
}
