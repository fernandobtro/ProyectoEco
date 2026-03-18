//
//  CreateAuthorProfileUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol CreateAuthorProfileUseCase {
    func execute(profile: AuthorProfile) async throws
}
