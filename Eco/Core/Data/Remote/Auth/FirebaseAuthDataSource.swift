//
//  FirebaseAuthDataSource.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation
import FirebaseAuth

final class FirebaseAuthDataSource {
    
    func register(email: String, password: String) async throws -> String {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        return result.user.uid
    }
    
    func login(email: String, password: String) async throws -> String {
        
        do {
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            return result.user.uid
        } catch {
            throw AuthError.map(error)
        }
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    func currentUserId() -> String? {
        Auth.auth().currentUser?.uid
    }
    
    func changePassword(newPassword: String) async throws {
        guard let user = Auth.auth().currentUser else {
            throw AuthError.noAuthenticatedUser
        }
        
        try await user.updatePassword(to: newPassword)
    }
}
