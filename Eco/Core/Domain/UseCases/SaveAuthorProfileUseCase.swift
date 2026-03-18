//
//  SaveAuthorProfileUseCase.swift
//  Eco
//
//  Created by Fernando Buenrostro on 16/03/26.
//

import Foundation

protocol SaveAuthorProfileUseCase {
    func execute(_ profile: AuthorProfile) async throws
}
