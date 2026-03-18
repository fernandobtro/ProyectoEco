//
//  UserRepositoryProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 27/02/26.
//

import Foundation

protocol UserRepositoryProtocol {
    func getCurrentUser() async throws -> User?
    /// Devuelve `true` cuando la historia se marca como descubierta por primera vez.
    func updateUserProgress(userId: UUID, storyId: UUID) async throws -> Bool
    func syncWithCloud() async throws 
}
