//
//  GetAuthorProfileUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol GetAuthorProfileUseCase {
    func execute() async throws -> AuthorProfile?
}
