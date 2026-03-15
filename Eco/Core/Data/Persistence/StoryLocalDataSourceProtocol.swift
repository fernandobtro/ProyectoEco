//
//  StoryLocalDataSourceProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 02/03/26.
//

import Foundation

protocol StoryLocalDataSourceProtocol {
    func save(story: StoryEntity) async throws
    func fetchAll() async throws -> [StoryEntity]
    func fetch(by id: UUID) async throws -> StoryEntity?
    func delete(id: UUID) async throws
}
