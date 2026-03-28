//
//  SessionRepositoryProtocol.swift
//  Eco
//
//  Copyright © 2026 Fernando Gonzalez Buenrostro.
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol SessionRepositoryProtocol {
    func getCurrentUserId() throws -> String
    func getNickname() -> String?
    func saveNickname(_ name: String)
}
