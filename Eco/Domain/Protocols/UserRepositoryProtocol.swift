//
//  UserRepositoryProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 27/02/26.
//

import Foundation

protocol UserRepositoryProtocol {
    func getCurrentUser() async throws -> User?
    func updateUserProgress(userId: UUID, storyId: UUID) async throws
    func syncWithCloud() async throws 
}
