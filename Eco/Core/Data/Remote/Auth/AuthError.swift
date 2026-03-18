//
//  AuthError.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import FirebaseAuth

enum AuthError: Error {
    case noAuthenticatedUser
    case invalidCredentials
    case emailAlreadyInUse
    case unknown
}

extension AuthError {
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

