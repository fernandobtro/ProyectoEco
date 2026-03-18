//
//  SessionRepositoryProtocol.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol SessionRepositoryProtocol {
    func getCurrentUserId() -> UUID
    func getNickname() -> String?
}
