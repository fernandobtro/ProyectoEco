//
//  UserLocalDataSourceProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation

protocol UserLocalDataSourceProtocol {
    func save(user: UserEntity) async throws
    func fetchCurrentUser() async throws -> UserEntity?
    func updateFoundStories(userId: UUID, storyId: UUID) async throws
}
